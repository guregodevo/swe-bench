# sympy__sympy-15349 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 270s 42 lines cost=0.014847 in=228492 cached=168448 out=32130 calls=21`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Incorrect result with Quaterniont.to_rotation_matrix()
https://github.com/sympy/sympy/blob/ab14b02dba5a7e3e4fb1e807fc8a954f1047a1a1/sympy/algebras/quaternion.py#L489

There appears to be an error in the `Quaternion.to_rotation_matrix()` output.  The simplest example I created to illustrate the problem is as follows:

```
>>import sympy
>>print('Sympy version: ', sympy.__version__)
Sympy version: 1.2

>> from sympy import *
>> x = symbols('x')
>> q = Quaternion(cos(x/2), sin(x/2), 0, 0)
>> trigsimp(q.to_rotation_matrix())
Matrix([
[1,      0,      0],
[0, cos(x), sin(x)],
[0, sin(x), cos(x)]])
```
One of the `sin(x)` functions should be negative.  What was the reference of the original equations?


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && git log --oneline -1 && sed -n '440,560p' sympy/algebras/quaternion.py"
}
```

**tool result**

```
/testbed
4058a6420 SWE-bench
        """
        if isinstance(r, tuple):
            # if r is of the form (vector, angle)
            q = Quaternion.from_axis_angle(r[0], r[1])
        else:
            # if r is a quaternion
            q = r.normalize()
        pout = q * Quaternion(0, pin[0], pin[1], pin[2]) * conjugate(q)
        return (pout.b, pout.c, pout.d)

    def to_axis_angle(self):
        """Returns the axis and angle of rotation of a quaternion

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> q = Quaternion(1, 1, 1, 1)
        >>> (axis, angle) = q.to_axis_angle()
        >>> axis
        (sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        >>> angle
        2*pi/3
        """
        q = self
        try:
            # Skips it if it doesn't know whether q.a is negative
            if q.a < 0:
                # avoid error with acos
                # axis and angle of rotation of q and q*-1 will be the same
                q = q * -1
        except BaseException:
            pass

        q = q.normalize()
        angle = trigsimp(2 * acos(q.a))

        # Since quaternion is normalised, q.a is less than 1.
        s = sqrt(1 - q.a*q.a)

        x = trigsimp(q.b / s)
        y = trigsimp(q.c / s)
        z = trigsimp(q.d / s)

        v = (x, y, z)
        t = (v, angle)

        return t

    def to_rotation_matrix(self, v=None):
        """Returns the equivalent rotation transformation matrix of the quaternion
        which represents rotation about the origin if v is not passed.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols, trigsimp, cos, sin
        >>> x = symbols('x')
        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
        >>> trigsimp(q.to_rotation_matrix())
        Matrix([
        [cos(x), -sin(x), 0],
        [sin(x),  cos(x), 0],
        [     0,       0, 1]])

        Generates a 4x4 transformation matrix (used for rotation about a point
        other than the origin) if the point(v) is passed as an argument.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols, trigsimp, cos, sin
        >>> x = symbols('x')
        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
        >>> trigsimp(q.to_rotation_matrix((1, 1, 1)))
         Matrix([
        [cos(x), -sin(x), 0,  sin(x) - cos(x) + 1],
        [sin(x),  cos(x), 0, -sin(x) - cos(x) + 1],
        [     0,       0, 1,                    0],
        [     0,       0, 0,                    1]])
        """

        q = self
        s = q.norm()**-2
        m00 = 1 - 2*s*(q.c**2 + q.d**2)
        m01 = 2*s*(q.b*q.c - q.d*q.a)
        m02 = 2*s*(q.b*q.d + q.c*q.a)

        m10 = 2*s*(q.b*q.c + q.d*q.a)
        m11 = 1 - 2*s*(q.b**2 + q.d**2)
        m12 = 2*s*(q.c*q.d + q.b*q.a)

        m20 = 2*s*(q.b*q.d - q.c*q.a)
        m21 = 2*s*(q.c*q.d + q.b*q.a)
        m22 = 1 - 2*s*(q.b**2 + q.c**2)

        if not v:
            return Matrix([[m00, m01, m02], [m10, m11, m12], [m20, m21, m22]])

        else:
            (x, y, z) = v

            m03 = x - x*m00 - y*m01 - z*m02
            m13 = y - x*m10 - y*m11 - z*m12
            m23 = z - x*m20 - y*m21 - z*m22
            m30 = m31 = m32 = 0
            m33 = 1

            return Matrix([[m00, m01, m02, m03], [m10, m11, m12, m13],
                          [m20, m21, m22, m23], [m30, m31, m32, m33]])
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"to_rotation_matrix\\|m12\\|m21\" sympy/algebras/tests/test_quaternion.py | head -50 && sed -n '1,80p' sympy/algebras/quaternion.py"
}
```

**tool result**

```
98:    assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
102:    assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
110:    assert trigsimp(q2.to_rotation_matrix()) == Matrix([
118:    assert trigsimp(q2.to_rotation_matrix((1, 1, 1))) == Matrix([
# References :
# http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/
# https://en.wikipedia.org/wiki/Quaternion
from __future__ import print_function

from sympy.core.expr import Expr
from sympy import Rational
from sympy import re, im, conjugate
from sympy import sqrt, sin, cos, acos, asin, exp, ln
from sympy import trigsimp
from sympy import diff, integrate
from sympy import Matrix, Add, Mul
from sympy import symbols, sympify
from sympy.printing.latex import latex
from sympy.printing import StrPrinter
from sympy.core.numbers import Integer
from sympy.core.compatibility import SYMPY_INTS


class Quaternion(Expr):
    """Provides basic quaternion operations.
    Quaternion objects can be instantiated as Quaternion(a, b, c, d)
    as in (a + b*i + c*j + d*k).

    Example
    ========

    >>> from sympy.algebras.quaternion import Quaternion
    >>> q = Quaternion(1, 2, 3, 4)
    >>> q
    1 + 2*i + 3*j + 4*k

    Quaternions over complex fields can be defined as :
    ========
    >>> from sympy.algebras.quaternion import Quaternion
    >>> from sympy import symbols, I
    >>> x = symbols('x')
    >>> q1 = Quaternion(x, x**3, x, x**2, real_field = False)
    >>> q2 = Quaternion(3 + 4*I, 2 + 5*I, 0, 7 + 8*I, real_field = False)
    >>> q1
    x + x**3*i + x*j + x**2*k
    >>> q2
    (3 + 4*I) + (2 + 5*I)*i + 0*j + (7 + 8*I)*k
    """
    _op_priority = 11.0

    is_commutative = False

    def __new__(cls, a=0, b=0, c=0, d=0, real_field=True):
        a = sympify(a)
        b = sympify(b)
        c = sympify(c)
        d = sympify(d)

        if any(i.is_commutative is False for i in [a, b, c, d]):
            raise ValueError("arguments have to be commutative")
        else:
            obj = Expr.__new__(cls, a, b, c, d)
            obj._a = a
            obj._b = b
            obj._c = c
            obj._d = d
            obj._real_field = real_field
            return obj

    @property
    def a(self):
        return self._a

    @property
    def b(self):
        return self._b

    @property
    def c(self):
        return self._c

    @property
    def d(self):
        return self._d
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '85,135p' sympy/algebras/tests/test_quaternion.py"
}
```

**tool result**

```
    Quaternion(x**2 / 2, x**2 / 2, x**2 / 2, x**2 / 2)

    assert Quaternion.rotate_point((1, 1, 1), q1) == (1 / 5, 1, 7 / 5)


def test_quaternion_conversions():
    q1 = Quaternion(1, 2, 3, 4)

    assert q1.to_axis_angle() == ((2 * sqrt(29)/29,
                                   3 * sqrt(29)/29,
                                   4 * sqrt(29)/29),
                                   2 * acos(sqrt(30)/30))

    assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
                                     [S(2)/3, -S(1)/3, S(14)/15],
                                     [S(1)/3, S(14)/15, S(2)/15]])

    assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
                                                  [S(2)/3, -S(1)/3, S(14)/15, -S(4)/15],
                                                  [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
                                                  [S(0), S(0), S(0), S(1)]])

    theta = symbols("theta", real=True)
    q2 = Quaternion(cos(theta/2), 0, 0, sin(theta/2))

    assert trigsimp(q2.to_rotation_matrix()) == Matrix([
                                               [cos(theta), -sin(theta), 0],
                                               [sin(theta),  cos(theta), 0],
                                               [0,           0,          1]])

    assert q2.to_axis_angle() == ((0, 0, sin(theta/2)/Abs(sin(theta/2))),
                                   2*acos(cos(theta/2)))

    assert trigsimp(q2.to_rotation_matrix((1, 1, 1))) == Matrix([
               [cos(theta), -sin(theta), 0, sin(theta) - cos(theta) + 1],
               [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],
               [0,           0,          1,  0],
               [0,           0,          0,  1]])
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/algebras/quaternion.py\n@@\n-        m12 = 2*s*(q.c*q.d + q.b*q.a)\n+        m12 = 2*s*(q.c*q.d - q.b*q.a)\n*** Update File: sympy/algebras/tests/test_quaternion.py\n@@\n-    assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],\n-                                     [S(2)/3, -S(1)/3, S(14)/15],\n+    assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],\n+                                     [S(2)/3, -S(1)/3, S(14)/15],\n                                      [S(1)/3, S(14)/15, S(2)/15]])\n \n     assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],\n-                                                  [S(2)/3, -S(1)/3, S(14)/15, -S(4)/15],\n+                                                  [S(2)/3, -S(1)/3, S(14)/15, S(0)],\n                                                   [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],\n                                                   [S(0), S(0), S(0), S(1)]])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/algebras/quaternion.py sympy/algebras/tests/test_quaternion.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/algebras/quaternion.py now (551 lines), around the change:
529:
530:        m10 = 2*s*(q.b*q.c + q.d*q.a)
531:        m11 = 1 - 2*s*(q.b**2 + q.d**2)
532:        m12 = 2*s*(q.c*q.d - q.b*q.a)
533:
534:        m20 = 2*s*(q.b*q.d - q.c*q.a)
535:        m21 = 2*s*(q.c*q.d + q.b*q.a)

sympy/algebras/tests/test_quaternion.py now (122 lines), around the change:
100:                                     [S(1)/3, S(14)/15, S(2)/15]])
101:
102:    assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
103:                                                  [S(2)/3, -S(1)/3, S(14)/15, S(0)],
104:                                                  [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
105:                                                  [S(0), S(0), S(0), S(1)]])
106:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/algebras/tests/test_quaternion.py\n@@\n     assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],\n-                                     [S(2)/3, -S(1)/3, S(14)/15],\n+                                     [S(2)/3, -S(1)/3, S(2)/3],\n                                      [S(1)/3, S(14)/15, S(2)/15]])\n \n     assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],\n-                                                  [S(2)/3, -S(1)/3, S(14)/15, S(0)],\n+                                                  [S(2)/3, -S(1)/3, S(2)/3, S(0)],\n                                                   [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],\n                                                   [S(0), S(0), S(0), S(1)]])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/algebras/tests/test_quaternion.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/algebras/tests/test_quaternion.py now (122 lines), around the change:
96:                                   2 * acos(sqrt(30)/30))
97:
98:    assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
99:                                     [S(2)/3, -S(1)/3, S(2)/3],
100:                                     [S(1)/3, S(14)/15, S(2)/15]])
101:
102:    assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
103:                                                  [S(2)/3, -S(1)/3, S(2)/3, S(0)],
104:                                                  [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
105:                                                  [S(0), S(0), S(0), S(1)]])
106:
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sympy/algebras/tests/test_quaternion.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nfrom sympy import *\nfrom sympy.algebras.quaternion import Quaternion\nx=symbols('x')\nq=Quaternion(cos(x/2),sin(x/2),0,0)\nprint(trigsimp(q.to_rotation_matrix()))\nq1=Quaternion(1,2,3,4)\nprint(q1.to_rotation_matrix())\nprint(q1.to_rotation_matrix((1,1,1)))\n\" && python bin/test sympy/algebras/tests/test_quaternion.py 2>&1 | tail -20"
}
```

**tool result**

```
/testbed/sympy/solvers/diophantine.py:3188: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if feasible is 1:  # it's prime and k == 2
Matrix([[1, 0, 0], [0, cos(x), -sin(x)], [0, sin(x), cos(x)]])
Matrix([[-2/3, 2/15, 11/15], [2/3, -1/3, 2/3], [1/3, 14/15, 2/15]])
Matrix([[-2/3, 2/15, 11/15, 4/5], [2/3, -1/3, 2/3, 0], [1/3, 14/15, 2/15, -2/5], [0, 0, 0, 1]])
============================= test process starts ==============================
executable:         /opt/miniconda3/envs/testbed/bin/python  (3.9.20-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
random seed:        38818331
hash randomization: on (PYTHONHASHSEED=1047969818)

sympy/algebras/tests/test_quaternion.py[4] ....                             [OK]

================== tests finished: 4 passed, in 0.44 seconds ===================
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sympy/algebras/tests/test_quaternion.py\n@@\n     assert trigsimp(q2.to_rotation_matrix((1, 1, 1))) == Matrix([\n                [cos(theta), -sin(theta), 0, sin(theta) - cos(theta) + 1],\n                [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],\n                [0,           0,          1,  0],\n                [0,           0,          0,  1]])\n+\n+    # rotation about the x-axis: the (1, 2) entry must be -sin(theta)\n+    q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)\n+    assert trigsimp(q3.to_rotation_matrix()) == Matrix([\n+               [1, 0,           0],\n+               [0, cos(theta), -sin(theta)],\n+               [0, sin(theta),  cos(theta)]])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sympy/algebras/tests/test_quaternion.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sympy/algebras/tests/test_quaternion.py now (129 lines), around the change:
120:               [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],
121:               [0,           0,          1,  0],
122:               [0,           0,          0,  1]])
123:
124:    # rotation about the x-axis: the (1, 2) entry must be -sin(theta)
125:    q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)
126:    assert trigsimp(q3.to_rotation_matrix()) == Matrix([
127:               [1, 0,           0],
128:               [0, cos(theta), -sin(theta)],
129:               [0, sin(theta),  cos(theta)]])
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/test sympy/algebras/tests/test_quaternion.py 2>&1 | tail -8"
}
```

**tool result**

```
ground types:       python 
numpy:              None
random seed:        13129792
hash randomization: on (PYTHONHASHSEED=2738185338)

sympy/algebras/tests/test_quaternion.py[4] ....                             [OK]

================== tests finished: 4 passed, in 0.45 seconds ===================
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -- sympy/algebras/quaternion.py | head -20 && git diff --stat && git diff"
}
```

**tool result**

```
3ae19fcb0 pep8
0eea46a2c Merge pull request #13745 from ArighnaIITG/13688_issue
224b6dfde Removed int
0e9be3a5a Added isinstance check
31579e944 Added NotImplemented
d1993f18f Modified code
30a902bb6 Modified Code for computing negative power of a quaternion
286f43b29 Code for computing negative power of a quaternion
c7b36de84 tests improved for test_quaternion and added test for inverse of zero quaternion
ae56fc5ee Throws Value Error for inverse of Quaternion(0,0,0,0)
ebfa6f2fb fix tests for quaternions
da649c69c quaternion: Add more tests related to matrix and axis/angle conversion
5dd1ddc7e Minor changes
97e01f875 Small change
0fc357cd1 Fixed to_rotation_matrix and changed doctests and tests
9483ba7ce Small fix
ac415d113 Added docstrings for complex field examples
e69d0ecba Small fix
b82265da8 Changed add and mul for quaternions over complex fields
4aea0b731 Changed addition for quaternions with complex elements
 sympy/algebras/quaternion.py            |  2 +-
 sympy/algebras/tests/test_quaternion.py | 11 +++++++++--
 2 files changed, 10 insertions(+), 3 deletions(-)
diff --git a/sympy/algebras/quaternion.py b/sympy/algebras/quaternion.py
index b84e7cb95..7eae8d73d 100644
--- a/sympy/algebras/quaternion.py
+++ b/sympy/algebras/quaternion.py
@@ -529,7 +529,7 @@ def to_rotation_matrix(self, v=None):
 
         m10 = 2*s*(q.b*q.c + q.d*q.a)
         m11 = 1 - 2*s*(q.b**2 + q.d**2)
-        m12 = 2*s*(q.c*q.d + q.b*q.a)
+        m12 = 2*s*(q.c*q.d - q.b*q.a)
 
         m20 = 2*s*(q.b*q.d - q.c*q.a)
         m21 = 2*s*(q.c*q.d + q.b*q.a)
diff --git a/sympy/algebras/tests/test_quaternion.py b/sympy/algebras/tests/test_quaternion.py
index 420e9976d..d19afa95c 100644
--- a/sympy/algebras/tests/test_quaternion.py
+++ b/sympy/algebras/tests/test_quaternion.py
@@ -96,11 +96,11 @@ def test_quaternion_conversions():
                                    2 * acos(sqrt(30)/30))
 
     assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
-                                     [S(2)/3, -S(1)/3, S(14)/15],
+                                     [S(2)/3, -S(1)/3, S(2)/3],
                                      [S(1)/3, S(14)/15, S(2)/15]])
 
     assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
-                                                  [S(2)/3, -S(1)/3, S(14)/15, -S(4)/15],
+                                                  [S(2)/3, -S(1)/3, S(2)/3, S(0)],
                                                   [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
                                                   [S(0), S(0), S(0), S(1)]])
 
@@ -120,3 +120,10 @@ def test_quaternion_conversions():
                [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],
                [0,           0,          1,  0],
                [0,           0,          0,  1]])
+
+    # rotation about the x-axis: the (1, 2) entry must be -sin(theta)
+    q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)
+    assert trigsimp(q3.to_rotation_matrix()) == Matrix([
+               [1, 0,           0],
+               [0, cos(theta), -sin(theta)],
+               [0, sin(theta),  cos(theta)]])
```

**assistant → tool `bash`**

```json
{
  "command": "git show 0fc357cd1 --stat && git show 0fc357cd1 -- sympy/algebras/quaternion.py | head -120"
}
```

**tool result**

```
commit 0fc357cd1742a8ad1514ecd7024342998bba7e6a
Author: Nikhil Pappu <nkhlpappu@gmail.com>
Date:   Fri Sep 15 18:47:20 2017 -0500

    Fixed to_rotation_matrix and changed doctests and tests

 sympy/algebras/quaternion.py            | 188 ++++++++++++++------------------
 sympy/algebras/tests/test_quaternion.py |  35 +++---
 2 files changed, 97 insertions(+), 126 deletions(-)
commit 0fc357cd1742a8ad1514ecd7024342998bba7e6a
Author: Nikhil Pappu <nkhlpappu@gmail.com>
Date:   Fri Sep 15 18:47:20 2017 -0500

    Fixed to_rotation_matrix and changed doctests and tests

diff --git a/sympy/algebras/quaternion.py b/sympy/algebras/quaternion.py
index 80114e3a4..61e3f59a6 100644
--- a/sympy/algebras/quaternion.py
+++ b/sympy/algebras/quaternion.py
@@ -13,6 +13,7 @@
 from sympy import symbols, sympify
 from sympy.printing.latex import latex
 from sympy.printing import StrPrinter
+from sympy import simplify
 
 
 class Quaternion(Expr):
@@ -88,9 +89,10 @@ def from_axis_angle(cls, vector, angle):
         ========
 
         >>> from sympy.algebras.quaternion import Quaternion
-        >>> q = Quaternion.from_axis_angle((2, 4, 6), 2)
+        >>> from sympy import pi, sqrt
+        >>> q = Quaternion.from_axis_angle((sqrt(3)/3, sqrt(3)/3, sqrt(3)/3), 2*pi/3)
         >>> q
-        cos(1) + sqrt(14)*sin(1)/14*i + sqrt(14)*sin(1)/7*j + 3*sqrt(14)*sin(1)/14*k
+        1/2 + 1/2*i + 1/2*j + 1/2*k
         """
         (x, y, z) = vector
         norm = sqrt(x**2 + y**2 + z**2)
@@ -101,7 +103,7 @@ def from_axis_angle(cls, vector, angle):
         c = y * s
         d = z * s
 
-        return cls(a, b, c, d)
+        return cls(a, b, c, d).normalize()
 
     @classmethod
     def from_matrix(cls, M):
@@ -112,27 +114,28 @@ def from_matrix(cls, M):
         ========
 
         >>> from sympy.algebras.quaternion import Quaternion
-        >>> from sympy import Matrix
-        >>> M = Matrix([[4, 6, 2], [1, 8, 6], [5, 2, 7]])
-        >>> q = Quaternion.from_matrix(M)
+        >>> from sympy import Matrix, symbols, cos, sin, trigsimp
+        >>> x = symbols('x')
+        >>> M = Matrix([[cos(x), -sin(x), 0], [sin(x), cos(x), 0], [0, 0, 1]])
+        >>> q = trigsimp(Quaternion.from_matrix(M))
         >>> q
-        sqrt(238**(1/3) + 19)/2
-        + 0*i
-        + (-sqrt(-3 + 238**(1/3))/2)*j
-        + (-sqrt(-5 + 238**(1/3))/2)*k
+        sqrt(2)*sqrt(cos(x) + 1)/2 + 0*i + 0*j + sqrt(-2*cos(x) + 2)/2*k
         """
 
         absQ = M.det()**Rational(1, 3)
-        # The max( 0, ... ) is just a safeguard against rounding error.
 
-        a = sqrt(max(0, absQ + M[0, 0] + M[1, 1] + M[2, 2])) / 2
-        b = sqrt(max(0, absQ + M[0, 0] - M[1, 1] - M[2, 2])) / 2
-        c = sqrt(max(0, absQ - M[0, 0] + M[1, 1] - M[2, 2])) / 2
-        d = sqrt(max(0, absQ - M[0, 0] - M[1, 1] + M[2, 2])) / 2
+        a = sqrt(absQ + M[0, 0] + M[1, 1] + M[2, 2]) / 2
+        b = sqrt(absQ + M[0, 0] - M[1, 1] - M[2, 2]) / 2
+        c = sqrt(absQ - M[0, 0] + M[1, 1] - M[2, 2]) / 2
+        d = sqrt(absQ - M[0, 0] - M[1, 1] + M[2, 2]) / 2
 
-        b = Quaternion.__copysign(b, M[2, 1] - M[1, 2])
-        c = Quaternion.__copysign(c, M[0, 2] - M[2, 0])
-        d = Quaternion.__copysign(d, M[1, 0] - M[0, 1])
+        try:
+            b = Quaternion.__copysign(b, M[2, 1] - M[1, 2])
+            c = Quaternion.__copysign(c, M[0, 2] - M[2, 0])
+            d = Quaternion.__copysign(d, M[1, 0] - M[0, 1])
+
+        except Exception:
+            pass
 
         return Quaternion(a, b, c, d)
 
@@ -416,12 +419,14 @@ def rotate(pin, r):
         ========
 
         >>> from sympy.algebras.quaternion import Quaternion
-        >>> q = Quaternion(1, 2, 3, 4)
-        >>> Quaternion.rotate((1, 2, 4), q)
-        (38/15, 8/3, 41/15)
+        >>> from sympy import symbols, trigsimp, cos, sin
+        >>> x = symbols('x')
+        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
+        >>> trigsimp(Quaternion.rotate((1, 1, 1), q))
+        (sqrt(2)*cos(x + pi/4), sqrt(2)*sin(x + pi/4), 1)
         >>> (axis, angle) = q.to_axis_angle()
-        >>> Quaternion.rotate((1, 2, 4), (axis, angle))
-        (38/15, 8/3, 41/15)
+        >>> trigsimp(Quaternion.rotate((1, 1, 1), (axis, angle)))
+        (sqrt(2)*cos(x + pi/4), sqrt(2)*sin(x + pi/4), 1)
         """
         if isinstance(r, tuple):
             # if r is of the form (vector, angle)
@@ -439,12 +444,12 @@ def to_axis_angle(self):
         ========
 
         >>> from sympy.algebras.quaternion import Quaternion
-        >>> q = Quaternion(1, 2, 3, 4)
+        >>> q = Quaternion(1, 1, 1, 1)
         >>> (axis, angle) = q.to_axis_angle()
         >>> axis
-        (2*sqrt(29)/29, 3*sqrt(29)/29, 4*sqrt(29)/29)
+        (sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
         >>> angle
-        2*acos(sqrt(30)/30)
+        2*pi/3
         """
         q = self
         try:
```

**assistant → tool `bash`**

```json
{
  "command": "git log -S'm12 = 2*s*(q.c*q.d + q.b*q.a)' --oneline --all -- sympy/algebras/quaternion.py && git log -S'to_rotation_matrix' --oneline --all -- sympy/algebras/quaternion.py | tail -20"
}
```

**tool result**

```
0fc357cd1 Fixed to_rotation_matrix and changed doctests and tests
0fc357cd1 Fixed to_rotation_matrix and changed doctests and tests
```

**assistant → tool `bash`**

```json
{
  "command": "git show 0fc357cd1 -- sympy/algebras/quaternion.py | sed -n '/to_rotation_matrix/,/def /p' | head -140"
}
```

**tool result**

```
    Fixed to_rotation_matrix and changed doctests and tests

diff --git a/sympy/algebras/quaternion.py b/sympy/algebras/quaternion.py
index 80114e3a4..61e3f59a6 100644
--- a/sympy/algebras/quaternion.py
+++ b/sympy/algebras/quaternion.py
@@ -13,6 +13,7 @@
 from sympy import symbols, sympify
 from sympy.printing.latex import latex
 from sympy.printing import StrPrinter
+from sympy import simplify
 
 
 class Quaternion(Expr):
@@ -88,9 +89,10 @@ def from_axis_angle(cls, vector, angle):
+    def to_rotation_matrix(self, v = None):
+        """Returns the equivalent rotation transformation matrix of the quaternion
+        which represenets rotation about the origin if v is not passed.
 
         Example
         ========
 
         >>> from sympy.algebras.quaternion import Quaternion
-        >>> q = Quaternion(1, 2, 3, 4)
-        >>> q.to_matrix()
+        >>> from sympy import symbols, trigsimp, cos, sin
+        >>> x = symbols('x')
+        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
+        >>> trigsimp(q.to_rotation_matrix())
         Matrix([
-        [-2/5,  2/5, 11/5],
-        [   2, -1/5,    2],
-        [   1, 14/5,    0]])
-        """
-        q = self
-        sqa = sqrt(q.a**2)
-        sqb = sqrt(q.b**2)
-        sqc = sqrt(q.c**2)
-        sqd = sqrt(q.d**2)
-
-        invs = 1 / (sqa + sqb + sqc + sqd)
-        m00 = (sqb - sqc - sqd + sqa) * invs
-        m11 = (-sqb + sqc - sqd + sqa) * invs
-        m22 = (-sqb - sqc + sqd + sqa) * invs
-
-        tmp1 = q.b * q.c
-        tmp2 = q.d * q.a
-        m10 = 2 * (tmp1 + tmp2) * invs
-        m01 = 2 * (tmp1 - tmp2) * invs
-
-        tmp1 = q.b * q.d
-        tmp2 = q.c * q.a
-        m20 = 2 * (tmp1 - tmp2) * invs
-        m02 = 2 * (tmp1 + tmp2) * invs
-
-        tmp1 = q.c * q.d
-        tmp2 = q.b * q.a
-        m21 = 2 * (tmp1 + tmp2) * invs
-        m12 = 2 * (tmp1 - tmp2) * invs
-
-        return Matrix([[m00, m01, m02], [m10, m11, m12], [m20, m21,
-                                                          m22]])
-
-    def to_matrix_4x4(self, v):
+        >>> trigsimp(q.to_rotation_matrix((1, 1, 1)))
+         Matrix([
+        [cos(x), -sin(x), 0, -sqrt(2)*cos(x + pi/4) + 1],
+        [sin(x),  cos(x), 0, -sqrt(2)*sin(x + pi/4) + 1],
+        [     0,       0, 1,                          0],
+        [     0,       0, 0,                          1]])
         """
 
         q = self
-        sqa = sqrt(q.a**2)
-        sqb = sqrt(q.b**2)
-        sqc = sqrt(q.c**2)
-        sqd = sqrt(q.d**2)
-
-        invs = 1 / (sqa + sqb + sqc + sqd)
-        m00 = (sqb - sqc - sqd + sqa) * invs
-        m11 = (-sqb + sqc - sqd + sqa) * invs
-        m22 = (-sqb - sqc + sqd + sqa) * invs
-
-        tmp1 = q.b * q.c
-        tmp2 = q.d * q.a
-        m10 = 2 * (tmp1 + tmp2) * invs
-        m01 = 2 * (tmp1 - tmp2) * invs
-
-        tmp1 = q.b * q.d
-        tmp2 = q.c * q.a
-        m20 = 2 * (tmp1 - tmp2) * invs
-        m02 = 2 * (tmp1 + tmp2) * invs
-
-        tmp1 = q.c * q.d
-        tmp2 = q.b * q.a
-        m21 = 2 * (tmp1 + tmp2) * invs
-        m12 = 2 * (tmp1 - tmp2) * invs
-
-        (x, y, z) = v
-
-        m03 = x - x*m00 - y*m01 - z*m02
-        m13 = y - x*m10 - y*m11 - z*m12
-        m23 = z - x*m20 - y*m21 - z*m22
-        m30 = m31 = m32 = 0
-        m33 = 1
-
-        return Matrix([[m00, m01, m02, m03], [m10, m11, m12, m13],
-                       [m20, m21, m22, m23], [m30, m31, m32, m33]])
+        s = q.norm()**-2
+        m00 = 1 - 2*s*(q.c**2 + q.d**2)
+        m01 = 2*s*(q.b*q.c - q.d*q.a)
+        m02 = 2*s*(q.b*q.d + q.c*q.a)
+
+        m10 = 2*s*(q.b*q.c + q.d*q.a)
+        m11 = 1 - 2*s*(q.b**2 + q.d**2)
+        m12 = 2*s*(q.c*q.d + q.b*q.a)
+
+        m20 = 2*s*(q.b*q.d - q.c*q.a)
+        m21 = 2*s*(q.c*q.d + q.b*q.a)
+        m22 = 1 - 2*s*(q.b**2 + q.c**2)
+
+        if not v:
+            return Matrix([[m00, m01, m02], [m10, m11, m12], [m20, m21, m22]])
+
+        else:
+            (x, y, z) = v
+
+            m03 = x - x*m00 - y*m01 - z*m02
+            m13 = y - x*m10 - y*m11 - z*m12
+            m23 = z - x*m20 - y*m21 - z*m22
+            m30 = m31 = m32 = 0
+            m33 = 1
+
+            return Matrix([[m00, m01, m02, m03], [m10, m11, m12, m13],
+                          [m20, m21, m22, m23], [m30, m31, m32, m33]])
```

**assistant → tool `bash`**

```json
{
  "command": "python bin/doctest sympy/algebras/quaternion.py 2>&1 | tail -20 && python bin/test sympy/algebras 2>&1 | tail -8"
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
hash randomization: on (PYTHONHASHSEED=3556781050)

sympy/algebras/quaternion.py[12] ............                               [OK]

================== tests finished: 12 passed, in 0.88 seconds ==================
ground types:       python 
numpy:              None
random seed:        1923251
hash randomization: on (PYTHONHASHSEED=2980115420)

sympy/algebras/tests/test_quaternion.py[4] ....                             [OK]

================== tests finished: 4 passed, in 0.44 seconds ===================
```

**assistant → tool `bash`**

```json
{
  "command": "git log -1 --format='%H %s' 0fc357cd1 && python -c \"\nfrom sympy import *\nfrom sympy.algebras.quaternion import Quaternion\nx=symbols('x')\nq=Quaternion(cos(x/2),sin(x/2),0,0)\nM=trigsimp(q.to_rotation_matrix())\nprint(M)\nprint('orthogonal:', trigsimp(M*M.T))\nprint('det:', trigsimp(M.det()))\nprint('rotate_point:', trigsimp(Quaternion.rotate((0,1,0), q)))\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `git log -1 --format='%H %s' 0fc357cd1 && python -c "
from sympy import *
from sympy.algebras.quaternion import Quaternion
x=symbols('x')
q=Quaternion(cos(x/2),sin(x/2),0,0)
M=trigsimp(q.to_rotation_matrix())
print(M)
print('orthogonal:', trigsimp(M*M.T))
print('det:', trigsimp(M.det()))
print('rotate_point:', trigsimp(Quaternion.rotate((0,1,0), q)))
"`
Output: 0fc357cd1742a8ad1514ecd7024342998bba7e6a Fixed to_rotation_matrix and changed doctests and tests
Traceback (most recent call last):
  File "<string>", line 10, in <module>
AttributeError: type object 'Quaternion' has no attribute 'rotate'
Matrix([[1, 0, 0], [0, cos(x), -sin(x)], [0, sin(x), cos(x)]])
orthogonal: Matrix([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
det: 1

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def rotate\" sympy/algebras/quaternion.py && python -c \"\nfrom sympy import *\nfrom sympy.algebras.quaternion import Quaternion\nx=symbols('x')\nq=Quaternion(cos(x/2),sin(x/2),0,0)\nprint(trigsimp(Quaternion.rotate_point((0,1,0), q)))\n\""
}
```

**tool result**

```
425:    def rotate_point(pin, r):
(0, cos(x), sin(x))
```

**assistant → tool `bash`**

```json
{
  "command": "git blame -L 525,540 sympy/algebras/quaternion.py"
}
```

**tool result**

```
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 525)         s = q.norm()**-2
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 526)         m00 = 1 - 2*s*(q.c**2 + q.d**2)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 527)         m01 = 2*s*(q.b*q.c - q.d*q.a)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 528)         m02 = 2*s*(q.b*q.d + q.c*q.a)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 529) 
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 530)         m10 = 2*s*(q.b*q.c + q.d*q.a)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 531)         m11 = 1 - 2*s*(q.b**2 + q.d**2)
0000000000 (Not Committed Yet 2026-11-06 13:27:32 +0000 532)         m12 = 2*s*(q.c*q.d - q.b*q.a)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 533) 
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 534)         m20 = 2*s*(q.b*q.d - q.c*q.a)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 535)         m21 = 2*s*(q.c*q.d + q.b*q.a)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 536)         m22 = 1 - 2*s*(q.b**2 + q.c**2)
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 537) 
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 538)         if not v:
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 539)             return Matrix([[m00, m01, m02], [m10, m11, m12], [m20, m21, m22]])
0fc357cd17 (Nikhil Pappu      2017-09-15 18:47:20 -0500 540)
```

**assistant**

````
## What was wrong

`m12` had a sign typo:

```python
m12 = 2*s*(q.c*q.d + q.b*q.a)   # wrong
```

The standard rotation matrix of a unit quaternion `q = a + b i + c j + d k` (Hamilton convention, active rotation) is

```
[ 1-2(c²+d²)   2(bc-ad)    2(bd+ac) ]
[ 2(bc+ad)     1-2(b²+d²)  2(cd-ab) ]
[ 2(bd-ac)     2(cd+ab)    1-2(b²+c²) ]
```

so entry `(1,2)` must be `2(cd − ab)`, not `2(cd + ab)`. For `q = (cos(x/2), sin(x/2), 0, 0)` that makes the matrix

```
[1,    0,      0    ]
[0,  cos(x), -sin(x)]
[0,  sin(x),  cos(x)]
```

which is the correct right-handed rotation about the x-axis.

### Reference of the original equations

The equations were introduced in commit `0fc357cd1` ("Fixed to_rotation_matrix and changed doctests and tests", Nikhil Pappu, 2017-09-15), which rewrote `to_matrix`/`to_matrix_4x4` into `to_rotation_matrix`. The **pre-refactor** version of the same file already had the correct form:

```python
tmp1 = q.c * q.d
tmp2 = q.b * q.a
m21 = 2 * (tmp1 + tmp2) * invs
m12 = 2 * (tmp1 - tmp2) * invs
```

So the reference is simply the standard quaternion → rotation-matrix formula (Wikipedia *Quaternion* / *Rotation formalisms in three dimensions*, and the euclidean-space reference already cited in the module header: `http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/`). The sign was lost when the expressions were inlined during that rewrite — `m21` kept `+`, `m12` wrongly also got `+`.

## Changes made

- `sympy/algebras/quaternion.py`: `m12 = 2*s*(q.c*q.d - q.b*q.a)`.
- `sympy/algebras/tests/test_quaternion.py`:
  - Updated `q1.to_rotation_matrix()` `(1,2)` entry `14/15 → 2/3` (and the corresponding 4x4 translation entry `-4/15 → 0`), which follows from the same correction for `Quaternion(1,2,3,4)`.
  - Added a regression test for `q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)` asserting `[[1,0,0],[0,cos,-sin],[0,sin,cos]]`.

Verification: `python bin/test sympy/algebras/tests/test_quaternion.py` → 4 passed; `python bin/doctest sympy/algebras/quaternion.py` → 12 passed. The resulting matrix is orthogonal with determinant 1, and `Quaternion.rotate_point((0,1,0), q)` gives `(0, cos(x), sin(x))`, consistent with the corrected matrix. No commits, checkouts, resets or stashes were made.
````

## Run folder `team-solve-2026-11-06T132624`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
4058a6420c11e8ea3f3be0ba0615a0dbaa4dad9b
```

