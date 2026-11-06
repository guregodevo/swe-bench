#!/bin/bash
# The maintainer's rule, fail fast (2026-11-05): when team-solve fails an instance its own first try (direct.patch)
# resolves, it is written to $O/alerts.log and this machine's runs stop (watch4.sh stops the other three). After
# the fix the run starts again from the first instance, so every published run is one pass on one version (pass@1).
# The separate single run is another sample of the same model: it shows the spread, it does not stop the run.
# A kit fault stops the run too, as its own alert: a score the harness could not give (ERROR) or a run whose
# container never started (docker-failed). Run 1 (2026-11-06) was stopped by an ERROR counted as team failing.
O=~/out2
while true; do
  hit=$(python3 - <<'PY'
import os
O = os.path.expanduser("~/out2"); v = {}
for l in open(f"{O}/scores.tsv") if os.path.exists(f"{O}/scores.tsv") else []:
    f = l.rstrip("\n").split("\t")
    if len(f) >= 3: v[(f[0], f[1])] = f[2]
for (i, var), s in sorted(v.items()):
    if var == "direct" and s.startswith("RESOLVED") and v.get((i, "team"), "").startswith("UNRESOLVED"):
        print(f"ALERT: {i} first try RESOLVED, team not")
    if s.startswith("ERROR"):
        print(f"ALERT (kit): {i} {var} scored {s}")
for l in open(f"{O}/results.tsv") if os.path.exists(f"{O}/results.tsv") else []:
    f = l.rstrip("\n").split("\t")
    if len(f) >= 3 and f[2] == "docker-failed":
        print(f"ALERT (kit): {f[0]} {f[1]} docker-failed after three starts")
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
