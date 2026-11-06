# pytest-dev__pytest-7571 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 111s 60 lines cost=0.005877 in=160753 cached=116224 out=11081 calls=16`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

caplog fixture doesn't restore log level after test
From the documentation at https://docs.pytest.org/en/6.0.0/logging.html#caplog-fixture, "The log levels set are restored automatically at the end of the test".
It used to work, but looks broken in new 6.0 release. Minimal example to reproduce:

```
def test_foo(caplog):
    caplog.set_level(42)

def test_bar(caplog):
    print(caplog.handler.level)
```

It prints "0" for pytest<6, "42" after.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls"
}
```

**tool result**

```
/testbed
AUTHORS
CHANGELOG.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.rst
LICENSE
OPENCOLLECTIVE.rst
README.rst
RELEASING.rst
TIDELIFT.rst
bench
changelog
codecov.yml
doc
extra
pyproject.toml
scripts
setup.cfg
setup.py
src
testing
tox.ini
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"set_level\\|class LogCaptureFixture\\|_force_enable\\|caplog\" src/_pytest/logging.py | head -80"
}
```

**tool result**

```
37:caplog_handler_key = StoreKey["LogCaptureHandler"]()
38:caplog_records_key = StoreKey[Dict[str, List[logging.LogRecord]]]()
341:class LogCaptureFixture:
353:        This restores the log levels changed by :meth:`set_level`.
365:        return self._item._store[caplog_handler_key]
379:        return self._item._store[caplog_records_key].get(when, [])
422:    def set_level(self, level: Union[int, str], logger: Optional[str] = None) -> None:
462:def caplog(request: FixtureRequest) -> Generator[LogCaptureFixture, None, None]:
467:    * caplog.messages        -> list of format-interpolated log messages
468:    * caplog.text            -> string containing formatted log output
469:    * caplog.records         -> list of logging.LogRecord instances
470:    * caplog.record_tuples   -> list of (logger_name, level, message) tuples
471:    * caplog.clear()         -> clear captured records and formatted log output string
526:        self.caplog_handler = LogCaptureHandler()
527:        self.caplog_handler.setFormatter(self.formatter)
677:            self.caplog_handler, level=self.log_level,
678:        ) as caplog_handler, catching_logs(
681:            caplog_handler.reset()
683:            item._store[caplog_records_key][when] = caplog_handler.records
684:            item._store[caplog_handler_key] = caplog_handler
696:        item._store[caplog_records_key] = empty
710:        del item._store[caplog_records_key]
711:        del item._store[caplog_handler_key]
```

**assistant → tool `read_file`**

```json
{
  "path": "src/_pytest/logging.py",
  "offset": 300,
  "limit": 180
}
```

**tool result**

```
        root_logger.addHandler(self.handler)
        if self.level is not None:
            self.orig_level = root_logger.level
            root_logger.setLevel(min(self.orig_level, self.level))
        return self.handler

    def __exit__(self, type, value, traceback):
        root_logger = logging.getLogger()
        if self.level is not None:
            root_logger.setLevel(self.orig_level)
        root_logger.removeHandler(self.handler)


class LogCaptureHandler(logging.StreamHandler):
    """A logging handler that stores log records and the log text."""

    stream = None  # type: StringIO

    def __init__(self) -> None:
        """Creates a new log handler."""
        super().__init__(StringIO())
        self.records = []  # type: List[logging.LogRecord]

    def emit(self, record: logging.LogRecord) -> None:
        """Keep the log records in a list in addition to the log text."""
        self.records.append(record)
        super().emit(record)

    def reset(self) -> None:
        self.records = []
        self.stream = StringIO()

    def handleError(self, record: logging.LogRecord) -> None:
        if logging.raiseExceptions:
            # Fail the test if the log message is bad (emit failed).
            # The default behavior of logging is to print "Logging error"
            # to stderr with the call stack and some extra details.
            # pytest wants to make such mistakes visible during testing.
            raise


class LogCaptureFixture:
    """Provides access and control of log capturing."""

    def __init__(self, item: nodes.Node) -> None:
        """Creates a new funcarg."""
        self._item = item
        # dict of log name -> log level
        self._initial_logger_levels = {}  # type: Dict[Optional[str], int]

    def _finalize(self) -> None:
        """Finalizes the fixture.

        This restores the log levels changed by :meth:`set_level`.
        """
        # restore log levels
        for logger_name, level in self._initial_logger_levels.items():
            logger = logging.getLogger(logger_name)
            logger.setLevel(level)

    @property
    def handler(self) -> LogCaptureHandler:
        """
        :rtype: LogCaptureHandler
        """
        return self._item._store[caplog_handler_key]

    def get_records(self, when: str) -> List[logging.LogRecord]:
        """
        Get the logging records for one of the possible test phases.

        :param str when:
            Which test phase to obtain the records from. Valid values are: "setup", "call" and "teardown".

        :rtype: List[logging.LogRecord]
        :return: the list of captured records at the given stage

        .. versionadded:: 3.4
        """
        return self._item._store[caplog_records_key].get(when, [])

    @property
    def text(self) -> str:
        """Returns the formatted log text."""
        return _remove_ansi_escape_sequences(self.handler.stream.getvalue())

    @property
    def records(self) -> List[logging.LogRecord]:
        """Returns the list of log records."""
        return self.handler.records

    @property
    def record_tuples(self) -> List[Tuple[str, int, str]]:
        """Returns a list of a stripped down version of log records intended
        for use in assertion comparison.

        The format of the tuple is:

            (logger_name, log_level, message)
        """
        return [(r.name, r.levelno, r.getMessage()) for r in self.records]

    @property
    def messages(self) -> List[str]:
        """Returns a list of format-interpolated log messages.

        Unlike 'records', which contains the format string and parameters for interpolation, log messages in this list
        are all interpolated.
        Unlike 'text', which contains the output from the handler, log messages in this list are unadorned with
        levels, timestamps, etc, making exact comparisons more reliable.

        Note that traceback or stack info (from :func:`logging.exception` or the `exc_info` or `stack_info` arguments
        to the logging functions) is not included, as this is added by the formatter in the handler.

        .. versionadded:: 3.7
        """
        return [r.getMessage() for r in self.records]

    def clear(self) -> None:
        """Reset the list of log records and the captured log text."""
        self.handler.reset()

    def set_level(self, level: Union[int, str], logger: Optional[str] = None) -> None:
        """Sets the level for capturing of logs. The level will be restored to its previous value at the end of
        the test.

        :param int level: the logger to level.
        :param str logger: the logger to update the level. If not given, the root logger level is updated.

        .. versionchanged:: 3.4
            The levels of the loggers changed by this function will be restored to their initial values at the
            end of the test.
        """
        logger_obj = logging.getLogger(logger)
        # save the original log-level to restore it during teardown
        self._initial_logger_levels.setdefault(logger, logger_obj.level)
        logger_obj.setLevel(level)
        self.handler.setLevel(level)

    @contextmanager
    def at_level(
        self, level: int, logger: Optional[str] = None
    ) -> Generator[None, None, None]:
        """Context manager that sets the level for capturing of logs. After the end of the 'with' statement the
        level is restored to its original value.

        :param int level: the logger to level.
        :param str logger: the logger to update the level. If not given, the root logger level is updated.
        """
        logger_obj = logging.getLogger(logger)
        orig_level = logger_obj.level
        logger_obj.setLevel(level)
        handler_orig_level = self.handler.level
        self.handler.setLevel(level)
        try:
            yield
        finally:
            logger_obj.setLevel(orig_level)
            self.handler.setLevel(handler_orig_level)


@pytest.fixture
def caplog(request: FixtureRequest) -> Generator[LogCaptureFixture, None, None]:
    """Access and control log capturing.

    Captured logs are available through the following properties/methods::

    * caplog.messages        -> list of format-interpolated log messages
    * caplog.text            -> string containing formatted log output
    * caplog.records         -> list of logging.LogRecord instances
    * caplog.record_tuples   -> list of (logger_name, level, message) tuples
    * caplog.clear()         -> clear captured records and formatted log output string
    """
    result = LogCaptureFixture(request.node)
    yield result
    result._finalize()


def get_log_level_for_setting(config: Config, *setting_names: str) -> Optional[int]:
    for setting_name in setting_names:

[337 more lines in /testbed/src/_pytest/logging.py (816 in all). read_file with offset: 480 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "src/_pytest/logging.py",
  "offset": 490,
  "limit": 240
}
```

**tool result**

```
    try:
        return int(getattr(logging, log_level, log_level))
    except ValueError as e:
        # Python logging does not recognise this as a logging level
        raise pytest.UsageError(
            "'{}' is not recognized as a logging level name for "
            "'{}'. Please consider passing the "
            "logging level num instead.".format(log_level, setting_name)
        ) from e


# run after terminalreporter/capturemanager are configured
@pytest.hookimpl(trylast=True)
def pytest_configure(config: Config) -> None:
    config.pluginmanager.register(LoggingPlugin(config), "logging-plugin")


class LoggingPlugin:
    """Attaches to the logging module and captures log messages for each test.
    """

    def __init__(self, config: Config) -> None:
        """Creates a new plugin to capture log messages.

        The formatter can be safely shared across all handlers so
        create a single one for the entire test session here.
        """
        self._config = config

        # Report logging.
        self.formatter = self._create_formatter(
            get_option_ini(config, "log_format"),
            get_option_ini(config, "log_date_format"),
            get_option_ini(config, "log_auto_indent"),
        )
        self.log_level = get_log_level_for_setting(config, "log_level")
        self.caplog_handler = LogCaptureHandler()
        self.caplog_handler.setFormatter(self.formatter)
        self.report_handler = LogCaptureHandler()
        self.report_handler.setFormatter(self.formatter)

        # File logging.
        self.log_file_level = get_log_level_for_setting(config, "log_file_level")
        log_file = get_option_ini(config, "log_file") or os.devnull
        if log_file != os.devnull:
            directory = os.path.dirname(os.path.abspath(log_file))
            if not os.path.isdir(directory):
                os.makedirs(directory)

        self.log_file_handler = _FileHandler(log_file, mode="w", encoding="UTF-8")
        log_file_format = get_option_ini(config, "log_file_format", "log_format")
        log_file_date_format = get_option_ini(
            config, "log_file_date_format", "log_date_format"
        )

        log_file_formatter = logging.Formatter(
            log_file_format, datefmt=log_file_date_format
        )
        self.log_file_handler.setFormatter(log_file_formatter)

        # CLI/live logging.
        self.log_cli_level = get_log_level_for_setting(
            config, "log_cli_level", "log_level"
        )
        if self._log_cli_enabled():
            terminal_reporter = config.pluginmanager.get_plugin("terminalreporter")
            capture_manager = config.pluginmanager.get_plugin("capturemanager")
            # if capturemanager plugin is disabled, live logging still works.
            self.log_cli_handler = _LiveLoggingStreamHandler(
                terminal_reporter, capture_manager
            )  # type: Union[_LiveLoggingStreamHandler, _LiveLoggingNullHandler]
        else:
            self.log_cli_handler = _LiveLoggingNullHandler()
        log_cli_formatter = self._create_formatter(
            get_option_ini(config, "log_cli_format", "log_format"),
            get_option_ini(config, "log_cli_date_format", "log_date_format"),
            get_option_ini(config, "log_auto_indent"),
        )
        self.log_cli_handler.setFormatter(log_cli_formatter)

    def _create_formatter(self, log_format, log_date_format, auto_indent):
        # color option doesn't exist if terminal plugin is disabled
        color = getattr(self._config.option, "color", "no")
        if color != "no" and ColoredLevelFormatter.LEVELNAME_FMT_REGEX.search(
            log_format
        ):
            formatter = ColoredLevelFormatter(
                create_terminal_writer(self._config), log_format, log_date_format
            )  # type: logging.Formatter
        else:
            formatter = logging.Formatter(log_format, log_date_format)

        formatter._style = PercentStyleMultiline(
            formatter._style._fmt, auto_indent=auto_indent
        )

        return formatter

    def set_log_path(self, fname: str) -> None:
        """Public method, which can set filename parameter for
        Logging.FileHandler(). Also creates parent directory if
        it does not exist.

        .. warning::
            Please considered as an experimental API.
        """
        fpath = Path(fname)

        if not fpath.is_absolute():
            fpath = Path(str(self._config.rootdir), fpath)

        if not fpath.parent.exists():
            fpath.parent.mkdir(exist_ok=True, parents=True)

        stream = fpath.open(mode="w", encoding="UTF-8")
        if sys.version_info >= (3, 7):
            old_stream = self.log_file_handler.setStream(stream)
        else:
            old_stream = self.log_file_handler.stream
            self.log_file_handler.acquire()
            try:
                self.log_file_handler.flush()
                self.log_file_handler.stream = stream
            finally:
                self.log_file_handler.release()
        if old_stream:
            old_stream.close()

    def _log_cli_enabled(self):
        """Return whether live logging is enabled."""
        enabled = self._config.getoption(
            "--log-cli-level"
        ) is not None or self._config.getini("log_cli")
        if not enabled:
            return False

        terminal_reporter = self._config.pluginmanager.get_plugin("terminalreporter")
        if terminal_reporter is None:
            # terminal reporter is disabled e.g. by pytest-xdist.
            return False

        return True

    @pytest.hookimpl(hookwrapper=True, tryfirst=True)
    def pytest_sessionstart(self) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("sessionstart")

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield

    @pytest.hookimpl(hookwrapper=True, tryfirst=True)
    def pytest_collection(self) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("collection")

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtestloop(self, session: Session) -> Generator[None, None, None]:
        """Runs all collected test items."""

        if session.config.option.collectonly:
            yield
            return

        if self._log_cli_enabled() and self._config.getoption("verbose") < 1:
            # setting verbose flag is needed to avoid messy test progress output
            self._config.option.verbose = 1

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield  # run all the tests

    @pytest.hookimpl
    def pytest_runtest_logstart(self) -> None:
        self.log_cli_handler.reset()
        self.log_cli_handler.set_when("start")

    @pytest.hookimpl
    def pytest_runtest_logreport(self) -> None:
        self.log_cli_handler.set_when("logreport")

    def _runtest_for(self, item: nodes.Item, when: str) -> Generator[None, None, None]:
        """Implements the internals of pytest_runtest_xxx() hook."""
        with catching_logs(
            self.caplog_handler, level=self.log_level,
        ) as caplog_handler, catching_logs(
            self.report_handler, level=self.log_level,
        ) as report_handler:
            caplog_handler.reset()
            report_handler.reset()
            item._store[caplog_records_key][when] = caplog_handler.records
            item._store[caplog_handler_key] = caplog_handler

            yield

            log = report_handler.stream.getvalue().strip()
            item.add_report_section(when, "log", log)

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtest_setup(self, item: nodes.Item) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("setup")

        empty = {}  # type: Dict[str, List[logging.LogRecord]]
        item._store[caplog_records_key] = empty
        yield from self._runtest_for(item, "setup")

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtest_call(self, item: nodes.Item) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("call")

        yield from self._runtest_for(item, "call")

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtest_teardown(self, item: nodes.Item) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("teardown")

        yield from self._runtest_for(item, "teardown")
        del item._store[caplog_records_key]
        del item._store[caplog_handler_key]

    @pytest.hookimpl
    def pytest_runtest_logfinish(self) -> None:
        self.log_cli_handler.set_when("finish")

    @pytest.hookimpl(hookwrapper=True, tryfirst=True)
    def pytest_sessionfinish(self) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("sessionfinish")

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield

    @pytest.hookimpl
    def pytest_unconfigure(self) -> None:
        # Close the FileHandler explicitly.
        # (logging.shutdown might have lost the weakref?!)
        self.log_file_handler.close()

[87 more lines in /testbed/src/_pytest/logging.py (816 in all). read_file with offset: 730 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"set_level\\|handler.level\\|_finalize\\|restore\" testing/test_logging.py | head -60"
}
```

**tool result**

```
grep: testing/test_logging.py: No such file or directory
```

**assistant → tool `bash`**

```json
{
  "command": "find testing -iname '*log*'"
}
```

**tool result**

```
testing/logging
testing/test_resultlog.py
```

**assistant → tool `bash`**

```json
{
  "command": "ls testing/logging && grep -rn \"set_level\\|handler.level\\|_finalize\\|restore\" testing/logging | head -80"
}
```

**tool result**

```
test_fixture.py
test_formatter.py
test_reporting.py
testing/logging/test_fixture.py:16:    caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:20:    caplog.set_level(logging.CRITICAL, logger=sublogger.name)
testing/logging/test_fixture.py:31:    """Ensure that 'set_level' is undone after the end of the test"""
testing/logging/test_fixture.py:37:            caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:69:    caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:77:    caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:98:    caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:105:    caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:113:    caplog.set_level(logging.INFO)
testing/logging/test_fixture.py:124:    caplog.set_level("INFO")
testing/logging/test_fixture.py:182:            caplog.set_level(logging.INFO, logger.name)
testing/logging/test_reporting.py:215:            assert plugin.log_cli_handler.level == logging.NOTSET
testing/logging/test_reporting.py:498:            assert plugin.log_cli_handler.level == logging.INFO
testing/logging/test_reporting.py:554:            assert plugin.log_cli_handler.level == logging.INFO
testing/logging/test_reporting.py:631:            assert plugin.log_file_handler.level == logging.WARNING
testing/logging/test_reporting.py:664:            assert plugin.log_file_handler.level == logging.INFO
testing/logging/test_reporting.py:719:            assert plugin.log_file_handler.level == logging.WARNING
testing/logging/test_reporting.py:758:            assert plugin.log_file_handler.level == logging.INFO
```

**assistant → tool `read_file`**

```json
{
  "path": "testing/logging/test_fixture.py",
  "limit": 210
}
```

**tool result**

```
import logging

import pytest
from _pytest.logging import caplog_records_key

logger = logging.getLogger(__name__)
sublogger = logging.getLogger(__name__ + ".baz")


def test_fixture_help(testdir):
    result = testdir.runpytest("--fixtures")
    result.stdout.fnmatch_lines(["*caplog*"])


def test_change_level(caplog):
    caplog.set_level(logging.INFO)
    logger.debug("handler DEBUG level")
    logger.info("handler INFO level")

    caplog.set_level(logging.CRITICAL, logger=sublogger.name)
    sublogger.warning("logger WARNING level")
    sublogger.critical("logger CRITICAL level")

    assert "DEBUG" not in caplog.text
    assert "INFO" in caplog.text
    assert "WARNING" not in caplog.text
    assert "CRITICAL" in caplog.text


def test_change_level_undo(testdir):
    """Ensure that 'set_level' is undone after the end of the test"""
    testdir.makepyfile(
        """
        import logging

        def test1(caplog):
            caplog.set_level(logging.INFO)
            # using + operator here so fnmatch_lines doesn't match the code in the traceback
            logging.info('log from ' + 'test1')
            assert 0

        def test2(caplog):
            # using + operator here so fnmatch_lines doesn't match the code in the traceback
            logging.info('log from ' + 'test2')
            assert 0
    """
    )
    result = testdir.runpytest()
    result.stdout.fnmatch_lines(["*log from test1*", "*2 failed in *"])
    result.stdout.no_fnmatch_line("*log from test2*")


def test_with_statement(caplog):
    with caplog.at_level(logging.INFO):
        logger.debug("handler DEBUG level")
        logger.info("handler INFO level")

        with caplog.at_level(logging.CRITICAL, logger=sublogger.name):
            sublogger.warning("logger WARNING level")
            sublogger.critical("logger CRITICAL level")

    assert "DEBUG" not in caplog.text
    assert "INFO" in caplog.text
    assert "WARNING" not in caplog.text
    assert "CRITICAL" in caplog.text


def test_log_access(caplog):
    caplog.set_level(logging.INFO)
    logger.info("boo %s", "arg")
    assert caplog.records[0].levelname == "INFO"
    assert caplog.records[0].msg == "boo %s"
    assert "boo arg" in caplog.text


def test_messages(caplog):
    caplog.set_level(logging.INFO)
    logger.info("boo %s", "arg")
    logger.info("bar %s\nbaz %s", "arg1", "arg2")
    assert "boo arg" == caplog.messages[0]
    assert "bar arg1\nbaz arg2" == caplog.messages[1]
    assert caplog.text.count("\n") > len(caplog.messages)
    assert len(caplog.text.splitlines()) > len(caplog.messages)

    try:
        raise Exception("test")
    except Exception:
        logger.exception("oops")

    assert "oops" in caplog.text
    assert "oops" in caplog.messages[-1]
    # Tracebacks are stored in the record and not added until the formatter or handler.
    assert "Exception" in caplog.text
    assert "Exception" not in caplog.messages[-1]


def test_record_tuples(caplog):
    caplog.set_level(logging.INFO)
    logger.info("boo %s", "arg")

    assert caplog.record_tuples == [(__name__, logging.INFO, "boo arg")]


def test_unicode(caplog):
    caplog.set_level(logging.INFO)
    logger.info("bū")
    assert caplog.records[0].levelname == "INFO"
    assert caplog.records[0].msg == "bū"
    assert "bū" in caplog.text


def test_clear(caplog):
    caplog.set_level(logging.INFO)
    logger.info("bū")
    assert len(caplog.records)
    assert caplog.text
    caplog.clear()
    assert not len(caplog.records)
    assert not caplog.text


@pytest.fixture
def logging_during_setup_and_teardown(caplog):
    caplog.set_level("INFO")
    logger.info("a_setup_log")
    yield
    logger.info("a_teardown_log")
    assert [x.message for x in caplog.get_records("teardown")] == ["a_teardown_log"]


def test_caplog_captures_for_all_stages(caplog, logging_during_setup_and_teardown):
    assert not caplog.records
    assert not caplog.get_records("call")
    logger.info("a_call_log")
    assert [x.message for x in caplog.get_records("call")] == ["a_call_log"]

    assert [x.message for x in caplog.get_records("setup")] == ["a_setup_log"]

    # This reaches into private API, don't use this type of thing in real tests!
    assert set(caplog._item._store[caplog_records_key]) == {"setup", "call"}


def test_ini_controls_global_log_level(testdir):
    testdir.makepyfile(
        """
        import pytest
        import logging
        def test_log_level_override(request, caplog):
            plugin = request.config.pluginmanager.getplugin('logging-plugin')
            assert plugin.log_level == logging.ERROR
            logger = logging.getLogger('catchlog')
            logger.warning("WARNING message won't be shown")
            logger.error("ERROR message will be shown")
            assert 'WARNING' not in caplog.text
            assert 'ERROR' in caplog.text
    """
    )
    testdir.makeini(
        """
        [pytest]
        log_level=ERROR
    """
    )

    result = testdir.runpytest()
    # make sure that that we get a '0' exit code for the testsuite
    assert result.ret == 0


def test_caplog_can_override_global_log_level(testdir):
    testdir.makepyfile(
        """
        import pytest
        import logging
        def test_log_level_override(request, caplog):
            logger = logging.getLogger('catchlog')
            plugin = request.config.pluginmanager.getplugin('logging-plugin')
            assert plugin.log_level == logging.WARNING

            logger.info("INFO message won't be shown")

            caplog.set_level(logging.INFO, logger.name)

            with caplog.at_level(logging.DEBUG, logger.name):
                logger.debug("DEBUG message will be shown")

            logger.debug("DEBUG message won't be shown")

            with caplog.at_level(logging.CRITICAL, logger.name):
                logger.warning("WARNING message won't be shown")

            logger.debug("DEBUG message won't be shown")
            logger.info("INFO message will be shown")

            assert "message won't be shown" not in caplog.text
    """
    )
    testdir.makeini(
        """
        [pytest]
        log_level=WARNING
    """
    )

    result = testdir.runpytest()
    assert result.ret == 0


def test_caplog_captures_despite_exception(testdir):
    testdir.makepyfile(

[66 more lines in /testbed/testing/logging/test_fixture.py (276 in all). read_file with offset: 211 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: src/_pytest/logging.py\n@@\n     def __init__(self, item: nodes.Node) -> None:\n         \"\"\"Creates a new funcarg.\"\"\"\n         self._item = item\n         # dict of log name -> log level\n         self._initial_logger_levels = {}  # type: Dict[Optional[str], int]\n+        self._initial_handler_level = None  # type: Optional[int]\n@@\n         # restore log levels\n         for logger_name, level in self._initial_logger_levels.items():\n             logger = logging.getLogger(logger_name)\n             logger.setLevel(level)\n+        if self._initial_handler_level is not None:\n+            self.handler.setLevel(self._initial_handler_level)\n@@\n         logger_obj = logging.getLogger(logger)\n         # save the original log-level to restore it during teardown\n         self._initial_logger_levels.setdefault(logger, logger_obj.level)\n+        if self._initial_handler_level is None:\n+            self._initial_handler_level = self.handler.level\n         logger_obj.setLevel(level)\n         self.handler.setLevel(level)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[src/_pytest/logging.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

src/_pytest/logging.py now (821 lines), around the change:
346:        self._item = item
347:        # dict of log name -> log level
348:        self._initial_logger_levels = {}  # type: Dict[Optional[str], int]
349:        self._initial_handler_level = None  # type: Optional[int]
350:
351:    def _finalize(self) -> None:
352:        """Finalizes the fixture.
…
357:        for logger_name, level in self._initial_logger_levels.items():
358:            logger = logging.getLogger(logger_name)
359:            logger.setLevel(level)
360:        if self._initial_handler_level is not None:
361:            self.handler.setLevel(self._initial_handler_level)
362:
363:    @property
364:    def handler(self) -> LogCaptureHandler:
…
436:        logger_obj = logging.getLogger(logger)
437:        # save the original log-level to restore it during teardown
438:        self._initial_logger_levels.setdefault(logger, logger_obj.level)
439:        if self._initial_handler_level is None:
440:            self._initial_handler_level = self.handler.level
441:        logger_obj.setLevel(level)
442:        self.handler.setLevel(level)
443:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: testing/logging/test_fixture.py\n@@\n def test_change_level_undo(testdir):\n     \"\"\"Ensure that 'set_level' is undone after the end of the test\"\"\"\n@@\n     result.stdout.fnmatch_lines([\"*log from test1*\", \"*2 failed in *\"])\n     result.stdout.no_fnmatch_line(\"*log from test2*\")\n \n \n+def test_change_level_undo_handler(testdir):\n+    \"\"\"Ensure that the caplog handler level set by 'set_level' is undone\n+    after the end of the test.\"\"\"\n+    testdir.makepyfile(\n+        \"\"\"\n+        import logging\n+\n+        def test1(caplog):\n+            caplog.set_level(logging.INFO)\n+            assert caplog.handler.level == logging.INFO\n+\n+        def test2(caplog):\n+            assert caplog.handler.level == logging.NOTSET\n+    \"\"\"\n+    )\n+    result = testdir.runpytest()\n+    result.stdout.fnmatch_lines([\"*2 passed in *\"])\n+\n+\n def test_with_statement(caplog):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[testing/logging/test_fixture.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

testing/logging/test_fixture.py now (295 lines), around the change:
48:    result = testdir.runpytest()
49:    result.stdout.fnmatch_lines(["*log from test1*", "*2 failed in *"])
50:    result.stdout.no_fnmatch_line("*log from test2*")
51:
52:
53:def test_change_level_undo_handler(testdir):
54:    """Ensure that the caplog handler level set by 'set_level' is undone
55:    after the end of the test."""
56:    testdir.makepyfile(
57:        """
58:        import logging
59:
60:        def test1(caplog):
61:            caplog.set_level(logging.INFO)
62:            assert caplog.handler.level == logging.INFO
63:
64:        def test2(caplog):
65:            assert caplog.handler.level == logging.NOTSET
66:    """
67:    )
68:    result = testdir.runpytest()
69:    result.stdout.fnmatch_lines(["*2 passed in *"])
70:
71:
72:def test_with_statement(caplog):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest testing/logging/test_fixture.py -q"
}
```

**tool result**

```
...............                                                          [100%]
15 passed in 0.42s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest testing/logging -q"
}
```

**tool result**

```
..........................................................               [100%]
58 passed in 2.42s
```

**assistant → tool `bash`**

```json
{
  "command": "ls changelog | head && grep -rn \"caplog\" changelog | head"
}
```

**tool result**

```
5584.breaking.rst
7389.trivial.rst
7392.bugfix.rst
7394.bugfix.rst
7422.doc.rst
7441.doc.rst
7464.feature.rst
7467.improvement.rst
7472.breaking.rst
7489.improvement.rst
```

**assistant**

```
Fixed. The root cause was that `caplog.set_level()` changed both the logger level *and* the shared `LogCaptureHandler` level, but `LogCaptureFixture._finalize()` only restored the logger levels. Since the handler is reused across tests, its level leaked into subsequent tests.

Changes in `src/_pytest/logging.py`:

- Track the handler's original level in `_initial_handler_level` the first time `set_level()` is called.
- Restore that level in `_finalize()` after the test.

Added a regression test in `testing/logging/test_fixture.py` verifying that the handler level is back to `NOTSET` in a following test.

Verification: `python -m pytest testing/logging -q` — **58 passed**.
```

## Run folder `team-solve-2026-11-06T132404`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
016f0edeafd634cae3dde59d7ed28dba6668a44b
```

### `baseline-check.log`

```
check: python -m pytest testing/logging/test_fixture.py -q
..............                                                           [100%]
14 passed in 0.33s
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/src/_pytest/logging.py b/src/_pytest/logging.py
index 11031f2f2..3c56f8c37 100644
--- a/src/_pytest/logging.py
+++ b/src/_pytest/logging.py
@@ -346,6 +346,7 @@ class LogCaptureFixture:
         self._item = item
         # dict of log name -> log level
         self._initial_logger_levels = {}  # type: Dict[Optional[str], int]
+        self._initial_handler_level = None  # type: Optional[int]
 
     def _finalize(self) -> None:
         """Finalizes the fixture.
@@ -356,6 +357,8 @@ class LogCaptureFixture:
         for logger_name, level in self._initial_logger_levels.items():
             logger = logging.getLogger(logger_name)
             logger.setLevel(level)
+        if self._initial_handler_level is not None:
+            self.handler.setLevel(self._initial_handler_level)
 
     @property
     def handler(self) -> LogCaptureHandler:
@@ -433,6 +436,8 @@ class LogCaptureFixture:
         logger_obj = logging.getLogger(logger)
         # save the original log-level to restore it during teardown
         self._initial_logger_levels.setdefault(logger, logger_obj.level)
+        if self._initial_handler_level is None:
+            self._initial_handler_level = self.handler.level
         logger_obj.setLevel(level)
         self.handler.setLevel(level)
 
diff --git a/testing/logging/test_fixture.py b/testing/logging/test_fixture.py
index da5303302..61aed2733 100644
--- a/testing/logging/test_fixture.py
+++ b/testing/logging/test_fixture.py
@@ -50,6 +50,25 @@ def test_change_level_undo(testdir):
     result.stdout.no_fnmatch_line("*log from test2*")
 
 
+def test_change_level_undo_handler(testdir):
+    """Ensure that the caplog handler level set by 'set_level' is undone
+    after the end of the test."""
+    testdir.makepyfile(
+        """
+        import logging
+
+        def test1(caplog):
+            caplog.set_level(logging.INFO)
+            assert caplog.handler.level == logging.INFO
+
+        def test2(caplog):
+            assert caplog.handler.level == logging.NOTSET
+    """
+    )
+    result = testdir.runpytest()
+    result.stdout.fnmatch_lines(["*2 passed in *"])
+
+
 def test_with_statement(caplog):
     with caplog.at_level(logging.INFO):
         logger.debug("handler DEBUG level")
```

### `check-kind.txt`

```
command
```

### `context.md`

````
# task.md

# Task

## Prompt

caplog fixture doesn't restore log level after test
From the documentation at https://docs.pytest.org/en/6.0.0/logging.html#caplog-fixture, "The log levels set are restored automatically at the end of the test".
It used to work, but looks broken in new 6.0 release. Minimal example to reproduce:

```
def test_foo(caplog):
    caplog.set_level(42)

def test_bar(caplog):
    print(caplog.handler.level)
```

It prints "0" for pytest<6, "42" after.

## Deliverable

changes to this tree

## Check

`python -m pytest testing/logging/test_fixture.py -q`

## Scope

`src/_pytest/logging.py`
`testing/logging/test_fixture.py`

## Done when

`caplog.set_level(42)` in one test no longer leaves `caplog.handler.level` at 42 in the next test; the handler level is restored automatically at the end of the test.
A logger level changed by `caplog.set_level(..., logger=...)` is restored at the end of the test.
The minimal two-test reproduction from the prompt passes with the old/default level visible in the later test.
Existing `caplog` fixture tests continue to pass.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest testing/logging/test_fixture.py -q`

## Scope
`src/_pytest/logging.py`
`testing/logging/test_fixture.py`

## Done when
`caplog.set_level(42)` in one test no longer leaves `caplog.handler.level` at 42 in the next test; the handler level is restored automatically at the end of the test.
A logger level changed by `caplog.set_level(..., logger=...)` is restored at the end of the test.
The minimal two-test reproduction from the prompt passes with the old/default level visible in the later test.
Existing `caplog` fixture tests continue to pass.

## Approach
Decompose into: add or identify a regression test in `testing/logging/test_fixture.py` covering both the handler-level leak from the minimal example and logger-level restoration; inspect `LogCaptureFixture.set_level` and `_finalize` in `src/_pytest/logging.py`; ensure original levels are captured before mutation and restored exactly once at finalization.

Candidate approaches:
1. Minimal fixture-local fix: in `LogCaptureFixture.set_level`, record the original handler level before the first `handler.setLevel(level)` call, and record each logger’s original level before its `setLevel(level)` call. In `_finalize`, restore the stored handler level and logger levels. This matches the documented behavior and is the least invasive.
2. Plugin lifecycle fix: capture/restore the handler level in the logging plugin’s per-phase context manager instead of relying only on the fixture finalizer. This may be more robust if the handler is recreated per phase, but risks restoring during teardown while logging should still be captured.
3. Avoid reusing the handler across tests/phases if the handler is shared unintentionally, restoring only logger levels separately. This fixes the observed leak but changes handler identity and may break code that keeps a reference to `caplog.handler`.

Prefer approach 1 unless inspection shows the handler is shared across test phases, in which case combine 1 with the phase-aware restoration from 2.


# src/_pytest/logging.py

```
""" Access and control log capturing. """
import logging
import os
import re
import sys
from contextlib import contextmanager
from io import StringIO
from typing import AbstractSet
from typing import Dict
from typing import Generator
from typing import List
from typing import Mapping
from typing import Optional
from typing import Tuple
from typing import TypeVar
from typing import Union

import pytest
from _pytest import nodes
from _pytest._io import TerminalWriter
from _pytest.capture import CaptureManager
from _pytest.compat import nullcontext
from _pytest.config import _strtobool
from _pytest.config import Config
from _pytest.config import create_terminal_writer
from _pytest.config.argparsing import Parser
from _pytest.fixtures import FixtureRequest
from _pytest.main import Session
from _pytest.pathlib import Path
from _pytest.store import StoreKey
from _pytest.terminal import TerminalReporter


DEFAULT_LOG_FORMAT = "%(levelname)-8s %(name)s:%(filename)s:%(lineno)d %(message)s"
DEFAULT_LOG_DATE_FORMAT = "%H:%M:%S"
_ANSI_ESCAPE_SEQ = re.compile(r"\x1b\[[\d;]+m")
caplog_handler_key = StoreKey["LogCaptureHandler"]()
caplog_records_key = StoreKey[Dict[str, List[logging.LogRecord]]]()


def _remove_ansi_escape_sequences(text: str) -> str:
    return _ANSI_ESCAPE_SEQ.sub("", text)


class ColoredLevelFormatter(logging.Formatter):
    """
    Colorize the %(levelname)..s part of the log format passed to __init__.
    """

    LOGLEVEL_COLOROPTS = {
        logging.CRITICAL: {"red"},
        logging.ERROR: {"red", "bold"},
        logging.WARNING: {"yellow"},
        logging.WARN: {"yellow"},
        logging.INFO: {"green"},
        logging.DEBUG: {"purple"},
        logging.NOTSET: set(),
    }  # type: Mapping[int, AbstractSet[str]]
    LEVELNAME_FMT_REGEX = re.compile(r"%\(levelname\)([+-.]?\d*s)")

    def __init__(self, terminalwriter: TerminalWriter, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._original_fmt = self._style._fmt
        self._level_to_fmt_mapping = {}  # type: Dict[int, str]

        assert self._fmt is not None
        levelname_fmt_match = self.LEVELNAME_FMT_REGEX.search(self._fmt)
        if not levelname_fmt_match:
            return
        levelname_fmt = levelname_fmt_match.group()

        for level, color_opts in self.LOGLEVEL_COLOROPTS.items():
            formatted_levelname = levelname_fmt % {
                "levelname": logging.getLevelName(level)
            }

            # add ANSI escape sequences around the formatted levelname
            color_kwargs = {name: True for name in color_opts}
            colorized_formatted_levelname = terminalwriter.markup(
                formatted_levelname, **color_kwargs
            )
            self._level_to_fmt_mapping[level] = self.LEVELNAME_FMT_REGEX.sub(
                colorized_formatted_levelname, self._fmt
            )

    def format(self, record: logging.LogRecord) -> str:
        fmt = self._level_to_fmt_mapping.get(record.levelno, self._original_fmt)
        self._style._fmt = fmt
        return super().format(record)


class PercentStyleMultiline(logging.PercentStyle):
    """A logging style with special support for multiline messages.

    If the message of a record consists of multiple lines, this style
    formats the message as if each line were logged separately.
    """

    def __init__(self, fmt: str, auto_indent: Union[int, str, bool, None]) -> None:
        super().__init__(fmt)
        self._auto_indent = self._get_auto_indent(auto_indent)

    @staticmethod
    def _update_message(
        record_dict: Dict[str, object], message: str
    ) -> Dict[str, object]:
        tmp = record_dict.copy()
        tmp["message"] = message
        return tmp

    @staticmethod
    def _get_auto_indent(auto_indent_option: Union[int, str, bool, None]) -> int:
        """Determines the current auto indentation setting

        Specify auto indent behavior (on/off/fixed) by passing in
        extra={"auto_indent": [value]} to the call to logging.log() or
        using a --log-auto-indent [value] command line or the
        log_auto_indent [value] config option.

        Default behavior is auto-indent off.

        Using the string "True" or "on" or the boolean True as the value
        turns auto indent on, using the string "False" or "off" or the
        boolean False or the int 0 turns it off, and specifying a
        positive integer fixes the indentation position to the value
        specified.

        Any other values for the option are invalid, and will silently be
        converted to the default.

        :param any auto_indent_option: User specified option for indentation
            from command line, config or extra kwarg. Accepts int, bool or str.
            str option accepts the same range of values as boolean config options,
            as well as positive integers represented in str form.

        :returns: indentation value, which can be
            -1 (automatically determine indentation) or
            0 (auto-indent turned off) or
            >0 (explicitly set indentation position).
        """

        if auto_indent_option is None:
            return 0
        elif isinstance(auto_indent_option, bool):
            if auto_indent_option:
                return -1
            else:
                return 0
        elif isinstance(auto_indent_option, int):
            return int(auto_indent_option)
        elif isinstance(auto_indent_option, str):
            try:
                return int(auto_indent_option)
            except ValueError:
                pass
            try:
                if _strtobool(auto_indent_option):
                    return -1
            except ValueError:
                return 0

        return 0

    def format(self, record: logging.LogRecord) -> str:
        if "\n" in record.message:
            if hasattr(record, "auto_indent"):
                # passed in from the "extra={}" kwarg on the call to logging.log()
                auto_indent = self._get_auto_indent(record.auto_indent)  # type: ignore[attr-defined]
            else:
                auto_indent = self._auto_indent

            if auto_indent:
                lines = record.message.splitlines()
                formatted = self._fmt % self._update_message(record.__dict__, lines[0])

                if auto_indent < 0:
                    indentation = _remove_ansi_escape_sequences(formatted).find(
                        lines[0]
                    )
                else:
                    # optimizes logging by allowing a fixed indentation
                    indentation = auto_indent
                lines[0] = formatted
                return ("\n" + " " * indentation).join(lines)
        return self._fmt % record.__dict__


def get_option_ini(config: Config, *names: str):
    for name in names:
        ret = config.getoption(name)  # 'default' arg won't work as expected
        if ret is None:
            ret = config.getini(name)
        if ret:
            return ret


def pytest_addoption(parser: Parser) -> None:
    """Add options to control log capturing."""
    group = parser.getgroup("logging")

    def add_option_ini(option, dest, default=None, type=None, **kwargs):
        parser.addini(
            dest, default=default, type=type, help="default value for " + option
        )
        group.addoption(option, dest=dest, **kwargs)

    add_option_ini(
        "--log-level",
        dest="log_level",
        default=None,
        metavar="LEVEL",
        help=(
            "level of messages to catch/display.\n"
            "Not set by default, so it depends on the root/parent log handler's"
            ' effective level, where it is "WARNING" by default.'
        ),
    )
    add_option_ini(
        "--log-format",
        dest="log_format",
        default=DEFAULT_LOG_FORMAT,
        help="log format as used by the logging module.",
    )
    add_option_ini(
        "--log-date-format",
        dest="log_date_format",
        default=DEFAULT_LOG_DATE_FORMAT,
        help="log date format as used by the logging module.",
    )
    parser.addini(
        "log_cli",
        default=False,
        type="bool",
        help='enable log display during test run (also known as "live logging").',
    )
    add_option_ini(
        "--log-cli-level", dest="log_cli_level", default=None, help="cli logging level."
    )
    add_option_ini(
        "--log-cli-format",
        dest="log_cli_format",
        default=None,
        help="log format as used by the logging module.",
    )
    add_option_ini(
        "--log-cli-date-format",
        dest="log_cli_date_format",
        default=None,
        help="log date format as used by the logging module.",
    )
    add_option_ini(
        "--log-file",
        dest="log_file",
        default=None,
        help="path to a file when logging will be written to.",
    )
    add_option_ini(
        "--log-file-level",
        dest="log_file_level",
        default=None,
        help="log file logging level.",
    )
    add_option_ini(
        "--log-file-format",
        dest="log_file_format",
        default=DEFAULT_LOG_FORMAT,
        help="log format as used by the logging module.",
    )
    add_option_ini(
        "--log-file-date-format",
        dest="log_file_date_format",
        default=DEFAULT_LOG_DATE_FORMAT,
        help="log date format as used by the logging module.",
    )
    add_option_ini(
        "--log-auto-indent",
        dest="log_auto_indent",
        default=None,
        help="Auto-indent multiline messages passed to the logging module. Accepts true|on, false|off or an integer.",
    )


_HandlerType = TypeVar("_HandlerType", bound=logging.Handler)


# Not using @contextmanager for performance reasons.
class catching_logs:
    """Context manager that prepares the whole logging machinery properly."""

    __slots__ = ("handler", "level", "orig_level")

    def __init__(self, handler: _HandlerType, level: Optional[int] = None) -> None:
        self.handler = handler
        self.level = level

    def __enter__(self):
        root_logger = logging.getLogger()
        if self.level is not None:
            self.handler.setLevel(self.level)
        root_logger.addHandler(self.handler)
        if self.level is not None:
            self.orig_level = root_logger.level
            root_logger.setLevel(min(self.orig_level, self.level))
        return self.handler

    def __exit__(self, type, value, traceback):
        root_logger = logging.getLogger()
        if self.level is not None:
            root_logger.setLevel(self.orig_level)
        root_logger.removeHandler(self.handler)


class LogCaptureHandler(logging.StreamHandler):
    """A logging handler that stores log records and the log text."""

    stream = None  # type: StringIO

    def __init__(self) -> None:
        """Creates a new log handler."""
        super().__init__(StringIO())
        self.records = []  # type: List[logging.LogRecord]

    def emit(self, record: logging.LogRecord) -> None:
        """Keep the log records in a list in addition to the log text."""
        self.records.append(record)
        super().emit(record)

    def reset(self) -> None:
        self.records = []
        self.stream = StringIO()

    def handleError(self, record: logging.LogRecord) -> None:
        if logging.raiseExceptions:
            # Fail the test if the log message is bad (emit failed).
            # The default behavior of logging is to print "Logging error"
            # to stderr with the call stack and some extra details.
            # pytest wants to make such mistakes visible during testing.
            raise


class LogCaptureFixture:
    """Provides access and control of log capturing."""

    def __init__(self, item: nodes.Node) -> None:
        """Creates a new funcarg."""
        self._item = item
        # dict of log name -> log level
        self._initial_logger_levels = {}  # type: Dict[Optional[str], int]
        self._initial_handler_level = None  # type: Optional[int]

    def _finalize(self) -> None:
        """Finalizes the fixture.

        This restores the log levels changed by :meth:`set_level`.
        """
        # restore log levels
        for logger_name, level in self._initial_logger_levels.items():
            logger = logging.getLogger(logger_name)
            logger.setLevel(level)
        if self._initial_handler_level is not None:
            self.handler.setLevel(self._initial_handler_level)

    @property
    def handler(self) -> LogCaptureHandler:
        """
        :rtype: LogCaptureHandler
        """
        return self._item._store[caplog_handler_key]

    def get_records(self, when: str) -> List[logging.LogRecord]:
        """
        Get the logging records for one of the possible test phases.

        :param str when:
            Which test phase to obtain the records from. Valid values are: "setup", "call" and "teardown".

        :rtype: List[logging.LogRecord]
        :return: the list of captured records at the given stage

        .. versionadded:: 3.4
        """
        return self._item._store[caplog_records_key].get(when, [])

    @property
    def text(self) -> str:
        """Returns the formatted log text."""
        return _remove_ansi_escape_sequences(self.handler.stream.getvalue())

    @property
    def records(self) -> List[logging.LogRecord]:
        """Returns the list of log records."""
        return self.handler.records

    @property
    def record_tuples(self) -> List[Tuple[str, int, str]]:
        """Returns a list of a stripped down version of log records intended
        for use in assertion comparison.

        The format of the tuple is:

            (logger_name, log_level, message)
        """
        return [(r.name, r.levelno, r.getMessage()) for r in self.records]

    @property
    def messages(self) -> List[str]:
        """Returns a list of format-interpolated log messages.

        Unlike 'records', which contains the format string and parameters for interpolation, log messages in this list
        are all interpolated.
        Unlike 'text', which contains the output from the handler, log messages in this list are unadorned with
        levels, timestamps, etc, making exact comparisons more reliable.

        Note that traceback or stack info (from :func:`logging.exception` or the `exc_info` or `stack_info` arguments
        to the logging functions) is not included, as this is added by the formatter in the handler.

        .. versionadded:: 3.7
        """
        return [r.getMessage() for r in self.records]

    def clear(self) -> None:
        """Reset the list of log records and the captured log text."""
        self.handler.reset()

    def set_level(self, level: Union[int, str], logger: Optional[str] = None) -> None:
        """Sets the level for capturing of logs. The level will be restored to its previous value at the end of
        the test.

        :param int level: the logger to level.
        :param str logger: the logger to update the level. If not given, the root logger level is updated.

        .. versionchanged:: 3.4
            The levels of the loggers changed by this function will be restored to their initial values at the
            end of the test.
        """
        logger_obj = logging.getLogger(logger)
        # save the original log-level to restore it during teardown
        self._initial_logger_levels.setdefault(logger, logger_obj.level)
        if self._initial_handler_level is None:
            self._initial_handler_level = self.handler.level
        logger_obj.setLevel(level)
        self.handler.setLevel(level)

    @contextmanager
    def at_level(
        self, level: int, logger: Optional[str] = None
    ) -> Generator[None, None, None]:
        """Context manager that sets the level for capturing of logs. After the end of the 'with' statement the
        level is restored to its original value.

        :param int level: the logger to level.
        :param str logger: the logger to update the level. If not given, the root logger level is updated.
        """
        logger_obj = logging.getLogger(logger)
        orig_level = logger_obj.level
        logger_obj.setLevel(level)
        handler_orig_level = self.handler.level
        self.handler.setLevel(level)
        try:
            yield
        finally:
            logger_obj.setLevel(orig_level)
            self.handler.setLevel(handler_orig_level)


@pytest.fixture
def caplog(request: FixtureRequest) -> Generator[LogCaptureFixture, None, None]:
    """Access and control log capturing.

    Captured logs are available through the following properties/methods::

    * caplog.messages        -> list of format-interpolated log messages
    * caplog.text            -> string containing formatted log output
    * caplog.records         -> list of logging.LogRecord instances
    * caplog.record_tuples   -> list of (logger_name, level, message) tuples
    * caplog.clear()         -> clear captured records and formatted log output string
    """
    result = LogCaptureFixture(request.node)
    yield result
    result._finalize()


def get_log_level_for_setting(config: Config, *setting_names: str) -> Optional[int]:
    for setting_name in setting_names:
        log_level = config.getoption(setting_name)
        if log_level is None:
            log_level = config.getini(setting_name)
        if log_level:
            break
    else:
        return None

    if isinstance(log_level, str):
        log_level = log_level.upper()
    try:
        return int(getattr(logging, log_level, log_level))
    except ValueError as e:
        # Python logging does not recognise this as a logging level
        raise pytest.UsageError(
            "'{}' is not recognized as a logging level name for "
            "'{}'. Please consider passing the "
            "logging level num instead.".format(log_level, setting_name)
        ) from e


# run after terminalreporter/capturemanager are configured
@pytest.hookimpl(trylast=True)
def pytest_configure(config: Config) -> None:
    config.pluginmanager.register(LoggingPlugin(config), "logging-plugin")


class LoggingPlugin:
    """Attaches to the logging module and captures log messages for each test.
    """

    def __init__(self, config: Config) -> None:
        """Creates a new plugin to capture log messages.

        The formatter can be safely shared across all handlers so
        create a single one for the entire test session here.
        """
        self._config = config

        # Report logging.
        self.formatter = self._create_formatter(
            get_option_ini(config, "log_format"),
            get_option_ini(config, "log_date_format"),
            get_option_ini(config, "log_auto_indent"),
        )
        self.log_level = get_log_level_for_setting(config, "log_level")
        self.caplog_handler = LogCaptureHandler()
        self.caplog_handler.setFormatter(self.formatter)
        self.report_handler = LogCaptureHandler()
        self.report_handler.setFormatter(self.formatter)

        # File logging.
        self.log_file_level = get_log_level_for_setting(config, "log_file_level")
        log_file = get_option_ini(config, "log_file") or os.devnull
        if log_file != os.devnull:
            directory = os.path.dirname(os.path.abspath(log_file))
            if not os.path.isdir(directory):
                os.makedirs(directory)

        self.log_file_handler = _FileHandler(log_file, mode="w", encoding="UTF-8")
        log_file_format = get_option_ini(config, "log_file_format", "log_format")
        log_file_date_format = get_option_ini(
            config, "log_file_date_format", "log_date_format"
        )

        log_file_formatter = logging.Formatter(
            log_file_format, datefmt=log_file_date_format
        )
        self.log_file_handler.setFormatter(log_file_formatter)

        # CLI/live logging.
        self.log_cli_level = get_log_level_for_setting(
            config, "log_cli_level", "log_level"
        )
        if self._log_cli_enabled():
            terminal_reporter = config.pluginmanager.get_plugin("terminalreporter")
            capture_manager = config.pluginmanager.get_plugin("capturemanager")
            # if capturemanager plugin is disabled, live logging still works.
            self.log_cli_handler = _LiveLoggingStreamHandler(
                terminal_reporter, capture_manager
            )  # type: Union[_LiveLoggingStreamHandler, _LiveLoggingNullHandler]
        else:
            self.log_cli_handler = _LiveLoggingNullHandler()
        log_cli_formatter = self._create_formatter(
            get_option_ini(config, "log_cli_format", "log_format"),
            get_option_ini(config, "log_cli_date_format", "log_date_format"),
            get_option_ini(config, "log_auto_indent"),
        )
        self.log_cli_handler.setFormatter(log_cli_formatter)

    def _create_formatter(self, log_format, log_date_format, auto_indent):
        # color option doesn't exist if terminal plugin is disabled
        color = getattr(self._config.option, "color", "no")
        if color != "no" and ColoredLevelFormatter.LEVELNAME_FMT_REGEX.search(
            log_format
        ):
            formatter = ColoredLevelFormatter(
                create_terminal_writer(self._config), log_format, log_date_format
            )  # type: logging.Formatter
        else:
            formatter = logging.Formatter(log_format, log_date_format)

        formatter._style = PercentStyleMultiline(
            formatter._style._fmt, auto_indent=auto_indent
        )

        return formatter

    def set_log_path(self, fname: str) -> None:
        """Public method, which can set filename parameter for
        Logging.FileHandler(). Also creates parent directory if
        it does not exist.

        .. warning::
            Please considered as an experimental API.
        """
        fpath = Path(fname)

        if not fpath.is_absolute():
            fpath = Path(str(self._config.rootdir), fpath)

        if not fpath.parent.exists():
            fpath.parent.mkdir(exist_ok=True, parents=True)

        stream = fpath.open(mode="w", encoding="UTF-8")
        if sys.version_info >= (3, 7):
            old_stream = self.log_file_handler.setStream(stream)
        else:
            old_stream = self.log_file_handler.stream
            self.log_file_handler.acquire()
            try:
                self.log_file_handler.flush()
                self.log_file_handler.stream = stream
            finally:
                self.log_file_handler.release()
        if old_stream:
            old_stream.close()

    def _log_cli_enabled(self):
        """Return whether live logging is enabled."""
        enabled = self._config.getoption(
            "--log-cli-level"
        ) is not None or self._config.getini("log_cli")
        if not enabled:
            return False

        terminal_reporter = self._config.pluginmanager.get_plugin("terminalreporter")
        if terminal_reporter is None:
            # terminal reporter is disabled e.g. by pytest-xdist.
            return False

        return True

    @pytest.hookimpl(hookwrapper=True, tryfirst=True)
    def pytest_sessionstart(self) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("sessionstart")

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield

    @pytest.hookimpl(hookwrapper=True, tryfirst=True)
    def pytest_collection(self) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("collection")

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtestloop(self, session: Session) -> Generator[None, None, None]:
        """Runs all collected test items."""

        if session.config.option.collectonly:
            yield
            return

        if self._log_cli_enabled() and self._config.getoption("verbose") < 1:
            # setting verbose flag is needed to avoid messy test progress output
            self._config.option.verbose = 1

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield  # run all the tests

    @pytest.hookimpl
    def pytest_runtest_logstart(self) -> None:
        self.log_cli_handler.reset()
        self.log_cli_handler.set_when("start")

    @pytest.hookimpl
    def pytest_runtest_logreport(self) -> None:
        self.log_cli_handler.set_when("logreport")

    def _runtest_for(self, item: nodes.Item, when: str) -> Generator[None, None, None]:
        """Implements the internals of pytest_runtest_xxx() hook."""
        with catching_logs(
            self.caplog_handler, level=self.log_level,
        ) as caplog_handler, catching_logs(
            self.report_handler, level=self.log_level,
        ) as report_handler:
            caplog_handler.reset()
            report_handler.reset()
            item._store[caplog_records_key][when] = caplog_handler.records
            item._store[caplog_handler_key] = caplog_handler

            yield

            log = report_handler.stream.getvalue().strip()
            item.add_report_section(when, "log", log)

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtest_setup(self, item: nodes.Item) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("setup")

        empty = {}  # type: Dict[str, List[logging.LogRecord]]
        item._store[caplog_records_key] = empty
        yield from self._runtest_for(item, "setup")

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtest_call(self, item: nodes.Item) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("call")

        yield from self._runtest_for(item, "call")

    @pytest.hookimpl(hookwrapper=True)
    def pytest_runtest_teardown(self, item: nodes.Item) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("teardown")

        yield from self._runtest_for(item, "teardown")
        del item._store[caplog_records_key]
        del item._store[caplog_handler_key]

    @pytest.hookimpl
    def pytest_runtest_logfinish(self) -> None:
        self.log_cli_handler.set_when("finish")

    @pytest.hookimpl(hookwrapper=True, tryfirst=True)
    def pytest_sessionfinish(self) -> Generator[None, None, None]:
        self.log_cli_handler.set_when("sessionfinish")

        with catching_logs(self.log_cli_handler, level=self.log_cli_level):
            with catching_logs(self.log_file_handler, level=self.log_file_level):
                yield

    @pytest.hookimpl
    def pytest_unconfigure(self) -> None:
        # Close the FileHandler explicitly.
        # (logging.shutdown might have lost the weakref?!)
        self.log_file_handler.close()


class _FileHandler(logging.FileHandler):
    """
    Custom FileHandler with pytest tweaks.
    """

    def handleError(self, record: logging.LogRecord) -> None:
        # Handled by LogCaptureHandler.
        pass


class _LiveLoggingStreamHandler(logging.StreamHandler):
    """
    Custom StreamHandler used by the live logging feature: it will write a newline before the first log message
    in each test.

    During live logging we must also explicitly disable stdout/stderr capturing otherwise it will get captured
    and won't appear in the terminal.
    """

    # Officially stream needs to be a IO[str], but TerminalReporter
    # isn't. So force it.
    stream = None  # type: TerminalReporter # type: ignore

    def __init__(
        self,
        terminal_reporter: TerminalReporter,
        capture_manager: Optional[CaptureManager],
    ) -> None:
        """
        :param _pytest.terminal.TerminalReporter terminal_reporter:
        :param _pytest.capture.CaptureManager capture_manager:
        """
        logging.StreamHandler.__init__(self, stream=terminal_reporter)  # type: ignore[arg-type]
        self.capture_manager = capture_manager
        self.reset()
        self.set_when(None)
        self._test_outcome_written = False

    def reset(self) -> None:
        """Reset the handler; should be called before the start of each test"""
        self._first_record_emitted = False

    def set_when(self, when: Optional[str]) -> None:
        """Prepares for the given test phase (setup/call/teardown)"""
        self._when = when
        self._section_name_shown = False
        if when == "start":
            self._test_outcome_written = False

    def emit(self, record: logging.LogRecord) -> None:
        ctx_manager = (
            self.capture_manager.global_and_fixture_disabled()
            if self.capture_manager
            else nullcontext()
        )
        with ctx_manager:
            if not self._first_record_emitted:
                self.stream.write("\n")
                self._first_record_emitted = True
            elif self._when in ("teardown", "finish"):
                if not self._test_outcome_written:
                    self._test_outcome_written = True
                    self.stream.write("\n")
            if not self._section_name_shown and self._when:
                self.stream.section("live log " + self._when, sep="-", bold=True)
                self._section_name_shown = True
            super().emit(record)

    def handleError(self, record: logging.LogRecord) -> None:
        # Handled by LogCaptureHandler.
        pass


class _LiveLoggingNullHandler(logging.NullHandler):
    """A handler used when live logging is disabled."""

    def reset(self) -> None:
        pass

    def set_when(self, when: str) -> None:
        pass

    def handleError(self, record: logging.LogRecord) -> None:
        # Handled by LogCaptureHandler.
        pass

```


# testing/logging/test_fixture.py

```
import logging

import pytest
from _pytest.logging import caplog_records_key

logger = logging.getLogger(__name__)
sublogger = logging.getLogger(__name__ + ".baz")


def test_fixture_help(testdir):
    result = testdir.runpytest("--fixtures")
    result.stdout.fnmatch_lines(["*caplog*"])


def test_change_level(caplog):
    caplog.set_level(logging.INFO)
    logger.debug("handler DEBUG level")
    logger.info("handler INFO level")

    caplog.set_level(logging.CRITICAL, logger=sublogger.name)
    sublogger.warning("logger WARNING level")
    sublogger.critical("logger CRITICAL level")

    assert "DEBUG" not in caplog.text
    assert "INFO" in caplog.text
    assert "WARNING" not in caplog.text
    assert "CRITICAL" in caplog.text


def test_change_level_undo(testdir):
    """Ensure that 'set_level' is undone after the end of the test"""
    testdir.makepyfile(
        """
        import logging

        def test1(caplog):
            caplog.set_level(logging.INFO)
            # using + operator here so fnmatch_lines doesn't match the code in the traceback
            logging.info('log from ' + 'test1')
            assert 0

        def test2(caplog):
            # using + operator here so fnmatch_lines doesn't match the code in the traceback
            logging.info('log from ' + 'test2')
            assert 0
    """
    )
    result = testdir.runpytest()
    result.stdout.fnmatch_lines(["*log from test1*", "*2 failed in *"])
    result.stdout.no_fnmatch_line("*log from test2*")


def test_change_level_undo_handler(testdir):
    """Ensure that the caplog handler level set by 'set_level' is undone
    after the end of the test."""
    testdir.makepyfile(
        """
        import logging

        def test1(caplog):
            caplog.set_level(logging.INFO)
            assert caplog.handler.level == logging.INFO

        def test2(caplog):
            assert caplog.handler.level == logging.NOTSET
    """
    )
    result = testdir.runpytest()
    result.stdout.fnmatch_lines(["*2 passed in *"])


def test_with_statement(caplog):
    with caplog.at_level(logging.INFO):
        logger.debug("handler DEBUG level")
        logger.info("handler INFO level")

        with caplog.at_level(logging.CRITICAL, logger=sublogger.name):
            sublogger.warning("logger WARNING level")
            sublogger.critical("logger CRITICAL level")

    assert "DEBUG" not in caplog.text
    assert "INFO" in caplog.text
    assert "WARNING" not in caplog.text
    assert "CRITICAL" in caplog.text


def test_log_access(caplog):
    caplog.set_level(logging.INFO)
    logger.info("boo %s", "arg")
    assert caplog.records[0].levelname == "INFO"
    assert caplog.records[0].msg == "boo %s"
    assert "boo arg" in caplog.text


def test_messages(caplog):
    caplog.set_level(logging.INFO)
    logger.info("boo %s", "arg")
    logger.info("bar %s\nbaz %s", "arg1", "arg2")
    assert "boo arg" == caplog.messages[0]
    assert "bar arg1\nbaz arg2" == caplog.messages[1]
    assert caplog.text.count("\n") > len(caplog.messages)
    assert len(caplog.text.splitlines()) > len(caplog.messages)

    try:
        raise Exception("test")
    except Exception:
        logger.exception("oops")

    assert "oops" in caplog.text
    assert "oops" in caplog.messages[-1]
    # Tracebacks are stored in the record and not added until the formatter or handler.
    assert "Exception" in caplog.text
    assert "Exception" not in caplog.messages[-1]


def test_record_tuples(caplog):
    caplog.set_level(logging.INFO)
    logger.info("boo %s", "arg")

    assert caplog.record_tuples == [(__name__, logging.INFO, "boo arg")]


def test_unicode(caplog):
    caplog.set_level(logging.INFO)
    logger.info("bū")
    assert caplog.records[0].levelname == "INFO"
    assert caplog.records[0].msg == "bū"
    assert "bū" in caplog.text


def test_clear(caplog):
    caplog.set_level(logging.INFO)
    logger.info("bū")
    assert len(caplog.records)
    assert caplog.text
    caplog.clear()
    assert not len(caplog.records)
    assert not caplog.text


@pytest.fixture
def logging_during_setup_and_teardown(caplog):
    caplog.set_level("INFO")
    logger.info("a_setup_log")
    yield
    logger.info("a_teardown_log")
    assert [x.message for x in caplog.get_records("teardown")] == ["a_teardown_log"]


def test_caplog_captures_for_all_stages(caplog, logging_during_setup_and_teardown):
    assert not caplog.records
    assert not caplog.get_records("call")
    logger.info("a_call_log")
    assert [x.message for x in caplog.get_records("call")] == ["a_call_log"]

    assert [x.message for x in caplog.get_records("setup")] == ["a_setup_log"]

    # This reaches into private API, don't use this type of thing in real tests!
    assert set(caplog._item._store[caplog_records_key]) == {"setup", "call"}


def test_ini_controls_global_log_level(testdir):
    testdir.makepyfile(
        """
        import pytest
        import logging
        def test_log_level_override(request, caplog):
            plugin = request.config.pluginmanager.getplugin('logging-plugin')
            assert plugin.log_level == logging.ERROR
            logger = logging.getLogger('catchlog')
            logger.warning("WARNING message won't be shown")
            logger.error("ERROR message will be shown")
            assert 'WARNING' not in caplog.text
            assert 'ERROR' in caplog.text
    """
    )
    testdir.makeini(
        """
        [pytest]
        log_level=ERROR
    """
    )

    result = testdir.runpytest()
    # make sure that that we get a '0' exit code for the testsuite
    assert result.ret == 0


def test_caplog_can_override_global_log_level(testdir):
    testdir.makepyfile(
        """
        import pytest
        import logging
        def test_log_level_override(request, caplog):
            logger = logging.getLogger('catchlog')
            plugin = request.config.pluginmanager.getplugin('logging-plugin')
            assert plugin.log_level == logging.WARNING

            logger.info("INFO message won't be shown")

            caplog.set_level(logging.INFO, logger.name)

            with caplog.at_level(logging.DEBUG, logger.name):
                logger.debug("DEBUG message will be shown")

            logger.debug("DEBUG message won't be shown")

            with caplog.at_level(logging.CRITICAL, logger.name):
                logger.warning("WARNING message won't be shown")

            logger.debug("DEBUG message won't be shown")
            logger.info("INFO message will be shown")

            assert "message won't be shown" not in caplog.text
    """
    )
    testdir.makeini(
        """
        [pytest]
        log_level=WARNING
    """
    )

    result = testdir.runpytest()
    assert result.ret == 0


def test_caplog_captures_despite_exception(testdir):
    testdir.makepyfile(
        """
        import pytest
        import logging
        def test_log_level_override(request, caplog):
            logger = logging.getLogger('catchlog')
            plugin = request.config.pluginmanager.getplugin('logging-plugin')
            assert plugin.log_level == logging.WARNING

            logger.error("ERROR message " + "will be shown")

            with caplog.at_level(logging.DEBUG, logger.name):
                logger.debug("DEBUG message " + "won't be shown")
                raise Exception()
    """
    )
    testdir.makeini(
        """
        [pytest]
        log_level=WARNING
    """
    )

    result = testdir.runpytest()
    result.stdout.fnmatch_lines(["*ERROR message will be shown*"])
    result.stdout.no_fnmatch_line("*DEBUG message won't be shown*")
    assert result.ret == 1


def test_log_report_captures_according_to_config_option_upon_failure(testdir):
    """ Test that upon failure:
    (1) `caplog` succeeded to capture the DEBUG message and assert on it => No `Exception` is raised
    (2) The `DEBUG` message does NOT appear in the `Captured log call` report
    (3) The stdout, `INFO`, and `WARNING` messages DO appear in the test reports due to `--log-level=INFO`
    """
    testdir.makepyfile(
        """
        import pytest
        import logging

        def function_that_logs():
            logging.debug('DEBUG log ' + 'message')
            logging.info('INFO log ' + 'message')
            logging.warning('WARNING log ' + 'message')
            print('Print ' + 'message')

        def test_that_fails(request, caplog):
            plugin = request.config.pluginmanager.getplugin('logging-plugin')
            assert plugin.log_level == logging.INFO

            with caplog.at_level(logging.DEBUG):
                function_that_logs()

            if 'DEBUG log ' + 'message' not in caplog.text:
                raise Exception('caplog failed to ' + 'capture DEBUG')

            assert False
    """
    )

    result = testdir.runpytest("--log-level=INFO")
    result.stdout.no_fnmatch_line("*Exception: caplog failed to capture DEBUG*")
    result.stdout.no_fnmatch_line("*DEBUG log message*")
    result.stdout.fnmatch_lines(
        ["*Print message*", "*INFO log message*", "*WARNING log message*"]
    )
    assert result.ret == 1

```


# The last commit

```
016f0edea SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest testing/logging/test_fixture.py -q
...............                                                          [100%]
15 passed in 0.30s
scope: src/_pytest/logging.py testing/logging/test_fixture.py
changed: src/_pytest/logging.py +5 -0
changed: testing/logging/test_fixture.py +19 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/src/_pytest/logging.py b/src/_pytest/logging.py
index 11031f2f2..3c56f8c37 100644
--- a/src/_pytest/logging.py
+++ b/src/_pytest/logging.py
@@ -346,6 +346,7 @@ class LogCaptureFixture:
         self._item = item
         # dict of log name -> log level
         self._initial_logger_levels = {}  # type: Dict[Optional[str], int]
+        self._initial_handler_level = None  # type: Optional[int]
 
     def _finalize(self) -> None:
         """Finalizes the fixture.
@@ -356,6 +357,8 @@ class LogCaptureFixture:
         for logger_name, level in self._initial_logger_levels.items():
             logger = logging.getLogger(logger_name)
             logger.setLevel(level)
+        if self._initial_handler_level is not None:
+            self.handler.setLevel(self._initial_handler_level)
 
     @property
     def handler(self) -> LogCaptureHandler:
@@ -433,6 +436,8 @@ class LogCaptureFixture:
         logger_obj = logging.getLogger(logger)
         # save the original log-level to restore it during teardown
         self._initial_logger_levels.setdefault(logger, logger_obj.level)
+        if self._initial_handler_level is None:
+            self._initial_handler_level = self.handler.level
         logger_obj.setLevel(level)
         self.handler.setLevel(level)
 
diff --git a/testing/logging/test_fixture.py b/testing/logging/test_fixture.py
index da5303302..61aed2733 100644
--- a/testing/logging/test_fixture.py
+++ b/testing/logging/test_fixture.py
@@ -50,6 +50,25 @@ def test_change_level_undo(testdir):
     result.stdout.no_fnmatch_line("*log from test2*")
 
 
+def test_change_level_undo_handler(testdir):
+    """Ensure that the caplog handler level set by 'set_level' is undone
+    after the end of the test."""
+    testdir.makepyfile(
+        """
+        import logging
+
+        def test1(caplog):
+            caplog.set_level(logging.INFO)
+            assert caplog.handler.level == logging.INFO
+
+        def test2(caplog):
+            assert caplog.handler.level == logging.NOTSET
+    """
+    )
+    result = testdir.runpytest()
+    result.stdout.fnmatch_lines(["*2 passed in *"])
+
+
 def test_with_statement(caplog):
     with caplog.at_level(logging.INFO):
         logger.debug("handler DEBUG level")
```

### `done.sh`

```
#!/usr/bin/env bash
# done.sh <step> <run dir>: whether an agent step did its part, the step's
# target. Exit 0 when it did; otherwise exit 1 and say what is missing. The
# problem step copies it into the run's folder; a task cannot edit its own
# target (gateway/target_guard.go).
set -u
step="$1"; r="$2"; miss=0
w=.memdoor/workflows/team-solve; [ -d "$w" ] || w="$HOME/.memdoor/workflows/team-solve"
no() { printf 'not done: %s\n' "$1"; miss=1; }
# section <file> <heading>: the lines under "## <heading>", comments and blanks dropped.
section() { sed -n "/^## $2\$/,/^## /p" "$1" | sed '1d;/^## /d;/^<!--.*-->$/d;/^[[:space:]]*$/d'; }
verdict() { [ -s "$1" ] && head -1 "$1" | grep -qE '^verdict: (PASS|FAIL)$'; }

case "$step" in
plan)
  t="$r/task.md"
  for s in Deliverable Check Scope "Done when"; do
    [ -n "$(section "$t" "$s")" ] || no "task.md: the $s section is not filled in"
  done
  { section "$t" Check | grep -q '`[^`]*`' || section "$t" Check | grep -qwE 'samples|judge'; } \
    || no 'task.md: Check names no command in backticks, nor samples, nor judge'
  section "$t" Scope | grep -q '`[^`]*`' || no 'task.md: Scope names no file or directory in backticks'
  first=$(grep -m1 '[^[:space:]]' "$r/prompt.md")
  grep -qF -- "$first" "$t" || no 'task.md: the Prompt section was changed; put it back as prompt.md has it'
  grep -q '[^[:space:]]' "$r/plan.md" 2>/dev/null || no 'plan.md is missing or empty'
  [ -f "$r/notes.md" ] || no 'notes.md is missing' ;;
solve)
  bash "$w/changes.sh" "$r" > /dev/null
  [ -s "$r/changes.diff" ] || no 'nothing in the project changed yet: do the task as the Deliverable says' ;;
review)
  verdict "$r/review.md" || no 'review.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
repair)
  head -1 "$r/review.md" 2>/dev/null | grep -qx 'verdict: PASS' && exit 0
  grep -q '[^[:space:]]' "$r/repair.md" 2>/dev/null || no 'repair.md is missing: what you changed and what the Check printed' ;;
judge)
  verdict "$r/verdict.md" || no 'verdict.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
