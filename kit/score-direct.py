#!/usr/bin/env python3
"""score-direct.py: would a decision model have told a right direct attempt from a wrong one?

For every instance whose direct attempt passed test-0, the decision model
scores one condition over what the run had at that moment: the task, what
the Check printed for the attempt (direct-check.log), and the review's
findings. The label is SWE-bench's: resolved or not. The output is the
probability per instance and, over the set, how many right attempts a
threshold would keep and how many wrong ones it would let through.

Evidence only, never a diff, unless --with-diff: the decision model scores
what the reviewer and the Check laid out (Hightouch, 2026-11-04: more
context did not help the decision models). --with-diff adds the head of
direct.patch so the two can be compared.

    export MEMDOOR_TOKEN=...   # a gateway account token
    python3 kit/score-direct.py --gateway http://localhost:18809 --ids astropy__astropy-13033 astropy__astropy-12907
    python3 kit/score-direct.py --gateway http://localhost:18809 --n 2          # 2 right, 2 wrong
    python3 kit/score-direct.py --gateway http://localhost:18809 --all -o scores.jsonl

Reads <run>/trajs/<instance>.md (the run folder's files are sections there)
and <run>/results/results.json. One decision call per instance, about
$0.00002 each.
"""
import argparse, glob, json, os, re, sys, urllib.request

RUN = "20261106_memdoor-team-solve_deepseek-v4.1-flash"
CONDITION = ("Judging from the task, what the Check printed for this attempt and the reviewer's findings, "
             "the attempt resolves the issue the task describes, completely and nothing else, and needs no further work.")
MAX_LOG = 4000     # the tail of the Check's output: its verdict is at the end
MAX_REVIEW = 3000
MAX_TASK = 3500    # the Prompt and the Check line are at the top of task.md
MAX_DIFF = 3000


def files_of(path):
    txt = open(path, encoding="utf-8", errors="replace").read()
    out = {}
    for m in re.finditer(r"^### `([^`]+)`\n\n```[^\n]*\n(.*?)\n```", txt, re.S | re.M):
        out.setdefault(m.group(1), m.group(2))
    return out


def head(s, n):
    return s if len(s) <= n else s[:n] + "\n[…]"


def tail(s, n):
    return s if len(s) <= n else "[…]\n" + s[-n:]


def state_of(f, with_diff):
    parts = ["# The task\n\n" + head(f.get("task.md", ""), MAX_TASK),
             "# What the Check printed for this attempt (status " + f.get("direct-status.txt", "?").strip() + "; 0 passed)\n\n" + tail(f.get("direct-check.log", ""), MAX_LOG),
             "# The reviewer's findings\n\n" + head(f.get("review.md", "(no review)"), MAX_REVIEW)]
    if with_diff:
        parts.append("# The attempt's change\n\n```diff\n" + head(f.get("direct.patch", f.get("changes.diff", "")), MAX_DIFF) + "\n```")
    return "\n\n".join(parts)


def decide(gateway, token, state):
    body = json.dumps({"state": state, "questions": {"resolves": {"type": "boolean", "instructions": CONDITION}},
                       "options": {"purpose": "score-direct", "timeoutMs": 20000}}).encode()
    req = urllib.request.Request(gateway.rstrip("/") + "/api/decisions/evaluate", data=body,
                                 headers={"Content-Type": "application/json", "Authorization": "Bearer " + token})
    with urllib.request.urlopen(req, timeout=30) as r:
        res = json.load(r)
    if res.get("status") != "ok":
        raise RuntimeError(res.get("reason", "unavailable") + ": " + str(res.get("detail", "")))
    ans = res["result"]["answers"]["resolves"]
    return float(ans.get("probabilityTrue", ans.get("probability_true", ans.get("p", -1))))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", default=RUN)
    ap.add_argument("--gateway", default=os.environ.get("MEMDOOR_GATEWAY", "http://localhost:18789"))
    ap.add_argument("--token", default=os.environ.get("MEMDOOR_TOKEN", ""))
    ap.add_argument("--ids", nargs="*", default=[])
    ap.add_argument("--n", type=int, default=0, help="score the first N right and N wrong attempts")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--with-diff", action="store_true")
    ap.add_argument("-o", "--out", default="")
    a = ap.parse_args()
    if not a.token:
        sys.exit("a gateway token: --token or MEMDOOR_TOKEN")
    resolved = set(json.load(open(os.path.join(a.run, "results", "results.json")))["resolved"])
    right, wrong = [], []
    trajs = {}
    for p in sorted(glob.glob(os.path.join(a.run, "trajs", "*.md"))):
        inst = os.path.basename(p)[:-3]
        f = files_of(p)
        if f.get("direct-status.txt", "").strip() != "0":
            continue
        trajs[inst] = f
        (right if inst in resolved else wrong).append(inst)
    if a.ids:
        todo = a.ids
    elif a.all:
        todo = right + wrong
    elif a.n:
        todo = right[:a.n] + wrong[:a.n]
    else:
        sys.exit(f"{len(right)} right and {len(wrong)} wrong direct attempts passed test-0; say --ids, --n or --all")
    out = open(a.out, "a") if a.out else None
    rows = []
    for inst in todo:
        f = trajs.get(inst)
        if f is None:
            print(f"{inst}: not an attempt that passed test-0", file=sys.stderr)
            continue
        label = inst in resolved
        try:
            p = decide(a.gateway, a.token, state_of(f, a.with_diff))
        except Exception as e:
            print(f"{inst}: {e}", file=sys.stderr)
            continue
        row = {"instance": inst, "resolved": label, "p": round(p, 3), "with_diff": a.with_diff}
        rows.append(row)
        print(f"{inst:40s} resolved={str(label):5s} p={p:.2f}")
        if out:
            out.write(json.dumps(row) + "\n")
            out.flush()
    if len(rows) >= 4:
        print("\nthreshold  right kept   wrong let through")
        for t in (0.5, 0.6, 0.7, 0.8, 0.9):
            rk = sum(1 for r in rows if r["resolved"] and r["p"] >= t)
            rn = sum(1 for r in rows if r["resolved"])
            wk = sum(1 for r in rows if not r["resolved"] and r["p"] >= t)
            wn = sum(1 for r in rows if not r["resolved"])
            print(f"   {t:.1f}     {rk:3d}/{rn:<3d}        {wk:3d}/{wn:<3d}")


if __name__ == "__main__":
    main()
