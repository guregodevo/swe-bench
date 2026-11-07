#!/usr/bin/env python3
"""strip-tests.py < patch.diff > patch.diff: the model's patch without its changes to test files.
SWE-bench applies the hidden test patch on top of the model's: a test file the model adds at the same
path makes the hidden patch fail to apply (django-11749, django-16877, sphinx-8595, 2026-11-07), and an
edit inside a hunk the hidden patch touches can conflict. A test file is one with a directory named
test, tests, testing, __tests__ or spec on its path, or a file named test_*.*, *_test.*, *.test.* or
*_tests.*: a path rule, the same in every language. Only the submission changes; the run is untouched."""
import re, sys
TEST_DIRS = {"test", "tests", "testing", "__tests__", "spec", "specs"}
def is_test(path):
    parts = path.split("/")
    if any(p in TEST_DIRS for p in parts[:-1]):
        return True
    name = parts[-1]
    stem = name.rsplit(".", 1)[0] if "." in name else name
    return stem.startswith("test_") or stem.endswith("_test") or stem.endswith("_tests") or ".test." in name or stem.startswith("tests_")
text = sys.stdin.read()
blocks = re.split(r"(?m)^(?=diff --git )", text)
out = []
for b in blocks:
    m = re.match(r"diff --git a/(\S+) b/(\S+)", b)
    if m and (is_test(m.group(1)) or is_test(m.group(2))):
        continue
    out.append(b)
sys.stdout.write("".join(out))
