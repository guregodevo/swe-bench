# Survey: Mod lambdify bug (`expr * Mod(a, b)` printed as `Mod(expr * a, b)` with `modules=[]`)

## The public API the issue names

- `sympy/utilities/lambdify.py:lambdify` — the public entry point; with `modules=[]` it builds an empty namespace, falls through every `_module_present` branch and selects the plain `PythonCodePrinter`, which is what produces the bad `-x % y` source.
- `sympy/utilities/lambdify.py:_module_present` — decides which printer `lambdify` picks; an empty `modules` list matches nothing, so the `else` branch (plain `PythonCodePrinter`) is taken.
- `sympy/utilities/lambdify.py:_get_namespace` — turns each entry of `modules` into a namespace dict; with `modules=[]` it contributes nothing, so no `mod` function is available and the printer must fall back to the `%` operator.
- `sympy/utilities/lambdify.py:_EvaluatorPrinter.doprint` — assembles the generated `def _lambdifygenerated(...)` body by calling the selected printer's `doprint` on the expression, so the printer's `_print_Mod`/`_print_Mul` output becomes the returned source.
- `sympy/utilities/lambdify.py:lambdastr` — the older string-producing sibling of `lambdify`; it also routes through `lambdarepr`/`LambdaPrinter` and therefore emits the same `%`-based Mod text.
- `sympy/core/mod.py:Mod` — the `Mod` class itself; its `eval` can pull a coefficient out of the dividend (`Mod(.6*x, .3*y) -> 0.3*Mod(2*x, y)`), which is why the expression reaching the printer is a `Mul` of a coefficient and a `Mod`.

## The printer that actually formats the bad output

- `sympy/printing/pycode.py:AbstractPythonCodePrinter._print_Mod` — the root cause: it formats `Mod` as `'{} % {}'` using `precedence(expr)` for both arguments, and because `Mod` has no precedence entry it is treated as an atom, so a negative multiplier is not parenthesized and `-Mod(x, y)` becomes `-x % y`.
- `sympy/printing/pycode.py:PythonCodePrinter` — the concrete printer `lambdify(..., modules=[])` instantiates; it inherits `_print_Mod` unchanged, so the plain-Python path is the one that misprints.
- `sympy/printing/pycode.py:PythonCodePrinter._print_frac` — a sibling that reuses `_print_Mod` (`Mod(arg, 1)`) and so inherits the same precedence/parenthesization weakness.
- `sympy/printing/pycode.py:pycode` — the public `pycode()` function; it uses `PythonCodePrinter` directly and therefore reproduces the same `-x % y` output outside lambdify.
- `sympy/printing/lambdarepr.py:LambdaPrinter` — the printer historically used for lambdify; it subclasses `PythonCodePrinter` and inherits the same `_print_Mod`.
- `sympy/printing/lambdarepr.py:lambdarepr` — the public helper that prints via `LambdaPrinter`, another entry point to the same `%` formatting.
- `sympy/printing/lambdarepr.py:NumExprPrinter` — a parallel lambda printer; it inherits `_print_Mod` from `LambdaPrinter`/`PythonCodePrinter` and so formats Mod the same way.
- `sympy/printing/precedence.py:precedence` — returns the precedence used by `_print_Mod`; `Mod` is absent from `PRECEDENCE_VALUES`, so it falls through to `PRECEDENCE["Atom"]` and the multiplier is never parenthesized.
- `sympy/printing/precedence.py:PRECEDENCE_VALUES` — the table that lacks a `"Mod"` entry; adding one (as upstream did) is what makes `Mod` bind like `Mul` and fixes the parenthesization.
- `sympy/printing/precedence.py:precedence_Mul` — computes `Mul` precedence and returns `Add` precedence for a negative coefficient, which is why `-Mod(x, y)` is a `Mul` with a negative leading coefficient that needs parentheses.
- `sympy/printing/codeprinter.py:CodePrinter._print_Mul` — prints the enclosing `Mul`; it emits a bare `-` sign plus the parenthesized factors, and with `Mod` at atom precedence the factor is not wrapped, yielding `-x % y`.
- `sympy/printing/codeprinter.py:CodePrinter` — the shared base for all code printers; its `_print_Mul`/`parenthesize` behavior is what every language printer below inherits.
- `sympy/printing/str.py:StrPrinter.parenthesize` — the parenthesization rule (`precedence(item) < level`) used by code printers; a `Mod` at atom precedence is never parenthesized at `Mul` level.

