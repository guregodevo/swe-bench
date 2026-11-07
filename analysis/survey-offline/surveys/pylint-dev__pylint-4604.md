# Survey: unused-import false positive for a module used in a type comment

Issue: `import abc` is reported as `W0611 unused-import` even though `abc` is
referenced as `abc.ABC` in a `# type:` comment. The paths the issue names
(the `pylint` command and the `unused-import` message) come first, then the
code that decides the message, then every sibling that does the same thing.

## Entry points named by the issue

- `pylint/__init__.py:run_pylint` — the `pylint` console entry point; imports `pylint.lint.Run` and passes `sys.argv[1:]`, so running `pylint a.py` starts here.
- `pylint/lint/run.py:Run.__init__` — builds the `PyLinter`, loads checkers/plugins, and calls `linter.check(args)` then `generate_reports()` (the "rated at 7.50/10" output).
- `pylint/lint/pylinter.py:PyLinter.check` — main checking entry; resolves file descriptors and dispatches each module to `_check_files`/`_check_file`.
- `pylint/lint/pylinter.py:PyLinter.check_astroid_module` — wraps `_check_astroid_module`, which runs the AST walker that fires the `visit_*`/`leave_*` hooks of `VariablesChecker`.
- `pylint/checkers/variables.py:VariablesChecker.leave_module` — end-of-module hook that pops the module `NamesConsumer` and calls `_check_globals` and then `_check_imports`, the path that actually emits `unused-import` for a module-level `import abc`.
- `pylint/checkers/variables.py:VariablesChecker._check_imports` — the emitter: for each unconsumed import it computes `is_type_annotation_import` from `self._type_annotation_names` and, if false, calls `add_message("unused-import", ...)`; this is where the false positive is produced.
- `pylint/checkers/variables.py:_fix_dot_imports` — helper called by `_check_imports` that expands dotted imports into the `(name, stmt)` pairs iterated there.
- `pylint/checkers/variables.py:_is_type_checking_import` — sibling suppression used by `_check_imports` to skip imports under `if TYPE_CHECKING:`; it is the other exemption checked before emitting `unused-import`.

## Where type-comment names are collected (the root cause)

- `pylint/checkers/variables.py:VariablesChecker._store_type_annotation_node` — the core collector: records `astroid.Name` and `astroid.Subscript` annotations into `self._type_annotation_names`, but has no branch for `astroid.Attribute`, so `abc.ABC` in a type comment is never recorded and `abc` stays "unused".
- `pylint/checkers/variables.py:VariablesChecker._store_type_annotation_names` — reads `node.type_annotation` and delegates to `_store_type_annotation_node`; the shared helper behind the `leave_*` hooks below.
- `pylint/checkers/variables.py:VariablesChecker.leave_assign` — calls `_store_type_annotation_names` for `X = ...  # type: abc.ABC`, the exact statement in the issue.
- `pylint/checkers/variables.py:VariablesChecker.leave_with` — sibling hook that collects the type comment on `with ... as x:  # type: ...`.
- `pylint/checkers/variables.py:VariablesChecker.leave_for` — sibling hook that collects the type comment on `for x in ...:  # type: ...`.
- `pylint/checkers/variables.py:VariablesChecker.leave_functiondef` — collects `node.type_comment_returns` and `node.type_comment_args` via `_store_type_annotation_node`; the function-level sibling of the assignment path.
- `pylint/checkers/variables.py:VariablesChecker.visit_arguments` — collects per-argument `# type:` comments (`node.type_comment_args`) via `_store_type_annotation_node`; another sibling entry into the same collector.
- `pylint/checkers/variables.py:VariablesChecker.__init__` — initialises `self._type_annotation_names = []`, the per-module list that all the collectors fill and `_check_imports` reads.

## The second, parallel unused-import emitter

- `pylint/checkers/variables.py:VariablesChecker._check_is_unused` — the function-scope emitter: for unconsumed locals it emits `unused-import` for `Import`/`ImportFrom` statements without ever consulting `self._type_annotation_names`, so a function-local import used only in a type comment is a sibling false positive.
- `pylint/checkers/variables.py:VariablesChecker.leave_functiondef` — also the caller of `_check_is_unused` (via the `not_consumed` loop), so it is both a collector and the driver of the second emitter.
- `pylint/checkers/variables.py:VariablesChecker._check_globals` — sibling end-of-module check that emits `unused-variable` for unconsumed globals; same `not_consumed` data, different message.
- `pylint/checkers/variables.py:VariablesChecker._check_all` — sibling end-of-module check that removes `__all__` names from `not_consumed` before `_check_imports`, another way an import escapes the warning.
- `pylint/checkers/variables.py:VariablesChecker._check_metaclasses` — sibling that pops consumed metaclass names from scope locals "to avoid unused-import and unused-variable false positives".

## Parallel type-annotation detection elsewhere

- `pylint/checkers/utils.py:is_node_in_type_annotation_context` — a second, independent notion of "in a type annotation" (AnnAssign/Arguments/returns) used by other checkers; it likewise has no notion of `# type:` comments or attribute expressions.
- `pylint/extensions/typing.py:TypingChecker.visit_name` — consumer of `is_node_in_type_annotation_context` for typing-alias/union messages; a parallel reader of type-annotation context.
- `pylint/extensions/typing.py:TypingChecker.visit_attribute` — sibling consumer for `typing.X` attribute nodes, the same node shape (`abc.ABC`) the issue's type comment contains.
- `pylint/extensions/typing.py:TypingChecker._check_for_alternative_union_syntax` — uses `is_node_in_type_annotation_context` to gate messages; another place that decides what counts as a type annotation.
- `pylint/extensions/typing.py:TypingChecker._check_for_typing_alias` — sibling gate on `is_node_in_type_annotation_context` for deprecated typing aliases.

## Other import handling (same statements, different messages)

- `pylint/checkers/imports.py:ImportsChecker.visit_import` — processes every `import` statement (reimport, deprecated module, preferred module, position) but never emits `unused-import`; the parallel import visitor.
- `pylint/checkers/imports.py:ImportsChecker.visit_importfrom` — the `from ... import ...` sibling of the above.
- `pylint/checkers/imports.py:ImportsChecker.leave_module` — end-of-module import grouping/order checks; the sibling of `VariablesChecker.leave_module` for the same import nodes.
- `pylint/checkers/imports.py:ImportsChecker._check_imports_order` — helper behind that leave-module check.
- `pylint/checkers/variables.py:TYPING_NAMES` — module-level constant that used to restrict type-annotation exemptions to typing names; now unused after the #3112 change, a leftover of the same feature.
