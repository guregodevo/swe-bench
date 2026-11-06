# sympy__sympy-18763 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 35s 29 lines cost=0.001191 in=66036 cached=54272 out=1787 calls=10`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

Incorrect parenthesizing of Subs
Here is an example.
```python
>>> from sympy import Subs
>>> from sympy.abc import x,y
>>> 3*Subs(-x+y, (x,),(1,))
```
LaTeX printing of this gives:  
```python
'3 \\left. - x + y \\right|_{\\substack{ x=1 }}'
```

![image](https://quicklatex.com/cache3/76/ql_9672fd7e62c909ff3d9ac8543c2e2576_l3.png)


It would be better to be parenthesized to:  
```python
'3 \\left. \\left(- x + y\\right) \\right|_{\\substack{ x=1 }}'
```

![image](https://quicklatex.com/cache3/bf/ql_936ffdb876e784206d4c54bb93d28dbf_l3.png)

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log --oneline -3"
}
```

**tool result**

```
AUTHORS
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE
MANIFEST.in
PULL_REQUEST_TEMPLATE.md
README.rst
bin
codecov.yml
conftest.py
coveragerc_travis
data
doc
examples
github_deploy_key.enc
isympy.py
pytest.ini
release
setup.cfg
setup.py
setupegg.py
sympy
sympy.egg-info
?? .memdoor/
f0d4b72728 SWE-bench
70381f282f Merge pull request #18084 from oscarbenjamin/pr_lambdify_fix
6cd5423b80 Fix lambdify tests
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"_print_Subs\\|def _print_Subs\\|\\\\\\\\left\\.\" sympy/printing/latex.py | head -30"
}
```

**tool result**

```
699:    def _print_Subs(self, subs):
706:        return r'\left. %s \right|_{\substack{ %s }}' % (latex_expr,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '680,720p' sympy/printing/latex.py && grep -n \"def _print_Mul\\|def _print_Add\\|def parenthesize\\|def _print_Pow\" sympy/printing/latex.py | head"
}
```

**tool result**

```
        dim = 0
        for x, num in reversed(expr.variable_count):
            dim += num
            if num == 1:
                tex += r"%s %s" % (diff_symbol, self._print(x))
            else:
                tex += r"%s %s^{%s}" % (diff_symbol,
                                        self.parenthesize_super(self._print(x)),
                                        self._print(num))

        if dim == 1:
            tex = r"\frac{%s}{%s}" % (diff_symbol, tex)
        else:
            tex = r"\frac{%s^{%s}}{%s}" % (diff_symbol, self._print(dim), tex)

        return r"%s %s" % (tex, self.parenthesize(expr.expr,
                                                  PRECEDENCE["Mul"],
                                                  strict=True))

    def _print_Subs(self, subs):
        expr, old, new = subs.args
        latex_expr = self._print(expr)
        latex_old = (self._print(e) for e in old)
        latex_new = (self._print(e) for e in new)
        latex_subs = r'\\ '.join(
            e[0] + '=' + e[1] for e in zip(latex_old, latex_new))
        return r'\left. %s \right|_{\substack{ %s }}' % (latex_expr,
                                                         latex_subs)

    def _print_Integral(self, expr):
        tex, symbols = "", []

        # Only up to \iiiint exists
        if len(expr.limits) <= 4 and all(len(lim) == 1 for lim in expr.limits):
            # Use len(expr.limits)-1 so that syntax highlighters don't think
            # \" is an escaped quote
            tex = r"\i" + "i"*(len(expr.limits) - 1) + "nt"
            symbols = [r"\, d%s" % self._print(symbol[0])
                       for symbol in expr.limits]

        else:
202:    def parenthesize(self, item, level, strict=False):
209:    def parenthesize_super(self, s):
339:    def _print_Add(self, expr, order=None):
434:    def _print_Mul(self, expr):
535:    def _print_Pow(self, expr):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Subs\" sympy/printing/tests/test_latex.py | head -30; sed -n '195,220p' sympy/printing/latex.py"
}
```

**tool result**

```
8:    RisingFactorial, rootof, RootSum, S, Shi, Si, SineTransform, Subs,
676:    assert latex(Subs(x*y, (
        try:
            self._settings['imaginary_unit_latex'] = \
                imaginary_unit_table[self._settings['imaginary_unit']]
        except KeyError:
            self._settings['imaginary_unit_latex'] = \
                self._settings['imaginary_unit']

    def parenthesize(self, item, level, strict=False):
        prec_val = precedence_traditional(item)
        if (prec_val < level) or ((not strict) and prec_val <= level):
            return r"\left({}\right)".format(self._print(item))
        else:
            return self._print(item)

    def parenthesize_super(self, s):
        """ Parenthesize s if there is a superscript in s"""
        if "^" in s:
            return r"\left({}\right)".format(s)
        return s

    def embed_super(self, s):
        """ Embed s in {} if there is a superscript in s"""
        if "^" in s:
            return "{{{}}}".format(s)
        return s
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '665,690p' sympy/printing/tests/test_latex.py"
}
```

**tool result**

```
    assert latex(diff(f(x1, x2), x1)) == r'\frac{\partial}{\partial x_{1}} f{\left(x_{1},x_{2} \right)}'

    n1 = Symbol('n1')
    assert latex(diff(f(x), (x, n1))) ==  r'\frac{d^{n_{1}}}{d x^{n_{1}}} f{\left(x \right)}'

    n2 = Symbol('n2')
    assert latex(diff(f(x), (x, Max(n1, n2)))) == \
        r'\frac{d^{\max\left(n_{1}, n_{2}\right)}}{d x^{\max\left(n_{1}, n_{2}\right)}} f{\left(x \right)}'


def test_latex_subs():
    assert latex(Subs(x*y, (
        x, y), (1, 2))) == r'\left. x y \right|_{\substack{ x=1\\ y=2 }}'


def test_latex_integrals():
    assert latex(Integral(log(x), x)) == r"\int \log{\left(x \right)}\, dx"
    assert latex(Integral(x**2, (x, 0, 1))) == \
        r"\int\limits_{0}^{1} x^{2}\, dx"
    assert latex(Integral(x**2, (x, 10, 20))) == \
        r"\int\limits_{10}^{20} x^{2}\, dx"
    assert latex(Integral(y*x**2, (x, 0, 1), y)) == \
        r"\int\int\limits_{0}^{1} x^{2} y\, dx\, dy"
    assert latex(Integral(y*x**2, (x, 0, 1), y), mode='equation*') == \
        r"\begin{equation*}\int\int\limits_{0}^{1} x^{2} y\, dx\, dy\end{equation*}"
    assert latex(Integral(y*x**2, (x, 0, 1), y), mode='equation*', itex=True) \
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/printing/latex.py\n@@\n-        return r'\\left. %s \\right|_{\\substack{ %s }}' % (latex_expr,\n-                                                         latex_subs)\n+        return r'\\left. %s \\right|_{\\substack{ %s }}' % (\n+            self.parenthesize(expr, PRECEDENCE['Mul'], strict=True),\n+            latex_subs)\n*** Update File: sympy/printing/tests/test_latex.py\n@@\n def test_latex_subs():\n     assert latex(Subs(x*y, (\n         x, y), (1, 2))) == r'\\left. x y \\right|_{\\substack{ x=1\\\\ y=2 }}'\n+    assert latex(3*Subs(-x + y, (x,), (1,))) == \\\n+        r'3 \\left. \\left(- x + y\\right) \\right|_{\\substack{ x=1 }}'\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/printing/latex.py sympy/printing/tests/test_latex.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/printing/latex.py now (2844 lines), around the change:
703:        latex_new = (self._print(e) for e in new)
704:        latex_subs = r'\\ '.join(
705:            e[0] + '=' + e[1] for e in zip(latex_old, latex_new))
706:        return r'\left. %s \right|_{\substack{ %s }}' % (
707:            self.parenthesize(expr, PRECEDENCE['Mul'], strict=True),
708:            latex_subs)
709:
710:    def _print_Integral(self, expr):
711:        tex, symbols = "", []

sympy/printing/tests/test_latex.py now (2525 lines), around the change:
675:def test_latex_subs():
676:    assert latex(Subs(x*y, (
677:        x, y), (1, 2))) == r'\left. x y \right|_{\substack{ x=1\\ y=2 }}'
678:    assert latex(3*Subs(-x + y, (x,), (1,))) == \
679:        r'3 \left. \left(- x + y\right) \right|_{\substack{ x=1 }}'
680:
681:
682:def test_latex_integrals():
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sympy/printing/tests/test_latex.py -q -k subs 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import Subs\nfrom sympy.abc import x,y\nfrom sympy.printing.latex import latex\nprint(latex(3*Subs(-x+y,(x,),(1,))))\nprint(latex(Subs(x*y,(x,y),(1,2))))\n\" && python bin/test sympy/printing/tests/test_latex.py 2>&1 | tail -15"
}
```

**tool result**

```
3 \left. \left(- x + y\right) \right|_{\substack{ x=1 }}
\left. x y \right|_{\substack{ x=1\\ y=2 }}
    e = parse_expr("-B*A", evaluate=False)
  File "/testbed/sympy/parsing/sympy_parser.py", line 1006, in parse_expr
    code = compile(evaluateFalse(code), '<string>', 'eval')
ValueError: Name node can't be used with 'False' constant
________________________________________________________________________________
_____________ sympy/printing/tests/test_latex.py:test_issue_13559 ______________
Traceback (most recent call last):
  File "/testbed/sympy/printing/tests/test_latex.py", line 2126, in test_issue_13559
    expr = parse_expr('5/1', evaluate=False)
  File "/testbed/sympy/parsing/sympy_parser.py", line 1006, in parse_expr
    code = compile(evaluateFalse(code), '<string>', 'eval')
ValueError: Name node can't be used with 'False' constant

 tests finished: 143 passed, 2 expected to fail, 2 exceptions, in 1.49 seconds =
DO *NOT* COMMIT!
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo OK; git diff --stat"
}
```

**tool result**

```
OK
 sympy/printing/latex.py            | 5 +++--
 sympy/printing/tests/test_latex.py | 2 ++
 2 files changed, 5 insertions(+), 2 deletions(-)
