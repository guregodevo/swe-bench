#!/usr/bin/env python3
"""pick-pair.py: can the decision model pick the right one of two patches?

On the instances where the published single call and the published team-solve
disagree (one resolved, the other not), the decision model is asked which
change resolves the issue, from the issue and the two diffs (test files left
out, as the kit submits them). Each pair is asked twice with the order
swapped, and the two answers averaged, so a preference for the first option
cancels. The pick is the one above 0.5; ties (exactly 0.5) go to the team.

    export MEMDOOR_TOKEN=...
    python3 kit/pick-pair.py --gateway http://localhost:18809 --n 1     # one instance
    python3 kit/pick-pair.py --gateway http://localhost:18809 --n 4
    python3 kit/pick-pair.py --gateway http://localhost:18809 --all -o pairs.jsonl

Compare with: team alone, single alone, and the oracle. Two decision calls a
pair, about $0.0001.
"""
import argparse, json, os, re, sys, urllib.request

TEAM = "20261106_memdoor-team-solve_deepseek-v4.1-flash"
SINGLE = "20261106_memdoor_deepseek-v4.1-flash"
INSTRUCTIONS = ("Which change resolves the issue as the project's maintainers would expect: the general case "
                "the issue describes and its sibling cases, the project's own conventions for messages and "
                "warnings, and no existing behaviour broken? Not only the example in the issue.")
MAX_ISSUE = 3500
MAX_DIFF = 3800
TEST = re.compile(r"(^|/)tests?(/|_)|_test\.py$|(^|/)test_[^/]*\.py$|/testing/|(^|/)conftest\.py$")


def issue_of(inst):
    for run in (TEAM, SINGLE):
        p = os.path.join(run, "trajs", inst + ".md")
        if not os.path.exists(p):
            continue
        txt = open(p, encoding="utf-8", errors="replace").read()
        i = txt.find("\n## Prompt\n")
        if i < 0:
            continue
        j = min([k for k in (txt.find("\n## Deliverable", i), txt.find("\n## Change\n", i), txt.find("\n## Check\n", i)) if k > 0] or [i + 6000])
        return txt[i + 11:j].strip()
    return ""


def code_only(diff):
    out, keep = [], True
    for line in diff.splitlines():
        if line.startswith("diff --git "):
            path = line.split(" b/", 1)[-1]
            keep = not TEST.search(path)
        if keep:
            out.append(line)
    return "\n".join(out)


def head(s, n):
    return s if len(s) <= n else s[:n] + "\n[…]"


def ask(gateway, token, issue, first, second):
    state = ("# The issue\n\n" + head(issue, MAX_ISSUE) +
             "\n\n# Change 1\n\n```diff\n" + head(first, MAX_DIFF) + "\n```" +
             "\n\n# Change 2\n\n```diff\n" + head(second, MAX_DIFF) + "\n```")
    body = json.dumps({"state": state,
                       "questions": {"pick": {"type": "choice", "instructions": INSTRUCTIONS,
                                              "criteria": {"1": "Change 1 resolves it", "2": "Change 2 resolves it"}}},
                       "options": {"purpose": "pick-pair", "timeoutMs": 20000}}).encode()
    req = urllib.request.Request(gateway.rstrip("/") + "/api/decisions/evaluate", data=body,
                                 headers={"Content-Type": "application/json", "Authorization": "Bearer " + token})
    with urllib.request.urlopen(req, timeout=30) as r:
        res = json.load(r)
    if res.get("status") != "ok":
        raise RuntimeError(f"{res.get('reason')}: {res.get('detail', '')}")
    ans = res["result"]["answers"]["pick"]
    probs = ans.get("probabilities") or {}
    return float(probs.get("1", 0.0)), len(state)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gateway", default=os.environ.get("MEMDOOR_GATEWAY", "http://localhost:18789"))
    ap.add_argument("--token", default=os.environ.get("MEMDOOR_TOKEN", ""))
    ap.add_argument("--n", type=int, default=0)
    ap.add_argument("--ids", nargs="*", default=[])
    ap.add_argument("--all", action="store_true")
    ap.add_argument("-o", "--out", default="")
    a = ap.parse_args()
    if not a.token:
        sys.exit("a gateway token: --token or MEMDOOR_TOKEN")
    t = set(json.load(open(os.path.join(TEAM, "results", "results.json")))["resolved"])
    s = set(json.load(open(os.path.join(SINGLE, "results", "results.json")))["resolved"])
    pairs = []
    for inst in sorted((t - s) | (s - t)):
        pt, ps = os.path.join(TEAM, "logs", inst, "patch.diff"), os.path.join(SINGLE, "logs", inst, "patch.diff")
        if os.path.exists(pt) and os.path.exists(ps):
            pairs.append((inst, inst in t))
    todo = [p for p in pairs if p[0] in a.ids] if a.ids else pairs if a.all else pairs[:a.n] if a.n else []
    if not todo:
        sys.exit(f"{len(pairs)} disagreements with both patches; say --n, --ids or --all")
    out = open(a.out, "a") if a.out else None
    rows = []
    for inst, team_right in todo:
        issue = issue_of(inst)
        team = code_only(open(os.path.join(TEAM, "logs", inst, "patch.diff"), errors="replace").read())
        single = code_only(open(os.path.join(SINGLE, "logs", inst, "patch.diff"), errors="replace").read())
        try:
            p1, n1 = ask(a.gateway, a.token, issue, team, single)    # team first
            p2, n2 = ask(a.gateway, a.token, issue, single, team)    # team second
        except Exception as e:
            print(f"{inst}: {e}", file=sys.stderr)
            continue
        p_team = (p1 + (1 - p2)) / 2
        pick_team = p_team >= 0.5
        right = pick_team == team_right
        row = {"instance": inst, "team_right": team_right, "p_team_first": round(p1, 3), "p_team_second": round(1 - p2, 3),
               "p_team": round(p_team, 3), "picked": "team" if pick_team else "single", "right": right,
               "state_chars": max(n1, n2), "same_diff": team.strip() == single.strip()}
        rows.append(row)
        print(f"{inst:40s} right={'team' if team_right else 'single':6s} p_team={p_team:.2f} ({p1:.2f}/{1-p2:.2f}) picked={row['picked']:6s} {'ok' if right else 'WRONG'}")
        if out:
            out.write(json.dumps(row) + "\n")
            out.flush()
    if rows:
        n = len(rows)
        print(f"\npicked right: {sum(r['right'] for r in rows)}/{n}   team alone: {sum(r['team_right'] for r in rows)}/{n}   "
              f"single alone: {sum(not r['team_right'] for r in rows)}/{n}   oracle: {n}/{n}")
        flips = sum(1 for r in rows if (r['p_team_first'] >= 0.5) != (r['p_team_second'] >= 0.5))
        print(f"order flipped the pick in {flips}/{n} (position bias)")


if __name__ == "__main__":
    main()
