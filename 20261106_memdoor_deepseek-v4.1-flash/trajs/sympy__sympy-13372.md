# sympy__sympy-13372 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 67s 36 lines cost=0.001782 in=154275 cached=141824 out=2351 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

UnboundLocalError in evalf
```
>>> Mul(x, Max(0, y), evaluate=False).evalf()
x*Max(0, y)
>>> Mul(Max(0, y), x, evaluate=False).evalf()
Traceback (most recent call last):
  File "./sympy/core/evalf.py", line 1285, in evalf
    rf = evalf_table[x.func]
KeyError: Max

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "./sympy/core/evalf.py", line 1394, in evalf
    result = evalf(self, prec + 4, options)
  File "./sympy/core/evalf.py", line 1286, in evalf
    r = rf(x, prec, options)
  File "./sympy/core/evalf.py", line 538, in evalf_mul
    arg = evalf(arg, prec, options)
  File "./sympy/core/evalf.py", line 1308, in evalf
    r = re, im, reprec, imprec
UnboundLocalError: local variable 'reprec' referenced before assignment
```

I found this after changing the order of Mul args in https://github.com/sympy/sympy/pull/13059.

Based on the code, I think the elif clauses that define reprec and imprec should have an `else: raise NotImplementedError`. That appears to fix it, although I didn't try to debug to see why the arg order is mattering here.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "cd /workspace 2>/dev/null || pwd; ls; git status --porcelain | head"
}
```

**tool result**

```
refused: this command cd's to /workspace, outside your working directory (/testbed). You are ALREADY in the right directory — drop the cd and use paths relative to it.

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "pwd; ls; git status --porcelain | head"
}
```

**tool result**

```
/testbed
AUTHORS
CODE_OF_CONDUCT.md
LICENSE
MANIFEST.in
PULL_REQUEST_TEMPLATE.md
README.rst
bin
conftest.py
data
doc
examples
github_deploy_key.enc
release
setup.py
setupegg.py
sympy
sympy.egg-info
tox.ini.sample
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1260,1330p' sympy/core/evalf.py; sed -n '500,560p' sympy/core/evalf.py"
}
```

**tool result**

```
        sin: evalf_trig,

        Add: evalf_add,
        Mul: evalf_mul,
        Pow: evalf_pow,

        log: evalf_log,
        atan: evalf_atan,
        Abs: evalf_abs,

        re: evalf_re,
        im: evalf_im,
        floor: evalf_floor,
        ceiling: evalf_ceiling,

        Integral: evalf_integral,
        Sum: evalf_sum,
        Product: evalf_prod,
        Piecewise: evalf_piecewise,

        bernoulli: evalf_bernoulli,
    }


def evalf(x, prec, options):
    from sympy import re as re_, im as im_
    try:
        rf = evalf_table[x.func]
        r = rf(x, prec, options)
    except KeyError:
        try:
            # Fall back to ordinary evalf if possible
            if 'subs' in options:
                x = x.subs(evalf_subs(prec, options['subs']))
            xe = x._eval_evalf(prec)
            re, im = xe.as_real_imag()
            if re.has(re_) or im.has(im_):
                raise NotImplementedError
            if re == 0:
                re = None
                reprec = None
            elif re.is_number:
                re = re._to_mpmath(prec, allow_ints=False)._mpf_
                reprec = prec
            if im == 0:
                im = None
                imprec = None
            elif im.is_number:
                im = im._to_mpmath(prec, allow_ints=False)._mpf_
                imprec = prec
            r = re, im, reprec, imprec
        except AttributeError:
            raise NotImplementedError
    if options.get("verbose"):
        print("### input", x)
        print("### output", to_str(r[0] or fzero, 50))
        print("### raw", r) # r[0], r[2]
        print()
    chop = options.get('chop', False)
    if chop:
        if chop is True:
            chop_prec = prec
        else:
            # convert (approximately) from given tolerance;
            # the formula here will will make 1e-i rounds to 0 for
            # i in the range +/-27 while 2e-i will not be chopped
            chop_prec = int(round(-3.321*math.log10(chop) + 2.5))
            if chop_prec == 3:
                chop_prec -= 1
        r = chop_parts(r, chop_prec)
    if options.get("strict"):
        terms = [evalf(arg, prec + 10, options) for arg in v.args]
        re, re_acc = add_terms(
            [a[0::2] for a in terms if a[0]], prec, target_prec)
        im, im_acc = add_terms(
            [a[1::2] for a in terms if a[1]], prec, target_prec)
        acc = complex_accuracy((re, im, re_acc, im_acc))
        if acc >= target_prec:
            if options.get('verbose'):
                print("ADD: wanted", target_prec, "accurate bits, got", re_acc, im_acc)
            break
        else:
            if (prec - target_prec) > options['maxprec']:
                break

            prec = prec + max(10 + 2**i, target_prec - acc)
            i += 1
            if options.get('verbose'):
                print("ADD: restarting with prec", prec)

    options['maxprec'] = oldmaxprec
    if iszero(re, scaled=True):
        re = scaled_zero(re)
    if iszero(im, scaled=True):
        im = scaled_zero(im)
    return re, im, re_acc, im_acc


