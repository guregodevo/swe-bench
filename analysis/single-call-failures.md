# What happened on the 107 issues team-solve's own single call did not resolve

From the traces in `../20261106_memdoor-team-solve_deepseek-v4.1-flash/trajs/` (`direct-status.txt`, `test-status.txt`, `final-status.txt`, `review.md`, `verdict.md`, `keep.txt`) and the run's CLI output. `(never seen)` marks an issue not among the 176 in `../kit/seen-ids.txt`.

| group | issues | never seen | what happened |
|---|---|---|---|
| V1 | 68 | 46 | The direct attempt was wrong; the Check (the project's tests, or the judge) passed it; the review passed it too; the team never ran |
| K1 | 13 | 7 | The direct attempt was wrong; the Check passed it; the review failed it; repair ran and wrote repair.patch; keep put the direct attempt back (keep.yaml: a direct attempt that passed test-0 stays) |
| V2 | 6 | 6 | The direct attempt failed the Check; the team ran; its patch passed the Check and was kept; SWE-bench says it is wrong |
| T1 | 9 | 6 | The run ended at the direct attempt or before it (a step timed out); no Check, no team; the tree as the single call left it was scored |
| T2 | 1 | 1 | The run ended during repair or recheck (no final status) |
| T3 | 4 | 4 | The run ended during the team (no final status) |
| fixed | 6 | 4 | The direct attempt failed the Check; the team ran; its patch passed the Check and resolves the issue |

No issue is in the group one might expect: the team ran on a failing Check and produced a patch that still failed it. Whenever the team ran to the end, its patch passed the Check it was given.

## V1: The direct attempt was wrong; the Check (the project's tests, or the judge) passed it; the review passed it too; the team never ran (68)

- astropy__astropy-13033
- astropy__astropy-13398
- astropy__astropy-14365
- astropy__astropy-14369
- astropy__astropy-14598
- django__django-10999
- django__django-11087
- django__django-11141
- django__django-11477
- django__django-11532
- django__django-11734
- django__django-11749
- django__django-11820
- django__django-11885
- django__django-12325
- django__django-13513
- django__django-13837
- django__django-14034
- django__django-14170
- django__django-14311
- django__django-14315
- django__django-14376
- django__django-15127 (never seen)
- django__django-15563 (never seen)
- django__django-15695 (never seen)
- django__django-15732 (never seen)
- django__django-16256 (never seen)
- django__django-16502 (never seen)
- django__django-16631 (never seen)
- django__django-16667 (never seen)
- django__django-16877 (never seen)
- matplotlib__matplotlib-21568 (never seen)
- matplotlib__matplotlib-23476 (never seen)
- matplotlib__matplotlib-25479 (never seen)
- matplotlib__matplotlib-26208 (never seen)
- mwaskom__seaborn-3187 (never seen)
- psf__requests-1724 (never seen)
- psf__requests-1766 (never seen)
- psf__requests-1921 (never seen)
- psf__requests-2317 (never seen)
- pydata__xarray-6599 (never seen)
- pydata__xarray-6744 (never seen)
- pydata__xarray-6938 (never seen)
- pydata__xarray-6992 (never seen)
- pydata__xarray-7229 (never seen)
- pylint-dev__pylint-4551 (never seen)
- pylint-dev__pylint-4604 (never seen)
- pylint-dev__pylint-4661 (never seen)
- pylint-dev__pylint-4970 (never seen)
- pytest-dev__pytest-5840 (never seen)
- scikit-learn__scikit-learn-25747 (never seen)
- sphinx-doc__sphinx-10614 (never seen)
- sphinx-doc__sphinx-7462 (never seen)
- sphinx-doc__sphinx-7590 (never seen)
- sphinx-doc__sphinx-8269 (never seen)
- sphinx-doc__sphinx-8595 (never seen)
- sphinx-doc__sphinx-9602 (never seen)
- sympy__sympy-13852 (never seen)
- sympy__sympy-13878 (never seen)
- sympy__sympy-15017 (never seen)
- sympy__sympy-18199 (never seen)
- sympy__sympy-18763 (never seen)
- sympy__sympy-20428 (never seen)
- sympy__sympy-20438 (never seen)
- sympy__sympy-20916 (never seen)
- sympy__sympy-21596 (never seen)
- sympy__sympy-21930 (never seen)
- sympy__sympy-22080 (never seen)

## K1: The direct attempt was wrong; the Check passed it; the review failed it; repair ran and wrote repair.patch; keep put the direct attempt back (keep.yaml: a direct attempt that passed test-0 stays) (13)

- astropy__astropy-13977
- django__django-10973
- django__django-13195
- django__django-13212
- django__django-14155
- matplotlib__matplotlib-25960 (never seen)
- matplotlib__matplotlib-26466 (never seen)
- pydata__xarray-3993 (never seen)
- pytest-dev__pytest-10356 (never seen)
- sphinx-doc__sphinx-7748 (never seen)
- sympy__sympy-11618
- sympy__sympy-13798 (never seen)
- sympy__sympy-16597 (never seen)

## V2: The direct attempt failed the Check; the team ran; its patch passed the Check and was kept; SWE-bench says it is wrong (6)

- django__django-15252 (never seen)
- django__django-16263 (never seen)
- mwaskom__seaborn-3069 (never seen)
- pylint-dev__pylint-8898 (never seen)
- pytest-dev__pytest-7324 (never seen)
- sphinx-doc__sphinx-7985 (never seen)

## T1: The run ended at the direct attempt or before it (a step timed out); no Check, no team; the tree as the single call left it was scored (9)

- django__django-10554
- django__django-12273
- django__django-13121
- django__django-15098 (never seen)
- matplotlib__matplotlib-25332 (never seen)
- pylint-dev__pylint-7080 (never seen)
- sphinx-doc__sphinx-8638 (never seen)
- sphinx-doc__sphinx-9461 (never seen)
- sympy__sympy-22456 (never seen)

## T2: The run ended during repair or recheck (no final status) (1)

- sphinx-doc__sphinx-8056 (never seen)

## T3: The run ended during the team (no final status) (4)

- django__django-14792 (never seen)
- sphinx-doc__sphinx-11510 (never seen)
- sphinx-doc__sphinx-7440 (never seen)
- sphinx-doc__sphinx-9229 (never seen)

## fixed: The direct attempt failed the Check; the team ran; its patch passed the Check and resolves the issue (6)

- django__django-12406
- django__django-12663
- django__django-15280 (never seen)
- matplotlib__matplotlib-24627 (never seen)
- scikit-learn__scikit-learn-25102 (never seen)
- sympy__sympy-23413 (never seen)

## repairs-not-applied/

The 13 `repair.patch` of group K1, each the whole change against the base commit as `snapshot.sh save` wrote it, and `preds.jsonl` in the harness's predictions format. To score them:

    python -m swebench.harness.run_evaluation -d SWE-bench/SWE-bench_Verified -p analysis/repairs-not-applied/preds.jsonl --max_workers 4 -id repairs-not-applied

