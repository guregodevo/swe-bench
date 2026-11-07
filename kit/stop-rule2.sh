#!/bin/bash
# The maintainer's rule, fail fast (2026-11-05): when team-solve fails an instance its own first try (direct.patch)
# resolves, it is written to $O/alerts.log and this machine's runs stop (watch4.sh stops the other three). After
# the fix the run starts again from the first instance, so every published run is one pass on one version (pass@1).
# The separate single run is another sample of the same model: it shows the spread, it does not stop the run.
# A kit fault stops the run too, as its own alert: a score the harness could not give (ERROR) or a run whose
# container never started (docker-failed). Run 1 (2026-11-06) was stopped by an ERROR counted as team failing.
# Partial results not as expected stop it too (the maintainer, 2026-11-07, "fail fast if partial results are not
# as expected"): a team run that ended without keep.txt (the run did not reach keep and verify, #151); twenty
# team runs and not one reproduction written (#150); and, from twenty team scores on, this machine losing to the
# previous run's team (~/kit/old-team-resolved.txt) on more instances than it gains by four or 15% of the scored.
O=~/out2
while true; do
  hit=$(python3 - <<'PY'
import glob, os
O = os.path.expanduser("~/out2"); v = {}
for l in open(f"{O}/scores.tsv") if os.path.exists(f"{O}/scores.tsv") else []:
    f = l.rstrip("\n").split("\t")
    if len(f) >= 3: v[(f[0], f[1])] = f[2]
for (i, var), s in sorted(v.items()):
    if var == "direct" and s.startswith("RESOLVED") and v.get((i, "team"), "").startswith("UNRESOLVED"):
        print(f"ALERT: {i} first try RESOLVED, team not")
    if s.startswith("ERROR"):
        print(f"ALERT (kit): {i} {var} scored {s}")
ran = []
for l in open(f"{O}/results.tsv") if os.path.exists(f"{O}/results.tsv") else []:
    f = l.rstrip("\n").split("\t")
    if len(f) >= 3 and f[2] == "docker-failed":
        print(f"ALERT (kit): {f[0]} {f[1]} docker-failed after three starts")
    if len(f) >= 3 and f[1] == "team" and f[2].startswith("wf="):
        ran.append(f[0])
# Every finished team run reached keep (its folder has keep.txt).
repros = 0
for i in ran:
    runs = glob.glob(f"{O}/runs/{i}-team/team-solve-*")
    if runs and not os.path.exists(runs[0] + "/keep.txt"):
        print(f"ALERT (kit): {i} team ended without keep.txt")
    if runs and os.path.exists(runs[0] + "/repro"):
        repros += 1
if len(ran) >= 20 and repros == 0:
    print(f"ALERT (kit): {len(ran)} team runs and no reproduction written")
# From twenty team scores on, this machine is not losing to the previous run's team.
old = set(open(os.path.expanduser("~/kit/old-team-resolved.txt")).read().split()) if os.path.exists(os.path.expanduser("~/kit/old-team-resolved.txt")) else set()
scored = [(i, s.startswith("RESOLVED")) for (i, var), s in v.items() if var == "team" and not s.startswith("ERROR")]
if old and len(scored) >= 20:
    lost = sum(1 for i, ok in scored if i in old and not ok); gained = sum(1 for i, ok in scored if i not in old and ok)
    if lost - gained >= max(4, 0.15 * len(scored)):
        print(f"ALERT (score): {len(scored)} team scores, lost {lost} the previous run resolved, gained {gained}")
PY
)
  if [ -n "$hit" ]; then
    printf '%s\n' "$hit" | while read -r line; do echo "$(date -u +%FT%TZ) $line"; done | tee -a $O/alerts.log
    pkill -f "[k]it/run-docker.sh"; pkill -f "[x]args -P"; pkill -f '[o]ne "\$0"'
    sg docker -c "docker ps -aq --filter name=swe- | xargs -r docker rm -f" >/dev/null 2>&1
    pkill -f "[k]it/score2.sh"; exit 0
  fi
  [ -f $O/run-finished ] && ! pgrep -f "[k]it/score2.sh" >/dev/null && exit 0   # the last scores checked too
  sleep 30
done