### `baseline-check.log`

```
check: python -m pytest sympy/algebras/tests/test_quaternion.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sympy/algebras/quaternion.py b/sympy/algebras/quaternion.py
index b84e7cb95..7eae8d73d 100644
--- a/sympy/algebras/quaternion.py
+++ b/sympy/algebras/quaternion.py
@@ -529,7 +529,7 @@ def to_rotation_matrix(self, v=None):
 
         m10 = 2*s*(q.b*q.c + q.d*q.a)
         m11 = 1 - 2*s*(q.b**2 + q.d**2)
-        m12 = 2*s*(q.c*q.d + q.b*q.a)
+        m12 = 2*s*(q.c*q.d - q.b*q.a)
 
         m20 = 2*s*(q.b*q.d - q.c*q.a)
         m21 = 2*s*(q.c*q.d + q.b*q.a)
diff --git a/sympy/algebras/tests/test_quaternion.py b/sympy/algebras/tests/test_quaternion.py
index 420e9976d..d19afa95c 100644
--- a/sympy/algebras/tests/test_quaternion.py
+++ b/sympy/algebras/tests/test_quaternion.py
@@ -96,11 +96,11 @@ def test_quaternion_conversions():
                                    2 * acos(sqrt(30)/30))
 
     assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
-                                     [S(2)/3, -S(1)/3, S(14)/15],
+                                     [S(2)/3, -S(1)/3, S(2)/3],
                                      [S(1)/3, S(14)/15, S(2)/15]])
 
     assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
-                                                  [S(2)/3, -S(1)/3, S(14)/15, -S(4)/15],
+                                                  [S(2)/3, -S(1)/3, S(2)/3, S(0)],
                                                   [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
                                                   [S(0), S(0), S(0), S(1)]])
 
@@ -120,3 +120,10 @@ def test_quaternion_conversions():
                [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],
                [0,           0,          1,  0],
                [0,           0,          0,  1]])
+
+    # rotation about the x-axis: the (1, 2) entry must be -sin(theta)
+    q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)
+    assert trigsimp(q3.to_rotation_matrix()) == Matrix([
+               [1, 0,           0],
+               [0, cos(theta), -sin(theta)],
+               [0, sin(theta),  cos(theta)]])
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

Incorrect result with Quaterniont.to_rotation_matrix()
https://github.com/sympy/sympy/blob/ab14b02dba5a7e3e4fb1e807fc8a954f1047a1a1/sympy/algebras/quaternion.py#L489

There appears to be an error in the `Quaternion.to_rotation_matrix()` output.  The simplest example I created to illustrate the problem is as follows:

```
>>import sympy
>>print('Sympy version: ', sympy.__version__)
Sympy version: 1.2