*) echo "done.sh: unknown step $step"; exit 2 ;;
esac
[ "$miss" = 0 ] && printf '%s: done\n' "$step"
exit "$miss"
```

### `final-check.log`

```
check: python -m pytest testing/logging/test_fixture.py -q
...............                                                          [100%]
15 passed in 0.47s
scope: src/_pytest/logging.py testing/logging/test_fixture.py
changed: src/_pytest/logging.py +5 -0
changed: testing/logging/test_fixture.py +19 -0
```

### `final-status.txt`

```
0
```

### `head.txt`

```
main
```

### `keep.txt`

```
kept: the direct attempt, untouched
```

### `notes.md`

```
# Notes, run 2026-11-06T132404

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

caplog fixture doesn't restore log level after test
From the documentation at https://docs.pytest.org/en/6.0.0/logging.html#caplog-fixture, "The log levels set are restored automatically at the end of the test".
It used to work, but looks broken in new 6.0 release. Minimal example to reproduce:

```
def test_foo(caplog):
    caplog.set_level(42)

def test_bar(caplog):
    print(caplog.handler.level)
```

It prints "0" for pytest<6, "42" after.


# The files of the project

```
.coveragerc
.gitattributes
.gitblameignore
.github/FUNDING.yml
.github/ISSUE_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE.md
.github/config.yml
.github/labels.toml
.github/workflows/main.yml
.github/workflows/release-on-comment.yml
.gitignore
.pre-commit-config.yaml
.travis.yml
AUTHORS
CHANGELOG.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.rst
LICENSE
OPENCOLLECTIVE.rst
README.rst
RELEASING.rst
TIDELIFT.rst
bench/bench.py
bench/bench_argcomplete.py
bench/empty.py
bench/manyparam.py
bench/skip.py
changelog/5584.breaking.rst
changelog/7389.trivial.rst
changelog/7392.bugfix.rst
changelog/7394.bugfix.rst
changelog/7422.doc.rst
changelog/7441.doc.rst
changelog/7464.feature.rst
changelog/7467.improvement.rst
changelog/7472.breaking.rst
changelog/7489.improvement.rst
changelog/7491.bugfix.rst
changelog/7517.bugfix.rst
changelog/7534.bugfix.rst
changelog/7536.trivial.rst
changelog/7558.bugfix.rst
changelog/README.rst
changelog/_template.rst
codecov.yml
doc/en/Makefile
doc/en/_templates/globaltoc.html
doc/en/_templates/layout.html
doc/en/_templates/links.html
doc/en/_templates/relations.html
doc/en/_templates/sidebarintro.html
doc/en/_templates/slim_searchbox.html
doc/en/adopt.rst
doc/en/announce/index.rst
doc/en/announce/release-2.0.0.rst
doc/en/announce/release-2.0.1.rst
doc/en/announce/release-2.0.2.rst
doc/en/announce/release-2.0.3.rst
doc/en/announce/release-2.1.0.rst
doc/en/announce/release-2.1.1.rst
doc/en/announce/release-2.1.2.rst
doc/en/announce/release-2.1.3.rst
doc/en/announce/release-2.2.0.rst
doc/en/announce/release-2.2.1.rst
doc/en/announce/release-2.2.2.rst
doc/en/announce/release-2.2.4.rst
doc/en/announce/release-2.3.0.rst
doc/en/announce/release-2.3.1.rst
doc/en/announce/release-2.3.2.rst
doc/en/announce/release-2.3.3.rst
doc/en/announce/release-2.3.4.rst
doc/en/announce/release-2.3.5.rst
doc/en/announce/release-2.4.0.rst
doc/en/announce/release-2.4.1.rst
doc/en/announce/release-2.4.2.rst
doc/en/announce/release-2.5.0.rst
doc/en/announce/release-2.5.1.rst
doc/en/announce/release-2.5.2.rst
doc/en/announce/release-2.6.0.rst
doc/en/announce/release-2.6.1.rst
doc/en/announce/release-2.6.2.rst
doc/en/announce/release-2.6.3.rst
doc/en/announce/release-2.7.0.rst
doc/en/announce/release-2.7.1.rst
doc/en/announce/release-2.7.2.rst
doc/en/announce/release-2.8.2.rst
doc/en/announce/release-2.8.3.rst
doc/en/announce/release-2.8.4.rst
doc/en/announce/release-2.8.5.rst
doc/en/announce/release-2.8.6.rst
doc/en/announce/release-2.8.7.rst
doc/en/announce/release-2.9.0.rst
doc/en/announce/release-2.9.1.rst
doc/en/announce/release-2.9.2.rst
doc/en/announce/release-3.0.0.rst
doc/en/announce/release-3.0.1.rst
doc/en/announce/release-3.0.2.rst
doc/en/announce/release-3.0.3.rst
doc/en/announce/release-3.0.4.rst
doc/en/announce/release-3.0.5.rst
doc/en/announce/release-3.0.6.rst
doc/en/announce/release-3.0.7.rst
doc/en/announce/release-3.1.0.rst
doc/en/announce/release-3.1.1.rst
doc/en/announce/release-3.1.2.rst
doc/en/announce/release-3.1.3.rst
doc/en/announce/release-3.10.0.rst
doc/en/announce/release-3.10.1.rst
doc/en/announce/release-3.2.0.rst
doc/en/announce/release-3.2.1.rst
doc/en/announce/release-3.2.2.rst
doc/en/announce/release-3.2.3.rst
doc/en/announce/release-3.2.4.rst
doc/en/announce/release-3.2.5.rst
doc/en/announce/release-3.3.0.rst
doc/en/announce/release-3.3.1.rst
doc/en/announce/release-3.3.2.rst
doc/en/announce/release-3.4.0.rst
doc/en/announce/release-3.4.1.rst
doc/en/announce/release-3.4.2.rst
doc/en/announce/release-3.5.0.rst
doc/en/announce/release-3.5.1.rst
doc/en/announce/release-3.6.0.rst
doc/en/announce/release-3.6.1.rst
doc/en/announce/release-3.6.2.rst
doc/en/announce/release-3.6.3.rst
doc/en/announce/release-3.6.4.rst
doc/en/announce/release-3.7.0.rst
doc/en/announce/release-3.7.1.rst
doc/en/announce/release-3.7.2.rst
doc/en/announce/release-3.7.3.rst
doc/en/announce/release-3.7.4.rst
doc/en/announce/release-3.8.0.rst
doc/en/announce/release-3.8.1.rst
doc/en/announce/release-3.8.2.rst
doc/en/announce/release-3.9.0.rst
doc/en/announce/release-3.9.1.rst
doc/en/announce/release-3.9.2.rst
doc/en/announce/release-3.9.3.rst
doc/en/announce/release-4.0.0.rst
doc/en/announce/release-4.0.1.rst
doc/en/announce/release-4.0.2.rst
doc/en/announce/release-4.1.0.rst
doc/en/announce/release-4.1.1.rst
doc/en/announce/release-4.2.0.rst
doc/en/announce/release-4.2.1.rst
doc/en/announce/release-4.3.0.rst
doc/en/announce/release-4.3.1.rst
doc/en/announce/release-4.4.0.rst
doc/en/announce/release-4.4.1.rst
doc/en/announce/release-4.4.2.rst
doc/en/announce/release-4.5.0.rst
doc/en/announce/release-4.6.0.rst
doc/en/announce/release-4.6.1.rst
doc/en/announce/release-4.6.2.rst
doc/en/announce/release-4.6.3.rst
doc/en/announce/release-4.6.4.rst
doc/en/announce/release-4.6.5.rst
doc/en/announce/release-4.6.6.rst
doc/en/announce/release-4.6.7.rst
doc/en/announce/release-4.6.8.rst
doc/en/announce/release-4.6.9.rst
doc/en/announce/release-5.0.0.rst
doc/en/announce/release-5.0.1.rst
doc/en/announce/release-5.1.0.rst
doc/en/announce/release-5.1.1.rst
doc/en/announce/release-5.1.2.rst
doc/en/announce/release-5.1.3.rst
doc/en/announce/release-5.2.0.rst
doc/en/announce/release-5.2.1.rst
doc/en/announce/release-5.2.2.rst
doc/en/announce/release-5.2.3.rst
doc/en/announce/release-5.2.4.rst
doc/en/announce/release-5.3.0.rst
doc/en/announce/release-5.3.1.rst
doc/en/announce/release-5.3.2.rst
doc/en/announce/release-5.3.3.rst
doc/en/announce/release-5.3.4.rst
doc/en/announce/release-5.3.5.rst
doc/en/announce/release-5.4.0.rst
doc/en/announce/release-5.4.1.rst
doc/en/announce/release-5.4.2.rst
doc/en/announce/release-5.4.3.rst
doc/en/announce/release-6.0.0.rst
doc/en/announce/release-6.0.0rc1.rst
doc/en/announce/sprint2016.rst
doc/en/assert.rst
doc/en/backwards-compatibility.rst
doc/en/bash-completion.rst
doc/en/builtin.rst
doc/en/cache.rst
doc/en/capture.rst
doc/en/changelog.rst
doc/en/conf.py
doc/en/conftest.py
doc/en/contact.rst
doc/en/contents.rst
doc/en/contributing.rst
doc/en/customize.rst
doc/en/deprecations.rst
doc/en/development_guide.rst
doc/en/doctest.rst
doc/en/example/assertion/failure_demo.py
doc/en/example/assertion/global_testmodule_config/conftest.py
doc/en/example/assertion/global_testmodule_config/test_hello_world.py
doc/en/example/assertion/test_failures.py
doc/en/example/assertion/test_setup_flow_example.py
doc/en/example/attic.rst
doc/en/example/conftest.py
doc/en/example/fixtures/test_fixtures_order.py
doc/en/example/index.rst
doc/en/example/markers.rst
doc/en/example/multipython.py
doc/en/example/nonpython.rst
doc/en/example/nonpython/__init__.py
doc/en/example/nonpython/conftest.py
doc/en/example/nonpython/test_simple.yaml
doc/en/example/parametrize.rst
doc/en/example/pythoncollection.py
doc/en/example/pythoncollection.rst
doc/en/example/reportingdemo.rst
doc/en/example/simple.rst
doc/en/example/special.rst
doc/en/example/xfail_demo.py
doc/en/existingtestsuite.rst
doc/en/faq.rst
doc/en/fixture.rst
doc/en/flaky.rst
doc/en/funcarg_compare.rst
doc/en/funcargs.rst
doc/en/getting-started.rst
doc/en/goodpractices.rst
doc/en/historical-notes.rst
doc/en/img/cramer2.png
doc/en/img/favicon.png
doc/en/img/freiburg2.jpg
doc/en/img/gaynor3.png
doc/en/img/keleshev.png
doc/en/img/pullrequest.png
doc/en/img/pylib.png
doc/en/img/pytest1.png
doc/en/img/theuni.png
doc/en/index.rst
doc/en/license.rst
doc/en/logging.rst
doc/en/mark.rst
doc/en/monkeypatch.rst
doc/en/naming20.rst
doc/en/nose.rst
doc/en/parametrize.rst
doc/en/plugins.rst
doc/en/projects.rst
doc/en/proposals/parametrize_with_fixtures.rst
doc/en/py27-py34-deprecation.rst
doc/en/pytest.ini
doc/en/pythonpath.rst
doc/en/recwarn.rst
doc/en/reference.rst
doc/en/requirements.txt
doc/en/skipping.rst
doc/en/sponsor.rst
doc/en/talks.rst
doc/en/tidelift.rst
doc/en/tmpdir.rst
doc/en/unittest.rst
doc/en/usage.rst
doc/en/warnings.rst
doc/en/writing_plugins.rst
doc/en/xunit_setup.rst
doc/en/yieldfixture.rst
extra/get_issues.py
extra/setup-py.test/setup.py
pyproject.toml
scripts/append_codecov_token.py
scripts/publish-gh-release-notes.py
scripts/release-on-comment.py
scripts/release.minor.rst
scripts/release.patch.rst
scripts/release.py
scripts/report-coverage.sh
scripts/towncrier-draft-to-file.py
setup.cfg
setup.py
src/_pytest/__init__.py
src/_pytest/_argcomplete.py
src/_pytest/_code/__init__.py
src/_pytest/_code/code.py
src/_pytest/_code/source.py
src/_pytest/_io/__init__.py
src/_pytest/_io/saferepr.py
src/_pytest/_io/terminalwriter.py
src/_pytest/_io/wcwidth.py
src/_pytest/assertion/__init__.py
src/_pytest/assertion/rewrite.py
src/_pytest/assertion/truncate.py
src/_pytest/assertion/util.py
src/_pytest/cacheprovider.py
src/_pytest/capture.py
src/_pytest/compat.py
src/_pytest/config/__init__.py
src/_pytest/config/argparsing.py
src/_pytest/config/exceptions.py
src/_pytest/config/findpaths.py
src/_pytest/debugging.py
src/_pytest/deprecated.py
src/_pytest/doctest.py
src/_pytest/faulthandler.py
src/_pytest/fixtures.py
src/_pytest/freeze_support.py
src/_pytest/helpconfig.py
src/_pytest/hookspec.py
src/_pytest/junitxml.py
src/_pytest/logging.py
src/_pytest/main.py
src/_pytest/mark/__init__.py
src/_pytest/mark/expression.py
src/_pytest/mark/structures.py
src/_pytest/monkeypatch.py
src/_pytest/nodes.py
src/_pytest/nose.py
src/_pytest/outcomes.py
src/_pytest/pastebin.py
src/_pytest/pathlib.py
src/_pytest/py.typed
src/_pytest/pytester.py
src/_pytest/python.py
src/_pytest/python_api.py
src/_pytest/recwarn.py
src/_pytest/reports.py
src/_pytest/resultlog.py
src/_pytest/runner.py
src/_pytest/setuponly.py
src/_pytest/setupplan.py
src/_pytest/skipping.py
src/_pytest/stepwise.py
src/_pytest/store.py
src/_pytest/terminal.py
src/_pytest/timing.py
src/_pytest/tmpdir.py
src/_pytest/unittest.py
src/_pytest/warning_types.py
src/_pytest/warnings.py
src/pytest/__init__.py
src/pytest/__main__.py
src/pytest/collect.py
src/pytest/py.typed
testing/acceptance_test.py
testing/code/test_code.py
testing/code/test_excinfo.py
testing/code/test_source.py
testing/conftest.py
testing/deprecated_test.py
testing/example_scripts/README.rst
testing/example_scripts/acceptance/fixture_mock_integration.py
testing/example_scripts/collect/collect_init_tests/pytest.ini
testing/example_scripts/collect/collect_init_tests/tests/__init__.py
testing/example_scripts/collect/collect_init_tests/tests/test_foo.py
testing/example_scripts/collect/package_infinite_recursion/__init__.pyi
testing/example_scripts/collect/package_infinite_recursion/conftest.py
testing/example_scripts/collect/package_infinite_recursion/tests/__init__.py
testing/example_scripts/collect/package_infinite_recursion/tests/test_basic.py
testing/example_scripts/collect/package_init_given_as_arg/pkg/__init__.py
testing/example_scripts/collect/package_init_given_as_arg/pkg/test_foo.py
testing/example_scripts/config/collect_pytest_prefix/__init__.pyi
testing/example_scripts/config/collect_pytest_prefix/conftest.py
testing/example_scripts/config/collect_pytest_prefix/test_foo.py
testing/example_scripts/conftest_usageerror/__init__.pyi
testing/example_scripts/conftest_usageerror/conftest.py
testing/example_scripts/dataclasses/test_compare_dataclasses.py
testing/example_scripts/dataclasses/test_compare_dataclasses_field_comparison_off.py
testing/example_scripts/dataclasses/test_compare_dataclasses_verbose.py
testing/example_scripts/dataclasses/test_compare_recursive_dataclasses.py
testing/example_scripts/dataclasses/test_compare_two_different_dataclasses.py
testing/example_scripts/fixtures/custom_item/__init__.pyi
testing/example_scripts/fixtures/custom_item/conftest.py
testing/example_scripts/fixtures/custom_item/foo/__init__.py
testing/example_scripts/fixtures/custom_item/foo/test_foo.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub1/__init__.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub1/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub1/test_in_sub1.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub2/__init__.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub2/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub2/test_in_sub2.py
testing/example_scripts/fixtures/fill_fixtures/test_detect_recursive_dependency_error.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/__init__.pyi
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/pkg/__init__.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/pkg/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/pkg/test_spam.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_module/__init__.pyi
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_module/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_module/test_extend_fixture_conftest_module.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_module_class.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_basic.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_lookup_classlevel.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_lookup_modulelevel.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_lookupfails.py
testing/example_scripts/fixtures/test_fixture_named_request.py
testing/example_scripts/fixtures/test_getfixturevalue_dynamic.py
testing/example_scripts/issue88_initial_file_multinodes/__init__.pyi
testing/example_scripts/issue88_initial_file_multinodes/conftest.py
testing/example_scripts/issue88_initial_file_multinodes/test_hello.py
testing/example_scripts/issue_519.py
testing/example_scripts/junit-10.xsd
testing/example_scripts/marks/marks_considered_keywords/__init__.pyi
testing/example_scripts/marks/marks_considered_keywords/conftest.py
testing/example_scripts/marks/marks_considered_keywords/test_marks_as_keywords.py
testing/example_scripts/perf_examples/collect_stats/.gitignore
testing/example_scripts/perf_examples/collect_stats/generate_folders.py
testing/example_scripts/perf_examples/collect_stats/template_test.py
testing/example_scripts/pytest.ini
testing/example_scripts/tmpdir/tmpdir_fixture.py
testing/example_scripts/unittest/test_parametrized_fixture_error_message.py
testing/example_scripts/unittest/test_setup_skip.py
testing/example_scripts/unittest/test_setup_skip_class.py
testing/example_scripts/unittest/test_setup_skip_module.py
testing/example_scripts/unittest/test_unittest_asyncio.py
testing/example_scripts/unittest/test_unittest_asynctest.py
testing/example_scripts/warnings/test_group_warnings_by_message.py
testing/example_scripts/warnings/test_group_warnings_by_message_summary/test_1.py
testing/example_scripts/warnings/test_group_warnings_by_message_summary/test_2.py
testing/examples/test_issue519.py
testing/freeze/.gitignore
testing/freeze/create_executable.py
testing/freeze/runtests_script.py
testing/freeze/tests/test_doctest.txt
testing/freeze/tests/test_trivial.py
testing/freeze/tox_run.py
testing/io/test_saferepr.py
testing/io/test_terminalwriter.py
testing/io/test_wcwidth.py
testing/logging/test_fixture.py
testing/logging/test_formatter.py
testing/logging/test_reporting.py
testing/python/approx.py
testing/python/collect.py
testing/python/fixtures.py
testing/python/integration.py
testing/python/metafunc.py
testing/python/raises.py
testing/python/show_fixtures_per_test.py
testing/test_argcomplete.py
testing/test_assertion.py
testing/test_assertrewrite.py
testing/test_cacheprovider.py
testing/test_capture.py
testing/test_collection.py
testing/test_compat.py
testing/test_config.py
testing/test_conftest.py
testing/test_debugging.py
testing/test_doctest.py
testing/test_entry_points.py
testing/test_error_diffs.py
testing/test_faulthandler.py
testing/test_findpaths.py
testing/test_helpconfig.py
testing/test_junitxml.py
testing/test_link_resolve.py
testing/test_main.py
testing/test_mark.py
testing/test_mark_expression.py
testing/test_meta.py
testing/test_monkeypatch.py
testing/test_nodes.py
testing/test_nose.py
testing/test_parseopt.py
testing/test_pastebin.py
testing/test_pathlib.py
testing/test_pluginmanager.py
testing/test_pytester.py
testing/test_recwarn.py
testing/test_reports.py
testing/test_resultlog.py
testing/test_runner.py
testing/test_runner_xunit.py
testing/test_session.py
testing/test_setuponly.py
testing/test_setupplan.py
testing/test_skipping.py
testing/test_stepwise.py
testing/test_store.py
testing/test_terminal.py
testing/test_tmpdir.py
testing/test_unittest.py
testing/test_warning_types.py
testing/test_warnings.py
testing/typing_checks.py
tox.ini
```


