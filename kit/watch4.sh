#!/bin/bash
# watch4.sh: every 3 minutes, each machine's alerts, cap and finish. Fail fast: an alert on one machine stops the
# runs on all four (the machines stay on, the results stay for the investigation), and this script ends so it is
# reported; after the fix the run starts again from the first instance. It also ends when a runner is gone before it
# finished, at the cap, or when all four are finished (runner and scorer).
# The machines: BENCH_VMS (names, space-separated), BENCH_PROJECT and BENCH_ZONE (the Compute Engine project and
# zone), run from the machine that watches them (gcloud signed in).
: "${BENCH_VMS:?set BENCH_VMS}" "${BENCH_PROJECT:?set BENCH_PROJECT}" "${BENCH_ZONE:?set BENCH_ZONE}"
VMS=$BENCH_VMS
q() { gcloud compute ssh "$1" --project "$BENCH_PROJECT" --zone "$BENCH_ZONE" --quiet --command "$2" 2>/dev/null | grep -vE 'Warning|known_hosts'; }
while true; do
  done_n=0
  for vm in $VMS; do
    st=$(q $vm 'cat ~/out2/alerts.log 2>/dev/null; grep -m1 cap ~/out2/budget.log 2>/dev/null; [ -f ~/out2/run-finished ] && ! pgrep -f "[k]it/score2.sh" >/dev/null && echo FINISHED; [ -f ~/out2/run-finished ] || pgrep -f "[r]un-docker.sh" >/dev/null || echo "RUNNER GONE"')
    case "$st" in
      *ALERT*)
        echo "$vm: $(printf '%s\n' "$st" | grep ALERT)"
        for o in $VMS; do q $o 'pkill -f "[k]it/run-docker.sh"; pkill -f "[x]args -P"; pkill -f '"'"'[o]ne "\$0"'"'"'; pkill -f "[k]it/score2.sh"; pkill -f "[k]it/stop-rule2.sh"; sg docker -c "docker ps -aq --filter name=swe- | xargs -r docker rm -f" >/dev/null 2>&1; echo runs stopped' | sed "s/^/$o: /"; done
        exit 0 ;;
      *"RUNNER GONE"*|*cap*) echo "$vm: $st"; exit 0 ;;
      *FINISHED*) done_n=$((done_n+1)) ;;
    esac
  done
  [ $done_n = 4 ] && { echo "all four finished"; exit 0; }
  sleep 180
done
