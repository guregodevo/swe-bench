#!/usr/bin/env bash
# survey.sh <instance_id>: Flash surveys the code paths of one SWE-bench issue at
# its base commit (read and search only), and the result says whether survey.md
# names the files the reference fix needed outside the planner's Scope.
# Reads verified-run.json and /tmp/never-touched.json; clones each repo once.
set -u
inst="$1"
here=$HOME/memdoor-flash-lever
S=$HOME/memdoor-decision-test
read -r repo base out < <(python3 - "$inst" <<'EOF'
import json,sys
inst=sys.argv[1]
r=[x for x in json.load(open('/Users/gregoryd/memdoor-flash-lever/verified-run.json')) if x['instance_id']==inst][0]
out=[o for i,o in json.load(open('/tmp/never-touched.json')) if i==inst]
print(r['repo'], r['base_commit'], ','.join(out[0] if out else []))
open(f'/tmp/issue-{inst}.md','w').write(r['problem_statement'])
EOF
)
name=${repo#*/}
[ -d "$here/repos/$name" ] || git clone -q "https://github.com/$repo.git" "$here/repos/$name"
wt="$here/wt/$inst"
rm -rf "$wt"; git -C "$here/repos/$name" worktree prune
git -C "$here/repos/$name" worktree add -q --detach "$wt" "$base" || { echo "$inst: worktree failed"; exit 1; }
cp "/tmp/issue-$inst.md" "$wt/issue.md"
mkdir -p "$wt/.memdoor/workflows/survey/steps"
cp "$here/probe/.memdoor/workflows/survey/steps/survey.yaml" "$wt/.memdoor/workflows/survey/steps/"
cd "$wt"
HOME=$S/home "$S/memdoor" --gateway http://localhost:18809 workspace use decision >/dev/null 2>&1
run=$(HOME=$S/home "$S/memdoor" --gateway http://localhost:18809 workflow run survey 2>&1 | grep -o 'survey-[0-9-]*' | head -1)
for i in $(seq 1 120); do
  st=$(HOME=$S/home "$S/memdoor" --gateway http://localhost:18809 workflow status "$run" 2>&1)
  echo "$st" | grep -qE "waiting|running" || break
  sleep 10
done
found=""; missed=""
for f in ${out//,/ }; do
  if [ -s survey.md ] && grep -qF "$f" survey.md; then found="$found $f"; else missed="$missed $f"; fi
done
changed=$(git status --short | grep -v -e 'survey.md' -e '\.memdoor' -e 'issue.md' | wc -l | tr -d ' ')
printf '%s\tsurvey=%s\tfound:%s\tmissed:%s\tother-files-changed=%s\n' "$inst" "$([ -s survey.md ] && echo yes || echo no)" "${found:- -}" "${missed:- -}" "$changed"
