# Survey: MigrationRecorder does not obey db_router allow_migrate rules

One line per code path that produces the behaviour in issue.md. Paths named by the issue come first.

- `django/db/migrations/recorder.py:MigrationRecorder.record_applied` — calls `ensure_schema()` unconditionally before inserting the applied row, so recording a migration creates `django_migrations` on any connection regardless of the router.
- `django/db/migrations/recorder.py:MigrationRecorder.ensure_schema` — checks `has_table()` and, if absent, creates the `Migration` model with a schema editor without ever consulting `router.allow_migrate`, which is the table creation the issue objects to.
- `django/db/migrations/recorder.py:MigrationRecorder.applied_migrations` — reads `migration_qs` whenever `has_table()` is true, with no router check, so it reports/uses migration state on connections the router says not to migrate.
- `django/db/migrations/recorder.py:MigrationRecorder.record_unapplied` — calls `ensure_schema()` then deletes the row, so unapplying a migration also creates/uses `django_migrations` on a disallowed connection.
- `django/db/migrations/executor.py:MigrationExecutor.apply_migration` — calls `record_migration()` (and thus `record_applied`/`ensure_schema`) after applying each migration, the path the issue traces from `migrate`.
- `django/db/migrations/executor.py:MigrationExecutor.migrate` — calls `self.recorder.ensure_schema()` at the start of every migrate run, creating the table before any router decision is made.
- `django/db/backends/base/creation.py:BaseDatabaseCreation.create_test_db` — invokes `call_command('migrate', database=self.connection.alias, run_syncdb=True)` for each test connection, the entry point the issue describes for test-database creation.
- `django/test/utils.py:setup_databases` — calls `connection.creation.create_test_db()` for each alias, so every configured connection gets a migrate run and therefore a `django_migrations` table.

## Siblings doing the same thing the same way

- `django/db/migrations/recorder.py:MigrationRecorder.has_table` — introspects table names on the connection with no router check, so it reports the table as absent on a disallowed DB and invites `ensure_schema` to create it.
- `django/db/migrations/recorder.py:MigrationRecorder.migration_qs` — binds the `Migration` queryset to `self.connection.alias` unconditionally, so all recorder reads/writes target the connection regardless of routing.
- `django/db/migrations/recorder.py:MigrationRecorder.flush` — deletes all rows via `migration_qs` without a router check, the same unguarded write pattern as `record_applied`/`record_unapplied`.
- `django/db/migrations/executor.py:MigrationExecutor.record_migration` — fans out to `recorder.record_applied` for replacement migrations, repeating the unguarded recording path.
- `django/db/migrations/executor.py:MigrationExecutor.unapply_migration` — calls `recorder.record_unapplied` for the migration and its replacements, repeating the unguarded unrecord path.
- `django/db/migrations/executor.py:MigrationExecutor.check_replacements` — calls `recorder.applied_migrations()` and `recorder.record_applied()` on every migrate, another unguarded read/write of the recorder table.
- `django/db/migrations/executor.py:MigrationExecutor._create_project_state` — builds state from `loader.applied_migrations`, which came from the unguarded recorder read.
- `django/db/migrations/loader.py:MigrationLoader.build_graph` — constructs a `MigrationRecorder` and calls `applied_migrations()` for the connection with no router check, so graph construction reads the recorder table on disallowed DBs.
- `django/db/migrations/loader.py:MigrationLoader.check_consistent_history` — constructs a `MigrationRecorder` and calls `applied_migrations()` directly, the same unguarded read used by `migrate` and `makemigrations`.
- `django/core/management/commands/migrate.py:Command.handle` — builds a `MigrationExecutor` for the chosen `--database` and calls `executor.migrate()`, the public command path that reaches the recorder.
- `django/core/management/commands/showmigrations.py:Command.show_list` — creates a `MigrationRecorder` and calls `applied_migrations()` for the selected database, reading the recorder table without a router check.
- `django/core/management/commands/showmigrations.py:Command.show_plan` — uses `loader.applied_migrations` (from the unguarded recorder read) to mark migrations applied.
- `django/core/management/commands/makemigrations.py:Command.handle` — calls `loader.check_consistent_history(connection)` for each connection, reaching the unguarded recorder read (the existing test only guards this via `has_table`).
- `django/core/management/commands/sqlmigrate.py:Command.handle` — builds a `MigrationLoader(connection)` which reads `applied_migrations()` from the recorder for the selected database.
- `django/core/management/commands/squashmigrations.py:Command.handle` — builds a `MigrationLoader(connections[DEFAULT_DB_ALIAS])`, reading recorder state without a router check.
- `django/db/utils.py:ConnectionRouter.allow_migrate` — the router hook that is never consulted by any `MigrationRecorder` method, the missing check at the heart of the issue.
- `django/db/utils.py:ConnectionRouter.allow_migrate_model` — wraps `allow_migrate` with model hints and is used by migration operations but not by the recorder.
- `django/db/utils.py:ConnectionRouter.get_migratable_models` — filters models by `allow_migrate_model`, the pattern the recorder should follow but does not.
