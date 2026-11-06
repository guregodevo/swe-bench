# sympy__sympy-22914 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 56s 39 lines cost=0.003113 in=168975 cached=144896 out=5008 calls=16`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

PythonCodePrinter doesn't support Min and Max
We can't generate python code for the sympy function Min and Max.

For example:
```
from sympy import symbols, Min, pycode
a, b = symbols("a b")
c = Min(a,b)
print(pycode(c))
```
the output is:

```
  # Not supported in Python:
  # Min
Min(a, b)
```

Similar to issue #16669, we should add following methods to PythonCodePrinter:

```
def _print_Min(self, expr):
    return "min({})".format(", ".join(self._print(arg) for arg in expr.args))


def _print_Max(self, expr):
    return "max({})".format(", ".join(self._print(arg) for arg in expr.args))

```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --short | head"
}
```

**assistant → tool `locate`**

```json
{
  "query": "PythonCodePrinter _print_Min _print_Max sympy printing"
}
```

**tool result**

```
AUTHORS
CODEOWNERS
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE
MANIFEST.in
PULL_REQUEST_TEMPLATE.md
README.md
asv.conf.actions.json
asv.conf.travis.json
banner.svg
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
```

**tool result**

```
Where "PythonCodePrinter _print_Min _print_Max sympy printing" lives (judged: 17 of 40 sections kept), most relevant first:
1. sympy/printing/numpy.py:207-240  p=0.96
2. sympy/printing/octave.py:486-493  p=0.95
3. sympy/printing/c.py:685-714  p=0.95
4. sympy/printing/latex.py:1013-1050  p=0.94
5. sympy/printing/mathml.py:1490-1522  p=0.94
6. sympy/printing/fortran.py:26-65  p=0.88
7. sympy/printing/pycode.py:474-478  p=0.78
8. sympy/printing/tensorflow.py:1-23  p=0.75

== sympy/printing/numpy.py:207-240 (p=0.96)
  207      def _print_Pow(self, expr, rational=False):
  208          # XXX Workaround for negative integer power error
  209          from sympy.core.power import Pow
  210          if expr.exp.is_integer and expr.exp.is_negative:
  211              expr = Pow(expr.base, expr.exp.evalf(), evaluate=False)
  212          return self._hprint_Pow(expr, rational=rational, sqrt=self._module + '.sqrt')
  213  
  214      def _print_Min(self, expr):
  215          return '{}(({}), axis=0)'.format(self._module_format(self._module + '.amin'), ','.join(self._print(i) for i in expr.args))
  216  
  217      def _print_Max(self, expr):
  218          return '{}(({}), axis=0)'.format(self._module_format(self._module + '.amax'), ','.join(self._print(i) for i in expr.args))
  219  
  220      def _print_arg(self, expr):
  221          return "%s(%s)" % (self._module_format(self._module + '.angle'), self._print(expr.args[0]))
  222  
  223      def _print_im(self, expr):
  224          return "%s(%s)" % (self._module_format(self._module + '.imag'), self._print(expr.args[0]))
  225  
  226      def _print_Mod(self, expr):
  227          return "%s(%s)" % (self._module_format(self._module + '.mod'), ', '.join(
  228              map(lambda arg: self._print(arg), expr.args)))
  229  
  230      def _print_re(self, expr):
  231          return "%s(%s)" % (self._module_format(self._module + '.real'), self._print(expr.args[0]))
  232  
  233      def _print_sinc(self, expr):
  234          return "%s(%s)" % (self._module_format(self._module + '.sinc'), self._print(expr.args[0]/S.Pi))
  235  
  236      def _print_MatrixBase(self, expr):
  237          func = self.known_functions.get(expr.__class__.__name__, None)
  238          if func is None:
  239              func = self._module_format(self._module + '.array')
  240          return "%s(%s)" % (func, self._print(expr.tolist()))

== sympy/printing/octave.py:486-493 (p=0.95)
  486      def _nested_binary_math_func(self, expr):
  487          return '{name}({arg1}, {arg2})'.format(
  488              name=self.known_functions[expr.__class__.__name__],
  489              arg1=self._print(expr.args[0]),
  490              arg2=self._print(expr.func(*expr.args[1:]))
  491              )
  492  
  493      _print_Max = _print_Min = _nested_binary_math_func

== sympy/printing/c.py:685-714 (p=0.95)
  685          if nest:
  686              args = self._print(expr.args[0])
  687              if len(expr.args) > 1:
  688                  paren_pile = ''
  689                  for curr_arg in expr.args[1:-1]:
  690                      paren_pile += ')'
  691                      args += ', {ns}{name}{suffix}({next}'.format(
  692                          ns=self._ns,
  693                          name=known,
  694                          suffix=suffix,
  695                          next = self._print(curr_arg)
  696                      )
  697                  args += ', %s%s' % (
  698                      self._print(expr.func(expr.args[-1])),
  699                      paren_pile
  700                  )
  701          else:
  702              args = ', '.join(map(lambda arg: self._print(arg), expr.args))
  703          return '{ns}{name}{suffix}({args})'.format(
  704              ns=self._ns,
  705              name=known,
  706              suffix=suffix,
  707              args=args
  708          )
  709  
  710      def _print_Max(self, expr):
  711          return self._print_math_func(expr, nest=True)
  712  
  713      def _print_Min(self, expr):
  714          return self._print_math_func(expr, nest=True)

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `read_file`**

```json
{
  "path": "sympy/printing/pycode.py",
  "offset": 1,
  "limit": 120
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Min\\|Max\\|_print_\" sympy/printing/pycode.py | head -80"
}
```

**tool result**

```
"""
Python code printers

This module contains Python code printers for plain Python as well as NumPy & SciPy enabled code.
"""
from collections import defaultdict
from itertools import chain
from sympy.core import S
from .precedence import precedence
from .codeprinter import CodePrinter

_kw = {
    'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif',
    'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in',
    'is', 'lambda', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while',
    'with', 'yield', 'None', 'False', 'nonlocal', 'True'
}

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
    'ln': 'log',
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
    'E': 'e',
    'Infinity': 'inf',
    'NaN': 'nan',
    'ComplexInfinity': 'nan'
}

def _print_known_func(self, expr):
    known = self.known_functions[expr.__class__.__name__]
    return '{name}({args})'.format(name=self._module_format(known),
                                   args=', '.join(map(lambda arg: self._print(arg), expr.args)))


def _print_known_const(self, expr):
    known = self.known_constants[expr.__class__.__name__]
    return self._module_format(known)


class AbstractPythonCodePrinter(CodePrinter):
    printmethod = "_pythoncode"
    language = "Python"
    reserved_words = _kw
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
        contract=False,
        standard='python3',
    )

    def __init__(self, settings=None):
        super().__init__(settings)

        # Python standard handler
        std = self._settings['standard']
        if std is None:
            import sys
            std = 'python{}'.format(sys.version_info.major)
        if std != 'python3':
            raise ValueError('Only Python 3 is supported.')
        self.standard = std

        self.module_imports = defaultdict(set)

        # Known functions and constants handler
        self.known_functions = dict(self._kf, **(settings or {}).get(
            'user_functions', {}))
        self.known_constants = dict(self._kc, **(settings or {}).get(
            'user_constants', {}))

    def _declare_number_const(self, name, value):
        return "%s = %s" % (name, value)

    def _module_format(self, fqn, register=True):
        parts = fqn.split('.')

[520 more lines in /testbed/sympy/printing/pycode.py (640 in all). read_file with offset: 121 to continue]
```

**tool result**

```
63:def _print_known_func(self, expr):
69:def _print_known_const(self, expr):
221:    def _print_NaN(self, expr):
224:    def _print_Infinity(self, expr):
227:    def _print_NegativeInfinity(self, expr):
230:    def _print_ComplexInfinity(self, expr):
231:        return self._print_NaN(expr)
233:    def _print_Mod(self, expr):
237:    def _print_Piecewise(self, expr):
260:    def _print_Relational(self, expr):
274:        return super()._print_Relational(expr)
276:    def _print_ITE(self, expr):
280:    def _print_Sum(self, expr):
291:    def _print_ImaginaryUnit(self, expr):
294:    def _print_KroneckerDelta(self, expr):
302:    def _print_MatrixBase(self, expr):
307:    _print_SparseRepMatrix = \
308:        _print_MutableSparseMatrix = \
309:        _print_ImmutableSparseMatrix = \
310:        _print_Matrix = \
311:        _print_DenseMatrix = \
312:        _print_MutableDenseMatrix = \
313:        _print_ImmutableMatrix = \
314:        _print_ImmutableDenseMatrix = \
315:        lambda self, expr: self._print_MatrixBase(expr)
320:    def _print_FunctionDefinition(self, fd):
328:    def _print_While(self, whl):
335:    def _print_Declaration(self, decl):
341:    def _print_Return(self, ret):
345:    def _print_Print(self, prnt):
355:    def _print_Stream(self, strm):
363:    def _print_NoneToken(self, arg):
403:        sympy.printing.str.StrPrinter._print_Pow
427:    def _print_sign(self, e):
431:    def _print_Not(self, expr):
435:    def _print_Indexed(self, expr):
440:    def _print_Pow(self, expr, rational=False):
443:    def _print_Rational(self, expr):
446:    def _print_Half(self, expr):
447:        return self._print_Rational(expr)
449:    def _print_frac(self, expr):
451:        return self._print_Mod(Mod(expr.args[0], 1))
453:    def _print_Symbol(self, expr):
455:        name = super()._print_Symbol(expr)
468:    _print_lowergamma = CodePrinter._print_not_supported
469:    _print_uppergamma = CodePrinter._print_not_supported
470:    _print_fresnelc = CodePrinter._print_not_supported
471:    _print_fresnels = CodePrinter._print_not_supported
475:    setattr(PythonCodePrinter, '_print_%s' % k, _print_known_func)
478:    setattr(PythonCodePrinter, '_print_%s' % k, _print_known_const)
537:    """ helper function for _print_Integral that
569:    def _print_Float(self, e):
579:    def _print_Rational(self, e):
586:    def _print_Half(self, e):
587:        return self._print_Rational(e)
589:    def _print_uppergamma(self, e):
596:    def _print_lowergamma(self, e):
602:    def _print_log2(self, e):
606:    def _print_log1p(self, e):
610:    def _print_Pow(self, expr, rational=False):
613:    def _print_Integral(self, e):
624:    setattr(MpmathPrinter, '_print_%s' % k, _print_known_func)
627:    setattr(MpmathPrinter, '_print_%s' % k, _print_known_const)
634:    def _print_Function(self, expr):
639:    def _print_Pow(self, expr, rational=False):
```

**assistant → tool `read_file`**

```json
{
  "path": "sympy/printing/pycode.py",
  "offset": 200,
  "limit": 120
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Min\\|Max\" sympy/printing/tests/test_pycode.py | head -20; grep -n \"class PythonCodePrinter\\|class ArrayPrinter\\|class NumPyPrinter\\|class SciPyPrinter\" sympy/printing/pycode.py"
}
```