def evalf_mul(v, prec, options):
    res = pure_complex(v)
    if res:
        # the only pure complex that is a mul is h*I
        _, h = res
        im, _, im_acc, _ = evalf(h, prec, options)
        return None, im, None, im_acc
    args = list(v.args)

    # see if any argument is NaN or oo and thus warrants a special return
    special = []
    from sympy.core.numbers import Float
    for arg in args:
        arg = evalf(arg, prec, options)
        if arg[0] is None:
            continue
        arg = Float._new(arg[0], 1)
        if arg is S.NaN or arg.is_infinite:
            special.append(arg)
    if special:
        from sympy.core.mul import Mul
        special = Mul(*special)
        return evalf(special, prec + 4, {})

    # With guard digits, multiplication in the real case does not destroy
    # accuracy. This is also true in the complex case when considering the
    # total accuracy; however accuracy for the real or imaginary parts
    # separately may be lower.
    acc = prec

    # XXX: big overestimate
    working_prec = prec + len(args) + 5

    # Empty product is 1
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nprint(Mul(Max(0,y),x,evaluate=False).evalf())\n\" 2>&1 | tail -20"
}
```

**tool result**

```
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/solvers/diophantine.py:3188: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if feasible is 1:  # it's prime and k == 2
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
Traceback (most recent call last):
  File "<string>", line 3, in <module>
NameError: name 'y' is not defined
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nx,y=symbols('x y')\nprint(Mul(Max(0,y),x,evaluate=False).evalf())\n\" 2>&1 | tail -20"
}
```

**tool result**

```
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
Traceback (most recent call last):
  File "/testbed/sympy/core/evalf.py", line 1287, in evalf
    rf = evalf_table[x.func]
KeyError: Max

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "<string>", line 4, in <module>
  File "/testbed/sympy/core/evalf.py", line 1396, in evalf
    result = evalf(self, prec + 4, options)
  File "/testbed/sympy/core/evalf.py", line 1288, in evalf
    r = rf(x, prec, options)
  File "/testbed/sympy/core/evalf.py", line 540, in evalf_mul
    arg = evalf(arg, prec, options)
  File "/testbed/sympy/core/evalf.py", line 1310, in evalf
    r = re, im, reprec, imprec