>> from sympy import *
>> x = symbols('x')
>> q = Quaternion(cos(x/2), sin(x/2), 0, 0)
>> trigsimp(q.to_rotation_matrix())
Matrix([
[1,      0,      0],
[0, cos(x), sin(x)],
[0, sin(x), cos(x)]])
```
One of the `sin(x)` functions should be negative.  What was the reference of the original equations?

## Deliverable

changes to this tree

## Check

`python -m pytest sympy/algebras/tests/test_quaternion.py`

## Scope

`sympy/algebras/quaternion.py`
`sympy/algebras/tests/test_quaternion.py`

## Done when

- `Quaternion(cos(x/2), sin(x/2), 0, 0).to_rotation_matrix()` simplifies to `Matrix([[1, 0, 0], [0, cos(x), -sin(x)], [0, sin(x), cos(x)]])`.
- The corrected matrix is a proper rotation for a unit quaternion, with the off-diagonal sine terms having opposite signs.
- The quaternion test module passes.
- (inferred) The fix identifies the standard quaternion-to-rotation-matrix convention/reference used, so the sign convention is explicit.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest sympy/algebras/tests/test_quaternion.py`

## Scope
`sympy/algebras/quaternion.py`
`sympy/algebras/tests/test_quaternion.py`

## Done when
- `Quaternion(cos(x/2), sin(x/2), 0, 0).to_rotation_matrix()` simplifies to `Matrix([[1, 0, 0], [0, cos(x), -sin(x)], [0, sin(x), cos(x)]])`.
- The corrected matrix is a proper rotation for a unit quaternion, with the off-diagonal sine terms having opposite signs.
- The quaternion test module passes.
- (inferred) The fix identifies the standard quaternion-to-rotation-matrix convention/reference used, so the sign convention is explicit.

