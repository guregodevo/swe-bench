"""Collect run 2's evaluation logs and one reasoning trace per instance, per variant.

Runs on a bench VM. Writes ~/sub/<v>/eval/memdoor-<v>/<iid>/{patch.diff,report.json,
test_output.txt} (the batch whose patch.diff is run 2's patch) and ~/sub/<v>/trajs/<iid>.md.
"""
import glob
import json
import os
import shutil
import sys

H = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~")  # run under sudo: pass the bench user's home
O = f"{H}/out2"
EV = f"{H}/logs/run_evaluation"
CAP = 200_000  # bytes per run-folder file in a trace; agent sessions are never cut


def rows(path):
    out = {}
    for line in open(path):
        p = line.rstrip("\n").split("\t")
        if len(p) > 2 and p[2].startswith("wf="):
            out[(p[0], p[1])] = p
    return out


def text(path):
    b = open(path, "rb").read()
    s = b.decode("utf-8", "replace")
    if len(b) > CAP:
        s = s[:CAP] + f"\n\n[... {len(b) - CAP} more bytes of this file not shown ...]\n"
    return s


def fence(s):
    n = 3
    while "`" * n in s:
        n += 1
    return "`" * n


def block(s, lang=""):
    f = fence(s)
    return f"{f}{lang}\n{s.rstrip()}\n{f}\n"


def content_text(c):
    if isinstance(c, str):
        return c
    out = []
    for part in c or []:
        if part.get("type") == "text":
            out.append(part.get("text", ""))
        else:
            out.append(json.dumps(part))
    return "\n".join(out)


def render_session(path):
    md = []
    for line in open(path, encoding="utf-8", errors="replace"):
        if not line.strip():
            continue
        m = json.loads(line).get("message", {})
        role = m.get("role", "?")
        c = m.get("content")
        if isinstance(c, str):
            md.append(f"**{role}**\n\n{block(c)}")
            continue
        for part in c or []:
            t = part.get("type")
            if t == "text":
                md.append(f"**{role}**\n\n{block(part.get('text', ''))}")
            elif t == "thinking":
                md.append(f"**{role} (thinking)**\n\n{block(part.get('thinking', ''))}")
            elif t == "tool_use":
                md.append(f"**{role} → tool `{part.get('name')}`**\n\n{block(json.dumps(part.get('input'), indent=2, ensure_ascii=False), 'json')}")
            elif t == "tool_result":
                md.append(f"**tool result**\n\n{block(content_text(part.get('content')))}")
            else:
                md.append(f"**{role} ({t})**\n\n{block(json.dumps(part, ensure_ascii=False))}")
    return "\n".join(md)


def first_ts(path):
    for line in open(path, encoding="utf-8", errors="replace"):
        if line.strip():
            return json.loads(line).get("timestamp", 0)
    return 0


def trace(iid, v, row):
    md = [f"# {iid} — memdoor {'team-solve' if v == 'team' else 'single call'}\n",
          f"Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `{' '.join(row[2:])}`\n",
          "The agent received only the instance's `problem_statement`, in a container built from the "
          "instance's SWE-bench image, with network access to openrouter.ai only.\n"]
    wo = f"{O}/trajs/{iid}-{v}/weboff.log"
    if os.path.isfile(wo):
        md.append("Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, "
                  "so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were "
                  "discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools "
                  "before the workflow started. No model request of this run offered a web tool:\n")
        md.append(block(text(wo)))
    rd = sorted(glob.glob(f"{O}/runs/{iid}-{v}/*-20*T*"))
    sessions = glob.glob(f"{O}/trajs/{iid}-{v}/sessions/*.json")
    sessions.sort(key=lambda p: (first_ts(p), p))
    md.append("## Agent sessions, in order\n")
    if not sessions:
        md.append("(none)\n")
    for s in sessions:
        step = os.path.basename(s).rsplit("_", 1)[-1].removesuffix(".json")
        md.append(f"### Step `{step}` (agent)\n")
        md.append(render_session(s))
    for d in rd:
        md.append(f"## Run folder `{os.path.basename(d)}`\n")
        md.append("Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, "
                  "the patches, and the step that kept the final patch.\n")
        for f in sorted(os.listdir(d)):
            p = os.path.join(d, f)
            if os.path.isfile(p) and os.path.getsize(p) > 0:
                md.append(f"### `{f}`\n")
                md.append(block(text(p), "diff" if f.endswith((".diff", ".patch")) else ""))
    return "\n".join(md)


def main():
    res = rows(f"{O}/results.tsv")
    out = f"{H}/sub"
    shutil.rmtree(out, ignore_errors=True)
    miss = []
    for (iid, v), row in sorted(res.items()):
        mine = f"{O}/patches/{iid}-{v}.diff"
        patch = open(mine).read() if os.path.isfile(mine) else ""
        found = None
        for d in sorted(glob.glob(f"{EV}/b*-{v}/memdoor-{v}/{iid}"), reverse=True):
            pd = os.path.join(d, "patch.diff")
            if os.path.isfile(pd) and open(pd).read().strip() == patch.strip():
                found = d
                break
        if found:
            dst = f"{out}/{v}/eval/memdoor-{v}/{iid}"
            os.makedirs(dst)
            for f in ("patch.diff", "report.json", "test_output.txt", "run_instance.log", "eval.sh"):
                if os.path.isfile(os.path.join(found, f)):
                    shutil.copy2(os.path.join(found, f), dst)
        elif patch.strip():
            miss.append(f"{iid}-{v}")
        os.makedirs(f"{out}/{v}/trajs", exist_ok=True)
        open(f"{out}/{v}/trajs/{iid}.md", "w").write(trace(iid, v, row))
    print(os.uname().nodename, "rows", len(res), "non-empty patch without logs:", miss)


main()
