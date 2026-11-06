#!/bin/bash
# shard.sh <k> <n> <fresh|keep>: stop this machine's runner, scorer and stop rule and its containers,
# write the ids with index % n == k to ~/kit/shard.txt; fresh empties ~/out2 (a copy of another machine's).
k=$1; n=$2; mode=$3
pkill -f "kit/run-docker.sh"; pkill -f "xargs -P"; pkill -f 'one "\$0"'; pkill -f "kit/score2.sh"; pkill -f "kit/stop-rule2.sh"
sg docker -c "docker ps -aq --filter name=swe- | xargs -r docker rm -f" >/dev/null 2>&1
sleep 3
if [ "$mode" = fresh ]; then
  mv ~/out2 ~/out2-copied-$(date +%s); mkdir -p ~/out2; cp ~/out2-copied-*/usage-start ~/out2-copied-*/cap ~/out2/ 2>/dev/null
else
  # Runs the stop cut short leave a line with a signal's status or a failed docker exec: not results.
  grep -vP '\twf=(1[2-9][0-9]|[2-9][0-9][0-9]|125|126|127)\t' ~/out2/results.tsv > ~/out2/r.tmp 2>/dev/null; mv ~/out2/r.tmp ~/out2/results.tsv
fi
python3 -c "import json; [print(r['instance_id']) for i, r in enumerate(json.load(open('$HOME/verified.json'))) if i % $n == $k]" > ~/kit/shard.txt
echo "shard $k: $(wc -l < ~/kit/shard.txt) ids; results kept: $(wc -l < ~/out2/results.tsv 2>/dev/null || echo 0); containers: $(sg docker -c 'docker ps -aq' | wc -l)"
