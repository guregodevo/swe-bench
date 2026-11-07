# Repair

## Review claim

`review.md` reported `verdict: FAIL`, claiming that `MaxValueValidator`,
`MinValueValidator`, `MaxLengthValidator`, and `MinLengthValidator` in
`django/core/validators.py` raise `ValidationError` without
`params={'value': value}`, and that the postgres subclasses inherit the
omission.

## Finding

No change was required. All four validators inherit `BaseValidator.__call__`,
which already builds:

    params = {'limit_value': limit_value, 'show_value': cleaned, 'value': value}

and raises with `params=params`. This line is pre-existing in the tree (not
part of the solver's diff), so the four core validators and the postgres
`RangeMaxValueValidator`, `RangeMinValueValidator`,
`ArrayMaxLengthValidator`, and `ArrayMinLengthValidator` already include the
provided value. The review's premise does not hold for this tree.

Direct verification of every built-in validator rejection path showed
`'value' in e.params` is `True` for all of them, including the four named in
the review and their postgres subclasses. A custom message using
`%(value)s` renders the validated value (e.g. `MaxValueValidator(3,
message='bad %(value)s')` on `9` yields `bad 9`).

## Check

`python tests/runtests.py validators`

    Testing against Django installed in '/testbed/django' with up to 8 processes
    System check identified no issues (0 silenced).
    ...................
    ----------------------------------------------------------------------
    Ran 19 tests in 0.334s

    OK
