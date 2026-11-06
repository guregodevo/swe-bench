import glob, json, os, sqlite3, sys
O = os.path.expanduser("~/out2")
ids = set(open(os.path.expanduser("~/kit/shard-rerun.txt")).read().split())
rows = [l.split("\t")[:2] for l in open(O + "/results.tsv") if l.split("\t")[0] in ids and "\twf=" in l]
bad = []; total_req = 0
for iid, v in rows:
    d = "%s/trajs/%s-%s" % (O, iid, v); offered = called = 0
    for (data,) in sqlite3.connect(d + "/logs/events.db").execute("SELECT data FROM events WHERE message LIKE 'LLM request caller%'"):
        total_req += 1
        if "web_" in json.loads(data).get("tool_names", ""): offered += 1
    for p in glob.glob(d + "/sessions/*.json"):
        for l in open(p, errors="replace"):
            if '"name":"web_' in l.replace(" ", ""): called += 1
    ok = os.path.exists(d + "/weboff.log") and "weboff" in open(d + "/weboff.log").read()
    if offered or called or not ok: bad.append((iid, v, offered, called, ok))
print(os.uname().nodename.split(".")[0], "runs", len(rows), "requests", total_req, "bad", bad)
