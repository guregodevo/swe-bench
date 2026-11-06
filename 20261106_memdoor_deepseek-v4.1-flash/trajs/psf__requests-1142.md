# psf__requests-1142 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 27s 16567 lines cost=0.000000 in=0 cached=0 out=0 calls=0`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

(none)

## Run folder `single-2026-11-06T124313`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
requests.get is ALWAYS sending content length
Hi,

It seems like that request.get always adds 'content-length' header to the request.
I think that the right behavior is not to add this header automatically in GET requests or add the possibility to not send it.

For example http://amazon.com returns 503 for every get request that contains 'content-length' header.

Thanks,

Oren
```