# The last commit

```
016f0edea SWE-bench


```

```diff

```


# pyproject.toml (the start)

```
[build-system]
requires = [
  # sync with setup.py until we discard non-pep-517/518
  "setuptools>=40.0",
  "setuptools-scm",
  "wheel",
]
build-backend = "setuptools.build_meta"

[tool.pytest.ini_options]
minversion = "2.0"
addopts = "-rfEX -p pytester --strict-markers"
python_files = ["test_*.py", "*_test.py", "testing/*/*.py"]
python_classes = ["Test", "Acceptance"]
python_functions = ["test"]
# NOTE: "doc" is not included here, but gets tested explicitly via "doctesting".
testpaths = ["testing"]
norecursedirs = ["testing/example_scripts"]
xfail_strict = true
filterwarnings = [
    "error",
    "default:Using or importing the ABCs:DeprecationWarning:unittest2.*",
    "default:the imp module is deprecated in favour of importlib:DeprecationWarning:nose.*",
    "ignore:Module already imported so cannot be rewritten:pytest.PytestWarning",
    # produced by python3.6/site.py itself (3.6.7 on Travis, could not trigger it with 3.6.8)."
    "ignore:.*U.*mode is deprecated:DeprecationWarning:(?!(pytest|_pytest))",
    # produced by pytest-xdist
    "ignore:.*type argument to addoption.*:DeprecationWarning",
    # produced by python >=3.5 on execnet (pytest-xdist)
    "ignore:.*inspect.getargspec.*deprecated, use inspect.signature.*:DeprecationWarning",
    # pytest's own futurewarnings
    "ignore::pytest.PytestExperimentalApiWarning",
    # Do not cause SyntaxError for invalid escape sequences in py37.
    # Those are caught/handled by pyupgrade, and not easy to filter with the
    # module being the filename (with .py removed).
    "default:invalid escape sequence:DeprecationWarning",
    # ignore use of unregistered marks, because we use many to test the implementation
    "ignore::_pytest.warning_types.PytestUnknownMarkWarning",
]
pytester_example_dir = "testing/example_scripts"
markers = [
    # dummy markers for testing
    "foo",
    "bar",
    "baz",
    # conftest.py reorders tests moving slow ones to the end of the list
    "slow",
    # experimental mark for all tests using pexpect
    "uses_pexpect",
]


[tool.towncrier]
package = "pytest"
package_dir = "src"
filename = "doc/en/changelog.rst"
directory = "changelog/"
title_format = "pytest {version} ({project_date})"
template = "changelog/_template.rst"

  [[tool.towncrier.type]]
  directory = "breaking"
  name = "Breaking Changes"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "deprecation"
  name = "Deprecations"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "feature"
  name = "Features"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "improvement"
  name = "Improvements"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "bugfix"
  name = "Bug Fixes"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "vendor"
  name = "Vendored Libraries"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "doc"
  name = "Improved Documentation"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "trivial"
  name = "Trivial/Internal Changes"
  showcontent = true

[tool.black]
target-version = ['py35']

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest testing/logging/test_fixture.py -q`

