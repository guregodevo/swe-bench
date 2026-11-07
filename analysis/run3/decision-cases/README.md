# Labelled cases for a decision task's threshold

The 13 repairs of memdoor#152, each the run folder's files as the published run wrote them (`task.md`, `review.md`, `verdict.md`, `test-output.log`, `final-check.log`, `repair.md`, the statuses) and `hidden.json`: whether the repair resolves the instance under SWE-bench's hidden tests (`analysis/repairs-not-applied/`).

The decision task of memdoor#160 scores the review's findings and the judge's findings against the Check's output; the label is the hidden verdict. A threshold that passes the four resolved repairs and fails the nine others is the one to pick; astropy-13033 (memdoor#105, the review that failed a correct attempt) bounds it from the other side.

| instance | review | judge after the repair | Check before | Check after | repair under the hidden tests |
|---|---|---|---|---|---|
| astropy__astropy-13977 | verdict: FAIL | verdict: FAIL | none | none | unresolved |
| django__django-10973 | verdict: FAIL | verdict: PASS | 0 | 0 | RESOLVED |
| django__django-13195 | verdict: FAIL | verdict: FAIL | 0 | 0 | unresolved |
| django__django-13212 | verdict: FAIL | verdict: FAIL | 0 | 0 | unresolved |
| django__django-14155 | verdict: FAIL | verdict: PASS | 0 | 0 | unresolved |
| matplotlib__matplotlib-25960 | verdict: FAIL | none | none | 0 | RESOLVED |
| matplotlib__matplotlib-26466 | verdict: FAIL | none | 0 | 0 | unresolved |
| pydata__xarray-3993 | verdict: FAIL | none | 0 | 0 | RESOLVED |
| pytest-dev__pytest-10356 | verdict: FAIL | verdict: FAIL | 0 | 0 | unresolved |
| sphinx-doc__sphinx-7748 | verdict: FAIL | none | 0 | 0 | unresolved |
| sympy__sympy-11618 | verdict: FAIL | verdict: PASS | none | none | RESOLVED |
| sympy__sympy-13798 |  | none | none | none | unresolved |
| sympy__sympy-16597 | verdict: FAIL | none | none | none | unresolved |
