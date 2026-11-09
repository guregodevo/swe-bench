# 20261106_memdoor-team-solve_deepseek-v4.1-flash

The team-solve workflow: a direct attempt checked with the project's own tests; when the check fails, a team (context, two ideators, solver, test, review, repair, judge) tries again, and keep puts the direct attempt back when the team did not do better. One prediction per instance; the pick between attempts uses the project's tests, never SWE-bench's.

| | |
| --- | --- |
| Split | `verified` |
| Model | `openrouter:deepseek/deepseek-v4.1-flash` (served as deepseek-v4.1-flash-20260910) |
| Memdoor | v1.798.0 (d98f2db) |
| Resolved | 400 / 500 (80.00%) |
| No generation (empty patch) | 7 |
| Missing logs | 0 |

Resolution was re-derived from each instance's `test_output.txt` by
`swebench submit package`, not taken from the run's own report;
`swebench submit verify` passes. How it was run, what was run again and
why: [../runs/2026-11-06.md](../runs/2026-11-06.md).