## Scope
`src/_pytest/logging.py`
`testing/logging/test_fixture.py`

## Done when
`caplog.set_level(42)` in one test no longer leaves `caplog.handler.level` at 42 in the next test; the handler level is restored automatically at the end of the test.
A logger level changed by `caplog.set_level(..., logger=...)` is restored at the end of the test.
The minimal two-test reproduction from the prompt passes with the old/default level visible in the later test.
Existing `caplog` fixture tests continue to pass.

## Approach
Decompose into: add or identify a regression test in `testing/logging/test_fixture.py` covering both the handler-level leak from the minimal example and logger-level restoration; inspect `LogCaptureFixture.set_level` and `_finalize` in `src/_pytest/logging.py`; ensure original levels are captured before mutation and restored exactly once at finalization.

Candidate approaches:
1. Minimal fixture-local fix: in `LogCaptureFixture.set_level`, record the original handler level before the first `handler.setLevel(level)` call, and record each logger’s original level before its `setLevel(level)` call. In `_finalize`, restore the stored handler level and logger levels. This matches the documented behavior and is the least invasive.
2. Plugin lifecycle fix: capture/restore the handler level in the logging plugin’s per-phase context manager instead of relying only on the fixture finalizer. This may be more robust if the handler is recreated per phase, but risks restoring during teardown while logging should still be captured.
3. Avoid reusing the handler across tests/phases if the handler is shared unintentionally, restoring only logger levels separately. This fixes the observed leak but changes handler identity and may break code that keeps a reference to `caplog.handler`.