## Approach
The reported matrix is not a rotation matrix: its determinant is `cos(2*x)`, not `1`. The likely defect is a single sign error in the `m12` entry of `to_rotation_matrix`, where the standard formula uses `2*(q.c*q.d - q.a*q.b)` but the implementation effectively contributes `+2*q.a*q.b` for the reported quaternion.

Candidate approaches:
1. Minimal sign correction: change only the `m12` expression to the standard `2*s*(q.c*q.d - q.a*q.b)` form, leaving the rest of the matrix unchanged. This is the smallest diff and preserves the existing convention.
2. Rewrite `to_rotation_matrix` from the standard unit-quaternion formula using `a, b, c, d` consistently, then normalize by `norm()**-2`. This is clearer and less error-prone, but a larger diff.
3. Derive the matrix via quaternion conjugation/multiplication and simplify. This is conceptually robust but may produce less predictable simplification and is slower.

If the first attempt fails, verify the convention: active versus passive rotation, row-vector versus column-vector multiplication, and whether the expected result is the transpose of the current formula. Also check consistency with `from_rotation_matrix` and the existing quaternion tests.


# sympy/algebras/quaternion.py

```
# References :
# http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/
# https://en.wikipedia.org/wiki/Quaternion
from __future__ import print_function

from sympy.core.expr import Expr
from sympy import Rational
from sympy import re, im, conjugate
from sympy import sqrt, sin, cos, acos, asin, exp, ln
from sympy import trigsimp
from sympy import diff, integrate
from sympy import Matrix, Add, Mul
from sympy import symbols, sympify
from sympy.printing.latex import latex
from sympy.printing import StrPrinter
from sympy.core.numbers import Integer
from sympy.core.compatibility import SYMPY_INTS


class Quaternion(Expr):
    """Provides basic quaternion operations.
    Quaternion objects can be instantiated as Quaternion(a, b, c, d)
    as in (a + b*i + c*j + d*k).

    Example
    ========

    >>> from sympy.algebras.quaternion import Quaternion
    >>> q = Quaternion(1, 2, 3, 4)
    >>> q
    1 + 2*i + 3*j + 4*k

    Quaternions over complex fields can be defined as :
    ========
    >>> from sympy.algebras.quaternion import Quaternion
    >>> from sympy import symbols, I
    >>> x = symbols('x')
    >>> q1 = Quaternion(x, x**3, x, x**2, real_field = False)
    >>> q2 = Quaternion(3 + 4*I, 2 + 5*I, 0, 7 + 8*I, real_field = False)
    >>> q1
    x + x**3*i + x*j + x**2*k
    >>> q2
    (3 + 4*I) + (2 + 5*I)*i + 0*j + (7 + 8*I)*k
    """
    _op_priority = 11.0

    is_commutative = False

    def __new__(cls, a=0, b=0, c=0, d=0, real_field=True):
        a = sympify(a)
        b = sympify(b)
        c = sympify(c)
        d = sympify(d)

        if any(i.is_commutative is False for i in [a, b, c, d]):
            raise ValueError("arguments have to be commutative")
        else:
            obj = Expr.__new__(cls, a, b, c, d)
            obj._a = a
            obj._b = b
            obj._c = c
            obj._d = d
            obj._real_field = real_field
            return obj

    @property
    def a(self):
        return self._a

    @property
    def b(self):
        return self._b

    @property
    def c(self):
        return self._c

    @property
    def d(self):
        return self._d
    @property
    def real_field(self):
        return self._real_field

    @classmethod
    def from_axis_angle(cls, vector, angle):
        """Returns a rotation quaternion given the axis and the angle of rotation.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import pi, sqrt
        >>> q = Quaternion.from_axis_angle((sqrt(3)/3, sqrt(3)/3, sqrt(3)/3), 2*pi/3)
        >>> q
        1/2 + 1/2*i + 1/2*j + 1/2*k
        """
        (x, y, z) = vector
        norm = sqrt(x**2 + y**2 + z**2)
        (x, y, z) = (x / norm, y / norm, z / norm)
        s = sin(angle * Rational(1, 2))
        a = cos(angle * Rational(1, 2))
        b = x * s
        c = y * s
        d = z * s

        return cls(a, b, c, d).normalize()

    @classmethod
    def from_rotation_matrix(cls, M):
        """Returns the equivalent quaternion of a matrix. The quaternion will be normalized
        only if the matrix is special orthogonal (orthogonal and det(M) = 1).

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import Matrix, symbols, cos, sin, trigsimp
        >>> x = symbols('x')
        >>> M = Matrix([[cos(x), -sin(x), 0], [sin(x), cos(x), 0], [0, 0, 1]])
        >>> q = trigsimp(Quaternion.from_rotation_matrix(M))
        >>> q
        sqrt(2)*sqrt(cos(x) + 1)/2 + 0*i + 0*j + sqrt(-2*cos(x) + 2)/2*k
        """

        absQ = M.det()**Rational(1, 3)

        a = sqrt(absQ + M[0, 0] + M[1, 1] + M[2, 2]) / 2
        b = sqrt(absQ + M[0, 0] - M[1, 1] - M[2, 2]) / 2
        c = sqrt(absQ - M[0, 0] + M[1, 1] - M[2, 2]) / 2
        d = sqrt(absQ - M[0, 0] - M[1, 1] + M[2, 2]) / 2

        try:
            b = Quaternion.__copysign(b, M[2, 1] - M[1, 2])
            c = Quaternion.__copysign(c, M[0, 2] - M[2, 0])
            d = Quaternion.__copysign(d, M[1, 0] - M[0, 1])

        except Exception:
            pass

        return Quaternion(a, b, c, d)

    @staticmethod
    def __copysign(x, y):

        # Takes the sign from the second term and sets the sign of the first
        # without altering the magnitude.

        if y == 0:
            return 0
        return x if x*y > 0 else -x

    def __add__(self, other):
        return self.add(other)

    def __radd__(self, other):
        return self.add(other)

    def __sub__(self, other):
        return self.add(other*-1)

    def __mul__(self, other):
        return self._generic_mul(self, other)

    def __rmul__(self, other):
        return self._generic_mul(other, self)

    def __pow__(self, p):
        return self.pow(p)

    def __neg__(self):
        return Quaternion(-self._a, -self._b, -self._c, -self.d)

    def _eval_Integral(self, *args):
        return self.integrate(*args)

    def _eval_diff(self, *symbols, **kwargs):
        return self.diff(*symbols)

    def add(self, other):
        """Adds quaternions.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols
        >>> q1 = Quaternion(1, 2, 3, 4)
        >>> q2 = Quaternion(5, 6, 7, 8)
        >>> q1.add(q2)
        6 + 8*i + 10*j + 12*k
        >>> q1 + 5
        6 + 2*i + 3*j + 4*k
        >>> x = symbols('x', real = True)
        >>> q1.add(x)
        (x + 1) + 2*i + 3*j + 4*k

        Quaternions over complex fields :
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import I
        >>> q3 = Quaternion(3 + 4*I, 2 + 5*I, 0, 7 + 8*I, real_field = False)
        >>> q3.add(2 + 3*I)
        (5 + 7*I) + (2 + 5*I)*i + 0*j + (7 + 8*I)*k
        """
        q1 = self
        q2 = sympify(other)

        # If q2 is a number or a sympy expression instead of a quaternion
        if not isinstance(q2, Quaternion):
            if q1.real_field:
                if q2.is_complex:
                    return Quaternion(re(q2) + q1.a, im(q2) + q1.b, q1.c, q1.d)
                else:
                    # q2 is something strange, do not evaluate:
                    return Add(q1, q2)
            else:
                return Quaternion(q1.a + q2, q1.b, q1.c, q1.d)

        return Quaternion(q1.a + q2.a, q1.b + q2.b, q1.c + q2.c, q1.d
                          + q2.d)

    def mul(self, other):
        """Multiplies quaternions.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols
        >>> q1 = Quaternion(1, 2, 3, 4)
        >>> q2 = Quaternion(5, 6, 7, 8)
        >>> q1.mul(q2)
        (-60) + 12*i + 30*j + 24*k
        >>> q1.mul(2)
        2 + 4*i + 6*j + 8*k
        >>> x = symbols('x', real = True)
        >>> q1.mul(x)
        x + 2*x*i + 3*x*j + 4*x*k

        Quaternions over complex fields :
        ========
        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import I
        >>> q3 = Quaternion(3 + 4*I, 2 + 5*I, 0, 7 + 8*I, real_field = False)
        >>> q3.mul(2 + 3*I)
        (2 + 3*I)*(3 + 4*I) + (2 + 3*I)*(2 + 5*I)*i + 0*j + (2 + 3*I)*(7 + 8*I)*k
        """
        return self._generic_mul(self, other)

    @staticmethod
    def _generic_mul(q1, q2):

        q1 = sympify(q1)
        q2 = sympify(q2)

        # None is a Quaternion:
        if not isinstance(q1, Quaternion) and not isinstance(q2, Quaternion):
            return q1 * q2

        # If q1 is a number or a sympy expression instead of a quaternion
        if not isinstance(q1, Quaternion):
            if q2.real_field:
                if q1.is_complex:
                    return q2 * Quaternion(re(q1), im(q1), 0, 0)
                else:
                    return Mul(q1, q2)
            else:
                return Quaternion(q1 * q2.a, q1 * q2.b, q1 * q2.c, q1 * q2.d)


        # If q2 is a number or a sympy expression instead of a quaternion
        if not isinstance(q2, Quaternion):
            if q1.real_field:
                if q2.is_complex:
                    return q1 * Quaternion(re(q2), im(q2), 0, 0)
                else:
                    return Mul(q1, q2)
            else:
                return Quaternion(q2 * q1.a, q2 * q1.b, q2 * q1.c, q2 * q1.d)

        return Quaternion(-q1.b*q2.b - q1.c*q2.c - q1.d*q2.d + q1.a*q2.a,
                          q1.b*q2.a + q1.c*q2.d - q1.d*q2.c + q1.a*q2.b,
                          -q1.b*q2.d + q1.c*q2.a + q1.d*q2.b + q1.a*q2.c,
                          q1.b*q2.c - q1.c*q2.b + q1.d*q2.a + q1.a * q2.d)

    def _eval_conjugate(self):
        """Returns the conjugate of the quaternion."""
        q = self
        return Quaternion(q.a, -q.b, -q.c, -q.d)

    def norm(self):
        """Returns the norm of the quaternion."""
        q = self
        # trigsimp is used to simplify sin(x)^2 + cos(x)^2 (these terms
        # arise when from_axis_angle is used).
        return sqrt(trigsimp(q.a**2 + q.b**2 + q.c**2 + q.d**2))

    def normalize(self):
        """Returns the normalized form of the quaternion."""
        q = self
        return q * (1/q.norm())

    def inverse(self):
        """Returns the inverse of the quaternion."""
        q = self
        if not q.norm():
            raise ValueError("Cannot compute inverse for a quaternion with zero norm")
        return conjugate(q) * (1/q.norm()**2)

    def pow(self, p):
        """Finds the pth power of the quaternion.
        Returns the inverse if p = -1.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> q = Quaternion(1, 2, 3, 4)
        >>> q.pow(4)
        668 + (-224)*i + (-336)*j + (-448)*k
        """
        q = self
        if p == -1:
            return q.inverse()
        res = 1

        if p < 0:
            q, p = q.inverse(), -p

        if not (isinstance(p, (Integer, SYMPY_INTS))):
            return NotImplemented

        while p > 0:
            if p & 1:
                res = q * res

            p = p >> 1
            q = q * q

        return res

    def exp(self):
        """Returns the exponential of q (e^q).

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> q = Quaternion(1, 2, 3, 4)
        >>> q.exp()
        E*cos(sqrt(29))
        + 2*sqrt(29)*E*sin(sqrt(29))/29*i
        + 3*sqrt(29)*E*sin(sqrt(29))/29*j
        + 4*sqrt(29)*E*sin(sqrt(29))/29*k
        """
        # exp(q) = e^a(cos||v|| + v/||v||*sin||v||)
        q = self
        vector_norm = sqrt(q.b**2 + q.c**2 + q.d**2)
        a = exp(q.a) * cos(vector_norm)
        b = exp(q.a) * sin(vector_norm) * q.b / vector_norm
        c = exp(q.a) * sin(vector_norm) * q.c / vector_norm
        d = exp(q.a) * sin(vector_norm) * q.d / vector_norm

        return Quaternion(a, b, c, d)

    def _ln(self):
        """Returns the natural logarithm of the quaternion (_ln(q)).

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> q = Quaternion(1, 2, 3, 4)
        >>> q._ln()
        log(sqrt(30))
        + 2*sqrt(29)*acos(sqrt(30)/30)/29*i
        + 3*sqrt(29)*acos(sqrt(30)/30)/29*j
        + 4*sqrt(29)*acos(sqrt(30)/30)/29*k
        """
        # _ln(q) = _ln||q|| + v/||v||*arccos(a/||q||)
        q = self
        vector_norm = sqrt(q.b**2 + q.c**2 + q.d**2)
        q_norm = q.norm()
        a = ln(q_norm)
        b = q.b * acos(q.a / q_norm) / vector_norm
        c = q.c * acos(q.a / q_norm) / vector_norm
        d = q.d * acos(q.a / q_norm) / vector_norm

        return Quaternion(a, b, c, d)

    def pow_cos_sin(self, p):
        """Computes the pth power in the cos-sin form.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> q = Quaternion(1, 2, 3, 4)
        >>> q.pow_cos_sin(4)
        900*cos(4*acos(sqrt(30)/30))
        + 1800*sqrt(29)*sin(4*acos(sqrt(30)/30))/29*i
        + 2700*sqrt(29)*sin(4*acos(sqrt(30)/30))/29*j
        + 3600*sqrt(29)*sin(4*acos(sqrt(30)/30))/29*k
        """
        # q = ||q||*(cos(a) + u*sin(a))
        # q^p = ||q||^p * (cos(p*a) + u*sin(p*a))

        q = self
        (v, angle) = q.to_axis_angle()
        q2 = Quaternion.from_axis_angle(v, p * angle)
        return q2 * (q.norm()**p)

    def diff(self, *args):
        return Quaternion(diff(self.a, *args), diff(self.b, *args),
                          diff(self.c, *args), diff(self.d, *args))

    def integrate(self, *args):
        # TODO: is this expression correct?
        return Quaternion(integrate(self.a, *args), integrate(self.b, *args),
                          integrate(self.c, *args), integrate(self.d, *args))

    @staticmethod
    def rotate_point(pin, r):
        """Returns the coordinates of the point pin(a 3 tuple) after rotation.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols, trigsimp, cos, sin
        >>> x = symbols('x')
        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
        >>> trigsimp(Quaternion.rotate_point((1, 1, 1), q))
        (sqrt(2)*cos(x + pi/4), sqrt(2)*sin(x + pi/4), 1)
        >>> (axis, angle) = q.to_axis_angle()
        >>> trigsimp(Quaternion.rotate_point((1, 1, 1), (axis, angle)))
        (sqrt(2)*cos(x + pi/4), sqrt(2)*sin(x + pi/4), 1)
        """
        if isinstance(r, tuple):
            # if r is of the form (vector, angle)
            q = Quaternion.from_axis_angle(r[0], r[1])
        else:
            # if r is a quaternion
            q = r.normalize()
        pout = q * Quaternion(0, pin[0], pin[1], pin[2]) * conjugate(q)
        return (pout.b, pout.c, pout.d)

    def to_axis_angle(self):
        """Returns the axis and angle of rotation of a quaternion

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> q = Quaternion(1, 1, 1, 1)
        >>> (axis, angle) = q.to_axis_angle()
        >>> axis
        (sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        >>> angle
        2*pi/3
        """
        q = self
        try:
            # Skips it if it doesn't know whether q.a is negative
            if q.a < 0:
                # avoid error with acos
                # axis and angle of rotation of q and q*-1 will be the same
                q = q * -1
        except BaseException:
            pass

        q = q.normalize()
        angle = trigsimp(2 * acos(q.a))

        # Since quaternion is normalised, q.a is less than 1.
        s = sqrt(1 - q.a*q.a)

        x = trigsimp(q.b / s)
        y = trigsimp(q.c / s)
        z = trigsimp(q.d / s)

        v = (x, y, z)
        t = (v, angle)

        return t

    def to_rotation_matrix(self, v=None):
        """Returns the equivalent rotation transformation matrix of the quaternion
        which represents rotation about the origin if v is not passed.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols, trigsimp, cos, sin
        >>> x = symbols('x')
        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
        >>> trigsimp(q.to_rotation_matrix())
        Matrix([
        [cos(x), -sin(x), 0],
        [sin(x),  cos(x), 0],
        [     0,       0, 1]])

        Generates a 4x4 transformation matrix (used for rotation about a point
        other than the origin) if the point(v) is passed as an argument.

        Example
        ========

        >>> from sympy.algebras.quaternion import Quaternion
        >>> from sympy import symbols, trigsimp, cos, sin
        >>> x = symbols('x')
        >>> q = Quaternion(cos(x/2), 0, 0, sin(x/2))
        >>> trigsimp(q.to_rotation_matrix((1, 1, 1)))
         Matrix([
        [cos(x), -sin(x), 0,  sin(x) - cos(x) + 1],
        [sin(x),  cos(x), 0, -sin(x) - cos(x) + 1],
        [     0,       0, 1,                    0],
        [     0,       0, 0,                    1]])
        """

        q = self
        s = q.norm()**-2
        m00 = 1 - 2*s*(q.c**2 + q.d**2)
        m01 = 2*s*(q.b*q.c - q.d*q.a)
        m02 = 2*s*(q.b*q.d + q.c*q.a)

        m10 = 2*s*(q.b*q.c + q.d*q.a)
        m11 = 1 - 2*s*(q.b**2 + q.d**2)
        m12 = 2*s*(q.c*q.d - q.b*q.a)

        m20 = 2*s*(q.b*q.d - q.c*q.a)
        m21 = 2*s*(q.c*q.d + q.b*q.a)
        m22 = 1 - 2*s*(q.b**2 + q.c**2)

        if not v:
            return Matrix([[m00, m01, m02], [m10, m11, m12], [m20, m21, m22]])

        else:
            (x, y, z) = v

            m03 = x - x*m00 - y*m01 - z*m02
            m13 = y - x*m10 - y*m11 - z*m12
            m23 = z - x*m20 - y*m21 - z*m22
            m30 = m31 = m32 = 0
            m33 = 1

            return Matrix([[m00, m01, m02, m03], [m10, m11, m12, m13],
                          [m20, m21, m22, m23], [m30, m31, m32, m33]])

```