**tool result**

```
            indices.append(lindices)
        mapping = {}
        letters_free = []
        letters_dum = []
        for i in indices:
            for j in i:
                if j not in mapping:
                    l = next(letters)
                    mapping[j] = l
                else:
                    l = mapping[j]
                contraction_string += l
                if j in d:
                    if l not in letters_dum:
                        letters_dum.append(l)
                else:
                    letters_free.append(l)
            contraction_string += ","
        contraction_string = contraction_string[:-1]
        return contraction_string, letters_free, letters_dum

    def _print_NaN(self, expr):
        return "float('nan')"

    def _print_Infinity(self, expr):
        return "float('inf')"

    def _print_NegativeInfinity(self, expr):
        return "float('-inf')"

    def _print_ComplexInfinity(self, expr):
        return self._print_NaN(expr)

    def _print_Mod(self, expr):
        PREC = precedence(expr)
        return ('{} % {}'.format(*map(lambda x: self.parenthesize(x, PREC), expr.args)))

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
        return super()._print_Relational(expr)

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

    def _print_KroneckerDelta(self, expr):
        a, b = expr.args

        return '(1 if {a} == {b} else 0)'.format(
            a = self._print(a),
            b = self._print(b)
        )

    def _print_MatrixBase(self, expr):
        name = expr.__class__.__name__
        func = self.known_functions.get(name, name)
        return "%s(%s)" % (func, self._print(expr.tolist()))

    _print_SparseRepMatrix = \
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


[321 more lines in /testbed/sympy/printing/pycode.py (640 in all). read_file with offset: 320 to continue]
```

**tool result**

```
140:    from sympy.functions.elementary.miscellaneous import (Max, Min)
143:    expr1 = Min(0.1*x + 3, x + 1, 0.5*x + 1)
148:    expr1 = Max(x**2, x**3)
425:class PythonCodePrinter(AbstractPythonCodePrinter):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '120,165p' sympy/printing/tests/test_pycode.py; sed -n '420,490p' sympy/printing/pycode.py"
}
```

**tool result**

```
    # Workaround for numpy negative integer power errors
    assert p.doprint(x**-1) == 'x**(-1.0)'
    assert p.doprint(x**-2) == 'x**(-2.0)'

    expr = Pow(2, -1, evaluate=False)
    assert p.doprint(expr) == "2**(-1.0)"

    assert p.doprint(S.Exp1) == 'numpy.e'
    assert p.doprint(S.Pi) == 'numpy.pi'
    assert p.doprint(S.EulerGamma) == 'numpy.euler_gamma'
    assert p.doprint(S.NaN) == 'numpy.nan'
    assert p.doprint(S.Infinity) == 'numpy.PINF'
    assert p.doprint(S.NegativeInfinity) == 'numpy.NINF'


def test_issue_18770():
    numpy = import_module('numpy')
    if not numpy:
        skip("numpy not installed.")

    from sympy.functions.elementary.miscellaneous import (Max, Min)
    from sympy.utilities.lambdify import lambdify

    expr1 = Min(0.1*x + 3, x + 1, 0.5*x + 1)
    func = lambdify(x, expr1, "numpy")
    assert (func(numpy.linspace(0, 3, 3)) == [1.0, 1.75, 2.5 ]).all()
    assert  func(4) == 3

    expr1 = Max(x**2, x**3)
    func = lambdify(x,expr1, "numpy")
    assert (func(numpy.linspace(-1, 2, 4)) == [1, 0, 1, 8] ).all()
    assert func(4) == 64


def test_SciPyPrinter():
    p = SciPyPrinter()
    expr = acos(x)
    assert 'numpy' not in p.module_imports
    assert p.doprint(expr) == 'numpy.arccos(x)'
    assert 'numpy' in p.module_imports
    assert not any(m.startswith('scipy') for m in p.module_imports)
    smat = SparseMatrix(2, 5, {(0, 1): 3})
    assert p.doprint(smat) == \
        'scipy.sparse.coo_matrix(([3], ([0], [1])), shape=(2, 5))'
    assert 'scipy.sparse' in p.module_imports

        base_str = self.parenthesize(expr.base, PREC, strict=False)
        exp_str = self.parenthesize(expr.exp, PREC, strict=False)
        return "{}**{}".format(base_str, exp_str)


class PythonCodePrinter(AbstractPythonCodePrinter):

    def _print_sign(self, e):
        return '(0.0 if {e} == 0 else {f}(1, {e}))'.format(
            f=self._module_format('math.copysign'), e=self._print(e.args[0]))

    def _print_Not(self, expr):
        PREC = precedence(expr)
        return self._operators['not'] + self.parenthesize(expr.args[0], PREC)

    def _print_Indexed(self, expr):
        base = expr.args[0]
        index = expr.args[1:]
        return "{}[{}]".format(str(base), ", ".join([self._print(ind) for ind in index]))

    def _print_Pow(self, expr, rational=False):
        return self._hprint_Pow(expr, rational=rational)

    def _print_Rational(self, expr):
        return '{}/{}'.format(expr.p, expr.q)

    def _print_Half(self, expr):
        return self._print_Rational(expr)

    def _print_frac(self, expr):
        from sympy.core.mod import Mod
        return self._print_Mod(Mod(expr.args[0], 1))

    def _print_Symbol(self, expr):

        name = super()._print_Symbol(expr)

        if name in self.reserved_words:
            if self._settings['error_on_reserved']:
                msg = ('This expression includes the symbol "{}" which is a '
                       'reserved keyword in this language.')
                raise ValueError(msg.format(name))
            return name + self._settings['reserved_word_suffix']
        elif '{' in name:   # Remove curly braces from subscripted variables
            return name.replace('{', '').replace('}', '')
        else:
            return name

    _print_lowergamma = CodePrinter._print_not_supported
    _print_uppergamma = CodePrinter._print_not_supported
    _print_fresnelc = CodePrinter._print_not_supported
    _print_fresnels = CodePrinter._print_not_supported


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
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^class \" sympy/printing/pycode.py sympy/printing/numpy.py | head -30; grep -n \"Min\\|Max\" sympy/printing/numpy.py"
}
```

**tool result**

```
sympy/printing/pycode.py:74:class AbstractPythonCodePrinter(CodePrinter):
sympy/printing/pycode.py:425:class PythonCodePrinter(AbstractPythonCodePrinter):
sympy/printing/pycode.py:555:class MpmathPrinter(PythonCodePrinter):
sympy/printing/pycode.py:630:class SymPyPrinter(AbstractPythonCodePrinter):
sympy/printing/numpy.py:33:class NumPyPrinter(PythonCodePrinter):
sympy/printing/numpy.py:363:class SciPyPrinter(NumPyPrinter):
sympy/printing/numpy.py:482:class CuPyPrinter(NumPyPrinter):
214:    def _print_Min(self, expr):
217:    def _print_Max(self, expr):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/printing/pycode.py\n@@\n     def _print_Indexed(self, expr):\n         base = expr.args[0]\n         index = expr.args[1:]\n         return \"{}[{}]\".format(str(base), \", \".join([self._print(ind) for ind in index]))\n \n+    def _print_Min(self, expr):\n+        return \"min({})\".format(\", \".join(self._print(arg) for arg in expr.args))\n+\n+    def _print_Max(self, expr):\n+        return \"max({})\".format(\", \".join(self._print(arg) for arg in expr.args))\n+\n     def _print_Pow(self, expr, rational=False):\n         return self._hprint_Pow(expr, rational=rational)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/printing/pycode.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/printing/pycode.py now (646 lines), around the change:
437:        index = expr.args[1:]
438:        return "{}[{}]".format(str(base), ", ".join([self._print(ind) for ind in index]))
439:
440:    def _print_Min(self, expr):
441:        return "min({})".format(", ".join(self._print(arg) for arg in expr.args))
442:
443:    def _print_Max(self, expr):
444:        return "max({})".format(", ".join(self._print(arg) for arg in expr.args))
445:
446:    def _print_Pow(self, expr, rational=False):
447:        return self._hprint_Pow(expr, rational=rational)
448:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import symbols, Min, Max, pycode\na,b=symbols('a b')\nprint(pycode(Min(a,b)))\nprint(pycode(Max(a,b)))\n\""
}
```

**tool result**

```
min(a, b)
max(a, b)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class .*Printer\\|def test_\" sympy/printing/tests/test_pycode.py | head -40"
}
```

**tool result**

```
27:def test_PythonCodePrinter():
62:def test_PythonCodePrinter_standard():
70:def test_MpmathPrinter():
85:def test_NumPyPrinter():
135:def test_issue_18770():
154:def test_SciPyPrinter():
171:def test_pycode_reserved_words():
178:def test_issue_20762():
189:def test_sqrt():
216:def test_frac():
245:def test_printmethod():
251:def test_codegen_ast_nodes():
255:def test_issue_14283():
262:def test_NumPyPrinter_print_seq():
268:def test_issue_16535_16536():
288:def test_Integral():
310:def test_fresnel_integrals():
333:def test_beta():
353:def test_airy():
371:def test_airy_prime():
390:def test_numerical_accuracy_functions():
```

**assistant → tool `read_file`**

```json
{
  "path": "sympy/printing/tests/test_pycode.py",
  "offset": 27,
  "limit": 40
}
```

**tool result**

```
def test_PythonCodePrinter():
    prntr = PythonCodePrinter()

    assert not prntr.module_imports

    assert prntr.doprint(x**y) == 'x**y'
    assert prntr.doprint(Mod(x, 2)) == 'x % 2'
    assert prntr.doprint(-Mod(x, y)) == '-(x % y)'
    assert prntr.doprint(Mod(-x, y)) == '(-x) % y'
    assert prntr.doprint(And(x, y)) == 'x and y'
    assert prntr.doprint(Or(x, y)) == 'x or y'
    assert not prntr.module_imports

    assert prntr.doprint(pi) == 'math.pi'
    assert prntr.module_imports == {'math': {'pi'}}

    assert prntr.doprint(x**Rational(1, 2)) == 'math.sqrt(x)'
    assert prntr.doprint(sqrt(x)) == 'math.sqrt(x)'
    assert prntr.module_imports == {'math': {'pi', 'sqrt'}}

    assert prntr.doprint(acos(x)) == 'math.acos(x)'
    assert prntr.doprint(Assignment(x, 2)) == 'x = 2'
    assert prntr.doprint(Piecewise((1, Eq(x, 0)),
                        (2, x>6))) == '((1) if (x == 0) else (2) if (x > 6) else None)'
    assert prntr.doprint(Piecewise((2, Le(x, 0)),
                        (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
                                                        ' (3) if (x > 0) else None)'
    assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'
    assert prntr.doprint(p[0, 1]) == 'p[0, 1]'
    assert prntr.doprint(KroneckerDelta(x,y)) == '(1 if x == y else 0)'

    assert prntr.doprint((2,3)) == "(2, 3)"
    assert prntr.doprint([2,3]) == "[2, 3]"


def test_PythonCodePrinter_standard():
    prntr = PythonCodePrinter()

    assert prntr.standard == 'python3'


[328 more lines in /testbed/sympy/printing/tests/test_pycode.py (394 in all). read_file with offset: 67 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,26p' sympy/printing/tests/test_pycode.py"
}
```

