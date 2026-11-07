verdict: FAIL
- The Done-when requires built-in validators that reject a value to include `params['value']`; `MaxValueValidator`, `MinValueValidator`, `MaxLengthValidator`, and `MinLengthValidator` in `django/core/validators.py` still raise `ValidationError` without it.
- Therefore a custom `%(value)s` message does not render for those validators, so the change is incomplete within the stated scope.
- The touched validators otherwise preserve existing params and appear consistent with the task.