# sympy/algebras/tests/test_quaternion.py

```
from sympy.algebras.quaternion import Quaternion
from sympy import symbols, re, im, Add, Mul, I, Abs
from sympy import cos, sin, sqrt, conjugate, exp, log, acos, E, pi
from sympy.utilities.pytest import raises
from sympy import Matrix
from sympy import diff, integrate, trigsimp
from sympy import S, Rational

x, y, z, w = symbols("x y z w")

def test_quaternion_construction():
    q = Quaternion(x, y, z, w)
    assert q + q == Quaternion(2*x, 2*y, 2*z, 2*w)

    q2 = Quaternion.from_axis_angle((sqrt(3)/3, sqrt(3)/3, sqrt(3)/3), 2*pi/3)
    assert q2 == Quaternion(Rational(1/2), Rational(1/2),
                            Rational(1/2), Rational(1,2))

    M = Matrix([[cos(x), -sin(x), 0], [sin(x), cos(x), 0], [0, 0, 1]])
    q3 = trigsimp(Quaternion.from_rotation_matrix(M))
    assert q3 == Quaternion(sqrt(2)*sqrt(cos(x) + 1)/2, 0, 0, sqrt(-2*cos(x) + 2)/2)


def test_quaternion_complex_real_addition():
    a = symbols("a", complex=True)
    b = symbols("b", real=True)
    # This symbol is not complex:
    c = symbols("c", commutative=False)

    q = Quaternion(x, y, z, w)
    assert a + q == Quaternion(x + re(a), y + im(a), z, w)
    assert 1 + q == Quaternion(1 + x, y, z, w)
    assert I + q == Quaternion(x, 1 + y, z, w)
    assert b + q == Quaternion(x + b, y, z, w)
    assert c + q == Add(c, Quaternion(x, y, z, w), evaluate=False)
    assert q * c == Mul(Quaternion(x, y, z, w), c, evaluate=False)
    assert c * q == Mul(c, Quaternion(x, y, z, w), evaluate=False)

    assert -q == Quaternion(-x, -y, -z, -w)

    q1 = Quaternion(3 + 4*I, 2 + 5*I, 0, 7 + 8*I, real_field = False)
    q2 = Quaternion(1, 4, 7, 8)

    assert q1 + (2 + 3*I) == Quaternion(5 + 7*I, 2 + 5*I, 0, 7 + 8*I)
    assert q2 + (2 + 3*I) == Quaternion(3, 7, 7, 8)
    assert q1 * (2 + 3*I) == \
    Quaternion((2 + 3*I)*(3 + 4*I), (2 + 3*I)*(2 + 5*I), 0, (2 + 3*I)*(7 + 8*I))
    assert q2 * (2 + 3*I) == Quaternion(-10, 11, 38, -5)


def test_quaternion_functions():
    q = Quaternion(x, y, z, w)
    q1 = Quaternion(1, 2, 3, 4)
    q0 = Quaternion(0, 0, 0, 0)

    assert conjugate(q) == Quaternion(x, -y, -z, -w)
    assert q.norm() == sqrt(w**2 + x**2 + y**2 + z**2)
    assert q.normalize() == Quaternion(x, y, z, w) / sqrt(w**2 + x**2 + y**2 + z**2)
    assert q.inverse() == Quaternion(x, -y, -z, -w) / (w**2 + x**2 + y**2 + z**2)
    raises(ValueError, lambda: q0.inverse())
    assert q.pow(2) == Quaternion(-w**2 + x**2 - y**2 - z**2, 2*x*y, 2*x*z, 2*w*x)
    assert q1.pow(-2) == Quaternion(-S(7)/225, -S(1)/225, -S(1)/150, -S(2)/225)
    assert q1.pow(-0.5) == NotImplemented

    assert q1.exp() == \
    Quaternion(E * cos(sqrt(29)),
               2 * sqrt(29) * E * sin(sqrt(29)) / 29,
               3 * sqrt(29) * E * sin(sqrt(29)) / 29,
               4 * sqrt(29) * E * sin(sqrt(29)) / 29)
    assert q1._ln() == \
    Quaternion(log(sqrt(30)),
               2 * sqrt(29) * acos(sqrt(30)/30) / 29,
               3 * sqrt(29) * acos(sqrt(30)/30) / 29,
               4 * sqrt(29) * acos(sqrt(30)/30) / 29)

    assert q1.pow_cos_sin(2) == \
    Quaternion(30 * cos(2 * acos(sqrt(30)/30)),
               60 * sqrt(29) * sin(2 * acos(sqrt(30)/30)) / 29,
               90 * sqrt(29) * sin(2 * acos(sqrt(30)/30)) / 29,
               120 * sqrt(29) * sin(2 * acos(sqrt(30)/30)) / 29)

    assert diff(Quaternion(x, x, x, x), x) == Quaternion(1, 1, 1, 1)

    assert integrate(Quaternion(x, x, x, x), x) == \
    Quaternion(x**2 / 2, x**2 / 2, x**2 / 2, x**2 / 2)

    assert Quaternion.rotate_point((1, 1, 1), q1) == (1 / 5, 1, 7 / 5)


def test_quaternion_conversions():
    q1 = Quaternion(1, 2, 3, 4)

    assert q1.to_axis_angle() == ((2 * sqrt(29)/29,
                                   3 * sqrt(29)/29,
                                   4 * sqrt(29)/29),
                                   2 * acos(sqrt(30)/30))

    assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
                                     [S(2)/3, -S(1)/3, S(2)/3],
                                     [S(1)/3, S(14)/15, S(2)/15]])

    assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
                                                  [S(2)/3, -S(1)/3, S(2)/3, S(0)],
                                                  [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
                                                  [S(0), S(0), S(0), S(1)]])

    theta = symbols("theta", real=True)
    q2 = Quaternion(cos(theta/2), 0, 0, sin(theta/2))

    assert trigsimp(q2.to_rotation_matrix()) == Matrix([
                                               [cos(theta), -sin(theta), 0],
                                               [sin(theta),  cos(theta), 0],
                                               [0,           0,          1]])

    assert q2.to_axis_angle() == ((0, 0, sin(theta/2)/Abs(sin(theta/2))),
                                   2*acos(cos(theta/2)))

    assert trigsimp(q2.to_rotation_matrix((1, 1, 1))) == Matrix([
               [cos(theta), -sin(theta), 0, sin(theta) - cos(theta) + 1],
               [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],
               [0,           0,          1,  0],
               [0,           0,          0,  1]])

    # rotation about the x-axis: the (1, 2) entry must be -sin(theta)
    q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)
    assert trigsimp(q3.to_rotation_matrix()) == Matrix([
               [1, 0,           0],
               [0, cos(theta), -sin(theta)],
               [0, sin(theta),  cos(theta)]])

```


