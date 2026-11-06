# sympy__sympy-14976 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 246s 39 lines cost=0.012753 in=171624 cached=114176 out=27582 calls=18`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

lambdify(modules='mpmath') doesn't wrap rationals
```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> f = lambdify(x, eqn.lhs - eqn.rhs, 'mpmath')
>>> print(inspect.getsource(f))
def _lambdifygenerated(x):
    return (  # Not supported in Python:
  # RisingFactorial
RisingFactorial(18, x) - 232/3)
```

This results in reduced precision results from `nsolve`, because the 232/3 isn't evaluated at full precision. 

```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> x0 = nsolve(eqn, Float('1.5', 64), prec=64)
>>> rf(18, x0).evalf(64)
77.33333333333332859638176159933209419250488281250000000000000000
```

Originally reported at https://github.com/sympy/sympy/pull/14971


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls"
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
conftest.py
data
doc
examples
github_deploy_key.enc
isympy.py
release
setup.py
setupegg.py
sympy
sympy.egg-info
tox.ini.sample
```

**assistant → tool `locate`**

```json
{
  "query": "lambdify mpmath rational printing Rational to mpf or mpmathify"
}
```

**tool result**

```
Where "lambdify mpmath rational printing Rational to mpf or mpmathify" lives (judged: 15 of 40 sections kept), most relevant first:
1. sympy/printing/pycode.py:314-332  p=0.88
2. sympy/core/numbers.py:1725-1764  p=0.77
3. sympy/utilities/lambdify.py:161-193  p=0.74
4. sympy/core/evalf.py:918-931  p=0.70
5. sympy/external/tests/test_numpy.py:20-26  p=0.70
6. sympy/functions/combinatorial/tests/test_comb_factorials.py:151-157  p=0.63
7. sympy/printing/str.py:1-15  p=0.60
8. sympy/utilities/tests/test_lambdify.py:172-176  p=0.55

== sympy/printing/pycode.py:314-332 (p=0.88)
  314  class MpmathPrinter(PythonCodePrinter):
  315      """
  316      Lambda printer for mpmath which maintains precision for floats
  317      """
  318      printmethod = "_mpmathcode"
  319  
  320      _kf = dict(chain(
  321          _known_functions.items(),
  322          [(k, 'mpmath.' + v) for k, v in _known_functions_mpmath.items()]
  323      ))
  324  
  325      def _print_Float(self, e):
  326          # XXX: This does not handle setting mpmath.mp.dps. It is assumed that
  327          # the caller of the lambdified function will have set it to sufficient
  328          # precision to match the Floats in the expression.
  329  
  330          # Remove 'mpz' if gmpy is installed.
  331          args = str(tuple(map(int, e._mpf_)))
  332          return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)

