#!/bin/bash
# start2.sh <parallel> [ids file]: the container runner, the scorer and the stop rule on ~/out2.
# The key is read from stdin: never on a command line, never in a file.
read -r OPEN_ROUTER_API_KEY; export OPEN_ROUTER_API_KEY
[ -n "$OPEN_ROUTER_API_KEY" ] || { echo "no key"; exit 1; }
mkdir -p ~/out2
nohup sg docker -c "$HOME/kit/run-docker.sh $1 $2" > ~/out2/runner.txt 2>&1 < /dev/null &
nohup sg docker -c "$HOME/kit/score2.sh" > ~/out2/scorer.txt 2>&1 < /dev/null &
nohup bash ~/kit/stop-rule2.sh > ~/out2/stop-rule.txt 2>&1 < /dev/null &
echo started
