# sympy__sympy-13372 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 161s 34 lines cost=0.007998 in=240534 cached=215040 out=16443 calls=20`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

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


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git log --oneline -3 && git status --short | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1250,1330p' sympy/core/evalf.py"
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
14fb9af0c SWE-bench
30379ea6e Merge pull request #13357 from nilabja10201992/master
3b6110583 convert expr.func is xyz to isinstance(expr, xyz)
?? .memdoor/
```

**tool result**

```
        Pi: lambda x, prec, options: (mpf_pi(prec), None, prec, None),
        Exp1: lambda x, prec, options: (mpf_e(prec), None, prec, None),
        ImaginaryUnit: lambda x, prec, options: (None, fone, None, prec),
        NegativeOne: lambda x, prec, options: (fnone, None, prec, None),
        NaN: lambda x, prec, options: (fnan, None, prec, None),

        exp: lambda x, prec, options: evalf_pow(
            Pow(S.Exp1, x.args[0], evaluate=False), prec, options),

        cos: evalf_trig,
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
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '500,560p' sympy/core/evalf.py && grep -n \"reprec\\|imprec\" sympy/core/evalf.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Max(0, y)\\|evalf.*Max\\|UnboundLocalError\" sympy/core/tests/test_evalf.py | head -30; grep -n \"def test_evalf\" sympy/core/tests/test_evalf.py | tail -20"
}
```

**tool result**

```
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
1300:                reprec = None
1303:                reprec = prec
1306:                imprec = None
1309:                imprec = prec
1310:            r = re, im, reprec, imprec
```

**tool result**

```
509:    eq = x*Max(0, y)
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
295:def test_evalf_product():
301:def test_evalf_py_methods():
309:def test_evalf_power_subs_bugs():
320:def test_evalf_arguments():
343:def test_evalf_relational():
408:def test_evalf_mul():
454:def test_evalf_integral():
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nx,y=symbols('x y')\nprint(Mul(x, Max(0, y), evaluate=False).evalf())\ntry:\n print(Mul(Max(0, y), x, evaluate=False).evalf())\nexcept Exception as e:\n import traceback; traceback.print_exc()\n\""
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '490,520p' sympy/core/tests/test_evalf.py; sed -n '400,455p' sympy/core/tests/test_evalf.py"
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
  File "/testbed/sympy/core/evalf.py", line 1287, in evalf
    rf = evalf_table[x.func]
KeyError: Max

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "<string>", line 6, in <module>
  File "/testbed/sympy/core/evalf.py", line 1396, in evalf
    result = evalf(self, prec + 4, options)
  File "/testbed/sympy/core/evalf.py", line 1288, in evalf
    r = rf(x, prec, options)
  File "/testbed/sympy/core/evalf.py", line 540, in evalf_mul
    arg = evalf(arg, prec, options)
  File "/testbed/sympy/core/evalf.py", line 1310, in evalf
    r = re, im, reprec, imprec
UnboundLocalError: local variable 'reprec' referenced before assignment
x*Max(0, y)
```

**tool result**

```
    assert ceiling(sqrt(2**30 + 1)) == 2**15 + 1


def test_AssocOp_Function():
    e = S('''
    Min(-sqrt(3)*cos(pi/18)/6 + re(1/((-1/2 - sqrt(3)*I/2)*(1/6 +
    sqrt(3)*I/18)**(1/3)))/3 + sin(pi/18)/2 + 2 + I*(-cos(pi/18)/2 -
    sqrt(3)*sin(pi/18)/6 + im(1/((-1/2 - sqrt(3)*I/2)*(1/6 +
    sqrt(3)*I/18)**(1/3)))/3), re(1/((-1/2 + sqrt(3)*I/2)*(1/6 +
    sqrt(3)*I/18)**(1/3)))/3 - sqrt(3)*cos(pi/18)/6 - sin(pi/18)/2 + 2 +
    I*(im(1/((-1/2 + sqrt(3)*I/2)*(1/6 + sqrt(3)*I/18)**(1/3)))/3 -
    sqrt(3)*sin(pi/18)/6 + cos(pi/18)/2))''')
    # the following should not raise a recursion error; it
    # should raise a value error because the first arg computes
    # a non-comparable (prec=1) imaginary part
    raises(ValueError, lambda: e._eval_evalf(2))


def test_issue_10395():
    eq = x*Max(0, y)
    assert nfloat(eq) == eq
    eq = x*Max(y, -1.1)
    assert nfloat(eq) == eq
    assert Max(y, 4).n() == Max(4.0, y)
    assert a.n() == 17.25866050002001


def test_issue_4806():
    assert integrate(atan(x)**2, (x, -1, 1)).evalf().round(1) == 0.5
    assert atan(0, evaluate=False).n() == 0


def test_evalf_mul():
    # sympy should not try to expand this; it should be handled term-wise
    # in evalf through mpmath
    assert NS(product(1 + sqrt(n)*I, (n, 1, 500)), 1) == '5.e+567 + 2.e+568*I'


def test_scaled_zero():
    a, b = (([0], 1, 100, 1), -1)
    assert scaled_zero(100) == (a, b)
    assert scaled_zero(a) == (0, 1, 100, 1)
    a, b = (([1], 1, 100, 1), -1)
    assert scaled_zero(100, -1) == (a, b)
    assert scaled_zero(a) == (1, 1, 100, 1)
    raises(ValueError, lambda: scaled_zero(scaled_zero(100)))
    raises(ValueError, lambda: scaled_zero(100, 2))
    raises(ValueError, lambda: scaled_zero(100, 0))
    raises(ValueError, lambda: scaled_zero((1, 5, 1, 3)))


def test_chop_value():
    for i in range(-27, 28):
        assert (Pow(10, i)*2).n(chop=10**i) and not (Pow(10, i)).n(chop=10**i)


def test_infinities():
    assert oo.evalf(chop=True) == inf
    assert (-oo).evalf(chop=True) == ninf


def test_to_mpmath():
    assert sqrt(3)._to_mpmath(20)._mpf_ == (0, long(908093), -19, 20)
    assert S(3.2)._to_mpmath(20)._mpf_ == (0, long(838861), -18, 20)


def test_issue_6632_evalf():
    add = (-100000*sqrt(2500000001) + 5000000001)
    assert add.n() == 9.999999998e-11
    assert (add*add).n() == 9.999999996e-21


def test_issue_4945():
    from sympy.abc import H
    from sympy import zoo
    assert (H/0).evalf(subs={H:1}) == zoo*H


def test_evalf_integral():
    # test that workprec has to increase in order to get a result other than 0
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1330,1420p' sympy/core/evalf.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def _eval_evalf\" sympy/functions/elementary/miscellaneous.py sympy/functions/elementary/*.py | head; grep -n \"class Max\\|class Min\" sympy/functions/elementary/miscellaneous.py"
}
```

**tool result**

```
    if options.get("strict"):
        check_target(x, r, prec)
    return r


class EvalfMixin(object):
    """Mixin class adding evalf capabililty."""

    __slots__ = []

    def evalf(self, n=15, subs=None, maxn=100, chop=False, strict=False, quad=None, verbose=False):
        """
        Evaluate the given formula to an accuracy of n digits.
        Optional keyword arguments:

            subs=<dict>
                Substitute numerical values for symbols, e.g.
                subs={x:3, y:1+pi}. The substitutions must be given as a
                dictionary.

            maxn=<integer>
                Allow a maximum temporary working precision of maxn digits
                (default=100)

            chop=<bool>
                Replace tiny real or imaginary parts in subresults
                by exact zeros (default=False)

            strict=<bool>
                Raise PrecisionExhausted if any subresult fails to evaluate
                to full accuracy, given the available maxprec
                (default=False)

            quad=<str>
                Choose algorithm for numerical quadrature. By default,
                tanh-sinh quadrature is used. For oscillatory
                integrals on an infinite interval, try quad='osc'.

            verbose=<bool>
                Print debug information (default=False)

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
```

**tool result**

```
sympy/functions/elementary/complexes.py:826:    def _eval_evalf(self, prec):
sympy/functions/elementary/complexes.py:913:    def _eval_evalf(self, prec):
sympy/functions/elementary/complexes.py:1006:    def _eval_evalf(self, prec):
sympy/functions/elementary/exponential.py:159:    def _eval_evalf(self, prec):
sympy/functions/elementary/piecewise.py:195:    def _eval_evalf(self, prec):
sympy/functions/elementary/trigonometric.py:2806:    def _eval_evalf(self, prec):
336:class MinMaxBase(Expr, LatticeOp):
524:class Max(MinMaxBase, Application):
642:class Min(MinMaxBase, Application):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '336,420p' sympy/functions/elementary/miscellaneous.py; sed -n '500,560p' sympy/functions/elementary/miscellaneous.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nx,y=symbols('x y')\ne=Max(0,y)\nprint(e._eval_evalf(20))\nprint(e.as_real_imag())\nprint(e._eval_evalf(20).as_real_imag())\n\" 2>/dev/null"
}
```

**tool result**

```
class MinMaxBase(Expr, LatticeOp):
    def __new__(cls, *args, **assumptions):
        if not args:
            raise ValueError("The Max/Min functions must have arguments.")

        args = (sympify(arg) for arg in args)

        # first standard filter, for cls.zero and cls.identity
        # also reshape Max(a, Max(b, c)) to Max(a, b, c)
        try:
            _args = frozenset(cls._new_args_filter(args))
        except ShortCircuit:
            return cls.zero

        # second filter
        # variant I: remove ones which can be removed
        # args = cls._collapse_arguments(set(_args), **assumptions)

        # variant II: find local zeros
        args = cls._find_localzeros(set(_args), **assumptions)

        if not args:
            return cls.identity
        elif len(args) == 1:
            return args.pop()
        else:
            # base creation
            # XXX should _args be made canonical with sorting?
            _args = frozenset(args)
            obj = Expr.__new__(cls, _args, **assumptions)
            obj._argset = _args
            return obj

    def _eval_simplify(self, ratio, measure):
        # simplify Min(foo, y, Max(foo, x)) to Min(foo, y)
        # Like And/Or, anything in common between the two
        # is cause to eliminate the opposite arg.
        cls = self.func
        if cls == Min:
            op = Max
        elif cls == Max:
            op = Min
        else:
            op = None
        if op:
            unnested = set()
            nested = []
            remove = []
            for a in self.args:
                if isinstance(a, op):
                    nested.append(a)
                else:
                    unnested.add(a)
            N = len(nested) - 1
            for i, n in enumerate(reversed(nested)):
                if set(n.args) & unnested:
                    nested.pop(N - i)
            return cls(*(list(unnested) + nested))

    @classmethod
    def _new_args_filter(cls, arg_sequence):
        """
        Generator filtering args.

        first standard filter, for cls.zero and cls.identity.
        Also reshape Max(a, Max(b, c)) to Max(a, b, c),
        and check arguments for comparability
        """
        for arg in arg_sequence:

            # pre-filter, checking comparability of arguments
            if (not isinstance(arg, Expr)) or (arg.is_real is False) or (arg is S.ComplexInfinity):
                raise ValueError("The argument '%s' is not comparable." % arg)

            if arg == cls.zero:
                raise ShortCircuit(arg)
            elif arg == cls.identity:
                continue
            elif arg.func == cls:
                for x in arg.args:
                    yield x
            else:
                yield arg

    @classmethod
    _eval_is_commutative = lambda s: _torf(i.is_commutative for i in s.args)
    _eval_is_complex = lambda s: _torf(i.is_complex for i in s.args)
    _eval_is_composite = lambda s: _torf(i.is_composite for i in s.args)
    _eval_is_even = lambda s: _torf(i.is_even for i in s.args)
    _eval_is_finite = lambda s: _torf(i.is_finite for i in s.args)
    _eval_is_hermitian = lambda s: _torf(i.is_hermitian for i in s.args)
    _eval_is_imaginary = lambda s: _torf(i.is_imaginary for i in s.args)
    _eval_is_infinite = lambda s: _torf(i.is_infinite for i in s.args)
    _eval_is_integer = lambda s: _torf(i.is_integer for i in s.args)
    _eval_is_irrational = lambda s: _torf(i.is_irrational for i in s.args)
    _eval_is_negative = lambda s: _torf(i.is_negative for i in s.args)
    _eval_is_noninteger = lambda s: _torf(i.is_noninteger for i in s.args)
    _eval_is_nonnegative = lambda s: _torf(i.is_nonnegative for i in s.args)
    _eval_is_nonpositive = lambda s: _torf(i.is_nonpositive for i in s.args)
    _eval_is_nonzero = lambda s: _torf(i.is_nonzero for i in s.args)
    _eval_is_odd = lambda s: _torf(i.is_odd for i in s.args)
    _eval_is_polar = lambda s: _torf(i.is_polar for i in s.args)
    _eval_is_positive = lambda s: _torf(i.is_positive for i in s.args)
    _eval_is_prime = lambda s: _torf(i.is_prime for i in s.args)
    _eval_is_rational = lambda s: _torf(i.is_rational for i in s.args)
    _eval_is_real = lambda s: _torf(i.is_real for i in s.args)
    _eval_is_transcendental = lambda s: _torf(i.is_transcendental for i in s.args)
    _eval_is_zero = lambda s: _torf(i.is_zero for i in s.args)

class Max(MinMaxBase, Application):
    """
    Return, if possible, the maximum value of the list.

    When number of arguments is equal one, then
    return this argument.

    When number of arguments is equal two, then
    return, if possible, the value from (a, b) that is >= the other.

    In common case, when the length of list greater than 2, the task
    is more complicated. Return only the arguments, which are greater
    than others, if it is possible to determine directional relation.

    If is not possible to determine such a relation, return a partially
    evaluated result.

    Assumptions are used to make the decision too.

    Also, only comparable arguments are permitted.

    It is named ``Max`` and not ``max`` to avoid conflicts
    with the built-in function ``max``.


    Examples
    ========

    >>> from sympy import Max, Symbol, oo
    >>> from sympy.abc import x, y
    >>> p = Symbol('p', positive=True)
    >>> n = Symbol('n', negative=True)

    >>> Max(x, -2)                  #doctest: +SKIP
    Max(x, -2)
    >>> Max(x, -2).subs(x, 3)
    3