Prefer approach 1 unless inspection shows the handler is shared across test phases, in which case combine 1 with the phase-aware restoration from 2.
```

### `prompt.md`

````
caplog fixture doesn't restore log level after test
From the documentation at https://docs.pytest.org/en/6.0.0/logging.html#caplog-fixture, "The log levels set are restored automatically at the end of the test".
It used to work, but looks broken in new 6.0 release. Minimal example to reproduce:

```
def test_foo(caplog):
    caplog.set_level(42)

def test_bar(caplog):
    print(caplog.handler.level)
```

It prints "0" for pytest<6, "42" after.
````

### `review.md`

```
verdict: PASS

- The check command passed: `15 passed`.
- `LogCaptureFixture._finalize()` now restores the handler level saved before the first `set_level()` call.
- Existing restoration of logger levels from `_initial_logger_levels` remains intact.
- The added test verifies that a handler level set by `caplog.set_level()` is restored to `NOTSET` in the next test.
- Changes are limited to the scoped files: `src/_pytest/logging.py` and `testing/logging/test_fixture.py`.
```

### `scope.txt`

```
scope: src/_pytest/logging.py testing/logging/test_fixture.py
changed: src/_pytest/logging.py +5 -0
changed: testing/logging/test_fixture.py +19 -0
```

### `task.md`

````
# Task

## Prompt

caplog fixture doesn't restore log level after test
From the documentation at https://docs.pytest.org/en/6.0.0/logging.html#caplog-fixture, "The log levels set are restored automatically at the end of the test".
It used to work, but looks broken in new 6.0 release. Minimal example to reproduce:

```
def test_foo(caplog):
    caplog.set_level(42)

