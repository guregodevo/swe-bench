verdict: PASS
- `ResolverMatch.__init__` now detects `functools.partial`, sets `func = func.func`, and merges `func.args + args` and `{**func.keywords, **kwargs}`, satisfying the unwrap/merge requirement.
- `__repr__` already formats `self.func`, `self.args`, and `self.kwargs`, so it now reveals the underlying function and combined arguments instead of `functools.partial`.
- Non-partial views bypass the new block, so their `func`, `args`, and `kwargs` remain unchanged.
- Tests cover a keyword-only partial and a partial with pre-bound positional/keyword arguments, with matching URL and view fixtures.
- The changes stay within the stated scope.
