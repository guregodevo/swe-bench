# pylint-dev__pylint-4970 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 103s 45 lines cost=0.005808 in=290065 cached=222720 out=8588 calls=21`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Setting `min-similarity-lines` to `0` should stop pylint from checking duplicate code
### Current problem

Setting `min-similarity-lines` to `0` in the rcfile doesn't disable checking for duplicate code, it instead treats every line of code as duplicate and raises many errors.

### Desired solution

Setting `min-similarity-lines` to `0` should disable the duplicate code check.

It works that way in many other linters (like flake8). Setting a numerical value in flake8 to `0` (e.g. `max-line-length`) disables that check.

### Additional context

#214 requests being able to disable `R0801`, but it is still open


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls -la && git status --short && grep -rn \"min-similarity-lines\\|min_similarity_lines\" pylint | head -50"
}
```

**assistant → tool `glob`**

```json
{
  "pattern": "**/*similarity*"
}
```

**tool result**

```
total 360
drwxrwxrwx  1 root root   4096 Nov  6 12:56 .
drwxr-xr-x  1 root root   4096 Nov  6 12:56 ..
-rw-r--r--  1 root root   2806 Aug 13 03:07 .copyrite_aliases
-rw-r--r--  1 root root    282 Aug 13 03:07 .coveragerc
-rw-r--r--  1 root root    187 Aug 13 03:07 .flake8
drwxrwxrwx  1 root root   4096 Nov  6 12:56 .git
drwxrwxrwx  4 root root   4096 Aug 13 03:07 .github
-rw-r--r--  1 root root    428 Aug 13 03:07 .gitignore
drwxr-xr-x  4 root root   4096 Nov  6 12:56 .memdoor
-rw-r--r--  1 root root   2982 Aug 13 03:07 .pre-commit-config.yaml
-rw-r--r--  1 root root    104 Aug 13 03:07 .pre-commit-hooks.yaml
-rw-r--r--  1 root root    226 Aug 13 03:07 .readthedocs.yaml
-rw-r--r--  1 root root  12590 Aug 13 03:07 CONTRIBUTORS.txt
-rw-r--r--  1 root root 191572 Aug 13 03:07 ChangeLog
-rw-r--r--  1 root root    140 Aug 13 03:07 Dockerfile
-rw-r--r--  1 root root  17984 Aug 13 03:07 LICENSE
-rw-r--r--  1 root root    234 Aug 13 03:07 MANIFEST.in
-rw-r--r--  1 root root   5613 Aug 13 03:07 README.rst
drwxrwxrwx  9 root root   4096 Aug 13 03:07 doc
drwxr-xr-x  2 root root   4096 Aug 13 03:07 elisp
drwxrwxrwx  2 root root   4096 Aug 13 03:07 examples
drwxrwxrwx 11 root root   4096 Aug 13 03:07 pylint
drwxr-xr-x  2 root root   4096 Aug 13 03:07 pylint.egg-info
-rw-r--r--  1 root root  11712 Aug 13 03:07 pylintrc
-rw-r--r--  1 root root    295 Aug 13 03:07 requirements_test.txt
-rw-r--r--  1 root root     96 Aug 13 03:07 requirements_test_min.txt
-rw-r--r--  1 root root    181 Aug 13 03:07 requirements_test_pre_commit.txt
drwxrwxrwx  2 root root   4096 Aug 13 03:07 script
-rw-r--r--  1 root root   3364 Aug 13 03:07 setup.cfg
-rw-r--r--  1 root root     38 Aug 13 03:07 setup.py
-rw-r--r--  1 root root   1363 Aug 13 03:07 tbump.toml
drwxrwxrwx 17 root root   4096 Aug 13 03:07 tests
-rw-r--r--  1 root root   2016 Aug 13 03:07 tox.ini
?? .memdoor/
pylint/checkers/similar.py:737:            "min-similarity-lines",
pylint/checkers/similar.py:789:            min_lines=self.config.min_similarity_lines,
pylint/checkers/similar.py:803:        if optname == "min-similarity-lines":
pylint/checkers/similar.py:804:            self.min_lines = self.config.min_similarity_lines
```

**tool result**

```
No files found matching pattern: **/*similarity*
```

**assistant → tool `read_file`**

```json
{
  "path": "pylint/checkers/similar.py",
  "offset": 700,
  "limit": 140
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"min_similarity_lines\\|min-similarity-lines\" tests doc pylintrc | head -50"
}
```

**tool result**

```

MSGS = {
    "R0801": (
        "Similar lines in %s files\n%s",
        "duplicate-code",
        "Indicates that a set of similar lines has been detected "
        "among multiple file. This usually means that the code should "
        "be refactored to avoid this duplication.",
    )
}


def report_similarities(sect, stats, old_stats):
    """make a layout with some stats about duplication"""
    lines = ["", "now", "previous", "difference"]
    lines += table_lines_from_stats(
        stats, old_stats, ("nb_duplicated_lines", "percent_duplicated_lines")
    )
    sect.append(Table(children=lines, cols=4, rheaders=1, cheaders=1))


# wrapper to get a pylint checker from the similar class
class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
    """checks for similarities and duplicated code. This computation may be
    memory / CPU intensive, so you should disable it if you experiment some
    problems.
    """

    __implements__ = (IRawChecker,)
    # configuration section name
    name = "similarities"
    # messages
    msgs = MSGS
    # configuration options
    # for available dict keys/values see the optik parser 'add_option' method
    options = (
        (
            "min-similarity-lines",
            {
                "default": DEFAULT_MIN_SIMILARITY_LINE,
                "type": "int",
                "metavar": "<int>",
                "help": "Minimum lines number of a similarity.",
            },
        ),
        (
            "ignore-comments",
            {
                "default": True,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Comments are removed from the similarity computation",
            },
        ),
        (
            "ignore-docstrings",
            {
                "default": True,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Docstrings are removed from the similarity computation",
            },
        ),
        (
            "ignore-imports",
            {
                "default": False,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Imports are removed from the similarity computation",
            },
        ),
        (
            "ignore-signatures",
            {
                "default": False,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Signatures are removed from the similarity computation",
            },
        ),
    )
    # reports
    reports = (("RP0801", "Duplication", report_similarities),)

    def __init__(self, linter=None) -> None:
        BaseChecker.__init__(self, linter)
        Similar.__init__(
            self,
            min_lines=self.config.min_similarity_lines,
            ignore_comments=self.config.ignore_comments,
            ignore_docstrings=self.config.ignore_docstrings,
            ignore_imports=self.config.ignore_imports,
            ignore_signatures=self.config.ignore_signatures,
        )
        self.stats = None

    def set_option(self, optname, value, action=None, optdict=None):
        """method called to set an option (registered in the options list)

        Overridden to report options setting to Similar
        """
        BaseChecker.set_option(self, optname, value, action, optdict)
        if optname == "min-similarity-lines":
            self.min_lines = self.config.min_similarity_lines
        elif optname == "ignore-comments":
            self.ignore_comments = self.config.ignore_comments
        elif optname == "ignore-docstrings":
            self.ignore_docstrings = self.config.ignore_docstrings
        elif optname == "ignore-imports":
            self.ignore_imports = self.config.ignore_imports
        elif optname == "ignore-signatures":
            self.ignore_signatures = self.config.ignore_signatures

    def open(self):
        """init the checkers: reset linesets and statistics information"""
        self.linesets = []
        self.stats = self.linter.add_stats(
            nb_duplicated_lines=0, percent_duplicated_lines=0
        )

    def process_module(self, node):
        """process a module

        the module's content is accessible via the stream object

        stream must implement the readlines method
        """
        with node.stream() as stream:
            self.append_stream(self.linter.current_name, stream, node.file_encoding)

    def close(self):
        """compute and display similarities on closing (i.e. end of parsing)"""
        total = sum(len(lineset) for lineset in self.linesets)
        duplicated = 0
        stats = self.stats
        for num, couples in self._compute_sims():
            msg = []
            lineset = start_line = end_line = None
            for lineset, start_line, end_line in couples:

[94 more lines in /testbed/pylint/checkers/similar.py (933 in all). read_file with offset: 840 to continue]
```

**tool result**

```
pylintrc:121:min-similarity-lines=4
```

**assistant → tool `read_file`**

```json
{
  "path": "pylint/checkers/similar.py",
  "offset": 840,
  "limit": 100
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Similar\\|min_lines\\|_compute_sims\\|def append_stream\\|def run\" pylint/checkers/similar.py | head -50"
}
```

**tool result**

```
                msg.append(f"=={lineset.name}:[{start_line}:{end_line}]")
            msg.sort()

            if lineset:
                for line in lineset.real_lines[start_line:end_line]:
                    msg.append(line.rstrip())

            self.add_message("R0801", args=(len(couples), "\n".join(msg)))
            duplicated += num * (len(couples) - 1)
        stats["nb_duplicated_lines"] = duplicated
        stats["percent_duplicated_lines"] = total and duplicated * 100.0 / total

    def get_map_data(self):
        """Passthru override"""
        return Similar.get_map_data(self)

    def reduce_map_data(self, linter, data):
        """Reduces and recombines data into a format that we can report on

        The partner function of get_map_data()"""
        recombined = SimilarChecker(linter)
        recombined.min_lines = self.min_lines
        recombined.ignore_comments = self.ignore_comments
        recombined.ignore_docstrings = self.ignore_docstrings
        recombined.ignore_imports = self.ignore_imports
        recombined.ignore_signatures = self.ignore_signatures
        recombined.open()
        Similar.combine_mapreduce_data(recombined, linesets_collection=data)
        recombined.close()


def register(linter):
    """required method to auto register this checker"""
    linter.register_checker(SimilarChecker(linter))


def usage(status=0):
    """display command line usage information"""
    print("finds copy pasted blocks in a set of files")
    print()
    print(
        "Usage: symilar [-d|--duplicates min_duplicated_lines] \
[-i|--ignore-comments] [--ignore-docstrings] [--ignore-imports] [--ignore-signatures] file1..."
    )
    sys.exit(status)


def Run(argv=None):
    """standalone command line access point"""
    if argv is None:
        argv = sys.argv[1:]

    s_opts = "hdi"
    l_opts = (
        "help",
        "duplicates=",
        "ignore-comments",
        "ignore-imports",
        "ignore-docstrings",
        "ignore-signatures",
    )
    min_lines = DEFAULT_MIN_SIMILARITY_LINE
    ignore_comments = False
    ignore_docstrings = False
    ignore_imports = False
    ignore_signatures = False
    opts, args = getopt(argv, s_opts, l_opts)
    for opt, val in opts:
        if opt in ("-d", "--duplicates"):
            min_lines = int(val)
        elif opt in ("-h", "--help"):
            usage()
        elif opt in ("-i", "--ignore-comments"):
            ignore_comments = True
        elif opt in ("--ignore-docstrings",):
            ignore_docstrings = True
        elif opt in ("--ignore-imports",):
            ignore_imports = True
        elif opt in ("--ignore-signatures",):
            ignore_signatures = True
    if not args:
        usage(1)
    sim = Similar(
        min_lines, ignore_comments, ignore_docstrings, ignore_imports, ignore_signatures
    )
    for filename in args:
        with open(filename, encoding="utf-8") as stream:
            sim.append_stream(filename, stream)
    sim.run()
    sys.exit(0)


if __name__ == "__main__":
    Run()

[lines 840-933 of /testbed/pylint/checkers/similar.py, the end]
```

**tool result**

```
353:class Similar:
358:        min_lines: int = DEFAULT_MIN_SIMILARITY_LINE,
364:        self.min_lines = min_lines
371:    def append_stream(self, streamid: str, stream: TextIO, encoding=None) -> None:
391:    def run(self) -> None:
393:        self._display_sims(self._compute_sims())
395:    def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:
478:        hash_to_index_1, index_to_lines_1 = hash_lineset(lineset1, self.min_lines)
479:        hash_to_index_2, index_to_lines_2 = hash_lineset(lineset2, self.min_lines)
503:                    effective_cmn_lines_nb=self.min_lines,
527:            if eff_cmn_nb > self.min_lines:
722:class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
789:            min_lines=self.config.min_similarity_lines,
804:            self.min_lines = self.config.min_similarity_lines
836:        for num, couples in self._compute_sims():
861:        recombined.min_lines = self.min_lines
901:    min_lines = DEFAULT_MIN_SIMILARITY_LINE
909:            min_lines = int(val)
923:        min_lines, ignore_comments, ignore_docstrings, ignore_imports, ignore_signatures
```

**assistant → tool `read_file`**

```json
{
  "path": "pylint/checkers/similar.py",
  "offset": 340,
  "limit": 210
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"duplicate-code\\|R0801\\|similar\" tests/checkers/unittest_similar.py tests -l | head -30"
}
```

**tool result**

```
    return sum(sline_1 == sline_2 for sline_1, sline_2 in zip(stripped_l1, stripped_l2))


class Commonality(NamedTuple):
    cmn_lines_nb: int
    fst_lset: "LineSet"
    fst_file_start: LineNumber
    fst_file_end: LineNumber
    snd_lset: "LineSet"
    snd_file_start: LineNumber
    snd_file_end: LineNumber


class Similar:
    """finds copy-pasted lines of code in a project"""

    def __init__(
        self,
        min_lines: int = DEFAULT_MIN_SIMILARITY_LINE,
        ignore_comments: bool = False,
        ignore_docstrings: bool = False,
        ignore_imports: bool = False,
        ignore_signatures: bool = False,
    ) -> None:
        self.min_lines = min_lines
        self.ignore_comments = ignore_comments
        self.ignore_docstrings = ignore_docstrings
        self.ignore_imports = ignore_imports
        self.ignore_signatures = ignore_signatures
        self.linesets: List["LineSet"] = []

    def append_stream(self, streamid: str, stream: TextIO, encoding=None) -> None:
        """append a file to search for similarities"""
        if encoding is None:
            readlines = stream.readlines
        else:
            readlines = decoding_stream(stream, encoding).readlines
        try:
            self.linesets.append(
                LineSet(
                    streamid,
                    readlines(),
                    self.ignore_comments,
                    self.ignore_docstrings,
                    self.ignore_imports,
                    self.ignore_signatures,
                )
            )
        except UnicodeDecodeError:
            pass

    def run(self) -> None:
        """start looking for similarities and display results on stdout"""
        self._display_sims(self._compute_sims())

    def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:
        """compute similarities in appended files"""
        no_duplicates: Dict[int, List[Set[LinesChunkLimits_T]]] = defaultdict(list)

        for commonality in self._iter_sims():
            num = commonality.cmn_lines_nb
            lineset1 = commonality.fst_lset
            start_line_1 = commonality.fst_file_start
            end_line_1 = commonality.fst_file_end
            lineset2 = commonality.snd_lset
            start_line_2 = commonality.snd_file_start
            end_line_2 = commonality.snd_file_end

            duplicate = no_duplicates[num]
            couples: Set[LinesChunkLimits_T]
            for couples in duplicate:
                if (lineset1, start_line_1, end_line_1) in couples or (
                    lineset2,
                    start_line_2,
                    end_line_2,
                ) in couples:
                    break
            else:
                duplicate.append(
                    {
                        (lineset1, start_line_1, end_line_1),
                        (lineset2, start_line_2, end_line_2),
                    }
                )
        sims: List[Tuple[int, Set[LinesChunkLimits_T]]] = []
        ensembles: List[Set[LinesChunkLimits_T]]
        for num, ensembles in no_duplicates.items():
            cpls: Set[LinesChunkLimits_T]
            for cpls in ensembles:
                sims.append((num, cpls))
        sims.sort()
        sims.reverse()
        return sims

    def _display_sims(
        self, similarities: List[Tuple[int, Set[LinesChunkLimits_T]]]
    ) -> None:
        """Display computed similarities on stdout"""
        report = self._get_similarity_report(similarities)
        print(report)

    def _get_similarity_report(
        self, similarities: List[Tuple[int, Set[LinesChunkLimits_T]]]
    ) -> str:
        """Create a report from similarities"""
        report: str = ""
        duplicated_line_number: int = 0
        for number, couples in similarities:
            report += f"\n{number} similar lines in {len(couples)} files\n"
            couples_l = sorted(couples)
            line_set = start_line = end_line = None
            for line_set, start_line, end_line in couples_l:
                report += f"=={line_set.name}:[{start_line}:{end_line}]\n"
            if line_set:
                for line in line_set._real_lines[start_line:end_line]:
                    report += f"   {line.rstrip()}\n" if line.rstrip() else "\n"
            duplicated_line_number += number * (len(couples_l) - 1)
        total_line_number: int = sum(len(lineset) for lineset in self.linesets)
        report += f"TOTAL lines={total_line_number} duplicates={duplicated_line_number} percent={duplicated_line_number * 100.0 / total_line_number:.2f}\n"
        return report

    def _find_common(
        self, lineset1: "LineSet", lineset2: "LineSet"
    ) -> Generator[Commonality, None, None]:
        """
        Find similarities in the two given linesets.

        This the core of the algorithm.
        The idea is to compute the hashes of a minimal number of successive lines of each lineset and then compare the hashes.
        Every match of such comparison is stored in a dict that links the couple of starting indices in both linesets to
        the couple of corresponding starting and ending lines in both files.
        Last regroups all successive couples in a bigger one. It allows to take into account common chunk of lines that have more
        than the minimal number of successive lines required.
        """
        hash_to_index_1: HashToIndex_T
        hash_to_index_2: HashToIndex_T
        index_to_lines_1: IndexToLines_T
        index_to_lines_2: IndexToLines_T
        hash_to_index_1, index_to_lines_1 = hash_lineset(lineset1, self.min_lines)
        hash_to_index_2, index_to_lines_2 = hash_lineset(lineset2, self.min_lines)

        hash_1: FrozenSet[LinesChunk] = frozenset(hash_to_index_1.keys())
        hash_2: FrozenSet[LinesChunk] = frozenset(hash_to_index_2.keys())

        common_hashes: Iterable[LinesChunk] = sorted(
            hash_1 & hash_2, key=lambda m: hash_to_index_1[m][0]
        )

        # all_couples is a dict that links the couple of indices in both linesets that mark the beginning of
        # successive common lines, to the corresponding starting and ending number lines in both files
        all_couples: CplIndexToCplLines_T = {}

        for c_hash in sorted(common_hashes, key=operator.attrgetter("_index")):
            for indices_in_linesets in itertools.product(
                hash_to_index_1[c_hash], hash_to_index_2[c_hash]
            ):
                index_1 = indices_in_linesets[0]
                index_2 = indices_in_linesets[1]
                all_couples[
                    LineSetStartCouple(index_1, index_2)
                ] = CplSuccessiveLinesLimits(
                    copy.copy(index_to_lines_1[index_1]),
                    copy.copy(index_to_lines_2[index_2]),
                    effective_cmn_lines_nb=self.min_lines,
                )

        remove_successives(all_couples)

        for cml_stripped_l, cmn_l in all_couples.items():
            start_index_1 = cml_stripped_l.fst_lineset_index
            start_index_2 = cml_stripped_l.snd_lineset_index
            nb_common_lines = cmn_l.effective_cmn_lines_nb

            com = Commonality(
                cmn_lines_nb=nb_common_lines,
                fst_lset=lineset1,
                fst_file_start=cmn_l.first_file.start,
                fst_file_end=cmn_l.first_file.end,
                snd_lset=lineset2,
                snd_file_start=cmn_l.second_file.start,
                snd_file_end=cmn_l.second_file.end,
            )

            eff_cmn_nb = filter_noncode_lines(
                lineset1, start_index_1, lineset2, start_index_2, nb_common_lines
            )

            if eff_cmn_nb > self.min_lines:
                yield com

    def _iter_sims(self) -> Generator[Commonality, None, None]:
        """iterate on similarities among all files, by making a cartesian
        product
        """
        for idx, lineset in enumerate(self.linesets[:-1]):
            for lineset2 in self.linesets[idx + 1 :]:
                yield from self._find_common(lineset, lineset2)

    def get_map_data(self):
        """Returns the data we can use for a map/reduce process

        In this case we are returning this instance's Linesets, that is all file
        information that will later be used for vectorisation.
        """
        return self.linesets

    def combine_mapreduce_data(self, linesets_collection):
        """Reduces and recombines data into a format that we can report on

        The partner function of get_map_data()"""

[384 more lines in /testbed/pylint/checkers/similar.py (933 in all). read_file with offset: 550 to continue]
```

**tool result**

```
tests/checkers/unittest_similar.py
tests/functional/m/member/member_checks_hints.txt
tests/functional/m/member/member_checks_hints.py
tests/functional/m/member/member_checks_no_hints.txt
tests/functional/m/member/member_checks_no_hints.py
tests/test_self.py
tests/test_check_parallel.py
tests/checkers/unittest_similar.py
tests/input/func_w0801.py
tests/input/similar4
tests/input/similar_lines_a.py
tests/input/w0801_same.py
tests/input/similar_lines_b.py
tests/input/similar3
tests/lint/unittest_lint.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"min_lines\\|min_similarity\\|Similar(\" tests/checkers/unittest_similar.py | head -80; grep -rn \"min-similarity-lines\" tests | head -40"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"duplicate-code\\|R0801\" tests/functional tests/test_self.py tests/test_check_parallel.py | head -50"
}
```

**tool result**

```

```

**tool result**

```
tests/test_self.py:1111:            [path, "--disable=all", "--enable=duplicate-code"],
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test\\|Similar\\|min_lines\\|duplicate\" tests/checkers/unittest_similar.py | head -100; sed -n '1,80p' tests/checkers/unittest_similar.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1080,1140p' tests/test_self.py; grep -rn \"similar\" tests/functional -l | head"
}
```

**tool result**

```
48:def test_ignore_comments() -> None:
71:TOTAL lines=62 duplicates=10 percent=16.13
77:def test_ignore_docstrings() -> None:
106:TOTAL lines=62 duplicates=10 percent=16.13
112:def test_ignore_imports() -> None:
120:TOTAL lines=62 duplicates=0 percent=0.00
125:def test_multiline_imports() -> None:
145:TOTAL lines=16 duplicates=8 percent=50.00
151:def test_ignore_multiline_imports() -> None:
159:TOTAL lines=16 duplicates=0 percent=0.00
164:def test_ignore_signatures_fail() -> None:
196:TOTAL lines=35 duplicates=15 percent=42.86
202:def test_ignore_signatures_pass() -> None:
210:TOTAL lines=35 duplicates=0 percent=0.00
215:def test_ignore_signatures_class_methods_fail() -> None:
255:TOTAL lines=54 duplicates=22 percent=40.74
261:def test_ignore_signatures_class_methods_pass() -> None:
269:TOTAL lines=54 duplicates=0 percent=0.00
274:def test_ignore_signatures_empty_functions_fail() -> None:
292:TOTAL lines=14 duplicates=6 percent=42.86
298:def test_ignore_signatures_empty_functions_pass() -> None:
306:TOTAL lines=14 duplicates=0 percent=0.00
311:def test_no_hide_code_with_imports() -> None:
316:    assert "TOTAL lines=32 duplicates=16 percent=50.00" in output.getvalue()
319:def test_ignore_nothing() -> None:
336:TOTAL lines=62 duplicates=5 percent=8.06
342:def test_lines_without_meaningful_content_do_not_trigger_similarity() -> None:
368:TOTAL lines=50 duplicates=14 percent=28.00
374:def test_help() -> None:
385:def test_no_args() -> None:
396:def test_get_map_data() -> None:
397:    """Tests that a SimilarChecker respects the MapReduceMixin interface"""
401:    linter.register_checker(similar.SimilarChecker(linter))
491:        sim = similar.SimilarChecker(linter)
# Copyright (c) 2010, 2012, 2014 LOGILAB S.A. (Paris, FRANCE) <contact@logilab.fr>
# Copyright (c) 2012 Ry4an Brase <ry4an-hg@ry4an.org>
# Copyright (c) 2014 Google, Inc.
# Copyright (c) 2015 Ionel Cristian Maries <contact@ionelmc.ro>
# Copyright (c) 2016-2018, 2020 Claudiu Popa <pcmanticore@gmail.com>
# Copyright (c) 2016 Derek Gustafson <degustaf@gmail.com>
# Copyright (c) 2018 Scott Worley <scottworley@scottworley.com>
# Copyright (c) 2018 Sushobhit <31987769+sushobhit27@users.noreply.github.com>
# Copyright (c) 2019-2021 Pierre Sassoulas <pierre.sassoulas@gmail.com>
# Copyright (c) 2019 Ashley Whetter <ashley@awhetter.co.uk>
# Copyright (c) 2019 Taewon D. Kim <kimt33@mcmaster.ca>
# Copyright (c) 2020-2021 hippo91 <guillaume.peillex@gmail.com>
# Copyright (c) 2020 Frank Harrison <frank@doublethefish.com>
# Copyright (c) 2020 Eli Fine <ejfine@gmail.com>
# Copyright (c) 2021 Maksym Humetskyi <Humetsky@gmail.com>
# Copyright (c) 2021 Daniël van Noord <13665637+DanielNoord@users.noreply.github.com>
# Copyright (c) 2021 Marc Mueller <30130371+cdce8p@users.noreply.github.com>
# Copyright (c) 2021 Aditya Gupta <adityagupta1089@users.noreply.github.com>

# Licensed under the GPL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
# For details: https://github.com/PyCQA/pylint/blob/main/LICENSE

from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path

import pytest

from pylint.checkers import similar
from pylint.lint import PyLinter
from pylint.testutils import GenericTestReporter as Reporter

INPUT = Path(__file__).parent / ".." / "input"
SIMILAR1 = str(INPUT / "similar1")
SIMILAR2 = str(INPUT / "similar2")
SIMILAR3 = str(INPUT / "similar3")
SIMILAR4 = str(INPUT / "similar4")
SIMILAR5 = str(INPUT / "similar5")
SIMILAR6 = str(INPUT / "similar6")
SIMILAR_CLS_A = str(INPUT / "similar_cls_a.py")
SIMILAR_CLS_B = str(INPUT / "similar_cls_b.py")
EMPTY_FUNCTION_1 = str(INPUT / "similar_empty_func_1.py")
EMPTY_FUNCTION_2 = str(INPUT / "similar_empty_func_2.py")
MULTILINE = str(INPUT / "multiline-import")
HIDE_CODE_WITH_IMPORTS = str(INPUT / "hide_code_with_imports.py")


def test_ignore_comments() -> None:
    output = StringIO()
    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
        similar.Run(["--ignore-comments", SIMILAR1, SIMILAR2])
    assert ex.value.code == 0
    assert (
        output.getvalue().strip()
        == (
            f"""
10 similar lines in 2 files
=={SIMILAR1}:[0:11]
=={SIMILAR2}:[0:11]
   import one
   from two import two
   three
   four
   five
   six
   # A full line comment
   seven
   eight
   nine
   ''' ten
TOTAL lines=62 duplicates=10 percent=16.13
"""
        ).strip()
    )


def test_ignore_docstrings() -> None:
    output = StringIO()
    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
        similar.Run(["--ignore-docstrings", SIMILAR1, SIMILAR2])
```

**tool result**

```
                code=0,
            )

    @staticmethod
    def test_can_list_directories_without_dunder_init(tmpdir: LocalPath) -> None:
        test_directory = tmpdir / "test_directory"
        test_directory.mkdir()
        spam_module = test_directory / "spam.py"
        spam_module.write("'Empty'")

        subprocess.check_output(
            [
                sys.executable,
                "-m",
                "pylint",
                "--disable=missing-docstring, missing-final-newline",
                "test_directory",
            ],
            cwd=str(tmpdir),
            stderr=subprocess.PIPE,
        )

    def test_jobs_score(self) -> None:
        path = join(HERE, "regrtest_data", "unused_variable.py")
        expected = "Your code has been rated at 7.50/10"
        self._test_output([path, "--jobs=2", "-ry"], expected_output=expected)

    def test_duplicate_code_raw_strings(self) -> None:
        path = join(HERE, "regrtest_data", "duplicate_data_raw_strings")
        expected_output = "Similar lines in 2 files"
        self._test_output(
            [path, "--disable=all", "--enable=duplicate-code"],
            expected_output=expected_output,
        )

    def test_regression_parallel_mode_without_filepath(self) -> None:
        # Test that parallel mode properly passes filepath
        # https://github.com/PyCQA/pylint/issues/3564
        path = join(
            HERE, "regrtest_data", "regression_missing_init_3564", "subdirectory/"
        )
        self._test_output([path, "-j2"], expected_output="No such file or directory")

    def test_output_file_valid_path(self, tmpdir: LocalPath) -> None:
        path = join(HERE, "regrtest_data", "unused_variable.py")
        output_file = tmpdir / "output.txt"
        expected = "Your code has been rated at 7.50/10"
        self._test_output_file(
            [path, f"--output={output_file}"],
            output_file,
            expected_output=expected,
        )

    def test_output_file_invalid_path_exits_with_code_32(self) -> None:
        path = join(HERE, "regrtest_data", "unused_variable.py")
        output_file = "thisdirectorydoesnotexit/output.txt"
        self._runtest([path, f"--output={output_file}"], code=32)

    @pytest.mark.parametrize(
        "args, expected",
        [
tests/functional/m/member/member_checks_hints.txt
tests/functional/m/member/member_checks_hints.py
tests/functional/m/member/member_checks_no_hints.txt
tests/functional/m/member/member_checks_no_hints.py
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '310,430p' tests/checkers/unittest_similar.py; sed -n '1,70p' pylint/checkers/similar.py; sed -n '100,135p' pylintrc"
}
```

**tool result**

```

def test_no_hide_code_with_imports() -> None:
    output = StringIO()
    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
        similar.Run(["--ignore-imports"] + 2 * [HIDE_CODE_WITH_IMPORTS])
    assert ex.value.code == 0
    assert "TOTAL lines=32 duplicates=16 percent=50.00" in output.getvalue()


def test_ignore_nothing() -> None:
    output = StringIO()
    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
        similar.Run([SIMILAR1, SIMILAR2])
    assert ex.value.code == 0
    assert (
        output.getvalue().strip()
        == (
            f"""
5 similar lines in 2 files
=={SIMILAR1}:[0:5]
=={SIMILAR2}:[0:5]
   import one
   from two import two
   three
   four
   five
TOTAL lines=62 duplicates=5 percent=8.06
"""
        ).strip()
    )


def test_lines_without_meaningful_content_do_not_trigger_similarity() -> None:
    output = StringIO()
    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
        similar.Run([SIMILAR3, SIMILAR4])
    assert ex.value.code == 0
    assert (
        output.getvalue().strip()
        == (
            f"""
14 similar lines in 2 files
=={SIMILAR3}:[11:25]
=={SIMILAR4}:[11:25]
   b = (
       (
           [
               "Lines 12-25 still trigger a similarity...",
               "...warning, because..."
           ],
           [
               "...even after ignoring lines with only symbols..."
           ],
       ),
       (
           "...there are still 5 similar lines in this code block.",
       )
   )
TOTAL lines=50 duplicates=14 percent=28.00
"""
        ).strip()
    )


def test_help() -> None:
    output = StringIO()
    with redirect_stdout(output):
        try:
            similar.Run(["--help"])
        except SystemExit as ex:
            assert ex.code == 0
        else:
            pytest.fail("not system exit")


def test_no_args() -> None:
    output = StringIO()
    with redirect_stdout(output):
        try:
            similar.Run([])
        except SystemExit as ex:
            assert ex.code == 1
        else:
            pytest.fail("not system exit")


def test_get_map_data() -> None:
    """Tests that a SimilarChecker respects the MapReduceMixin interface"""
    linter = PyLinter(reporter=Reporter())

    # Add a parallel checker to ensure it can map and reduce
    linter.register_checker(similar.SimilarChecker(linter))

    source_streams = (
        str(INPUT / "similar_lines_a.py"),
        str(INPUT / "similar_lines_b.py"),
    )
    expected_linelists = (
        (
            "def adipiscing(elit):",
            'etiam = "id"',
            'dictum = "purus,"',
            'vitae = "pretium"',
            'neque = "Vivamus"',
            'nec = "ornare"',
            'tortor = "sit"',
            "return etiam, dictum, vitae, neque, nec, tortor",
            "class Amet:",
            "def similar_function_3_lines(self, tellus):",
            "agittis = 10",
            "tellus *= 300",
            "return agittis, tellus",
            "def lorem(self, ipsum):",
            'dolor = "sit"',
            'amet = "consectetur"',
            "return (lorem, dolor, amet)",
            "def similar_function_5_lines(self, similar):",
            "some_var = 10",
            "someother_var *= 300",
            'fusce = "sit"',
            'amet = "tortor"',
# Copyright (c) 2006, 2008-2014 LOGILAB S.A. (Paris, FRANCE) <contact@logilab.fr>
# Copyright (c) 2012 Ry4an Brase <ry4an-hg@ry4an.org>
# Copyright (c) 2012 Google, Inc.
# Copyright (c) 2012 Anthony VEREZ <anthony.verez.external@cassidian.com>
# Copyright (c) 2014-2020 Claudiu Popa <pcmanticore@gmail.com>
# Copyright (c) 2014 Brett Cannon <brett@python.org>
# Copyright (c) 2014 Arun Persaud <arun@nubati.net>
# Copyright (c) 2015 Ionel Cristian Maries <contact@ionelmc.ro>
# Copyright (c) 2017, 2020 Anthony Sottile <asottile@umich.edu>
# Copyright (c) 2017 Mikhail Fesenko <proggga@gmail.com>
# Copyright (c) 2018 Scott Worley <scottworley@scottworley.com>
# Copyright (c) 2018 ssolanki <sushobhitsolanki@gmail.com>
# Copyright (c) 2019, 2021 Pierre Sassoulas <pierre.sassoulas@gmail.com>
# Copyright (c) 2019 Hugo van Kemenade <hugovk@users.noreply.github.com>
# Copyright (c) 2019 Taewon D. Kim <kimt33@mcmaster.ca>
# Copyright (c) 2020-2021 hippo91 <guillaume.peillex@gmail.com>
# Copyright (c) 2020 Frank Harrison <frank@doublethefish.com>
# Copyright (c) 2020 Eli Fine <ejfine@gmail.com>
# Copyright (c) 2020 Shiv Venkatasubrahmanyam <shvenkat@users.noreply.github.com>
# Copyright (c) 2021 Marc Mueller <30130371+cdce8p@users.noreply.github.com>
# Copyright (c) 2021 Maksym Humetskyi <Humetsky@gmail.com>
# Copyright (c) 2021 Daniël van Noord <13665637+DanielNoord@users.noreply.github.com>
# Copyright (c) 2021 bot <bot@noreply.github.com>
# Copyright (c) 2021 Aditya Gupta <adityagupta1089@users.noreply.github.com>

# Licensed under the GPL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
# For details: https://github.com/PyCQA/pylint/blob/main/LICENSE

# pylint: disable=redefined-builtin
"""a similarities / code duplication command line tool and pylint checker

The algorithm is based on comparing the hash value of n successive lines of a file.
First the files are read and any line that doesn't fullfill requirement are removed (comments, docstrings...)
Those stripped lines are stored in the LineSet class which gives access to them.
Then each index of the stripped lines collection is associated with the hash of n successive entries of the stripped lines starting at the current index
(n is the minimum common lines option).
The common hashes between both linesets are then looked for. If there are matches, then the match indices in both linesets are stored and associated
with the corresponding couples (start line number/end line number) in both files.
This association is then postprocessed to handle the case of successive matches. For example if the minimum common lines setting is set to four, then
the hashes are computed with four lines. If one of match indices couple (12, 34) is the successor of another one (11, 33) then it means that there are
in fact five lines wich are common.
Once postprocessed the values of association table are the result looked for, i.e start and end lines numbers of common lines in both files.
"""
import copy
import functools
import itertools
import operator
import re
import sys
from collections import defaultdict
from getopt import getopt
from itertools import chain, groupby
from typing import (
    Any,
    Dict,
    FrozenSet,
    Generator,
    Iterable,
    List,
    NamedTuple,
    NewType,
    Set,
    TextIO,
    Tuple,
)

import astroid
from astroid import nodes

from pylint.checkers import BaseChecker, MapReduceMixin, table_lines_from_stats
# Template used to display messages. This is a python new-style format string
# used to format the message information. See doc for all details
#msg-template=


[LOGGING]

# Logging modules to check that the string format arguments are in logging
# function parameter format
logging-modules=logging


[MISCELLANEOUS]

# List of note tags to take in consideration, separated by a comma.
notes=FIXME,XXX,TODO


[SIMILARITIES]

# Minimum lines number of a similarity.
min-similarity-lines=4

# Ignore comments when computing similarities.
ignore-comments=yes

# Ignore docstrings when computing similarities.
ignore-docstrings=yes

# Ignore imports when computing similarities.
ignore-imports=no


[VARIABLES]

# Tells whether we should check for unused import in __init__ files.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '430,530p' tests/checkers/unittest_similar.py; grep -n \"def hash_lineset\" -A35 pylint/checkers/similar.py"
}
```

**tool result**

```
            'amet = "tortor"',
            "return some_var, someother_var, fusce, amet",
            'def __init__(self, moleskie, lectus="Mauris", ac="pellentesque"):',
            'metus = "ut"',
            'lobortis = "urna."',
            'Integer = "nisl"',
            '(mauris,) = "interdum"',
            'non = "odio"',
            'semper = "aliquam"',
            'malesuada = "nunc."',
            'iaculis = "dolor"',
            'facilisis = "ultrices"',
            'vitae = "ut."',
            "return (",
            "metus,",
            "lobortis,",
            "Integer,",
            "mauris,",
            "non,",
            "semper,",
            "malesuada,",
            "iaculis,",
            "facilisis,",
            "vitae,",
            ")",
            "def similar_function_3_lines(self, tellus):",
            "agittis = 10",
            "tellus *= 300",
            "return agittis, tellus",
        ),
        (
            "class Nulla:",
            'tortor = "ultrices quis porta in"',
            'sagittis = "ut tellus"',
            "def pulvinar(self, blandit, metus):",
            "egestas = [mauris for mauris in zip(blandit, metus)]",
            "neque = (egestas, blandit)",
            "def similar_function_5_lines(self, similar):",
            "some_var = 10",
            "someother_var *= 300",
            'fusce = "sit"',
            'amet = "tortor"',
            'iaculis = "dolor"',
            "return some_var, someother_var, fusce, amet, iaculis, iaculis",
            "def tortor(self):",
            "ultrices = 2",
            'quis = ultricies * "porta"',
            "return ultricies, quis",
            "class Commodo:",
            "def similar_function_3_lines(self, tellus):",
            "agittis = 10",
            "tellus *= 300",
            'laoreet = "commodo "',
            "return agittis, tellus, laoreet",
        ),
    )

    data = []

    # Manually perform a 'map' type function
    for source_fname in source_streams:
        sim = similar.SimilarChecker(linter)
        with open(source_fname, encoding="utf-8") as stream:
            sim.append_stream(source_fname, stream)
        # The map bit, can you tell? ;)
        data.extend(sim.get_map_data())

    assert len(expected_linelists) == len(data)
    for source_fname, expected_lines, lineset_obj in zip(
        source_streams, expected_linelists, data
    ):
        assert source_fname == lineset_obj.name
        # There doesn't seem to be a faster way of doing this, yet.
        lines = (linespec.text for linespec in lineset_obj.stripped_lines)
        assert tuple(expected_lines) == tuple(lines)
225:def hash_lineset(
226-    lineset: "LineSet", min_common_lines: int = DEFAULT_MIN_SIMILARITY_LINE
227-) -> Tuple[HashToIndex_T, IndexToLines_T]:
228-    """
229-    Return two dicts. The first associates the hash of successive stripped lines of a lineset
230-    to the indices of the starting lines.
231-    The second dict, associates the index of the starting line in the lineset's stripped lines to the
232-    couple [start, end] lines number in the corresponding file.
233-
234-    :param lineset: lineset object (i.e the lines in a file)
235-    :param min_common_lines: number of successive lines that are used to compute the hash
236-    :return: a dict linking hashes to corresponding start index and a dict that links this
237-             index to the start and end lines in the file
238-    """
239-    hash2index = defaultdict(list)
240-    index2lines = {}
241-    # Comments, docstring and other specific patterns maybe excluded -> call to stripped_lines
242-    # to get only what is desired
243-    lines = tuple(x.text for x in lineset.stripped_lines)
244-    # Need different iterators on same lines but each one is shifted 1 from the precedent
245-    shifted_lines = [iter(lines[i:]) for i in range(min_common_lines)]
246-
247-    for index_i, *succ_lines in enumerate(zip(*shifted_lines)):
248-        start_linenumber = lineset.stripped_lines[index_i].line_number
249-        try:
250-            end_linenumber = lineset.stripped_lines[
251-                index_i + min_common_lines
252-            ].line_number
253-        except IndexError:
254-            end_linenumber = lineset.stripped_lines[-1].line_number + 1
255-
256-        index = Index(index_i)
257-        index2lines[index] = SuccessiveLinesLimits(
258-            start=LineNumber(start_linenumber), end=LineNumber(end_linenumber)
259-        )
260-
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: pylint/checkers/similar.py\n@@\n     def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:\n         \"\"\"compute similarities in appended files\"\"\"\n+        if self.min_lines <= 0:\n+            # A minimum of zero (or less) lines means the check is disabled.\n+            return []\n+\n         no_duplicates: Dict[int, List[Set[LinesChunkLimits_T]]] = defaultdict(list)\n@@\n                 \"default\": DEFAULT_MIN_SIMILARITY_LINE,\n                 \"type\": \"int\",\n                 \"metavar\": \"<int>\",\n-                \"help\": \"Minimum lines number of a similarity.\",\n+                \"help\": \"Minimum lines number of a similarity. \"\n+                \"If set to 0, disable the duplicate code check.\",\n             },\n         ),\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[pylint/checkers/similar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

pylint/checkers/similar.py now (938 lines), around the change:
394:
395:    def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:
396:        """compute similarities in appended files"""
397:        if self.min_lines <= 0:
398:            # A minimum of zero (or less) lines means the check is disabled.
399:            return []
400:
401:        no_duplicates: Dict[int, List[Set[LinesChunkLimits_T]]] = defaultdict(list)
402:
403:        for commonality in self._iter_sims():
…
743:                "default": DEFAULT_MIN_SIMILARITY_LINE,
744:                "type": "int",
745:                "metavar": "<int>",
746:                "help": "Minimum lines number of a similarity. "
747:                "If set to 0, disable the duplicate code check.",
748:            },
749:        ),
750:        (
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_get_map_data\" -B5 tests/checkers/unittest_similar.py; grep -rn \"min-similarity-lines\" doc | head -20; grep -n \"SimilarChecker\" tests/checkers/unittest_similar.py"
}
```

**tool result**

```
391-            assert ex.code == 1
392-        else:
393-            pytest.fail("not system exit")
394-
395-
396:def test_get_map_data() -> None:
397:    """Tests that a SimilarChecker respects the MapReduceMixin interface"""
401:    linter.register_checker(similar.SimilarChecker(linter))
491:        sim = similar.SimilarChecker(linter)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Minimum lines number of a similarity\" . --exclude-dir=.git --exclude-dir=.memdoor; grep -n \"DEFAULT_MIN_SIMILARITY_LINE\" pylint/checkers/similar.py"
}
```

**tool result**

```
./examples/pylintrc:300:# Minimum lines number of a similarity.
./pylintrc:120:# Minimum lines number of a similarity.
./pylint/checkers/similar.py:746:                "help": "Minimum lines number of a similarity. "
75:DEFAULT_MIN_SIMILARITY_LINE = 4
226:    lineset: "LineSet", min_common_lines: int = DEFAULT_MIN_SIMILARITY_LINE
358:        min_lines: int = DEFAULT_MIN_SIMILARITY_LINE,
743:                "default": DEFAULT_MIN_SIMILARITY_LINE,
906:    min_lines = DEFAULT_MIN_SIMILARITY_LINE
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/checkers/unittest_similar.py\n@@\n def test_ignore_nothing() -> None:\n@@\n     )\n \n \n+def test_min_similarity_lines_zero_disables_check() -> None:\n+    output = StringIO()\n+    with redirect_stdout(output), pytest.raises(SystemExit) as ex:\n+        similar.Run([\"--duplicates=0\", SIMILAR1, SIMILAR2])\n+    assert ex.value.code == 0\n+    assert \"similar lines in\" not in output.getvalue()\n+    assert \"duplicates=0\" in output.getvalue()\n+\n+\n def test_lines_without_meaningful_content_do_not_trigger_similarity() -> None:\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/checkers/unittest_similar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/checkers/unittest_similar.py now (513 lines), around the change:
337:"""
338:        ).strip()
339:    )
340:
341:
342:def test_min_similarity_lines_zero_disables_check() -> None:
343:    output = StringIO()
344:    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
345:        similar.Run(["--duplicates=0", SIMILAR1, SIMILAR2])
346:    assert ex.value.code == 0
347:    assert "similar lines in" not in output.getvalue()
348:    assert "duplicates=0" in output.getvalue()
349:
350:
351:def test_lines_without_meaningful_content_do_not_trigger_similarity() -> None:
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/checkers/unittest_similar.py -q 2>&1 | tail -20"
}
```

**tool result**

```
..................                                                       [100%]
=============================== warnings summary ===============================
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90: DeprecationWarning: The 'astroid.node_classes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26: DeprecationWarning: The 'astroid.scoped_nodes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/warnings.html
18 passed, 3 warnings in 0.07s
```

**assistant → tool `bash`**

```json
{
  "command": "printf '[SIMILARITIES]\\nmin-similarity-lines=0\\n' > /tmp/rc0; python -m pylint --rcfile=/tmp/rc0 --disable=all --enable=duplicate-code tests/input/similar1 tests/input/similar2 2>&1 | tail -10; echo \"exit:$?\""
}
```

**tool result**

```

------------------------------------
Your code has been rated at 10.00/10

exit:0
```

**assistant → tool `bash`**

```json
{
  "command": "printf '[SIMILARITIES]\\nmin-similarity-lines=4\\n' > /tmp/rc4; python -m pylint --rcfile=/tmp/rc4 --disable=all --enable=duplicate-code tests/input/similar1 tests/input/similar2 2>&1 | grep -E \"Similar lines|duplicate-code|rated\"; python -m pytest tests/test_self.py -q -k \"duplicate_code\" 2>&1 | tail -3"
}
```

**tool result**

```
tests/input/similar2:1:0: R0801: Similar lines in 2 files
fourteen (duplicate-code)
Your code has been rated at 9.72/10 (previous run: 10.00/10, -0.28)

-- Docs: https://docs.pytest.org/en/stable/warnings.html
1 passed, 101 deselected, 3 warnings in 0.35s
```

**assistant → tool `bash`**

```json
{
  "command": "ls doc/whatsnew/fragments 2>/dev/null | head; git diff --stat"
}
```

**tool result**

```
 pylint/checkers/similar.py         | 7 ++++++-
 tests/checkers/unittest_similar.py | 9 +++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)
```

**assistant → tool `bash`**

```json
{
  "command": "ls doc/whatsnew | tail; ls doc/whatsnew/2.13* 2>/dev/null | head"
}
```

**tool result**

```
2.2.rst
2.3.rst
2.4.rst
2.5.rst
2.6.rst
2.7.rst
2.8.rst
2.9.rst
changelog.rst
index.rst
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/checkers/unittest_similar.py tests/test_self.py -q -k \"similar or duplicate\" 2>&1 | tail -4"
}
```

**tool result**

```
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/warnings.html
20 passed, 100 deselected, 3 warnings in 0.79s
```

**assistant**

```
Implemented the `min-similarity-lines = 0` disable behavior.

Changes:
- `pylint/checkers/similar.py`
  - `Similar._compute_sims()` now returns no similarities when `min_lines <= 0`, preventing the zero-window hashing that previously flagged every line.
  - Updated the option help text to document that `0` disables the duplicate code check.
- `tests/checkers/unittest_similar.py`
  - Added `test_min_similarity_lines_zero_disables_check`, verifying `--duplicates=0` produces no similarity warnings and reports `duplicates=0`.

Verification:
- `tests/checkers/unittest_similar.py`: 18 passed.
- Similar/duplicate tests across `unittest_similar.py` and `test_self.py`: 20 passed.
- Manual check: an rcfile with `min-similarity-lines=0` reports no `R0801`, while `=4` still reports it.
```

## Run folder `team-solve-2026-11-06T125624`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
7300d5d4bd744607a196f627546d09919cb10f55
```

### `baseline-check.log`

```
check: python -m pytest tests/checkers/unittest_similar.py -q
.................                                                        [100%]
=============================== warnings summary ===============================
../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90: DeprecationWarning: The 'astroid.node_classes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26: DeprecationWarning: The 'astroid.scoped_nodes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/warnings.html
17 passed, 3 warnings in 0.10s
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/pylint/checkers/similar.py b/pylint/checkers/similar.py
index c65b1c89..e9b75f19 100644
--- a/pylint/checkers/similar.py
+++ b/pylint/checkers/similar.py
@@ -394,6 +394,10 @@ class Similar:
 
     def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:
         """compute similarities in appended files"""
+        if self.min_lines <= 0:
+            # A minimum of zero (or less) lines means the check is disabled.
+            return []
+
         no_duplicates: Dict[int, List[Set[LinesChunkLimits_T]]] = defaultdict(list)
 
         for commonality in self._iter_sims():
@@ -739,7 +743,8 @@ class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
                 "default": DEFAULT_MIN_SIMILARITY_LINE,
                 "type": "int",
                 "metavar": "<int>",
-                "help": "Minimum lines number of a similarity.",
+                "help": "Minimum lines number of a similarity. "
+                "If set to 0, disable the duplicate code check.",
             },
         ),
         (
diff --git a/tests/checkers/unittest_similar.py b/tests/checkers/unittest_similar.py
index 4ddf2029..59618f58 100644
--- a/tests/checkers/unittest_similar.py
+++ b/tests/checkers/unittest_similar.py
@@ -339,6 +339,15 @@ TOTAL lines=62 duplicates=5 percent=8.06
     )
 
 
+def test_min_similarity_lines_zero_disables_check() -> None:
+    output = StringIO()
+    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
+        similar.Run(["--duplicates=0", SIMILAR1, SIMILAR2])
+    assert ex.value.code == 0
+    assert "similar lines in" not in output.getvalue()
+    assert "duplicates=0" in output.getvalue()
+
+
 def test_lines_without_meaningful_content_do_not_trigger_similarity() -> None:
     output = StringIO()
     with redirect_stdout(output), pytest.raises(SystemExit) as ex:
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

Setting `min-similarity-lines` to `0` should stop pylint from checking duplicate code
### Current problem

Setting `min-similarity-lines` to `0` in the rcfile doesn't disable checking for duplicate code, it instead treats every line of code as duplicate and raises many errors.

### Desired solution

Setting `min-similarity-lines` to `0` should disable the duplicate code check.

It works that way in many other linters (like flake8). Setting a numerical value in flake8 to `0` (e.g. `max-line-length`) disables that check.

### Additional context

#214 requests being able to disable `R0801`, but it is still open

## Deliverable

changes to this tree

## Check

`python -m pytest tests/checkers/unittest_similar.py -q`

## Scope

`pylint/checkers/similar.py`
`tests/checkers/`

## Done when

Setting `min-similarity-lines = 0` causes the duplicate-code checker to emit no `R0801` messages.
The duplicate-code checker does not treat every line as duplicate when `min-similarity-lines` is `0`.
Positive `min-similarity-lines` values still perform duplicate-code detection as before.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest tests/checkers/unittest_similar.py -q`

## Scope
`pylint/checkers/similar.py`
`tests/checkers/`

## Done when
Setting `min-similarity-lines = 0` causes the duplicate-code checker to emit no `R0801` messages.
The duplicate-code checker does not treat every line as duplicate when `min-similarity-lines` is `0`.
Positive `min-similarity-lines` values still perform duplicate-code detection as before.

## Approach
Find every use of `config.min_similarity_lines` in `SimilarChecker` and short-circuit the duplicate-code comparison when it is `0`, before any line-set pair can be treated as matching. Add a focused regression test that runs the checker with `min_similarity_lines = 0` and asserts no `R0801`.

Candidate approaches:
1. Guard at the start of the similarity check (`close`/`_check_similarity`): return immediately when the option is `0`. Simplest and least likely to disturb positive-threshold behavior; cost is that line sets may still be collected.
2. Guard earlier, when collecting line sets: skip collection entirely when disabled. More efficient, but must ensure checker state is still reset correctly between modules.
3. Change option validation to translate `0` into a disabled sentinel. More invasive and risks changing configuration semantics beyond the requested behavior.


# pylint/checkers/similar.py

```
# Copyright (c) 2006, 2008-2014 LOGILAB S.A. (Paris, FRANCE) <contact@logilab.fr>
# Copyright (c) 2012 Ry4an Brase <ry4an-hg@ry4an.org>
# Copyright (c) 2012 Google, Inc.
# Copyright (c) 2012 Anthony VEREZ <anthony.verez.external@cassidian.com>
# Copyright (c) 2014-2020 Claudiu Popa <pcmanticore@gmail.com>
# Copyright (c) 2014 Brett Cannon <brett@python.org>
# Copyright (c) 2014 Arun Persaud <arun@nubati.net>
# Copyright (c) 2015 Ionel Cristian Maries <contact@ionelmc.ro>
# Copyright (c) 2017, 2020 Anthony Sottile <asottile@umich.edu>
# Copyright (c) 2017 Mikhail Fesenko <proggga@gmail.com>
# Copyright (c) 2018 Scott Worley <scottworley@scottworley.com>
# Copyright (c) 2018 ssolanki <sushobhitsolanki@gmail.com>
# Copyright (c) 2019, 2021 Pierre Sassoulas <pierre.sassoulas@gmail.com>
# Copyright (c) 2019 Hugo van Kemenade <hugovk@users.noreply.github.com>
# Copyright (c) 2019 Taewon D. Kim <kimt33@mcmaster.ca>
# Copyright (c) 2020-2021 hippo91 <guillaume.peillex@gmail.com>
# Copyright (c) 2020 Frank Harrison <frank@doublethefish.com>
# Copyright (c) 2020 Eli Fine <ejfine@gmail.com>
# Copyright (c) 2020 Shiv Venkatasubrahmanyam <shvenkat@users.noreply.github.com>
# Copyright (c) 2021 Marc Mueller <30130371+cdce8p@users.noreply.github.com>
# Copyright (c) 2021 Maksym Humetskyi <Humetsky@gmail.com>
# Copyright (c) 2021 Daniël van Noord <13665637+DanielNoord@users.noreply.github.com>
# Copyright (c) 2021 bot <bot@noreply.github.com>
# Copyright (c) 2021 Aditya Gupta <adityagupta1089@users.noreply.github.com>

# Licensed under the GPL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
# For details: https://github.com/PyCQA/pylint/blob/main/LICENSE

# pylint: disable=redefined-builtin
"""a similarities / code duplication command line tool and pylint checker

The algorithm is based on comparing the hash value of n successive lines of a file.
First the files are read and any line that doesn't fullfill requirement are removed (comments, docstrings...)
Those stripped lines are stored in the LineSet class which gives access to them.
Then each index of the stripped lines collection is associated with the hash of n successive entries of the stripped lines starting at the current index
(n is the minimum common lines option).
The common hashes between both linesets are then looked for. If there are matches, then the match indices in both linesets are stored and associated
with the corresponding couples (start line number/end line number) in both files.
This association is then postprocessed to handle the case of successive matches. For example if the minimum common lines setting is set to four, then
the hashes are computed with four lines. If one of match indices couple (12, 34) is the successor of another one (11, 33) then it means that there are
in fact five lines wich are common.
Once postprocessed the values of association table are the result looked for, i.e start and end lines numbers of common lines in both files.
"""
import copy
import functools
import itertools
import operator
import re
import sys
from collections import defaultdict
from getopt import getopt
from itertools import chain, groupby
from typing import (
    Any,
    Dict,
    FrozenSet,
    Generator,
    Iterable,
    List,
    NamedTuple,
    NewType,
    Set,
    TextIO,
    Tuple,
)

import astroid
from astroid import nodes

from pylint.checkers import BaseChecker, MapReduceMixin, table_lines_from_stats
from pylint.interfaces import IRawChecker
from pylint.reporters.ureports.nodes import Table
from pylint.utils import decoding_stream

DEFAULT_MIN_SIMILARITY_LINE = 4

REGEX_FOR_LINES_WITH_CONTENT = re.compile(r".*\w+")

# Index defines a location in a LineSet stripped lines collection
Index = NewType("Index", int)

# LineNumber defines a location in a LinesSet real lines collection (the whole file lines)
LineNumber = NewType("LineNumber", int)


# LineSpecifs holds characteristics of a line in a file
class LineSpecifs(NamedTuple):
    line_number: LineNumber
    text: str


# Links LinesChunk object to the starting indices (in lineset's stripped lines)
# of the different chunk of lines that are used to compute the hash
HashToIndex_T = Dict["LinesChunk", List[Index]]

# Links index in the lineset's stripped lines to the real lines in the file
IndexToLines_T = Dict[Index, "SuccessiveLinesLimits"]


class CplSuccessiveLinesLimits:
    """
    This class holds a couple of SuccessiveLinesLimits objects, one for each file compared,
    and a counter on the number of common lines between both stripped lines collections extracted
    from both files
    """

    __slots__ = ("first_file", "second_file", "effective_cmn_lines_nb")

    def __init__(
        self,
        first_file: "SuccessiveLinesLimits",
        second_file: "SuccessiveLinesLimits",
        effective_cmn_lines_nb: int,
    ) -> None:
        self.first_file = first_file
        self.second_file = second_file
        self.effective_cmn_lines_nb = effective_cmn_lines_nb


# Links the indices ot the starting line in both lineset's stripped lines to
# the start and end lines in both files
CplIndexToCplLines_T = Dict["LineSetStartCouple", CplSuccessiveLinesLimits]


class LinesChunk:
    """
    The LinesChunk object computes and stores the hash of some consecutive stripped lines of a lineset.
    """

    __slots__ = ("_fileid", "_index", "_hash")

    def __init__(self, fileid: str, num_line: int, *lines: Iterable[str]) -> None:
        self._fileid: str = fileid
        """The name of the file from which the LinesChunk object is generated """

        self._index: Index = Index(num_line)
        """The index in the stripped lines that is the starting of consecutive lines"""

        self._hash: int = sum(hash(lin) for lin in lines)
        """The hash of some consecutive lines"""

    def __eq__(self, o: Any) -> bool:
        if not isinstance(o, LinesChunk):
            return NotImplemented
        return self._hash == o._hash

    def __hash__(self) -> int:
        return self._hash

    def __repr__(self) -> str:
        return (
            f"<LinesChunk object for file {self._fileid} ({self._index}, {self._hash})>"
        )

    def __str__(self) -> str:
        return (
            f"LinesChunk object for file {self._fileid}, starting at line {self._index} \n"
            f"Hash is {self._hash}"
        )


class SuccessiveLinesLimits:
    """
    A class to handle the numbering of begin and end of successive lines.

    :note: Only the end line number can be updated.
    """

    __slots__ = ("_start", "_end")

    def __init__(self, start: LineNumber, end: LineNumber) -> None:
        self._start: LineNumber = start
        self._end: LineNumber = end

    @property
    def start(self) -> LineNumber:
        return self._start

    @property
    def end(self) -> LineNumber:
        return self._end

    @end.setter
    def end(self, value: LineNumber) -> None:
        self._end = value

    def __repr__(self) -> str:
        return f"<SuccessiveLinesLimits <{self._start};{self._end}>>"


class LineSetStartCouple(NamedTuple):
    """
    Indices in both linesets that mark the beginning of successive lines
    """

    fst_lineset_index: Index
    snd_lineset_index: Index

    def __repr__(self) -> str:
        return (
            f"<LineSetStartCouple <{self.fst_lineset_index};{self.snd_lineset_index}>>"
        )

    def __eq__(self, other) -> bool:
        if not isinstance(other, LineSetStartCouple):
            return NotImplemented
        return (
            self.fst_lineset_index == other.fst_lineset_index
            and self.snd_lineset_index == other.snd_lineset_index
        )

    def __hash__(self) -> int:
        return hash(self.fst_lineset_index) + hash(self.snd_lineset_index)

    def increment(self, value: Index) -> "LineSetStartCouple":
        return LineSetStartCouple(
            Index(self.fst_lineset_index + value),
            Index(self.snd_lineset_index + value),
        )


LinesChunkLimits_T = Tuple["LineSet", LineNumber, LineNumber]


def hash_lineset(
    lineset: "LineSet", min_common_lines: int = DEFAULT_MIN_SIMILARITY_LINE
) -> Tuple[HashToIndex_T, IndexToLines_T]:
    """
    Return two dicts. The first associates the hash of successive stripped lines of a lineset
    to the indices of the starting lines.
    The second dict, associates the index of the starting line in the lineset's stripped lines to the
    couple [start, end] lines number in the corresponding file.

    :param lineset: lineset object (i.e the lines in a file)
    :param min_common_lines: number of successive lines that are used to compute the hash
    :return: a dict linking hashes to corresponding start index and a dict that links this
             index to the start and end lines in the file
    """
    hash2index = defaultdict(list)
    index2lines = {}
    # Comments, docstring and other specific patterns maybe excluded -> call to stripped_lines
    # to get only what is desired
    lines = tuple(x.text for x in lineset.stripped_lines)
    # Need different iterators on same lines but each one is shifted 1 from the precedent
    shifted_lines = [iter(lines[i:]) for i in range(min_common_lines)]

    for index_i, *succ_lines in enumerate(zip(*shifted_lines)):
        start_linenumber = lineset.stripped_lines[index_i].line_number
        try:
            end_linenumber = lineset.stripped_lines[
                index_i + min_common_lines
            ].line_number
        except IndexError:
            end_linenumber = lineset.stripped_lines[-1].line_number + 1

        index = Index(index_i)
        index2lines[index] = SuccessiveLinesLimits(
            start=LineNumber(start_linenumber), end=LineNumber(end_linenumber)
        )

        l_c = LinesChunk(lineset.name, index, *succ_lines)
        hash2index[l_c].append(index)

    return hash2index, index2lines


def remove_successives(all_couples: CplIndexToCplLines_T) -> None:
    """
    Removes all successive entries in the dictionary in argument

    :param all_couples: collection that has to be cleaned up from successives entries.
                        The keys are couples of indices that mark the beginning of common entries
                        in both linesets. The values have two parts. The first one is the couple
                        of starting and ending line numbers of common successives lines in the first file.
                        The second part is the same for the second file.

    For example consider the following dict:

    >>> all_couples
    {(11, 34): ([5, 9], [27, 31]),
     (23, 79): ([15, 19], [45, 49]),
     (12, 35): ([6, 10], [28, 32])}

    There are two successives keys (11, 34) and (12, 35).
    It means there are two consecutive similar chunks of lines in both files.
    Thus remove last entry and update the last line numbers in the first entry

    >>> remove_successives(all_couples)
    >>> all_couples
    {(11, 34): ([5, 10], [27, 32]),
     (23, 79): ([15, 19], [45, 49])}
    """
    couple: LineSetStartCouple
    for couple in tuple(all_couples.keys()):
        to_remove = []
        test = couple.increment(Index(1))
        while test in all_couples:
            all_couples[couple].first_file.end = all_couples[test].first_file.end
            all_couples[couple].second_file.end = all_couples[test].second_file.end
            all_couples[couple].effective_cmn_lines_nb += 1
            to_remove.append(test)
            test = test.increment(Index(1))

        for target in to_remove:
            try:
                all_couples.pop(target)
            except KeyError:
                pass


def filter_noncode_lines(
    ls_1: "LineSet",
    stindex_1: Index,
    ls_2: "LineSet",
    stindex_2: Index,
    common_lines_nb: int,
) -> int:
    """
    Return the effective number of common lines between lineset1 and lineset2 filtered from non code lines, that is to say the number of
    common successive stripped lines except those that do not contain code (for example a ligne with only an
    ending parathensis)

    :param ls_1: first lineset
    :param stindex_1: first lineset starting index
    :param ls_2: second lineset
    :param stindex_2: second lineset starting index
    :param common_lines_nb: number of common successive stripped lines before being filtered from non code lines
    :return: the number of common successives stripped lines that contain code
    """
    stripped_l1 = [
        lspecif.text
        for lspecif in ls_1.stripped_lines[stindex_1 : stindex_1 + common_lines_nb]
        if REGEX_FOR_LINES_WITH_CONTENT.match(lspecif.text)
    ]
    stripped_l2 = [
        lspecif.text
        for lspecif in ls_2.stripped_lines[stindex_2 : stindex_2 + common_lines_nb]
        if REGEX_FOR_LINES_WITH_CONTENT.match(lspecif.text)
    ]
    return sum(sline_1 == sline_2 for sline_1, sline_2 in zip(stripped_l1, stripped_l2))


class Commonality(NamedTuple):
    cmn_lines_nb: int
    fst_lset: "LineSet"
    fst_file_start: LineNumber
    fst_file_end: LineNumber
    snd_lset: "LineSet"
    snd_file_start: LineNumber
    snd_file_end: LineNumber


class Similar:
    """finds copy-pasted lines of code in a project"""

    def __init__(
        self,
        min_lines: int = DEFAULT_MIN_SIMILARITY_LINE,
        ignore_comments: bool = False,
        ignore_docstrings: bool = False,
        ignore_imports: bool = False,
        ignore_signatures: bool = False,
    ) -> None:
        self.min_lines = min_lines
        self.ignore_comments = ignore_comments
        self.ignore_docstrings = ignore_docstrings
        self.ignore_imports = ignore_imports
        self.ignore_signatures = ignore_signatures
        self.linesets: List["LineSet"] = []

    def append_stream(self, streamid: str, stream: TextIO, encoding=None) -> None:
        """append a file to search for similarities"""
        if encoding is None:
            readlines = stream.readlines
        else:
            readlines = decoding_stream(stream, encoding).readlines
        try:
            self.linesets.append(
                LineSet(
                    streamid,
                    readlines(),
                    self.ignore_comments,
                    self.ignore_docstrings,
                    self.ignore_imports,
                    self.ignore_signatures,
                )
            )
        except UnicodeDecodeError:
            pass

    def run(self) -> None:
        """start looking for similarities and display results on stdout"""
        self._display_sims(self._compute_sims())

    def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:
        """compute similarities in appended files"""
        no_duplicates: Dict[int, List[Set[LinesChunkLimits_T]]] = defaultdict(list)

        for commonality in self._iter_sims():
            num = commonality.cmn_lines_nb
            lineset1 = commonality.fst_lset
            start_line_1 = commonality.fst_file_start
            end_line_1 = commonality.fst_file_end
            lineset2 = commonality.snd_lset
            start_line_2 = commonality.snd_file_start
            end_line_2 = commonality.snd_file_end

            duplicate = no_duplicates[num]
            couples: Set[LinesChunkLimits_T]
            for couples in duplicate:
                if (lineset1, start_line_1, end_line_1) in couples or (
                    lineset2,
                    start_line_2,
                    end_line_2,
                ) in couples:
                    break
            else:
                duplicate.append(
                    {
                        (lineset1, start_line_1, end_line_1),
                        (lineset2, start_line_2, end_line_2),
                    }
                )
        sims: List[Tuple[int, Set[LinesChunkLimits_T]]] = []
        ensembles: List[Set[LinesChunkLimits_T]]
        for num, ensembles in no_duplicates.items():
            cpls: Set[LinesChunkLimits_T]
            for cpls in ensembles:
                sims.append((num, cpls))
        sims.sort()
        sims.reverse()
        return sims

    def _display_sims(
        self, similarities: List[Tuple[int, Set[LinesChunkLimits_T]]]
    ) -> None:
        """Display computed similarities on stdout"""
        report = self._get_similarity_report(similarities)
        print(report)

    def _get_similarity_report(
        self, similarities: List[Tuple[int, Set[LinesChunkLimits_T]]]
    ) -> str:
        """Create a report from similarities"""
        report: str = ""
        duplicated_line_number: int = 0
        for number, couples in similarities:
            report += f"\n{number} similar lines in {len(couples)} files\n"
            couples_l = sorted(couples)
            line_set = start_line = end_line = None
            for line_set, start_line, end_line in couples_l:
                report += f"=={line_set.name}:[{start_line}:{end_line}]\n"
            if line_set:
                for line in line_set._real_lines[start_line:end_line]:
                    report += f"   {line.rstrip()}\n" if line.rstrip() else "\n"
            duplicated_line_number += number * (len(couples_l) - 1)
        total_line_number: int = sum(len(lineset) for lineset in self.linesets)
        report += f"TOTAL lines={total_line_number} duplicates={duplicated_line_number} percent={duplicated_line_number * 100.0 / total_line_number:.2f}\n"
        return report

    def _find_common(
        self, lineset1: "LineSet", lineset2: "LineSet"
    ) -> Generator[Commonality, None, None]:
        """
        Find similarities in the two given linesets.

        This the core of the algorithm.
        The idea is to compute the hashes of a minimal number of successive lines of each lineset and then compare the hashes.
        Every match of such comparison is stored in a dict that links the couple of starting indices in both linesets to
        the couple of corresponding starting and ending lines in both files.
        Last regroups all successive couples in a bigger one. It allows to take into account common chunk of lines that have more
        than the minimal number of successive lines required.
        """
        hash_to_index_1: HashToIndex_T
        hash_to_index_2: HashToIndex_T
        index_to_lines_1: IndexToLines_T
        index_to_lines_2: IndexToLines_T
        hash_to_index_1, index_to_lines_1 = hash_lineset(lineset1, self.min_lines)
        hash_to_index_2, index_to_lines_2 = hash_lineset(lineset2, self.min_lines)

        hash_1: FrozenSet[LinesChunk] = frozenset(hash_to_index_1.keys())
        hash_2: FrozenSet[LinesChunk] = frozenset(hash_to_index_2.keys())

        common_hashes: Iterable[LinesChunk] = sorted(
            hash_1 & hash_2, key=lambda m: hash_to_index_1[m][0]
        )

        # all_couples is a dict that links the couple of indices in both linesets that mark the beginning of
        # successive common lines, to the corresponding starting and ending number lines in both files
        all_couples: CplIndexToCplLines_T = {}

        for c_hash in sorted(common_hashes, key=operator.attrgetter("_index")):
            for indices_in_linesets in itertools.product(
                hash_to_index_1[c_hash], hash_to_index_2[c_hash]
            ):
                index_1 = indices_in_linesets[0]
                index_2 = indices_in_linesets[1]
                all_couples[
                    LineSetStartCouple(index_1, index_2)
                ] = CplSuccessiveLinesLimits(
                    copy.copy(index_to_lines_1[index_1]),
                    copy.copy(index_to_lines_2[index_2]),
                    effective_cmn_lines_nb=self.min_lines,
                )

        remove_successives(all_couples)

        for cml_stripped_l, cmn_l in all_couples.items():
            start_index_1 = cml_stripped_l.fst_lineset_index
            start_index_2 = cml_stripped_l.snd_lineset_index
            nb_common_lines = cmn_l.effective_cmn_lines_nb

            com = Commonality(
                cmn_lines_nb=nb_common_lines,
                fst_lset=lineset1,
                fst_file_start=cmn_l.first_file.start,
                fst_file_end=cmn_l.first_file.end,
                snd_lset=lineset2,
                snd_file_start=cmn_l.second_file.start,
                snd_file_end=cmn_l.second_file.end,
            )

            eff_cmn_nb = filter_noncode_lines(
                lineset1, start_index_1, lineset2, start_index_2, nb_common_lines
            )

            if eff_cmn_nb > self.min_lines:
                yield com

    def _iter_sims(self) -> Generator[Commonality, None, None]:
        """iterate on similarities among all files, by making a cartesian
        product
        """
        for idx, lineset in enumerate(self.linesets[:-1]):
            for lineset2 in self.linesets[idx + 1 :]:
                yield from self._find_common(lineset, lineset2)

    def get_map_data(self):
        """Returns the data we can use for a map/reduce process

        In this case we are returning this instance's Linesets, that is all file
        information that will later be used for vectorisation.
        """
        return self.linesets

    def combine_mapreduce_data(self, linesets_collection):
        """Reduces and recombines data into a format that we can report on

        The partner function of get_map_data()"""
        self.linesets = [line for lineset in linesets_collection for line in lineset]


def stripped_lines(
    lines: Iterable[str],
    ignore_comments: bool,
    ignore_docstrings: bool,
    ignore_imports: bool,
    ignore_signatures: bool,
) -> List[LineSpecifs]:
    """
    Return tuples of line/line number/line type with leading/trailing whitespace and any ignored code features removed

    :param lines: a collection of lines
    :param ignore_comments: if true, any comment in the lines collection is removed from the result
    :param ignore_docstrings: if true, any line that is a docstring is removed from the result
    :param ignore_imports: if true, any line that is an import is removed from the result
    :param ignore_signatures: if true, any line that is part of a function signature is removed from the result
    :return: the collection of line/line number/line type tuples
    """
    if ignore_imports or ignore_signatures:
        tree = astroid.parse("".join(lines))
    if ignore_imports:
        node_is_import_by_lineno = (
            (node.lineno, isinstance(node, (nodes.Import, nodes.ImportFrom)))
            for node in tree.body
        )
        line_begins_import = {
            lineno: all(is_import for _, is_import in node_is_import_group)
            for lineno, node_is_import_group in groupby(
                node_is_import_by_lineno, key=lambda x: x[0]
            )
        }
        current_line_is_import = False
    if ignore_signatures:

        def _get_functions(
            functions: List[nodes.NodeNG], tree: nodes.NodeNG
        ) -> List[nodes.NodeNG]:
            """Recursively get all functions including nested in the classes from the tree."""

            for node in tree.body:
                if isinstance(node, (nodes.FunctionDef, nodes.AsyncFunctionDef)):
                    functions.append(node)

                if isinstance(
                    node,
                    (nodes.ClassDef, nodes.FunctionDef, nodes.AsyncFunctionDef),
                ):
                    _get_functions(functions, node)

            return functions

        functions = _get_functions([], tree)
        signature_lines = set(
            chain(
                *(
                    range(
                        func.lineno,
                        func.body[0].lineno if func.body else func.tolineno + 1,
                    )
                    for func in functions
                )
            )
        )

    strippedlines = []
    docstring = None
    for lineno, line in enumerate(lines, start=1):
        line = line.strip()
        if ignore_docstrings:
            if not docstring:
                if line.startswith('"""') or line.startswith("'''"):
                    docstring = line[:3]
                    line = line[3:]
                elif line.startswith('r"""') or line.startswith("r'''"):
                    docstring = line[1:4]
                    line = line[4:]
            if docstring:
                if line.endswith(docstring):
                    docstring = None
                line = ""
        if ignore_imports:
            current_line_is_import = line_begins_import.get(
                lineno, current_line_is_import
            )
            if current_line_is_import:
                line = ""
        if ignore_comments:
            line = line.split("#", 1)[0].strip()
        if ignore_signatures and lineno in signature_lines:
            line = ""
        if line:
            strippedlines.append(
                LineSpecifs(text=line, line_number=LineNumber(lineno - 1))
            )
    return strippedlines


@functools.total_ordering
class LineSet:
    """
    Holds and indexes all the lines of a single source file.
    Allows for correspondance between real lines of the source file and stripped ones, which
    are the real ones from which undesired patterns have been removed.
    """

    def __init__(
        self,
        name,
        lines,
        ignore_comments=False,
        ignore_docstrings=False,
        ignore_imports=False,
        ignore_signatures=False,
    ) -> None:
        self.name = name
        self._real_lines = lines
        self._stripped_lines = stripped_lines(
            lines, ignore_comments, ignore_docstrings, ignore_imports, ignore_signatures
        )

    def __str__(self):
        return f"<Lineset for {self.name}>"

    def __len__(self):
        return len(self._real_lines)

    def __getitem__(self, index):
        return self._stripped_lines[index]

    def __lt__(self, other):
        return self.name < other.name

    def __hash__(self):
        return id(self)

    def __eq__(self, other):
        if not isinstance(other, LineSet):
            return False
        return self.__dict__ == other.__dict__

    @property
    def stripped_lines(self):
        return self._stripped_lines

    @property
    def real_lines(self):
        return self._real_lines


MSGS = {
    "R0801": (
        "Similar lines in %s files\n%s",
        "duplicate-code",
        "Indicates that a set of similar lines has been detected "
        "among multiple file. This usually means that the code should "
        "be refactored to avoid this duplication.",
    )
}


def report_similarities(sect, stats, old_stats):
    """make a layout with some stats about duplication"""
    lines = ["", "now", "previous", "difference"]
    lines += table_lines_from_stats(
        stats, old_stats, ("nb_duplicated_lines", "percent_duplicated_lines")
    )
    sect.append(Table(children=lines, cols=4, rheaders=1, cheaders=1))


# wrapper to get a pylint checker from the similar class
class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
    """checks for similarities and duplicated code. This computation may be
    memory / CPU intensive, so you should disable it if you experiment some
    problems.
    """

    __implements__ = (IRawChecker,)
    # configuration section name
    name = "similarities"
    # messages
    msgs = MSGS
    # configuration options
    # for available dict keys/values see the optik parser 'add_option' method
    options = (
        (
            "min-similarity-lines",
            {
                "default": DEFAULT_MIN_SIMILARITY_LINE,
                "type": "int",
                "metavar": "<int>",
                "help": "Minimum lines number of a similarity.",
            },
        ),
        (
            "ignore-comments",
            {
                "default": True,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Comments are removed from the similarity computation",
            },
        ),
        (
            "ignore-docstrings",
            {
                "default": True,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Docstrings are removed from the similarity computation",
            },
        ),
        (
            "ignore-imports",
            {
                "default": False,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Imports are removed from the similarity computation",
            },
        ),
        (
            "ignore-signatures",
            {
                "default": False,
                "type": "yn",
                "metavar": "<y or n>",
                "help": "Signatures are removed from the similarity computation",
            },
        ),
    )
    # reports
    reports = (("RP0801", "Duplication", report_similarities),)

    def __init__(self, linter=None) -> None:
        BaseChecker.__init__(self, linter)
        Similar.__init__(
            self,
            min_lines=self.config.min_similarity_lines,
            ignore_comments=self.config.ignore_comments,
            ignore_docstrings=self.config.ignore_docstrings,
            ignore_imports=self.config.ignore_imports,
            ignore_signatures=self.config.ignore_signatures,
        )
        self.stats = None

    def set_option(self, optname, value, action=None, optdict=None):
        """method called to set an option (registered in the options list)

        Overridden to report options setting to Similar
        """
        BaseChecker.set_option(self, optname, value, action, optdict)
        if optname == "min-similarity-lines":
            self.min_lines = self.config.min_similarity_lines
        elif optname == "ignore-comments":
            self.ignore_comments = self.config.ignore_comments
        elif optname == "ignore-docstrings":
            self.ignore_docstrings = self.config.ignore_docstrings
        elif optname == "ignore-imports":
            self.ignore_imports = self.config.ignore_imports
        elif optname == "ignore-signatures":
            self.ignore_signatures = self.config.ignore_signatures

    def open(self):
        """init the checkers: reset linesets and statistics information"""
        self.linesets = []
        self.stats = self.linter.add_stats(
            nb_duplicated_lines=0, percent_duplicated_lines=0
        )

    def process_module(self, node):
        """process a module

        the module's content is accessible via the stream object

        stream must implement the readlines method
        """
        with node.stream() as stream:
            self.append_stream(self.linter.current_name, stream, node.file_encoding)

    def close(self):
        """compute and display similarities on closing (i.e. end of parsing)"""
        total = sum(len(lineset) for lineset in self.linesets)
        duplicated = 0
        stats = self.stats
        for num, couples in self._compute_sims():
            msg = []
            lineset = start_line = end_line = None
            for lineset, start_line, end_line in couples:
                msg.append(f"=={lineset.name}:[{start_line}:{end_line}]")
            msg.sort()

            if lineset:
                for line in lineset.real_lines[start_line:end_line]:
                    msg.append(line.rstrip())

            self.add_message("R0801", args=(len(couples), "\n".join(msg)))
            duplicated += num * (len(couples) - 1)
        stats["nb_duplicated_lines"] = duplicated
        stats["percent_duplicated_lines"] = total and duplicated * 100.0 / total

    def get_map_data(self):
        """Passthru override"""
        return Similar.get_map_data(self)

    def reduce_map_data(self, linter, data):
        """Reduces and recombines data into a format that we can report on

        The partner function of get_map_data()"""
        recombined = SimilarChecker(linter)
        recombined.min_lines = self.min_lines
        recombined.ignore_comments = self.ignore_comments
        recombined.ignore_docstrings = self.ignore_docstrings
        recombined.ignore_imports = self.ignore_imports
        recombined.ignore_signatures = self.ignore_signatures
        recombined.open()
        Similar.combine_mapreduce_data(recombined, linesets_collection=data)
        recombined.close()


def register(linter):
    """required method to auto register this checker"""
    linter.register_checker(SimilarChecker(linter))


def usage(status=0):
    """display command line usage information"""
    print("finds copy pasted blocks in a set of files")
    print()
    print(
        "Usage: symilar [-d|--duplicates min_duplicated_lines] \
[-i|--ignore-comments] [--ignore-docstrings] [--ignore-imports] [--ignore-signatures] file1..."
    )
    sys.exit(status)


def Run(argv=None):
    """standalone command line access point"""
    if argv is None:
        argv = sys.argv[1:]

    s_opts = "hdi"
    l_opts = (
        "help",
        "duplicates=",
        "ignore-comments",
        "ignore-imports",
        "ignore-docstrings",
        "ignore-signatures",
    )
    min_lines = DEFAULT_MIN_SIMILARITY_LINE
    ignore_comments = False
    ignore_docstrings = False
    ignore_imports = False
    ignore_signatures = False
    opts, args = getopt(argv, s_opts, l_opts)
    for opt, val in opts:
        if opt in ("-d", "--duplicates"):
            min_lines = int(val)
        elif opt in ("-h", "--help"):
            usage()
        elif opt in ("-i", "--ignore-comments"):
            ignore_comments = True
        elif opt in ("--ignore-docstrings",):
            ignore_docstrings = True
        elif opt in ("--ignore-imports",):
            ignore_imports = True
        elif opt in ("--ignore-signatures",):
            ignore_signatures = True
    if not args:
        usage(1)
    sim = Similar(
        min_lines, ignore_comments, ignore_docstrings, ignore_imports, ignore_signatures
    )
    for filename in args:
        with open(filename, encoding="utf-8") as stream:
            sim.append_stream(filename, stream)
    sim.run()
    sys.exit(0)


if __name__ == "__main__":
    Run()

```


# tests/checkers (the files in it)

tests/checkers/__init__.py
tests/checkers/conftest.py
tests/checkers/unittest_base.py
tests/checkers/unittest_classes.py
tests/checkers/unittest_deprecated.py
tests/checkers/unittest_design.py
tests/checkers/unittest_exceptions.py
tests/checkers/unittest_format.py
tests/checkers/unittest_imports.py
tests/checkers/unittest_logging.py
tests/checkers/unittest_misc.py
tests/checkers/unittest_refactoring.py
tests/checkers/unittest_similar.py
tests/checkers/unittest_spelling.py
tests/checkers/unittest_stdlib.py
tests/checkers/unittest_strings.py
tests/checkers/unittest_typecheck.py
tests/checkers/unittest_utils.py
tests/checkers/unittest_variables.py


# The last commit

```
7300d5d4 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest tests/checkers/unittest_similar.py -q
..................                                                       [100%]
=============================== warnings summary ===============================
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90: DeprecationWarning: The 'astroid.node_classes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26: DeprecationWarning: The 'astroid.scoped_nodes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/warnings.html
18 passed, 3 warnings in 0.31s
scope: pylint/checkers/similar.py tests/checkers
changed: pylint/checkers/similar.py +6 -1
changed: tests/checkers/unittest_similar.py +9 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/pylint/checkers/similar.py b/pylint/checkers/similar.py
index c65b1c89..e9b75f19 100644
--- a/pylint/checkers/similar.py
+++ b/pylint/checkers/similar.py
@@ -394,6 +394,10 @@ class Similar:
 
     def _compute_sims(self) -> List[Tuple[int, Set[LinesChunkLimits_T]]]:
         """compute similarities in appended files"""
+        if self.min_lines <= 0:
+            # A minimum of zero (or less) lines means the check is disabled.
+            return []
+
         no_duplicates: Dict[int, List[Set[LinesChunkLimits_T]]] = defaultdict(list)
 
         for commonality in self._iter_sims():
@@ -739,7 +743,8 @@ class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
                 "default": DEFAULT_MIN_SIMILARITY_LINE,
                 "type": "int",
                 "metavar": "<int>",
-                "help": "Minimum lines number of a similarity.",
+                "help": "Minimum lines number of a similarity. "
+                "If set to 0, disable the duplicate code check.",
             },
         ),
         (
diff --git a/tests/checkers/unittest_similar.py b/tests/checkers/unittest_similar.py
index 4ddf2029..59618f58 100644
--- a/tests/checkers/unittest_similar.py
+++ b/tests/checkers/unittest_similar.py
@@ -339,6 +339,15 @@ TOTAL lines=62 duplicates=5 percent=8.06
     )
 
 
+def test_min_similarity_lines_zero_disables_check() -> None:
+    output = StringIO()
+    with redirect_stdout(output), pytest.raises(SystemExit) as ex:
+        similar.Run(["--duplicates=0", SIMILAR1, SIMILAR2])
+    assert ex.value.code == 0
+    assert "similar lines in" not in output.getvalue()
+    assert "duplicates=0" in output.getvalue()
+
+
 def test_lines_without_meaningful_content_do_not_trigger_similarity() -> None:
     output = StringIO()
     with redirect_stdout(output), pytest.raises(SystemExit) as ex:
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
check: python -m pytest tests/checkers/unittest_similar.py -q
..................                                                       [100%]
=============================== warnings summary ===============================
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90: DeprecationWarning: The 'astroid.node_classes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26: DeprecationWarning: The 'astroid.scoped_nodes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/warnings.html
18 passed, 3 warnings in 0.17s
scope: pylint/checkers/similar.py tests/checkers
changed: pylint/checkers/similar.py +6 -1
changed: tests/checkers/unittest_similar.py +9 -0
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
# Notes, run 2026-11-06T125624

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Setting `min-similarity-lines` to `0` should stop pylint from checking duplicate code
### Current problem

Setting `min-similarity-lines` to `0` in the rcfile doesn't disable checking for duplicate code, it instead treats every line of code as duplicate and raises many errors.

### Desired solution

Setting `min-similarity-lines` to `0` should disable the duplicate code check.

It works that way in many other linters (like flake8). Setting a numerical value in flake8 to `0` (e.g. `max-line-length`) disables that check.

### Additional context

#214 requests being able to disable `R0801`, but it is still open


# The files of the project

```
.copyrite_aliases
.coveragerc
.flake8
.github/CONTRIBUTING.md
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/BUG-REPORT.yml
.github/ISSUE_TEMPLATE/FEATURE-REQUEST.yml
.github/ISSUE_TEMPLATE/QUESTION.yml
.github/ISSUE_TEMPLATE/config.yml
.github/PULL_REQUEST_TEMPLATE.md
.github/SECURITY.md
.github/dependabot.yml
.github/workflows/ci.yaml
.github/workflows/codeql-analysis.yml
.github/workflows/release.yml
.gitignore
.pre-commit-config.yaml
.pre-commit-hooks.yaml
.readthedocs.yaml
CONTRIBUTORS.txt
ChangeLog
Dockerfile
LICENSE
MANIFEST.in
README.rst
doc/Makefile
doc/backlinks.rst
doc/conf.py
doc/development_guide/contribute.rst
doc/development_guide/index.rst
doc/exts/pylint_extensions.py
doc/exts/pylint_features.py
doc/faq.rst
doc/how_tos/custom_checkers.rst
doc/how_tos/index.rst
doc/how_tos/plugins.rst
doc/how_tos/transform_plugins.rst
doc/index.rst
doc/intro.rst
doc/logo.png
doc/logo.svg
doc/make.bat
doc/media/Tidelift_Logos_RGB_Tidelift_Shorthand_On-White.png
doc/media/Tidelift_Logos_RGB_Tidelift_Shorthand_On-White_small.png
doc/release.md
doc/requirements.txt
doc/support.rst
doc/technical_reference/c_extensions.rst
doc/technical_reference/checkers.rst
doc/technical_reference/index.rst
doc/technical_reference/startup.rst
doc/tutorial.rst
doc/user_guide/ide-integration.rst
doc/user_guide/index.rst
doc/user_guide/installation.rst
doc/user_guide/message-control.rst
doc/user_guide/options.rst
doc/user_guide/output.rst
doc/user_guide/run.rst
doc/whatsnew/1.6.rst
doc/whatsnew/1.7.rst
doc/whatsnew/1.8.rst
doc/whatsnew/1.9.rst
doc/whatsnew/2.0.rst
doc/whatsnew/2.1.rst
doc/whatsnew/2.10.rst
doc/whatsnew/2.11.rst
doc/whatsnew/2.2.rst
doc/whatsnew/2.3.rst
doc/whatsnew/2.4.rst
doc/whatsnew/2.5.rst
doc/whatsnew/2.6.rst
doc/whatsnew/2.7.rst
doc/whatsnew/2.8.rst
doc/whatsnew/2.9.rst
doc/whatsnew/changelog.rst
doc/whatsnew/index.rst
elisp/pylint-flymake.el
elisp/pylint.el
elisp/startup
examples/custom.py
examples/custom_raw.py
examples/deprecation_checker.py
examples/pylintrc
examples/pylintrc_camelcase
pylint/__init__.py
pylint/__main__.py
pylint/__pkginfo__.py
pylint/checkers/__init__.py
pylint/checkers/async.py
pylint/checkers/base.py
pylint/checkers/base_checker.py
pylint/checkers/classes.py
pylint/checkers/deprecated.py
pylint/checkers/design_analysis.py
pylint/checkers/exceptions.py
pylint/checkers/format.py
pylint/checkers/imports.py
pylint/checkers/logging.py
pylint/checkers/mapreduce_checker.py
pylint/checkers/misc.py
pylint/checkers/newstyle.py
pylint/checkers/raw_metrics.py
pylint/checkers/refactoring/__init__.py
pylint/checkers/refactoring/len_checker.py
pylint/checkers/refactoring/not_checker.py
pylint/checkers/refactoring/recommendation_checker.py
pylint/checkers/refactoring/refactoring_checker.py
pylint/checkers/similar.py
pylint/checkers/spelling.py
pylint/checkers/stdlib.py
pylint/checkers/strings.py
pylint/checkers/typecheck.py
pylint/checkers/utils.py
pylint/checkers/variables.py
pylint/config/__init__.py
pylint/config/configuration_mixin.py
pylint/config/find_default_config_files.py
pylint/config/man_help_formatter.py
pylint/config/option.py
pylint/config/option_manager_mixin.py
pylint/config/option_parser.py
pylint/config/options_provider_mixin.py
pylint/constants.py
pylint/epylint.py
pylint/exceptions.py
pylint/extensions/__init__.py
pylint/extensions/_check_docs_utils.py
pylint/extensions/bad_builtin.py
pylint/extensions/bad_builtin.rst
pylint/extensions/broad_try_clause.py
pylint/extensions/check_docs.py
pylint/extensions/check_elif.py
pylint/extensions/code_style.py
pylint/extensions/code_style.rst
pylint/extensions/comparetozero.py
pylint/extensions/confusing_elif.py
pylint/extensions/consider_ternary_expression.py
pylint/extensions/docparams.py
pylint/extensions/docparams.rst
pylint/extensions/docstyle.py
pylint/extensions/empty_comment.py
pylint/extensions/emptystring.py
pylint/extensions/mccabe.py
pylint/extensions/mccabe.rst
pylint/extensions/overlapping_exceptions.py
pylint/extensions/redefined_variable_type.py
pylint/extensions/set_membership.py
pylint/extensions/typing.py
pylint/extensions/typing.rst
pylint/extensions/while_used.py
pylint/graph.py
pylint/interfaces.py
pylint/lint/__init__.py
pylint/lint/expand_modules.py
pylint/lint/parallel.py
pylint/lint/pylinter.py
pylint/lint/report_functions.py
pylint/lint/run.py
pylint/lint/utils.py
pylint/message/__init__.py
pylint/message/message.py
pylint/message/message_definition.py
pylint/message/message_definition_store.py
pylint/message/message_handler_mix_in.py
pylint/message/message_id_store.py
pylint/pyreverse/__init__.py
pylint/pyreverse/diadefslib.py
pylint/pyreverse/diagrams.py
pylint/pyreverse/dot_printer.py
pylint/pyreverse/inspector.py
pylint/pyreverse/main.py
pylint/pyreverse/plantuml_printer.py
pylint/pyreverse/printer.py
pylint/pyreverse/printer_factory.py
pylint/pyreverse/utils.py
pylint/pyreverse/vcg_printer.py
pylint/pyreverse/writer.py
pylint/reporters/__init__.py
pylint/reporters/base_reporter.py
pylint/reporters/collecting_reporter.py
pylint/reporters/json_reporter.py
pylint/reporters/multi_reporter.py
pylint/reporters/reports_handler_mix_in.py
pylint/reporters/text.py
pylint/reporters/ureports/__init__.py
pylint/reporters/ureports/nodes.py
pylint/reporters/ureports/text_writer.py
pylint/testutils/__init__.py
pylint/testutils/checker_test_case.py
pylint/testutils/constants.py
pylint/testutils/decorator.py
pylint/testutils/functional_test_file.py
pylint/testutils/get_test_info.py
pylint/testutils/global_test_linter.py
pylint/testutils/lint_module_test.py
pylint/testutils/output_line.py
pylint/testutils/reporter_for_tests.py
pylint/testutils/tokenize_str.py
pylint/testutils/unittest_linter.py
pylint/utils/__init__.py
pylint/utils/ast_walker.py
pylint/utils/file_state.py
pylint/utils/pragma_parser.py
pylint/utils/utils.py
pylintrc
requirements_test.txt
requirements_test_min.txt
requirements_test_pre_commit.txt
script/__init__.py
script/bump_changelog.py
script/fix_documentation.py
setup.cfg
setup.py
tbump.toml
tests/acceptance/test_stdlib.py
tests/benchmark/test_baseline_benchmarks.py
tests/checkers/__init__.py
tests/checkers/conftest.py
tests/checkers/unittest_base.py
tests/checkers/unittest_classes.py
tests/checkers/unittest_deprecated.py
tests/checkers/unittest_design.py
tests/checkers/unittest_exceptions.py
tests/checkers/unittest_format.py
tests/checkers/unittest_imports.py
tests/checkers/unittest_logging.py
tests/checkers/unittest_misc.py
tests/checkers/unittest_refactoring.py
tests/checkers/unittest_similar.py
tests/checkers/unittest_spelling.py
tests/checkers/unittest_stdlib.py
tests/checkers/unittest_strings.py
tests/checkers/unittest_typecheck.py
tests/checkers/unittest_utils.py
tests/checkers/unittest_variables.py
tests/conftest.py
tests/data/__init__.py
tests/data/ascript
tests/data/clientmodule_test.py
tests/data/suppliermodule_test.py
tests/extensions/__init__.py
tests/extensions/data/bad_builtin.py
tests/extensions/data/broad_try_clause.py
tests/extensions/data/compare_to_zero.py
tests/extensions/data/docstring.py
tests/extensions/data/elif.py
tests/extensions/data/empty_comment.py
tests/extensions/data/empty_string_comparison.py
tests/extensions/data/mccabe.py
tests/extensions/data/overlapping_exceptions.py
tests/extensions/data/overlapping_exceptions_py33.py
tests/extensions/data/redefined.py
tests/extensions/test_bad_builtin.py
tests/extensions/test_broad_try_clause.py
tests/extensions/test_check_docs.py
tests/extensions/test_check_docs_utils.py
tests/extensions/test_check_mccabe.py
tests/extensions/test_check_raise_docs.py
tests/extensions/test_check_return_docs.py
tests/extensions/test_check_yields_docs.py
tests/extensions/test_comparetozero.py
tests/extensions/test_confusing_elif.py
tests/extensions/test_docstyle.py
tests/extensions/test_elseif_used.py
tests/extensions/test_empty_comment.py
tests/extensions/test_emptystring.py
tests/extensions/test_overlapping_exceptions.py
tests/extensions/test_redefined.py
tests/extensions/test_while_used.py
tests/functional/__init__.py
tests/functional/a/__init__.py
tests/functional/a/abstract/abstract_abc_methods.py
tests/functional/a/abstract/abstract_class_instantiated.py
tests/functional/a/abstract/abstract_class_instantiated.txt
tests/functional/a/abstract/abstract_class_instantiated_in_class.py
tests/functional/a/abstract/abstract_method.py
tests/functional/a/abstract/abstract_method.txt
tests/functional/a/access/access_attr_before_def_false_positive.py
tests/functional/a/access/access_member_before_definition.py
tests/functional/a/access/access_member_before_definition.txt
tests/functional/a/access/access_to__name__.py
tests/functional/a/access/access_to__name__.txt
tests/functional/a/access/access_to_protected_members.py
tests/functional/a/access/access_to_protected_members.txt
tests/functional/a/access/access_to_protected_members_typing.py
tests/functional/a/access/access_to_protected_members_typing.rc
tests/functional/a/access/access_to_protected_members_typing.txt
tests/functional/a/alternative/alternative_union_syntax.py
tests/functional/a/alternative/alternative_union_syntax.rc
tests/functional/a/alternative/alternative_union_syntax_error.py
tests/functional/a/alternative/alternative_union_syntax_error.rc
tests/functional/a/alternative/alternative_union_syntax_error.txt
tests/functional/a/alternative/alternative_union_syntax_py37.py
tests/functional/a/alternative/alternative_union_syntax_py37.rc
tests/functional/a/alternative/alternative_union_syntax_py37.txt
tests/functional/a/anomalous_backslash_escape.py
tests/functional/a/anomalous_backslash_escape.txt
tests/functional/a/anomalous_unicode_escape.py
tests/functional/a/anomalous_unicode_escape.txt
tests/functional/a/arguments.py
tests/functional/a/arguments.rc
tests/functional/a/arguments.txt
tests/functional/a/arguments_differ.py
tests/functional/a/arguments_differ.txt
tests/functional/a/arguments_out_of_order.py
tests/functional/a/arguments_out_of_order.txt
tests/functional/a/arguments_renamed.py
tests/functional/a/arguments_renamed.txt
tests/functional/a/assert_on_string_literal.py
tests/functional/a/assert_on_string_literal.txt
tests/functional/a/assert_on_tuple.py
tests/functional/a/assert_on_tuple.txt
tests/functional/a/assign/assigning_non_slot.py
tests/functional/a/assign/assigning_non_slot.txt
tests/functional/a/assign/assigning_non_slot_4509.py
tests/functional/a/assign/assigning_non_slot_4509.rc
tests/functional/a/assign/assigning_non_slot_4509.txt
tests/functional/a/assign/assignment_expression.py
tests/functional/a/assign/assignment_expression.rc
tests/functional/a/assign/assignment_expression.txt
tests/functional/a/assign/assignment_from_no_return.py
tests/functional/a/assign/assignment_from_no_return.txt
tests/functional/a/assign/assignment_from_no_return_2.py
tests/functional/a/assign/assignment_from_no_return_2.txt
tests/functional/a/assign/assignment_from_no_return_py3.py
tests/functional/a/async_functions.py
tests/functional/a/async_functions.txt
tests/functional/a/attribute_defined_outside_init.py
tests/functional/a/attribute_defined_outside_init.txt
tests/functional/a/await_outside_async.py
tests/functional/a/await_outside_async.rc
tests/functional/a/await_outside_async.txt
tests/functional/b/__init__.py
tests/functional/b/bad_except_order.py
tests/functional/b/bad_except_order.txt
tests/functional/b/bad_exception_context.py
tests/functional/b/bad_exception_context.txt
tests/functional/b/bad_indentation.py
tests/functional/b/bad_indentation.txt
tests/functional/b/bad_inline_option.py
tests/functional/b/bad_inline_option.rc
tests/functional/b/bad_inline_option.txt
tests/functional/b/bad_open_mode.py
tests/functional/b/bad_open_mode.rc
tests/functional/b/bad_open_mode.txt
tests/functional/b/bad_option_value.py
tests/functional/b/bad_option_value.txt
tests/functional/b/bad_reversed_sequence.py
tests/functional/b/bad_reversed_sequence.txt
tests/functional/b/bad_reversed_sequence_py37.py
tests/functional/b/bad_reversed_sequence_py37.rc
tests/functional/b/bad_reversed_sequence_py37.txt
tests/functional/b/bad_reversed_sequence_py38.py
tests/functional/b/bad_reversed_sequence_py38.rc
tests/functional/b/bad_staticmethod_argument.py
tests/functional/b/bad_staticmethod_argument.txt
tests/functional/b/bad_thread_instantiation.py
tests/functional/b/bad_thread_instantiation.txt
tests/functional/b/bare_except.py
tests/functional/b/bare_except.txt
tests/functional/b/base_init_vars.py
tests/functional/b/blacklisted_name.py
tests/functional/b/blacklisted_name.txt
tests/functional/b/broad_except.py
tests/functional/b/broad_except.txt
tests/functional/b/bugfix_local_scope_metaclass_1177.py
tests/functional/b/builtin_module_test.py
tests/functional/c/__init__.py
tests/functional/c/cached_property.py
tests/functional/c/cached_property.rc
tests/functional/c/cached_property.txt
tests/functional/c/cellvar_escaping_loop.py
tests/functional/c/cellvar_escaping_loop.txt
tests/functional/c/class_attributes.py
tests/functional/c/class_members.py
tests/functional/c/class_members_py30.py
tests/functional/c/class_members_py30.txt
tests/functional/c/class_scope.py
tests/functional/c/class_scope.txt
tests/functional/c/class_variable_slots_conflict_exempted.py
tests/functional/c/classes_meth_could_be_a_function.py
tests/functional/c/classes_protected_member_access.py
tests/functional/c/comparison_with_callable.py
tests/functional/c/comparison_with_callable.txt
tests/functional/c/condition_evals_to_constant.py
tests/functional/c/condition_evals_to_constant.txt
tests/functional/c/confidence_filter.py
tests/functional/c/confidence_filter.rc
tests/functional/c/confidence_filter.txt
tests/functional/c/confusing_with_statement.py
tests/functional/c/confusing_with_statement.txt
tests/functional/c/consider/consider_iterating_dictionary.py
tests/functional/c/consider/consider_iterating_dictionary.txt
tests/functional/c/consider/consider_join.py
tests/functional/c/consider/consider_join.txt
tests/functional/c/consider/consider_merging_isinstance.py
tests/functional/c/consider/consider_merging_isinstance.txt
tests/functional/c/consider/consider_swap_variables.py
tests/functional/c/consider/consider_swap_variables.txt
tests/functional/c/consider/consider_using_dict_comprehension.py
tests/functional/c/consider/consider_using_dict_comprehension.txt
tests/functional/c/consider/consider_using_dict_items.py
tests/functional/c/consider/consider_using_dict_items.txt
tests/functional/c/consider/consider_using_enumerate.py
tests/functional/c/consider/consider_using_enumerate.txt
tests/functional/c/consider/consider_using_f_string.py
tests/functional/c/consider/consider_using_f_string.txt
tests/functional/c/consider/consider_using_generator.py
tests/functional/c/consider/consider_using_generator.txt
tests/functional/c/consider/consider_using_get.py
tests/functional/c/consider/consider_using_get.txt
tests/functional/c/consider/consider_using_in.py
tests/functional/c/consider/consider_using_in.txt
tests/functional/c/consider/consider_using_min_max_builtin.py
tests/functional/c/consider/consider_using_min_max_builtin.txt
tests/functional/c/consider/consider_using_set_comprehension.py
tests/functional/c/consider/consider_using_set_comprehension.txt
tests/functional/c/consider/consider_using_sys_exit.py
tests/functional/c/consider/consider_using_sys_exit.txt
tests/functional/c/consider/consider_using_sys_exit_exempted.py
tests/functional/c/consider/consider_using_sys_exit_local_scope.py
tests/functional/c/consider/consider_using_with.py
tests/functional/c/consider/consider_using_with.txt
tests/functional/c/consider/consider_using_with_open.py
tests/functional/c/consider/consider_using_with_open.rc
tests/functional/c/consider/consider_using_with_open.txt
tests/functional/c/continue_in_finally.py
tests/functional/c/continue_in_finally.rc
tests/functional/c/continue_in_finally.txt
tests/functional/c/control_pragmas.py
tests/functional/c/crash_missing_module_type.py
tests/functional/c/ctor_arguments.py
tests/functional/c/ctor_arguments.txt
tests/functional/d/__init__.py
tests/functional/d/dangerous_default_value.py
tests/functional/d/dangerous_default_value.txt
tests/functional/d/dataclass_with_default_factory.py
tests/functional/d/dataclass_with_default_factory.rc
tests/functional/d/dataclass_with_default_factory.txt
tests/functional/d/dataclass_with_field.py
tests/functional/d/dataclass_with_field.rc
tests/functional/d/dataclass_with_field.txt
tests/functional/d/decorator_scope.py
tests/functional/d/decorator_unused.py
tests/functional/d/defined_and_used_on_same_line.py
tests/functional/d/deprecated/dataclass_typecheck.py
tests/functional/d/deprecated/dataclass_typecheck.rc
tests/functional/d/deprecated/dataclass_typecheck.txt
tests/functional/d/deprecated/deprecated_class_py33.py
tests/functional/d/deprecated/deprecated_class_py33.rc
tests/functional/d/deprecated/deprecated_class_py33.txt
tests/functional/d/deprecated/deprecated_decorators.py
tests/functional/d/deprecated/deprecated_decorators.txt
tests/functional/d/deprecated/deprecated_method_getmoduleinfo.py
tests/functional/d/deprecated/deprecated_method_getmoduleinfo.rc
tests/functional/d/deprecated/deprecated_method_getmoduleinfo.txt
tests/functional/d/deprecated/deprecated_methods_py3.py
tests/functional/d/deprecated/deprecated_methods_py3.rc
tests/functional/d/deprecated/deprecated_methods_py3.txt
tests/functional/d/deprecated/deprecated_methods_py36.py
tests/functional/d/deprecated/deprecated_methods_py36.txt
tests/functional/d/deprecated/deprecated_methods_py38.py
tests/functional/d/deprecated/deprecated_methods_py38.rc
tests/functional/d/deprecated/deprecated_methods_py38.txt
tests/functional/d/deprecated/deprecated_module_py3.py
tests/functional/d/deprecated/deprecated_module_py3.rc
tests/functional/d/deprecated/deprecated_module_py3.txt
tests/functional/d/deprecated/deprecated_module_py36.py
tests/functional/d/deprecated/deprecated_module_py36.txt
tests/functional/d/deprecated/deprecated_module_py4.py
tests/functional/d/deprecated/deprecated_module_py4.rc
tests/functional/d/deprecated/deprecated_module_py4.txt
tests/functional/d/deprecated/deprecated_module_uninstalled.py
tests/functional/d/deprecated/deprecated_module_uninstalled.rc
tests/functional/d/deprecated/deprecated_module_uninstalled.txt
tests/functional/d/deprecated/deprecated_relative_import/__init__.py
tests/functional/d/deprecated/deprecated_relative_import/dot_relative_import.py
tests/functional/d/deprecated/deprecated_relative_import/dot_relative_import.txt
tests/functional/d/deprecated/deprecated_relative_import/subpackage/__init__.py
tests/functional/d/deprecated/deprecated_relative_import/subpackage/dot_dot_relative_import.py
tests/functional/d/deprecated/deprecated_relative_import/subpackage/dot_dot_relative_import.txt
tests/functional/d/dict_iter_missing_items.py
tests/functional/d/dict_iter_missing_items.txt
tests/functional/d/disable_msg_github_issue_1389.py
tests/functional/d/disable_msg_next_line.py
tests/functional/d/disable_msg_next_line.txt
tests/functional/d/disable_ungrouped_imports.py
tests/functional/d/disable_ungrouped_imports.txt
tests/functional/d/disable_wrong_import_order.py
tests/functional/d/disable_wrong_import_order.txt
tests/functional/d/disable_wrong_import_position.py
tests/functional/d/disabled_msgid_in_pylintrc.py
tests/functional/d/disabled_msgid_in_pylintrc.rc
tests/functional/d/docstrings.py
tests/functional/d/docstrings.txt
tests/functional/d/dotted_ancestor.py
tests/functional/d/dotted_ancestor.txt
tests/functional/d/duplicate_argument_name.py
tests/functional/d/duplicate_argument_name.txt
tests/functional/d/duplicate_argument_name_py3.py
tests/functional/d/duplicate_argument_name_py3.txt
tests/functional/d/duplicate_bases.py
tests/functional/d/duplicate_bases.txt
tests/functional/d/duplicate_dict_literal_key.py
tests/functional/d/duplicate_dict_literal_key.txt
tests/functional/d/duplicate_except.py
tests/functional/d/duplicate_except.txt
tests/functional/d/duplicate_string_formatting_argument.py
tests/functional/d/duplicate_string_formatting_argument.txt
tests/functional/e/__init__.py
tests/functional/e/e1101_9588_base_attr_aug_assign.py
tests/functional/e/enum_subclasses.py
tests/functional/e/eval_used.py
tests/functional/e/eval_used.txt
tests/functional/e/exception_is_binary_op.py
tests/functional/e/exception_is_binary_op.txt
tests/functional/e/excess_escapes.py
tests/functional/e/excess_escapes.txt
tests/functional/e/exec_used.py
tests/functional/e/exec_used.txt
tests/functional/e/external_classmethod_crash.py
tests/functional/ext/bad_builtins.py
tests/functional/ext/bad_builtins.rc
tests/functional/ext/bad_builtins.txt
tests/functional/ext/code_style/code_style_consider_using_assignment_expr.py
tests/functional/ext/code_style/code_style_consider_using_assignment_expr.rc
tests/functional/ext/code_style/code_style_consider_using_assignment_expr.txt
tests/functional/ext/code_style/code_style_consider_using_namedtuple_or_dataclass.py
tests/functional/ext/code_style/code_style_consider_using_namedtuple_or_dataclass.rc
tests/functional/ext/code_style/code_style_consider_using_namedtuple_or_dataclass.txt
tests/functional/ext/code_style/code_style_consider_using_tuple.py
tests/functional/ext/code_style/code_style_consider_using_tuple.rc
tests/functional/ext/code_style/code_style_consider_using_tuple.txt
tests/functional/ext/confusing_elif.py
tests/functional/ext/confusing_elif.rc
tests/functional/ext/confusing_elif.txt
tests/functional/ext/consider_ternary_expression.py
tests/functional/ext/consider_ternary_expression.rc
tests/functional/ext/consider_ternary_expression.txt
tests/functional/ext/docparams.py
tests/functional/ext/docparams.rc
tests/functional/ext/docparams.txt
tests/functional/ext/set_membership/set_membership_use_set_membership.py
tests/functional/ext/set_membership/set_membership_use_set_membership.rc
tests/functional/ext/set_membership/set_membership_use_set_membership.txt
tests/functional/ext/typing/typing_consider_using_alias.py
tests/functional/ext/typing/typing_consider_using_alias.rc
tests/functional/ext/typing/typing_consider_using_alias.txt
tests/functional/ext/typing/typing_consider_using_alias_without_future.py
tests/functional/ext/typing/typing_consider_using_alias_without_future.rc
tests/functional/ext/typing/typing_consider_using_alias_without_future.txt
tests/functional/ext/typing/typing_consider_using_union.py
tests/functional/ext/typing/typing_consider_using_union.rc
tests/functional/ext/typing/typing_consider_using_union.txt
tests/functional/ext/typing/typing_consider_using_union_py310.py
tests/functional/ext/typing/typing_consider_using_union_py310.rc
tests/functional/ext/typing/typing_consider_using_union_py310.txt
tests/functional/ext/typing/typing_consider_using_union_without_future.py
tests/functional/ext/typing/typing_consider_using_union_without_future.rc
tests/functional/ext/typing/typing_consider_using_union_without_future.txt
tests/functional/ext/typing/typing_deprecated_alias.py
tests/functional/ext/typing/typing_deprecated_alias.rc
tests/functional/ext/typing/typing_deprecated_alias.txt
tests/functional/ext/while_used.py
tests/functional/ext/while_used.rc
tests/functional/ext/while_used.txt
tests/functional/f/__init__.py
tests/functional/f/f_string_without_interpolation.py
tests/functional/f/f_string_without_interpolation.txt
tests/functional/f/fallback_import_disabled.py
tests/functional/f/fallback_import_enabled.py
tests/functional/f/fallback_import_enabled.rc
tests/functional/f/fallback_import_enabled.txt
tests/functional/f/first_arg.py
tests/functional/f/first_arg.txt
tests/functional/f/fixme.py
tests/functional/f/fixme.rc
tests/functional/f/fixme.txt
tests/functional/f/fixme_bad_formatting_1139.py
tests/functional/f/fixme_bad_formatting_1139.rc
tests/functional/f/fixme_bad_formatting_1139.txt
tests/functional/f/forgotten_debug_statement_py37.py
tests/functional/f/forgotten_debug_statement_py37.rc
tests/functional/f/forgotten_debug_statement_py37.txt
tests/functional/f/formatted_string_literal_with_if.py
tests/functional/f/func_disable_linebased.py
tests/functional/f/func_disable_linebased.txt
tests/functional/f/function_redefined.py
tests/functional/f/function_redefined.txt
tests/functional/f/function_redefined_2540.py
tests/functional/f/function_redefined_2540.rc
tests/functional/f/future_import.py
tests/functional/f/future_unicode_literals.py
tests/functional/f/future_unicode_literals.rc
tests/functional/f/future_unicode_literals.txt
tests/functional/g/__init__.py
tests/functional/g/generated_members.py
tests/functional/g/generated_members.rc
tests/functional/g/generated_members.txt
```


# The last commit

```
7300d5d4 SWE-bench


```

```diff

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest tests/checkers/unittest_similar.py -q`

## Scope
`pylint/checkers/similar.py`
`tests/checkers/`

## Done when
Setting `min-similarity-lines = 0` causes the duplicate-code checker to emit no `R0801` messages.
The duplicate-code checker does not treat every line as duplicate when `min-similarity-lines` is `0`.
Positive `min-similarity-lines` values still perform duplicate-code detection as before.

## Approach
Find every use of `config.min_similarity_lines` in `SimilarChecker` and short-circuit the duplicate-code comparison when it is `0`, before any line-set pair can be treated as matching. Add a focused regression test that runs the checker with `min_similarity_lines = 0` and asserts no `R0801`.

Candidate approaches:
1. Guard at the start of the similarity check (`close`/`_check_similarity`): return immediately when the option is `0`. Simplest and least likely to disturb positive-threshold behavior; cost is that line sets may still be collected.
2. Guard earlier, when collecting line sets: skip collection entirely when disabled. More efficient, but must ensure checker state is still reset correctly between modules.
3. Change option validation to translate `0` into a disabled sentinel. More invasive and risks changing configuration semantics beyond the requested behavior.
```

### `prompt.md`

```
Setting `min-similarity-lines` to `0` should stop pylint from checking duplicate code
### Current problem

Setting `min-similarity-lines` to `0` in the rcfile doesn't disable checking for duplicate code, it instead treats every line of code as duplicate and raises many errors.

### Desired solution

Setting `min-similarity-lines` to `0` should disable the duplicate code check.

It works that way in many other linters (like flake8). Setting a numerical value in flake8 to `0` (e.g. `max-line-length`) disables that check.

### Additional context

#214 requests being able to disable `R0801`, but it is still open
```

### `review.md`

```
verdict: PASS

- The guard added to `Similar._compute_sims` returns an empty result when `min_lines <= 0`, so no `R0801` similarity groups are produced; the summary still reports `duplicates=0`, which is what the new test asserts.
- Positive `min_lines` values are untouched: the early return only triggers for zero or negative values, so existing detection behaviour is preserved (the pre-existing similarity tests still pass).
- The added test in `tests/checkers/unittest_similar.py` drives the CLI with `--duplicates=0` and confirms no "similar lines in" output plus a `duplicates=0` summary, matching the Done-when condition.
- The documented check `python -m pytest tests/checkers/unittest_similar.py -q` reports `18 passed`, and both changed files lie within the stated scope; the help-text update is a harmless clarification.
- No unrelated behaviour, files, or content were removed.
```

### `scope.txt`

```
scope: pylint/checkers/similar.py tests/checkers
changed: pylint/checkers/similar.py +6 -1
changed: tests/checkers/unittest_similar.py +9 -0
```

### `task.md`

```
# Task

## Prompt

Setting `min-similarity-lines` to `0` should stop pylint from checking duplicate code
### Current problem

Setting `min-similarity-lines` to `0` in the rcfile doesn't disable checking for duplicate code, it instead treats every line of code as duplicate and raises many errors.

### Desired solution

Setting `min-similarity-lines` to `0` should disable the duplicate code check.

It works that way in many other linters (like flake8). Setting a numerical value in flake8 to `0` (e.g. `max-line-length`) disables that check.

### Additional context

#214 requests being able to disable `R0801`, but it is still open

## Deliverable

changes to this tree

## Check

`python -m pytest tests/checkers/unittest_similar.py -q`

## Scope

`pylint/checkers/similar.py`
`tests/checkers/`

## Done when

Setting `min-similarity-lines = 0` causes the duplicate-code checker to emit no `R0801` messages.
The duplicate-code checker does not treat every line as duplicate when `min-similarity-lines` is `0`.
Positive `min-similarity-lines` values still perform duplicate-code detection as before.
```

### `test-output.log`

```
check: python -m pytest tests/checkers/unittest_similar.py -q
..................                                                       [100%]
=============================== warnings summary ===============================
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/interpreter/_import/util.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/node_classes.py:90: DeprecationWarning: The 'astroid.node_classes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/astroid/scoped_nodes.py:26: DeprecationWarning: The 'astroid.scoped_nodes' module is deprecated and will be replaced by 'astroid.nodes' in astroid 3.0.0
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/warnings.html
18 passed, 3 warnings in 0.10s
scope: pylint/checkers/similar.py tests/checkers
changed: pylint/checkers/similar.py +6 -1
changed: tests/checkers/unittest_similar.py +9 -0
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
