#!/usr/bin/env python3
"""replay-rewrite.py: the replay's dataset, on the scoring VM.

The VM's ~/verified.json carries a prebuilt eval_script per instance, and the harness runs it as is:
a test_patch put in the row is ignored (it was, on the first try). So the script is rewritten. The
hidden test patch is not applied, the checkouts name the attempt's edited test files, and the test
command runs those files (Django's as test modules, the harness's own conversion). FAIL_TO_PASS and
PASS_TO_PASS are empty: the statuses are read from the logs by replay-parse.py. A row whose script
does not have the expected shape is left out and counted.

    R=~/replay python3 kit/replay-rewrite.py      # reads $R/meta.json, writes $R/ds.json
"""
import collections, json, os, re

R = os.path.expanduser(os.environ.get("R", "~/replay"))
NON_TEST = (".json", ".png", "csv", ".txt", ".md", ".jpg", ".jpeg", ".pkl", ".yml", ".yaml", ".toml")
H = "EOF_114329324912"
START, END = ": '>>>>> Start Test Output'\n", ": '>>>>> End Test Output'"


def directives(repo, files):
    out = [f for f in files if not f.endswith(NON_TEST)]
    if repo == "django/django":
        out = [(f[:-3] if f.endswith(".py") else f) for f in out]
        out = [(f[len("tests/"):] if f.startswith("tests/") else f).replace("/", ".") for f in out]
    return out


def main():
    v = {r["instance_id"]: r for r in json.load(open(os.path.expanduser("~/verified.json")))}
    rows, bad = [], collections.Counter()
    for m in json.load(open(os.path.join(R, "meta.json"))):
        r = dict(v[m["id"]])
        s, base = r["eval_script"], r["base_commit"]
        gold = re.findall(r"(?m)^diff --git a/\S+ b/(\S+)", r["test_patch"])
        a, b = s.index(START), s.index(END)
        block = s[a:b].split("\n")
        cmd = [k for k, l in enumerate(block) if l and not l.startswith(":") and "SWEBENCH_TEST_EXIT_CODE" not in l]
        if len(cmd) != 1:
            bad["test command"] += 1
            continue
        line, gd = block[cmd[0]], " ".join(directives(r["repo"], gold))
        if gd and not line.endswith(gd):
            bad["directives"] += 1
            continue
        prefix = line[: len(line) - len(gd)].rstrip() if gd else line.rstrip()
        block[cmd[0]] = prefix + " " + " ".join(directives(r["repo"], m["tests"]))
        s = s[:a] + "\n".join(block) + s[b:]
        old = "git checkout " + base + " " + " ".join(gold)
        if s.count(old) != 2:
            bad["checkout"] += 1
            continue
        s = s.replace(old, "git checkout " + base + " " + " ".join(m["tests"]))
        s, n = re.subn(r"git apply -v - <<'" + H + r"'\n.*?\n" + H + r"\n", "", s, flags=re.S)
        if n != 1:
            bad["test patch"] += 1
            continue
        r["eval_script"] = s
        r["FAIL_TO_PASS"] = r["PASS_TO_PASS"] = "[]" if isinstance(r["FAIL_TO_PASS"], str) else []
        rows.append(r)
    json.dump(rows, open(os.path.join(R, "ds.json"), "w"))
    print(len(rows), "rewritten", dict(bad))


if __name__ == "__main__":
    main()
