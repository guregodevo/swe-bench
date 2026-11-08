#!/usr/bin/env python3
"""replay-parse.py <batch> <id>...: one JSON line per instance, from the batch's two harness runs.

newfail: the tests that pass (or xfail) on base and do not with the attempt's change. The statuses
come from the harness's own log parser for the repository. Django's parser can read a test's
description line as a test of its own: the count is high there, the flag is not.
Runs with the harness's python (/opt/swe/bin/python).
"""
import json, os, sys

from swebench.harness.grading import PARSER_REGISTRY
from swebench.harness.utils import make_test_spec

R = os.path.expanduser(os.environ.get("R", "~/replay"))
LOGS = os.path.expanduser("~/logs/run_evaluation")
OK = ("PASSED", "XFAIL")

b, ids = sys.argv[1], sys.argv[2:]
ds = {r["instance_id"]: r for r in json.load(open(os.path.join(R, "ds.json")))}
meta = {m["id"]: m for m in json.load(open(os.path.join(R, "meta.json")))}
for i in ids:
    st = {}
    for v in ("base", "attempt"):
        p = f"{LOGS}/rp{b}-{v}/replay-{v}/{i}/test_output.txt"
        if os.path.exists(p):
            ts = make_test_spec(ds[i])
            st[v] = PARSER_REGISTRY[ts.log_parser](open(p, errors="replace").read(), ts)
    if len(st) != 2:
        print(json.dumps({"id": i, "resolved": meta[i]["resolved"], "error": "no output"}))
        continue
    newfail = sorted(t for t, s in st["base"].items() if s in OK and st["attempt"].get(t) not in OK)
    print(json.dumps({"id": i, "resolved": meta[i]["resolved"], "outside_gold": bool(meta[i]["outside_gold"]),
                      "base_passed": sum(s in OK for s in st["base"].values()), "attempt_tests": len(st["attempt"]),
                      "newfail": newfail}))