## Sibling printers that format Mod the same way or a parallel way

- `sympy/printing/numpy.py:NumPyPrinter._print_Mod` — the NumPy sibling; it emits `numpy.mod(a, b)` instead of `%`, so it is immune to the operator-precedence bug and is the behavior the default `lambdify` path gets.
- `sympy/printing/numpy.py:SciPyPrinter` — inherits `NumPyPrinter._print_Mod`, so the SciPy lambdify path also uses `numpy.mod`.
- `sympy/printing/numpy.py:CuPyPrinter` — inherits `NumPyPrinter._print_Mod`, using `cupy.mod`.
- `sympy/printing/c.py:C89CodePrinter._print_Mod` — the C sibling; it prints `((num) % (den))` for integers and `fmod(...)` otherwise, always parenthesizing both operands.
- `sympy/printing/c.py:C99CodePrinter` — inherits the C `_print_Mod` and `_print_Mul` behavior.
- `sympy/printing/c.py:C11CodePrinter` — inherits the same C `_print_Mod`.
- `sympy/printing/cxx.py:_CXXCodePrinterBase` — maps `Mod` to `fmod` for C++ and inherits the C printer's Mod handling.
- `sympy/printing/cxx.py:CXX98CodePrinter` — inherits `C89CodePrinter._print_Mod`/`_print_Mul`.
- `sympy/printing/cxx.py:CXX11CodePrinter` — inherits `C99CodePrinter._print_Mod`/`_print_Mul`.
- `sympy/printing/cxx.py:CXX17CodePrinter` — inherits `C99CodePrinter._print_Mod`/`_print_Mul`.
- `sympy/printing/fortran.py:FCodePrinter._print_Mod` — the Fortran sibling; it emits `modulo(x, y)` (or raises for F66/F77), avoiding the `%` precedence issue.
- `sympy/printing/fortran.py:FCodePrinter._print_Mul` — the Fortran `Mul` printer, a parallel implementation of the same sign/parenthesization logic.
- `sympy/printing/octave.py:OctaveCodePrinter` — maps `Mod` to the `mod` function via its known-functions table, so it does not use `%`.
- `sympy/printing/octave.py:OctaveCodePrinter._print_Mul` — Octave's own `Mul` printer, a sibling of the code-printer `_print_Mul`.
- `sympy/printing/julia.py:JuliaCodePrinter._print_Mul` — Julia's `Mul` printer, another parallel implementation of the same sign/parenthesization logic.
- `sympy/printing/glsl.py:GLSLPrinter._print_Mul` — GLSL's `Mul` printer, delegating to `CodePrinter._print_Mul` for the general case.
- `sympy/printing/rust.py:RustCodePrinter` — Rust printer with its own `_print_Pow` but no `_print_Mod`, so `Mod` falls back to `CodePrinter._print_Function`/`_print_not_supported`.
- `sympy/printing/jscode.py:JavascriptCodePrinter` — JavaScript printer with its own `_print_Pow` but no `_print_Mod`, so `Mod` falls back to the generic function printer.
- `sympy/printing/tensorflow.py:TensorflowPrinter` — subclasses `AbstractPythonCodePrinter` and inherits the same `_print_Mod`/`_print_Mul` behavior for the TensorFlow lambdify path.
- `sympy/printing/pycode.py:MpmathPrinter` — subclasses `PythonCodePrinter` and inherits `_print_Mod`, so the mpmath lambdify path also uses `%`.
- `sympy/printing/pycode.py:SymPyPrinter` — subclasses `AbstractPythonCodePrinter` and inherits `_print_Mod`, so the `sympy`-module lambdify path also uses `%`.

## Other printers that render Mod (parallel formatting, not the bug)

- `sympy/printing/str.py:StrPrinter._print_Mul` — the string printer's `Mul` implementation, the model the code printers' `_print_Mul` copies.
- `sympy/printing/pretty/pretty.py:PrettyPrinter._print_Mod` — pretty-prints `a mod b` and explicitly parenthesizes the dividend when its binding is above `MUL`.
- `sympy/printing/latex.py:LatexPrinter._print_Mod` — LaTeX sibling; it parenthesizes the dividend with `PRECEDENCE['Mul']` and `strict=True`.
- `sympy/printing/latex.py:LatexPrinter._print_frac` — LaTeX's `frac` printer, a parallel of the Python `_print_frac` that does not reuse `_print_Mod`.
