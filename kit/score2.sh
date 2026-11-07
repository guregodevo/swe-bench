#!/bin/bash
# score2.sh: score every instance whose two runs are in, a batch at a time, with the official harness; images removed after each batch.
# Three patches each: the single run, team-solve's final tree, and team-solve's own first try (direct.patch, saved before the
# team touches it). The stop rule compares the last two: the team never ends worse than its own first try.
O=~/out2; cd ~; export HF_HUB_DISABLE_TELEMETRY=1; touch $O/scores.tsv
while true; do
  # Seen before the list is read: a result written after it is in the next pass, never lost to the exit below.
  fin=; [ -f $O/run-finished ] && fin=1
  ready=$(python3 - <<'PY'
import os
O = os.path.expanduser("~/out2"); done = set()
for l in open(f"{O}/scores.tsv"):
    f = l.split("\t")
    if len(f) >= 2: done.add((f[0], f[1]))
have = {}
for l in open(f"{O}/results.tsv") if os.path.exists(f"{O}/results.tsv") else []:
    f = l.split("\t")
    if len(f) >= 3 and f[2].startswith("wf="): have.setdefault(f[0], set()).add(f[1])   # a run that ran: never docker-failed
arms = set(os.environ.get("ARMS", "single team").split())   # the arms this run makes (ARMS=team: the team alone)
print(" ".join([i for i, v in have.items() if arms <= v and (i, sorted(arms)[0]) not in done][:12]))
PY
)
  if [ -z "$ready" ]; then [ -n "$fin" ] && break; sleep 60; continue; fi
  b=$(date +%s)
  # team-solve's own first try, as the run saved it (none: an empty patch), without its test files like the team's
  # patch (strip-tests.py): a first try that had rewritten an existing test scored RESOLVED against the team's stripped
  # patch, the same tree, and the net rule stopped run 3 on it (django-11141, 2026-11-07).
  for id in $ready; do f=$(ls $O/runs/$id-team/team-solve-*/direct.patch 2>/dev/null | head -1); if [ -n "$f" ]; then python3 -I $HOME/kit/strip-tests.py < "$f" > $O/patches/$id-direct.diff; else : > $O/patches/$id-direct.diff; fi; done
  for v in ${ARMS:-single team} $(printf '%s\n' "${ARMS:-single team}" | grep -qw team && echo direct); do
    ids=$ready
    if [ "$v" = direct ]; then
      # A first try the team left as it was has the team's score: the same lines changed.
      ids=""
      for id in $ready; do
        if diff -q <(grep -E '^[+-]' $O/patches/$id-direct.diff | grep -vE '^(\+\+\+|---) ') <(grep -E '^[+-]' $O/patches/$id-team.diff | grep -vE '^(\+\+\+|---) ') >/dev/null; then
          printf '%s\t%s\t%s\n' "$id" direct "$(grep -P "^$id\tteam\t" $O/scores.tsv | tail -1 | cut -f3) (same as team)" >> $O/scores.tsv
        else ids="$ids $id"; fi
      done
      [ -z "$ids" ] && continue
    fi
    # Written fresh for this batch: a batch whose files could not be written used the last batch's, and the harness
    # refused every id (run 1, 2026-11-06). A run with no patch file is an empty patch.
    rm -f $O/pred-$v.json $O/ds-batch.json
    python3 - "$v" $ids <<'PY'
import json, os, sys
v, ids = sys.argv[1], sys.argv[2:]; O = os.path.expanduser("~/out2")
def patch(i):
    p = f"{O}/patches/{i}-{v}.diff"
    return open(p).read() if os.path.exists(p) else ""
json.dump([{"instance_id": i, "model_name_or_path": "memdoor-" + v, "model_patch": patch(i)} for i in ids], open(f"{O}/pred-{v}.json", "w"))
rows = [r for r in json.load(open(os.path.expanduser("~/verified.json"))) if r["instance_id"] in ids]
json.dump(rows, open(f"{O}/ds-batch.json", "w"))
PY
    hrc=1; [ -s $O/pred-$v.json ] && [ -s $O/ds-batch.json ] && { sg docker -c "/opt/swe/bin/python -m swebench.harness.run_evaluation -d $O/ds-batch.json -p $O/pred-$v.json -i $ids --max_workers 6 -id b$b-$v --report_dir $O/reports" > $O/logs/score-b$b-$v.txt 2>&1; hrc=$?; }
    for id in $ids; do
      rep=$(ls logs/run_evaluation/b$b-$v/memdoor-$v/$id/report.json 2>/dev/null)
      if [ ! -s "$O/patches/$id-$v.diff" ]; then s="UNRESOLVED (empty patch)"
      elif [ -n "$rep" ]; then s=$(python3 -c "import json; print('RESOLVED' if json.load(open('$rep'))['$id']['resolved'] else 'UNRESOLVED')")
      elif [ $hrc != 0 ]; then s="ERROR (harness exit $hrc: logs/score-b$b-$v.txt)"   # the kit's fault, never the patch's
      else s="ERROR"; fi
      printf '%s\t%s\t%s\n' "$id" "$v" "$s" >> $O/scores.tsv
    done
  done
  # Only this batch's images, and never one a container still uses: removing every sweb.eval image took the ones the
  # runner was pulling for its next instances (the likely cause of run 1's failed layer extraction).
  for id in $ready; do
    img=$(python3 -c "import json; print([x for x in json.load(open('$HOME/verified.json')) if x['instance_id']=='$id'][0]['image'])")
    sg docker -c "docker ps -q --filter ancestor=$img | grep -q . || docker rmi $img" >/dev/null 2>&1
  done
  sg docker -c 'docker image prune -f' >/dev/null 2>&1
done
