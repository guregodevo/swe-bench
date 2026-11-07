# Task

## Prompt

autodoc_docstring_signature with overloaded methods
When using swig to wrap C++ classes for python, if they have overloaded methods, I believe the convention is to place the signatures for each of the overloaded C++ methods at the start of the docstring. Currently, `autodoc_docstring_signature` can only pick up the first one. It would be nice to be able to pick up all of them.

## Deliverable

changes to this tree

## Check

`make test TEST=tests/test_ext_autodoc.py`

## Scope

`sphinx/ext/autodoc/__init__.py`
`tests/`

## Done when

- With `autodoc_docstring_signature = True`, a docstring beginning with multiple SWIG-style signature lines (for example `foo(self, x)` followed by `foo(self, x, y)`) yields all of those signatures in the generated directive, not only the first.
- All matched signature lines are removed from the docstring body, so the overload signatures are not also rendered as ordinary paragraph text.
- The signatures are emitted in the order they appear in the docstring.
- `(inferred)` A docstring with a single signature still produces the same signature and body as before.