**tool result**

```
from sympy.codegen import Assignment
from sympy.codegen.ast import none
from sympy.codegen.cfunctions import expm1, log1p
from sympy.codegen.scipy_nodes import cosm1
from sympy.codegen.matrix_nodes import MatrixSolve
from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo, Rational, Pow
from sympy.core.numbers import pi
from sympy.core.singleton import S
from sympy.functions import acos, KroneckerDelta, Piecewise, sign, sqrt
from sympy.logic import And, Or
from sympy.matrices import SparseMatrix, MatrixSymbol, Identity
from sympy.printing.pycode import (
    MpmathPrinter, PythonCodePrinter, pycode, SymPyPrinter
)
from sympy.printing.numpy import NumPyPrinter, SciPyPrinter
from sympy.testing.pytest import raises, skip
from sympy.tensor import IndexedBase
from sympy.external import import_module
from sympy.functions.special.gamma_functions import loggamma
from sympy.parsing.latex import parse_latex


x, y, z = symbols('x y z')
p = IndexedBase("p")
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/printing/tests/test_pycode.py\n@@\n-from sympy.functions import acos, KroneckerDelta, Piecewise, sign, sqrt\n+from sympy.functions import acos, KroneckerDelta, Max, Min, Piecewise, sign, sqrt\n@@\n     assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'\n+    assert prntr.doprint(Min(x, y)) == 'min(x, y)'\n+    assert prntr.doprint(Max(x, y)) == 'max(x, y)'\n     assert prntr.doprint(p[0, 1]) == 'p[0, 1]'\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/printing/tests/test_pycode.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/printing/tests/test_pycode.py now (396 lines), around the change:
6:from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo, Rational, Pow
7:from sympy.core.numbers import pi
8:from sympy.core.singleton import S
9:from sympy.functions import acos, KroneckerDelta, Max, Min, Piecewise, sign, sqrt
10:from sympy.logic import And, Or
11:from sympy.matrices import SparseMatrix, MatrixSymbol, Identity
12:from sympy.printing.pycode import (
…
52:                        (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
53:                                                        ' (3) if (x > 0) else None)'
54:    assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'
55:    assert prntr.doprint(Min(x, y)) == 'min(x, y)'
56:    assert prntr.doprint(Max(x, y)) == 'max(x, y)'
57:    assert prntr.doprint(p[0, 1]) == 'p[0, 1]'
58:    assert prntr.doprint(KroneckerDelta(x,y)) == '(1 if x == y else 0)'
59:
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
  "command": "python -c \"import sympy; sympy.test('sympy/printing/tests/test_pycode.py', verbose=False)\" 2>&1 | tail -20"
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
random seed:        85270349
hash randomization: on (PYTHONHASHSEED=2296774886)

sympy/printing/tests/test_pycode.py[21] ....s..s.............               [OK]

============ tests finished: 19 passed, 2 skipped, in 0.11 seconds =============
```

**assistant**

````
Implemented support for `Min` and `Max` in `PythonCodePrinter`.

Changes:
- Added `_print_Min` and `_print_Max` to `PythonCodePrinter` in `sympy/printing/pycode.py`, emitting `min(...)` / `max(...)`.
- Added regression assertions in `sympy/printing/tests/test_pycode.py`.

Verification:
```
>>> pycode(Min(a, b))
'min(a, b)'
>>> pycode(Max(a, b))
'max(a, b)'
```

Test suite: `sympy/printing/tests/test_pycode.py` — 19 passed, 2 skipped.
````

## Run folder `team-solve-2026-11-06T123148`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
7efc643deee7b83ae54909886fc4d12c9f90922d
```

### `baseline-check.log`

```
check: bin/test sympy/printing/tests/test_pycode.py
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.20-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        32581397
hash randomization: on (PYTHONHASHSEED=2002482441)

sympy/printing/tests/test_pycode.py[21] ....s..s.............               [OK]

============ tests finished: 19 passed, 2 skipped, in 0.30 seconds =============
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/sympy/printing/pycode.py b/sympy/printing/pycode.py
index 3a72ab606c..e82445fcf5 100644
--- a/sympy/printing/pycode.py
+++ b/sympy/printing/pycode.py
@@ -437,6 +437,12 @@ def _print_Indexed(self, expr):
         index = expr.args[1:]
         return "{}[{}]".format(str(base), ", ".join([self._print(ind) for ind in index]))
 
+    def _print_Min(self, expr):
+        return "min({})".format(", ".join(self._print(arg) for arg in expr.args))
+
+    def _print_Max(self, expr):
+        return "max({})".format(", ".join(self._print(arg) for arg in expr.args))
+
     def _print_Pow(self, expr, rational=False):
         return self._hprint_Pow(expr, rational=rational)
 
diff --git a/sympy/printing/tests/test_pycode.py b/sympy/printing/tests/test_pycode.py
index 9c1285d7dd..099de22ad3 100644
--- a/sympy/printing/tests/test_pycode.py
+++ b/sympy/printing/tests/test_pycode.py
@@ -6,7 +6,7 @@
 from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo, Rational, Pow
 from sympy.core.numbers import pi
 from sympy.core.singleton import S
