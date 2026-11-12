# Memdoor on SWE-bench Verified

[Memdoor](https://github.com/guregodevo/memdoor) workflows on DeepSeek V4.1 Flash
(`openrouter:deepseek/deepseek-v4.1-flash`), scored with SWE-bench's harness
(swebench 5.0.2).

## Results

| date | workflow | model build | instances | resolved | $ / instance | report |
|---|---|---|---|---|---|---|
| 2026-11-06 | team-solve | 0910 | 500 | **400** (80.0%) | 0.022 | [run](runs/2026-11-06.md), [entry](20261106_memdoor-team-solve_deepseek-v4.1-flash/) |
| 2026-11-06 | single call | 0910 | 500 | 388 (77.6%) | 0.012 | [run](runs/2026-11-06.md), [entry](20261106_memdoor_deepseek-v4.1-flash/) |
| 2026-11-09 | team-solve-fanout | 0910 | 91, stopped | 74 (81.3%) | 0.050 | [analysis](analysis/fanout-2026-11-09.md) |
| 2026-11-09 | team-solve-fanout | 1017 | 116, stopped | 92 (79.3%) | 0.065 | [analysis](analysis/fanout-2026-11-09.md) |
| 2026-11-12 | team-solve-fanout, fixes found by the pass | 1017 | 100 | **81** (81%) | 0.125 | [analysis](analysis/fanout-2026-11-12.md) |

$ / instance is OpenRouter's `cost_usd`, summed from each run's meter. On the 100
instances of the 2026-11-12 pass: team-solve 79 and the single call 75 (0910 build),
the 2026-11-09 fan-out 76 (1017 build). No single call or team-solve run on the 1017
build yet.

For reference, Claude Fable 5, not run here:

| benchmark | Fable 5 | $ / instance | source |
|---|---|---|---|
| SWE-bench Verified (500) | 95.0%, Anthropic's own agent harness | not published; our runs' tokens at Fable 5's list price ($10 / M in, $1 / M cached, $50 / M out) come to about 2 (single call) and 12 (team-solve-fanout), an estimate | Anthropic; [vals.ai](https://benchmarklist.com/benchmarks/vals_swebench/) lists 95.00% |
| LiveCodeBench, GVS5H's 100 | 90.4%, single call, thinking on | 0.61 | GVS5H's paper |

Only the 2026-11-06 runs cover all 500. LiveCodeBench, GVS5H's 100 hardest:
team-solve-fanout 91 of 100 ([analysis](analysis/fanout-2026-11-09.md#livecodebench-the-100-hardest)).

## Analysis

- [single-call-failures.md](analysis/single-call-failures.md): the 107 instances
  team-solve's direct attempt did not resolve, by what the harness did next.
- [run3-2026-11-07.md](analysis/run3-2026-11-07.md): the day after the 500. A kit
  fault that cost 5 instances; three team-solve changes measured on the 176 seen.
- [survey-offline/](analysis/survey-offline/README.md): the survey step on the 23
  instances whose needed file no step touched.
- [fanout-2026-11-09.md](analysis/fanout-2026-11-09.md): team-solve-fanout, two
  partial SWE-bench runs and LiveCodeBench.
- [fanout-2026-11-12.md](analysis/fanout-2026-11-12.md): team-solve-fanout on
  100 instances, run as a loop that stopped at each regression; how the fan-out
  works and what improves the result.

## Files

- `20261106_*/`: the two entries in the leaderboard's layout: `metadata.yaml`,
  `results/`, `all_preds.jsonl`, `logs/<instance>/`, `trajs/<instance>.md`.
- `runs/2026-11-06.md`: how the 500 run ran, what was run again, what it is not.
- `analysis/`: the notes above and their data.
- `kit/`: the runner, the proxy, the scorer, the stop rule, the web-tool removal,
  the collector and the single-call workflow.
- `first-pass/`: the discarded attempts' results and scores.

## What went wrong, and what was run again

In run 2, OpenRouter's server-side `web_search` answered on 126 instances. Those
126 ([kit/rerun-ids.txt](kit/rerun-ids.txt)) ran again in both arms with the web
tools removed; [first-pass/](first-pass) keeps the discarded results. Details:
[runs/2026-11-06.md](runs/2026-11-06.md#what-went-wrong-and-what-was-run-again).

## Check it

    pip install "swebench @ git+https://github.com/SWE-bench/SWE-bench@02e7a74"
    d=20261106_memdoor-team-solve_deepseek-v4.1-flash
    swebench submit verify $d -s verified --logs $d/logs

## Run it again

On a Linux machine with Docker and `swebench` installed: this `kit/` as
`~/kit`, the Linux build of Memdoor as `~/kit/memdoor`, `workflows/team-solve`
next to `single` in `~/kit/workflows/`, the Verified dataset as
`~/verified.json` (each row with its `swebench/sweb.eval.*` image name in
`image`), then

    echo "$OPENROUTER_API_KEY" | bash ~/kit/start2.sh 6 [ids file]

It runs every instance in both arms, scores them as they finish
(`score2.sh`) and stops on a web tool, a kit fault, or team-solve ending
worse than its own direct attempt (`stop-rule2.sh`). Results in `~/out2`;
`collect.py` writes the per-instance logs and traces.
