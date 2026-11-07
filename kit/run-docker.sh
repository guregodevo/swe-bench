#!/bin/bash
# run-docker.sh [parallel] [ids file]: every SWE-bench Verified instance not yet run, as the single call
# and as team-solve, each in its own container of the instance's image (the repository at /testbed with
# its environment installed), with its own memdoor gateway inside. The Check and the agents' own test
# runs then work, as they do on a developer's machine. Results in ~/out2.
K=${1:-5}; O=${OUT:-~/out2}; mkdir -p $O/patches $O/logs $O/runs
M="openrouter:deepseek/deepseek-v4.1-flash"
# The key from the host gateway's environment: never on a command line, never in a file.
# Launch it as: export the key (start.sh does), then sg docker -c "~/kit/run-docker.sh ...".
[ -n "$OPEN_ROUTER_API_KEY" ] || { echo "no key in the host gateway's environment"; exit 1; }
[ -f $O/usage-start ] || curl -s -m 10 https://openrouter.ai/api/v1/key -H "Authorization: Bearer $OPEN_ROUTER_API_KEY" | python3 -c "import json,sys;print(json.load(sys.stdin)['data']['usage'])" > $O/usage-start
# No web: each task's container is on an internal network whose only way out is allow-proxy.py, which
# tunnels to openrouter.ai (the model) and refuses everything else, logged to $O/proxy.log. The SWE-bench
# checklist: "has taken steps to prevent lookup of SWE-bench solutions via web-browsing".
docker network inspect swe-internal >/dev/null 2>&1 || docker network create --internal swe-internal >/dev/null
if [ "$(docker inspect -f '{{.State.Running}}' swe-proxy 2>/dev/null)" != true ]; then
  docker rm -f swe-proxy >/dev/null 2>&1
  docker run -d --name swe-proxy --restart unless-stopped -v $HOME/kit/allow-proxy.py:/p/allow-proxy.py:ro -v $O:/out python:3.12-slim \
    sh -c 'exec python -u /p/allow-proxy.py 3128 >> /out/proxy.log 2>&1' >/dev/null && docker network connect swe-internal swe-proxy
