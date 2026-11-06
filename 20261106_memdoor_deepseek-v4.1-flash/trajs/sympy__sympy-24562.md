# sympy__sympy-24562 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 96s 42 lines cost=0.003438 in=169411 cached=157184 out=6351 calls=20`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
18:48:10 weboff: chief: web_fetch,web_search
18:48:10 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Rational calc value error
python 3.11, sympy 1.11.1
when calc Rational('0.5', '100'), the value is 1/100100; but Rational(0.5, 100) the value is 1/200, this value is the true value, and the version of sympy 1.8 is normal

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain -- . ':(exclude).memdoor' | head"
}
```

**tool result**

```
/testbed
AUTHORS
CODEOWNERS
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE
MANIFEST.in
PULL_REQUEST_TEMPLATE.md
README.md
asv.conf.actions.json
banner.svg
bin
codecov.yml
conftest.py
data
doc
examples
isympy.py
pytest.ini
release
setup.cfg
setup.py
setupegg.py
sympy
sympy.egg-info
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"from sympy import Rational; print(Rational('0.5','100')); print(Rational(0.5,100))\""
}
```

**tool result**

```
1/100100
1/200
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Rational\" sympy/core/numbers.py | head"
}
```

**tool result**

```
1483:class Rational(Number):
3026:class RationalConstant(Rational):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1483,1700p' sympy/core/numbers.py"
}
```

**tool result**

```
class Rational(Number):
    """Represents rational numbers (p/q) of any size.

    Examples
    ========

    >>> from sympy import Rational, nsimplify, S, pi
    >>> Rational(1, 2)
    1/2

    Rational is unprejudiced in accepting input. If a float is passed, the
    underlying value of the binary representation will be returned:

    >>> Rational(.5)
    1/2
    >>> Rational(.2)
    3602879701896397/18014398509481984

    If the simpler representation of the float is desired then consider
    limiting the denominator to the desired value or convert the float to
    a string (which is roughly equivalent to limiting the denominator to
    10**12):

    >>> Rational(str(.2))
    1/5
    >>> Rational(.2).limit_denominator(10**12)
    1/5

    An arbitrarily precise Rational is obtained when a string literal is
    passed:

    >>> Rational("1.23")
    123/100
    >>> Rational('1e-2')
    1/100
    >>> Rational(".1")
    1/10
    >>> Rational('1e-2/3.2')
    1/320

    The conversion of other types of strings can be handled by
    the sympify() function, and conversion of floats to expressions
    or simple fractions can be handled with nsimplify:

    >>> S('.[3]')  # repeating digits in brackets
    1/3
    >>> S('3**2/10')  # general expressions
    9/10
    >>> nsimplify(.3)  # numbers that have a simple form
    3/10

    But if the input does not reduce to a literal Rational, an error will
    be raised:

    >>> Rational(pi)
    Traceback (most recent call last):
    ...
    TypeError: invalid input: pi


    Low-level
    ---------

    Access numerator and denominator as .p and .q:

    >>> r = Rational(3, 4)
    >>> r
    3/4
    >>> r.p
    3
    >>> r.q
    4

    Note that p and q return integers (not SymPy Integers) so some care
    is needed when using them in expressions:

    >>> r.p/r.q
    0.75

    If an unevaluated Rational is desired, ``gcd=1`` can be passed and
    this will keep common divisors of the numerator and denominator
    from being eliminated. It is not possible, however, to leave a
    negative value in the denominator.

    >>> Rational(2, 4, gcd=1)
    2/4
    >>> Rational(2, -4, gcd=1).q
    4

    See Also
    ========
    sympy.core.sympify.sympify, sympy.simplify.simplify.nsimplify
    """
    is_real = True
    is_integer = False
    is_rational = True
    is_number = True

    __slots__ = ('p', 'q')

    p: int
    q: int

    is_Rational = True

    @cacheit
    def __new__(cls, p, q=None, gcd=None):
        if q is None:
            if isinstance(p, Rational):
                return p

            if isinstance(p, SYMPY_INTS):
                pass
            else:
                if isinstance(p, (float, Float)):
                    return Rational(*_as_integer_ratio(p))

                if not isinstance(p, str):
                    try:
                        p = sympify(p)
                    except (SympifyError, SyntaxError):
                        pass  # error will raise below
                else:
                    if p.count('/') > 1:
                        raise TypeError('invalid input: %s' % p)
                    p = p.replace(' ', '')
                    pq = p.rsplit('/', 1)
                    if len(pq) == 2:
                        p, q = pq
                        fp = fractions.Fraction(p)
                        fq = fractions.Fraction(q)
                        p = fp/fq
                    try:
                        p = fractions.Fraction(p)
                    except ValueError:
                        pass  # error will raise below
                    else:
                        return Rational(p.numerator, p.denominator, 1)

                if not isinstance(p, Rational):
                    raise TypeError('invalid input: %s' % p)

            q = 1
            gcd = 1

        if not isinstance(p, SYMPY_INTS):
            p = Rational(p)
            q *= p.q
            p = p.p
        else:
            p = int(p)

        if not isinstance(q, SYMPY_INTS):
            q = Rational(q)
            p *= q.q
            q = q.p
        else:
            q = int(q)

        # p and q are now ints
        if q == 0:
            if p == 0:
                if _errdict["divide"]:
                    raise ValueError("Indeterminate 0/0")
                else:
                    return S.NaN
            return S.ComplexInfinity
        if q < 0:
            q = -q
            p = -p
        if not gcd:
            gcd = igcd(abs(p), q)
        if gcd > 1:
            p //= gcd
            q //= gcd
        if q == 1:
            return Integer(p)
        if p == 1 and q == 2:
            return S.Half
        obj = Expr.__new__(cls)
        obj.p = p
        obj.q = q
        return obj

    def limit_denominator(self, max_denominator=1000000):
        """Closest Rational to self with denominator at most max_denominator.

        Examples
        ========

        >>> from sympy import Rational
        >>> Rational('3.141592653589793').limit_denominator(10)
        22/7
        >>> Rational('3.141592653589793').limit_denominator(100)
        311/99

        """
        f = fractions.Fraction(self.p, self.q)
        return Rational(f.limit_denominator(fractions.Fraction(int(max_denominator))))

    def __getnewargs__(self):
        return (self.p, self.q)

    def _hashable_content(self):
        return (self.p, self.q)

    def _eval_is_positive(self):
        return self.p > 0

    def _eval_is_zero(self):
        return self.p == 0

    def __neg__(self):
        return Rational(-self.p, self.q)

    @_sympifyit('other', NotImplemented)
    def __add__(self, other):
        if global_parameters.evaluate:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport fractions\np='0.5/100'\npq=p.rsplit('/',1)\nprint(pq)\na,b=pq\nfp=fractions.Fraction(a); fq=fractions.Fraction(b)\nprint(fp,fq,fp/fq)\nprint(fractions.Fraction(fp/fq))\n\""
}
```

**tool result**

```
['0.5', '100']
1/2 100 1/200
1/200
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Rational('0.5'\\|Rational(\\\"0.5\\\"\\|100100\\|Rational(.*,.*str\" sympy/core/tests/test_numbers.py | head -30"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_Rational\\|Rational(.*gcd\\|Rational('\" sympy/core/tests/test_numbers.py | head -40"
}
```

**tool result**

```
321:    assert Integer(Rational('1.' + '9'*20)) == 1
324:def test_Rational_new():
339:    assert Rational('3/4') == n3_4
340:    assert -Rational('-3/4') == n3_4
341:    assert Rational('.76').limit_denominator(4) == n3_4
343:    assert Rational('19/25').limit_denominator(4) == n3_4
347:    assert Rational('1e2/1e-2') == Rational(10000)
348:    assert Rational('1 234') == Rational(1234)
349:    assert Rational('1/1 234') == Rational(1, 1234)
354:    raises(TypeError, lambda: Rational('3**3'))
355:    raises(TypeError, lambda: Rational('1/2 + 2/3'))
367:    assert Rational(2, 4, gcd=1).q == 4
368:    n = Rational(2, -4, gcd=1)
415:def test_Rational_cmp():
535:    assert Rational('123 456.123 456') == Rational('123456.123456')
1533:def test_Rational_factors():
1562:def test_Rational_gcd_lcm_cofactors():
1575:    assert Rational(4, 3).gcd(2) == Rational(2, 3)
1577:    assert Rational(4, 3).gcd(Integer(2)) == Rational(2, 3)
1583:    assert Rational(4, 3).gcd(Rational(2, 9)) == Rational(2, 9)
1585:    assert Rational(4, 5).gcd(Rational(2, 9)) == Rational(2, 45)
1587:    assert Rational(5, 9).lcm(Rational(3, 7)) == Rational(Integer(5).lcm(3),Integer(9).gcd(7))
1677:def test_Rational_int():
2114:    rpi = Rational('905502432259640373/288230376151711744')
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '324,375p' sympy/core/tests/test_numbers.py"
}
```

**tool result**

```
def test_Rational_new():
    """"
    Test for Rational constructor
    """
    _test_rational_new(Rational)

    n1 = S.Half
    assert n1 == Rational(Integer(1), 2)
    assert n1 == Rational(Integer(1), Integer(2))
    assert n1 == Rational(1, Integer(2))
    assert n1 == Rational(S.Half)
    assert 1 == Rational(n1, n1)
    assert Rational(3, 2) == Rational(S.Half, Rational(1, 3))
    assert Rational(3, 1) == Rational(1, Rational(1, 3))
    n3_4 = Rational(3, 4)
    assert Rational('3/4') == n3_4
    assert -Rational('-3/4') == n3_4
    assert Rational('.76').limit_denominator(4) == n3_4
    assert Rational(19, 25).limit_denominator(4) == n3_4
    assert Rational('19/25').limit_denominator(4) == n3_4
    assert Rational(1.0, 3) == Rational(1, 3)
    assert Rational(1, 3.0) == Rational(1, 3)
    assert Rational(Float(0.5)) == S.Half
    assert Rational('1e2/1e-2') == Rational(10000)
    assert Rational('1 234') == Rational(1234)
    assert Rational('1/1 234') == Rational(1, 1234)
    assert Rational(-1, 0) is S.ComplexInfinity
    assert Rational(1, 0) is S.ComplexInfinity
    # Make sure Rational doesn't lose precision on Floats
    assert Rational(pi.evalf(100)).evalf(100) == pi.evalf(100)
    raises(TypeError, lambda: Rational('3**3'))
    raises(TypeError, lambda: Rational('1/2 + 2/3'))

    # handle fractions.Fraction instances
    try:
        import fractions
        assert Rational(fractions.Fraction(1, 2)) == S.Half
    except ImportError:
        pass

    assert Rational(mpq(2, 6)) == Rational(1, 3)
    assert Rational(PythonRational(2, 6)) == Rational(1, 3)

    assert Rational(2, 4, gcd=1).q == 4
    n = Rational(2, -4, gcd=1)
    assert n.q == 4
    assert n.p == -2


def test_Number_new():
    """"
    Test for Number constructor
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -5 && git log --oneline --all -- sympy/core/numbers.py | head -20"
}
```

**tool result**

```
ba53e56dc8 SWE-bench
b1cb676cf9 Merge pull request #24557 from sylee957/slow
0eaf5f6d55 Mark some trig rewrite tests slow
68803e50d9 Merge pull request #24492 from hanspi42/laplace_new_structure
d50759b7b6 Test whether `noconds=True` in `doit`
f2622b8990 fix # 24369
2cdab284f8 Update numbers.py
cefe2c9b03 Fixed typos
601088ac2e Update numbers.py
b596d8b1cc Moved commit to last of notes
7474135c33 Moved commit to notes section
25ec127108 Improved Float docs
e934618846 limit expansion of powers
da665dadec Merge pull request #23256 from eagleoflqj/type_free_symbols
5abe85f364 clean some type hints
95a13732c1 fix(core): make core assumptions fully deterministic
84eeff1872 Merge pull request #22924 from ariebovenberg/fix-slots
f3b0852200 Cleanup documentation
117f955446 Moved definition of illegal
3387753241 Fixed issues with __slots__ (overlaps and omission in base classes)
97296dc992 Removed unused imports
43458d1aec Removed deprecated keyword argument
b89453c700 Merge pull request #22737 from skieffer/nf_isom_improve
ea42f5169e Give `Poly` a `same_root()` method.
f5ef4e62e5 core/basic: Basic.__eq__ only performs user defined conversions
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"SYMPY_INTS\" sympy/core/numbers.py | head"
}
```

**tool result**

```
22:from sympy.external.gmpy import SYMPY_INTS, HAS_GMPY, gmpy
601:        if isinstance(obj, SYMPY_INTS):
1061:        elif isinstance(num, (SYMPY_INTS, Integer)):
1594:            if isinstance(p, SYMPY_INTS):
1628:        if not isinstance(p, SYMPY_INTS):
1635:        if not isinstance(q, SYMPY_INTS):
```

**assistant → tool `bash`**

```json
{
  "command": "git show f2622b8990 --stat && git show f2622b8990 -- sympy/core/numbers.py | head -80"
}
```

**tool result**

```
commit f2622b8990ec2accb6754c85b5b0ea6acbc7b14d
Author: Abhishek Patidar <1e9abhi1e10@gmail.com>
Date:   Sun Dec 11 19:31:05 2022 +0530

    fix # 24369

 sympy/core/numbers.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
commit f2622b8990ec2accb6754c85b5b0ea6acbc7b14d
Author: Abhishek Patidar <1e9abhi1e10@gmail.com>
Date:   Sun Dec 11 19:31:05 2022 +0530

    fix # 24369

diff --git a/sympy/core/numbers.py b/sympy/core/numbers.py
index 3b1aec2429..52f7ea45ad 100644
--- a/sympy/core/numbers.py
+++ b/sympy/core/numbers.py
@@ -2423,7 +2423,7 @@ def __floordiv__(self, other):
             return NotImplemented
         if isinstance(other, Integer):
             return Integer(self.p // other)
-        return Integer(divmod(self, other)[0])
+        return divmod(self, other)[0]
 
     def __rfloordiv__(self, other):
         return Integer(Integer(other).p // self.p)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sympy/core/numbers.py\n@@\n-        if not isinstance(p, SYMPY_INTS):\n-            p = Rational(p)\n-            q *= p.q\n-            p = p.p\n-        else:\n-            p = int(p)\n-\n         if not isinstance(q, SYMPY_INTS):\n             q = Rational(q)\n             p *= q.q\n             q = q.p\n         else:\n             q = int(q)\n \n+        if not isinstance(p, SYMPY_INTS):\n+            p = Rational(p)\n+            q *= p.q\n+            p = p.p\n+        else:\n+            p = int(p)\n+\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sympy/core/numbers.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sympy/core/numbers.py now (4496 lines), around the change:
1625:            q = 1
1626:            gcd = 1
1627:
1628:        if not isinstance(q, SYMPY_INTS):
1629:            q = Rational(q)
1630:            p *= q.q
1631:            q = q.p
1632:        else:
1633:            q = int(q)
1634:
1635:        if not isinstance(p, SYMPY_INTS):
1636:            p = Rational(p)
1637:            q *= p.q
1638:            p = p.p
1639:        else:
1640:            p = int(p)
1641:
1642:        # p and q are now ints
1643:        if q == 0:
1644:            if p == 0:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import Rational\nprint(Rational('0.5','100'))\nprint(Rational(0.5,100))\nprint(Rational('1/2','3/4'))\nprint(Rational('0.5', 100))\nprint(Rational(1, '0.5'))\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `python -c "
from sympy import Rational
print(Rational('0.5','100'))
print(Rational(0.5,100))
print(Rational('1/2','3/4'))
print(Rational('0.5', 100))
print(Rational(1, '0.5'))
"`
Output: Traceback (most recent call last):
  File "<string>", line 5, in <module>
  File "/testbed/sympy/core/cache.py", line 72, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/testbed/sympy/core/numbers.py", line 1636, in __new__
    p = Rational(p)
  File "/testbed/sympy/core/cache.py", line 72, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/testbed/sympy/core/numbers.py", line 1607, in __new__
    raise TypeError('invalid input: %s' % p)
TypeError: invalid input: 1/21/21/21/2
1/200
1/200

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sympy/core/numbers.py\n@@\n-        if not isinstance(q, SYMPY_INTS):\n-            q = Rational(q)\n-            p *= q.q\n-            q = q.p\n-        else:\n-            q = int(q)\n-\n-        if not isinstance(p, SYMPY_INTS):\n-            p = Rational(p)\n-            q *= p.q\n-            p = p.p\n-        else:\n-            p = int(p)\n+        if not isinstance(p, SYMPY_INTS):\n+            p = Rational(p)\n+            pn, pd = p.p, p.q\n+        else:\n+            pn, pd = int(p), 1\n+\n+        if not isinstance(q, SYMPY_INTS):\n+            q = Rational(q)\n+            qn, qd = q.p, q.q\n+        else:\n+            qn, qd = int(q), 1\n+\n+        p = pn*qd\n+        q = pd*qn\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sympy/core/numbers.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sympy/core/numbers.py now (4497 lines), around the change:
1625:            q = 1
1626:            gcd = 1
1627:
1628:        if not isinstance(p, SYMPY_INTS):
1629:            p = Rational(p)
1630:            pn, pd = p.p, p.q
1631:        else:
1632:            pn, pd = int(p), 1
1633:
1634:        if not isinstance(q, SYMPY_INTS):
1635:            q = Rational(q)
1636:            qn, qd = q.p, q.q
1637:        else:
1638:            qn, qd = int(q), 1
1639:
1640:        p = pn*qd
1641:        q = pd*qn
1642:
1643:        # p and q are now ints
1644:        if q == 0:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import Rational\nprint(Rational('0.5','100'))\nprint(Rational(0.5,100))\nprint(Rational('1/2','3/4'))\nprint(Rational('0.5', 100))\nprint(Rational(1, '0.5'))\nprint(Rational('1/2', '3/4'))\n\""
}
```

**tool result**

```
1/200
1/200
2/3
1/200
2
2/3
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sympy/core/tests/test_numbers.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_numbers.py 2>&1 | tail -20"
}
```

**tool result**

```
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.20-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        20392765
hash randomization: on (PYTHONHASHSEED=2730376583)

sympy/core/tests/test_numbers.py[108] ..........................................
................................f......................s..........          [OK]

== tests finished: 106 passed, 1 skipped, 1 expected to fail, in 1.96 seconds ==
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sympy/core/tests/test_numbers.py\n@@\n     assert Rational('1e2/1e-2') == Rational(10000)\n     assert Rational('1 234') == Rational(1234)\n     assert Rational('1/1 234') == Rational(1, 1234)\n+    assert Rational('0.5', '100') == Rational(1, 200)\n+    assert Rational('1/2', '3/4') == Rational(2, 3)\n     assert Rational(-1, 0) is S.ComplexInfinity\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sympy/core/tests/test_numbers.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sympy/core/tests/test_numbers.py now (2229 lines), around the change:
347:    assert Rational('1e2/1e-2') == Rational(10000)
348:    assert Rational('1 234') == Rational(1234)
349:    assert Rational('1/1 234') == Rational(1, 1234)
350:    assert Rational('0.5', '100') == Rational(1, 200)
351:    assert Rational('1/2', '3/4') == Rational(2, 3)
352:    assert Rational(-1, 0) is S.ComplexInfinity
353:    assert Rational(1, 0) is S.ComplexInfinity
354:    # Make sure Rational doesn't lose precision on Floats
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_numbers.py 2>&1 | tail -5 && git diff --stat && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```

sympy/core/tests/test_numbers.py[108] ..........................................
................................f......................s..........          [OK]

== tests finished: 106 passed, 1 skipped, 1 expected to fail, in 2.19 seconds ==
 sympy/core/numbers.py            | 13 +++++++------
 sympy/core/tests/test_numbers.py |  2 ++
 2 files changed, 9 insertions(+), 6 deletions(-)
TASK_OK
```

**assistant**

```
Fixed.

**Root cause:** In `Rational.__new__`, when both `p` and `q` were strings, the numerator was converted first and its denominator was multiplied into `q` *before* `q` was itself converted. For `Rational('0.5', '100')`, `p` became `1/2`, so `q` became `'100' * 2` → the string `'1002'` (actually concatenation), yielding `1/100100`.

**Fix:** Convert both arguments to integer numerator/denominator pairs first, then combine them as `p = pn*qd`, `q = pd*qn`. This also correctly handles cases like `Rational('1/2', '3/4')` → `2/3`.

Added regression tests, and the full `test_numbers.py` suite passes (106 passed, 1 skipped, 1 expected failure). The task's verification command exits 0.
```

## Run folder `single-2026-11-06T184810`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Rational calc value error
python 3.11, sympy 1.11.1
when calc Rational('0.5', '100'), the value is 1/100100; but Rational(0.5, 100) the value is 1/200, this value is the true value, and the version of sympy 1.8 is normal
```