# The last commit

```
4058a6420 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest sympy/algebras/tests/test_quaternion.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/algebras/quaternion.py sympy/algebras/tests/test_quaternion.py
changed: sympy/algebras/quaternion.py +1 -1
changed: sympy/algebras/tests/test_quaternion.py +9 -2
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sympy/algebras/quaternion.py b/sympy/algebras/quaternion.py
index b84e7cb95..7eae8d73d 100644
--- a/sympy/algebras/quaternion.py
+++ b/sympy/algebras/quaternion.py
@@ -529,7 +529,7 @@ def to_rotation_matrix(self, v=None):
 
         m10 = 2*s*(q.b*q.c + q.d*q.a)
         m11 = 1 - 2*s*(q.b**2 + q.d**2)
-        m12 = 2*s*(q.c*q.d + q.b*q.a)
+        m12 = 2*s*(q.c*q.d - q.b*q.a)
 
         m20 = 2*s*(q.b*q.d - q.c*q.a)
         m21 = 2*s*(q.c*q.d + q.b*q.a)
diff --git a/sympy/algebras/tests/test_quaternion.py b/sympy/algebras/tests/test_quaternion.py
index 420e9976d..d19afa95c 100644
--- a/sympy/algebras/tests/test_quaternion.py
+++ b/sympy/algebras/tests/test_quaternion.py
@@ -96,11 +96,11 @@ def test_quaternion_conversions():
                                    2 * acos(sqrt(30)/30))
 
     assert q1.to_rotation_matrix() == Matrix([[-S(2)/3, S(2)/15, S(11)/15],
-                                     [S(2)/3, -S(1)/3, S(14)/15],
+                                     [S(2)/3, -S(1)/3, S(2)/3],
                                      [S(1)/3, S(14)/15, S(2)/15]])
 
     assert q1.to_rotation_matrix((1, 1, 1)) == Matrix([[-S(2)/3, S(2)/15, S(11)/15, S(4)/5],
-                                                  [S(2)/3, -S(1)/3, S(14)/15, -S(4)/15],
+                                                  [S(2)/3, -S(1)/3, S(2)/3, S(0)],
                                                   [S(1)/3, S(14)/15, S(2)/15, -S(2)/5],
                                                   [S(0), S(0), S(0), S(1)]])
 
@@ -120,3 +120,10 @@ def test_quaternion_conversions():
                [sin(theta),  cos(theta), 0, -sin(theta) - cos(theta) + 1],
                [0,           0,          1,  0],
                [0,           0,          0,  1]])
+
+    # rotation about the x-axis: the (1, 2) entry must be -sin(theta)
+    q3 = Quaternion(cos(theta/2), sin(theta/2), 0, 0)
+    assert trigsimp(q3.to_rotation_matrix()) == Matrix([
+               [1, 0,           0],
+               [0, cos(theta), -sin(theta)],
+               [0, sin(theta),  cos(theta)]])
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
check: python -m pytest sympy/algebras/tests/test_quaternion.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/algebras/quaternion.py sympy/algebras/tests/test_quaternion.py
changed: sympy/algebras/quaternion.py +1 -1
changed: sympy/algebras/tests/test_quaternion.py +9 -2
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
# Notes, run 2026-11-06T132624

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Incorrect result with Quaterniont.to_rotation_matrix()
https://github.com/sympy/sympy/blob/ab14b02dba5a7e3e4fb1e807fc8a954f1047a1a1/sympy/algebras/quaternion.py#L489

There appears to be an error in the `Quaternion.to_rotation_matrix()` output.  The simplest example I created to illustrate the problem is as follows:

```
>>import sympy
>>print('Sympy version: ', sympy.__version__)
Sympy version: 1.2

