#!/bin/bash
# rerun-prep.sh: run 2's tasks on which web_search answered (~/kit/rerun-ids.txt, 126 tasks, both variants) run
# again with no web tools, on the machine that ran them. Their run-2 rows, patches, runs, traces and meters move to
# ~/out2/web-run2/ (kept, never scored again); this machine's share goes to ~/kit/shard-rerun.txt for start2.sh.
O=~/out2; A=$O/web-run2
pkill -f "[k]it/run-docker.sh"; pkill -f "[x]args -P"; pkill -f '[o]ne "\$0"'; pkill -f "[k]it/score2.sh"; pkill -f "[k]it/stop-rule2.sh"
sg docker -c "docker ps -aq --filter name=swe- | xargs -r docker rm -f" >/dev/null 2>&1
[ -d $A ] && { echo "$A exists: already prepared"; exit 1; }
mkdir -p $A/patches $A/runs $A/trajs $A/meters $A/logs
awk -F'\t' '$3 ~ /^wf=/ {print $1}' $O/results.tsv | sort -u | grep -xF -f ~/kit/rerun-ids.txt > ~/kit/shard-rerun.txt
for id in $(cat ~/kit/shard-rerun.txt); do
  for v in single team direct; do
    mv $O/patches/$id-$v.diff $A/patches/ 2>/dev/null; mv $O/meters/$id-$v.jsonl $A/meters/ 2>/dev/null
    [ -e $O/runs/$id-$v ] && sudo mv $O/runs/$id-$v $A/runs/
    [ -e $O/trajs/$id-$v ] && sudo mv $O/trajs/$id-$v $A/trajs/
    mv $O/logs/$id-$v.* $A/logs/ 2>/dev/null
  done
done
python3 - <<'PY'
import os
O = os.path.expanduser("~/out2"); A = O + "/web-run2"
ids = set(open(os.path.expanduser("~/kit/shard-rerun.txt")).read().split())
for name in ("results.tsv", "scores.tsv"):
    keep, move = [], []
    for l in open(f"{O}/{name}"):
        f = l.rstrip("\n").split("\t")
        (move if f[0] in ids and (name == "scores.tsv" or (len(f) > 2 and f[2].startswith("wf="))) else keep).append(l)
    open(f"{A}/{name}", "w").writelines(move); open(f"{O}/{name}", "w").writelines(keep)
    print(name, "moved", len(move), "kept", len(keep))
PY
rm -f $O/run-finished $O/budget.log
echo "$(hostname -s): $(wc -l < ~/kit/shard-rerun.txt) tasks to rerun, $(~/kit/memdoor version | head -1)"