fi
spent_total() { # dollars since this run's first usage check; "x" when it cannot be read (then nothing starts)
  local u=$(curl -s -m 10 https://openrouter.ai/api/v1/key -H "Authorization: Bearer $OPEN_ROUTER_API_KEY" | python3 -c "import json,sys;print(json.load(sys.stdin)['data']['usage'])" 2>/dev/null)
  [ -n "$u" ] || { echo x; return; }
  python3 -c "print(round($u - $(cat $O/usage-start), 3))"
}
one() { # instance variant
  local id=$1 v=$2 wf=single; [ "$v" = team ] && wf=team-solve
  grep -q "^$id	$v	" $O/results.tsv 2>/dev/null && return
  local c="swe-$id-$v"
  docker inspect "$c" >/dev/null 2>&1 && return   # in flight from an earlier runner
  local s=$(spent_total)
  if [ "$s" = x ] || python3 -c "import sys; sys.exit(0 if $s >= $(cat $O/cap 2>/dev/null || echo 40) else 1)"; then
    echo "$(date -u +%FT%TZ) cap: spent $s, not starting $id $v" >> $O/budget.log; return; fi
  local img=$(python3 -c "import json; print([x for x in json.load(open('$HOME/verified.json')) if x['instance_id']=='$id'][0]['image'])")
  # One pull per image at a time: single and team pulled the same image at once while the scorer removed images, and
  # containerd failed to extract a layer (run 1, 2026-11-06, django-14915: "failed to Lchown"). Then up to three starts.
  local lock=/tmp/swe-pull-$(printf %s "$img" | md5sum | cut -c1-12).lock n=0
  # Docker Hub allows an address 100 anonymous pulls in 6 hours: a pull it refuses for that waits ten minutes and
  # tries again, as long as it takes (a kit fault that spent a machine's pulls in minutes stopped phase A, 2026-11-07).
  while :; do
    if ! flock "$lock" docker pull -q "$img" >> $O/logs/$id-$v.docker 2>&1; then
      if tail -15 $O/logs/$id-$v.docker | grep -qiE "rate limit|too ?many ?requests|: 429"; then
        echo "$(date -u +%FT%TZ) $id $v: Docker Hub's pull rate limit; waiting 10 min" >> $O/pulls.log; sleep 600; continue
      fi
      n=$((n + 1)); [ $n -ge 3 ] && break; sleep $((n * 20)); continue
    fi
    docker run -d --name "$c" --network swe-internal \
      -e HTTPS_PROXY=http://swe-proxy:3128 -e HTTP_PROXY=http://swe-proxy:3128 -e https_proxy=http://swe-proxy:3128 -e http_proxy=http://swe-proxy:3128 -e NO_PROXY=localhost,127.0.0.1 -e no_proxy=localhost,127.0.0.1 \
      -e OPEN_ROUTER_API_KEY -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e PYTHONIOENCODING=utf-8 -e PATH=/opt/miniconda3/envs/testbed/bin:/opt/miniconda3/condabin:/opt/miniconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
      -v $HOME/kit:/kit:ro -w /testbed "$img" sleep infinity >/dev/null 2>>$O/logs/$id-$v.docker && break
    docker rm -f "$c" >/dev/null 2>&1; docker rmi -f "$img" >/dev/null 2>&1
    n=$((n + 1)); [ $n -ge 3 ] && break; sleep $((n * 20))
  done
  # A container that never started is no result: the id keeps no row, so the next start of the runner takes it
  # again (a docker-failed row once stopped all four machines for a pull Docker Hub refused, 2026-11-07).
  if [ "$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)" != true ]; then echo "$(date -u +%FT%TZ) $id $v: the container never started after three tries ($O/logs/$id-$v.docker)" >> $O/docker-failed.log; return; fi
  # Only the problem statement goes in: never the patch, the tests or the hints.
  python3 -c "import json; print([x for x in json.load(open('$HOME/verified.json')) if x['instance_id']=='$id'][0]['problem_statement'])" | docker exec -i "$c" sh -c 'cat > /tmp/prompt.txt'
  local t0=$(date +%s)
  docker exec -i "$c" bash -c '
    cd /testbed; git config --global --add safe.directory /testbed; git rev-parse HEAD > /tmp/base
    mkdir -p .memdoor/workflows; cp -R /kit/workflows/team-solve /kit/workflows/single .memdoor/workflows/
    /kit/memdoor gateway --port 18797 > /tmp/gateway.log 2>&1 &
    for i in $(seq 1 60); do curl -s -m 2 localhost:18797/health >/dev/null && break; sleep 1; done
    # No web tools: web_search reached the web through openrouter.ai in run 2. The agents are seeded at the first
    # sign-in, so this machine signs in first (the account `workflow run` would make: <user>@localhost, workspace
    # Memdoor), the palettes lose the web tools, and only then the workflow starts; the watch stays as a backstop.
    MEMDOOR_GATEWAY=http://localhost:18797 /kit/memdoor setup --admin-email "$(id -un)@localhost" --admin-password "$(head -c 24 /dev/urandom | base64 | tr -dc A-Za-z0-9)" --workspace-name Memdoor > /tmp/setup.log 2>&1
    python3 /kit/weboff.py --once > /tmp/weboff.log 2>&1 || exit 97
    python3 /kit/weboff.py >> /tmp/weboff.log 2>&1 &
    MEMDOOR_GATEWAY=http://localhost:18797 /kit/memdoor workflow run '"$wf"' --model '"$M"' --timeout 4h --wait - < /tmp/prompt.txt' > $O/logs/$id-$v.txt 2>&1; local rc=$?
  docker exec "$c" bash -c 'cd /testbed; git add -A -N -- . ":(exclude).memdoor" 2>/dev/null; git diff "$(cat /tmp/base)" -- . ":(exclude).memdoor"' > $O/patches/$id-$v.raw.diff
  # The submission is the change without its test files (strip-tests.py): the harness applies the hidden test patch on
  # top, and a test file the agent adds at the same path, or an edit inside a hunk it touches, makes that fail. Five
  # team patches of run 2 scored as wrong for it (2026-11-07). The raw diff stays beside it for the trajectory.
  python3 -I $HOME/kit/strip-tests.py < $O/patches/$id-$v.raw.diff > $O/patches/$id-$v.diff
  # An earlier run's folder would take this one inside it (docker cp into an existing directory).
  [ -e $O/runs/$id-$v ] && mv $O/runs/$id-$v $O/runs/.old-$id-$v-$(date +%s)
  docker cp "$c:/testbed/.memdoor/runs" $O/runs/$id-$v >/dev/null 2>&1
  # The cost: this container's gateway served only this run, so its meter is the run's every model call,
  # agent turns and llm steps, with OpenRouter's own cost_usd. Kept whole, and summed on the result line.
  # The reasoning trace, written as the run went (the leaderboard requires one per instance): every agent
  # step's session, the run's folder above (plan, proposals, review, verdict, keep) and the gateway's log.
  mkdir -p $O/trajs/$id-$v; docker cp "$c:/root/.memdoor/workflow-sessions" $O/trajs/$id-$v/sessions >/dev/null 2>&1
  docker cp "$c:/tmp/gateway.log" $O/trajs/$id-$v/gateway.log >/dev/null 2>&1
  docker cp "$c:/root/.memdoor/logs" $O/trajs/$id-$v/logs >/dev/null 2>&1   # the gateway's own log: retries, cuts, errors
  docker cp "$c:/tmp/weboff.log" $O/trajs/$id-$v/weboff.log >/dev/null 2>&1
  [ "$rc" = 97 ] && echo "$(date -u +%FT%TZ) ALERT (kit): $id $v weboff --once changed no palette, the workflow did not start" >> $O/alerts.log
  docker cp "$c:/tmp/setup.log" $O/trajs/$id-$v/setup.log >/dev/null 2>&1
  docker exec "$c" test -f /tmp/weboff.ok || echo "$(date -u +%FT%TZ) ALERT (kit): $id $v weboff never found a web tool to remove" >> $O/alerts.log
  # Fail fast on the web: a model offered a web tool (the gateway's own record of each request) or an agent that
  # called one stops the runs on all four machines (watch4.sh reads alerts.log).
  local web=$(python3 - $O/trajs/$id-$v <<'PY'
import glob, json, sqlite3, sys
d = sys.argv[1]; hits = set()
for p in glob.glob(d + "/logs/events.db"):
    for (data,) in sqlite3.connect(p).execute("SELECT data FROM events WHERE message LIKE 'LLM request caller%'"):
        names = json.loads(data).get("tool_names", "") if data else ""
        hits |= {t for t in ("web_search", "web_fetch") if t in names}
for p in glob.glob(d + "/sessions/*.json"):
    for l in open(p, errors="replace"):
        hits |= {t for t in ("web_search", "web_fetch") if '"name":"%s"' % t in l.replace(" ", "")}
print(",".join(sorted(hits)))
PY
)
  [ -n "$web" ] && echo "$(date -u +%FT%TZ) ALERT (web): $id $v offered or called $web" >> $O/alerts.log
  mkdir -p $O/meters; docker cp "$c:/root/.memdoor/meter.jsonl" $O/meters/$id-$v.jsonl >/dev/null 2>&1 || : > $O/meters/$id-$v.jsonl
  local cost=$(python3 - $O/meters/$id-$v.jsonl <<'PY'
import json, sys
c = i = k = o = n = 0
for l in open(sys.argv[1]):
    try: r = json.loads(l)
    except ValueError: continue
    c += r.get("cost_usd") or 0; i += r.get("input_tokens") or 0; k += r.get("cached_tokens") or 0; o += r.get("output_tokens") or 0; n += 1
print("cost=%.6f\tin=%d\tcached=%d\tout=%d\tcalls=%d" % (c, i, k, o, n))
PY
)
  printf '%s\t%s\twf=%s\t%ss\t%s lines\t%s\n' "$id" "$v" "$rc" "$(( $(date +%s)-t0 ))" "$(wc -l < $O/patches/$id-$v.diff)" "$cost" >> $O/results.tsv
  docker rm -f "$c" >/dev/null 2>&1
}
export -f one spent_total; export O M
if [ -n "${2:-}" ]; then cat "$2"; else python3 -c "import json; [print(r['instance_id']) for r in json.load(open('$HOME/verified.json'))]"; fi \
  | while read id; do for v in ${ARMS:-single team}; do echo "$id $v"; done; done | xargs -P $((K * $(echo ${ARMS:-single team} | wc -w))) -L 1 bash -c 'one "$0" "$1"'
touch $O/run-finished   # the list (all of Verified, or a shard) is done
