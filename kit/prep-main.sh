#!/bin/bash
# prep-main.sh <k> <n> <usage at the start> <cap>: the kit from ~/kit-new (main's binary and team-solve, run-docker.sh,
# allow-proxy.py), a clean
# ~/out2 (the pilot's moved aside), and this machine's shard of Verified (index % n == k) in ~/kit/shard.txt.
k=$1; n=$2; start=$3; cap=$4
pkill -f "[k]it/run-docker.sh"; pkill -f "[x]args -P"; pkill -f '[o]ne "\$0"'; pkill -f "[k]it/score2.sh"; pkill -f "[k]it/stop-rule2.sh"
sg docker -c "docker ps -aq --filter name=swe- | xargs -r docker rm -f" >/dev/null 2>&1   # the old proxy too: it logs into ~/out2
mv ~/kit/memdoor ~/kit/memdoor.bench && mv ~/kit-new/memdoor ~/kit/memdoor && chmod +x ~/kit/memdoor
mv ~/kit/workflows/team-solve ~/kit/workflows/team-solve.bench-$(date +%s) && mv ~/kit-new/team-solve ~/kit/workflows/team-solve
mv ~/kit-new/run-docker.sh ~/kit/run-docker.sh && chmod +x ~/kit/run-docker.sh
mv ~/kit-new/allow-proxy.py ~/kit/allow-proxy.py
mv ~/kit-new/stop-rule2.sh ~/kit/stop-rule2.sh && chmod +x ~/kit/stop-rule2.sh   # alert only
[ -d ~/out2 ] && mv ~/out2 ~/out2-pilot-$(date +%s)
mkdir -p ~/out2 && echo "$start" > ~/out2/usage-start && echo "$cap" > ~/out2/cap
python3 -c "import json; [print(r['instance_id']) for i, r in enumerate(json.load(open('$HOME/verified.json'))) if i % $n == $k]" > ~/kit/shard.txt
echo "$(hostname -s): $(~/kit/memdoor version | head -1), shard $k: $(wc -l < ~/kit/shard.txt) ids, team-solve steps $(ls ~/kit/workflows/team-solve/steps | wc -l), cap $(cat ~/out2/cap)"
