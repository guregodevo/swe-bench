#!/bin/bash
# ensure-scoring.sh: start the scorer and the stop rule when they are not running. A script, so that pgrep does not
# match the ssh command line that names them (it did: the scorer was never started, 2026-11-06).
pgrep -f "kit/score2.sh" >/dev/null || { nohup sg docker -c "$HOME/kit/score2.sh" >> ~/out2/scorer.txt 2>&1 < /dev/null & }
pgrep -f "kit/stop-rule2.sh" >/dev/null || { nohup bash ~/kit/stop-rule2.sh >> ~/out2/stop-rule.txt 2>&1 < /dev/null & }
sleep 2; echo "$(hostname -s): scorer $(pgrep -fc "kit/score2.sh"), stop rule $(pgrep -fc "kit/stop-rule2.sh")"
