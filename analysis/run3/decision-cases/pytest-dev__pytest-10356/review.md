verdict: FAIL

- The core fix is correct and matches the Done when: `get_unpacked_marks` now walks `obj.__mro__` and merges each class's own `pytestmark` from `__dict__`, so `TestDings(Foo, Bar)` collects both `foo` and `bar`; `store_mark` uses `consider_mro=False` so applying a new mark does not duplicate inherited marks.
- The regression test `test_mark_decorator_multiple_baseclasses` covers multiple inheritance from two marked base classes and asserts both marks, as required.
- The check `python -m pytest testing/test_mark.py -q` passed (89 passed, 1 xfailed), status 0.
- However, the change touches `doc/en/example/markers.rst`, which the scope report explicitly flags as OUTSIDE THE SCOPE. That documentation edit is not needed for the fix (the task's Scope is `src/_pytest/mark/structures.py`, `src/_pytest/python.py`, `testing/`, `changelog/`), so it is an unrequested out-of-scope change.

Repair: revert the out-of-scope documentation edit with `git checkout -- doc/en/example/markers.rst` (or delete the added lines). Keep the `src/_pytest/mark/structures.py`, `testing/test_mark.py`, and `changelog/5357.bugfix.rst` changes as they are.
