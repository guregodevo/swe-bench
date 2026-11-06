#!/bin/bash
# finish-one.sh <vm> <id>: wait for the id's two result rows, make sure a scorer and the stop rule run, wait for its scores.
# The machines: BENCH_VMS (names, space-separated), BENCH_PROJECT and BENCH_ZONE (the Compute Engine project and
# zone), run from the machine that watches them (gcloud signed in).
: "${BENCH_VMS:?set BENCH_VMS}" "${BENCH_PROJECT:?set BENCH_PROJECT}" "${BENCH_ZONE:?set BENCH_ZONE}"
vm=$1; id=$2
q() { gcloud compute ssh "$vm" --project "$BENCH_PROJECT" --zone "$BENCH_ZONE" --quiet --command "$1" 2>/dev/null | grep -vE 'Warning|known_hosts|Updating|External'; }
until [ "$(q "grep -cP '^$id\t(single|team)\twf=' ~/out2/results.tsv")" = 2 ]; do sleep 60; done
q 'bash ~/kit/ensure-scoring.sh' >/dev/null
until [ "$(q "grep -cP '^$id\t(single|team|direct)\t' ~/out2/scores.tsv")" = 3 ]; do sleep 60; q 'bash ~/kit/ensure-scoring.sh' >/dev/null; done
echo "$vm $id: $(q "grep -P '^$id\t' ~/out2/scores.tsv | cut -f2,3 | tr '\t\n' ': '") alerts: $(q 'cat ~/out2/alerts.log 2>/dev/null | wc -l')"