-from sympy.functions import acos, KroneckerDelta, Piecewise, sign, sqrt
+from sympy.functions import acos, KroneckerDelta, Max, Min, Piecewise, sign, sqrt
 from sympy.logic import And, Or
 from sympy.matrices import SparseMatrix, MatrixSymbol, Identity
 from sympy.printing.pycode import (
@@ -52,6 +52,8 @@ def test_PythonCodePrinter():
                         (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
                                                         ' (3) if (x > 0) else None)'
     assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'
+    assert prntr.doprint(Min(x, y)) == 'min(x, y)'
+    assert prntr.doprint(Max(x, y)) == 'max(x, y)'
     assert prntr.doprint(p[0, 1]) == 'p[0, 1]'
     assert prntr.doprint(KroneckerDelta(x,y)) == '(1 if x == y else 0)'
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

PythonCodePrinter doesn't support Min and Max
We can't generate python code for the sympy function Min and Max.

For example:
```
from sympy import symbols, Min, pycode
a, b = symbols("a b")
c = Min(a,b)
print(pycode(c))
```
the output is:

```
  # Not supported in Python:
  # Min
Min(a, b)
```

Similar to issue #16669, we should add following methods to PythonCodePrinter:

```
def _print_Min(self, expr):
    return "min({})".format(", ".join(self._print(arg) for arg in expr.args))


def _print_Max(self, expr):
    return "max({})".format(", ".join(self._print(arg) for arg in expr.args))

```

## Deliverable

changes to this tree

## Check

`bin/test sympy/printing/tests/test_pycode.py`

## Scope

`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`

## Done when

`pycode(Min(a, b))` returns `min(a, b)` with no “Not supported in Python” comment.
`pycode(Max(a, b))` returns `max(a, b)` with no “Not supported in Python” comment.
`PythonCodePrinter` defines `_print_Min` and `_print_Max`, each printing every `expr.args` element through `self._print`.
The printing test suite for `pycode` passes.



# plan.md

## Deliverable
changes to this tree

## Check
`bin/test sympy/printing/tests/test_pycode.py`

## Scope
`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`

## Done when
`pycode(Min(a, b))` returns `min(a, b)` with no “Not supported in Python” comment.
`pycode(Max(a, b))` returns `max(a, b)` with no “Not supported in Python” comment.
`PythonCodePrinter` defines `_print_Min` and `_print_Max`, each printing every `expr.args` element through `self._print`.
The printing test suite for `pycode` passes.

## Approach
Decompose into: locate `PythonCodePrinter` in `sympy/printing/pycode.py`, add `_print_Min` and `_print_Max` using the supplied `min(...)`/`max(...)` formatting, add focused tests in `sympy/printing/tests/test_pycode.py`, then run the scoped test command.

Candidate approaches:
1. Add the two methods directly to `PythonCodePrinter` as proposed. This is the smallest change and matches the prompt exactly.
2. Add the methods to a shared base printer if one exists, so other Python-like printers inherit them. Tradeoff: broader behavior change than requested and may affect unrelated printers.
3. Implement through a generic function-printing hook or `_known_functions` mapping. Tradeoff: more indirection and less explicit than the requested `_print_Min`/`_print_Max` methods.

Prefer approach 1; fall back to checking whether `Min`/`Max` are already handled by a parent printer or need to be added to a subclass only if the scoped tests show dispatch is not reaching `PythonCodePrinter`.


# sympy/printing/pycode.py

```
"""
Python code printers

This module contains Python code printers for plain Python as well as NumPy & SciPy enabled code.
"""
from collections import defaultdict
from itertools import chain
from sympy.core import S
from .precedence import precedence
from .codeprinter import CodePrinter

_kw = {
    'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif',
    'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in',
    'is', 'lambda', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while',
    'with', 'yield', 'None', 'False', 'nonlocal', 'True'
}

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
    'ln': 'log',
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
    'E': 'e',
    'Infinity': 'inf',
    'NaN': 'nan',
    'ComplexInfinity': 'nan'
}

def _print_known_func(self, expr):
    known = self.known_functions[expr.__class__.__name__]
    return '{name}({args})'.format(name=self._module_format(known),
                                   args=', '.join(map(lambda arg: self._print(arg), expr.args)))


def _print_known_const(self, expr):
    known = self.known_constants[expr.__class__.__name__]
    return self._module_format(known)


class AbstractPythonCodePrinter(CodePrinter):
    printmethod = "_pythoncode"
    language = "Python"
    reserved_words = _kw
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
        contract=False,
        standard='python3',
    )

    def __init__(self, settings=None):
        super().__init__(settings)

        # Python standard handler
        std = self._settings['standard']
        if std is None:
            import sys
            std = 'python{}'.format(sys.version_info.major)
        if std != 'python3':
            raise ValueError('Only Python 3 is supported.')
        self.standard = std

        self.module_imports = defaultdict(set)

        # Known functions and constants handler
        self.known_functions = dict(self._kf, **(settings or {}).get(
            'user_functions', {}))
        self.known_constants = dict(self._kc, **(settings or {}).get(
            'user_constants', {}))

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
        return "{}".format(codestring)

    def _get_comment(self, text):
        return "  # {}".format(text)

    def _expand_fold_binary_op(self, op, args):
        """
        This method expands a fold on binary operations.

        ``functools.reduce`` is an example of a folded operation.

        For example, the expression

        `A + B + C + D`

        is folded into

        `((A + B) + C) + D`
        """
        if len(args) == 1:
            return self._print(args[0])
        else:
            return "%s(%s, %s)" % (
                self._module_format(op),
                self._expand_fold_binary_op(op, args[:-1]),
                self._print(args[-1]),
            )

    def _expand_reduce_binary_op(self, op, args):
        """
        This method expands a reductin on binary operations.

        Notice: this is NOT the same as ``functools.reduce``.

        For example, the expression

        `A + B + C + D`

        is reduced into:

        `(A + B) + (C + D)`
        """
        if len(args) == 1:
            return self._print(args[0])
        else:
            N = len(args)
            Nhalf = N // 2
            return "%s(%s, %s)" % (
                self._module_format(op),
                self._expand_reduce_binary_op(args[:Nhalf]),
                self._expand_reduce_binary_op(args[Nhalf:]),
            )

    def _get_einsum_string(self, subranks, contraction_indices):
        letters = self._get_letter_generator_for_einsum()
        contraction_string = ""
        counter = 0
        d = {j: min(i) for i in contraction_indices for j in i}
        indices = []
        for rank_arg in subranks:
            lindices = []
            for i in range(rank_arg):
                if counter in d:
                    lindices.append(d[counter])
                else:
                    lindices.append(counter)
                counter += 1
            indices.append(lindices)
        mapping = {}
        letters_free = []
        letters_dum = []
        for i in indices:
            for j in i:
                if j not in mapping:
                    l = next(letters)
                    mapping[j] = l
                else:
                    l = mapping[j]
                contraction_string += l
                if j in d:
                    if l not in letters_dum:
                        letters_dum.append(l)
                else:
                    letters_free.append(l)
            contraction_string += ","
        contraction_string = contraction_string[:-1]
        return contraction_string, letters_free, letters_dum

    def _print_NaN(self, expr):
        return "float('nan')"

    def _print_Infinity(self, expr):
        return "float('inf')"

    def _print_NegativeInfinity(self, expr):
        return "float('-inf')"

    def _print_ComplexInfinity(self, expr):
        return self._print_NaN(expr)

    def _print_Mod(self, expr):
        PREC = precedence(expr)
        return ('{} % {}'.format(*map(lambda x: self.parenthesize(x, PREC), expr.args)))

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
        return super()._print_Relational(expr)

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

    def _print_KroneckerDelta(self, expr):
        a, b = expr.args

        return '(1 if {a} == {b} else 0)'.format(
            a = self._print(a),
            b = self._print(b)
        )

    def _print_MatrixBase(self, expr):
        name = expr.__class__.__name__
        func = self.known_functions.get(name, name)
        return "%s(%s)" % (func, self._print(expr.tolist()))

    _print_SparseRepMatrix = \
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
        if prnt.format_string != None: # Must be '!= None', cannot be 'is not None'
            print_args = '{} % ({})'.format(
                self._print(prnt.format_string), print_args)
        if prnt.file != None: # Must be '!= None', cannot be 'is not None'
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

    def _hprint_Pow(self, expr, rational=False, sqrt='math.sqrt'):
        """Printing helper function for ``Pow``

        Notes
        =====

        This only preprocesses the ``sqrt`` as math formatter

        Examples
        ========

        >>> from sympy.functions import sqrt
        >>> from sympy.printing.pycode import PythonCodePrinter
        >>> from sympy.abc import x

        Python code printer automatically looks up ``math.sqrt``.

        >>> printer = PythonCodePrinter()
        >>> printer._hprint_Pow(sqrt(x), rational=True)
        'x**(1/2)'
        >>> printer._hprint_Pow(sqrt(x), rational=False)
        'math.sqrt(x)'
        >>> printer._hprint_Pow(1/sqrt(x), rational=True)
        'x**(-1/2)'
        >>> printer._hprint_Pow(1/sqrt(x), rational=False)
        '1/math.sqrt(x)'

        Using sqrt from numpy or mpmath

        >>> printer._hprint_Pow(sqrt(x), sqrt='numpy.sqrt')
        'numpy.sqrt(x)'
        >>> printer._hprint_Pow(sqrt(x), sqrt='mpmath.sqrt')
        'mpmath.sqrt(x)'

        See Also
        ========

        sympy.printing.str.StrPrinter._print_Pow
        """
        PREC = precedence(expr)

        if expr.exp == S.Half and not rational:
            func = self._module_format(sqrt)
            arg = self._print(expr.base)
            return '{func}({arg})'.format(func=func, arg=arg)

        if expr.is_commutative:
            if -expr.exp is S.Half and not rational:
                func = self._module_format(sqrt)
                num = self._print(S.One)
                arg = self._print(expr.base)
                return "{num}/{func}({arg})".format(
                    num=num, func=func, arg=arg)

        base_str = self.parenthesize(expr.base, PREC, strict=False)
        exp_str = self.parenthesize(expr.exp, PREC, strict=False)
        return "{}**{}".format(base_str, exp_str)


class PythonCodePrinter(AbstractPythonCodePrinter):

    def _print_sign(self, e):
        return '(0.0 if {e} == 0 else {f}(1, {e}))'.format(
            f=self._module_format('math.copysign'), e=self._print(e.args[0]))

    def _print_Not(self, expr):
        PREC = precedence(expr)
        return self._operators['not'] + self.parenthesize(expr.args[0], PREC)

    def _print_Indexed(self, expr):
        base = expr.args[0]
        index = expr.args[1:]
        return "{}[{}]".format(str(base), ", ".join([self._print(ind) for ind in index]))

    def _print_Min(self, expr):
        return "min({})".format(", ".join(self._print(arg) for arg in expr.args))

    def _print_Max(self, expr):
        return "max({})".format(", ".join(self._print(arg) for arg in expr.args))

    def _print_Pow(self, expr, rational=False):
        return self._hprint_Pow(expr, rational=rational)

    def _print_Rational(self, expr):
        return '{}/{}'.format(expr.p, expr.q)

    def _print_Half(self, expr):
        return self._print_Rational(expr)

    def _print_frac(self, expr):
        from sympy.core.mod import Mod
        return self._print_Mod(Mod(expr.args[0], 1))

    def _print_Symbol(self, expr):

        name = super()._print_Symbol(expr)

        if name in self.reserved_words:
            if self._settings['error_on_reserved']:
                msg = ('This expression includes the symbol "{}" which is a '
                       'reserved keyword in this language.')
                raise ValueError(msg.format(name))
            return name + self._settings['reserved_word_suffix']
        elif '{' in name:   # Remove curly braces from subscripted variables
            return name.replace('{', '').replace('}', '')
        else:
            return name

    _print_lowergamma = CodePrinter._print_not_supported
    _print_uppergamma = CodePrinter._print_not_supported
    _print_fresnelc = CodePrinter._print_not_supported
    _print_fresnels = CodePrinter._print_not_supported


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
    standard : str or None, optional
        Only 'python3' (default) is supported.
        This parameter may be removed in the future.

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
    'beta': 'beta',
    'frac': 'frac',
    'fresnelc': 'fresnelc',
    'fresnels': 'fresnels',
    'sign': 'sign',
    'loggamma': 'loggamma',
    'hyper': 'hyper',
    'meijerg': 'meijerg',
    'besselj': 'besselj',
    'bessely': 'bessely',
    'besseli': 'besseli',
    'besselk': 'besselk',
})
_known_constants_mpmath = {
    'Exp1': 'e',
    'Pi': 'pi',
    'GoldenRatio': 'phi',
    'EulerGamma': 'euler',
    'Catalan': 'catalan',
    'NaN': 'nan',
    'Infinity': 'inf',
    'NegativeInfinity': 'ninf'
}


def _unpack_integral_limits(integral_expr):
    """ helper function for _print_Integral that
        - accepts an Integral expression
        - returns a tuple of
           - a list variables of integration
           - a list of tuples of the upper and lower limits of integration
    """
    integration_vars = []
    limits = []
    for integration_range in integral_expr.limits:
        if len(integration_range) == 3:
            integration_var, lower_limit, upper_limit = integration_range
        else:
            raise NotImplementedError("Only definite integrals are supported")
        integration_vars.append(integration_var)
        limits.append((lower_limit, upper_limit))
    return integration_vars, limits


class MpmathPrinter(PythonCodePrinter):
    """
    Lambda printer for mpmath which maintains precision for floats
    """
    printmethod = "_mpmathcode"

    language = "Python with mpmath"

    _kf = dict(chain(
        _known_functions.items(),
        [(k, 'mpmath.' + v) for k, v in _known_functions_mpmath.items()]
    ))
    _kc = {k: 'mpmath.'+v for k, v in _known_constants_mpmath.items()}

    def _print_Float(self, e):
        # XXX: This does not handle setting mpmath.mp.dps. It is assumed that
        # the caller of the lambdified function will have set it to sufficient
        # precision to match the Floats in the expression.

        # Remove 'mpz' if gmpy is installed.
        args = str(tuple(map(int, e._mpf_)))
        return '{func}({args})'.format(func=self._module_format('mpmath.mpf'), args=args)


    def _print_Rational(self, e):
        return "{func}({p})/{func}({q})".format(
            func=self._module_format('mpmath.mpf'),
            q=self._print(e.q),
            p=self._print(e.p)
        )

    def _print_Half(self, e):
        return self._print_Rational(e)

    def _print_uppergamma(self, e):
        return "{}({}, {}, {})".format(
            self._module_format('mpmath.gammainc'),
            self._print(e.args[0]),
            self._print(e.args[1]),
            self._module_format('mpmath.inf'))

    def _print_lowergamma(self, e):
        return "{}({}, 0, {})".format(
            self._module_format('mpmath.gammainc'),
            self._print(e.args[0]),
            self._print(e.args[1]))

    def _print_log2(self, e):
        return '{0}({1})/{0}(2)'.format(
            self._module_format('mpmath.log'), self._print(e.args[0]))

    def _print_log1p(self, e):
        return '{}({}+1)'.format(
            self._module_format('mpmath.log'), self._print(e.args[0]))

    def _print_Pow(self, expr, rational=False):
        return self._hprint_Pow(expr, rational=rational, sqrt='mpmath.sqrt')

    def _print_Integral(self, e):
        integration_vars, limits = _unpack_integral_limits(e)

        return "{}(lambda {}: {}, {})".format(
                self._module_format("mpmath.quad"),
                ", ".join(map(self._print, integration_vars)),
                self._print(e.args[0]),
                ", ".join("(%s, %s)" % tuple(map(self._print, l)) for l in limits))


for k in MpmathPrinter._kf:
    setattr(MpmathPrinter, '_print_%s' % k, _print_known_func)

for k in _known_constants_mpmath:
    setattr(MpmathPrinter, '_print_%s' % k, _print_known_const)


class SymPyPrinter(AbstractPythonCodePrinter):

    language = "Python with SymPy"

    def _print_Function(self, expr):
        mod = expr.func.__module__ or ''
        return '%s(%s)' % (self._module_format(mod + ('.' if mod else '') + expr.func.__name__),
                           ', '.join(map(lambda arg: self._print(arg), expr.args)))

    def _print_Pow(self, expr, rational=False):
        return self._hprint_Pow(expr, rational=rational, sqrt='sympy.sqrt')

```


# sympy/printing/tests/test_pycode.py

```
from sympy.codegen import Assignment
from sympy.codegen.ast import none
from sympy.codegen.cfunctions import expm1, log1p
from sympy.codegen.scipy_nodes import cosm1
from sympy.codegen.matrix_nodes import MatrixSolve
from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo, Rational, Pow
from sympy.core.numbers import pi
from sympy.core.singleton import S
from sympy.functions import acos, KroneckerDelta, Piecewise, sign, sqrt
from sympy.logic import And, Or
from sympy.matrices import SparseMatrix, MatrixSymbol, Identity
from sympy.printing.pycode import (
    MpmathPrinter, PythonCodePrinter, pycode, SymPyPrinter
)
from sympy.printing.numpy import NumPyPrinter, SciPyPrinter
from sympy.testing.pytest import raises, skip
from sympy.tensor import IndexedBase
from sympy.external import import_module
from sympy.functions.special.gamma_functions import loggamma
from sympy.parsing.latex import parse_latex


x, y, z = symbols('x y z')
p = IndexedBase("p")


def test_PythonCodePrinter():
    prntr = PythonCodePrinter()

    assert not prntr.module_imports

    assert prntr.doprint(x**y) == 'x**y'
    assert prntr.doprint(Mod(x, 2)) == 'x % 2'
    assert prntr.doprint(-Mod(x, y)) == '-(x % y)'
    assert prntr.doprint(Mod(-x, y)) == '(-x) % y'
    assert prntr.doprint(And(x, y)) == 'x and y'
    assert prntr.doprint(Or(x, y)) == 'x or y'
    assert not prntr.module_imports

    assert prntr.doprint(pi) == 'math.pi'
    assert prntr.module_imports == {'math': {'pi'}}

    assert prntr.doprint(x**Rational(1, 2)) == 'math.sqrt(x)'
    assert prntr.doprint(sqrt(x)) == 'math.sqrt(x)'
    assert prntr.module_imports == {'math': {'pi', 'sqrt'}}

    assert prntr.doprint(acos(x)) == 'math.acos(x)'
    assert prntr.doprint(Assignment(x, 2)) == 'x = 2'
    assert prntr.doprint(Piecewise((1, Eq(x, 0)),
                        (2, x>6))) == '((1) if (x == 0) else (2) if (x > 6) else None)'
    assert prntr.doprint(Piecewise((2, Le(x, 0)),
                        (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
                                                        ' (3) if (x > 0) else None)'
    assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'
    assert prntr.doprint(p[0, 1]) == 'p[0, 1]'
    assert prntr.doprint(KroneckerDelta(x,y)) == '(1 if x == y else 0)'

    assert prntr.doprint((2,3)) == "(2, 3)"
    assert prntr.doprint([2,3]) == "[2, 3]"


def test_PythonCodePrinter_standard():
    prntr = PythonCodePrinter()

    assert prntr.standard == 'python3'

    raises(ValueError, lambda: PythonCodePrinter({'standard':'python4'}))


def test_MpmathPrinter():
    p = MpmathPrinter()
    assert p.doprint(sign(x)) == 'mpmath.sign(x)'
    assert p.doprint(Rational(1, 2)) == 'mpmath.mpf(1)/mpmath.mpf(2)'

    assert p.doprint(S.Exp1) == 'mpmath.e'
    assert p.doprint(S.Pi) == 'mpmath.pi'
    assert p.doprint(S.GoldenRatio) == 'mpmath.phi'
    assert p.doprint(S.EulerGamma) == 'mpmath.euler'
    assert p.doprint(S.NaN) == 'mpmath.nan'
    assert p.doprint(S.Infinity) == 'mpmath.inf'
    assert p.doprint(S.NegativeInfinity) == 'mpmath.ninf'
    assert p.doprint(loggamma(x)) == 'mpmath.loggamma(x)'


def test_NumPyPrinter():
    from sympy.core.function import Lambda
    from sympy.matrices.expressions.adjoint import Adjoint
    from sympy.matrices.expressions.diagonal import (DiagMatrix, DiagonalMatrix, DiagonalOf)
    from sympy.matrices.expressions.funcmatrix import FunctionMatrix
    from sympy.matrices.expressions.hadamard import HadamardProduct
    from sympy.matrices.expressions.kronecker import KroneckerProduct
    from sympy.matrices.expressions.special import (OneMatrix, ZeroMatrix)
    from sympy.abc import a, b
    p = NumPyPrinter()
    assert p.doprint(sign(x)) == 'numpy.sign(x)'
    A = MatrixSymbol("A", 2, 2)
    B = MatrixSymbol("B", 2, 2)
    C = MatrixSymbol("C", 1, 5)
    D = MatrixSymbol("D", 3, 4)
    assert p.doprint(A**(-1)) == "numpy.linalg.inv(A)"
    assert p.doprint(A**5) == "numpy.linalg.matrix_power(A, 5)"
    assert p.doprint(Identity(3)) == "numpy.eye(3)"

    u = MatrixSymbol('x', 2, 1)
    v = MatrixSymbol('y', 2, 1)
    assert p.doprint(MatrixSolve(A, u)) == 'numpy.linalg.solve(A, x)'
    assert p.doprint(MatrixSolve(A, u) + v) == 'numpy.linalg.solve(A, x) + y'

    assert p.doprint(ZeroMatrix(2, 3)) == "numpy.zeros((2, 3))"
    assert p.doprint(OneMatrix(2, 3)) == "numpy.ones((2, 3))"
    assert p.doprint(FunctionMatrix(4, 5, Lambda((a, b), a + b))) == \
        "numpy.fromfunction(lambda a, b: a + b, (4, 5))"
    assert p.doprint(HadamardProduct(A, B)) == "numpy.multiply(A, B)"
    assert p.doprint(KroneckerProduct(A, B)) == "numpy.kron(A, B)"
    assert p.doprint(Adjoint(A)) == "numpy.conjugate(numpy.transpose(A))"
    assert p.doprint(DiagonalOf(A)) == "numpy.reshape(numpy.diag(A), (-1, 1))"
    assert p.doprint(DiagMatrix(C)) == "numpy.diagflat(C)"
    assert p.doprint(DiagonalMatrix(D)) == "numpy.multiply(D, numpy.eye(3, 4))"

    # Workaround for numpy negative integer power errors
    assert p.doprint(x**-1) == 'x**(-1.0)'
    assert p.doprint(x**-2) == 'x**(-2.0)'

    expr = Pow(2, -1, evaluate=False)
    assert p.doprint(expr) == "2**(-1.0)"

    assert p.doprint(S.Exp1) == 'numpy.e'
    assert p.doprint(S.Pi) == 'numpy.pi'
    assert p.doprint(S.EulerGamma) == 'numpy.euler_gamma'
    assert p.doprint(S.NaN) == 'numpy.nan'
    assert p.doprint(S.Infinity) == 'numpy.PINF'
    assert p.doprint(S.NegativeInfinity) == 'numpy.NINF'


def test_issue_18770():
    numpy = import_module('numpy')
    if not numpy:
        skip("numpy not installed.")

    from sympy.functions.elementary.miscellaneous import (Max, Min)
    from sympy.utilities.lambdify import lambdify

    expr1 = Min(0.1*x + 3, x + 1, 0.5*x + 1)
    func = lambdify(x, expr1, "numpy")
    assert (func(numpy.linspace(0, 3, 3)) == [1.0, 1.75, 2.5 ]).all()
    assert  func(4) == 3

    expr1 = Max(x**2, x**3)
    func = lambdify(x,expr1, "numpy")
    assert (func(numpy.linspace(-1, 2, 4)) == [1, 0, 1, 8] ).all()
    assert func(4) == 64


def test_SciPyPrinter():
    p = SciPyPrinter()
    expr = acos(x)
    assert 'numpy' not in p.module_imports
    assert p.doprint(expr) == 'numpy.arccos(x)'
    assert 'numpy' in p.module_imports
    assert not any(m.startswith('scipy') for m in p.module_imports)
    smat = SparseMatrix(2, 5, {(0, 1): 3})
    assert p.doprint(smat) == \
        'scipy.sparse.coo_matrix(([3], ([0], [1])), shape=(2, 5))'
    assert 'scipy.sparse' in p.module_imports

    assert p.doprint(S.GoldenRatio) == 'scipy.constants.golden_ratio'
    assert p.doprint(S.Pi) == 'scipy.constants.pi'
    assert p.doprint(S.Exp1) == 'numpy.e'


def test_pycode_reserved_words():
    s1, s2 = symbols('if else')
    raises(ValueError, lambda: pycode(s1 + s2, error_on_reserved=True))
    py_str = pycode(s1 + s2)
    assert py_str in ('else_ + if_', 'if_ + else_')


def test_issue_20762():
    antlr4 = import_module("antlr4")
    if not antlr4:
        skip('antlr not installed.')
    # Make sure pycode removes curly braces from subscripted variables
    expr = parse_latex(r'a_b \cdot b')
    assert pycode(expr) == 'a_b*b'
    expr = parse_latex(r'a_{11} \cdot b')
    assert pycode(expr) == 'a_11*b'


def test_sqrt():
    prntr = PythonCodePrinter()
    assert prntr._print_Pow(sqrt(x), rational=False) == 'math.sqrt(x)'
    assert prntr._print_Pow(1/sqrt(x), rational=False) == '1/math.sqrt(x)'

    prntr = PythonCodePrinter({'standard' : 'python3'})
    assert prntr._print_Pow(sqrt(x), rational=True) == 'x**(1/2)'
    assert prntr._print_Pow(1/sqrt(x), rational=True) == 'x**(-1/2)'

    prntr = MpmathPrinter()
    assert prntr._print_Pow(sqrt(x), rational=False) == 'mpmath.sqrt(x)'
    assert prntr._print_Pow(sqrt(x), rational=True) == \
        "x**(mpmath.mpf(1)/mpmath.mpf(2))"

    prntr = NumPyPrinter()
    assert prntr._print_Pow(sqrt(x), rational=False) == 'numpy.sqrt(x)'
    assert prntr._print_Pow(sqrt(x), rational=True) == 'x**(1/2)'

    prntr = SciPyPrinter()
    assert prntr._print_Pow(sqrt(x), rational=False) == 'numpy.sqrt(x)'
    assert prntr._print_Pow(sqrt(x), rational=True) == 'x**(1/2)'

    prntr = SymPyPrinter()
    assert prntr._print_Pow(sqrt(x), rational=False) == 'sympy.sqrt(x)'
    assert prntr._print_Pow(sqrt(x), rational=True) == 'x**(1/2)'


def test_frac():
    from sympy.functions.elementary.integers import frac

    expr = frac(x)

    prntr = NumPyPrinter()
    assert prntr.doprint(expr) == 'numpy.mod(x, 1)'

    prntr = SciPyPrinter()
    assert prntr.doprint(expr) == 'numpy.mod(x, 1)'

    prntr = PythonCodePrinter()
    assert prntr.doprint(expr) == 'x % 1'

    prntr = MpmathPrinter()
    assert prntr.doprint(expr) == 'mpmath.frac(x)'

    prntr = SymPyPrinter()
    assert prntr.doprint(expr) == 'sympy.functions.elementary.integers.frac(x)'


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

    assert prntr.doprint(zoo) == "math.nan"
    assert prntr.doprint(-oo) == "float('-inf')"


def test_NumPyPrinter_print_seq():
    n = NumPyPrinter()

    assert n._print_seq(range(2)) == '(0, 1,)'


def test_issue_16535_16536():
    from sympy.functions.special.gamma_functions import (lowergamma, uppergamma)

    a = symbols('a')
    expr1 = lowergamma(a, x)
    expr2 = uppergamma(a, x)

    prntr = SciPyPrinter()
    assert prntr.doprint(expr1) == 'scipy.special.gamma(a)*scipy.special.gammainc(a, x)'
    assert prntr.doprint(expr2) == 'scipy.special.gamma(a)*scipy.special.gammaincc(a, x)'

    prntr = NumPyPrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)

    prntr = PythonCodePrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)


def test_Integral():
    from sympy.functions.elementary.exponential import exp
    from sympy.integrals.integrals import Integral

    single = Integral(exp(-x), (x, 0, oo))
    double = Integral(x**2*exp(x*y), (x, -z, z), (y, 0, z))
    indefinite = Integral(x**2, x)
    evaluateat = Integral(x**2, (x, 1))

    prntr = SciPyPrinter()
    assert prntr.doprint(single) == 'scipy.integrate.quad(lambda x: numpy.exp(-x), 0, numpy.PINF)[0]'
    assert prntr.doprint(double) == 'scipy.integrate.nquad(lambda x, y: x**2*numpy.exp(x*y), ((-z, z), (0, z)))[0]'
    raises(NotImplementedError, lambda: prntr.doprint(indefinite))
    raises(NotImplementedError, lambda: prntr.doprint(evaluateat))

    prntr = MpmathPrinter()
    assert prntr.doprint(single) == 'mpmath.quad(lambda x: mpmath.exp(-x), (0, mpmath.inf))'
    assert prntr.doprint(double) == 'mpmath.quad(lambda x, y: x**2*mpmath.exp(x*y), (-z, z), (0, z))'
    raises(NotImplementedError, lambda: prntr.doprint(indefinite))
    raises(NotImplementedError, lambda: prntr.doprint(evaluateat))


def test_fresnel_integrals():
    from sympy.functions.special.error_functions import (fresnelc, fresnels)

    expr1 = fresnelc(x)
    expr2 = fresnels(x)

    prntr = SciPyPrinter()
    assert prntr.doprint(expr1) == 'scipy.special.fresnel(x)[1]'
    assert prntr.doprint(expr2) == 'scipy.special.fresnel(x)[0]'

    prntr = NumPyPrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)

    prntr = PythonCodePrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)

    prntr = MpmathPrinter()
    assert prntr.doprint(expr1) == 'mpmath.fresnelc(x)'
    assert prntr.doprint(expr2) == 'mpmath.fresnels(x)'


def test_beta():
    from sympy.functions.special.beta_functions import beta

    expr = beta(x, y)

    prntr = SciPyPrinter()
    assert prntr.doprint(expr) == 'scipy.special.beta(x, y)'

    prntr = NumPyPrinter()
    assert prntr.doprint(expr) == 'math.gamma(x)*math.gamma(y)/math.gamma(x + y)'

    prntr = PythonCodePrinter()
    assert prntr.doprint(expr) == 'math.gamma(x)*math.gamma(y)/math.gamma(x + y)'

    prntr = PythonCodePrinter({'allow_unknown_functions': True})
    assert prntr.doprint(expr) == 'math.gamma(x)*math.gamma(y)/math.gamma(x + y)'

    prntr = MpmathPrinter()
    assert prntr.doprint(expr) ==  'mpmath.beta(x, y)'

def test_airy():
    from sympy.functions.special.bessel import (airyai, airybi)

    expr1 = airyai(x)
    expr2 = airybi(x)

    prntr = SciPyPrinter()
    assert prntr.doprint(expr1) == 'scipy.special.airy(x)[0]'
    assert prntr.doprint(expr2) == 'scipy.special.airy(x)[2]'

    prntr = NumPyPrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)

    prntr = PythonCodePrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)

def test_airy_prime():
    from sympy.functions.special.bessel import (airyaiprime, airybiprime)

    expr1 = airyaiprime(x)
    expr2 = airybiprime(x)

    prntr = SciPyPrinter()
    assert prntr.doprint(expr1) == 'scipy.special.airy(x)[1]'
    assert prntr.doprint(expr2) == 'scipy.special.airy(x)[3]'

    prntr = NumPyPrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)

    prntr = PythonCodePrinter()
    assert "Not supported" in prntr.doprint(expr1)
    assert "Not supported" in prntr.doprint(expr2)


def test_numerical_accuracy_functions():
    prntr = SciPyPrinter()
    assert prntr.doprint(expm1(x)) == 'numpy.expm1(x)'
    assert prntr.doprint(log1p(x)) == 'numpy.log1p(x)'
    assert prntr.doprint(cosm1(x)) == 'scipy.special.cosm1(x)'

```


# The last commit

```
7efc643dee SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: bin/test sympy/printing/tests/test_pycode.py
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.20-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        42727478
hash randomization: on (PYTHONHASHSEED=599473541)

sympy/printing/tests/test_pycode.py[21] ....s..s.............               [OK]

============ tests finished: 19 passed, 2 skipped, in 0.10 seconds =============
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py
changed: sympy/printing/pycode.py +6 -0
changed: sympy/printing/tests/test_pycode.py +3 -1
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sympy/printing/pycode.py b/sympy/printing/pycode.py
index 3a72ab606c..e82445fcf5 100644
--- a/sympy/printing/pycode.py
+++ b/sympy/printing/pycode.py
@@ -437,6 +437,12 @@ def _print_Indexed(self, expr):
         index = expr.args[1:]
         return "{}[{}]".format(str(base), ", ".join([self._print(ind) for ind in index]))
 
+    def _print_Min(self, expr):
+        return "min({})".format(", ".join(self._print(arg) for arg in expr.args))
+
+    def _print_Max(self, expr):
+        return "max({})".format(", ".join(self._print(arg) for arg in expr.args))
+
     def _print_Pow(self, expr, rational=False):
         return self._hprint_Pow(expr, rational=rational)
 
diff --git a/sympy/printing/tests/test_pycode.py b/sympy/printing/tests/test_pycode.py
index 9c1285d7dd..099de22ad3 100644
--- a/sympy/printing/tests/test_pycode.py
+++ b/sympy/printing/tests/test_pycode.py
@@ -6,7 +6,7 @@
 from sympy.core import Expr, Mod, symbols, Eq, Le, Gt, zoo, oo, Rational, Pow
 from sympy.core.numbers import pi
 from sympy.core.singleton import S
-from sympy.functions import acos, KroneckerDelta, Piecewise, sign, sqrt
+from sympy.functions import acos, KroneckerDelta, Max, Min, Piecewise, sign, sqrt
 from sympy.logic import And, Or
 from sympy.matrices import SparseMatrix, MatrixSymbol, Identity
 from sympy.printing.pycode import (
@@ -52,6 +52,8 @@ def test_PythonCodePrinter():
                         (3, Gt(x, 0)), evaluate=False)) == '((2) if (x <= 0) else'\
                                                         ' (3) if (x > 0) else None)'
     assert prntr.doprint(sign(x)) == '(0.0 if x == 0 else math.copysign(1, x))'
+    assert prntr.doprint(Min(x, y)) == 'min(x, y)'
+    assert prntr.doprint(Max(x, y)) == 'max(x, y)'
     assert prntr.doprint(p[0, 1]) == 'p[0, 1]'
     assert prntr.doprint(KroneckerDelta(x,y)) == '(1 if x == y else 0)'
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
check: bin/test sympy/printing/tests/test_pycode.py
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.20-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        84697766
hash randomization: on (PYTHONHASHSEED=69676617)

sympy/printing/tests/test_pycode.py[21] ....s..s.............               [OK]

============ tests finished: 19 passed, 2 skipped, in 0.11 seconds =============
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py
changed: sympy/printing/pycode.py +6 -0
changed: sympy/printing/tests/test_pycode.py +3 -1
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
# Notes, run 2026-11-06T123148

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

PythonCodePrinter doesn't support Min and Max
We can't generate python code for the sympy function Min and Max.

For example:
```
from sympy import symbols, Min, pycode
a, b = symbols("a b")
c = Min(a,b)
print(pycode(c))
```
the output is:

```
  # Not supported in Python:
  # Min
Min(a, b)
```

Similar to issue #16669, we should add following methods to PythonCodePrinter:

```
def _print_Min(self, expr):
    return "min({})".format(", ".join(self._print(arg) for arg in expr.args))


def _print_Max(self, expr):
    return "max({})".format(", ".join(self._print(arg) for arg in expr.args))

```


# The files of the project

```
.ci/README.rst
.ci/blacklisted.json
.ci/durations.json
.ci/generate_durations_log.sh
.ci/parse_durations_log.py
.editorconfig
.gitattributes
.github/workflows/ci-sage.yml
.github/workflows/comment-on-pr.yml
.github/workflows/runtests.yml
.gitignore
.mailmap
.travis.yml
AUTHORS
CODEOWNERS
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE
MANIFEST.in
PULL_REQUEST_TEMPLATE.md
README.md
asv.conf.actions.json
asv.conf.travis.json
banner.svg
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
bin/mailmap_check.py
bin/mailmap_update.py
bin/py.bench
bin/strip_whitespace
bin/sympy_time.py
bin/sympy_time_cache.py
bin/test
bin/test_executable.py
bin/test_external_imports.py
bin/test_import
bin/test_import.py
bin/test_isolated
bin/test_optional_dependencies.py
bin/test_py2_import.py
bin/test_setup.py
bin/test_sphinx.sh
bin/test_submodule_imports.py
bin/test_symengine.py
bin/test_tensorflow.py
bin/test_travis.sh
codecov.yml
conftest.py
coveragerc_travis
data/TeXmacs/LICENSE
data/TeXmacs/bin/tm_sympy
data/TeXmacs/progs/init-sympy.scm
doc/Dockerfile.htmldoc
doc/Makefile
doc/README.rst
doc/api/conf.py
doc/api/index.rst
doc/apidoc.conf
doc/cheatsheet/cheatsheet.tex
doc/cheatsheet/combinatoric_cheatsheet.tex
doc/convert-svg-to-pdf.sh
doc/ext/docscrape.py
doc/ext/docscrape_sphinx.py
doc/ext/numpydoc.py
doc/ext/sympylive.py
doc/generate_logos.py
doc/man/isympy.1
doc/man/isympy.xml
doc/requirements.txt
doc/src/_static/default.css_t
doc/src/_static/sympylogo.png
doc/src/_static/sympylogo_big.png
doc/src/_templates/layout.html
doc/src/aboutus.rst
doc/src/citing.rst
doc/src/conf.py
doc/src/explanation/gotchas.rst
doc/src/explanation/index.rst
doc/src/explanation/special_topics/classification.rst
doc/src/explanation/special_topics/finite_diff_derivatives.rst
doc/src/explanation/special_topics/index.rst
doc/src/guides/assumptions.rst
doc/src/guides/booleans.rst
doc/src/guides/contributing/build-docs.rst
doc/src/guides/contributing/debug.rst
doc/src/guides/contributing/dependencies.md
doc/src/guides/contributing/dev-setup.rst
doc/src/guides/contributing/docstring.rst
doc/src/guides/contributing/documentation-style-guide.rst
doc/src/guides/contributing/index.rst
doc/src/guides/contributing/make-a-contribution.rst
doc/src/guides/getting_started/index.rst
doc/src/guides/getting_started/install.md
doc/src/guides/index.rst
doc/src/index.rst
doc/src/logo/info.txt
doc/src/logo/sympy-use-text.svg
doc/src/logo/sympy.svg
doc/src/miscellaneous/index.rst
doc/src/modules/abc.rst
doc/src/modules/algebras.rst
doc/src/modules/assumptions/ask.rst
doc/src/modules/assumptions/assume.rst
doc/src/modules/assumptions/index.rst
doc/src/modules/assumptions/predicates.rst
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
doc/src/modules/combinatorics/pc_groups.rst
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
doc/src/modules/discrete.rst
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
doc/src/modules/holonomic/internal.rst
doc/src/modules/holonomic/operations.rst
doc/src/modules/holonomic/represent.rst
doc/src/modules/holonomic/uses.rst
doc/src/modules/integrals/g-functions.rst
doc/src/modules/integrals/index.rst
doc/src/modules/integrals/integrals.rst
doc/src/modules/interactive.rst
doc/src/modules/liealgebras/index.rst
doc/src/modules/logic.rst
doc/src/modules/matrices/common.rst
doc/src/modules/matrices/dense.rst
doc/src/modules/matrices/expressions.rst
doc/src/modules/matrices/immutablematrices.rst
doc/src/modules/matrices/index.rst
doc/src/modules/matrices/matrices.rst
doc/src/modules/matrices/normalforms.rst
doc/src/modules/matrices/sparse.rst
doc/src/modules/matrices/sparsetools.rst
doc/src/modules/ntheory.rst
doc/src/modules/numeric-computation.rst
doc/src/modules/parsing.rst
doc/src/modules/physics/continuum_mechanics/allowed-sign-conventions.png
doc/src/modules/physics/continuum_mechanics/beam.rst
doc/src/modules/physics/continuum_mechanics/beam_problems.rst
doc/src/modules/physics/continuum_mechanics/ildreaction.png
doc/src/modules/physics/continuum_mechanics/ildshear.png
doc/src/modules/physics/continuum_mechanics/index.rst
doc/src/modules/physics/control/control.rst
doc/src/modules/physics/control/control_plots.rst
doc/src/modules/physics/control/index.rst
doc/src/modules/physics/control/lti.rst
doc/src/modules/physics/hep/index.rst
doc/src/modules/physics/hydrogen.rst
doc/src/modules/physics/matrices.rst
doc/src/modules/physics/mechanics/advanced.rst
doc/src/modules/physics/mechanics/api/body.rst
doc/src/modules/physics/mechanics/api/expr_manip.rst
doc/src/modules/physics/mechanics/api/joint.rst
doc/src/modules/physics/mechanics/api/kane_lagrange.rst
doc/src/modules/physics/mechanics/api/linearize.rst
doc/src/modules/physics/mechanics/api/part_bod.rst
doc/src/modules/physics/mechanics/api/printing.rst
doc/src/modules/physics/mechanics/api/system.rst
doc/src/modules/physics/mechanics/autolev_parser.rst
doc/src/modules/physics/mechanics/examples.rst
doc/src/modules/physics/mechanics/examples/bicycle_example.rst
doc/src/modules/physics/mechanics/examples/lin_pend_nonmin_example.rst
doc/src/modules/physics/mechanics/examples/multi_degree_freedom_holonomic_system.rst
doc/src/modules/physics/mechanics/examples/multidof-holonomic.png
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
doc/src/modules/physics/mechanics/sympy_mechanics_for_autolev_users.rst
doc/src/modules/physics/mechanics/symsystem.rst
doc/src/modules/physics/optics/gaussopt.rst
doc/src/modules/physics/optics/index.rst
doc/src/modules/physics/optics/medium.rst
doc/src/modules/physics/optics/polarization.rst
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
doc/src/modules/polys/domainmatrix.rst
doc/src/modules/polys/domainsintro.rst
doc/src/modules/polys/domainsref.rst
doc/src/modules/polys/index.rst
doc/src/modules/polys/internals.rst
doc/src/modules/polys/literature.rst
doc/src/modules/polys/numberfields.rst
doc/src/modules/polys/reference.rst
doc/src/modules/polys/ringseries.rst
doc/src/modules/polys/solvers.rst
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
doc/src/modules/simplify/fu.rst
doc/src/modules/simplify/hyperexpand.rst
doc/src/modules/simplify/index.rst
doc/src/modules/simplify/simplify.rst
doc/src/modules/solvers/diophantine.rst
doc/src/modules/solvers/index.rst
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
doc/src/modules/tensor/toperators.rst
doc/src/modules/testing/index.rst
doc/src/modules/testing/pytest.rst
doc/src/modules/testing/randtest.rst
doc/src/modules/testing/runtests.rst
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
doc/src/modules/vector/vector_integration.rst
doc/src/outreach.rst
doc/src/pics/consoleascii.png
doc/src/pics/consoleunicode.png
doc/src/pics/ipythonnotebook.png
doc/src/pics/ipythonqtconsole.png
doc/src/pics/pngview1.png
doc/src/reference/index.rst
doc/src/reference/public/basics/index.rst
doc/src/reference/public/codegeneration/index.rst
doc/src/reference/public/logic/index.rst
doc/src/reference/public/matrices/index.rst
doc/src/reference/public/numbertheory/index.rst
doc/src/reference/public/physics/index.rst
doc/src/reference/public/topics/index.rst
doc/src/reference/public/utilities/index.rst
doc/src/tutorial/basic_operations.rst
doc/src/tutorial/calculus.rst
doc/src/tutorial/features.rst
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
pytest.ini
release/.gitignore
release/Dockerfile
release/README.md
release/aptinstall.sh
release/authors.py
release/build_docs.py
release/compare_tar_against_git.py
release/fabfile.py
release/github_release.py
release/helpers.py
release/pull_and_run_rever.sh
release/release.sh
release/releasecheck.py
release/requirements.txt
release/rever.xsh
release/sha256.py
release/test_install.py
release/update_docs.py
release/update_requirements.sh
setup.cfg
setup.py
setupegg.py
sympy/__init__.py
sympy/abc.py
sympy/algebras/__init__.py
sympy/algebras/quaternion.py
sympy/algebras/tests/__init__.py
sympy/algebras/tests/test_quaternion.py
sympy/assumptions/__init__.py
sympy/assumptions/ask.py
sympy/assumptions/ask_generated.py
sympy/assumptions/assume.py
sympy/assumptions/cnf.py
sympy/assumptions/facts.py
sympy/assumptions/handlers/__init__.py
sympy/assumptions/handlers/calculus.py
sympy/assumptions/handlers/common.py
sympy/assumptions/handlers/matrices.py
sympy/assumptions/handlers/ntheory.py
sympy/assumptions/handlers/order.py
sympy/assumptions/handlers/sets.py
sympy/assumptions/predicates/__init__.py
sympy/assumptions/predicates/calculus.py
sympy/assumptions/predicates/common.py
sympy/assumptions/predicates/matrices.py
sympy/assumptions/predicates/ntheory.py
sympy/assumptions/predicates/order.py
sympy/assumptions/predicates/sets.py
sympy/assumptions/refine.py
sympy/assumptions/relation/__init__.py
sympy/assumptions/relation/binrel.py
sympy/assumptions/relation/equality.py
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
sympy/assumptions/tests/test_wrapper.py
sympy/assumptions/wrapper.py
sympy/benchmarks/__init__.py
sympy/benchmarks/bench_discrete_log.py
sympy/benchmarks/bench_meijerint.py
sympy/benchmarks/bench_symbench.py
sympy/calculus/__init__.py
sympy/calculus/accumulationbounds.py
sympy/calculus/euler.py
sympy/calculus/finite_diff.py
sympy/calculus/singularities.py
sympy/calculus/tests/__init__.py
sympy/calculus/tests/test_accumulationbounds.py
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
sympy/codegen/abstract_nodes.py
sympy/codegen/algorithms.py
sympy/codegen/approximations.py
sympy/codegen/array_utils.py
sympy/codegen/ast.py
sympy/codegen/cfunctions.py
sympy/codegen/cnodes.py
sympy/codegen/cutils.py
sympy/codegen/cxxnodes.py
sympy/codegen/fnodes.py
sympy/codegen/futils.py
sympy/codegen/matrix_nodes.py
sympy/codegen/numpy_nodes.py
sympy/codegen/pynodes.py
sympy/codegen/pyutils.py
sympy/codegen/rewriting.py
sympy/codegen/scipy_nodes.py
sympy/codegen/tests/__init__.py
sympy/codegen/tests/test_algorithms.py
sympy/codegen/tests/test_applications.py
sympy/codegen/tests/test_approximations.py
sympy/codegen/tests/test_ast.py
sympy/codegen/tests/test_cfunctions.py
sympy/codegen/tests/test_cnodes.py
sympy/codegen/tests/test_cxxnodes.py
sympy/codegen/tests/test_fnodes.py
sympy/codegen/tests/test_numpy_nodes.py
sympy/codegen/tests/test_pynodes.py
sympy/codegen/tests/test_pyutils.py
sympy/codegen/tests/test_rewriting.py
sympy/codegen/tests/test_scipy_nodes.py
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
sympy/combinatorics/pc_groups.py
sympy/combinatorics/perm_groups.py
sympy/combinatorics/permutations.py
sympy/combinatorics/polyhedron.py
sympy/combinatorics/prufer.py
sympy/combinatorics/rewritingsystem.py
sympy/combinatorics/rewritingsystem_fsm.py
sympy/combinatorics/schur_number.py
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
sympy/combinatorics/tests/test_pc_groups.py
sympy/combinatorics/tests/test_perm_groups.py
sympy/combinatorics/tests/test_permutations.py
sympy/combinatorics/tests/test_polyhedron.py
sympy/combinatorics/tests/test_prufer.py
sympy/combinatorics/tests/test_rewriting.py
sympy/combinatorics/tests/test_schur_number.py
sympy/combinatorics/tests/test_subsets.py
sympy/combinatorics/tests/test_tensor_can.py
sympy/combinatorics/tests/test_testutil.py
sympy/combinatorics/tests/test_util.py
```


# The last commit

```
7efc643dee SWE-bench


```

```diff

```


# README.md (the start)

```
# SymPy

[![pypi version](https://img.shields.io/pypi/v/sympy.svg)](https://pypi.python.org/pypi/sympy)
[![Build status](https://secure.travis-ci.org/sympy/sympy.svg?branch=master)](https://travis-ci.org/sympy/sympy)
[![Join the chat at https://gitter.im/sympy/sympy](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/sympy/sympy?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Zenodo Badge](https://zenodo.org/badge/18918/sympy/sympy.svg)](https://zenodo.org/badge/latestdoi/18918/sympy/sympy)
[![codecov Badge](https://codecov.io/gh/sympy/sympy/branch/master/graph/badge.svg)](https://codecov.io/gh/sympy/sympy)

[![SymPy Banner](https://github.com/sympy/sympy/raw/master/banner.svg)](https://sympy.org/)


See the [AUTHORS](AUTHORS) file for the list of authors.

And many more people helped on the SymPy mailing list, reported bugs,
helped organize SymPy's participation in the Google Summer of Code, the
Google Highly Open Participation Contest, Google Code-In, wrote and
blogged about SymPy...

License: New BSD License (see the [LICENSE](LICENSE) file for details) covers all
files in the sympy repository unless stated otherwise.

Our mailing list is at
<https://groups.google.com/forum/?fromgroups#!forum/sympy>.

We have a community chat at [Gitter](https://gitter.im/sympy/sympy). Feel
free to ask us anything there. We have a very welcoming and helpful
community.

## Download

The recommended installation method is through Anaconda,
<https://www.anaconda.com/download/>

You can also get the latest version of SymPy from
<https://pypi.python.org/pypi/sympy/>

To get the git version do

    $ git clone https://github.com/sympy/sympy.git

For other options (tarballs, debs, etc.), see
<https://docs.sympy.org/dev/install.html>.

## Documentation and Usage

For in-depth instructions on installation and building the
documentation, see the [SymPy Documentation Style Guide](https://docs.sympy.org/dev/documentation-style-guide.html).

Everything is at:

<https://docs.sympy.org/>

You can generate everything at the above site in your local copy of
SymPy by:

    $ cd doc
    $ make html

Then the docs will be in <span class="title-ref">\_build/html</span>. If
you don't want to read that, here is a short usage:

From this directory, start Python and:

``` python
>>> from sympy import Symbol, cos
>>> x = Symbol('x')
>>> e = 1/cos(x)
>>> print(e.series(x, 0, 10))
1 + x**2/2 + 5*x**4/24 + 61*x**6/720 + 277*x**8/8064 + O(x**10)
```

SymPy also comes with a console that is a simple wrapper around the
classic python console (or IPython when available) that loads the SymPy
namespace and executes some common commands for you.

To start it, issue:

    $ bin/isympy

from this directory, if SymPy is not installed or simply:

    $ isympy

if SymPy is installed.

## Installation

SymPy has a hard dependency on the [mpmath](http://mpmath.org/) library
(version \>= 0.19). You should install it first, please refer to the
mpmath installation guide:

<https://github.com/fredrik-johansson/mpmath#1-download--installation>

To install SymPy using PyPI, run the following command:

    $ pip install sympy

To install SymPy using Anaconda, run the following command:

    $ conda install -c anaconda sympy

To install SymPy from GitHub source, first clone SymPy using `git`:

    $ git clone https://github.com/sympy/sympy.git

Then, in the `sympy` repository that you cloned, simply run:

    $ python setup.py install

See <https://docs.sympy.org/dev/install.html> for more information.

## Contributing

We welcome contributions from anyone, even if you are new to open
source. Please read our [Introduction to Contributing](https://github.com/sympy/sympy/wiki/Introduction-to-contributing)
page and the [SymPy Documentation Style Guide](https://docs.sympy.org/dev/documentation-style-guide.html). If you
are new and looking for some way to contribute, a good place to start is
to look at the issues tagged [Easy to Fix](https://github.com/sympy/sympy/issues?q=is%3Aopen+is%3Aissue+label%3A%22Easy+to+Fix%22).

Please note that all participants in this project are expected to follow
our Code of Conduct. By participating in this project you agree to abide
by its terms. See [CODE\_OF\_CONDUCT.md](CODE_OF_CONDUCT.md).

## Tests

To execute all tests, run:

    $./setup.py test

in the current directory.

For the more fine-grained running of tests or doctests, use `bin/test`
or respectively `bin/doctest`. The master branch is automatically tested
by Travis CI.

To test pull requests, use
[sympy-bot](https://github.com/sympy/sympy-bot).

## Regenerate Experimental <span class="title-ref">LaTeX</span> Parser/Lexer

The parser and lexer were generated with the [ANTLR4](http://antlr4.org)
toolchain in `sympy/parsing/latex/_antlr` and checked into the repo.
Presently, most users should not need to regenerate these files, but
if you plan to work on this feature, you will need the `antlr4`
command-line tool (and you must ensure that it is in your `PATH`).
One way to get it is:

    $ conda install -c conda-forge antlr=4.7.2

Alternatively, follow the instructions on the ANTLR website and download
the `antlr-4.7.2-complete.jar`. Then export the `CLASSPATH` as instructed
and instead of creating `antlr4` as an alias, make it an executable file
with the following contents:
``` bash
#!/bin/bash
java -jar /usr/local/lib/antlr-4.7.2-complete.jar "$@"
```

After making changes to `sympy/parsing/latex/LaTeX.g4`, run:

    $ ./setup.py antlr

## Clean

To clean everything (thus getting the same tree as in the repository):

    $ ./setup.py clean

You can also clean things with git using:

    $ git clean -Xdf

which will clear everything ignored by `.gitignore`, and:

    $ git clean -df

to clear all untracked files. You can revert the most recent changes in
git with:

    $ git reset --hard

WARNING: The above commands will all clear changes you may have made,
and you will lose them forever. Be sure to check things with `git
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
`bin/test sympy/printing/tests/test_pycode.py`

## Scope
`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`

## Done when
`pycode(Min(a, b))` returns `min(a, b)` with no “Not supported in Python” comment.
`pycode(Max(a, b))` returns `max(a, b)` with no “Not supported in Python” comment.
`PythonCodePrinter` defines `_print_Min` and `_print_Max`, each printing every `expr.args` element through `self._print`.
The printing test suite for `pycode` passes.

## Approach
Decompose into: locate `PythonCodePrinter` in `sympy/printing/pycode.py`, add `_print_Min` and `_print_Max` using the supplied `min(...)`/`max(...)` formatting, add focused tests in `sympy/printing/tests/test_pycode.py`, then run the scoped test command.

Candidate approaches:
1. Add the two methods directly to `PythonCodePrinter` as proposed. This is the smallest change and matches the prompt exactly.
2. Add the methods to a shared base printer if one exists, so other Python-like printers inherit them. Tradeoff: broader behavior change than requested and may affect unrelated printers.
3. Implement through a generic function-printing hook or `_known_functions` mapping. Tradeoff: more indirection and less explicit than the requested `_print_Min`/`_print_Max` methods.

Prefer approach 1; fall back to checking whether `Min`/`Max` are already handled by a parent printer or need to be added to a subclass only if the scoped tests show dispatch is not reaching `PythonCodePrinter`.
```

### `prompt.md`

````
PythonCodePrinter doesn't support Min and Max
We can't generate python code for the sympy function Min and Max.

For example:
```
from sympy import symbols, Min, pycode
a, b = symbols("a b")
c = Min(a,b)
print(pycode(c))
```
the output is:

```
  # Not supported in Python:
  # Min
Min(a, b)
```

Similar to issue #16669, we should add following methods to PythonCodePrinter:

```
def _print_Min(self, expr):
    return "min({})".format(", ".join(self._print(arg) for arg in expr.args))


def _print_Max(self, expr):
    return "max({})".format(", ".join(self._print(arg) for arg in expr.args))

```
````

### `review.md`

```
verdict: PASS
- The diff adds `_print_Min` and `_print_Max` to `PythonCodePrinter`, each printing every `expr.args` element through `self._print`, matching the requested implementation.
- This makes `pycode(Min(a, b))` return `min(a, b)` and `pycode(Max(a, b))` return `max(a, b)` without the “Not supported in Python” comment.
- Tests were added in `sympy/printing/tests/test_pycode.py`; the check output reports 19 passed, 2 skipped, with check status 0.
- Only the scoped files were changed, and no unrelated behavior or content was removed.
```

### `scope.txt`

```
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py
changed: sympy/printing/pycode.py +6 -0
changed: sympy/printing/tests/test_pycode.py +3 -1
```

### `task.md`

````
# Task

## Prompt

PythonCodePrinter doesn't support Min and Max
We can't generate python code for the sympy function Min and Max.

For example:
```
from sympy import symbols, Min, pycode
a, b = symbols("a b")
c = Min(a,b)
print(pycode(c))
```
the output is:

```
  # Not supported in Python:
  # Min
Min(a, b)
```

Similar to issue #16669, we should add following methods to PythonCodePrinter:

```
def _print_Min(self, expr):
    return "min({})".format(", ".join(self._print(arg) for arg in expr.args))


def _print_Max(self, expr):
    return "max({})".format(", ".join(self._print(arg) for arg in expr.args))

```

## Deliverable

changes to this tree

## Check

`bin/test sympy/printing/tests/test_pycode.py`

## Scope

`sympy/printing/pycode.py`
`sympy/printing/tests/test_pycode.py`

## Done when

`pycode(Min(a, b))` returns `min(a, b)` with no “Not supported in Python” comment.
`pycode(Max(a, b))` returns `max(a, b)` with no “Not supported in Python” comment.
`PythonCodePrinter` defines `_print_Min` and `_print_Max`, each printing every `expr.args` element through `self._print`.
The printing test suite for `pycode` passes.
````

### `test-output.log`

```
check: bin/test sympy/printing/tests/test_pycode.py
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.20-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        19583494
hash randomization: on (PYTHONHASHSEED=710611392)

sympy/printing/tests/test_pycode.py[21] ....s..s.............               [OK]

============ tests finished: 19 passed, 2 skipped, in 0.10 seconds =============
scope: sympy/printing/pycode.py sympy/printing/tests/test_pycode.py
changed: sympy/printing/pycode.py +6 -0
changed: sympy/printing/tests/test_pycode.py +3 -1
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