```

**assistant**

````
Fixed `Subs` LaTeX parenthesization in `sympy/printing/latex.py`: the substitution expression is now parenthesized via `self.parenthesize(expr, PRECEDENCE['Mul'], strict=True)`, so an additive expression renders as:

```
3 \left. \left(- x + y\right) \right|_{\substack{ x=1 }}
```

Added a regression test to `sympy/printing/tests/test_latex.py`. The related tests pass (143 passed; the 2 exceptions are pre-existing `parse_expr` environment issues unrelated to this change). The required `git status` check exits 0.
````

## Run folder `single-2026-11-06T140555`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
Incorrect parenthesizing of Subs
Here is an example.
```python
>>> from sympy import Subs
>>> from sympy.abc import x,y
>>> 3*Subs(-x+y, (x,),(1,))
```
LaTeX printing of this gives:  
```python
'3 \\left. - x + y \\right|_{\\substack{ x=1 }}'
```

![image](https://quicklatex.com/cache3/76/ql_9672fd7e62c909ff3d9ac8543c2e2576_l3.png)


It would be better to be parenthesized to:  
```python
'3 \\left. \\left(- x + y\\right) \\right|_{\\substack{ x=1 }}'
```

![image](https://quicklatex.com/cache3/bf/ql_936ffdb876e784206d4c54bb93d28dbf_l3.png)
````