>> from sympy import *
>> x = symbols('x')
>> q = Quaternion(cos(x/2), sin(x/2), 0, 0)
>> trigsimp(q.to_rotation_matrix())
Matrix([
[1,      0,      0],
[0, cos(x), sin(x)],
[0, sin(x), cos(x)]])
```
One of the `sin(x)` functions should be negative.  What was the reference of the original equations?


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
azure-pipelines.yml
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
bin/test_executable.py
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
doc/src/modules/physics/mechanics/autolev_parser.rst
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
doc/src/modules/physics/mechanics/sympy_mechanics_for_autolev_users.rst
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
sympy/algebras/tests/__init__.py
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
sympy/codegen/tests/__init__.py
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
```


# The last commit

```
4058a6420 SWE-bench


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
`python -m pytest sympy/algebras/tests/test_quaternion.py`

## Scope
`sympy/algebras/quaternion.py`
`sympy/algebras/tests/test_quaternion.py`

## Done when
- `Quaternion(cos(x/2), sin(x/2), 0, 0).to_rotation_matrix()` simplifies to `Matrix([[1, 0, 0], [0, cos(x), -sin(x)], [0, sin(x), cos(x)]])`.
- The corrected matrix is a proper rotation for a unit quaternion, with the off-diagonal sine terms having opposite signs.
- The quaternion test module passes.
- (inferred) The fix identifies the standard quaternion-to-rotation-matrix convention/reference used, so the sign convention is explicit.

## Approach
The reported matrix is not a rotation matrix: its determinant is `cos(2*x)`, not `1`. The likely defect is a single sign error in the `m12` entry of `to_rotation_matrix`, where the standard formula uses `2*(q.c*q.d - q.a*q.b)` but the implementation effectively contributes `+2*q.a*q.b` for the reported quaternion.

Candidate approaches:
1. Minimal sign correction: change only the `m12` expression to the standard `2*s*(q.c*q.d - q.a*q.b)` form, leaving the rest of the matrix unchanged. This is the smallest diff and preserves the existing convention.
2. Rewrite `to_rotation_matrix` from the standard unit-quaternion formula using `a, b, c, d` consistently, then normalize by `norm()**-2`. This is clearer and less error-prone, but a larger diff.
3. Derive the matrix via quaternion conjugation/multiplication and simplify. This is conceptually robust but may produce less predictable simplification and is slower.

If the first attempt fails, verify the convention: active versus passive rotation, row-vector versus column-vector multiplication, and whether the expected result is the transpose of the current formula. Also check consistency with `from_rotation_matrix` and the existing quaternion tests.
```