UnboundLocalError: local variable 'reprec' referenced before assignment
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '560,650p' sympy/core/evalf.py"
}
```

**tool result**

```
    # Empty product is 1
    start = man, exp, bc = MPZ(1), 0, 1

    # First, we multiply all pure real or pure imaginary numbers.
    # direction tells us that the result should be multiplied by
    # I**direction; all other numbers get put into complex_factors
    # to be multiplied out after the first phase.
    last = len(args)
    direction = 0
    args.append(S.One)
    complex_factors = []

    for i, arg in enumerate(args):
        if i != last and pure_complex(arg):
            args[-1] = (args[-1]*arg).expand()
            continue
        elif i == last and arg is S.One:
            continue
        re, im, re_acc, im_acc = evalf(arg, working_prec, options)
        if re and im:
            complex_factors.append((re, im, re_acc, im_acc))
            continue
        elif re:
            (s, m, e, b), w_acc = re, re_acc
        elif im:
            (s, m, e, b), w_acc = im, im_acc
            direction += 1
        else:
            return None, None, None, None
        direction += 2*s
        man *= m
        exp += e
        bc += b
        if bc > 3*working_prec:
            man >>= working_prec
            exp += working_prec
        acc = min(acc, w_acc)
    sign = (direction & 2) >> 1
    if not complex_factors:
        v = normalize(sign, man, exp, bitcount(man), prec, rnd)
        # multiply by i
        if direction & 1:
            return None, v, None, acc
        else:
            return v, None, acc, None
    else:
        # initialize with the first term
        if (man, exp, bc) != start:
            # there was a real part; give it an imaginary part
            re, im = (sign, man, exp, bitcount(man)), (0, MPZ(0), 0, 0)
            i0 = 0
        else:
            # there is no real part to start (other than the starting 1)
            wre, wim, wre_acc, wim_acc = complex_factors[0]
            acc = min(acc,
                      complex_accuracy((wre, wim, wre_acc, wim_acc)))
            re = wre
            im = wim
            i0 = 1

        for wre, wim, wre_acc, wim_acc in complex_factors[i0:]:
            # acc is the overall accuracy of the product; we aren't
            # computing exact accuracies of the product.
            acc = min(acc,
                      complex_accuracy((wre, wim, wre_acc, wim_acc)))

            use_prec = working_prec
            A = mpf_mul(re, wre, use_prec)
            B = mpf_mul(mpf_neg(im), wim, use_prec)
            C = mpf_mul(re, wim, use_prec)
            D = mpf_mul(im, wre, use_prec)
            re = mpf_add(A, B, use_prec)
            im = mpf_add(C, D, use_prec)
        if options.get('verbose'):
            print("MUL: wanted", prec, "accurate bits, got", acc)
        # multiply by I
        if direction & 1:
            re, im = mpf_neg(im), re
        return re, im, acc, acc


