verdict: FAIL

- `sphinx/ext/autodoc/__init__.py`: `Documenter.format_signature` wraps each docstring signature’s args in an extra pair of parentheses via `self._format_signature("(%s)" % args, retann)`. The `args` captured by `_find_signature` already include the parentheses, so the generated directive would contain signatures like `Overloaded.meth((int)) -> int` instead of `Overloaded.meth(int) -> int`. This also regresses the single-signature case.
- The new `test_autodoc_docstring_signature_overloaded` is added to `tests/test_ext_autodoc_configs.py`, which is not run by the stated Check command `make test TEST=tests/test_ext_autodoc.py`, so this regression is not caught by the check.
- `CHANGES` and `doc/usage/extensions/autodoc.rst` are outside the stated scope and are not required by the task.

Repair instructions:
- In `sphinx/ext/autodoc/__init__.py`, change the multi-signature formatting to pass `args` unchanged: `[self._format_signature(args, retann) for args, retann in self._signatures]`.
- Run `test_autodoc_docstring_signature_overloaded` directly, or move/add it to a test file covered by the Check, and verify the output is `Overloaded.meth(int) -> int`, `Overloaded.meth(str) -> str`, `Overloaded.meth(float, int) -> float`.
- Revert the out-of-scope `CHANGES` and `doc/usage/extensions/autodoc.rst` edits.
