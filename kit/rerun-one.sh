#!/bin/bash
# rerun-one.sh <id>: a task whose run the watcher's stop killed and the restart skipped (its exited container
# still stood): the exited containers go, the killed run's logs go to ~/out2/stale/, and the variant with no
# result runs again (the key on stdin). The variant with a result is skipped by run-docker.sh.
id=$1; read -r OPEN_ROUTER_API_KEY; export OPEN_ROUTER_API_KEY
sg docker -c 'docker ps -aq --filter status=exited --filter name=swe- | xargs -r docker rm -f' >/dev/null
mkdir -p ~/out2/stale
for v in single team; do grep -qP "^$id\t$v\twf=" ~/out2/results.tsv || mv ~/out2/logs/$id-$v.txt ~/out2/logs/$id-$v.docker ~/out2/stale/ 2>/dev/null; done
echo $id > ~/kit/one.txt
nohup sg docker -c "$HOME/kit/run-docker.sh 1 $HOME/kit/one.txt" > ~/out2/runner-one.txt 2>&1 < /dev/null &
sleep 30; sg docker -c 'docker ps --format "{{.Names}}"' | grep "$id"
