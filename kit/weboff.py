"""weboff.py: no web tools for the bench (2026-11-06). `--once` after `memdoor setup` has seeded the agents and
before the workflow starts; then beside the workflow until the container goes: every 0.2 s it removes web_search and web_fetch from every agent's palette in
the gateway's database (the agents are seeded at the first sign-in; left to `workflow run`, a step read the palette
before the watch changed it: django-16938, 2026-11-06). web_fetch was refused by the proxy, but web_search is OpenRouter's own server-side search,
answered through openrouter.ai, the one host the proxy allows: in run 2 it returned upstream fixes.
Each change is a line on stdout; /tmp/weboff.ok is written at the first. The runner's check after the run reads
the tool list of every model request the gateway made: one that still offered a web tool stops the bench.
Plain Python 3.5+: it runs on the instance's own interpreter."""
import glob
import json
import sqlite3
import sys
import time

WEB = {"web_search", "web_fetch"}


def sweep():
    n = 0
    for path in glob.glob("/root/.memdoor/**/*.db", recursive=True):
        try:
            db = sqlite3.connect(path, timeout=5)
            rows = db.execute("SELECT id, name, tools FROM buddies").fetchall()
            for rid, name, tools in rows:
                try:
                    palette = json.loads(tools or "[]")
                except ValueError:
                    continue
                kept = [t for t in palette if t not in WEB]
                if len(kept) != len(palette):
                    db.execute("UPDATE buddies SET tools = ? WHERE id = ?", (json.dumps(kept), rid))
                    n += 1
                    print("%s weboff: %s: %s" % (time.strftime("%H:%M:%S"), name, ",".join(sorted(set(palette) & WEB))), flush=True)
            db.commit()
            db.close()
        except sqlite3.Error:
            continue
    return n


if sys.argv[1:] == ["--once"]:   # before the workflow: the agents are seeded; fail when there was nothing to change
    changed = sweep()
    if changed:
        open("/tmp/weboff.ok", "w").close()
    sys.exit(0 if changed else 1)
while True:
    if sweep():
        open("/tmp/weboff.ok", "w").close()
    time.sleep(0.2)