```

**tool result**

```
Max(0, y)
(Max(0, y), 0)
(Max(0, y), 0)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' sympy/core/tests/test_evalf.py"
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
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/core/evalf.py\n@@\n             if re == 0:\n                 re = None\n                 reprec = None\n             elif re.is_number:\n                 re = re._to_mpmath(prec, allow_ints=False)._mpf_\n                 reprec = prec\n+            else:\n+                raise NotImplementedError\n             if im == 0:\n                 im = None\n                 imprec = None\n             elif im.is_number:\n                 im = im._to_mpmath(prec, allow_ints=False)._mpf_\n                 imprec = prec\n+            else:\n+                raise NotImplementedError\n             r = re, im, reprec, imprec\n*** End Patch\n"
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
  "command": "python -c \"\nfrom sympy import *\nx,y=symbols('x y')\nprint(Mul(x, Max(0, y), evaluate=False).evalf())\nprint(Mul(Max(0, y), x, evaluate=False).evalf())\nprint(Mul(Max(0, y), x, evaluate=False).n())\nprint(Max(0,y).evalf())\n\" 2>/dev/null"
}
```

**tool result**

```
x*Max(0, y)
x*Max(0, y)
x*Max(0, y)
Max(0, y)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/core/tests/test_evalf.py\n@@\n def test_issue_10395():\n     eq = x*Max(0, y)\n     assert nfloat(eq) == eq\n+    # the order of the factors should not matter (issue 13059)\n+    assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq\n     eq = x*Max(y, -1.1)\n     assert nfloat(eq) == eq\n     assert Max(y, 4).n() == Max(4.0, y)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/core/tests/test_evalf.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/core/tests/test_evalf.py now (515 lines), around the change:
508:def test_issue_10395():
509:    eq = x*Max(0, y)
510:    assert nfloat(eq) == eq
511:    # the order of the factors should not matter (issue 13059)
512:    assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq
513:    eq = x*Max(y, -1.1)
514:    assert nfloat(eq) == eq
515:    assert Max(y, 4).n() == Max(4.0, y)
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
  "command": "python -m sympy.utilities.pytest sympy/core/tests/test_evalf.py 2>&1 | tail -20"
}
```

**tool result**

```
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
```

**assistant → tool `bash`**

```json
{
  "command": "python -m sympy.utilities.pytest sympy/core/tests/test_evalf.py; echo EXIT:$?"
}
```

**tool result**

```
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
EXIT:0
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_evalf.py 2>&1 | tail -20; echo EXIT:${PIPESTATUS[0]}"
}
```

**tool result**

```
  from collections import Callable
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.21-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        70941274
hash randomization: on (PYTHONHASHSEED=1217516839)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 7.66 seconds ========
EXIT:0
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_arit.py sympy/functions/elementary/tests/test_miscellaneous.py 2>&1 | tail -8; echo EXIT:${PIPESTATUS[0]}"
}
```

**tool result**

```
    from collections import MutableMapping, defaultdict
  File "<frozen importlib._bootstrap>", line 1055, in _handle_fromlist
  File "/opt/miniconda3/envs/testbed/lib/python3.9/collections/__init__.py", line 62, in __getattr__
    warnings.warn("Using or importing the ABCs from 'collections' instead "
DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working

= tests finished: 84 passed, 3 expected to fail, 2 exceptions, in 5.93 seconds =
DO *NOT* COMMIT!
EXIT:1
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_arit.py sympy/functions/elementary/tests/test_miscellaneous.py 2>&1 | grep -A20 \"exception\\|Exception\\|Traceback\" | head -80"
}
```

**tool result**

```
= tests finished: 84 passed, 3 expected to fail, 2 exceptions, in 6.48 seconds =
DO *NOT* COMMIT!
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/core/tests/test_arit.py 2>&1 | tail -40"
}
```

**tool result**

```
    evaluated = cls.eval(*args)
  File "/testbed/sympy/functions/elementary/exponential.py", line 251, in eval
    if ask(Q.integer(2*coeff)):
  File "/testbed/sympy/assumptions/ask.py", line 1247, in ask
    from sympy.assumptions.satask import satask
  File "/testbed/sympy/assumptions/satask.py", line 9, in <module>
    from sympy.assumptions.sathandlers import fact_registry
  File "/testbed/sympy/assumptions/sathandlers.py", line 3, in <module>
    from collections import MutableMapping, defaultdict
  File "<frozen importlib._bootstrap>", line 1055, in _handle_fromlist
  File "/opt/miniconda3/envs/testbed/lib/python3.9/collections/__init__.py", line 62, in __getattr__
    warnings.warn("Using or importing the ABCs from 'collections' instead "
DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
________________________________________________________________________________
_________________ sympy/core/tests/test_arit.py:test_mul_coeff _________________
  File "/testbed/sympy/core/tests/test_arit.py", line 1829, in test_mul_coeff
    p = exp(I*pi/3)
  File "/testbed/sympy/core/cache.py", line 93, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/testbed/sympy/core/function.py", line 439, in __new__
    result = super(Function, cls).__new__(cls, *args, **options)
  File "/testbed/sympy/core/cache.py", line 93, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/testbed/sympy/core/function.py", line 250, in __new__
    evaluated = cls.eval(*args)
  File "/testbed/sympy/functions/elementary/exponential.py", line 251, in eval
    if ask(Q.integer(2*coeff)):
  File "/testbed/sympy/assumptions/ask.py", line 1247, in ask
    from sympy.assumptions.satask import satask
  File "/testbed/sympy/assumptions/satask.py", line 9, in <module>
    from sympy.assumptions.sathandlers import fact_registry
  File "/testbed/sympy/assumptions/sathandlers.py", line 3, in <module>
    from collections import MutableMapping, defaultdict
  File "<frozen importlib._bootstrap>", line 1055, in _handle_fromlist
  File "/opt/miniconda3/envs/testbed/lib/python3.9/collections/__init__.py", line 62, in __getattr__
    warnings.warn("Using or importing the ABCs from 'collections' instead "
DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working

= tests finished: 75 passed, 3 expected to fail, 2 exceptions, in 2.88 seconds =
DO *NOT* COMMIT!
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/functions/elementary/tests/test_miscellaneous.py 2>&1 | tail -5; git diff --stat; git diff"
}
```

**tool result**

```
hash randomization: on (PYTHONHASHSEED=208513806)

sympy/functions/elementary/tests/test_miscellaneous.py[9] .........         [OK]

================== tests finished: 9 passed, in 2.58 seconds ===================
 sympy/core/evalf.py            | 4 ++++
 sympy/core/tests/test_evalf.py | 2 ++
 2 files changed, 6 insertions(+)
diff --git a/sympy/core/evalf.py b/sympy/core/evalf.py
index 72a5fbae5..f34908710 100644
--- a/sympy/core/evalf.py
+++ b/sympy/core/evalf.py
@@ -1301,12 +1301,16 @@ def evalf(x, prec, options):
             elif re.is_number:
                 re = re._to_mpmath(prec, allow_ints=False)._mpf_
                 reprec = prec
+            else:
+                raise NotImplementedError
             if im == 0:
                 im = None
                 imprec = None
             elif im.is_number:
                 im = im._to_mpmath(prec, allow_ints=False)._mpf_
                 imprec = prec
+            else:
+                raise NotImplementedError
             r = re, im, reprec, imprec
         except AttributeError:
             raise NotImplementedError
diff --git a/sympy/core/tests/test_evalf.py b/sympy/core/tests/test_evalf.py
index 4ac3d5c47..7ac5231c7 100644
--- a/sympy/core/tests/test_evalf.py
+++ b/sympy/core/tests/test_evalf.py
@@ -508,6 +508,8 @@ def test_AssocOp_Function():
 def test_issue_10395():
     eq = x*Max(0, y)
     assert nfloat(eq) == eq
+    # the order of the factors should not matter (issue 13059)
+    assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq
     eq = x*Max(y, -1.1)
     assert nfloat(eq) == eq
     assert Max(y, 4).n() == Max(4.0, y)
```

**assistant**

````
Fixed the `UnboundLocalError` in `sympy/core/evalf.py`.

## Root cause

In `evalf()`'s fallback path (used when `x.func` is not in `evalf_table`, e.g. `Max`), the code did:

```python
if re == 0:
    re = None
    reprec = None
elif re.is_number:
    re = ...
    reprec = prec
# no else -> reprec never assigned
```

When `_eval_evalf` returns a non-numeric expression (as `Max(0, y)` does), neither branch runs, so `reprec`/`imprec` are unbound and `r = re, im, reprec, imprec` raises `UnboundLocalError`. The arg order mattered only because `evalf_mul` evaluates factors in order and the first factor's result short-circuits differently.

## Change

Added the missing `else: raise NotImplementedError` to both the real and imaginary part branches, as suggested. This lets the existing `NotImplementedError` handling in `EvalfMixin.evalf` fall back to returning the unevaluated expression instead of crashing.

```python
            else:
                raise NotImplementedError
```

## Test

Added a regression assertion in `test_issue_10395` in `sympy/core/tests/test_evalf.py`:

```python
assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq
```

## Verification

- Both `Mul(x, Max(0, y), evaluate=False).evalf()` and `Mul(Max(0, y), x, evaluate=False).evalf()` now return `x*Max(0, y)`.
- `sympy/core/tests/test_evalf.py`: 46 passed, 2 expected to fail.
- `sympy/functions/elementary/tests/test_miscellaneous.py`: 9 passed.
- `test_arit.py` has 2 pre-existing environment exceptions from `collections.MutableMapping` imports (Python 3.9), unrelated to this change.

No commits, checkouts, resets, or stashes were performed.
````

## Run folder `team-solve-2026-11-06T121347`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
14fb9af0c75af37cf215c57efdda3cf01ad6cf7e
```

### `baseline-check.log`

```
check: bin/test sympy/core/tests/test_evalf.py
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/solvers/diophantine.py:3188: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if feasible is 1:  # it's prime and k == 2
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/.memdoor/runs/team-solve-2026-11-06T121347/baseline-tree/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.21-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        87151162
hash randomization: on (PYTHONHASHSEED=831042716)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 8.62 seconds ========
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/sympy/core/evalf.py b/sympy/core/evalf.py
index 72a5fbae5..f34908710 100644
--- a/sympy/core/evalf.py
+++ b/sympy/core/evalf.py
@@ -1301,12 +1301,16 @@ def evalf(x, prec, options):
             elif re.is_number:
                 re = re._to_mpmath(prec, allow_ints=False)._mpf_
                 reprec = prec
+            else:
+                raise NotImplementedError
             if im == 0:
                 im = None
                 imprec = None
             elif im.is_number:
                 im = im._to_mpmath(prec, allow_ints=False)._mpf_
                 imprec = prec
+            else:
+                raise NotImplementedError
             r = re, im, reprec, imprec
         except AttributeError:
             raise NotImplementedError
diff --git a/sympy/core/tests/test_evalf.py b/sympy/core/tests/test_evalf.py
index 4ac3d5c47..7ac5231c7 100644
--- a/sympy/core/tests/test_evalf.py
+++ b/sympy/core/tests/test_evalf.py
@@ -508,6 +508,8 @@ def test_AssocOp_Function():
 def test_issue_10395():
     eq = x*Max(0, y)
     assert nfloat(eq) == eq
+    # the order of the factors should not matter (issue 13059)
+    assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq
     eq = x*Max(y, -1.1)
     assert nfloat(eq) == eq
     assert Max(y, 4).n() == Max(4.0, y)
```

### `check-kind.txt`

```
command
```

### `context.md`

````
# task.md

# Task

## Prompt

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

## Deliverable

changes to this tree

## Check

`bin/test sympy/core/tests/test_evalf.py`

## Scope

`sympy/core/evalf.py`
`sympy/core/tests/test_evalf.py`

## Done when

`Mul(Max(0, y), x, evaluate=False).evalf()` returns `x*Max(0, y)` without raising `UnboundLocalError`.
`Mul(x, Max(0, y), evaluate=False).evalf()` still returns `x*Max(0, y)`.
The fallback `elif` chain in `evalf` raises `NotImplementedError` when no branch assigns `reprec`/`imprec`.
`bin/test sympy/core/tests/test_evalf.py` passes.



# plan.md

## Deliverable
changes to this tree

## Check
`bin/test sympy/core/tests/test_evalf.py`

## Scope
`sympy/core/evalf.py`
`sympy/core/tests/test_evalf.py`

## Done when
`Mul(Max(0, y), x, evaluate=False).evalf()` returns `x*Max(0, y)` without raising `UnboundLocalError`.
`Mul(x, Max(0, y), evaluate=False).evalf()` still returns `x*Max(0, y)`.
The fallback `elif` chain in `evalf` raises `NotImplementedError` when no branch assigns `reprec`/`imprec`.
`bin/test sympy/core/tests/test_evalf.py` passes.

## Approach
Locate the `evalf` fallback around the `KeyError: Max` path, add `else: raise NotImplementedError` to the `elif` chain that assigns `reprec`/`imprec`, and confirm `evalf_mul` catches that `NotImplementedError` and returns the unevaluated product. Add a regression test for both argument orders if the existing test file does not already cover it.

Candidate approaches:
1. Add `else: raise NotImplementedError` to the fallback `elif` chain — the prompt’s suggested minimal fix; lets `evalf_mul` handle the unsupported `Max` argument consistently.
2. Initialize `reprec = imprec = None` before the chain — suppresses the `UnboundLocalError` but can return a malformed result and hide unsupported functions; not preferred.
3. Add an explicit `Max` evalf handler — more invasive and unnecessary for this bug; better as a separate enhancement.

If the first attempt fails, check that the new `else` is attached at the correct `elif` level and that `evalf_mul` catches `NotImplementedError` around each argument evaluation.


# sympy/core/evalf.py

```
"""
Adaptive numerical evaluation of SymPy expressions, using mpmath
for mathematical functions.
"""
from __future__ import print_function, division

import math

import mpmath.libmp as libmp
from mpmath import (
    make_mpc, make_mpf, mp, mpc, mpf, nsum, quadts, quadosc, workprec)
from mpmath import inf as mpmath_inf
from mpmath.libmp import (from_int, from_man_exp, from_rational, fhalf,
        fnan, fnone, fone, fzero, mpf_abs, mpf_add,
        mpf_atan, mpf_atan2, mpf_cmp, mpf_cos, mpf_e, mpf_exp, mpf_log, mpf_lt,
        mpf_mul, mpf_neg, mpf_pi, mpf_pow, mpf_pow_int, mpf_shift, mpf_sin,
        mpf_sqrt, normalize, round_nearest, to_int, to_str)
from mpmath.libmp import bitcount as mpmath_bitcount
from mpmath.libmp.backend import MPZ
from mpmath.libmp.libmpc import _infs_nan
from mpmath.libmp.libmpf import dps_to_prec, prec_to_dps
from mpmath.libmp.gammazeta import mpf_bernoulli

from .compatibility import SYMPY_INTS, range
from .sympify import sympify
from .singleton import S

from sympy.utilities.iterables import is_sequence

LG10 = math.log(10, 2)
rnd = round_nearest


def bitcount(n):
    """Return smallest integer, b, such that |n|/2**b < 1.
    """
    return mpmath_bitcount(abs(int(n)))

# Used in a few places as placeholder values to denote exponents and
# precision levels, e.g. of exact numbers. Must be careful to avoid
# passing these to mpmath functions or returning them in final results.
INF = float(mpmath_inf)
MINUS_INF = float(-mpmath_inf)

# ~= 100 digits. Real men set this to INF.
DEFAULT_MAXPREC = 333


class PrecisionExhausted(ArithmeticError):
    pass

#----------------------------------------------------------------------------#
#                                                                            #
#              Helper functions for arithmetic and complex parts             #
#                                                                            #
#----------------------------------------------------------------------------#

"""
An mpf value tuple is a tuple of integers (sign, man, exp, bc)
representing a floating-point number: [1, -1][sign]*man*2**exp where
sign is 0 or 1 and bc should correspond to the number of bits used to
represent the mantissa (man) in binary notation, e.g.

>>> from sympy.core.evalf import bitcount
>>> sign, man, exp, bc = 0, 5, 1, 3
>>> n = [1, -1][sign]*man*2**exp
>>> n, bitcount(man)
(10, 3)

A temporary result is a tuple (re, im, re_acc, im_acc) where
re and im are nonzero mpf value tuples representing approximate
numbers, or None to denote exact zeros.

re_acc, im_acc are integers denoting log2(e) where e is the estimated
relative accuracy of the respective complex part, but may be anything
if the corresponding complex part is None.

"""


def fastlog(x):
    """Fast approximation of log2(x) for an mpf value tuple x.

    Notes: Calculated as exponent + width of mantissa. This is an
    approximation for two reasons: 1) it gives the ceil(log2(abs(x)))
    value and 2) it is too high by 1 in the case that x is an exact
    power of 2. Although this is easy to remedy by testing to see if
    the odd mpf mantissa is 1 (indicating that one was dealing with
    an exact power of 2) that would decrease the speed and is not
    necessary as this is only being used as an approximation for the
    number of bits in x. The correct return value could be written as
    "x[2] + (x[3] if x[1] != 1 else 0)".
        Since mpf tuples always have an odd mantissa, no check is done
    to see if the mantissa is a multiple of 2 (in which case the
    result would be too large by 1).

    Examples
    ========

    >>> from sympy import log
    >>> from sympy.core.evalf import fastlog, bitcount
    >>> s, m, e = 0, 5, 1
    >>> bc = bitcount(m)
    >>> n = [1, -1][s]*m*2**e
    >>> n, (log(n)/log(2)).evalf(2), fastlog((s, m, e, bc))
    (10, 3.3, 4)
    """

    if not x or x == fzero:
        return MINUS_INF
    return x[2] + x[3]


def pure_complex(v, or_real=False):
    """Return a and b if v matches a + I*b where b is not zero and
    a and b are Numbers, else None. If `or_real` is True then 0 will
    be returned for `b` if `v` is a real number.

    >>> from sympy.core.evalf import pure_complex
    >>> from sympy import sqrt, I, S
    >>> a, b, surd = S(2), S(3), sqrt(2)
    >>> pure_complex(a)
    >>> pure_complex(a, or_real=True)
    (2, 0)
    >>> pure_complex(surd)
    >>> pure_complex(a + b*I)
    (2, 3)
    >>> pure_complex(I)
    (0, 1)
    """
    h, t = v.as_coeff_Add()
    if not t:
        if or_real:
            return h, t
        return
    c, i = t.as_coeff_Mul()
    if i is S.ImaginaryUnit:
        return h, c


def scaled_zero(mag, sign=1):
    """Return an mpf representing a power of two with magnitude ``mag``
    and -1 for precision. Or, if ``mag`` is a scaled_zero tuple, then just
    remove the sign from within the list that it was initially wrapped
    in.

    Examples
    ========

    >>> from sympy.core.evalf import scaled_zero
    >>> from sympy import Float
    >>> z, p = scaled_zero(100)
    >>> z, p
    (([0], 1, 100, 1), -1)
    >>> ok = scaled_zero(z)
    >>> ok
    (0, 1, 100, 1)
    >>> Float(ok)
    1.26765060022823e+30
    >>> Float(ok, p)
    0.e+30
    >>> ok, p = scaled_zero(100, -1)
    >>> Float(scaled_zero(ok), p)
    -0.e+30
    """
    if type(mag) is tuple and len(mag) == 4 and iszero(mag, scaled=True):
        return (mag[0][0],) + mag[1:]
    elif isinstance(mag, SYMPY_INTS):
        if sign not in [-1, 1]:
            raise ValueError('sign must be +/-1')
        rv, p = mpf_shift(fone, mag), -1
        s = 0 if sign == 1 else 1
        rv = ([s],) + rv[1:]
        return rv, p
    else:
        raise ValueError('scaled zero expects int or scaled_zero tuple.')


def iszero(mpf, scaled=False):
    if not scaled:
        return not mpf or not mpf[1] and not mpf[-1]
    return mpf and type(mpf[0]) is list and mpf[1] == mpf[-1] == 1


def complex_accuracy(result):
    """
    Returns relative accuracy of a complex number with given accuracies
    for the real and imaginary parts. The relative accuracy is defined
    in the complex norm sense as ||z|+|error|| / |z| where error
    is equal to (real absolute error) + (imag absolute error)*i.

    The full expression for the (logarithmic) error can be approximated
    easily by using the max norm to approximate the complex norm.

    In the worst case (re and im equal), this is wrong by a factor
    sqrt(2), or by log2(sqrt(2)) = 0.5 bit.
    """
    re, im, re_acc, im_acc = result
    if not im:
        if not re:
            return INF
        return re_acc
    if not re:
        return im_acc
    re_size = fastlog(re)
    im_size = fastlog(im)
    absolute_error = max(re_size - re_acc, im_size - im_acc)
    relative_error = absolute_error - max(re_size, im_size)
    return -relative_error


def get_abs(expr, prec, options):
    re, im, re_acc, im_acc = evalf(expr, prec + 2, options)

    if not re:
        re, re_acc, im, im_acc = im, im_acc, re, re_acc
    if im:
        if expr.is_number:
            abs_expr, _, acc, _ = evalf(abs(N(expr, prec + 2)),
                                        prec + 2, options)
            return abs_expr, None, acc, None
        else:
            if 'subs' in options:
                return libmp.mpc_abs((re, im), prec), None, re_acc, None
            return abs(expr), None, prec, None
    elif re:
        return mpf_abs(re), None, re_acc, None
    else:
        return None, None, None, None


def get_complex_part(expr, no, prec, options):
    """no = 0 for real part, no = 1 for imaginary part"""
    workprec = prec
    i = 0
    while 1:
        res = evalf(expr, workprec, options)
        value, accuracy = res[no::2]
        # XXX is the last one correct? Consider re((1+I)**2).n()
        if (not value) or accuracy >= prec or -value[2] > prec:
            return value, None, accuracy, None
        workprec += max(30, 2**i)
        i += 1


def evalf_abs(expr, prec, options):
    return get_abs(expr.args[0], prec, options)


def evalf_re(expr, prec, options):
    return get_complex_part(expr.args[0], 0, prec, options)


def evalf_im(expr, prec, options):
    return get_complex_part(expr.args[0], 1, prec, options)


def finalize_complex(re, im, prec):
    if re == fzero and im == fzero:
        raise ValueError("got complex zero with unknown accuracy")
    elif re == fzero:
        return None, im, None, prec
    elif im == fzero:
        return re, None, prec, None

    size_re = fastlog(re)
    size_im = fastlog(im)
    if size_re > size_im:
        re_acc = prec
        im_acc = prec + min(-(size_re - size_im), 0)
    else:
        im_acc = prec
        re_acc = prec + min(-(size_im - size_re), 0)
    return re, im, re_acc, im_acc


def chop_parts(value, prec):
    """
    Chop off tiny real or complex parts.
    """
    re, im, re_acc, im_acc = value
    # Method 1: chop based on absolute value
    if re and re not in _infs_nan and (fastlog(re) < -prec + 4):
        re, re_acc = None, None
    if im and im not in _infs_nan and (fastlog(im) < -prec + 4):
        im, im_acc = None, None
    # Method 2: chop if inaccurate and relatively small
    if re and im:
        delta = fastlog(re) - fastlog(im)
        if re_acc < 2 and (delta - re_acc <= -prec + 4):
            re, re_acc = None, None
        if im_acc < 2 and (delta - im_acc >= prec - 4):
            im, im_acc = None, None
    return re, im, re_acc, im_acc


def check_target(expr, result, prec):
    a = complex_accuracy(result)
    if a < prec:
        raise PrecisionExhausted("Failed to distinguish the expression: \n\n%s\n\n"
            "from zero. Try simplifying the input, using chop=True, or providing "
            "a higher maxn for evalf" % (expr))


def get_integer_part(expr, no, options, return_ints=False):
    """
    With no = 1, computes ceiling(expr)
    With no = -1, computes floor(expr)

    Note: this function either gives the exact result or signals failure.
    """
    from sympy.functions.elementary.complexes import re, im
    # The expression is likely less than 2^30 or so
    assumed_size = 30
    ire, iim, ire_acc, iim_acc = evalf(expr, assumed_size, options)

    # We now know the size, so we can calculate how much extra precision
    # (if any) is needed to get within the nearest integer
    if ire and iim:
        gap = max(fastlog(ire) - ire_acc, fastlog(iim) - iim_acc)
    elif ire:
        gap = fastlog(ire) - ire_acc
    elif iim:
        gap = fastlog(iim) - iim_acc
    else:
        # ... or maybe the expression was exactly zero
        return None, None, None, None

    margin = 10

    if gap >= -margin:
        ire, iim, ire_acc, iim_acc = \
            evalf(expr, margin + assumed_size + gap, options)

    # We can now easily find the nearest integer, but to find floor/ceil, we
    # must also calculate whether the difference to the nearest integer is
    # positive or negative (which may fail if very close).
    def calc_part(expr, nexpr):
        from sympy.core.add import Add
        nint = int(to_int(nexpr, rnd))
        n, c, p, b = nexpr
        is_int = (p == 0)
        if not is_int:
            # if there are subs and they all contain integer re/im parts
            # then we can (hopefully) safely substitute them into the
            # expression
            s = options.get('subs', False)
            if s:
                doit = True
                from sympy.core.compatibility import as_int
                for v in s.values():
                    try:
                        as_int(v)
                    except ValueError:
                        try:
                            [as_int(i) for i in v.as_real_imag()]
                            continue
                        except (ValueError, AttributeError):
                            doit = False
                            break
                if doit:
                    expr = expr.subs(s)

            expr = Add(expr, -nint, evaluate=False)
            x, _, x_acc, _ = evalf(expr, 10, options)
            try:
                check_target(expr, (x, None, x_acc, None), 3)
            except PrecisionExhausted:
                if not expr.equals(0):
                    raise PrecisionExhausted
                x = fzero
            nint += int(no*(mpf_cmp(x or fzero, fzero) == no))
        nint = from_int(nint)
        return nint, fastlog(nint) + 10

    re_, im_, re_acc, im_acc = None, None, None, None

    if ire:
        re_, re_acc = calc_part(re(expr, evaluate=False), ire)
    if iim:
        im_, im_acc = calc_part(im(expr, evaluate=False), iim)

    if return_ints:
        return int(to_int(re_ or fzero)), int(to_int(im_ or fzero))
    return re_, im_, re_acc, im_acc


def evalf_ceiling(expr, prec, options):
    return get_integer_part(expr.args[0], 1, options)


def evalf_floor(expr, prec, options):
    return get_integer_part(expr.args[0], -1, options)

#----------------------------------------------------------------------------#
#                                                                            #
#                            Arithmetic operations                           #
#                                                                            #
#----------------------------------------------------------------------------#


def add_terms(terms, prec, target_prec):
    """
    Helper for evalf_add. Adds a list of (mpfval, accuracy) terms.

    Returns
    -------

    - None, None if there are no non-zero terms;
    - terms[0] if there is only 1 term;
    - scaled_zero if the sum of the terms produces a zero by cancellation
      e.g. mpfs representing 1 and -1 would produce a scaled zero which need
      special handling since they are not actually zero and they are purposely
      malformed to ensure that they can't be used in anything but accuracy
      calculations;
    - a tuple that is scaled to target_prec that corresponds to the
      sum of the terms.

    The returned mpf tuple will be normalized to target_prec; the input
    prec is used to define the working precision.

    XXX explain why this is needed and why one can't just loop using mpf_add
    """

    terms = [t for t in terms if not iszero(t)]
    if not terms:
        return None, None
    elif len(terms) == 1:
        return terms[0]

    # see if any argument is NaN or oo and thus warrants a special return
    special = []
    from sympy.core.numbers import Float
    for t in terms:
        arg = Float._new(t[0], 1)
        if arg is S.NaN or arg.is_infinite:
            special.append(arg)
    if special:
        from sympy.core.add import Add
        rv = evalf(Add(*special), prec + 4, {})
        return rv[0], rv[2]

    working_prec = 2*prec
    sum_man, sum_exp, absolute_error = 0, 0, MINUS_INF

    for x, accuracy in terms:
        sign, man, exp, bc = x
        if sign:
            man = -man
        absolute_error = max(absolute_error, bc + exp - accuracy)
        delta = exp - sum_exp
        if exp >= sum_exp:
            # x much larger than existing sum?
            # first: quick test
            if ((delta > working_prec) and
                ((not sum_man) or
                 delta - bitcount(abs(sum_man)) > working_prec)):
                sum_man = man
                sum_exp = exp
            else:
                sum_man += (man << delta)
        else:
            delta = -delta
            # x much smaller than existing sum?
            if delta - bc > working_prec:
                if not sum_man:
                    sum_man, sum_exp = man, exp
            else:
                sum_man = (sum_man << delta) + man
                sum_exp = exp
    if not sum_man:
        return scaled_zero(absolute_error)
    if sum_man < 0:
        sum_sign = 1
        sum_man = -sum_man
    else:
        sum_sign = 0
    sum_bc = bitcount(sum_man)
    sum_accuracy = sum_exp + sum_bc - absolute_error
    r = normalize(sum_sign, sum_man, sum_exp, sum_bc, target_prec,
        rnd), sum_accuracy
    return r


def evalf_add(v, prec, options):
    res = pure_complex(v)
    if res:
        h, c = res
        re, _, re_acc, _ = evalf(h, prec, options)
        im, _, im_acc, _ = evalf(c, prec, options)
        return re, im, re_acc, im_acc

    oldmaxprec = options.get('maxprec', DEFAULT_MAXPREC)

    i = 0
    target_prec = prec
    while 1:
        options['maxprec'] = min(oldmaxprec, 2*prec)

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
        # Exact
        if not p:
            return fone, None, prec, None
        # Exponentiation by p magnifies relative error by |p|, so the
        # base must be evaluated with increased precision if p is large
        prec += int(math.log(abs(p), 2))
        re, im, re_acc, im_acc = evalf(base, prec + 5, options)
        # Real to integer power
        if re and not im:
            return mpf_pow_int(re, p, target_prec), None, target_prec, None
        # (x*I)**n = I**n * x**n
        if im and not re:
            z = mpf_pow_int(im, p, target_prec)
            case = p % 4
            if case == 0:
                return z, None, target_prec, None
            if case == 1:
                return None, z, None, target_prec
            if case == 2:
                return mpf_neg(z), None, target_prec, None
            if case == 3:
                return None, mpf_neg(z), None, target_prec
        # Zero raised to an integer power
        if not re:
            return None, None, None, None
        # General complex number to arbitrary integer power
        re, im = libmp.mpc_pow_int((re, im), p, prec)
        # Assumes full accuracy in input
        return finalize_complex(re, im, target_prec)

    # Pure square root
    if exp is S.Half:
        xre, xim, _, _ = evalf(base, prec + 5, options)
        # General complex square root
        if xim:
            re, im = libmp.mpc_sqrt((xre or fzero, xim), prec)
            return finalize_complex(re, im, prec)
        if not xre:
            return None, None, None, None
        # Square root of a negative real number
        if mpf_lt(xre, fzero):
            return None, mpf_sqrt(mpf_neg(xre), prec), None, prec
        # Positive square root
        return mpf_sqrt(xre, prec), None, prec, None

    # We first evaluate the exponent to find its magnitude
    # This determines the working precision that must be used
    prec += 10
    yre, yim, _, _ = evalf(exp, prec, options)
    # Special cases: x**0
    if not (yre or yim):
        return fone, None, prec, None

    ysize = fastlog(yre)
    # Restart if too big
    # XXX: prec + ysize might exceed maxprec
    if ysize > 5:
        prec += ysize
        yre, yim, _, _ = evalf(exp, prec, options)

    # Pure exponential function; no need to evalf the base
    if base is S.Exp1:
        if yim:
            re, im = libmp.mpc_exp((yre or fzero, yim), prec)
            return finalize_complex(re, im, target_prec)
        return mpf_exp(yre, target_prec), None, target_prec, None

    xre, xim, _, _ = evalf(base, prec + 5, options)
    # 0**y
    if not (xre or xim):
        return None, None, None, None

    # (real ** complex) or (complex ** complex)
    if yim:
        re, im = libmp.mpc_pow(
            (xre or fzero, xim or fzero), (yre or fzero, yim),
            target_prec)
        return finalize_complex(re, im, target_prec)
    # complex ** real
    if xim:
        re, im = libmp.mpc_pow_mpf((xre or fzero, xim), yre, target_prec)
        return finalize_complex(re, im, target_prec)
    # negative ** real
    elif mpf_lt(xre, fzero):
        re, im = libmp.mpc_pow_mpf((xre, fzero), yre, target_prec)
        return finalize_complex(re, im, target_prec)
    # positive ** real
    else:
        return mpf_pow(xre, yre, target_prec), None, target_prec, None


#----------------------------------------------------------------------------#
#                                                                            #
#                            Special functions                               #
#                                                                            #
#----------------------------------------------------------------------------#
def evalf_trig(v, prec, options):
    """
    This function handles sin and cos of complex arguments.

    TODO: should also handle tan of complex arguments.
    """
    from sympy import cos, sin
    if isinstance(v, cos):
        func = mpf_cos
    elif isinstance(v, sin):
        func = mpf_sin
    else:
        raise NotImplementedError
    arg = v.args[0]
    # 20 extra bits is possibly overkill. It does make the need
    # to restart very unlikely
    xprec = prec + 20
    re, im, re_acc, im_acc = evalf(arg, xprec, options)
    if im:
        if 'subs' in options:
            v = v.subs(options['subs'])
        return evalf(v._eval_evalf(prec), prec, options)
    if not re:
        if isinstance(v, cos):
            return fone, None, prec, None
        elif isinstance(v, sin):
            return None, None, None, None
        else:
            raise NotImplementedError
    # For trigonometric functions, we are interested in the
    # fixed-point (absolute) accuracy of the argument.
    xsize = fastlog(re)
    # Magnitude <= 1.0. OK to compute directly, because there is no
    # danger of hitting the first root of cos (with sin, magnitude
    # <= 2.0 would actually be ok)
    if xsize < 1:
        return func(re, prec, rnd), None, prec, None
    # Very large
    if xsize >= 10:
        xprec = prec + xsize
        re, im, re_acc, im_acc = evalf(arg, xprec, options)
    # Need to repeat in case the argument is very close to a
    # multiple of pi (or pi/2), hitting close to a root
    while 1:
        y = func(re, prec, rnd)
        ysize = fastlog(y)
        gap = -ysize
        accuracy = (xprec - xsize) - gap
        if accuracy < prec:
            if options.get('verbose'):
                print("SIN/COS", accuracy, "wanted", prec, "gap", gap)
                print(to_str(y, 10))
            if xprec > options.get('maxprec', DEFAULT_MAXPREC):
                return y, None, accuracy, None
            xprec += gap
            re, im, re_acc, im_acc = evalf(arg, xprec, options)
            continue
        else:
            return y, None, prec, None


def evalf_log(expr, prec, options):
    from sympy import Abs, Add, log
    if len(expr.args)>1:
        expr = expr.doit()
        return evalf(expr, prec, options)
    arg = expr.args[0]
    workprec = prec + 10
    xre, xim, xacc, _ = evalf(arg, workprec, options)

    if xim:
        # XXX: use get_abs etc instead
        re = evalf_log(
            log(Abs(arg, evaluate=False), evaluate=False), prec, options)
        im = mpf_atan2(xim, xre or fzero, prec)
        return re[0], im, re[2], prec

    imaginary_term = (mpf_cmp(xre, fzero) < 0)

    re = mpf_log(mpf_abs(xre), prec, rnd)
    size = fastlog(re)
    if prec - size > workprec and re != fzero:
        # We actually need to compute 1+x accurately, not x
        arg = Add(S.NegativeOne, arg, evaluate=False)
        xre, xim, _, _ = evalf_add(arg, prec, options)
        prec2 = workprec - fastlog(xre)
        # xre is now x - 1 so we add 1 back here to calculate x
        re = mpf_log(mpf_abs(mpf_add(xre, fone, prec2)), prec, rnd)

    re_acc = prec

    if imaginary_term:
        return re, mpf_pi(prec), re_acc, prec
    else:
        return re, None, re_acc, None


def evalf_atan(v, prec, options):
    arg = v.args[0]
    xre, xim, reacc, imacc = evalf(arg, prec + 5, options)
    if xre is xim is None:
        return (None,)*4
    if xim:
        raise NotImplementedError
    return mpf_atan(xre, prec, rnd), None, prec, None


def evalf_subs(prec, subs):
    """ Change all Float entries in `subs` to have precision prec. """
    newsubs = {}
    for a, b in subs.items():
        b = S(b)
        if b.is_Float:
            b = b._eval_evalf(prec)
        newsubs[a] = b
    return newsubs


def evalf_piecewise(expr, prec, options):
    from sympy import Float, Integer
    if 'subs' in options:
        expr = expr.subs(evalf_subs(prec, options['subs']))
        newopts = options.copy()
        del newopts['subs']
        if hasattr(expr, 'func'):
            return evalf(expr, prec, newopts)
        if type(expr) == float:
            return evalf(Float(expr), prec, newopts)
        if type(expr) == int:
            return evalf(Integer(expr), prec, newopts)

    # We still have undefined symbols
    raise NotImplementedError


def evalf_bernoulli(expr, prec, options):
    arg = expr.args[0]
    if not arg.is_Integer:
        raise ValueError("Bernoulli number index must be an integer")
    n = int(arg)
    b = mpf_bernoulli(n, prec, rnd)
    if b == fzero:
        return None, None, None, None
    return b, None, prec, None

#----------------------------------------------------------------------------#
#                                                                            #
#                            High-level operations                           #
#                                                                            #
#----------------------------------------------------------------------------#


def as_mpmath(x, prec, options):
    from sympy.core.numbers import Infinity, NegativeInfinity, Zero
    x = sympify(x)
    if isinstance(x, Zero) or x == 0:
        return mpf(0)
    if isinstance(x, Infinity):
        return mpf('inf')
    if isinstance(x, NegativeInfinity):
        return mpf('-inf')
    # XXX
    re, im, _, _ = evalf(x, prec, options)
    if im:
        return mpc(re or fzero, im)
    return mpf(re)


def do_integral(expr, prec, options):
    func = expr.args[0]
    x, xlow, xhigh = expr.args[1]
    if xlow == xhigh:
        xlow = xhigh = 0
    elif x not in func.free_symbols:
        # only the difference in limits matters in this case
        # so if there is a symbol in common that will cancel
        # out when taking the difference, then use that
        # difference
        if xhigh.free_symbols & xlow.free_symbols:
            diff = xhigh - xlow
            if not diff.free_symbols:
                xlow, xhigh = 0, diff

    oldmaxprec = options.get('maxprec', DEFAULT_MAXPREC)
    options['maxprec'] = min(oldmaxprec, 2*prec)

    with workprec(prec + 5):
        xlow = as_mpmath(xlow, prec + 15, options)
        xhigh = as_mpmath(xhigh, prec + 15, options)

        # Integration is like summation, and we can phone home from
        # the integrand function to update accuracy summation style
        # Note that this accuracy is inaccurate, since it fails
        # to account for the variable quadrature weights,
        # but it is better than nothing

        from sympy import cos, sin, Wild

        have_part = [False, False]
        max_real_term = [MINUS_INF]
        max_imag_term = [MINUS_INF]

        def f(t):
            re, im, re_acc, im_acc = evalf(func, mp.prec, {'subs': {x: t}})

            have_part[0] = re or have_part[0]
            have_part[1] = im or have_part[1]

            max_real_term[0] = max(max_real_term[0], fastlog(re))
            max_imag_term[0] = max(max_imag_term[0], fastlog(im))

            if im:
                return mpc(re or fzero, im)
            return mpf(re or fzero)

        if options.get('quad') == 'osc':
            A = Wild('A', exclude=[x])
            B = Wild('B', exclude=[x])
            D = Wild('D')
            m = func.match(cos(A*x + B)*D)
            if not m:
                m = func.match(sin(A*x + B)*D)
            if not m:
                raise ValueError("An integrand of the form sin(A*x+B)*f(x) "
                  "or cos(A*x+B)*f(x) is required for oscillatory quadrature")
            period = as_mpmath(2*S.Pi/m[A], prec + 15, options)
            result = quadosc(f, [xlow, xhigh], period=period)
            # XXX: quadosc does not do error detection yet
            quadrature_error = MINUS_INF
        else:
            result, quadrature_error = quadts(f, [xlow, xhigh], error=1)
            quadrature_error = fastlog(quadrature_error._mpf_)

    options['maxprec'] = oldmaxprec

    if have_part[0]:
        re = result.real._mpf_
        if re == fzero:
            re, re_acc = scaled_zero(
                min(-prec, -max_real_term[0], -quadrature_error))
            re = scaled_zero(re)  # handled ok in evalf_integral
        else:
            re_acc = -max(max_real_term[0] - fastlog(re) -
                          prec, quadrature_error)
    else:
        re, re_acc = None, None

    if have_part[1]:
        im = result.imag._mpf_
        if im == fzero:
            im, im_acc = scaled_zero(
                min(-prec, -max_imag_term[0], -quadrature_error))
            im = scaled_zero(im)  # handled ok in evalf_integral
        else:
            im_acc = -max(max_imag_term[0] - fastlog(im) -
                          prec, quadrature_error)
    else:
        im, im_acc = None, None

    result = re, im, re_acc, im_acc
    return result


def evalf_integral(expr, prec, options):
    limits = expr.limits
    if len(limits) != 1 or len(limits[0]) != 3:
        raise NotImplementedError
    workprec = prec
    i = 0
    maxprec = options.get('maxprec', INF)
    while 1:
        result = do_integral(expr, workprec, options)
        accuracy = complex_accuracy(result)
        if accuracy >= prec:  # achieved desired precision
            break
        if workprec >= maxprec:  # can't increase accuracy any more
            break
        if accuracy == -1:
            # maybe the answer really is zero and maybe we just haven't increased
            # the precision enough. So increase by doubling to not take too long
            # to get to maxprec.
            workprec *= 2
        else:
            workprec += max(prec, 2**i)
        workprec = min(workprec, maxprec)
        i += 1
    return result


def check_convergence(numer, denom, n):
    """
    Returns (h, g, p) where
    -- h is:
        > 0 for convergence of rate 1/factorial(n)**h
        < 0 for divergence of rate factorial(n)**(-h)
        = 0 for geometric or polynomial convergence or divergence

    -- abs(g) is:
        > 1 for geometric convergence of rate 1/h**n
        < 1 for geometric divergence of rate h**n
        = 1 for polynomial convergence or divergence

        (g < 0 indicates an alternating series)

    -- p is:
        > 1 for polynomial convergence of rate 1/n**h
        <= 1 for polynomial divergence of rate n**(-h)

    """
    from sympy import Poly
    npol = Poly(numer, n)
    dpol = Poly(denom, n)
    p = npol.degree()
    q = dpol.degree()
    rate = q - p
    if rate:
        return rate, None, None
    constant = dpol.LC() / npol.LC()
    if abs(constant) != 1:
        return rate, constant, None
    if npol.degree() == dpol.degree() == 0:
        return rate, constant, 0
    pc = npol.all_coeffs()[1]
    qc = dpol.all_coeffs()[1]
    return rate, constant, (qc - pc)/dpol.LC()


def hypsum(expr, n, start, prec):
    """
    Sum a rapidly convergent infinite hypergeometric series with
    given general term, e.g. e = hypsum(1/factorial(n), n). The
    quotient between successive terms must be a quotient of integer
    polynomials.
    """
    from sympy import Float, hypersimp, lambdify

    if prec == float('inf'):
        raise NotImplementedError('does not support inf prec')

    if start:
        expr = expr.subs(n, n + start)
    hs = hypersimp(expr, n)
    if hs is None:
        raise NotImplementedError("a hypergeometric series is required")
    num, den = hs.as_numer_denom()

    func1 = lambdify(n, num)
    func2 = lambdify(n, den)

    h, g, p = check_convergence(num, den, n)

    if h < 0:
        raise ValueError("Sum diverges like (n!)^%i" % (-h))

    term = expr.subs(n, 0)
    if not term.is_Rational:
        raise NotImplementedError("Non rational term functionality is not implemented.")

    # Direct summation if geometric or faster
    if h > 0 or (h == 0 and abs(g) > 1):
        term = (MPZ(term.p) << prec) // term.q
        s = term
        k = 1
        while abs(term) > 5:
            term *= MPZ(func1(k - 1))
            term //= MPZ(func2(k - 1))
            s += term
            k += 1
        return from_man_exp(s, -prec)
    else:
        alt = g < 0
        if abs(g) < 1:
            raise ValueError("Sum diverges like (%i)^n" % abs(1/g))
        if p < 1 or (p == 1 and not alt):
            raise ValueError("Sum diverges like n^%i" % (-p))
        # We have polynomial convergence: use Richardson extrapolation
        vold = None
        ndig = prec_to_dps(prec)
        while True:
            # Need to use at least quad precision because a lot of cancellation
            # might occur in the extrapolation process; we check the answer to
            # make sure that the desired precision has been reached, too.
            prec2 = 4*prec
            term0 = (MPZ(term.p) << prec2) // term.q

            def summand(k, _term=[term0]):
                if k:
                    k = int(k)
                    _term[0] *= MPZ(func1(k - 1))
                    _term[0] //= MPZ(func2(k - 1))
                return make_mpf(from_man_exp(_term[0], -prec2))

            with workprec(prec):
                v = nsum(summand, [0, mpmath_inf], method='richardson')
            vf = Float(v, ndig)
            if vold is not None and vold == vf:
                break
            prec += prec  # double precision each time
            vold = vf

        return v._mpf_


def evalf_prod(expr, prec, options):
    from sympy import Sum
    if all((l[1] - l[2]).is_Integer for l in expr.limits):
        re, im, re_acc, im_acc = evalf(expr.doit(), prec=prec, options=options)
    else:
        re, im, re_acc, im_acc = evalf(expr.rewrite(Sum), prec=prec, options=options)
    return re, im, re_acc, im_acc


def evalf_sum(expr, prec, options):
    from sympy import Float
    if 'subs' in options:
        expr = expr.subs(options['subs'])
    func = expr.function
    limits = expr.limits
    if len(limits) != 1 or len(limits[0]) != 3:
        raise NotImplementedError
    if func is S.Zero:
        return mpf(0), None, None, None
    prec2 = prec + 10
    try:
        n, a, b = limits[0]
        if b != S.Infinity or a != int(a):
            raise NotImplementedError
        # Use fast hypergeometric summation if possible
        v = hypsum(func, n, int(a), prec2)
        delta = prec - fastlog(v)
        if fastlog(v) < -10:
            v = hypsum(func, n, int(a), delta)
        return v, None, min(prec, delta), None
    except NotImplementedError:
        # Euler-Maclaurin summation for general series
        eps = Float(2.0)**(-prec)
        for i in range(1, 5):
            m = n = 2**i * prec
            s, err = expr.euler_maclaurin(m=m, n=n, eps=ep
```


# sympy/core/tests/test_evalf.py

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


def test_evalf_rump():
    a = 1335*y**6/4 + x**2*(11*x**2*y**2 - y**6 - 121*y**4 - 2) + 11*y**8/2 + x/(2*y)
    assert NS(a, 15, subs={x: 77617, y: 33096}) == '-0.827396059946821'


def test_evalf_complex():
    assert NS('2*sqrt(pi)*I', 10) == '3.544907702*I'
    assert NS('3+3*I', 15) == '3.00000000000000 + 3.00000000000000*I'
    assert NS('E+pi*I', 15) == '2.71828182845905 + 3.14159265358979*I'
    assert NS('pi * (3+4*I)', 15) == '9.42477796076938 + 12.5663706143592*I'
    assert NS('I*(2+I)', 15) == '-1.00000000000000 + 2.00000000000000*I'


@XFAIL
def test_evalf_complex_bug():
    assert NS('(pi+E*I)*(E+pi*I)', 15) in ('0.e-15 + 17.25866050002*I',
              '0.e-17 + 17.25866050002*I', '-0.e-17 + 17.25866050002*I')


def test_evalf_complex_powers():
    assert NS('(E+pi*I)**100000000000000000') == \
        '-3.58896782867793e+61850354284995199 + 4.58581754997159e+61850354284995199*I'
    # XXX: rewrite if a+a*I simplification introduced in sympy
    #assert NS('(pi + pi*I)**2') in ('0.e-15 + 19.7392088021787*I', '0.e-16 + 19.7392088021787*I')
    assert NS('(pi + pi*I)**2', chop=True) == '19.7392088021787*I'
    assert NS(
        '(pi + 1/10**8 + pi*I)**2') == '6.2831853e-8 + 19.7392088650106*I'
    assert NS('(pi + 1/10**12 + pi*I)**2') == '6.283e-12 + 19.7392088021850*I'
    assert NS('(pi + pi*I)**4', chop=True) == '-389.636364136010'
    assert NS(
        '(pi + 1/10**8 + pi*I)**4') == '-389.636366616512 + 2.4805021e-6*I'
    assert NS('(pi + 1/10**12 + pi*I)**4') == '-389.636364136258 + 2.481e-10*I'
    assert NS(
        '(10000*pi + 10000*pi*I)**4', chop=True) == '-3.89636364136010e+18'


@XFAIL
def test_evalf_complex_powers_bug():
    assert NS('(pi + pi*I)**4') == '-389.63636413601 + 0.e-14*I'


def test_evalf_exponentiation():
    assert NS(sqrt(-pi)) == '1.77245385090552*I'
    assert NS(Pow(pi*I, Rational(
        1, 2), evaluate=False)) == '1.25331413731550 + 1.25331413731550*I'
    assert NS(pi**I) == '0.413292116101594 + 0.910598499212615*I'
    assert NS(pi**(E + I/3)) == '20.8438653991931 + 8.36343473930031*I'
    assert NS((pi + I/3)**(E + I/3)) == '17.2442906093590 + 13.6839376767037*I'
    assert NS(exp(pi)) == '23.1406926327793'
    assert NS(exp(pi + E*I)) == '-21.0981542849657 + 9.50576358282422*I'
    assert NS(pi**pi) == '36.4621596072079'
    assert NS((-pi)**pi) == '-32.9138577418939 - 15.6897116534332*I'
    assert NS((-pi)**(-pi)) == '-0.0247567717232697 + 0.0118013091280262*I'

# An example from Smith, "Multiple Precision Complex Arithmetic and Functions"


def test_evalf_complex_cancellation():
    A = Rational('63287/100000')
    B = Rational('52498/100000')
    C = Rational('69301/100000')
    D = Rational('83542/100000')
    F = Rational('2231321613/2500000000')
    # XXX: the number of returned mantissa digits in the real part could
    # change with the implementation. What matters is that the returned digits are
    # correct; those that are showing now are correct.
    # >>> ((A+B*I)*(C+D*I)).expand()
    # 64471/10000000000 + 2231321613*I/2500000000
    # >>> 2231321613*4
    # 8925286452L
    assert NS((A + B*I)*(C + D*I), 6) == '6.44710e-6 + 0.892529*I'
    assert NS((A + B*I)*(C + D*I), 10) == '6.447100000e-6 + 0.8925286452*I'
    assert NS((A + B*I)*(
        C + D*I) - F*I, 5) in ('6.4471e-6 + 0.e-14*I', '6.4471e-6 - 0.e-14*I')


def test_evalf_logs():
    assert NS("log(3+pi*I)", 15) == '1.46877619736226 + 0.808448792630022*I'
    assert NS("log(pi*I)", 15) == '1.14472988584940 + 1.57079632679490*I'
    assert NS('log(-1 + 0.00001)', 2) == '-1.0e-5 + 3.1*I'
    assert NS('log(100, 10, evaluate=False)', 15) == '2.00000000000000'
    assert NS('-2*I*log(-(-1)**(S(1)/9))', 15) == '-5.58505360638185'


def test_evalf_trig():
    assert NS('sin(1)', 15) == '0.841470984807897'
    assert NS('cos(1)', 15) == '0.540302305868140'
    assert NS('sin(10**-6)', 15) == '9.99999999999833e-7'
    assert NS('cos(10**-6)', 15) == '0.999999999999500'
    assert NS('sin(E*10**100)', 15) == '0.409160531722613'
    # Some input near roots
    assert NS(sin(exp(pi*sqrt(163))*pi), 15) == '-2.35596641936785e-12'
    assert NS(sin(pi*10**100 + Rational(7, 10**5), evaluate=False), 15, maxn=120) == \
        '6.99999999428333e-5'
    assert NS(sin(Rational(7, 10**5), evaluate=False), 15) == \
        '6.99999999428333e-5'

# Check detection of various false identities


def test_evalf_near_integers():
    # Binet's formula
    f = lambda n: ((1 + sqrt(5))**n)/(2**n * sqrt(5))
    assert NS(f(5000) - fibonacci(5000), 10, maxn=1500) == '5.156009964e-1046'
    # Some near-integer identities from
    # http://mathworld.wolfram.com/AlmostInteger.html
    assert NS('sin(2017*2**(1/5))', 15) == '-1.00000000000000'
    assert NS('sin(2017*2**(1/5))', 20) == '-0.99999999999999997857'
    assert NS('1+sin(2017*2**(1/5))', 15) == '2.14322287389390e-17'
    assert NS('45 - 613*E/37 + 35/991', 15) == '6.03764498766326e-11'


def test_evalf_ramanujan():
    assert NS(exp(pi*sqrt(163)) - 640320**3 - 744, 10) == '-7.499274028e-13'
    # A related identity
    A = 262537412640768744*exp(-pi*sqrt(163))
    B = 196884*exp(-2*pi*sqrt(163))
    C = 103378831900730205293632*exp(-3*pi*sqrt(163))
    assert NS(1 - A - B + C, 10) == '1.613679005e-59'

# Input that for various reasons have failed at some point


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
    b = floor(log(8)/log(2), evaluate=False)
    assert a.evalf() == 3
    assert b.evalf() == 3
    # equals, as a fallback, can still fail but it might succeed as here
    assert ceiling(10*(sin(1)**2 + cos(1)**2)) == 10

    assert int(floor(factorial(50)/E, evaluate=False).evalf(70)) == \
        long(11188719610782480504630258070757734324011354208865721592720336800)
    assert int(ceiling(factorial(50)/E, evaluate=False).evalf(70)) == \
        long(11188719610782480504630258070757734324011354208865721592720336801)
    assert int(floor((GoldenRatio**999 / sqrt(5) + Rational(1, 2)))
               .evalf(1000)) == fibonacci(999)
    assert int(floor((GoldenRatio**1000 / sqrt(5) + Rational(1, 2)))
               .evalf(1000)) == fibonacci(1000)

    assert ceiling(x).evalf(subs={x: 3}) == 3
    assert ceiling(x).evalf(subs={x: 3*I}) == 3*I
    assert ceiling(x).evalf(subs={x: 2 + 3*I}) == 2 + 3*I
    assert ceiling(x).evalf(subs={x: 3.}) == 3
    assert ceiling(x).evalf(subs={x: 3.*I}) == 3*I
    assert ceiling(x).evalf(subs={x: 2. + 3*I}) == 2 + 3*I


def test_evalf_trig_zero_detection():
    a = sin(160*pi, evaluate=False)
    t = a.evalf(maxn=100)
    assert abs(t) < 1e-100
    assert t._prec < 2
    assert a.evalf(chop=True) == 0
    raises(PrecisionExhausted, lambda: a.evalf(strict=True))


def test_evalf_sum():
    assert Sum(n,(n,1,2)).evalf() == 3.
    assert Sum(n,(n,1,2)).doit().evalf() == 3.
    # the next test should return instantly
    assert Sum(1/n,(n,1,2)).evalf() == 1.5

    # issue 8219
    assert Sum(E/factorial(n), (n, 0, oo)).evalf() == (E*E).evalf()
    # issue 8254
    assert Sum(2**n*n/factorial(n), (n, 0, oo)).evalf() == (2*E*E).evalf()
    # issue 8411
    s = Sum(1/x**2, (x, 100, oo))
    assert s.n() == s.doit().n()


def test_evalf_divergent_series():
    raises(ValueError, lambda: Sum(1/n, (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum(n/(n**2 + 1), (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum((-1)**n, (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum((-1)**n, (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum(n**2, (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum(2**n, (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum((-2)**n, (n, 1, oo)).evalf())
    raises(ValueError, lambda: Sum((2*n + 3)/(3*n**2 + 4), (n, 0, oo)).evalf())
    raises(ValueError, lambda: Sum((0.5*n**3)/(n**4 + 1), (n, 0, oo)).evalf())


def test_evalf_product():
    assert Product(n, (n, 1, 10)).evalf() == 3628800.
    assert Product(1 - S.Half**2/n**2, (n, 1, oo)).evalf(5)==0.63662
    assert Product(n, (n, -1, 3)).evalf() == 0


def test_evalf_py_methods():
    assert abs(float(pi + 1) - 4.1415926535897932) < 1e-10
    assert abs(complex(pi + 1) - 4.1415926535897932) < 1e-10
    assert abs(
        complex(pi + E*I) - (3.1415926535897931 + 2.7182818284590451j)) < 1e-10
    raises(TypeError, lambda: float(pi + x))


def test_evalf_power_subs_bugs():
    assert (x**2).evalf(subs={x: 0}) == 0
    assert sqrt(x).evalf(subs={x: 0}) == 0
    assert (x**Rational(2, 3)).evalf(subs={x: 0}) == 0
    assert (x**x).evalf(subs={x: 0}) == 1
    assert (3**x).evalf(subs={x: 0}) == 1
    assert exp(x).evalf(subs={x: 0}) == 1
    assert ((2 + I)**x).evalf(subs={x: 0}) == 1
    assert (0**x).evalf(subs={x: 0}) == 1


def test_evalf_arguments():
    raises(TypeError, lambda: pi.evalf(method="garbage"))


def test_implemented_function_evalf():
    from sympy.utilities.lambdify import implemented_function
    f = Function('f')
    f = implemented_function(f, lambda x: x + 1)
    assert str(f(x)) == "f(x)"
    assert str(f(2)) == "f(2)"
    assert f(2).evalf() == 3
    assert f(x).evalf() == f(x)
    del f._imp_     # XXX: due to caching _imp_ would influence all other tests


def test_evaluate_false():
    for no in [0, False]:
        assert Add(3, 2, evaluate=no).is_Add
        assert Mul(3, 2, evaluate=no).is_Mul
        assert Pow(3, 2, evaluate=no).is_Pow
    assert Pow(y, 2, evaluate=True) - Pow(y, 2, evaluate=True) == 0


def test_evalf_relational():
    assert Eq(x/5, y/10).evalf() == Eq(0.2*x, 0.1*y)


def test_issue_5486():
    assert not cos(sqrt(0.5 + I)).n().is_Function


def test_issue_5486_bug():
    from sympy import I, Expr
    assert abs(Expr._from_mpmath(I._to_mpmath(15), 15) - I) < 1.0e-15


def test_bugs():
    from sympy import polar_lift, re

    assert abs(re((1 + I)**2)) < 1e-15

    # anything that evalf's to 0 will do in place of polar_lift
    assert abs(polar_lift(0)).n() == 0


def test_subs():
    assert NS('besseli(-x, y) - besseli(x, y)', subs={x: 3.5, y: 20.0}) == \
        '-4.92535585957223e-10'
    assert NS('Piecewise((x, x>0)) + Piecewise((1-x, x>0))', subs={x: 0.1}) == \
        '1.00000000000000'
    raises(TypeError, lambda: x.evalf(subs=(x, 1)))


def test_issue_4956_5204():
    # issue 4956
    v = S('''(-27*12**(1/3)*sqrt(31)*I +
    27*2**(2/3)*3**(1/3)*sqrt(31)*I)/(-2511*2**(2/3)*3**(1/3) +
    (29*18**(1/3) + 9*2**(1/3)*3**(2/3)*sqrt(31)*I +
    87*2**(1/3)*3**(1/6)*I)**2)''')
    assert NS(v, 1) == '0.e-118 - 0.e-118*I'

    # issue 5204
    v = S('''-(357587765856 + 18873261792*249**(1/2) + 56619785376*I*83**(1/2) +
    108755765856*I*3**(1/2) + 41281887168*6**(1/3)*(1422 +
    54*249**(1/2))**(1/3) - 1239810624*6**(1/3)*249**(1/2)*(1422 +
    54*249**(1/2))**(1/3) - 3110400000*I*6**(1/3)*83**(1/2)*(1422 +
    54*249**(1/2))**(1/3) + 13478400000*I*3**(1/2)*6**(1/3)*(1422 +
    54*249**(1/2))**(1/3) + 1274950152*6**(2/3)*(1422 +
    54*249**(1/2))**(2/3) + 32347944*6**(2/3)*249**(1/2)*(1422 +
    54*249**(1/2))**(2/3) - 1758790152*I*3**(1/2)*6**(2/3)*(1422 +
    54*249**(1/2))**(2/3) - 304403832*I*6**(2/3)*83**(1/2)*(1422 +
    4*249**(1/2))**(2/3))/(175732658352 + (1106028 + 25596*249**(1/2) +
    76788*I*83**(1/2))**2)''')
    assert NS(v, 5) == '0.077284 + 1.1104*I'
    assert NS(v, 1) == '0.08 + 1.*I'


def test_old_docstring():
    a = (E + pi*I)*(E - pi*I)
    assert NS(a) == '17.2586605000200'
    assert a.n() == 17.25866050002001


def test_issue_4806():
    assert integrate(atan(x)**2, (x, -1, 1)).evalf().round(1) == 0.5
    assert atan(0, evaluate=False).n() == 0


def test_evalf_mul():
    # sympy should not try to expand this; it should be handled term-wise
    # in evalf through mpmath
    assert NS(product(1 + sqrt(n)*I, (n, 1, 500)), 1) == '5.e+567 + 2.e+568*I'


def test_scaled_zero():
    a, b = (([0], 1, 100, 1), -1)
    assert scaled_zero(100) == (a, b)
    assert scaled_zero(a) == (0, 1, 100, 1)
    a, b = (([1], 1, 100, 1), -1)
    assert scaled_zero(100, -1) == (a, b)
    assert scaled_zero(a) == (1, 1, 100, 1)
    raises(ValueError, lambda: scaled_zero(scaled_zero(100)))
    raises(ValueError, lambda: scaled_zero(100, 2))
    raises(ValueError, lambda: scaled_zero(100, 0))
    raises(ValueError, lambda: scaled_zero((1, 5, 1, 3)))


def test_chop_value():
    for i in range(-27, 28):
        assert (Pow(10, i)*2).n(chop=10**i) and not (Pow(10, i)).n(chop=10**i)


def test_infinities():
    assert oo.evalf(chop=True) == inf
    assert (-oo).evalf(chop=True) == ninf


def test_to_mpmath():
    assert sqrt(3)._to_mpmath(20)._mpf_ == (0, long(908093), -19, 20)
    assert S(3.2)._to_mpmath(20)._mpf_ == (0, long(838861), -18, 20)


def test_issue_6632_evalf():
    add = (-100000*sqrt(2500000001) + 5000000001)
    assert add.n() == 9.999999998e-11
    assert (add*add).n() == 9.999999996e-21


def test_issue_4945():
    from sympy.abc import H
    from sympy import zoo
    assert (H/0).evalf(subs={H:1}) == zoo*H


def test_evalf_integral():
    # test that workprec has to increase in order to get a result other than 0
    eps = Rational(1, 1000000)
    assert Integral(sin(x), (x, -pi, pi + eps)).n(2)._prec == 10


def test_issue_8821_highprec_from_str():
    s = str(pi.evalf(128))
    p = N(s)
    assert Abs(sin(p)) < 1e-15
    p = N(s, 64)
    assert Abs(sin(p)) < 1e-64


def test_issue_8853():
    p = Symbol('x', even=True, positive=True)
    assert floor(-p - S.Half).is_even == False
    assert floor(-p + S.Half).is_even == True
    assert ceiling(p - S.Half).is_even == True
    assert ceiling(p + S.Half).is_even == False

    assert get_integer_part(S.Half, -1, {}, True) == (0, 0)
    assert get_integer_part(S.Half, 1, {}, True) == (1, 0)
    assert get_integer_part(-S.Half, -1, {}, True) == (-1, 0)
    assert get_integer_part(-S.Half, 1, {}, True) == (0, 0)


def test_issue_9326():
    from sympy import Dummy
    d1 = Dummy('d')
    d2 = Dummy('d')
    e = d1 + d2
    assert e.evalf(subs = {d1: 1, d2: 2}) == 3


def test_issue_10323():
    assert ceiling(sqrt(2**30 + 1)) == 2**15 + 1


def test_AssocOp_Function():
    e = S('''
    Min(-sqrt(3)*cos(pi/18)/6 + re(1/((-1/2 - sqrt(3)*I/2)*(1/6 +
    sqrt(3)*I/18)**(1/3)))/3 + sin(pi/18)/2 + 2 + I*(-cos(pi/18)/2 -
    sqrt(3)*sin(pi/18)/6 + im(1/((-1/2 - sqrt(3)*I/2)*(1/6 +
    sqrt(3)*I/18)**(1/3)))/3), re(1/((-1/2 + sqrt(3)*I/2)*(1/6 +
    sqrt(3)*I/18)**(1/3)))/3 - sqrt(3)*cos(pi/18)/6 - sin(pi/18)/2 + 2 +
    I*(im(1/((-1/2 + sqrt(3)*I/2)*(1/6 + sqrt(3)*I/18)**(1/3)))/3 -
    sqrt(3)*sin(pi/18)/6 + cos(pi/18)/2))''')
    # the following should not raise a recursion error; it
    # should raise a value error because the first arg computes
    # a non-comparable (prec=1) imaginary part
    raises(ValueError, lambda: e._eval_evalf(2))


def test_issue_10395():
    eq = x*Max(0, y)
    assert nfloat(eq) == eq
    # the order of the factors should not matter (issue 13059)
    assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq
    eq = x*Max(y, -1.1)
    assert nfloat(eq) == eq
    assert Max(y, 4).n() == Max(4.0, y)

```


# The last commit

```
14fb9af0c SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: bin/test sympy/core/tests/test_evalf.py
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.21-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        19464043
hash randomization: on (PYTHONHASHSEED=2527313249)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 8.05 seconds ========
scope: sympy/core/evalf.py sympy/core/tests/test_evalf.py
changed: sympy/core/evalf.py +4 -0
changed: sympy/core/tests/test_evalf.py +2 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sympy/core/evalf.py b/sympy/core/evalf.py
index 72a5fbae5..f34908710 100644
--- a/sympy/core/evalf.py
+++ b/sympy/core/evalf.py
@@ -1301,12 +1301,16 @@ def evalf(x, prec, options):
             elif re.is_number:
                 re = re._to_mpmath(prec, allow_ints=False)._mpf_
                 reprec = prec
+            else:
+                raise NotImplementedError
             if im == 0:
                 im = None
                 imprec = None
             elif im.is_number:
                 im = im._to_mpmath(prec, allow_ints=False)._mpf_
                 imprec = prec
+            else:
+                raise NotImplementedError
             r = re, im, reprec, imprec
         except AttributeError:
             raise NotImplementedError
diff --git a/sympy/core/tests/test_evalf.py b/sympy/core/tests/test_evalf.py
index 4ac3d5c47..7ac5231c7 100644
--- a/sympy/core/tests/test_evalf.py
+++ b/sympy/core/tests/test_evalf.py
@@ -508,6 +508,8 @@ def test_AssocOp_Function():
 def test_issue_10395():
     eq = x*Max(0, y)
     assert nfloat(eq) == eq
+    # the order of the factors should not matter (issue 13059)
+    assert nfloat(Mul(Max(0, y), x, evaluate=False)) == eq
     eq = x*Max(y, -1.1)
     assert nfloat(eq) == eq
     assert Max(y, 4).n() == Max(4.0, y)
```

### `done.sh`

```
#!/usr/bin/env bash
# done.sh <step> <run dir>: whether an agent step did its part, the step's
# target. Exit 0 when it did; otherwise exit 1 and say what is missing. The
# problem step copies it into the run's folder; a task cannot edit its own
# target (gateway/target_guard.go).
set -u
step="$1"; r="$2"; miss=0
w=.memdoor/workflows/team-solve; [ -d "$w" ] || w="$HOME/.memdoor/workflows/team-solve"
no() { printf 'not done: %s\n' "$1"; miss=1; }
# section <file> <heading>: the lines under "## <heading>", comments and blanks dropped.
section() { sed -n "/^## $2\$/,/^## /p" "$1" | sed '1d;/^## /d;/^<!--.*-->$/d;/^[[:space:]]*$/d'; }
verdict() { [ -s "$1" ] && head -1 "$1" | grep -qE '^verdict: (PASS|FAIL)$'; }

case "$step" in
plan)
  t="$r/task.md"
  for s in Deliverable Check Scope "Done when"; do
    [ -n "$(section "$t" "$s")" ] || no "task.md: the $s section is not filled in"
  done
  { section "$t" Check | grep -q '`[^`]*`' || section "$t" Check | grep -qwE 'samples|judge'; } \
    || no 'task.md: Check names no command in backticks, nor samples, nor judge'
  section "$t" Scope | grep -q '`[^`]*`' || no 'task.md: Scope names no file or directory in backticks'
  first=$(grep -m1 '[^[:space:]]' "$r/prompt.md")
  grep -qF -- "$first" "$t" || no 'task.md: the Prompt section was changed; put it back as prompt.md has it'
  grep -q '[^[:space:]]' "$r/plan.md" 2>/dev/null || no 'plan.md is missing or empty'
  [ -f "$r/notes.md" ] || no 'notes.md is missing' ;;
solve)
  bash "$w/changes.sh" "$r" > /dev/null
  [ -s "$r/changes.diff" ] || no 'nothing in the project changed yet: do the task as the Deliverable says' ;;
review)
  verdict "$r/review.md" || no 'review.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
repair)
  head -1 "$r/review.md" 2>/dev/null | grep -qx 'verdict: PASS' && exit 0
  grep -q '[^[:space:]]' "$r/repair.md" 2>/dev/null || no 'repair.md is missing: what you changed and what the Check printed' ;;
judge)
  verdict "$r/verdict.md" || no 'verdict.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
*) echo "done.sh: unknown step $step"; exit 2 ;;
esac
[ "$miss" = 0 ] && printf '%s: done\n' "$step"
exit "$miss"
```

### `final-check.log`

```
check: bin/test sympy/core/tests/test_evalf.py
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.21-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        23540611
hash randomization: on (PYTHONHASHSEED=2566914306)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 5.44 seconds ========
scope: sympy/core/evalf.py sympy/core/tests/test_evalf.py
changed: sympy/core/evalf.py +4 -0
changed: sympy/core/tests/test_evalf.py +2 -0
```

### `final-status.txt`

```
0
```

### `head.txt`

```
master
```

### `keep.txt`

```
kept: the direct attempt, untouched
```

### `notes.md`

```
# Notes, run 2026-11-06T121347

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

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


# The files of the project

```
.ci/durations.json
.ci/generate_durations_log.sh
.ci/parse_durations_log.py
.editorconfig
.gitattributes
.gitignore
.mailmap
.travis.yml
AUTHORS
CODE_OF_CONDUCT.md
LICENSE
MANIFEST.in
PULL_REQUEST_TEMPLATE.md
README.rst
bin/ask_update.py
bin/authors_update.py
bin/coverage_doctest.py
bin/coverage_report.py
bin/diagnose_imports
bin/doctest
bin/generate_module_list.py
bin/generate_test_list.py
bin/get_sympy.py
bin/isympy
bin/mailmap_update.py
bin/py.bench
bin/strip_whitespace
bin/sympy_time.py
bin/sympy_time_cache.py
bin/test
bin/test_import
bin/test_import.py
bin/test_isolated
bin/test_setup.py
bin/test_travis.sh
conftest.py
data/TeXmacs/LICENSE
data/TeXmacs/bin/tm_sympy
data/TeXmacs/progs/init-sympy.scm
doc/Makefile
doc/README.rst
doc/api/conf.py
doc/api/index.rst
doc/apidoc.conf
doc/cheatsheet/cheatsheet.tex
doc/cheatsheet/combinatoric_cheatsheet.tex
doc/ext/docscrape.py
doc/ext/docscrape_sphinx.py
doc/ext/numpydoc.py
doc/ext/sympylive.py
doc/generate_logos.py
doc/man/isympy.1
doc/man/isympy.xml
doc/src/_static/default.css_t
doc/src/_static/sympylogo.png
doc/src/_static/sympylogo_big.png
doc/src/_templates/layout.html
doc/src/aboutus.rst
doc/src/citing.rst
doc/src/conf.py
doc/src/gotchas.rst
doc/src/guide.rst
doc/src/index.rst
doc/src/install.rst
doc/src/logo/info.txt
doc/src/logo/sympy-use-text.svg
doc/src/logo/sympy.svg
doc/src/modules/assumptions/ask.rst
doc/src/modules/assumptions/assume.rst
doc/src/modules/assumptions/handlers/calculus.rst
doc/src/modules/assumptions/handlers/index.rst
doc/src/modules/assumptions/handlers/ntheory.rst
doc/src/modules/assumptions/handlers/order.rst
doc/src/modules/assumptions/handlers/sets.rst
doc/src/modules/assumptions/index.rst
doc/src/modules/assumptions/refine.rst
doc/src/modules/calculus/index.rst
doc/src/modules/categories.rst
doc/src/modules/codegen.rst
doc/src/modules/combinatorics/fp_groups.rst
doc/src/modules/combinatorics/graycode.rst
doc/src/modules/combinatorics/group_constructs.rst
doc/src/modules/combinatorics/index.rst
doc/src/modules/combinatorics/named_groups.rst
doc/src/modules/combinatorics/partitions.rst
doc/src/modules/combinatorics/perm_groups.rst
doc/src/modules/combinatorics/permutations.rst
doc/src/modules/combinatorics/polyhedron.rst
doc/src/modules/combinatorics/prufer.rst
doc/src/modules/combinatorics/subsets.rst
doc/src/modules/combinatorics/tensor_can.rst
doc/src/modules/combinatorics/testutil.rst
doc/src/modules/combinatorics/util.rst
doc/src/modules/concrete.rst
doc/src/modules/core.rst
doc/src/modules/crypto.rst
doc/src/modules/diffgeom.rst
doc/src/modules/evalf.rst
doc/src/modules/functions/combinatorial.rst
doc/src/modules/functions/elementary.rst
doc/src/modules/functions/index.rst
doc/src/modules/functions/special.rst
doc/src/modules/geometry/curves.rst
doc/src/modules/geometry/ellipses.rst
doc/src/modules/geometry/entities.rst
doc/src/modules/geometry/index.rst
doc/src/modules/geometry/lines.rst
doc/src/modules/geometry/plane.rst
doc/src/modules/geometry/points.rst
doc/src/modules/geometry/polygons.rst
doc/src/modules/geometry/utils.rst
doc/src/modules/holonomic/about.rst
doc/src/modules/holonomic/convert.rst
doc/src/modules/holonomic/index.rst
doc/src/modules/holonomic/operations.rst
doc/src/modules/holonomic/represent.rst
doc/src/modules/holonomic/uses.rst
doc/src/modules/index.rst
doc/src/modules/integrals/g-functions.rst
doc/src/modules/integrals/integrals.rst
doc/src/modules/liealgebras/index.rst
doc/src/modules/logic.rst
doc/src/modules/matrices/dense.rst
doc/src/modules/matrices/expressions.rst
doc/src/modules/matrices/immutablematrices.rst
doc/src/modules/matrices/index.rst
doc/src/modules/matrices/matrices.rst
doc/src/modules/matrices/sparse.rst
doc/src/modules/ntheory.rst
doc/src/modules/numeric-computation.rst
doc/src/modules/parsing.rst
doc/src/modules/physics/continuum_mechanics/beam.rst
doc/src/modules/physics/continuum_mechanics/beam_problems.rst
doc/src/modules/physics/continuum_mechanics/index.rst
doc/src/modules/physics/hep/index.rst
doc/src/modules/physics/hydrogen.rst
doc/src/modules/physics/index.rst
doc/src/modules/physics/matrices.rst
doc/src/modules/physics/mechanics/advanced.rst
doc/src/modules/physics/mechanics/api/body.rst
doc/src/modules/physics/mechanics/api/expr_manip.rst
doc/src/modules/physics/mechanics/api/kane_lagrange.rst
doc/src/modules/physics/mechanics/api/linearize.rst
doc/src/modules/physics/mechanics/api/part_bod.rst
doc/src/modules/physics/mechanics/api/printing.rst
doc/src/modules/physics/mechanics/api/system.rst
doc/src/modules/physics/mechanics/examples.rst
doc/src/modules/physics/mechanics/examples/bicycle_example.rst
doc/src/modules/physics/mechanics/examples/lin_pend_nonmin_example.rst
doc/src/modules/physics/mechanics/examples/pendulum_nonmin.svg
doc/src/modules/physics/mechanics/examples/rollingdisc.svg
doc/src/modules/physics/mechanics/examples/rollingdisc_example.rst
doc/src/modules/physics/mechanics/examples/rollingdisc_example_kane.rst
doc/src/modules/physics/mechanics/examples/rollingdisc_example_kane_constraints.rst
doc/src/modules/physics/mechanics/examples/rollingdisc_example_lagrange.rst
doc/src/modules/physics/mechanics/index.rst
doc/src/modules/physics/mechanics/kane.rst
doc/src/modules/physics/mechanics/lagrange.rst
doc/src/modules/physics/mechanics/linearize.rst
doc/src/modules/physics/mechanics/masses.rst
doc/src/modules/physics/mechanics/reference.rst
doc/src/modules/physics/mechanics/symsystem.rst
doc/src/modules/physics/optics/gaussopt.rst
doc/src/modules/physics/optics/index.rst
doc/src/modules/physics/optics/medium.rst
doc/src/modules/physics/optics/utils.rst
doc/src/modules/physics/optics/waves.rst
doc/src/modules/physics/paulialgebra.rst
doc/src/modules/physics/qho_1d.rst
doc/src/modules/physics/quantum/anticommutator.rst
doc/src/modules/physics/quantum/cartesian.rst
doc/src/modules/physics/quantum/cg.rst
doc/src/modules/physics/quantum/circuitplot.rst
doc/src/modules/physics/quantum/commutator.rst
doc/src/modules/physics/quantum/constants.rst
doc/src/modules/physics/quantum/dagger.rst
doc/src/modules/physics/quantum/gate.rst
doc/src/modules/physics/quantum/grover.rst
doc/src/modules/physics/quantum/hilbert.rst
doc/src/modules/physics/quantum/index.rst
doc/src/modules/physics/quantum/innerproduct.rst
doc/src/modules/physics/quantum/operator.rst
doc/src/modules/physics/quantum/operatorset.rst
doc/src/modules/physics/quantum/piab.rst
doc/src/modules/physics/quantum/qapply.rst
doc/src/modules/physics/quantum/qft.rst
doc/src/modules/physics/quantum/qubit.rst
doc/src/modules/physics/quantum/represent.rst
doc/src/modules/physics/quantum/shor.rst
doc/src/modules/physics/quantum/spin.rst
doc/src/modules/physics/quantum/state.rst
doc/src/modules/physics/quantum/tensorproduct.rst
doc/src/modules/physics/secondquant.rst
doc/src/modules/physics/sho.rst
doc/src/modules/physics/units/dimensions.rst
doc/src/modules/physics/units/examples.rst
doc/src/modules/physics/units/index.rst
doc/src/modules/physics/units/philosophy.rst
doc/src/modules/physics/units/prefixes.rst
doc/src/modules/physics/units/quantities.rst
doc/src/modules/physics/units/unitsystem.rst
doc/src/modules/physics/vector/advanced.rst
doc/src/modules/physics/vector/api/classes.rst
doc/src/modules/physics/vector/api/fieldfunctions.rst
doc/src/modules/physics/vector/api/functions.rst
doc/src/modules/physics/vector/api/kinematics.rst
doc/src/modules/physics/vector/api/printing.rst
doc/src/modules/physics/vector/fields.rst
doc/src/modules/physics/vector/index.rst
doc/src/modules/physics/vector/kin_1.svg
doc/src/modules/physics/vector/kin_1pt.svg
doc/src/modules/physics/vector/kin_2.svg
doc/src/modules/physics/vector/kin_2pt.svg
doc/src/modules/physics/vector/kin_3.svg
doc/src/modules/physics/vector/kin_4.svg
doc/src/modules/physics/vector/kin_angvel1.svg
doc/src/modules/physics/vector/kin_angvel2.svg
doc/src/modules/physics/vector/kin_angvel3.svg
doc/src/modules/physics/vector/kin_rolling.svg
doc/src/modules/physics/vector/kinematics.rst
doc/src/modules/physics/vector/simp_rot.svg
doc/src/modules/physics/vector/vec_add.svg
doc/src/modules/physics/vector/vec_cross.svg
doc/src/modules/physics/vector/vec_dot.svg
doc/src/modules/physics/vector/vec_fix_notfix.svg
doc/src/modules/physics/vector/vec_mul.svg
doc/src/modules/physics/vector/vec_rep.svg
doc/src/modules/physics/vector/vec_simp_der.svg
doc/src/modules/physics/vector/vectors.rst
doc/src/modules/physics/wigner.rst
doc/src/modules/plotting.rst
doc/src/modules/polys/agca.rst
doc/src/modules/polys/basics.rst
doc/src/modules/polys/index.rst
doc/src/modules/polys/internals.rst
doc/src/modules/polys/literature.rst
doc/src/modules/polys/reference.rst
doc/src/modules/polys/ringseries.rst
doc/src/modules/polys/wester.rst
doc/src/modules/printing.rst
doc/src/modules/rewriting.rst
doc/src/modules/series/formal.rst
doc/src/modules/series/fourier.rst
doc/src/modules/series/index.rst
doc/src/modules/series/limitseq.rst
doc/src/modules/series/sequences.rst
doc/src/modules/series/series.rst
doc/src/modules/sets.rst
doc/src/modules/simplify/hyperexpand.rst
doc/src/modules/simplify/simplify.rst
doc/src/modules/solvers/diophantine.rst
doc/src/modules/solvers/inequalities.rst
doc/src/modules/solvers/ode.rst
doc/src/modules/solvers/pde.rst
doc/src/modules/solvers/solvers.rst
doc/src/modules/solvers/solveset.rst
doc/src/modules/stats.rst
doc/src/modules/tensor/array.rst
doc/src/modules/tensor/index.rst
doc/src/modules/tensor/index_methods.rst
doc/src/modules/tensor/indexed.rst
doc/src/modules/tensor/tensor.rst
doc/src/modules/utilities/autowrap.rst
doc/src/modules/utilities/codegen.rst
doc/src/modules/utilities/decorator.rst
doc/src/modules/utilities/enumerative.rst
doc/src/modules/utilities/index.rst
doc/src/modules/utilities/iterables.rst
doc/src/modules/utilities/lambdify.rst
doc/src/modules/utilities/memoization.rst
doc/src/modules/utilities/misc.rst
doc/src/modules/utilities/pkgdata.rst
doc/src/modules/utilities/pytest.rst
doc/src/modules/utilities/randtest.rst
doc/src/modules/utilities/runtests.rst
doc/src/modules/utilities/source.rst
doc/src/modules/utilities/timeutils.rst
doc/src/modules/vector/api/classes.rst
doc/src/modules/vector/api/orienterclasses.rst
doc/src/modules/vector/api/vectorfunctions.rst
doc/src/modules/vector/basics.rst
doc/src/modules/vector/coordsys.rst
doc/src/modules/vector/coordsys_rot.svg
doc/src/modules/vector/examples.rst
doc/src/modules/vector/fields.rst
doc/src/modules/vector/index.rst
doc/src/modules/vector/intro.rst
doc/src/outreach.rst
doc/src/pics/consoleascii.png
doc/src/pics/consoleunicode.png
doc/src/pics/ipythonnotebook.png
doc/src/pics/ipythonqtconsole.png
doc/src/pics/pngview1.png
doc/src/pics/winpdb1.png
doc/src/pics/winpdb2.png
doc/src/python-comparisons.rst
doc/src/special_topics/finite_diff_derivatives.rst
doc/src/special_topics/index.rst
doc/src/special_topics/intro.rst
doc/src/tutorial/basic_operations.rst
doc/src/tutorial/calculus.rst
doc/src/tutorial/gotchas.rst
doc/src/tutorial/index.rst
doc/src/tutorial/intro.rst
doc/src/tutorial/manipulation.rst
doc/src/tutorial/matrices.rst
doc/src/tutorial/preliminaries.rst
doc/src/tutorial/printing.rst
doc/src/tutorial/simplification.rst
doc/src/tutorial/solvers.rst
doc/src/wiki.rst
examples/README
examples/advanced/autowrap_integrators.py
examples/advanced/autowrap_ufuncify.py
examples/advanced/curvilinear_coordinates.py
examples/advanced/dense_coding_example.py
examples/advanced/fem.py
examples/advanced/gibbs_phenomenon.py
examples/advanced/grover_example.py
examples/advanced/hydrogen.py
examples/advanced/identitysearch_example.ipynb
examples/advanced/pidigits.py
examples/advanced/pyglet_plotting.py
examples/advanced/qft.py
examples/advanced/relativity.py
examples/all.py
examples/beginner/basic.py
examples/beginner/differentiation.py
examples/beginner/expansion.py
examples/beginner/functions.py
examples/beginner/limits_examples.py
examples/beginner/plot_advanced.ipynb
examples/beginner/plot_colors.ipynb
examples/beginner/plot_discont.ipynb
examples/beginner/plot_examples.py
examples/beginner/plot_gallery.ipynb
examples/beginner/plot_intro.ipynb
examples/beginner/plotting_nice_plot.py
examples/beginner/precision.py
examples/beginner/print_pretty.py
examples/beginner/series.py
examples/beginner/substitution.py
examples/intermediate/coupled_cluster.py
examples/intermediate/differential_equations.py
examples/intermediate/infinite_1d_box.py
examples/intermediate/limit_examples_advanced.ipynb
examples/intermediate/mplot2d.py
examples/intermediate/mplot3d.py
examples/intermediate/partial_differential_eqs.py
examples/intermediate/print_gtk.py
examples/intermediate/sample.py
examples/intermediate/schwarzschild.ipynb
examples/intermediate/trees.py
examples/intermediate/vandermonde.py
examples/notebooks/IntegrationOverPolytopes.ipynb
examples/notebooks/README.txt
examples/notebooks/density.ipynb
examples/notebooks/fidelity.ipynb
examples/notebooks/fresnel_integrals.ipynb
examples/notebooks/qubits.ipynb
examples/notebooks/sho1d_example.ipynb
examples/notebooks/spin.ipynb
examples/notebooks/trace.ipynb
github_deploy_key.enc
release/.gitignore
release/Dockerfile
release/README.md
release/fabfile.py
release/pull_and_run_rever.sh
release/release.sh
release/rever.xsh
setup.py
setupegg.py
sympy/__init__.py
sympy/abc.py
sympy/algebras/__init__.py
sympy/algebras/quaternion.py
sympy/algebras/tests/test_quaternion.py
sympy/assumptions/__init__.py
sympy/assumptions/ask.py
sympy/assumptions/ask_generated.py
sympy/assumptions/assume.py
sympy/assumptions/handlers/__init__.py
sympy/assumptions/handlers/calculus.py
sympy/assumptions/handlers/common.py
sympy/assumptions/handlers/matrices.py
sympy/assumptions/handlers/ntheory.py
sympy/assumptions/handlers/order.py
sympy/assumptions/handlers/sets.py
sympy/assumptions/refine.py
sympy/assumptions/satask.py
sympy/assumptions/sathandlers.py
sympy/assumptions/tests/__init__.py
sympy/assumptions/tests/test_assumptions_2.py
sympy/assumptions/tests/test_context.py
sympy/assumptions/tests/test_matrices.py
sympy/assumptions/tests/test_query.py
sympy/assumptions/tests/test_refine.py
sympy/assumptions/tests/test_satask.py
sympy/assumptions/tests/test_sathandlers.py
sympy/benchmarks/__init__.py
sympy/benchmarks/bench_discrete_log.py
sympy/benchmarks/bench_meijerint.py
sympy/benchmarks/bench_symbench.py
sympy/calculus/__init__.py
sympy/calculus/euler.py
sympy/calculus/finite_diff.py
sympy/calculus/singularities.py
sympy/calculus/tests/__init__.py
sympy/calculus/tests/test_euler.py
sympy/calculus/tests/test_finite_diff.py
sympy/calculus/tests/test_singularities.py
sympy/calculus/tests/test_util.py
sympy/calculus/util.py
sympy/categories/__init__.py
sympy/categories/baseclasses.py
sympy/categories/diagram_drawing.py
sympy/categories/tests/__init__.py
sympy/categories/tests/test_baseclasses.py
sympy/categories/tests/test_drawing.py
sympy/codegen/__init__.py
sympy/codegen/ast.py
sympy/codegen/cfunctions.py
sympy/codegen/ffunctions.py
sympy/codegen/rewriting.py
sympy/codegen/tests/test_ast.py
sympy/codegen/tests/test_cfunctions.py
sympy/codegen/tests/test_ffunctions.py
sympy/codegen/tests/test_rewriting.py
sympy/combinatorics/__init__.py
sympy/combinatorics/coset_table.py
sympy/combinatorics/fp_groups.py
sympy/combinatorics/free_groups.py
sympy/combinatorics/generators.py
sympy/combinatorics/graycode.py
sympy/combinatorics/group_constructs.py
sympy/combinatorics/homomorphisms.py
sympy/combinatorics/named_groups.py
sympy/combinatorics/partitions.py
sympy/combinatorics/perm_groups.py
sympy/combinatorics/permutations.py
sympy/combinatorics/polyhedron.py
sympy/combinatorics/prufer.py
sympy/combinatorics/rewritingsystem.py
sympy/combinatorics/subsets.py
sympy/combinatorics/tensor_can.py
sympy/combinatorics/tests/__init__.py
sympy/combinatorics/tests/test_coset_table.py
sympy/combinatorics/tests/test_fp_groups.py
sympy/combinatorics/tests/test_free_groups.py
sympy/combinatorics/tests/test_generators.py
sympy/combinatorics/tests/test_graycode.py
sympy/combinatorics/tests/test_group_constructs.py
sympy/combinatorics/tests/test_homomorphisms.py
sympy/combinatorics/tests/test_named_groups.py
sympy/combinatorics/tests/test_partitions.py
sympy/combinatorics/tests/test_perm_groups.py
sympy/combinatorics/tests/test_permutations.py
sympy/combinatorics/tests/test_polyhedron.py
sympy/combinatorics/tests/test_prufer.py
sympy/combinatorics/tests/test_rewriting.py
sympy/combinatorics/tests/test_subsets.py
sympy/combinatorics/tests/test_tensor_can.py
sympy/combinatorics/tests/test_testutil.py
sympy/combinatorics/tests/test_util.py
sympy/combinatorics/testutil.py
sympy/combinatorics/util.py
sympy/concrete/__init__.py
sympy/concrete/delta.py
sympy/concrete/expr_with_intlimits.py
sympy/concrete/expr_with_limits.py
sympy/concrete/gosper.py
sympy/concrete/guess.py
sympy/concrete/products.py
sympy/concrete/summations.py
sympy/concrete/tests/__init__.py
sympy/concrete/tests/test_delta.py
sympy/concrete/tests/test_gosper.py
sympy/concrete/tests/test_guess.py
sympy/concrete/tests/test_products.py
sympy/concrete/tests/test_sums_products.py
sympy/conftest.py
sympy/core/__init__.py
sympy/core/add.py
sympy/core/alphabets.py
sympy/core/assumptions.py
sympy/core/backend.py
sympy/core/basic.py
sympy/core/benchmarks/__init__.py
sympy/core/benchmarks/bench_arit.py
sympy/core/benchmarks/bench_assumptions.py
sympy/core/benchmarks/bench_basic.py
sympy/core/benchmarks/bench_expand.py
sympy/core/benchmarks/bench_numbers.py
sympy/core/benchmarks/bench_sympify.py
sympy/core/cache.py
sympy/core/compatibility.py
sympy/core/containers.py
sympy/core/core.py
sympy/core/coreerrors.py
sympy/core/decorators.py
sympy/core/evalf.py
sympy/core/evaluate.py
sympy/core/expr.py
sympy/core/exprtools.py
sympy/core/facts.py
sympy/core/function.py
sympy/core/logic.py
sympy/core/mod.py
sympy/core/mul.py
sympy/core/multidimensional.py
sympy/core/numbers.py
sympy/core/operations.py
sympy/core/power.py
sympy/core/relational.py
sympy/core/rules.py
sympy/core/singleton.py
sympy/core/symbol.py
sympy/core/sympify.py
sympy/core/tests/__init__.py
sympy/core/tests/test_args.py
sympy/core/tests/test_arit.py
sympy/core/tests/test_assumptions.py
sympy/core/tests/test_basic.py
sympy/core/tests/test_cache.py
sympy/core/tests/test_compatibility.py
sympy/core/tests/test_complex.py
sympy/core/tests/test_constructor_postprocessor.py
sympy/core/tests/test_containers.py
sympy/core/tests/test_count_ops.py
sympy/core/tests/test_diff.py
sympy/core/tests/test_equal.py
sympy/core/tests/test_eval.py
sympy/core/tests/test_eval_power.py
sympy/core/tests/test_evalf.py
sympy/core/tests/test_evaluate.py
sympy/core/tests/test_expand.py
sympy/core/tests/test_expr.py
sympy/core/tests/test_exprtools.py
sympy/core/tests/test_facts.py
sympy/core/tests/test_function.py
sympy/core/tests/test_logic.py
sympy/core/tests/test_match.py
sympy/core/tests/test_noncommutative.py
sympy/core/tests/test_numbers.py
sympy/core/tests/test_operations.py
sympy/core/tests/test_priority.py
sympy/core/tests/test_relational.py
sympy/core/tests/test_rules.py
sympy/core/tests/test_subs.py
sympy/core/tests/test_symbol.py
sympy/core/tests/test_sympify.py
sympy/core/tests/test_trace.py
sympy/core/tests/test_truediv.py
sympy/core/tests/test_var.py
sympy/core/trace.py
sympy/crypto/__init__.py
sympy/crypto/crypto.py
sympy/crypto/tests/__init__.py
sympy/crypto/tests/test_crypto.py
sympy/deprecated/__init__.py
sympy/deprecated/class_registry.py
sympy/deprecated/tests/__init__.py
sympy/deprecated/tests/test_class_registry.py
sympy/diffgeom/__init__.py
sympy/diffgeom/diffgeom.py
sympy/diffgeom/rn.py
sympy/diffgeom/tests/__init__.py
sympy/diffgeom/tests/test_class_structure.py
sympy/diffgeom/tests/test_diffgeom.py
sympy/diffgeom/tests/test_function_diffgeom_book.py
sympy/diffgeom/tests/test_hyperbolic_space.py
sympy/external/__init__.py
sympy/external/importtools.py
sympy/external/tests/__init__.py
sympy/external/tests/test_autowrap.py
sympy/external/tests/test_codegen.py
sympy/external/tests/test_importtools.py
sympy/external/tests/test_numpy.py
sympy/external/tests/test_sage.py
sympy/external/tests/test_scipy.py
sympy/functions/__init__.py
sympy/functions/combinatorial/__init__.py
sympy/functions/combinatorial/factorials.py
sympy/functions/combinatorial/numbers.py
sympy/functions/combinatorial/tests/__init__.py
sympy/functions/combinatorial/tests/test_comb_factorials.py
sympy/functions/combinatorial/tests/test_comb_numbers.py
sympy/functions/elementary/__init__.py
sympy/functions/elementary/benchmarks/__init__.py
sympy/functions/elementary/benchmarks/bench_exp.py
sympy/functions/elementary/complexes.py
sympy/functions/elementary/exponential.py
sympy/functions/elementary/hyperbolic.py
sympy/functions/elementary/integers.py
sympy/functions/elementary/miscellaneous.py
sympy/functions/elementary/piecewise.py
sympy/functions/elementary/tests/__init__.py
sympy/functions/elementary/tests/test_complexes.py
sympy/functions/elementary/tests/test_exponential.py
```


# The last commit

```
14fb9af0c SWE-bench


```

```diff

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`bin/test sympy/core/tests/test_evalf.py`

## Scope
`sympy/core/evalf.py`
`sympy/core/tests/test_evalf.py`

## Done when
`Mul(Max(0, y), x, evaluate=False).evalf()` returns `x*Max(0, y)` without raising `UnboundLocalError`.
`Mul(x, Max(0, y), evaluate=False).evalf()` still returns `x*Max(0, y)`.
The fallback `elif` chain in `evalf` raises `NotImplementedError` when no branch assigns `reprec`/`imprec`.
`bin/test sympy/core/tests/test_evalf.py` passes.

## Approach
Locate the `evalf` fallback around the `KeyError: Max` path, add `else: raise NotImplementedError` to the `elif` chain that assigns `reprec`/`imprec`, and confirm `evalf_mul` catches that `NotImplementedError` and returns the unevaluated product. Add a regression test for both argument orders if the existing test file does not already cover it.

Candidate approaches:
1. Add `else: raise NotImplementedError` to the fallback `elif` chain — the prompt’s suggested minimal fix; lets `evalf_mul` handle the unsupported `Max` argument consistently.
2. Initialize `reprec = imprec = None` before the chain — suppresses the `UnboundLocalError` but can return a malformed result and hide unsupported functions; not preferred.
3. Add an explicit `Max` evalf handler — more invasive and unnecessary for this bug; better as a separate enhancement.

If the first attempt fails, check that the new `else` is attached at the correct `elif` level and that `evalf_mul` catches `NotImplementedError` around each argument evaluation.
```

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

### `review.md`

```
verdict: PASS
The diff adds `else: raise NotImplementedError` to both fallback branches in `evalf`, preventing the unbound `reprec`/`imprec` path.
The added regression test covers the reversed `Mul` argument order from the issue.
`bin/test sympy/core/tests/test_evalf.py` completed successfully: 46 passed, 2 expected failures.
Changes are confined to the stated scope and do not remove unrelated content.
```

### `scope.txt`

```
scope: sympy/core/evalf.py sympy/core/tests/test_evalf.py
changed: sympy/core/evalf.py +4 -0
changed: sympy/core/tests/test_evalf.py +2 -0
```

### `task.md`

````
# Task

## Prompt

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

## Deliverable

changes to this tree

## Check

`bin/test sympy/core/tests/test_evalf.py`

## Scope

`sympy/core/evalf.py`
`sympy/core/tests/test_evalf.py`

## Done when

`Mul(Max(0, y), x, evaluate=False).evalf()` returns `x*Max(0, y)` without raising `UnboundLocalError`.
`Mul(x, Max(0, y), evaluate=False).evalf()` still returns `x*Max(0, y)`.
The fallback `elif` chain in `evalf` raises `NotImplementedError` when no branch assigns `reprec`/`imprec`.
`bin/test sympy/core/tests/test_evalf.py` passes.
````

### `test-output.log`

```
check: bin/test sympy/core/tests/test_evalf.py
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
/testbed/sympy/core/basic.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Mapping, defaultdict
/testbed/sympy/core/containers.py:271: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  class OrderedSet(collections.MutableSet):
/testbed/sympy/plotting/plot.py:28: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
  from collections import Callable
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.21-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        51270483
hash randomization: on (PYTHONHASHSEED=1994452812)

sympy/core/tests/test_evalf.py[48] ......f.f....................................
...                                                                         [OK]

======== tests finished: 46 passed, 2 expected to fail, in 8.13 seconds ========
scope: sympy/core/evalf.py sympy/core/tests/test_evalf.py
changed: sympy/core/evalf.py +4 -0
changed: sympy/core/tests/test_evalf.py +2 -0
```

### `test-status.txt`

```
0
```

### `untracked-before.txt`

```
.memdoor/.gitignore
.memdoor/workflows/single/README.md
.memdoor/workflows/single/steps/do.yaml
.memdoor/workflows/team-solve/README.md
.memdoor/workflows/team-solve/changes.sh
.memdoor/workflows/team-solve/check-samples.sh
.memdoor/workflows/team-solve/check.sh
.memdoor/workflows/team-solve/done.sh
.memdoor/workflows/team-solve/failures.sh
.memdoor/workflows/team-solve/sample/task.md
.memdoor/workflows/team-solve/sample/tests/1.in
.memdoor/workflows/team-solve/sample/tests/1.out
.memdoor/workflows/team-solve/sample/tests/2.in
.memdoor/workflows/team-solve/sample/tests/2.out
.memdoor/workflows/team-solve/sample/tests/3.in
.memdoor/workflows/team-solve/sample/tests/3.out
.memdoor/workflows/team-solve/sample/tests/4.in
.memdoor/workflows/team-solve/sample/tests/4.out
.memdoor/workflows/team-solve/sample/tests/5.in
.memdoor/workflows/team-solve/sample/tests/5.out
.memdoor/workflows/team-solve/scope.sh
.memdoor/workflows/team-solve/settle.sh
.memdoor/workflows/team-solve/snapshot.sh
.memdoor/workflows/team-solve/steps/baseline.yaml
.memdoor/workflows/team-solve/steps/context.yaml
.memdoor/workflows/team-solve/steps/direct.yaml
.memdoor/workflows/team-solve/steps/ideate.yaml
.memdoor/workflows/team-solve/steps/judge.yaml
.memdoor/workflows/team-solve/steps/keep.yaml
.memdoor/workflows/team-solve/steps/outline.yaml
.memdoor/workflows/team-solve/steps/plan.yaml
.memdoor/workflows/team-solve/steps/problem.yaml
.memdoor/workflows/team-solve/steps/recheck.yaml
.memdoor/workflows/team-solve/steps/repair.yaml
.memdoor/workflows/team-solve/steps/review.yaml
.memdoor/workflows/team-solve/steps/settle.yaml
.memdoor/workflows/team-solve/steps/solve.yaml
.memdoor/workflows/team-solve/steps/test-0.yaml
.memdoor/workflows/team-solve/steps/test.yaml
.memdoor/workflows/team-solve/steps/verify.yaml
.memdoor/workflows/team-solve/task.sh
.memdoor/workflows/team-solve/task.template.md
.memdoor/workflows/team-solve/verdict.sh
```
