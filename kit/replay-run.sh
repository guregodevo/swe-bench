#!/bin/bash
# replay-run.sh: the read-only replay on a scoring VM, 12 instances a batch, images removed after each.
# Every wrong attempt and N_RIGHT right ones (seed 0), alternated: the rate on right attempts is known
# from the first batch, and the run can stop as soon as the two rates are clear. A restart skips the
# instances in results.jsonl. The VM powers off at the end; set a timer too (sudo shutdown -h +180).
#   R=~/replay N_RIGHT=75 nohup kit/replay-run.sh > ~/replay/run.out 2>&1 &
R=${R:-~/replay}; N=${N_RIGHT:-75}; export R; cd ~; touch $R/results.jsonl
ids=$(R=$R N=$N python3 - <<'PY'
import json, os, random
R = os.environ["R"]; n = int(os.environ["N"])
m = json.load(open(f"{R}/meta.json")); done = {json.loads(l)["id"] for l in open(f"{R}/results.jsonl")}
wrong = [x["id"] for x in m if not x["resolved"]]; right = sorted(x["id"] for x in m if x["resolved"])
random.seed(0); right = random.sample(right, min(n, len(right)))
k = max(len(wrong), len(right)); pick = [x for p in zip(wrong + [None] * k, right + [None] * k) for x in p if x]
print(" ".join(i for i in pick if i not in done))
PY
)
set -- $ids
while [ $# -gt 0 ]; do
  batch="${@:1:12}"; shift $(( $# < 12 ? $# : 12 )); b=$(date +%s)
  for v in base attempt; do
    sg docker -c "/opt/swe/bin/python -m swebench.harness.run_evaluation -d $R/ds.json -p $R/pred-$v.json -i $batch --max_workers 6 -id rp$b-$v --report_dir $R/reports" > $R/log-$b-$v.txt 2>&1
  done
  /opt/swe/bin/python $HOME/kit/replay-parse.py $b $batch >> $R/results.jsonl
  for i in $batch; do
    img=$(python3 -c "import json,sys; print([r['image'] for r in json.load(open('$R/ds.json')) if r['instance_id'] == sys.argv[1]][0])" "$i")
    sg docker -c "docker rmi -f $img" > /dev/null 2>&1
  done
  sg docker -c "docker image prune -f" > /dev/null 2>&1
  echo "$(date +%T) batch $b done: $(wc -l < $R/results.jsonl) results" >> $R/progress.txt
done
touch $R/finished; sudo shutdown -h now
