verdict: PASS
- `client.py` now launches the client with `subprocess.run(args, check=True, env=env)`.
- `PGPASSWORD` is set in the subprocess environment only when a password is configured.
- Temporary `.pgpass` creation, `_escape_pgpass`, and `PGPASSFILE` cleanup are removed.
- Existing argument construction for user, host, port, database, and extra parameters is unchanged.
- New `tests/backends/postgresql/test_client.py` covers command args and `PGPASSWORD` for configured passwords, no password, special characters, accents, and SIGINT.
- Existing dbshell tests are updated to mock `subprocess.run` and assert `PGPASSWORD`, keeping the suite consistent.