def evalf_pow(v, prec, options):

    target_prec = prec
    base, exp = v.args

    # We handle x**n separately. This has two purposes: 1) it is much
    # faster, because we avoid calling evalf on the exponent, and 2) it
    # allows better handling of real/imaginary parts that are exactly zero
    if exp.is_Integer:
        p = exp.p
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1370,1420p' sympy/core/evalf.py; grep -n \"NotImplementedError\" sympy/core/evalf.py"
}
```

**tool result**

```

        """
        from sympy import Float, Number
        n = n if n is not None else 15

        if subs and is_sequence(subs):
            raise TypeError('subs must be given as a dictionary')

        # for sake of sage that doesn't like evalf(1)
        if n == 1 and isinstance(self, Number):
            from sympy.core.expr import _mag
            rv = self.evalf(2, subs, maxn, chop, strict, quad, verbose)
            m = _mag(rv)
            rv = rv.round(1 - m)
            return rv

        if not evalf_table:
            _create_evalf_table()
        prec = dps_to_prec(n)
        options = {'maxprec': max(prec, int(maxn*LG10)), 'chop': chop,
               'strict': strict, 'verbose': verbose}
        if subs is not None:
            options['subs'] = subs
        if quad is not None:
            options['quad'] = quad
        try:
            result = evalf(self, prec + 4, options)
        except NotImplementedError:
            # Fall back to the ordinary evalf
            v = self._eval_evalf(prec)
            if v is None:
                return self
            try:
                # If the result is numerical, normalize it
                result = evalf(v, prec, options)
            except NotImplementedError:
                # Probably contains symbols or unknown functions
                return v
        re, im, re_acc, im_acc = result
        if re:
            p = max(min(prec, re_acc), 1)
            re = Float._new(re, p)
        else:
            re = S.Zero
        if im:
            p = max(min(prec, im_acc), 1)
            im = Float._new(im, p)
            return re + im*S.ImaginaryUnit
        else:
            return re

759:        raise NotImplementedError
775:            raise NotImplementedError
850:        raise NotImplementedError
879:    raise NotImplementedError
1013:        raise NotImplementedError
1084:        raise NotImplementedError('does not support inf prec')
1090:        raise NotImplementedError("a hypergeometric series is required")
1103:        raise NotImplementedError("Non rational term functionality is not implemented.")
1166:        raise NotImplementedError
1173:            raise NotImplementedError
1180:    except NotImplementedError:
1297:                raise NotImplementedError
1312:            raise NotImplementedError
1397:        except NotImplementedError:
1405:            except NotImplementedError:
1450:        except NotImplementedError:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/core/evalf.py\n@@\n             elif re.is_number:\n                 re = re._to_mpmath(prec, allow_ints=False)._mpf_\n                 reprec = prec\n+            else:\n+                raise NotImplementedError\n             if im == 0:\n                 im = None\n                 imprec = None\n             elif im.is_number:\n                 im = im._to_mpmath(prec, allow_ints=False)._mpf_\n                 imprec = prec\n+            else:\n+                raise NotImplementedError\n             r = re, im, reprec, imprec\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/core/evalf.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/core/evalf.py now (1495 lines), around the change:
1301:            elif re.is_number:
1302:                re = re._to_mpmath(prec, allow_ints=False)._mpf_
1303:                reprec = prec
1304:            else:
1305:                raise NotImplementedError
1306:            if im == 0:
1307:                im = None
1308:                imprec = None
1309:            elif im.is_number:
1310:                im = im._to_mpmath(prec, allow_ints=False)._mpf_
1311:                imprec = prec
1312:            else:
1313:                raise NotImplementedError
1314:            r = re, im, reprec, imprec
1315:        except AttributeError:
1316:            raise NotImplementedError
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nx,y=symbols('x y')\nprint(Mul(Max(0,y),x,evaluate=False).evalf())\nprint(Mul(x, Max(0,y), evaluate=False).evalf())\n\" 2>&1 | tail -5"
}
```

**tool result**

```
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
x*Max(0, y)
x*Max(0, y)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sympy/core/tests/test_evalf.py -q 2>&1 | tail -15"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_evalf.py 2>&1 | tail -15"
}
```

**tool result**

```
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.21-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        78920061
hash randomization: on (PYTHONHASHSEED=3657068853)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 7.36 seconds ========
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Max\\|evaluate=False\" sympy/core/tests/test_evalf.py | head"
}
```

**tool result**

```
4:    Rational, S, Sum, sin, sqrt, sstr, sympify, Symbol, Max, nfloat)
36:    assert NS(Add(pi, Rational(1, 10**1000), -pi, evaluate=False), 15,
95:        1, 2), evaluate=False)) == '1.25331413731550 + 1.25331413731550*I'
131:    assert NS('log(100, 10, evaluate=False)', 15) == '2.00000000000000'
143:    assert NS(sin(pi*10**100 + Rational(7, 10**5), evaluate=False), 15, maxn=120) == \
145:    assert NS(sin(Rational(7, 10**5), evaluate=False), 15) == \
235:    a = floor(log(8)/log(2) - exp(-1000), evaluate=False)
236:    b = floor(log(8)/log(2), evaluate=False)
242:    assert int(floor(factorial(50)/E, evaluate=False).evalf(70)) == \
244:    assert int(ceiling(factorial(50)/E, evaluate=False).evalf(70)) == \
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,50p' sympy/core/tests/test_evalf.py; grep -n \"^def test_\" sympy/core/tests/test_evalf.py | head -20"
}
```

**tool result**

```
from sympy import (Abs, Add, atan, ceiling, cos, E, Eq, exp,
    factorial, fibonacci, floor, Function, GoldenRatio, I, Integral,
    integrate, log, Mul, N, oo, pi, Pow, product, Product,
    Rational, S, Sum, sin, sqrt, sstr, sympify, Symbol, Max, nfloat)
from sympy.core.evalf import (complex_accuracy, PrecisionExhausted,
    scaled_zero, get_integer_part, as_mpmath)
from mpmath import inf, ninf
from mpmath.libmp.libmpf import from_float
from sympy.core.compatibility import long, range
from sympy.utilities.pytest import raises, XFAIL

from sympy.abc import n, x, y

def NS(e, n=15, **options):
    return sstr(sympify(e).evalf(n, **options), full_prec=True)


def test_evalf_helpers():
    assert complex_accuracy((from_float(2.0), None, 35, None)) == 35
    assert complex_accuracy((from_float(2.0), from_float(10.0), 35, 100)) == 37
    assert complex_accuracy(
        (from_float(2.0), from_float(1000.0), 35, 100)) == 43
    assert complex_accuracy((from_float(2.0), from_float(10.0), 100, 35)) == 35
    assert complex_accuracy(
        (from_float(2.0), from_float(1000.0), 100, 35)) == 35


def test_evalf_basic():
    assert NS('pi', 15) == '3.14159265358979'
    assert NS('2/3', 10) == '0.6666666667'
    assert NS('355/113-pi', 6) == '2.66764e-7'
    assert NS('16*atan(1/5)-4*atan(1/239)', 15) == '3.14159265358979'


def test_cancellation():
    assert NS(Add(pi, Rational(1, 10**1000), -pi, evaluate=False), 15,
              maxn=1200) == '1.00000000000000e-1000'


def test_evalf_powers():
    assert NS('pi**(10**20)', 10) == '1.339148777e+49714987269413385435'
    assert NS(pi**(10**100), 10) == ('4.946362032e+4971498726941338543512682882'
          '9089887365167832438044244613405349992494711208'
          '95526746555473864642912223')
    assert NS('2**(1/10**50)', 15) == '1.00000000000000'
    assert NS('2**(1/10**50)-1', 15) == '6.93147180559945e-51'

# Evaluation of Rump's ill-conditioned polynomial


18:def test_evalf_helpers():
28:def test_evalf_basic():
35:def test_cancellation():
40:def test_evalf_powers():
51:def test_evalf_rump():
56:def test_evalf_complex():
65:def test_evalf_complex_bug():
70:def test_evalf_complex_powers():
88:def test_evalf_complex_powers_bug():
92:def test_evalf_exponentiation():
108:def test_evalf_complex_cancellation():
127:def test_evalf_logs():
135:def test_evalf_trig():
151:def test_evalf_near_integers():
163:def test_evalf_ramanujan():
174:def test_evalf_bugs():
234:def test_evalf_integer_parts():
259:def test_evalf_trig_zero_detection():
268:def test_evalf_sum():
283:def test_evalf_divergent_series():
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '174,235p' sympy/core/tests/test_evalf.py"
}
```

**tool result**

```
def test_evalf_bugs():
    assert NS(sin(1) + exp(-10**10), 10) == NS(sin(1), 10)
    assert NS(exp(10**10) + sin(1), 10) == NS(exp(10**10), 10)
    assert NS('log(1+1/10**50)', 20) == '1.0000000000000000000e-50'
    assert NS('log(10**100,10)', 10) == '100.0000000'
    assert NS('log(2)', 10) == '0.6931471806'
    assert NS(
        '(sin(x)-x)/x**3', 15, subs={x: '1/10**50'}) == '-0.166666666666667'
    assert NS(sin(1) + Rational(
        1, 10**100)*I, 15) == '0.841470984807897 + 1.00000000000000e-100*I'
    assert x.evalf() == x
    assert NS((1 + I)**2*I, 6) == '-2.00000'
    d = {n: (
        -1)**Rational(6, 7), y: (-1)**Rational(4, 7), x: (-1)**Rational(2, 7)}
    assert NS((x*(1 + y*(1 + n))).subs(d).evalf(), 6) == '0.346011 + 0.433884*I'
    assert NS(((-I - sqrt(2)*I)**2).evalf()) == '-5.82842712474619'
    assert NS((1 + I)**2*I, 15) == '-2.00000000000000'
    # issue 4758 (1/2):
    assert NS(pi.evalf(69) - pi) == '-4.43863937855894e-71'
    # issue 4758 (2/2): With the bug present, this still only fails if the
    # terms are in the order given here. This is not generally the case,
    # because the order depends on the hashes of the terms.
    assert NS(20 - 5008329267844*n**25 - 477638700*n**37 - 19*n,
              subs={n: .01}) == '19.8100000000000'
    assert NS(((x - 1)*((1 - x))**1000).n()
              ) == '(-x + 1.00000000000000)**1000*(x - 1.00000000000000)'
    assert NS((-x).n()) == '-x'
    assert NS((-2*x).n()) == '-2.00000000000000*x'
    assert NS((-2*x*y).n()) == '-2.00000000000000*x*y'
    assert cos(x).n(subs={x: 1+I}) == cos(x).subs(x, 1+I).n()
    # issue 6660. Also NaN != mpmath.nan
    # In this order:
    # 0*nan, 0/nan, 0*inf, 0/inf
    # 0+nan, 0-nan, 0+inf, 0-inf
    # >>> n = Some Number
    # n*nan, n/nan, n*inf, n/inf
    # n+nan, n-nan, n+inf, n-inf
    assert (0*E**(oo)).n() == S.NaN
    assert (0/E**(oo)).n() == S.Zero

    assert (0+E**(oo)).n() == S.Infinity
    assert (0-E**(oo)).n() == S.NegativeInfinity

    assert (5*E**(oo)).n() == S.Infinity
    assert (5/E**(oo)).n() == S.Zero

    assert (5+E**(oo)).n() == S.Infinity
    assert (5-E**(oo)).n() == S.NegativeInfinity

    #issue 7416
    assert as_mpmath(0.0, 10, {'chop': True}) == 0

    #issue 5412
    assert ((oo*I).n() == S.Infinity*I)
    assert ((oo+oo*I).n() == S.Infinity + S.Infinity*I)

    #issue 11518
    assert NS(2*x**2.5, 5) == '2.0000*x**2.5000'


def test_evalf_integer_parts():
    a = floor(log(8)/log(2) - exp(-1000), evaluate=False)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/core/tests/test_evalf.py\n@@\n     #issue 11518\n     assert NS(2*x**2.5, 5) == '2.0000*x**2.5000'\n+\n+    # issue 13059\n+    assert Mul(Max(0, y), x, evaluate=False).evalf() == x*Max(0, y)\n+    assert Mul(x, Max(0, y), evaluate=False).evalf() == x*Max(0, y)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/core/tests/test_evalf.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/core/tests/test_evalf.py now (517 lines), around the change:
230:    #issue 11518
231:    assert NS(2*x**2.5, 5) == '2.0000*x**2.5000'
232:
233:    # issue 13059
234:    assert Mul(Max(0, y), x, evaluate=False).evalf() == x*Max(0, y)
235:    assert Mul(x, Max(0, y), evaluate=False).evalf() == x*Max(0, y)
236:
237:
238:def test_evalf_integer_parts():
239:    a = floor(log(8)/log(2) - exp(-1000), evaluate=False)
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_evalf.py 2>&1 | tail -6; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
hash randomization: on (PYTHONHASHSEED=4101568721)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 7.62 seconds ========
TASK_OK
```

**assistant**

```
Fixed the `UnboundLocalError` in `sympy/core/evalf.py`.

**Cause:** In the fallback path of `evalf`, `reprec`/`imprec` were only assigned when the real/imaginary part was zero or a number. If `_eval_evalf` returned a non-numeric part (as with `Max`), neither branch ran, leaving the variables unbound. Argument order mattered because it determined whether the `Max` factor was reached through this fallback path.

**Change:** Added `else: raise NotImplementedError` to both `elif` chains, so unsupported cases fall back cleanly to ordinary `evalf` instead of crashing.

Also added a regression test in `sympy/core/tests/test_evalf.py` covering both argument orders. The evalf test suite passes (46 passed, 2 expected failures), and the required `git status` check exits 0.
```

## Run folder `single-2026-11-06T121348`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
UnboundLocalError in evalf
```
>>> Mul(x, Max(0, y), evaluate=False).evalf()
x*Max(0, y)
>>> Mul(Max(0, y), x, evaluate=False).evalf()
Traceback (most recent call last):
  File "./sympy/core/evalf.py", line 1285, in evalf
    rf = evalf_table[x.func]
KeyError: Max

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "./sympy/core/evalf.py", line 1394, in evalf
    result = evalf(self, prec + 4, options)
  File "./sympy/core/evalf.py", line 1286, in evalf
    r = rf(x, prec, options)
  File "./sympy/core/evalf.py", line 538, in evalf_mul
    arg = evalf(arg, prec, options)
  File "./sympy/core/evalf.py", line 1308, in evalf
    r = re, im, reprec, imprec
UnboundLocalError: local variable 'reprec' referenced before assignment
```

I found this after changing the order of Mul args in https://github.com/sympy/sympy/pull/13059.

Based on the code, I think the elif clauses that define reprec and imprec should have an `else: raise NotImplementedError`. That appears to fix it, although I didn't try to debug to see why the arg order is mattering here.
````
