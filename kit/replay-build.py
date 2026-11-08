#!/usr/bin/env python3
"""replay-build.py: the inputs of the read-only replay, from the published run.

For every direct attempt that passed test-0 (analysis/direct-scores/scores-evidence.jsonl: 381 right,
82 wrong), the test files it edited that existed on base. The replay runs those files in their original
form on base and with the attempt's change: a test that passes on base and fails with the change is an
old test the attempt broke, and hid by editing it. conftest.py and __init__.py are left out.

    python3 kit/replay-build.py --dataset verified.json --out replay/

Writes meta.json (per instance: resolved, the files, those the hidden test patch does not touch),
pred-base.json (a no-op patch: the harness skips an empty one) and pred-attempt.json (direct.patch
without its test files, as score2.sh submits it). Then kit/replay-rewrite.py on the scoring VM.
"""
import argparse, json, os, re, subprocess

RUN = "20261106_memdoor-team-solve_deepseek-v4.1-flash"
KIT = os.path.dirname(os.path.abspath(__file__))
NOOP = ("diff --git a/memdoor-replay-noop.txt b/memdoor-replay-noop.txt\nnew file mode 100644\n"
        "--- /dev/null\n+++ b/memdoor-replay-noop.txt\n@@ -0,0 +1 @@\n+noop\n")

ns = {}
exec(open(os.path.join(KIT, "strip-tests.py")).read().split("text = sys.stdin.read()")[0], ns)
is_test = ns["is_test"]


def files_of(path):
    txt = open(path, encoding="utf-8", errors="replace").read()
    out = {}
    for m in re.finditer(r"^### `([^`]+)`\n\n```[^\n]*\n(.*?)\n```", txt, re.S | re.M):
        out.setdefault(m.group(1), m.group(2))
    return out


def touched(patch, existing_only):
    out = []
    for b in re.split(r"(?m)^(?=diff --git )", patch):
        m = re.match(r"diff --git a/(\S+) b/(\S+)", b)
        if m and not (existing_only and re.search(r"(?m)^new file mode", b.split("@@")[0])):
            out.append(m.group(1))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", default=RUN)
    ap.add_argument("--evidence", default="analysis/direct-scores/scores-evidence.jsonl")
    ap.add_argument("--dataset", required=True, help="SWE-bench Verified as a JSON list")
    ap.add_argument("--out", default="replay")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    ds = {r["instance_id"]: r for r in json.load(open(a.dataset))}
    meta, base, att = [], [], []
    for l in open(a.evidence):
        e = json.loads(l)
        i = e["instance"]
        patch = files_of(os.path.join(a.run, "trajs", i + ".md")).get("direct.patch", "") + "\n"
        tests = [t for t in touched(patch, True) if is_test(t) and t.endswith(".py")
                 and t.rsplit("/", 1)[-1] not in ("conftest.py", "__init__.py")]
        if not tests:
            continue
        gold = set(touched(ds[i]["test_patch"], False))
        stripped = subprocess.run(["python3", "-I", os.path.join(KIT, "strip-tests.py")],
                                  input=patch, capture_output=True, text=True, check=True).stdout
        meta.append({"id": i, "resolved": e["resolved"], "tests": tests, "outside_gold": [t for t in tests if t not in gold]})
        base.append({"instance_id": i, "model_name_or_path": "replay-base", "model_patch": NOOP})
        att.append({"instance_id": i, "model_name_or_path": "replay-attempt", "model_patch": stripped})
    for name, v in (("meta", meta), ("pred-base", base), ("pred-attempt", att)):
        json.dump(v, open(os.path.join(a.out, name + ".json"), "w"))
    print(len(meta), "attempts,", sum(not m["resolved"] for m in meta), "wrong")


if __name__ == "__main__":
    main()