### `prompt.md`

````
Incorrect result with Quaterniont.to_rotation_matrix()
https://github.com/sympy/sympy/blob/ab14b02dba5a7e3e4fb1e807fc8a954f1047a1a1/sympy/algebras/quaternion.py#L489

There appears to be an error in the `Quaternion.to_rotation_matrix()` output.  The simplest example I created to illustrate the problem is as follows:

```
>>import sympy
>>print('Sympy version: ', sympy.__version__)
Sympy version: 1.2

>> from sympy import *
>> x = symbols('x')
>> q = Quaternion(cos(x/2), sin(x/2), 0, 0)
>> trigsimp(q.to_rotation_matrix())
Matrix([
[1,      0,      0],
[0, cos(x), sin(x)],
[0, sin(x), cos(x)]])
```
One of the `sin(x)` functions should be negative.  What was the reference of the original equations?
````

### `review.md`

```
verdict: PASS

The `m12` correction to `2*s*(q.c*q.d - q.b*q.a)` is the standard active quaternion rotation-matrix entry and produces `-sin(x)` for `Quaternion(cos(x/2), sin(x/2), 0, 0)`.
The updated `q1` expectations are arithmetically correct: the corrected `m12` becomes `S(2)/3`, and the homogeneous translation entry becomes `S(0)`.
The added regression test covers the reported x-axis case and should simplify to the requested matrix.
The pytest check could not be executed because `pytest` is unavailable, but manual verification against the formulas finds no failing expectation.
Only the two in-scope files were changed; no unrelated content was removed or altered.
```

### `scope.txt`

```
scope: sympy/algebras/quaternion.py sympy/algebras/tests/test_quaternion.py
changed: sympy/algebras/quaternion.py +1 -1
changed: sympy/algebras/tests/test_quaternion.py +9 -2
```

### `task.md`

````
# Task

## Prompt

Incorrect result with Quaterniont.to_rotation_matrix()
https://github.com/sympy/sympy/blob/ab14b02dba5a7e3e4fb1e807fc8a954f1047a1a1/sympy/algebras/quaternion.py#L489

There appears to be an error in the `Quaternion.to_rotation_matrix()` output.  The simplest example I created to illustrate the problem is as follows:

```
>>import sympy
>>print('Sympy version: ', sympy.__version__)
Sympy version: 1.2

>> from sympy import *
>> x = symbols('x')
>> q = Quaternion(cos(x/2), sin(x/2), 0, 0)
>> trigsimp(q.to_rotation_matrix())
Matrix([
[1,      0,      0],
[0, cos(x), sin(x)],
[0, sin(x), cos(x)]])
```
One of the `sin(x)` functions should be negative.  What was the reference of the original equations?

## Deliverable

changes to this tree

## Check

`python -m pytest sympy/algebras/tests/test_quaternion.py`

## Scope

`sympy/algebras/quaternion.py`
`sympy/algebras/tests/test_quaternion.py`

## Done when

- `Quaternion(cos(x/2), sin(x/2), 0, 0).to_rotation_matrix()` simplifies to `Matrix([[1, 0, 0], [0, cos(x), -sin(x)], [0, sin(x), cos(x)]])`.
- The corrected matrix is a proper rotation for a unit quaternion, with the off-diagonal sine terms having opposite signs.
- The quaternion test module passes.
- (inferred) The fix identifies the standard quaternion-to-rotation-matrix convention/reference used, so the sign convention is explicit.
````

### `test-output.log`

```
check: python -m pytest sympy/algebras/tests/test_quaternion.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/algebras/quaternion.py sympy/algebras/tests/test_quaternion.py
changed: sympy/algebras/quaternion.py +1 -1
changed: sympy/algebras/tests/test_quaternion.py +9 -2
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
- The source change flips `m12` to `2*s*(q.c*q.d - q.b*q.a)`, matching the standard quaternion-to-rotation-matrix convention; for `Quaternion(cos(x/2), sin(x/2), 0, 0)` this yields `-sin(x)` at `(1,2)` and `+sin(x)` at `(2,1)`.
- The updated `q1` expectations are consistent with the corrected formula: `m12` becomes `2/3`, and the translated fourth-column entry becomes `0`.
- The added `q3` test directly checks the required Done-when matrix.
- The change stays within the specified scope and does not remove unrelated content.
```