== sympy/core/numbers.py:1725-1764 (p=0.77)
 1725      def _mpmath_(self, prec, rnd):
 1726          return mpmath.make_mpf(mlib.from_rational(self.p, self.q, prec, rnd))
 1727  
 1728      def __abs__(self):
 1729          return Rational(abs(self.p), self.q)
 1730  
 1731      def __int__(self):
 1732          p, q = self.p, self.q
 1733          if p < 0:
 1734              return -int(-p//q)
 1735          return int(p//q)
 1736  
 1737      __long__ = __int__
 1738  
 1739      def floor(self):
 1740          return Integer(self.p // self.q)
 1741  
 1742      def ceiling(self):
 1743          return -Integer(-self.p // self.q)
 1744  
 1745      def __eq__(self, other):
 1746          try:
 1747              other = _sympify(other)
 1748          except SympifyError:
 1749              return NotImplemented
 1750          if other.is_NumberSymbol:
 1751              if other.is_irrational:
 1752                  return False
 1753              return other.__eq__(self)
 1754          if other.is_Number:
 1755              if other.is_Rational:
 1756                  # a Rational is always in reduced form so will never be 2/4
 1757                  # so we can just check equivalence of args
 1758                  return self.p == other.p and self.q == other.q
 1759              if other.is_Float:
 1760                  return mlib.mpf_eq(self._as_mpf_val(other._prec), other._mpf_)
 1761          return False
 1762  
 1763      def __ne__(self, other):
 1764          return not self == other

== sympy/utilities/lambdify.py:161-193 (p=0.74)
  161  # Used for dynamically generated filenames that are inserted into the
  162  # linecache.
  163  _lambdify_generated_counter = 1
  164  
  165  @doctest_depends_on(modules=('numpy'))
  166  def lambdify(args, expr, modules=None, printer=None, use_imps=True,
  167               dummify=False):
  168      """
  169      Returns an anonymous function for fast calculation of numerical values.
  170  
  171      If not specified differently by the user, ``modules`` defaults to
  172      ``["numpy"]`` if NumPy is installed, and ``["math", "mpmath", "sympy"]``
  173      if it isn't, that is, SymPy functions are replaced as far as possible by
  174      either ``numpy`` functions if available, and Python's standard library
  175      ``math``, or ``mpmath`` functions otherwise. To change this behavior, the
  176      "modules" argument can be used. It accepts:
  177  
  178       - the strings "math", "mpmath", "numpy", "numexpr", "sympy", "tensorflow"
  179       - any modules (e.g. math)
  180       - dictionaries that map names of sympy functions to arbitrary functions
  181       - lists that contain a mix of the arguments above, with higher priority
  182         given to entries appearing first.
  183  
  184      .. warning::
  185          Note that this function uses ``eval``, and thus shouldn't be used on
  186          unsanitized input.
  187  
  188      Arguments in the provided expression that are not valid Python identifiers
  189      are substitued with dummy symbols. This allows for applied functions
  190      (e.g. f(t)) to be supplied as arguments. Call the function with
  191      dummify=True to replace all arguments with dummy symbols (if `args` is
  192      not a string) - for example, to ensure that the arguments do not
  193      redefine any built-in names.

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `read_file`**

```json
{
  "path": "sympy/printing/pycode.py",
  "offset": 280,
  "limit": 100
}
```

**tool result**

```
def pycode(expr, **settings):
    """ Converts an expr to a string of Python code

    Parameters
    ==========

    expr : Expr
        A SymPy expression.
    fully_qualified_modules : bool
        Whether or not to write out full module names of functions
        (``math.sin`` vs. ``sin``). default: ``True``.

    Examples
    ========

    >>> from sympy import tan, Symbol
    >>> from sympy.printing.pycode import pycode
    >>> pycode(tan(Symbol('x')) + 1)
    'math.tan(x) + 1'

    """
    return PythonCodePrinter(settings).doprint(expr)


_not_in_mpmath = 'log1p log2'.split()
_in_mpmath = [(k, v) for k, v in _known_functions_math.items() if k not in _not_in_mpmath]
_known_functions_mpmath = dict(_in_mpmath, **{
    'sign': 'sign',
})
_known_constants_mpmath = {
    'Pi': 'pi'
}


class MpmathPrinter(PythonCodePrinter):
    """
    Lambda printer for mpmath which maintains precision for floats
    """
    printmethod = "_mpmathcode"

    _kf = dict(chain(
        _known_functions.items(),
        [(k, 'mpmath.' + v) for k, v in _known_functions_mpmath.items()]
    ))

    def _print_Float(self, e):
        # XXX: This does not handle setting mpmath.mp.dps. It is assumed that
        # the caller of the lambdified function will have set it to sufficient
        # precision to match the Floats in the expression.

        # Remove 'mpz' if gmpy is installed.
        args = str(tuple(map(int, e._mpf_)))
        return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)


    def _print_uppergamma(self, e):
        return "{0}({1}, {2}, {3})".format(
            self._module_format('mpmath.gammainc'),
            self._print(e.args[0]),
            self._print(e.args[1]),
            self._module_format('mpmath.inf'))

    def _print_lowergamma(self, e):
        return "{0}({1}, 0, {2})".format(
            self._module_format('mpmath.gammainc'),
            self._print(e.args[0]),
            self._print(e.args[1]))

    def _print_log2(self, e):
        return '{0}({1})/{0}(2)'.format(
            self._module_format('mpmath.log'), self._print(e.args[0]))

    def _print_log1p(self, e):
        return '{0}({1}+1)'.format(
            self._module_format('mpmath.log'), self._print(e.args[0]))

for k in MpmathPrinter._kf:
    setattr(MpmathPrinter, '_print_%s' % k, _print_known_func)

for k in _known_constants_mpmath:
    setattr(MpmathPrinter, '_print_%s' % k, _print_known_const)


_not_in_numpy = 'erf erfc factorial gamma lgamma'.split()
_in_numpy = [(k, v) for k, v in _known_functions_math.items() if k not in _not_in_numpy]
_known_functions_numpy = dict(_in_numpy, **{
    'acos': 'arccos',
    'acosh': 'arccosh',
    'asin': 'arcsin',
    'asinh': 'arcsinh',
    'atan': 'arctan',
    'atan2': 'arctan2',
    'atanh': 'arctanh',
    'exp2': 'exp2',
    'sign': 'sign',
})


class NumPyPrinter(PythonCodePrinter):
    """

[177 more lines in /testbed/sympy/printing/pycode.py (556 in all). read_file with offset: 380 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Rational\\|_print_Integer\\|_print_Float\" sympy/printing/pycode.py"
}
```

**tool result**

```
325:    def _print_Float(self, e):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"_print_Rational\" sympy/printing/ | head -20"
}
```

**tool result**

```
sympy/printing/pretty/pretty.py:1669:    def _print_Rational(self, expr):
sympy/printing/pretty/pretty.py:2007:    def _print_RationalField(self, expr):
sympy/printing/ccode.py:301:    def _print_Rational(self, expr):
sympy/printing/str.py:594:    def _print_Rational(self, expr):
sympy/printing/latex.py:1312:    def _print_Rational(self, expr):
sympy/printing/latex.py:1823:    def _print_RationalField(self, expr):
sympy/printing/mathml.py:228:    def _print_Rational(self, e):
sympy/printing/mathml.py:588:    def _print_Rational(self, e):
sympy/printing/theanocode.py:167:    def _print_Rational(self, expr, **kwargs):
sympy/printing/rcode.py:158:    def _print_Rational(self, expr):
sympy/printing/fcode.py:341:    def _print_Rational(self, expr):
sympy/printing/rust.py:358:    def _print_Rational(self, expr):
sympy/printing/jscode.py:111:    def _print_Rational(self, expr):
sympy/printing/glsl.py:281:    def _print_Rational(self, expr):
sympy/printing/printer.py:56:        |-- p._print_Rational(expr)
sympy/printing/printer.py:64:    if ``._print_Rational`` method exists in the printer, then it is called,
sympy/printing/repr.py:73:    def _print_RationalConstant(self, expr):
sympy/printing/repr.py:134:    def _print_Rational(self, expr):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,140p' sympy/printing/pycode.py && grep -n \"class PythonCodePrinter\\|_module_format\\|_print_Integer\\|known_functions\" sympy/printing/pycode.py | head -40"
}
```

**tool result**

```
"""
Python code printers

This module contains python code printers for plain python as well as NumPy & SciPy enabled code.
"""


from collections import defaultdict
from functools import wraps
from itertools import chain
from sympy.core import sympify, S
from .precedence import precedence
from .codeprinter import CodePrinter

_kw_py2and3 = {
    'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif',
    'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in',
    'is', 'lambda', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while',
    'with', 'yield', 'None'  # 'None' is actually not in Python 2's keyword.kwlist
}
_kw_only_py2 = {'exec', 'print'}
_kw_only_py3 = {'False', 'nonlocal', 'True'}

_known_functions = {
    'Abs': 'abs',
}
_known_functions_math = {
    'acos': 'acos',
    'acosh': 'acosh',
    'asin': 'asin',
    'asinh': 'asinh',
    'atan': 'atan',
    'atan2': 'atan2',
    'atanh': 'atanh',
    'ceiling': 'ceil',
    'cos': 'cos',
    'cosh': 'cosh',
    'erf': 'erf',
    'erfc': 'erfc',
    'exp': 'exp',
    'expm1': 'expm1',
    'factorial': 'factorial',
    'floor': 'floor',
    'gamma': 'gamma',
    'hypot': 'hypot',
    'loggamma': 'lgamma',
    'log': 'log',
    'log10': 'log10',
    'log1p': 'log1p',
    'log2': 'log2',
    'sin': 'sin',
    'sinh': 'sinh',
    'Sqrt': 'sqrt',
    'tan': 'tan',
    'tanh': 'tanh'
}  # Not used from ``math``: [copysign isclose isfinite isinf isnan ldexp frexp pow modf
# radians trunc fmod fsum gcd degrees fabs]
_known_constants_math = {
    'Exp1': 'e',
    'Pi': 'pi',
    # Only in python >= 3.5:
    # 'Infinity': 'inf',
    # 'NaN': 'nan'
}

def _print_known_func(self, expr):
    known = self.known_functions[expr.__class__.__name__]
    return '{name}({args})'.format(name=self._module_format(known),
                                   args=', '.join(map(lambda arg: self._print(arg), expr.args)))


def _print_known_const(self, expr):
    known = self.known_constants[expr.__class__.__name__]
    return self._module_format(known)


class PythonCodePrinter(CodePrinter):
    printmethod = "_pythoncode"
    language = "Python"
    standard = "python3"
    reserved_words = _kw_py2and3.union(_kw_only_py3)
    modules = None  # initialized to a set in __init__
    tab = '    '
    _kf = dict(chain(
        _known_functions.items(),
        [(k, 'math.' + v) for k, v in _known_functions_math.items()]
    ))
    _kc = {k: 'math.'+v for k, v in _known_constants_math.items()}
    _operators = {'and': 'and', 'or': 'or', 'not': 'not'}
    _default_settings = dict(
        CodePrinter._default_settings,
        user_functions={},
        precision=17,
        inline=True,
        fully_qualified_modules=True,
        contract=False
    )

    def __init__(self, settings=None):
        super(PythonCodePrinter, self).__init__(settings)
        self.module_imports = defaultdict(set)
        self.known_functions = dict(self._kf, **(settings or {}).get(
            'user_functions', {}))
        self.known_constants = dict(self._kc, **(settings or {}).get(
            'user_constants', {}))

    def _get_statement(self, codestring):
        return codestring

    def _declare_number_const(self, name, value):
        return "%s = %s" % (name, value)

    def _module_format(self, fqn, register=True):
        parts = fqn.split('.')
        if register and len(parts) > 1:
            self.module_imports['.'.join(parts[:-1])].add(parts[-1])

        if self._settings['fully_qualified_modules']:
            return fqn
        else:
            return fqn.split('(')[0].split('[')[0].split('.')[-1]

    def _format_code(self, lines):
        return lines

    def _get_statement(self, codestring):
        return "%s" % codestring

    def _get_comment(self, text):
        return "  # {0}".format(text)

    def _print_NaN(self, expr):
        return "float('nan')"

    def _print_Infinity(self, expr):
        return "float('inf')"

    def _print_sign(self, e):
        return '(0.0 if {e} == 0 else {f}(1, {e}))'.format(
            f=self._module_format('math.copysign'), e=self._print(e.args[0]))
24:_known_functions = {
27:_known_functions_math = {
67:    known = self.known_functions[expr.__class__.__name__]
68:    return '{name}({args})'.format(name=self._module_format(known),
74:    return self._module_format(known)
77:class PythonCodePrinter(CodePrinter):
85:        _known_functions.items(),
86:        [(k, 'math.' + v) for k, v in _known_functions_math.items()]
102:        self.known_functions = dict(self._kf, **(settings or {}).get(
113:    def _module_format(self, fqn, register=True):
140:            f=self._module_format('math.copysign'), e=self._print(e.args[0]))
211:        func = self.known_functions.get(name, name)
263:            return self._module_format('sys.stdout')
265:            return self._module_format('sys.stderr')
305:_in_mpmath = [(k, v) for k, v in _known_functions_math.items() if k not in _not_in_mpmath]
306:_known_functions_mpmath = dict(_in_mpmath, **{
321:        _known_functions.items(),
322:        [(k, 'mpmath.' + v) for k, v in _known_functions_mpmath.items()]
332:        return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)
337:            self._module_format('mpmath.gammainc'),
340:            self._module_format('mpmath.inf'))
344:            self._module_format('mpmath.gammainc'),
350:            self._module_format('mpmath.log'), self._print(e.args[0]))
354:            self._module_format('mpmath.log'), self._print(e.args[0]))
364:_in_numpy = [(k, v) for k, v in _known_functions_math.items() if k not in _not_in_numpy]
365:_known_functions_numpy = dict(_in_numpy, **{
387:        [(k, 'numpy.' + v) for k, v in _known_functions_numpy.items()]
412:        return "%s(%s, %s)" % (self._module_format('numpy.dot'),
424:        return '{0}({1}, {2}, default=numpy.nan)'.format(self._module_format('numpy.select'), conds, exprs)
439:            return '{op}({lhs}, {rhs})'.format(op=self._module_format('numpy.'+op[expr.rel_op]),
448:        return '{0}.reduce(({1}))'.format(self._module_format('numpy.logical_and'), ','.join(self._print(i) for i in expr.args))
455:        return '{0}.reduce(({1}))'.format(self._module_format('numpy.logical_or'), ','.join(self._print(i) for i in expr.args))
462:        return '{0}({1})'.format(self._module_format('numpy.logical_not'), ','.join(self._print(i) for i in expr.args))
465:        return '{0}(({1}))'.format(self._module_format('numpy.amin'), ','.join(self._print(i) for i in expr.args))
468:        return '{0}(({1}))'.format(self._module_format('numpy.amax'), ','.join(self._print(i) for i in expr.args))
472:            return '{0}({1})'.format(self._module_format('numpy.sqrt'), self._print(expr.base))
477:        return "%s(%s)" % (self._module_format('numpy.angle'), self._print(expr.args[0]))
480:        return "%s(%s)" % (self._module_format('numpy.imag', self._print(expr.args[0])))
483:        return "%s(%s)" % (self._module_format('numpy.mod'), ', '.join(
487:        return "%s(%s)" % (self._module_format('numpy.real'), self._print(expr.args[0]))
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"MpmathPrinter\\|mpmath\" sympy/printing/tests/test_pycode.py | head -40 && sed -n '150,190p' sympy/utilities/tests/test_lambdify.py"
}
```

**tool result**

```
13:    MpmathPrinter, NumPyPrinter, PythonCodePrinter, pycode, SciPyPrinter
40:def test_MpmathPrinter():
41:    p = MpmathPrinter()
42:    assert p.doprint(sign(x)) == 'mpmath.sign(x)'
73:    def _mpmathcode(self, printer):
74:        return 'mpmath'
80:    assert MpmathPrinter().doprint(obj) == 'mpmath'
    sin02 = mpmath.mpf("0.19866933079506121545941262711838975037020672954020")
    f = lambdify(x, sin02, "mpmath")
    prec = 1e-49  # mpmath precision is around 50 decimal places
    assert -prec < f(0) - sin02 < prec

@conserve_mpmath_dps
def test_mpmath_precision():
    mpmath.mp.dps = 100
    assert str(lambdify((), pi.evalf(100), 'mpmath')()) == str(pi.evalf(100))

#================== Test Translations ==============================
# We can only check if all translated functions are valid. It has to be checked
# by hand if they are complete.


def test_math_transl():
    from sympy.utilities.lambdify import MATH_TRANSLATIONS
    for sym, mat in MATH_TRANSLATIONS.items():
        assert sym in sympy.__dict__
        assert mat in math.__dict__


def test_mpmath_transl():
    from sympy.utilities.lambdify import MPMATH_TRANSLATIONS
    for sym, mat in MPMATH_TRANSLATIONS.items():
        assert sym in sympy.__dict__ or sym == 'Matrix'
        assert mat in mpmath.__dict__


def test_numpy_transl():
    if not numpy:
        skip("numpy not installed.")

    from sympy.utilities.lambdify import NUMPY_TRANSLATIONS
    for sym, nump in NUMPY_TRANSLATIONS.items():
        assert sym in sympy.__dict__
        assert nump in numpy.__dict__

def test_tensorflow_transl():
    if not tensorflow:
        skip("tensorflow not installed")
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/printing/pycode.py\n@@\n     def _print_Float(self, e):\n         # XXX: This does not handle setting mpmath.mp.dps. It is assumed that\n         # the caller of the lambdified function will have set it to sufficient\n         # precision to match the Floats in the expression.\n \n         # Remove 'mpz' if gmpy is installed.\n         args = str(tuple(map(int, e._mpf_)))\n         return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)\n \n+    def _print_Rational(self, e):\n+        # Convert the numerator and denominator to mpf so that the division is\n+        # carried out at mpmath's working precision instead of using Python's\n+        # integer division (which would truncate the result to an integer).\n+        return '{0}({1})/{0}({2})'.format(\n+            self._module_format('mpmath.mpf'), e.p, e.q)\n+\n \n     def _print_uppergamma(self, e):\n*** Update File: sympy/printing/tests/test_pycode.py\n@@\n def test_MpmathPrinter():\n     p = MpmathPrinter()\n     assert p.doprint(sign(x)) == 'mpmath.sign(x)'\n+    assert p.doprint(S(1)/3) == 'mpmath.mpf(1)/mpmath.mpf(3)'\n     assert p.doprint(mpmath_fn(x)) == 'mpmath.mpf(0.5)*x'\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update sympy/printing/tests/test_pycode.py: failed to find expected lines in /testbed/sympy/printing/tests/test_pycode.py:
def test_MpmathPrinter():
    p = MpmathPrinter()
    assert p.doprint(sign(x)) == 'mpmath.sign(x)'
    assert p.doprint(mpmath_fn(x)) == 'mpmath.mpf(0.5)*x'

The file's ACTUAL current content is below. Copy your context lines from THIS exact text — do not edit from memory:
1	# -*- coding: utf-8 -*-
2	from __future__ import (absolute_import, division, print_function)
3	
4	from sympy.codegen import Assignment
5	from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo
6	from sympy.core.numbers import pi
7	from sympy.codegen.ast import none
8	from sympy.external import import_module
9	from sympy.logic import And, Or
10	from sympy.functions import acos, Piecewise, sign
11	from sympy.matrices import SparseMatrix
12	from sympy.printing.pycode import (
13	    MpmathPrinter, NumPyPrinter, PythonCodePrinter, pycode, SciPyPrinter
14	)
15	from sympy.utilities.pytest import raises
16	
17	x, y, z = symbols('x y z')
18	
19	
20	def test_PythonCodePrinter():
21	    prntr = PythonCodePrinter()
22	    assert not prntr.module_imports
23	    assert prntr.doprint(x**y) == 'x**y'
24	    assert prntr.doprint(Mod(x, 2)) == 'x % 2'
25	    assert prntr.doprint(And(x, y)) == 'x and y'
26	    assert prntr.doprint(Or(x, y)) == 'x or y'
27	    assert not prntr.module_imports
28	    assert prntr.doprint(pi) == 'math.pi'
29	    assert prntr.module_imports == {'math': {'pi'}}
30	    assert prntr.doprint(acos(x)) == 'math.acos(x)'
31	    assert prntr.doprint(Assignment(x, 2)) == 'x = 2'
32	    assert prntr.doprint(Piecewise((1, Eq(x, 0)),
33	                        (2, x>6))) == '((1) if (x == 0) else (2) if (x > 6) else None)'
34	    assert prntr.doprint(Piecewise((2, Le(x, 0)),
35	                        (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
36	                                                        ' (3) if (x > 0) else None)'
37	    assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'
38	
39	
40	def test_MpmathPrinter():
41	    p = MpmathPrinter()
42	    assert p.doprint(sign(x)) == 'mpmath.sign(x)'
43	
44	
45	def test_NumPyPrinter():
46	    p = NumPyPrinter()
47	    assert p.doprint(sign(x)) == 'numpy.sign(x)'
48	
49	
50	def test_SciPyPrinter():
51	    p = SciPyPrinter()
52	    expr = acos(x)
53	    assert 'numpy' not in p.module_imports
54	    assert p.doprint(expr) == 'numpy.arccos(x)'
55	    assert 'numpy' in p.module_imports
56	    assert not any(m.startswith('scipy') for m in p.module_imports)
57	    smat = SparseMatrix(2, 5, {(0, 1): 3})
58	    assert p.doprint(smat) == 'scipy.sparse.coo_matrix([3], ([0], [1]), shape=(2, 5))'
59	    assert 'scipy.sparse' in p.module_imports
60	
61	
62	def test_pycode_reserved_words():
63	    s1, s2 = symbols('if else')
64	    raises(ValueError, lambda: pycode(s1 + s2, error_on_reserved=True))
65	    py_str = pycode(s1 + s2)
66	    assert py_str in ('else_ + if_', 'if_ + else_')
67	
68	
69	class CustomPrintedObject(Expr):
70	    def _numpycode(self, printer):
71	        return 'numpy'
72	
73	    def _mpmathcode(self, printer):
74	        return 'mpmath'
75	
76	
77	def test_printmethod():
78	    obj = CustomPrintedObject()
79	    assert NumPyPrinter().doprint(obj) == 'numpy'
80	    assert MpmathPrinter().doprint(obj) == 'mpmath'
81	
82	
83	def test_codegen_ast_nodes():
84	    assert pycode(none) == 'None'
85	
86	
87	def test_issue_14283():
88	    prntr = PythonCodePrinter()
89	
90	    assert prntr.doprint(zoo) == "float('nan')"
91	    assert prntr.doprint(-oo) == "float('-inf')"


Nothing in this patch was written — not sympy/printing/pycode.py, sympy/printing/tests/test_pycode.py. Fix it and resend the whole patch.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/printing/pycode.py\n@@\n     def _print_Float(self, e):\n         # XXX: This does not handle setting mpmath.mp.dps. It is assumed that\n         # the caller of the lambdified function will have set it to sufficient\n         # precision to match the Floats in the expression.\n \n         # Remove 'mpz' if gmpy is installed.\n         args = str(tuple(map(int, e._mpf_)))\n         return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)\n \n+    def _print_Rational(self, e):\n+        # Convert the numerator and denominator to mpf so that the division is\n+        # carried out at mpmath's working precision instead of using Python's\n+        # integer division (which would truncate the result to an integer).\n+        return '{0}({1})/{0}({2})'.format(\n+            self._module_format('mpmath.mpf'), e.p, e.q)\n+\n \n     def _print_uppergamma(self, e):\n*** Update File: sympy/printing/tests/test_pycode.py\n@@\n-from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo\n+from sympy.core import Expr, Mod, S, symbols, Eq, Le, Gt, zoo, oo\n@@\n def test_MpmathPrinter():\n     p = MpmathPrinter()\n     assert p.doprint(sign(x)) == 'mpmath.sign(x)'\n+    assert p.doprint(S(1)/3) == 'mpmath.mpf(1)/mpmath.mpf(3)'\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/printing/pycode.py sympy/printing/tests/test_pycode.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/printing/pycode.py now (563 lines), around the change:
331:        args = str(tuple(map(int, e._mpf_)))
332:        return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)
333:
334:    def _print_Rational(self, e):
335:        # Convert the numerator and denominator to mpf so that the division is
336:        # carried out at mpmath's working precision instead of using Python's
337:        # integer division (which would truncate the result to an integer).
338:        return '{0}({1})/{0}({2})'.format(
339:            self._module_format('mpmath.mpf'), e.p, e.q)
340:
341:
342:    def _print_uppergamma(self, e):
343:        return "{0}({1}, {2}, {3})".format(

sympy/printing/tests/test_pycode.py now (92 lines), around the change:
2:from __future__ import (absolute_import, division, print_function)
3:
4:from sympy.codegen import Assignment
5:from sympy.core import Expr, Mod, S, symbols, Eq, Le, Gt, zoo, oo
6:from sympy.core.numbers import pi
7:from sympy.codegen.ast import none
8:from sympy.external import import_module
…
40:def test_MpmathPrinter():
41:    p = MpmathPrinter()
42:    assert p.doprint(sign(x)) == 'mpmath.sign(x)'
43:    assert p.doprint(S(1)/3) == 'mpmath.mpf(1)/mpmath.mpf(3)'
44:
45:
46:def test_NumPyPrinter():
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sympy/printing/tests/test_pycode.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nfrom sympy.printing.pycode import MpmathPrinter\nx=Symbol('x')\np=MpmathPrinter()\nprint(p.doprint(S(1)/3))\nprint(p.doprint(S(-232)/3))\nfrom sympy.utilities.lambdify import lambdify\nimport inspect, mpmath\neqn=Eq(rf(18,x), 77+S(1)/3)\nf=lambdify(x, eqn.lhs-eqn.rhs, 'mpmath')\nprint(inspect.getsource(f))\nprint(f(mpmath.mpf('1.5')))\n\""
}
```

**tool result**

```
/testbed/sympy/solvers/diophantine.py:3188: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if feasible is 1:  # it's prime and k == 2
mpmath.mpf(1)/mpmath.mpf(3)
mpmath.mpf(-232)/mpmath.mpf(3)
def _lambdifygenerated(x):
    return (  # Not supported in Python:
  # RisingFactorial
RisingFactorial(18, x) + mpf(-232)/mpf(3))

0.612415648412878
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/printing/tests/test_pycode.py 2>&1 | tail -20"
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
random seed:        67794555
hash randomization: on (PYTHONHASHSEED=962351776)

sympy/printing/tests/test_pycode.py[8] ........                             [OK]

================== tests finished: 8 passed, in 0.02 seconds ===================
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/utilities/tests/test_lambdify.py 2>&1 | tail -15"
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
random seed:        56331327
hash randomization: on (PYTHONHASHSEED=4078825173)

sympy/utilities/tests/test_lambdify.py[83] .................sssss...........ssss
ss.ssssssssssssss...................s.s...ss..                              [OK]

============ tests finished: 54 passed, 29 skipped, in 0.35 seconds ============
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nx=Symbol('x')\neqn=Eq(rf(18,x), 77+S(1)/3)\nx0=nsolve(eqn, Float('1.5',64), prec=64)\nprint(rf(18,x0).evalf(64))\n\" 2>&1 | tail -3"
}
```

**tool result**

```
77.33333333333333333333333333333333333333333333333333333333333333
```

**assistant**

```
I fixed the mpmath printer so rationals are emitted as `mpmath.mpf(p)/mpmath.mpf(q)` rather than Python integer division.

Changes:
- `sympy/printing/pycode.py`: added `MpmathPrinter._print_Rational`.
- `sympy/printing/tests/test_pycode.py`: added a regression assertion for `S(1)/3`.

Verified:
- `MpmathPrinter().doprint(S(1)/3)` → `mpmath.mpf(1)/mpmath.mpf(3)`
- Existing `test_pycode.py`: 8 passed
- `test_lambdify.py`: 54 passed, 29 skipped
- The original `nsolve(..., prec=64)` example now yields `77.33333333333333333333333333333333333333333333333333333333333333`, i.e. full precision rather than the truncated `77.333333333333328...` result.
```

## Run folder `team-solve-2026-11-06T133913`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
a2eb1df2c17ee0edfe0c9dd3671da8768fad8e0b
```

### `baseline-check.log`

```
check: python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sympy/printing/pycode.py b/sympy/printing/pycode.py
index d06901425..201917928 100644
--- a/sympy/printing/pycode.py
+++ b/sympy/printing/pycode.py
@@ -331,6 +331,13 @@ def _print_Float(self, e):
         args = str(tuple(map(int, e._mpf_)))
         return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)
 
+    def _print_Rational(self, e):
+        # Convert the numerator and denominator to mpf so that the division is
+        # carried out at mpmath's working precision instead of using Python's
+        # integer division (which would truncate the result to an integer).
+        return '{0}({1})/{0}({2})'.format(
+            self._module_format('mpmath.mpf'), e.p, e.q)
+
 
     def _print_uppergamma(self, e):
         return "{0}({1}, {2}, {3})".format(
diff --git a/sympy/printing/tests/test_pycode.py b/sympy/printing/tests/test_pycode.py
index 68994056e..b7ad8ceae 100644
--- a/sympy/printing/tests/test_pycode.py
+++ b/sympy/printing/tests/test_pycode.py
@@ -2,7 +2,7 @@
 from __future__ import (absolute_import, division, print_function)
 
 from sympy.codegen import Assignment
-from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo
+from sympy.core import Expr, Mod, S, symbols, Eq, Le, Gt, zoo, oo
 from sympy.core.numbers import pi
 from sympy.codegen.ast import none
 from sympy.external import import_module
@@ -40,6 +40,7 @@ def test_PythonCodePrinter():
 def test_MpmathPrinter():
     p = MpmathPrinter()
     assert p.doprint(sign(x)) == 'mpmath.sign(x)'
+    assert p.doprint(S(1)/3) == 'mpmath.mpf(1)/mpmath.mpf(3)'
 
 
 def test_NumPyPrinter():
```

### `check-kind.txt`

```
judge
```

### `context.md`

````
# task.md

# Task

## Prompt

lambdify(modules='mpmath') doesn't wrap rationals
```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> f = lambdify(x, eqn.lhs - eqn.rhs, 'mpmath')
>>> print(inspect.getsource(f))
def _lambdifygenerated(x):
    return (  # Not supported in Python:
  # RisingFactorial
RisingFactorial(18, x) - 232/3)
```

This results in reduced precision results from `nsolve`, because the 232/3 isn't evaluated at full precision. 

```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> x0 = nsolve(eqn, Float('1.5', 64), prec=64)
>>> rf(18, x0).evalf(64)
77.33333333333332859638176159933209419250488281250000000000000000
```

Originally reported at https://github.com/sympy/sympy/pull/14971

## Deliverable

changes to this tree

## Check

`python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q`

## Scope

`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`
`sympy/utilities/tests/test_lambdify.py`

## Done when

The mpmath lambdified output for a `Rational` wraps the numerator in `mpmath.mpf` instead of emitting bare integer division such as `232/3`.
`lambdify(x, rf(18, x) - (77 + S(1)/3), 'mpmath')` evaluates the rational constant at the active mpmath precision.
The reported `nsolve(..., prec=64)` case no longer loses precision through an un-wrapped rational constant.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q`

## Scope
`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`
`sympy/utilities/tests/test_lambdify.py`

## Done when
The mpmath lambdified output for a `Rational` wraps the numerator in `mpmath.mpf` instead of emitting bare integer division such as `232/3`.
`lambdify(x, rf(18, x) - (77 + S(1)/3), 'mpmath')` evaluates the rational constant at the active mpmath precision.
The reported `nsolve(..., prec=64)` case no longer loses precision through an un-wrapped rational constant.

## Approach
Add a `_print_Rational` override in `MpmathPrinter` in `sympy/printing/pycode.py`, returning an expression built from `mpmath.mpf` for the numerator and the denominator, then cover it with printer and/or lambdify regression tests.

Candidate approaches:
- Override only `MpmathPrinter._print_Rational` with `mpmath.mpf(p)/q`: smallest, targeted, keeps the Python printer unchanged.
- Handle rationals in `lambdify.py` before code generation: broader and risks affecting non-mpmath modules.
- Change `PythonCodePrinter._print_Rational` globally with a module/settings check: more invasive and could regress existing Python/numpy output.


# sympy/printing/pycode.py

```
"""
Python code printers

This module contains python code printers for plain python as well as NumPy & SciPy enabled code.
"""


from collections import defaultdict
from functools import wraps
from itertools import chain
from sympy.core import sympify, S
from .precedence import precedence
from .codeprinter import CodePrinter

_kw_py2and3 = {
    'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif',
    'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in',
    'is', 'lambda', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while',
    'with', 'yield', 'None'  # 'None' is actually not in Python 2's keyword.kwlist
}
_kw_only_py2 = {'exec', 'print'}
_kw_only_py3 = {'False', 'nonlocal', 'True'}

_known_functions = {
    'Abs': 'abs',
}
_known_functions_math = {
    'acos': 'acos',
    'acosh': 'acosh',
    'asin': 'asin',
    'asinh': 'asinh',
    'atan': 'atan',
    'atan2': 'atan2',
    'atanh': 'atanh',
    'ceiling': 'ceil',
    'cos': 'cos',
    'cosh': 'cosh',
    'erf': 'erf',
    'erfc': 'erfc',
    'exp': 'exp',
    'expm1': 'expm1',
    'factorial': 'factorial',
    'floor': 'floor',
    'gamma': 'gamma',
    'hypot': 'hypot',
    'loggamma': 'lgamma',
    'log': 'log',
    'log10': 'log10',
    'log1p': 'log1p',
    'log2': 'log2',
    'sin': 'sin',
    'sinh': 'sinh',
    'Sqrt': 'sqrt',
    'tan': 'tan',
    'tanh': 'tanh'
}  # Not used from ``math``: [copysign isclose isfinite isinf isnan ldexp frexp pow modf
# radians trunc fmod fsum gcd degrees fabs]
_known_constants_math = {
    'Exp1': 'e',
    'Pi': 'pi',
    # Only in python >= 3.5:
    # 'Infinity': 'inf',
    # 'NaN': 'nan'
}

def _print_known_func(self, expr):
    known = self.known_functions[expr.__class__.__name__]
    return '{name}({args})'.format(name=self._module_format(known),
                                   args=', '.join(map(lambda arg: self._print(arg), expr.args)))


def _print_known_const(self, expr):
    known = self.known_constants[expr.__class__.__name__]
    return self._module_format(known)


class PythonCodePrinter(CodePrinter):
    printmethod = "_pythoncode"
    language = "Python"
    standard = "python3"
    reserved_words = _kw_py2and3.union(_kw_only_py3)
    modules = None  # initialized to a set in __init__
    tab = '    '
    _kf = dict(chain(
        _known_functions.items(),
        [(k, 'math.' + v) for k, v in _known_functions_math.items()]
    ))
    _kc = {k: 'math.'+v for k, v in _known_constants_math.items()}
    _operators = {'and': 'and', 'or': 'or', 'not': 'not'}
    _default_settings = dict(
        CodePrinter._default_settings,
        user_functions={},
        precision=17,
        inline=True,
        fully_qualified_modules=True,
        contract=False
    )

    def __init__(self, settings=None):
        super(PythonCodePrinter, self).__init__(settings)
        self.module_imports = defaultdict(set)
        self.known_functions = dict(self._kf, **(settings or {}).get(
            'user_functions', {}))
        self.known_constants = dict(self._kc, **(settings or {}).get(
            'user_constants', {}))

    def _get_statement(self, codestring):
        return codestring

    def _declare_number_const(self, name, value):
        return "%s = %s" % (name, value)

    def _module_format(self, fqn, register=True):
        parts = fqn.split('.')
        if register and len(parts) > 1:
            self.module_imports['.'.join(parts[:-1])].add(parts[-1])

        if self._settings['fully_qualified_modules']:
            return fqn
        else:
            return fqn.split('(')[0].split('[')[0].split('.')[-1]

    def _format_code(self, lines):
        return lines

    def _get_statement(self, codestring):
        return "%s" % codestring

    def _get_comment(self, text):
        return "  # {0}".format(text)

    def _print_NaN(self, expr):
        return "float('nan')"

    def _print_Infinity(self, expr):
        return "float('inf')"

    def _print_sign(self, e):
        return '(0.0 if {e} == 0 else {f}(1, {e}))'.format(
            f=self._module_format('math.copysign'), e=self._print(e.args[0]))

    def _print_NegativeInfinity(self, expr):
        return "float('-inf')"

    def _print_ComplexInfinity(self, expr):
        return self._print_NaN(expr)

    def _print_Mod(self, expr):
        PREC = precedence(expr)
        return ('{0} % {1}'.format(*map(lambda x: self.parenthesize(x, PREC), expr.args)))

    def _print_Piecewise(self, expr):
        result = []
        i = 0
        for arg in expr.args:
            e = arg.expr
            c = arg.cond
            if i == 0:
                result.append('(')
            result.append('(')
            result.append(self._print(e))
            result.append(')')
            result.append(' if ')
            result.append(self._print(c))
            result.append(' else ')
            i += 1
        result = result[:-1]
        if result[-1] == 'True':
            result = result[:-2]
            result.append(')')
        else:
            result.append(' else None)')
        return ''.join(result)

    def _print_Relational(self, expr):
        "Relational printer for Equality and Unequality"
        op = {
            '==' :'equal',
            '!=' :'not_equal',
            '<'  :'less',
            '<=' :'less_equal',
            '>'  :'greater',
            '>=' :'greater_equal',
        }
        if expr.rel_op in op:
            lhs = self._print(expr.lhs)
            rhs = self._print(expr.rhs)
            return '({lhs} {op} {rhs})'.format(op=expr.rel_op, lhs=lhs, rhs=rhs)
        return super(PythonCodePrinter, self)._print_Relational(expr)

    def _print_ITE(self, expr):
        from sympy.functions.elementary.piecewise import Piecewise
        return self._print(expr.rewrite(Piecewise))

    def _print_Sum(self, expr):
        loops = (
            'for {i} in range({a}, {b}+1)'.format(
                i=self._print(i),
                a=self._print(a),
                b=self._print(b))
            for i, a, b in expr.limits)
        return '(builtins.sum({function} {loops}))'.format(
            function=self._print(expr.function),
            loops=' '.join(loops))

    def _print_ImaginaryUnit(self, expr):
        return '1j'

    def _print_MatrixBase(self, expr):
        name = expr.__class__.__name__
        func = self.known_functions.get(name, name)
        return "%s(%s)" % (func, self._print(expr.tolist()))

    _print_SparseMatrix = \
        _print_MutableSparseMatrix = \
        _print_ImmutableSparseMatrix = \
        _print_Matrix = \
        _print_DenseMatrix = \
        _print_MutableDenseMatrix = \
        _print_ImmutableMatrix = \
        _print_ImmutableDenseMatrix = \
        lambda self, expr: self._print_MatrixBase(expr)

    def _indent_codestring(self, codestring):
        return '\n'.join([self.tab + line for line in codestring.split('\n')])

    def _print_FunctionDefinition(self, fd):
        body = '\n'.join(map(lambda arg: self._print(arg), fd.body))
        return "def {name}({parameters}):\n{body}".format(
            name=self._print(fd.name),
            parameters=', '.join([self._print(var.symbol) for var in fd.parameters]),
            body=self._indent_codestring(body)
        )

    def _print_While(self, whl):
        body = '\n'.join(map(lambda arg: self._print(arg), whl.body))
        return "while {cond}:\n{body}".format(
            cond=self._print(whl.condition),
            body=self._indent_codestring(body)
        )

    def _print_Declaration(self, decl):
        return '%s = %s' % (
            self._print(decl.variable.symbol),
            self._print(decl.variable.value)
        )

    def _print_Return(self, ret):
        arg, = ret.args
        return 'return %s' % self._print(arg)

    def _print_Print(self, prnt):
        print_args = ', '.join(map(lambda arg: self._print(arg), prnt.print_args))
        if prnt.format_string != None:
            print_args = '{0} % ({1})'.format(
                self._print(prnt.format_string), print_args)
        if prnt.file != None:
            print_args += ', file=%s' % self._print(prnt.file)
        return 'print(%s)' % print_args

    def _print_Stream(self, strm):
        if str(strm.name) == 'stdout':
            return self._module_format('sys.stdout')
        elif str(strm.name) == 'stderr':
            return self._module_format('sys.stderr')
        else:
            return self._print(strm.name)

    def _print_NoneToken(self, arg):
        return 'None'


for k in PythonCodePrinter._kf:
    setattr(PythonCodePrinter, '_print_%s' % k, _print_known_func)

for k in _known_constants_math:
    setattr(PythonCodePrinter, '_print_%s' % k, _print_known_const)


def pycode(expr, **settings):
    """ Converts an expr to a string of Python code

    Parameters
    ==========

    expr : Expr
        A SymPy expression.
    fully_qualified_modules : bool
        Whether or not to write out full module names of functions
        (``math.sin`` vs. ``sin``). default: ``True``.

    Examples
    ========

    >>> from sympy import tan, Symbol
    >>> from sympy.printing.pycode import pycode
    >>> pycode(tan(Symbol('x')) + 1)
    'math.tan(x) + 1'

    """
    return PythonCodePrinter(settings).doprint(expr)


_not_in_mpmath = 'log1p log2'.split()
_in_mpmath = [(k, v) for k, v in _known_functions_math.items() if k not in _not_in_mpmath]
_known_functions_mpmath = dict(_in_mpmath, **{
    'sign': 'sign',
})
_known_constants_mpmath = {
    'Pi': 'pi'
}


class MpmathPrinter(PythonCodePrinter):
    """
    Lambda printer for mpmath which maintains precision for floats
    """
    printmethod = "_mpmathcode"

    _kf = dict(chain(
        _known_functions.items(),
        [(k, 'mpmath.' + v) for k, v in _known_functions_mpmath.items()]
    ))

    def _print_Float(self, e):
        # XXX: This does not handle setting mpmath.mp.dps. It is assumed that
        # the caller of the lambdified function will have set it to sufficient
        # precision to match the Floats in the expression.

        # Remove 'mpz' if gmpy is installed.
        args = str(tuple(map(int, e._mpf_)))
        return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)

    def _print_Rational(self, e):
        # Convert the numerator and denominator to mpf so that the division is
        # carried out at mpmath's working precision instead of using Python's
        # integer division (which would truncate the result to an integer).
        return '{0}({1})/{0}({2})'.format(
            self._module_format('mpmath.mpf'), e.p, e.q)


    def _print_uppergamma(self, e):
        return "{0}({1}, {2}, {3})".format(
            self._module_format('mpmath.gammainc'),
            self._print(e.args[0]),
            self._print(e.args[1]),
            self._module_format('mpmath.inf'))

    def _print_lowergamma(self, e):
        return "{0}({1}, 0, {2})".format(
            self._module_format('mpmath.gammainc'),
            self._print(e.args[0]),
            self._print(e.args[1]))

    def _print_log2(self, e):
        return '{0}({1})/{0}(2)'.format(
            self._module_format('mpmath.log'), self._print(e.args[0]))

    def _print_log1p(self, e):
        return '{0}({1}+1)'.format(
            self._module_format('mpmath.log'), self._print(e.args[0]))

for k in MpmathPrinter._kf:
    setattr(MpmathPrinter, '_print_%s' % k, _print_known_func)

for k in _known_constants_mpmath:
    setattr(MpmathPrinter, '_print_%s' % k, _print_known_const)


_not_in_numpy = 'erf erfc factorial gamma lgamma'.split()
_in_numpy = [(k, v) for k, v in _known_functions_math.items() if k not in _not_in_numpy]
_known_functions_numpy = dict(_in_numpy, **{
    'acos': 'arccos',
    'acosh': 'arccosh',
    'asin': 'arcsin',
    'asinh': 'arcsinh',
    'atan': 'arctan',
    'atan2': 'arctan2',
    'atanh': 'arctanh',
    'exp2': 'exp2',
    'sign': 'sign',
})


class NumPyPrinter(PythonCodePrinter):
    """
    Numpy printer which handles vectorized piecewise functions,
    logical operators, etc.
    """
    printmethod = "_numpycode"

    _kf = dict(chain(
        PythonCodePrinter._kf.items(),
        [(k, 'numpy.' + v) for k, v in _known_functions_numpy.items()]
    ))
    _kc = {k: 'numpy.'+v for k, v in _known_constants_math.items()}


    def _print_seq(self, seq):
        "General sequence printer: converts to tuple"
        # Print tuples here instead of lists because numba supports
        #     tuples in nopython mode.
        delimite.get('delimiter', ', ')
        return '({},)'.format(delimiter.join(self._print(item) for item in seq))

    def _print_MatMul(self, expr):
        "Matrix multiplication printer"
        return '({0})'.format(').dot('.join(self._print(i) for i in expr.args))

    def _print_DotProduct(self, expr):
        # DotProduct allows any shape order, but numpy.dot does matrix
        # multiplication, so we have to make sure it gets 1 x n by n x 1.
        arg1, arg2 = expr.args
        if arg1.shape[0] != 1:
            arg1 = arg1.T
        if arg2.shape[1] != 1:
            arg2 = arg2.T

        return "%s(%s, %s)" % (self._module_format('numpy.dot'),
                               self._print(arg1),
                               self._print(arg2))

    def _print_Piecewise(self, expr):
        "Piecewise function printer"
        exprs = '[{0}]'.format(','.join(self._print(arg.expr) for arg in expr.args))
        conds = '[{0}]'.format(','.join(self._print(arg.cond) for arg in expr.args))
        # If [default_value, True] is a (expr, cond) sequence in a Piecewise object
        #     it will behave the same as passing the 'default' kwarg to select()
        #     *as long as* it is the last element in expr.args.
        # If this is not the case, it may be triggered prematurely.
        return '{0}({1}, {2}, default=numpy.nan)'.format(self._module_format('numpy.select'), conds, exprs)

    def _print_Relational(self, expr):
        "Relational printer for Equality and Unequality"
        op = {
            '==' :'equal',
            '!=' :'not_equal',
            '<'  :'less',
            '<=' :'less_equal',
            '>'  :'greater',
            '>=' :'greater_equal',
        }
        if expr.rel_op in op:
            lhs = self._print(expr.lhs)
            rhs = self._print(expr.rhs)
            return '{op}({lhs}, {rhs})'.format(op=self._module_format('numpy.'+op[expr.rel_op]),
                                               lhs=lhs, rhs=rhs)
        return super(NumPyPrinter, self)._print_Relational(expr)

    def _print_And(self, expr):
        "Logical And printer"
        # We have to override LambdaPrinter because it uses Python 'and' keyword.
        # If LambdaPrinter didn't define it, we could use StrPrinter's
        # version of the function and add 'logical_and' to NUMPY_TRANSLATIONS.
        return '{0}.reduce(({1}))'.format(self._module_format('numpy.logical_and'), ','.join(self._print(i) for i in expr.args))

    def _print_Or(self, expr):
        "Logical Or printer"
        # We have to override LambdaPrinter because it uses Python 'or' keyword.
        # If LambdaPrinter didn't define it, we could use StrPrinter's
        # version of the function and add 'logical_or' to NUMPY_TRANSLATIONS.
        return '{0}.reduce(({1}))'.format(self._module_format('numpy.logical_or'), ','.join(self._print(i) for i in expr.args))

    def _print_Not(self, expr):
        "Logical Not printer"
        # We have to override LambdaPrinter because it uses Python 'not' keyword.
        # If LambdaPrinter didn't define it, we would still have to define our
        #     own because StrPrinter doesn't define it.
        return '{0}({1})'.format(self._module_format('numpy.logical_not'), ','.join(self._print(i) for i in expr.args))

    def _print_Min(self, expr):
        return '{0}(({1}))'.format(self._module_format('numpy.amin'), ','.join(self._print(i) for i in expr.args))

    def _print_Max(self, expr):
        return '{0}(({1}))'.format(self._module_format('numpy.amax'), ','.join(self._print(i) for i in expr.args))

    def _print_Pow(self, expr):
        if expr.exp == 0.5:
            return '{0}({1})'.format(self._module_format('numpy.sqrt'), self._print(expr.base))
        else:
            return super(NumPyPrinter, self)._print_Pow(expr)

    def _print_arg(self, expr):
        return "%s(%s)" % (self._module_format('numpy.angle'), self._print(expr.args[0]))

    def _print_im(self, expr):
        return "%s(%s)" % (self._module_format('numpy.imag', self._print(expr.args[0])))

    def _print_Mod(self, expr):
        return "%s(%s)" % (self._module_format('numpy.mod'), ', '.join(
            map(lambda arg: self._print(arg), expr.args)))

    def _print_re(self, expr):
        return "%s(%s)" % (self._module_format('numpy.real'), self._print(expr.args[0]))

    def _print_sinc(self, expr):
        return "%s(%s)" % (self._module_format('numpy.sinc'), self._print(expr.args[0]/S.Pi))

    def _print_MatrixBase(self, expr):
        func = self.known_functions.get(expr.__class__.__name__, None)
        if func is None:
            func = self._module_format('numpy.array')
        return "%s(%s)" % (func, self._print(expr.tolist()))


for k in NumPyPrinter._kf:
    setattr(NumPyPrinter, '_print_%s' % k, _print_known_func)

for k in NumPyPrinter._kc:
    setattr(NumPyPrinter, '_print_%s' % k, _print_known_const)


_known_functions_scipy_special = {
    'erf': 'erf',
    'erfc': 'erfc',
    'gamma': 'gamma',
    'loggamma': 'gammaln'
}
_known_constants_scipy_constants = {
    'GoldenRatio': 'golden_ratio'
}

class SciPyPrinter(NumPyPrinter):

    _kf = dict(chain(
        NumPyPrinter._kf.items(),
        [(k, 'scipy.special.' + v) for k, v in _known_functions_scipy_special.items()]
    ))
    _kc = {k: 'scipy.constants.' + v for k, v in _known_constants_scipy_constants.items()}

    def _print_SparseMatrix(self, expr):
        i, j, data = [], [], []
        for (r, c), v in expr._smat.items():
            i.append(r)
            j.append(c)
            data.append(v)

        return "{name}({data}, ({i}, {j}), shape={shape})".format(
            name=self._module_format('scipy.sparse.coo_matrix'),
            data=data, i=i, j=j, shape=expr.shape
        )

    _print_ImmutableSparseMatrix = _print_SparseMatrix


for k in SciPyPrinter._kf:
    setattr(SciPyPrinter, '_print_%s' % k, _print_known_func)

for k in SciPyPrinter._kc:
    setattr(SciPyPrinter, '_print_%s' % k, _print_known_const)


class SymPyPrinter(PythonCodePrinter):

    _kf = dict([(k, 'sympy.' + v) for k, v in chain(
        _known_functions.items(),
        _known_functions_math.items()
    )])

    def _print_Function(self, expr):
        mod = expr.func.__module__ or ''
        return '%s(%s)' % (self._module_format(mod + ('.' if mod else '') + expr.func.__name__),
                           ', '.join(map(lambda arg: self._print(arg), expr.args)))

```


# sympy/printing/tests/test_pycode.py

```
# -*- coding: utf-8 -*-
from __future__ import (absolute_import, division, print_function)

from sympy.codegen import Assignment
from sympy.core import Expr, Mod, S, symbols, Eq, Le, Gt, zoo, oo
from sympy.core.numbers import pi
from sympy.codegen.ast import none
from sympy.external import import_module
from sympy.logic import And, Or
from sympy.functions import acos, Piecewise, sign
from sympy.matrices import SparseMatrix
from sympy.printing.pycode import (
    MpmathPrinter, NumPyPrinter, PythonCodePrinter, pycode, SciPyPrinter
)
from sympy.utilities.pytest import raises

x, y, z = symbols('x y z')


def test_PythonCodePrinter():
    prntr = PythonCodePrinter()
    assert not prntr.module_imports
    assert prntr.doprint(x**y) == 'x**y'
    assert prntr.doprint(Mod(x, 2)) == 'x % 2'
    assert prntr.doprint(And(x, y)) == 'x and y'
    assert prntr.doprint(Or(x, y)) == 'x or y'
    assert not prntr.module_imports
    assert prntr.doprint(pi) == 'math.pi'
    assert prntr.module_imports == {'math': {'pi'}}
    assert prntr.doprint(acos(x)) == 'math.acos(x)'
    assert prntr.doprint(Assignment(x, 2)) == 'x = 2'
    assert prntr.doprint(Piecewise((1, Eq(x, 0)),
                        (2, x>6))) == '((1) if (x == 0) else (2) if (x > 6) else None)'
    assert prntr.doprint(Piecewise((2, Le(x, 0)),
                        (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
                                                        ' (3) if (x > 0) else None)'
    assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'


def test_MpmathPrinter():
    p = MpmathPrinter()
    assert p.doprint(sign(x)) == 'mpmath.sign(x)'
    assert p.doprint(S(1)/3) == 'mpmath.mpf(1)/mpmath.mpf(3)'


def test_NumPyPrinter():
    p = NumPyPrinter()
    assert p.doprint(sign(x)) == 'numpy.sign(x)'


def test_SciPyPrinter():
    p = SciPyPrinter()
    expr = acos(x)
    assert 'numpy' not in p.module_imports
    assert p.doprint(expr) == 'numpy.arccos(x)'
    assert 'numpy' in p.module_imports
    assert not any(m.startswith('scipy') for m in p.module_imports)
    smat = SparseMatrix(2, 5, {(0, 1): 3})
    assert p.doprint(smat) == 'scipy.sparse.coo_matrix([3], ([0], [1]), shape=(2, 5))'
    assert 'scipy.sparse' in p.module_imports


def test_pycode_reserved_words():
    s1, s2 = symbols('if else')
    raises(ValueError, lambda: pycode(s1 + s2, error_on_reserved=True))
    py_str = pycode(s1 + s2)
    assert py_str in ('else_ + if_', 'if_ + else_')


class CustomPrintedObject(Expr):
    def _numpycode(self, printer):
        return 'numpy'

    def _mpmathcode(self, printer):
        return 'mpmath'


def test_printmethod():
    obj = CustomPrintedObject()
    assert NumPyPrinter().doprint(obj) == 'numpy'
    assert MpmathPrinter().doprint(obj) == 'mpmath'


def test_codegen_ast_nodes():
    assert pycode(none) == 'None'


def test_issue_14283():
    prntr = PythonCodePrinter()

    assert prntr.doprint(zoo) == "float('nan')"
    assert prntr.doprint(-oo) == "float('-inf')"

```


# sympy/utilities/tests/test_lambdify.py

```
from distutils.version import LooseVersion as V
from itertools import product
import math
import inspect

import mpmath
from sympy.utilities.pytest import XFAIL, raises
from sympy import (
    symbols, lambdify, sqrt, sin, cos, tan, pi, acos, acosh, Rational,
    Float, Matrix, Lambda, Piecewise, exp, Integral, oo, I, Abs, Function,
    true, false, And, Or, Not, ITE, Min, Max, floor, diff, IndexedBase, Sum,
    DotProduct, Eq, Dummy, sinc)
from sympy.printing.lambdarepr import LambdaPrinter
from sympy.utilities.lambdify import implemented_function
from sympy.utilities.pytest import skip
from sympy.utilities.decorator import conserve_mpmath_dps
from sympy.external import import_module
from sympy.functions.special.gamma_functions import uppergamma,lowergamma

import sympy


MutableDenseMatrix = Matrix

numpy = import_module('numpy')
numexpr = import_module('numexpr')
tensorflow = import_module('tensorflow')

if tensorflow:
    # Hide Tensorflow warnings
    import os
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

w, x, y, z = symbols('w,x,y,z')

#================== Test different arguments =======================


def test_no_args():
    f = lambdify([], 1)
    raises(TypeError, lambda: f(-1))
    assert f() == 1


def test_single_arg():
    f = lambdify(x, 2*x)
    assert f(1) == 2


def test_list_args():
    f = lambdify([x, y], x + y)
    assert f(1, 2) == 3

def test_nested_args():
    f1 = lambdify([[w, x]], [w, x])
    assert f1([91, 2]) == [91, 2]
    raises(TypeError, lambda: f1(1, 2))

    f2 = lambdify([(w, x), (y, z)], [w, x, y, z])
    assert f2((18, 12), (73, 4)) == [18, 12, 73, 4]
    raises(TypeError, lambda: f2(3, 4))

    f3 = lambdify([w, [[[x]], y], z], [w, x, y, z])
    assert f3(10, [[[52]], 31], 44) == [10, 52, 31, 44]

def test_str_args():
    f = lambdify('x,y,z', 'z,y,x')
    assert f(3, 2, 1) == (1, 2, 3)
    assert f(1.0, 2.0, 3.0) == (3.0, 2.0, 1.0)
    # make sure correct number of args required
    raises(TypeError, lambda: f(0))


def test_own_namespace_1():
    myfunc = lambda x: 1
    f = lambdify(x, sin(x), {"sin": myfunc})
    assert f(0.1) == 1
    assert f(100) == 1


def test_own_namespace_2():
    def myfunc(x):
        return 1
    f = lambdify(x, sin(x), {'sin': myfunc})
    assert f(0.1) == 1
    assert f(100) == 1


def test_own_module():
    f = lambdify(x, sin(x), math)
    assert f(0) == 0.0


def test_bad_args():
    # no vargs given
    raises(TypeError, lambda: lambdify(1))
    # same with vector exprs
    raises(TypeError, lambda: lambdify([1, 2]))


def test_atoms():
    # Non-Symbol atoms should not be pulled out from the expression namespace
    f = lambdify(x, pi + x, {"pi": 3.14})
    assert f(0) == 3.14
    f = lambdify(x, I + x, {"I": 1j})
    assert f(1) == 1 + 1j

#================== Test different modules =========================

# high precision output of sin(0.2*pi) is used to detect if precision is lost unwanted


@conserve_mpmath_dps
def test_sympy_lambda():
    mpmath.mp.dps = 50
    sin02 = mpmath.mpf("0.19866933079506121545941262711838975037020672954020")
    f = lambdify(x, sin(x), "sympy")
    assert f(x) == sin(x)
    prec = 1e-15
    assert -prec < f(Rational(1, 5)).evalf() - Float(str(sin02)) < prec
    # arctan is in numpy module and should not be available
    raises(NameError, lambda: lambdify(x, arctan(x), "sympy"))


@conserve_mpmath_dps
def test_math_lambda():
    mpmath.mp.dps = 50
    sin02 = mpmath.mpf("0.19866933079506121545941262711838975037020672954020")
    f = lambdify(x, sin(x), "math")
    prec = 1e-15
    assert -prec < f(0.2) - sin02 < prec
    raises(TypeError, lambda: f(x))
           # if this succeeds, it can't be a python math function


@conserve_mpmath_dps
def test_mpmath_lambda():
    mpmath.mp.dps = 50
    sin02 = mpmath.mpf("0.19866933079506121545941262711838975037020672954020")
    f = lambdify(x, sin(x), "mpmath")
    prec = 1e-49  # mpmath precision is around 50 decimal places
    assert -prec < f(mpmath.mpf("0.2")) - sin02 < prec
    raises(TypeError, lambda: f(x))
           # if this succeeds, it can't be a mpmath function


@conserve_mpmath_dps
def test_number_precision():
    mpmath.mp.dps = 50
    sin02 = mpmath.mpf("0.19866933079506121545941262711838975037020672954020")
    f = lambdify(x, sin02, "mpmath")
    prec = 1e-49  # mpmath precision is around 50 decimal places
    assert -prec < f(0) - sin02 < prec

@conserve_mpmath_dps
def test_mpmath_precision():
    mpmath.mp.dps = 100
    assert str(lambdify((), pi.evalf(100), 'mpmath')()) == str(pi.evalf(100))

#================== Test Translations ==============================
# We can only check if all translated functions are valid. It has to be checked
# by hand if they are complete.


def test_math_transl():
    from sympy.utilities.lambdify import MATH_TRANSLATIONS
    for sym, mat in MATH_TRANSLATIONS.items():
        assert sym in sympy.__dict__
        assert mat in math.__dict__


def test_mpmath_transl():
    from sympy.utilities.lambdify import MPMATH_TRANSLATIONS
    for sym, mat in MPMATH_TRANSLATIONS.items():
        assert sym in sympy.__dict__ or sym == 'Matrix'
        assert mat in mpmath.__dict__


def test_numpy_transl():
    if not numpy:
        skip("numpy not installed.")

    from sympy.utilities.lambdify import NUMPY_TRANSLATIONS
    for sym, nump in NUMPY_TRANSLATIONS.items():
        assert sym in sympy.__dict__
        assert nump in numpy.__dict__

def test_tensorflow_transl():
    if not tensorflow:
        skip("tensorflow not installed")

    from sympy.utilities.lambdify import TENSORFLOW_TRANSLATIONS
    for sym, tens in TENSORFLOW_TRANSLATIONS.items():
        assert sym in sympy.__dict__
        assert tens in tensorflow.__dict__

def test_numpy_translation_abs():
    if not numpy:
        skip("numpy not installed.")

    f = lambdify(x, Abs(x), "numpy")
    assert f(-1) == 1
    assert f(1) == 1

def test_numexpr_printer():
    if not numexpr:
        skip("numexpr not installed.")

    # if translation/printing is done incorrectly then evaluating
    # a lambdified numexpr expression will throw an exception
    from sympy.printing.lambdarepr import NumExprPrinter
    from sympy import S

    blacklist = ('where', 'complex', 'contains')
    arg_tuple = (x, y, z) # some functions take more than one argument
    for sym in NumExprPrinter._numexpr_functions.keys():
        if sym in blacklist:
            continue
        ssym = S(sym)
        if hasattr(ssym, '_nargs'):
            nargs = ssym._nargs[0]
        else:
            nargs = 1
        args = arg_tuple[:nargs]
        f = lambdify(args, ssym(*args), modules='numexpr')
        assert f(*(1, )*nargs) is not None

def test_issue_9334():
    if not numexpr:
        skip("numexpr not installed.")
    if not numpy:
        skip("numpy not installed.")
    expr = sympy.S('b*a - sqrt(a**2)')
    a, b = sorted(expr.free_symbols, key=lambda s: s.name)
    func_numexpr = lambdify((a,b), expr, modules=[numexpr], dummify=False)
    foo, bar = numpy.random.random((2, 4))
    func_numexpr(foo, bar)

#================== Test some functions ============================


def test_exponentiation():
    f = lambdify(x, x**2)
    assert f(-1) == 1
    assert f(0) == 0
    assert f(1) == 1
    assert f(-2) == 4
    assert f(2) == 4
    assert f(2.5) == 6.25


def test_sqrt():
    f = lambdify(x, sqrt(x))
    assert f(0) == 0.0
    assert f(1) == 1.0
    assert f(4) == 2.0
    assert abs(f(2) - 1.414) < 0.001
    assert f(6.25) == 2.5


def test_trig():
    f = lambdify([x], [cos(x), sin(x)], 'math')
    d = f(pi)
    prec = 1e-11
    assert -prec < d[0] + 1 < prec
    assert -prec < d[1] < prec
    d = f(3.14159)
    prec = 1e-5
    assert -prec < d[0] + 1 < prec
    assert -prec < d[1] < prec

#================== Test vectors ===================================


def test_vector_simple():
    f = lambdify((x, y, z), (z, y, x))
    assert f(3, 2, 1) == (1, 2, 3)
    assert f(1.0, 2.0, 3.0) == (3.0, 2.0, 1.0)
    # make sure correct number of args required
    raises(TypeError, lambda: f(0))


def test_vector_discontinuous():
    f = lambdify(x, (-1/x, 1/x))
    raises(ZeroDivisionError, lambda: f(0))
    assert f(1) == (-1.0, 1.0)
    assert f(2) == (-0.5, 0.5)
    assert f(-2) == (0.5, -0.5)


def test_trig_symbolic():
    f = lambdify([x], [cos(x), sin(x)], 'math')
    d = f(pi)
    assert abs(d[0] + 1) < 0.0001
    assert abs(d[1] - 0) < 0.0001


def test_trig_float():
    f = lambdify([x], [cos(x), sin(x)])
    d = f(3.14159)
    assert abs(d[0] + 1) < 0.0001
    assert abs(d[1] - 0) < 0.0001


def test_docs():
    f = lambdify(x, x**2)
    assert f(2) == 4
    f = lambdify([x, y, z], [z, y, x])
    assert f(1, 2, 3) == [3, 2, 1]
    f = lambdify(x, sqrt(x))
    assert f(4) == 2.0
    f = lambdify((x, y), sin(x*y)**2)
    assert f(0, 5) == 0


def test_math():
    f = lambdify((x, y), sin(x), modules="math")
    assert f(0, 5) == 0


def test_sin():
    f = lambdify(x, sin(x)**2)
    assert isinstance(f(2), float)
    f = lambdify(x, sin(x)**2, modules="math")
    assert isinstance(f(2), float)


def test_matrix():
    A = Matrix([[x, x*y], [sin(z) + 4, x**z]])
    sol = Matrix([[1, 2], [sin(3) + 4, 1]])
    f = lambdify((x, y, z), A, modules="sympy")
    assert f(1, 2, 3) == sol
    f = lambdify((x, y, z), (A, [A]), modules="sympy")
    assert f(1, 2, 3) == (sol, [sol])
    J = Matrix((x, x + y)).jacobian((x, y))
    v = Matrix((x, y))
    sol = Matrix([[1, 0], [1, 1]])
    assert lambdify(v, J, modules='sympy')(1, 2) == sol
    assert lambdify(v.T, J, modules='sympy')(1, 2) == sol

def test_numpy_matrix():
    if not numpy:
        skip("numpy not installed.")
    A = Matrix([[x, x*y], [sin(z) + 4, x**z]])
    sol_arr = numpy.array([[1, 2], [numpy.sin(3) + 4, 1]])
    #Lambdify array first, to ensure return to array as default
    f = lambdify((x, y, z), A, ['numpy'])
    numpy.testing.assert_allclose(f(1, 2, 3), sol_arr)
    #Check that the types are arrays and matrices
    assert isinstance(f(1, 2, 3), numpy.ndarray)

def test_numpy_transpose():
    if not numpy:
        skip("numpy not installed.")
    A = Matrix([[1, x], [0, 1]])
    f = lambdify((x), A.T, modules="numpy")
    numpy.testing.assert_array_equal(f(2), numpy.array([[1, 0], [2, 1]]))

def test_numpy_dotproduct():
    if not numpy:
        skip("numpy not installed")
    A = Matrix([x, y, z])
    f1 = lambdify([x, y, z], DotProduct(A, A), modules='numpy')
    f2 = lambdify([x, y, z], DotProduct(A, A.T), modules='numpy')
    f3 = lambdify([x, y, z], DotProduct(A.T, A), modules='numpy')
    f4 = lambdify([x, y, z], DotProduct(A, A.T), modules='numpy')

    assert f1(1, 2, 3) == \
           f2(1, 2, 3) == \
           f3(1, 2, 3) == \
           f4(1, 2, 3) == \
           numpy.array([14])

def test_numpy_inverse():
    if not numpy:
        skip("numpy not installed.")
    A = Matrix([[1, x], [0, 1]])
    f = lambdify((x), A**-1, modules="numpy")
    numpy.testing.assert_array_equal(f(2), numpy.array([[1, -2], [0,  1]]))

def test_numpy_old_matrix():
    if not numpy:
        skip("numpy not installed.")
    A = Matrix([[x, x*y], [sin(z) + 4, x**z]])
    sol_arr = numpy.array([[1, 2], [numpy.sin(3) + 4, 1]])
    f = lambdify((x, y, z), A, [{'ImmutableDenseMatrix': numpy.matrix}, 'numpy'])
    numpy.testing.assert_allclose(f(1, 2, 3), sol_arr)
    assert isinstance(f(1, 2, 3), numpy.matrix)

def test_python_div_zero_issue_11306():
    if not numpy:
        skip("numpy not installed.")
    p = Piecewise((1 / x, y < -1), (x, y < 1), (1 / x, True))
    f = lambdify([x, y], p, modules='numpy')
    numpy.seterr(divide='ignore')
    assert float(f(numpy.array([0]),numpy.array([0.5]))) == 0
    assert str(float(f(numpy.array([0]),numpy.array([1])))) == 'inf'
    numpy.seterr(divide='warn')

def test_issue9474():
    mods = [None, 'math']
    if numpy:
        mods.append('numpy')
    if mpmath:
        mods.append('mpmath')
    for mod in mods:
        f = lambdify(x, sympy.S(1)/x, modules=mod)
        assert f(2) == 0.5
        f = lambdify(x, floor(sympy.S(1)/x), modules=mod)
        assert f(2) == 0

    for absfunc, modules in product([Abs, abs], mods):
        f = lambdify(x, absfunc(x), modules=modules)
        assert f(-1) == 1
        assert f(1) == 1
        assert f(3+4j) == 5


def test_issue_9871():
    if not numexpr:
        skip("numexpr not installed.")
    if not numpy:
        skip("numpy not installed.")

    r = sqrt(x**2 + y**2)
    expr = diff(1/r, x)

    xn = yn = numpy.linspace(1, 10, 16)
    # expr(xn, xn) = -xn/(sqrt(2)*xn)^3
    fv_exact = -numpy.sqrt(2.)**-3 * xn**-2

    fv_numpy = lambdify((x, y), expr, modules='numpy')(xn, yn)
    fv_numexpr = lambdify((x, y), expr, modules='numexpr')(xn, yn)
    numpy.testing.assert_allclose(fv_numpy, fv_exact, rtol=1e-10)
    numpy.testing.assert_allclose(fv_numexpr, fv_exact, rtol=1e-10)


def test_numpy_piecewise():
    if not numpy:
        skip("numpy not installed.")
    pieces = Piecewise((x, x < 3), (x**2, x > 5), (0, True))
    f = lambdify(x, pieces, modules="numpy")
    numpy.testing.assert_array_equal(f(numpy.arange(10)),
                                     numpy.array([0, 1, 2, 0, 0, 0, 36, 49, 64, 81]))
    # If we evaluate somewhere all conditions are False, we should get back NaN
    nodef_func = lambdify(x, Piecewise((x, x > 0), (-x, x < 0)))
    numpy.testing.assert_array_equal(nodef_func(numpy.array([-1, 0, 1])),
                                     numpy.array([1, numpy.nan, 1]))

def test_numpy_logical_ops():
    if not numpy:
        skip("numpy not installed.")
    and_func = lambdify((x, y), And(x, y), modules="numpy")
    and_func_3 = lambdify((x, y, z), And(x, y, z), modules="numpy")
    or_func = lambdify((x, y), Or(x, y), modules="numpy")
    or_func_3 = lambdify((x, y, z), Or(x, y, z), modules="numpy")
    not_func = lambdify((x), Not(x), modules="numpy")
    arr1 = numpy.array([True, True])
    arr2 = numpy.array([False, True])
    arr3 = numpy.array([True, False])
    numpy.testing.assert_array_equal(and_func(arr1, arr2), numpy.array([False, True]))
    numpy.testing.assert_array_equal(and_func_3(arr1, arr2, arr3), numpy.array([False, False]))
    numpy.testing.assert_array_equal(or_func(arr1, arr2), numpy.array([True, True]))
    numpy.testing.assert_array_equal(or_func_3(arr1, arr2, arr3), numpy.array([True, True]))
    numpy.testing.assert_array_equal(not_func(arr2), numpy.array([True, False]))

def test_numpy_matmul():
    if not numpy:
        skip("numpy not installed.")
    xmat = Matrix([[x, y], [z, 1+z]])
    ymat = Matrix([[x**2], [Abs(x)]])
    mat_func = lambdify((x, y, z), xmat*ymat, modules="numpy")
    numpy.testing.assert_array_equal(mat_func(0.5, 3, 4), numpy.array([[1.625], [3.5]]))
    numpy.testing.assert_array_equal(mat_func(-0.5, 3, 4), numpy.array([[1.375], [3.5]]))
    # Multiple matrices chained together in multiplication
    f = lambdify((x, y, z), xmat*xmat*xmat, modules="numpy")
    numpy.testing.assert_array_equal(f(0.5, 3, 4), numpy.array([[72.125, 119.25],
                                                                [159, 251]]))

def test_numpy_numexpr():
    if not numpy:
        skip("numpy not installed.")
    if not numexpr:
        skip("numexpr not installed.")
    a, b, c = numpy.random.randn(3, 128, 128)
    # ensure that numpy and numexpr return same value for complicated expression
    expr = sin(x) + cos(y) + tan(z)**2 + Abs(z-y)*acos(sin(y*z)) + \
           Abs(y-z)*acosh(2+exp(y-x))- sqrt(x**2+I*y**2)
    npfunc = lambdify((x, y, z), expr, modules='numpy')
    nefunc = lambdify((x, y, z), expr, modules='numexpr')
    assert numpy.allclose(npfunc(a, b, c), nefunc(a, b, c))

def test_numexpr_userfunctions():
    if not numpy:
        skip("numpy not installed.")
    if not numexpr:
        skip("numexpr not installed.")
    a, b = numpy.random.randn(2, 10)
    uf = type('uf', (Function, ),
              {'eval' : classmethod(lambda x, y : y**2+1)})
    func = lambdify(x, 1-uf(x), modules='numexpr')
    assert numpy.allclose(func(a), -(a**2))

    uf = implemented_function(Function('uf'), lambda x, y : 2*x*y+1)
    func = lambdify((x, y), uf(x, y), modules='numexpr')
    assert numpy.allclose(func(a, b), 2*a*b+1)

def test_tensorflow_basic_math():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Max(sin(x), Abs(1/(x+2)))
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.constant(0, dtype=tensorflow.float32)
    s = tensorflow.Session()
    assert func(a).eval(session=s) == 0.5

def test_tensorflow_placeholders():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Max(sin(x), Abs(1/(x+2)))
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.placeholder(dtype=tensorflow.float32)
    s = tensorflow.Session()
    assert func(a).eval(session=s, feed_dict={a: 0}) == 0.5

def test_tensorflow_variables():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Max(sin(x), Abs(1/(x+2)))
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.Variable(0, dtype=tensorflow.float32)
    s = tensorflow.Session()
    if V(tensorflow.__version__) < '1.0':
        s.run(tensorflow.initialize_all_variables())
    else:
        s.run(tensorflow.global_variables_initializer())
    assert func(a).eval(session=s) == 0.5

def test_tensorflow_logical_operations():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Not(And(Or(x, y), y))
    func = lambdify([x, y], expr, modules="tensorflow")
    a = tensorflow.constant(False)
    b = tensorflow.constant(True)
    s = tensorflow.Session()
    assert func(a, b).eval(session=s) == 0

def test_tensorflow_piecewise():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Piecewise((0, Eq(x,0)), (-1, x < 0), (1, x > 0))
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.placeholder(dtype=tensorflow.float32)
    s = tensorflow.Session()
    assert func(a).eval(session=s, feed_dict={a: -1}) == -1
    assert func(a).eval(session=s, feed_dict={a: 0}) == 0
    assert func(a).eval(session=s, feed_dict={a: 1}) == 1

def test_tensorflow_multi_max():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Max(x, -x, x**2)
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.placeholder(dtype=tensorflow.float32)
    s = tensorflow.Session()
    assert func(a).eval(session=s, feed_dict={a: -2}) == 4

def test_tensorflow_multi_min():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = Min(x, -x, x**2)
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.placeholder(dtype=tensorflow.float32)
    s = tensorflow.Session()
    assert func(a).eval(session=s, feed_dict={a: -2}) == -2

def test_tensorflow_relational():
    if not tensorflow:
        skip("tensorflow not installed.")
    expr = x >= 0
    func = lambdify(x, expr, modules="tensorflow")
    a = tensorflow.placeholder(dtype=tensorflow.float32)
    s = tensorflow.Session()
    assert func(a).eval(session=s, feed_dict={a: 1})

def test_integral():
    f = Lambda(x, exp(-x**2))
    l = lambdify(x, Integral(f(x), (x, -oo, oo)), modules="sympy")
    assert l(x) == Integral(exp(-x**2), (x, -oo, oo))

#================== Test symbolic ==================================


def test_sym_single_arg():
    f = lambdify(x, x * y)
    assert f(z) == z * y


def test_sym_list_args():
    f = lambdify([x, y], x + y + z)
    assert f(1, 2) == 3 + z


def test_sym_integral():
    f = Lambda(x, exp(-x**2))
    l = lambdify(x, Integral(f(x), (x, -oo, oo)), modules="sympy")
    assert l(y).doit() == sqrt(pi)


def test_namespace_order():
    # lambdify had a bug, such that module dictionaries or cached module
    # dictionaries would pull earlier namespaces into themselves.
    # Because the module dictionaries form the namespace of the
    # generated lambda, this meant that the behavior of a previously
    # generated lambda function could change as a result of later calls
    # to lambdify.
    n1 = {'f': lambda x: 'first f'}
    n2 = {'f': lambda x: 'second f',
          'g': lambda x: 'function g'}
    f = sympy.Function('f')
    g = sympy.Function('g')
    if1 = lambdify(x, f(x), modules=(n1, "sympy"))
    assert if1(1) == 'first f'
    if2 = lambdify(x, g(x), modules=(n2, "sympy"))
    # previously gave 'second f'
    assert if1(1) == 'first f'


def test_namespace_type():
    # lambdify had a bug where it would reject modules of type unicode
    # on Python 2.
    x = sympy.Symbol('x')
    lambdify(x, x, modules=u'math')


def test_imps():
    # Here we check if the default returned functions are anonymous - in
    # the sense that we can have more than one function with the same name
    f = implemented_function('f', lambda x: 2*x)
    g = implemented_function('f', lambda x: math.sqrt(x))
    l1 = lambdify(x, f(x))
    l2 = lambdify(x, g(x))
    assert str(f(x)) == str(g(x))
    assert l1(3) == 6
    assert l2(3) == math.sqrt(3)
    # check that we can pass in a Function as input
    func = sympy.Function('myfunc')
    assert not hasattr(func, '_imp_')
    my_f = implemented_function(func, lambda x: 2*x)
    assert hasattr(my_f, '_imp_')
    # Error for functions with same name and different implementation
    f2 = implemented_function("f", lambda x: x + 101)
    raises(ValueError, lambda: lambdify(x, f(f2(x))))


def test_imps_errors():
    # Test errors that implemented functions can return, and still be able to
    # form expressions.
    # See: https://github.com/sympy/sympy/issues/10810
    for val, error_class in product((0, 0., 2, 2.0),
                                    (AttributeError, TypeError, ValueError)):

        def myfunc(a):
            if a == 0:
                raise error_class
            return 1

        f = implemented_function('f', myfunc)
        expr = f(val)
        assert expr == f(val)


def test_imps_wrong_args():
    raises(ValueError, lambda: implemented_function(sin, lambda x: x))


def test_lambdify_imps():
    # Test lambdify with implemented functions
    # first test basic (sympy) lambdify
    f = sympy.cos
    assert lambdify(x, f(x))(0) == 1
    assert lambdify(x, 1 + f(x))(0) == 2
    assert lambdify((x, y), y + f(x))(0, 1) == 2
    # make an implemented function and test
    f = implemented_function("f", lambda x: x + 100)
    assert lambdify(x, f(x))(0) == 100
    assert lambdify(x, 1 + f(x))(0) == 101
    assert lambdify((x, y), y + f(x))(0, 1) == 101
    # Can also handle tuples, lists, dicts as expressions
    lam = lambdify(x, (f(x), x))
    assert lam(3) == (103, 3)
    lam = lambdify(x, [f(x), x])
    assert lam(3) == [103, 3]
    lam = lambdify(x, [f(x), (f(x), x)])
    assert lam(3) == [103, (103, 3)]
    lam = lambdify(x, {f(x): x})
    assert lam(3) == {103: 3}
    lam = lambdify(x, {f(x): x})
    assert lam(3) == {103: 3}
    lam = lambdify(x, {x: f(x)})
    assert lam(3) == {3: 103}
    # Check that imp preferred to other namespaces by default
    d = {'f': lambda x: x + 99}
    lam = lambdify(x, f(x), d)
    assert lam(3) == 103
    # Unless flag passed
    lam = lambdify(x, f(x), d, use_imps=False)
    assert lam(3) == 102

def test_dummification():
    t = symbols('t')
    F = Function('F')
    G = Function('G')
    #"\alpha" is not a valid python variable name
    #lambdify should sub in a dummy for it, and return
    #without a syntax error
    alpha = symbols(r'\alpha')
    some_expr = 2 * F(t)**2 / G(t)
    lam = lambdify((F(t), G(t)), some_expr)
    assert lam(3, 9) == 2
    lam = lambdify(sin(t), 2 * sin(t)**2)
    assert lam(F(t)) == 2 * F(t)**2
    #Test that \alpha was properly dummified
    lam = lambdify((alpha, t), 2*alpha + t)
    assert lam(2, 1) == 5
    raises(SyntaxError, lambda: lambdify(F(t) * G(t), F(t) * G(t) + 5))
    raises(SyntaxError, lambda: lambdify(2 * F(t), 2 * F(t) + 5))
    raises(SyntaxError, lambda: lambdify(2 * F(t), 4 * F(t) + 5))

def test_python_keywords():
    # Test for issue 7452. The automatic dummification should ensure use of
    # Python reserved keywords as symbol names will create valid lambda
    # functions. This is an additional regression test.
    python_if = symbols('if')
    expr = python_if / 2
    f = lambdify(python_if, expr)
    assert f(4.0) == 2.0


def test_lambdify_docstring():
    func = lambdify((w, x, y, z), w + x + y + z)
    ref = (
        "Created with lambdify. Signature:\n\n"
        "func(w, x, y, z)\n\n"
        "Expression:\n\n"
        "w + x + y + z"
    ).splitlines()
    assert func.__doc__.splitlines()[:len(ref)] == ref
    syms = symbols('a1:26')
    func = lambdify(syms, sum(syms))
    ref = (
        "Created with lambdify. Signature:\n\n"
        "func(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,\n"
        "        a16, a17, a18, a19, a20, a21, a22, a23, a24, a25)\n\n"
        "Expression:\n\n"
        "a1 + a10 + a11 + a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a2 + a20 +..."
    ).splitlines()
    assert func.__doc__.splitlines()[:len(ref)] == ref


#================== Test special printers ==========================


def test_special_printers():
    class IntervalPrinter(LambdaPrinter):
        """Use ``lambda`` printer but print numbers as ``mpi`` intervals. """

        def _print_Integer(self, expr):
            return "mpi('%s')" % super(IntervalPrinter, self)._print_Integer(expr)

        def _print_Rational(self, expr):
            return "mpi('%s')" % super(IntervalPrinter, self)._print_Rational(expr)

    def intervalrepr(expr):
        return IntervalPrinter().doprint(expr)

    expr = sympy.sqrt(sympy.sqrt(2) + sympy.sqrt(3)) + sympy.S(1)/2

    func0 = lambdify((), expr, modules="mpmath", printer=intervalrepr)
    func1 = lambdify((), expr, modules="mpmath", printer=IntervalPrinter)
    func2 = lambdify((), expr, modules="mpmath", printer=IntervalPrinter())

    mpi = type(mpmath.mpi(1, 2))

    assert isinstance(func0(), mpi)
    assert isinstance(func1(), mpi)
    assert isinstance(func2(), mpi)

def test_true_false():
    # We want exact is comparison here, not just ==
    assert lambdify([], true)() is True
    assert lambdify([], false)() is False

def test_issue_2790():
    assert lambdify((x, (y, z)), x + y)(1, (2, 4)) == 3
    assert lambdify((x, (y, (w, z))), w + x + y + z)(1, (2, (3, 4))) == 10
    assert lambdify(x, x + 1, dummify=False)(1) == 2

def test_issue_12092():
    f = implemented_function('f', lambda x: x**2)
    assert f(f(2)).evalf() == Float(16)

def test_ITE():
    assert lambdify((x, y, z), ITE(x, y, z))(True, 5, 3) == 5
    assert lambdify((x, y, z), ITE(x, y, z))(False, 5, 3) == 3


def test_Min_Max():
    # see gh-10375
    assert lambdify((x, y, z), Min(x, y, z))(1, 2, 3) == 1
    assert lambdify((x, y, z), Max(x, y, z))(1, 2, 3) == 3

def test_Indexed():
    # Issue #10934
    if not numpy:
        skip("numpy not installed")

    a = IndexedBase('a')
    i, j = symbols('i j')
    b = numpy.array([[1, 2], [3, 4]])
    assert lambdify(a, Sum(a[x, y], (x, 0, 1), (y, 0, 1)))(b) == 10

def test_issue_12173():
    #test for issue 12173
    exp1 = lambdify((x, y), uppergamma(x, y),"mpmath")(1, 2)
    exp2 = lambdify((x, y), lowergamma(x, y),"mpmath")(1, 2)
    assert exp1 == uppergamma(1, 2).evalf()
    assert exp2 == lowergamma(1, 2).evalf()

def test_issue_13642():
    if not numpy:
        skip("numpy not installed")
    f = lambdify(x, sinc(x))
    assert Abs(f(1) - sinc(1)).n() < 1e-15

def test_sinc_mpmath():
    f = lambdify(x, sinc(x), "mpmath")
    assert Abs(f(1) - sinc(1)).n() < 1e-15

def test_lambdify_dummy_arg():
    d1 = Dummy()
    f1 = lambdify(d1, d1 + 1, dummify=False)
    assert f1(2) == 3
    f1b = lambdify(d1, d1 + 1)
    assert f1b(2) == 3
    d2 = Dummy('x')
    f2 = lambdify(d2, d2 + 1)
    assert f2(2) == 3
    f3 = lambdify([[d2]], d2 + 1)
    assert f3([2]) == 3

def test_lambdify_mixed_symbol_dummy_args():
    d = Dummy()
    # Contrived example of name clash
    dsym = symbols(str(d))
    f = lambdify([d, dsym], d - dsym)
    assert f(4, 1) == 3

def test_numpy_array_arg():
    # Test for issue 14655 (numpy part)
    if not numpy:
        skip("numpy not installed")

    f = lambdify([[x, y]], x*x + y, 'numpy')

    assert f(numpy.array([2.0, 1.0])) == 5

def test_tensorflow_array_arg():
    # Test for issue 14655 (tensorflow part)
    if not tensorflow:
        skip("tensorflow not installed.")

    f = lambdify([[x, y]], x*x + y, 'tensorflow')

    fcall = f(tensorflow.constant([2.0, 1.0]))

    s = tensorflow.Session()
    assert s.run(fcall) == 5

def test_lambdify_inspect():
    f = lambdify(x, x**2)
    # Test that inspect.getsource works but don't hard-code implementation
    # details
    assert 'x**2' in inspect.getsource(f)

def test_issue_14941():
    x, y = Dummy(), Dummy()

    # test dict
    f1 = lambdify([x, y], {x: 3, y: 3}, 'sympy')
    assert f1(2, 3) == {2: 3, 3: 3}

    # test tuple
    f2 = lambdify([x, y], (y, x), 'sympy')
    assert f2(2, 3) == (3, 2)

    # test list
    f3 = lambdify([x, y], [y, x], 'sympy')
    assert f3(2, 3) == [3, 2]

```


# The last commit

```
a2eb1df2c SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py
changed: sympy/printing/pycode.py +7 -0
changed: sympy/printing/tests/test_pycode.py +2 -1
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sympy/printing/pycode.py b/sympy/printing/pycode.py
index d06901425..201917928 100644
--- a/sympy/printing/pycode.py
+++ b/sympy/printing/pycode.py
@@ -331,6 +331,13 @@ def _print_Float(self, e):
         args = str(tuple(map(int, e._mpf_)))
         return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)
 
+    def _print_Rational(self, e):
+        # Convert the numerator and denominator to mpf so that the division is
+        # carried out at mpmath's working precision instead of using Python's
+        # integer division (which would truncate the result to an integer).
+        return '{0}({1})/{0}({2})'.format(
+            self._module_format('mpmath.mpf'), e.p, e.q)
+
 
     def _print_uppergamma(self, e):
         return "{0}({1}, {2}, {3})".format(
diff --git a/sympy/printing/tests/test_pycode.py b/sympy/printing/tests/test_pycode.py
index 68994056e..b7ad8ceae 100644
--- a/sympy/printing/tests/test_pycode.py
+++ b/sympy/printing/tests/test_pycode.py
@@ -2,7 +2,7 @@
 from __future__ import (absolute_import, division, print_function)
 
 from sympy.codegen import Assignment
-from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo
+from sympy.core import Expr, Mod, S, symbols, Eq, Le, Gt, zoo, oo
 from sympy.core.numbers import pi
 from sympy.codegen.ast import none
 from sympy.external import import_module
@@ -40,6 +40,7 @@ def test_PythonCodePrinter():
 def test_MpmathPrinter():
     p = MpmathPrinter()
     assert p.doprint(sign(x)) == 'mpmath.sign(x)'
+    assert p.doprint(S(1)/3) == 'mpmath.mpf(1)/mpmath.mpf(3)'
 
 
 def test_NumPyPrinter():
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
check: python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py
changed: sympy/printing/pycode.py +7 -0
changed: sympy/printing/tests/test_pycode.py +2 -1
```

### `final-status.txt`

```
none
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
# Notes, run 2026-11-06T133913

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

lambdify(modules='mpmath') doesn't wrap rationals
```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> f = lambdify(x, eqn.lhs - eqn.rhs, 'mpmath')
>>> print(inspect.getsource(f))
def _lambdifygenerated(x):
    return (  # Not supported in Python:
  # RisingFactorial
RisingFactorial(18, x) - 232/3)
```

This results in reduced precision results from `nsolve`, because the 232/3 isn't evaluated at full precision. 

```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> x0 = nsolve(eqn, Float('1.5', 64), prec=64)
>>> rf(18, x0).evalf(64)
77.33333333333332859638176159933209419250488281250000000000000000
```

Originally reported at https://github.com/sympy/sympy/pull/14971


# The files of the project

```
.ci/blacklisted.json
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
CONTRIBUTING.md
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
bin/test_external_imports.py
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
examples/notebooks/Bezout_Dixon_resultant.ipynb
examples/notebooks/IntegrationOverPolytopes.ipynb
examples/notebooks/Macaulay_resultant.ipynb
examples/notebooks/README.txt
examples/notebooks/Sylvester_resultant.ipynb
examples/notebooks/density.ipynb
examples/notebooks/fidelity.ipynb
examples/notebooks/fresnel_integrals.ipynb
examples/notebooks/qubits.ipynb
examples/notebooks/sho1d_example.ipynb
examples/notebooks/spin.ipynb
examples/notebooks/trace.ipynb
github_deploy_key.enc
isympy.py
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
sympy/codegen/algorithms.py
sympy/codegen/approximations.py
sympy/codegen/ast.py
sympy/codegen/cfunctions.py
sympy/codegen/cnodes.py
sympy/codegen/cutils.py
sympy/codegen/cxxnodes.py
sympy/codegen/fnodes.py
sympy/codegen/futils.py
sympy/codegen/pyutils.py
sympy/codegen/rewriting.py
sympy/codegen/tests/test_algorithms.py
sympy/codegen/tests/test_applications.py
sympy/codegen/tests/test_approximations.py
sympy/codegen/tests/test_ast.py
sympy/codegen/tests/test_cfunctions.py
sympy/codegen/tests/test_cnodes.py
sympy/codegen/tests/test_cxxnodes.py
sympy/codegen/tests/test_fnodes.py
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
sympy/combinatorics/rewritingsystem_fsm.py
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
sympy/core/tests/test_power.py
sympy/core/tests/test_priority.py
sympy/core/tests/test_relational.py
sympy/core/tests/test_rules.py
sympy/core/tests/test_singleton.py
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
sympy/discrete/__init__.py
sympy/discrete/convolution.py
sympy/discrete/recurrence.py
sympy/discrete/tests/__init__.py
sympy/discrete/tests/test_convolution.py
sympy/discrete/tests/test_recurrence.py
sympy/discrete/tests/test_transforms.py
```


# The last commit

```
a2eb1df2c SWE-bench


```

```diff

```


# CONTRIBUTING.md (the start)

```
## Contributing

We welcome contributions from anyone, even if you are new to open
source. Please read our [introduction to contributing](
https://github.com/sympy/sympy/wiki/Introduction-to-contributing). If you are new and
looking for some way to contribute a good place to start is to look at the
issues tagged [Easy to Fix](
https://github.com/sympy/sympy/issues?q=is%3Aopen+is%3Aissue+label%3A%22Easy+to+Fix%22).

Please note that all participants of this project are expected to follow our
Code of Conduct. By participating in this project you agree to abide by its
terms. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q`

## Scope
`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`
`sympy/utilities/tests/test_lambdify.py`

## Done when
The mpmath lambdified output for a `Rational` wraps the numerator in `mpmath.mpf` instead of emitting bare integer division such as `232/3`.
`lambdify(x, rf(18, x) - (77 + S(1)/3), 'mpmath')` evaluates the rational constant at the active mpmath precision.
The reported `nsolve(..., prec=64)` case no longer loses precision through an un-wrapped rational constant.

## Approach
Add a `_print_Rational` override in `MpmathPrinter` in `sympy/printing/pycode.py`, returning an expression built from `mpmath.mpf` for the numerator and the denominator, then cover it with printer and/or lambdify regression tests.

Candidate approaches:
- Override only `MpmathPrinter._print_Rational` with `mpmath.mpf(p)/q`: smallest, targeted, keeps the Python printer unchanged.
- Handle rationals in `lambdify.py` before code generation: broader and risks affecting non-mpmath modules.
- Change `PythonCodePrinter._print_Rational` globally with a module/settings check: more invasive and could regress existing Python/numpy output.
```

### `prompt.md`

````
lambdify(modules='mpmath') doesn't wrap rationals
```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> f = lambdify(x, eqn.lhs - eqn.rhs, 'mpmath')
>>> print(inspect.getsource(f))
def _lambdifygenerated(x):
    return (  # Not supported in Python:
  # RisingFactorial
RisingFactorial(18, x) - 232/3)
```

This results in reduced precision results from `nsolve`, because the 232/3 isn't evaluated at full precision. 

```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> x0 = nsolve(eqn, Float('1.5', 64), prec=64)
>>> rf(18, x0).evalf(64)
77.33333333333332859638176159933209419250488281250000000000000000
```

Originally reported at https://github.com/sympy/sympy/pull/14971
````

### `review.md`

```
verdict: PASS
- `MpmathPrinter._print_Rational` now emits `mpmath.mpf(p)/mpmath.mpf(q)`, so rational constants are evaluated with mpmath precision instead of bare Python division.
- This addresses the reported `nsolve(..., prec=64)` precision loss for rational constants such as `232/3`.
- The added `test_MpmathPrinter` assertion covers the new rational printing behavior.
- Only in-scope files were changed; the check could not run because `pytest` is missing from the environment, so the change was judged directly against the task.
```

### `scope.txt`

```
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py
changed: sympy/printing/pycode.py +7 -0
changed: sympy/printing/tests/test_pycode.py +2 -1
```

### `task.md`

````
# Task

## Prompt

lambdify(modules='mpmath') doesn't wrap rationals
```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> f = lambdify(x, eqn.lhs - eqn.rhs, 'mpmath')
>>> print(inspect.getsource(f))
def _lambdifygenerated(x):
    return (  # Not supported in Python:
  # RisingFactorial
RisingFactorial(18, x) - 232/3)
```

This results in reduced precision results from `nsolve`, because the 232/3 isn't evaluated at full precision. 

```py
>>> eqn = Eq(rf(18,x), 77 + S(1)/3)
>>> x0 = nsolve(eqn, Float('1.5', 64), prec=64)
>>> rf(18, x0).evalf(64)
77.33333333333332859638176159933209419250488281250000000000000000
```

Originally reported at https://github.com/sympy/sympy/pull/14971

## Deliverable

changes to this tree

## Check

`python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q`

## Scope

`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`
`sympy/utilities/tests/test_lambdify.py`

## Done when

The mpmath lambdified output for a `Rational` wraps the numerator in `mpmath.mpf` instead of emitting bare integer division such as `232/3`.
`lambdify(x, rf(18, x) - (77 + S(1)/3), 'mpmath')` evaluates the rational constant at the active mpmath precision.
The reported `nsolve(..., prec=64)` case no longer loses precision through an un-wrapped rational constant.
````

### `test-output.log`

```
check: python -m pytest sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py -q
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py sympy/utilities/tests/test_lambdify.py
changed: sympy/printing/pycode.py +7 -0
changed: sympy/printing/tests/test_pycode.py +2 -1
```

### `test-status.txt`

```
none
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

### `verdict.md`

```
verdict: PASS
- `MpmathPrinter._print_Rational` replaces bare `232/3` with `mpmath.mpf(232)/mpmath.mpf(3)`, satisfying the wrapping requirement.
- It uses the same `_module_format('mpmath.mpf')` mechanism as `_print_Float`, so it is consistent with existing mpmath-printer output.
- The generated division is evaluated when the lambdified function is called, so it follows the active mpmath precision used by `nsolve`.
- The added `test_MpmathPrinter` assertion directly checks the rational printing change.
- No unrelated code or tests are removed; the change stays within the stated scope.
```
