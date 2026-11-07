# Survey: pylint XDG Base Directory compliance (`.pylint.d` in `$HOME`)

Paths the issue names first, then the code that reaches them, then siblings that
place or read user files the same way.

- `pylint/config/__init__.py:PYLINT_HOME` — module-level constant that computes the persistent-data directory as `$PYLINTHOME`, else `~/.pylint.d`, else `.pylint.d` in the CWD; this is the literal source of the unwanted home directory.
- `pylint/config/__init__.py:USER_HOME` — module-level `os.path.expanduser("~")` used to build `PYLINT_HOME`, and also rewritten from `PYLINTHOME` when the home cannot be expanded.
- `pylint/config/__init__.py:_get_pdata_path` — joins `PYLINT_HOME` with `<base_name>1.stats`, so every stats file inherits the non-XDG location.
- `pylint/config/__init__.py:load_results` — opens and unpickles the stats file under `PYLINT_HOME` for comparison with the previous run.
- `pylint/config/__init__.py:save_results` — creates `PYLINT_HOME` with `os.mkdir` and pickles the run stats there, which is what actually creates `~/.pylint.d`.
- `pylint/config/__init__.py:ENV_HELP` — user-facing help text documenting the default as `~/.pylint.d/` or `.pylint.d`, so the non-XDG path is advertised as the contract.
- `pylint/lint/pylinter.py:PyLinter.generate_reports` — calls `config.load_results` and, when `persistent` is on, `config.save_results`, making every normal lint run write into `PYLINT_HOME`.
- `pylint/lint/pylinter.py:PyLinter._report_evaluation` — calls `config.load_results` again to show the previous score, another read of the same non-XDG stats file.
- `pylint/lint/pylinter.py:PyLinter.make_options` (`persistent` option) — defines the `--persistent` flag (default `True`) that gates the `save_results` write.
- `pylint/lint/pylinter.py:PyLinter.error_mode` — disables `persistent`, the only existing way to avoid creating the directory.
- `pylint/config/find_default_config_files.py:find_default_config_files` — sibling user-file locator: already checks `~/.config/pylintrc` (XDG config) but still checks legacy `~/.pylintrc` first, showing the same home-directory pattern for config rather than data.
- `pylint/config/__init__.py:find_pylintrc` — wraps `find_default_config_files` and fixes `PYLINTRC` at import time from those home-directory candidates.
- `pylint/pyreverse/utils.py:get_default_options` — parallel tool reading `$HOME/.pyreverserc` directly via `os.environ["HOME"]`, the same "dotfile in home" approach for pyreverse config.
- `pylint/pyreverse/utils.py:insert_default_options` — inserts the options from that home dotfile into `sys.argv`, called from `pylint/pyreverse/main.py:Run.__init__`.
- `pylint/checkers/spelling.py:SpellingChecker.open` — expands `~` for `spelling-private-dict-file` and appends to it, another user-data file whose location is left to the user rather than an XDG data dir.
- `pylint/config/option_manager_mixin.py:OptionsManagerMixIn.load_command_line_configuration` — expands `~` in an explicit `--rcfile` path, the generic user-file path handling shared by all config loading.
- `tests/lint/unittest_lint.py:test_pylint_home` — asserts `config.PYLINT_HOME` equals `~/.pylint.d` (or `.pylint.d`) and that `PYLINTHOME` overrides it, encoding the current non-XDG behaviour as expected.
- `doc/faq.rst` (section 3.2) — documents the persistent-data lookup order as `PYLINTHOME`, `~/.pylint.d`, then `./.pylint.d`.
- `doc/user_guide/run.rst` (config file search order) — documents `~/.pylintrc` and `~/.config/pylintrc`, the config-side counterpart of the same home-directory convention.