def test_bar(caplog):
    print(caplog.handler.level)
```

It prints "0" for pytest<6, "42" after.

## Deliverable

changes to this tree

## Check

`python -m pytest testing/logging/test_fixture.py -q`

## Scope

`src/_pytest/logging.py`
`testing/logging/test_fixture.py`

## Done when

`caplog.set_level(42)` in one test no longer leaves `caplog.handler.level` at 42 in the next test; the handler level is restored automatically at the end of the test.
A logger level changed by `caplog.set_level(..., logger=...)` is restored at the end of the test.
The minimal two-test reproduction from the prompt passes with the old/default level visible in the later test.
Existing `caplog` fixture tests continue to pass.
````

### `test-output.log`

```
check: python -m pytest testing/logging/test_fixture.py -q
...............                                                          [100%]
15 passed in 0.61s
scope: src/_pytest/logging.py testing/logging/test_fixture.py
changed: src/_pytest/logging.py +5 -0
changed: testing/logging/test_fixture.py +19 -0
```

### `test-status.txt`

```
0
```

### `untracked-before.txt`

```
.memdoor/.gitignore
.memdoor/workflows/single/README.md
.memdoor/workflows/single/steps/do.yaml
.memdoor/workflows/team-solve/README.md
.memdoor/workflows/team-solve/changes.sh
.memdoor/workflows/team-solve/check-samples.sh
.memdoor/workflows/team-solve/check.sh
.memdoor/workflows/team-solve/done.sh
.memdoor/workflows/team-solve/failures.sh
.memdoor/workflows/team-solve/sample/task.md
.memdoor/workflows/team-solve/sample/tests/1.in
.memdoor/workflows/team-solve/sample/tests/1.out
.memdoor/workflows/team-solve/sample/tests/2.in
.memdoor/workflows/team-solve/sample/tests/2.out
.memdoor/workflows/team-solve/sample/tests/3.in
.memdoor/workflows/team-solve/sample/tests/3.out
.memdoor/workflows/team-solve/sample/tests/4.in
.memdoor/workflows/team-solve/sample/tests/4.out
.memdoor/workflows/team-solve/sample/tests/5.in
.memdoor/workflows/team-solve/sample/tests/5.out
.memdoor/workflows/team-solve/scope.sh
.memdoor/workflows/team-solve/settle.sh
.memdoor/workflows/team-solve/snapshot.sh
.memdoor/workflows/team-solve/steps/baseline.yaml
.memdoor/workflows/team-solve/steps/context.yaml
.memdoor/workflows/team-solve/steps/direct.yaml
.memdoor/workflows/team-solve/steps/ideate.yaml
.memdoor/workflows/team-solve/steps/judge.yaml
.memdoor/workflows/team-solve/steps/keep.yaml
.memdoor/workflows/team-solve/steps/outline.yaml
.memdoor/workflows/team-solve/steps/plan.yaml
.memdoor/workflows/team-solve/steps/problem.yaml
.memdoor/workflows/team-solve/steps/recheck.yaml
.memdoor/workflows/team-solve/steps/repair.yaml
.memdoor/workflows/team-solve/steps/review.yaml
.memdoor/workflows/team-solve/steps/settle.yaml
.memdoor/workflows/team-solve/steps/solve.yaml
.memdoor/workflows/team-solve/steps/test-0.yaml
.memdoor/workflows/team-solve/steps/test.yaml
.memdoor/workflows/team-solve/steps/verify.yaml
.memdoor/workflows/team-solve/task.sh
.memdoor/workflows/team-solve/task.template.md
.memdoor/workflows/team-solve/verdict.sh
```
