#!/bin/bash
# restart-vm.sh: stop the runner, the scorer and the stop rule and the run containers; drop the rows of runs the
# stop left unfinished (a signal's status, a failed exec, docker-failed) and their scores, so they run again;
# then start again on the shard with the key on stdin (ARMS as exported).
O=~/out2
pkill -f "[k]it/run-docker.sh"; pkill -f "[x]args -P"; pkill -f "[k]it/score2.sh"; pkill -f "[k]it/stop-rule2.sh"
sg docker -c 'docker ps -aq --filter name=swe- | xargs -r docker rm -f' >/dev/null 2>&1
sleep 2
python3 - <<'PY'
import os
O = os.path.expanduser("~/out2"); drop = set(); keep = []
for l in open(f"{O}/results.tsv") if os.path.exists(f"{O}/results.tsv") else []:
    f = l.rstrip("\n").split("\t")
    s = f[2] if len(f) > 2 else ""
    if s == "docker-failed" or (s.startswith("wf=") and (not s[3:].isdigit() or int(s[3:]) >= 125)):
        drop.add((f[0], f[1]))
    else:
        keep.append(l)
open(f"{O}/results.tsv", "w").writelines(keep)
ids = {i for i, _ in drop}
if os.path.exists(f"{O}/scores.tsv"):
    rows = [l for l in open(f"{O}/scores.tsv") if l.split("\t")[0] not in ids]
    open(f"{O}/scores.tsv", "w").writelines(rows)
print(f"dropped {len(drop)} unfinished runs: {' '.join(sorted(ids))}")
PY
[ -f $O/alerts.log ] && mv $O/alerts.log $O/alerts-$(date +%s).log
rm -f $O/run-finished
bash ~/kit/start2.sh 6 ~/kit/shard.txt
