# The survey, offline, on the 23 instances whose needed file no step touched

On the Nov 6 run, the reference fix needed a file outside the planner's Scope in 32 of the
100 instances team-solve did not resolve, against 51 of the 400 it did. In 23 of those 32,
no step of the run ever touched that file ([never-touched.json](never-touched.json): the
instance and the files). seaborn-3187 is the shape: the issue says it also reproduces with
`scatterplot`, the fix is in `seaborn/utils.py`, and every attempt changed only
`_core/scales.py`.

For each of the 23, DeepSeek V4.1 Flash got one read-only agent turn on the instance's tree
at its base commit (Memdoor's coder, a one-step workflow, `model:
openrouter:deepseek/deepseek-v4.1-flash`): find every code path the issue's behaviour goes
through, siblings included, and write them in `survey.md`; do not fix, do not run the
project's code. [kit/survey-offline.sh](../../kit/survey-offline.sh) ran it; the survey
files are in [surveys/](surveys/), one line per instance in [results.tsv](results.tsv).

| on the 23 | count |
|---|---|
| the survey named every file the reference fix needed | 17 |
| it named at least one of them | 18 |
| it named none | 5 |
| it changed a file other than survey.md | 0 |

It named a median of 9 files per instance (3 to 19), of trees with 104 to 851 source files.
The five misses are mostly fixes to a convention rather than to a sibling path: a constant
added to `pylint/constants.py` (pylint-4604), `setup.cfg` (pylint-4661), Django's messages
app config (django-15127), and two lookups and indexes changes (django-11734, xarray-6992).

Naming the file is not fixing it: in 9 other unresolved instances the final patch touched
the needed file and was still wrong. What the survey is worth is measured by the A/B in
memdoor#164 (the survey step in team-solve against main, the same 48 instances).
