#!/bin/bash
# reset-vm.sh: stop the runner, the scorer and the stop rule, remove the run containers, empty ~/out2 (cap kept),
# fix the runner's parallelism for one arm.
pkill -f "[k]it/run-docker.sh"; pkill -f "[x]args -P"; pkill -f '[o]ne "\$0"'; pkill -f "[k]it/score2.sh"; pkill -f "[k]it/stop-rule2.sh"
sg docker -c 'docker ps -aq --filter name=swe- | xargs -r docker rm -f' >/dev/null 2>&1
cap=$(cat ~/out2/cap 2>/dev/null || echo 40)
rm -rf ~/out2; mkdir -p ~/out2; echo "$cap" > ~/out2/cap
sed -i 's/xargs -P \$((K\*2))/xargs -P $((K * $(echo ${ARMS:-single team} | wc -w)))/' ~/kit/run-docker.sh
echo "$(hostname -s): reset; parallel fix $(grep -c 'wc -w' ~/kit/run-docker.sh); containers $(sg docker -c 'docker ps -aq --filter name=swe-' | wc -l)"
