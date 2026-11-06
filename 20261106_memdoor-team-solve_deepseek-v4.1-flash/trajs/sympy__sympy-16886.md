# sympy__sympy-16886 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 44s 30 lines cost=0.002862 in=128663 cached=89088 out=4087 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Morse encoding for "1" is not correct
The current Morse mapping in simpy.crypto.crypto contains an incorrect mapping of 
`"----": "1"`   

The correct mapping is `".----": "1"`.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `grep`**

```json
{
  "pattern": "\"----\": \"1\"",
  "output_mode": "content",
  "head_limit": 20
}
```

**assistant → tool `glob`**

```json
{
  "pattern": "**/crypto*"
}
```

**tool result**

```
/testbed/sympy/crypto/crypto.py:    "-----": "0", "----": "1",
```

**tool result**

```
/testbed/doc/src/modules/crypto.rst
/testbed/sympy/crypto/crypto.py
```

**assistant → tool `grep`**

```json
{
  "pattern": "\"-----\": \"0\"",
  "path": "/testbed/sympy/crypto/crypto.py",
  "output_mode": "content",
  "head_limit": 20
}
```

**assistant → tool `grep`**

```json
{
  "pattern": "----|\\.----|1",
  "path": "/testbed/sympy/crypto/tests/test_crypto.py",
  "output_mode": "content",
  "head_limit": 40
}
```

**tool result**

```
/testbed/sympy/crypto/crypto.py:    "-----": "0", "----": "1",
```

**tool result**

```
/testbed/sympy/crypto/tests/test_crypto.py:      bifid5_square, bifid6_square, bifid5, bifid6, bifid10,
/testbed/sympy/crypto/tests/test_crypto.py:      bg_private_key, bg_public_key, encipher_rot13, decipher_rot13,
/testbed/sympy/crypto/tests/test_crypto.py:    assert cycle_list(3, 4) == [3, 0, 1, 2]
/testbed/sympy/crypto/tests/test_crypto.py:    assert cycle_list(-1, 4) == [3, 0, 1, 2]
/testbed/sympy/crypto/tests/test_crypto.py:    assert cycle_list(1, 4) == [1, 2, 3, 0]
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_shift("ABC", 1) == "BCD"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_shift("ABC", -1) == "ZAB"
/testbed/sympy/crypto/tests/test_crypto.py:    assert decipher_shift("ZAB", -1) == "ABC"
/testbed/sympy/crypto/tests/test_crypto.py:def test_encipher_rot13():
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_rot13("ABC") == "NOP"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_rot13("NOP") == "ABC"
/testbed/sympy/crypto/tests/test_crypto.py:    assert decipher_rot13("ABC") == "NOP"
/testbed/sympy/crypto/tests/test_crypto.py:    assert decipher_rot13("NOP") == "ABC"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_affine("ABC", (1, 0)) == "ABC"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_affine("ABC", (1, 1)) == "BCD"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_affine("ABC", (-1, 0)) == "AZY"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_affine("ABC", (-1, 1), symbols="ABCD") == "BAD"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_affine("123", (-1, 1), symbols="1234") == "214"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_affine("ABC", (3, 16)) == "QTW"
/testbed/sympy/crypto/tests/test_crypto.py:    assert decipher_affine("QTW", (3, 16)) == "ABC"
/testbed/sympy/crypto/tests/test_crypto.py:    assert encipher_substitution("123", "1243", "1234") == "124"
/testbed/sympy/crypto/tests/test_crypto.py:    A = Matrix(2, 2, [1, 2, 3, 5])
/testbed/sympy/crypto/tests/test_crypto.py:    A = Matrix(2, 2, [1, 0, 0, 1])
/testbed/sympy/crypto/tests/test_crypto.py:    A = Matrix(2, 2, [1, 2, 3, 5])
/testbed/sympy/crypto/tests/test_crypto.py:    A = Matrix(2, 2, [1, 2, 3, 5])
/testbed/sympy/crypto/tests/test_crypto.py:    A = Matrix(2, 2, [1, 0, 0, 1])
/testbed/sympy/crypto/tests/test_crypto.py:    A = Matrix(2, 2, [1, 2, 3, 5])
/testbed/sympy/crypto/tests/test_crypto.py:    assert rsa_public_key(2, 3, 1) == (6, 1)
/testbed/sympy/crypto/tests/test_crypto.py:    assert rsa_public_key(5, 3, 3) == (15, 3)
/testbed/sympy/crypto/tests/test_crypto.py:        assert rsa_public_key(2, 2, 1) == (4, 1)
/testbed/sympy/crypto/tests/test_crypto.py:    assert rsa_private_key(2, 3, 1) == (6, 1)
/testbed/sympy/crypto/tests/test_crypto.py:    assert rsa_private_key(5, 3, 3) == (15, 3)
/testbed/sympy/crypto/tests/test_crypto.py:        assert rsa_private_key(2, 2, 1) == (4, 1)
/testbed/sympy/crypto/tests/test_crypto.py:    p = int('101565610013301240713207239558950144682174355406589305284428666'\
/testbed/sympy/crypto/tests/test_crypto.py:    q = int('894687191887545488935455605955948413812376003053143521429242133'\
/testbed/sympy/crypto/tests/test_crypto.py:        '12069293984003')
/testbed/sympy/crypto/tests/test_crypto.py:    d = int('893650581832704239530398858744759129594796235440844479456143566'\
/testbed/sympy/crypto/tests/test_crypto.py:        '6999402846577625762582824202269399672579058991442587406384754958587'\
/testbed/sympy/crypto/tests/test_crypto.py:        '400493169361356902030209')
/testbed/sympy/crypto/tests/test_crypto.py:    puk = rsa_public_key(2, 3, 1)
```

**assistant → tool `grep`**

```json
{
  "pattern": "def (encipher_morse|decipher_morse)|morse|Morse",
  "path": "/testbed/sympy/crypto/crypto.py",
  "output_mode": "content",
  "head_limit": 40
}
```

**assistant → tool `grep`**

```json
{
  "pattern": "morse|Morse",
  "path": "/testbed/sympy/crypto/tests/test_crypto.py",
  "output_mode": "content",
  "head_limit": 40
}
```

**tool result**

```
/testbed/sympy/crypto/crypto.py:#################### Morse Code ######################################
/testbed/sympy/crypto/crypto.py:morse_char = {
/testbed/sympy/crypto/crypto.py:char_morse = {v: k for k, v in morse_char.items()}
/testbed/sympy/crypto/crypto.py:def encode_morse(msg, sep='|', mapping=None):
/testbed/sympy/crypto/crypto.py:    Encodes a plaintext into popular Morse Code with letters
/testbed/sympy/crypto/crypto.py:    .. [1] https://en.wikipedia.org/wiki/Morse_code
/testbed/sympy/crypto/crypto.py:    >>> from sympy.crypto.crypto import encode_morse
/testbed/sympy/crypto/crypto.py:    >>> encode_morse(msg)
/testbed/sympy/crypto/crypto.py:    mapping = mapping or char_morse
/testbed/sympy/crypto/crypto.py:    morsestring = []
/testbed/sympy/crypto/crypto.py:        morseword = []
/testbed/sympy/crypto/crypto.py:            morseletter = mapping[letter]
/testbed/sympy/crypto/crypto.py:            morseword.append(morseletter)
/testbed/sympy/crypto/crypto.py:        word = sep.join(morseword)
/testbed/sympy/crypto/crypto.py:        morsestring.append(word)
/testbed/sympy/crypto/crypto.py:    return word_sep.join(morsestring) + (word_sep if suffix else '')
/testbed/sympy/crypto/crypto.py:def decode_morse(msg, sep='|', mapping=None):
/testbed/sympy/crypto/crypto.py:    Decodes a Morse Code with letters separated by `sep`
/testbed/sympy/crypto/crypto.py:    .. [1] https://en.wikipedia.org/wiki/Morse_code
/testbed/sympy/crypto/crypto.py:    >>> from sympy.crypto.crypto import decode_morse
/testbed/sympy/crypto/crypto.py:    >>> decode_morse(mc)
/testbed/sympy/crypto/crypto.py:    mapping = mapping or morse_char
```

**tool result**

`````
/testbed/sympy/crypto/tests/test_crypto.py:      encode_morse, decode_morse, elgamal_private_key, elgamal_public_key,
/testbed/sympy/crypto/tests/test_crypto.py:def test_encode_morse():
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse('ABC') == '.-|-...|-.-.'
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse('SMS ') == '...|--|...||'
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse('SMS\n') == '...|--|...||'
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse('') == ''
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse(' ') == '||'
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse(' ', sep='`') == '``'
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse(' ', sep='``') == '````'
/testbed/sympy/crypto/tests/test_crypto.py:    assert encode_morse('!@#$%^&*()_+') == '-.-.--|.--.-.|...-..-|-.--.|-.--.-|..--.-|.-.-.'
/testbed/sympy/crypto/tests/test_crypto.py:def test_decode_morse():
/testbed/sympy/crypto/tests/test_crypto.py:    assert decode_morse('-.-|.|-.--') == 'KEY'
/testbed/sympy/crypto/tests/test_crypto.py:    assert decode_morse('.-.|..-|-.||') == 'RUN'
/testbed/sympy/crypto/tests/test_crypto.py:    raises(KeyError, lambda: decode_morse('.....----'))
`````

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/sympy/crypto/crypto.py",
  "offset": 1290,
  "limit": 45
}
```

**tool result**

```

#################### RSA  #############################


def rsa_public_key(p, q, e):
    r"""
    Return the RSA *public key* pair, `(n, e)`, where `n`
    is a product of two primes and `e` is relatively
    prime (coprime) to the Euler totient `\phi(n)`. False
    is returned if any assumption is violated.

    Examples
    ========

    >>> from sympy.crypto.crypto import rsa_public_key
    >>> p, q, e = 3, 5, 7
    >>> rsa_public_key(p, q, e)
    (15, 7)
    >>> rsa_public_key(p, q, 30)
    False

    """
    n = p*q
    if isprime(p) and isprime(q):
        if p == q:
            SymPyDeprecationWarning(
                feature="Using non-distinct primes for rsa_public_key",
                useinstead="distinct primes",
                issue=16162,
                deprecated_since_version="1.4").warn()
            phi = p * (p - 1)
        else:
            phi = (p - 1) * (q - 1)
        if gcd(e, phi) == 1:
            return n, e
    return False


def rsa_private_key(p, q, e):
    r"""
    Return the RSA *private key*, `(n,d)`, where `n`
    is a product of two primes and `d` is the inverse of
    `e` (mod `\phi(n)`). False is returned if any assumption
    is violated.


[1193 more lines in /testbed/sympy/crypto/crypto.py (2527 in all). read_file with offset: 1335 to continue]
```

**assistant → tool `grep`**

```json
{
  "pattern": "morse_char = \\{",
  "path": "/testbed/sympy/crypto/crypto.py",
  "output_mode": "content",
  "head_limit": 1
}
```

**tool result**

```
/testbed/sympy/crypto/crypto.py:morse_char = {
```

**assistant → tool `grep`**

```json
{
  "pattern": "morse_char",
  "path": "/testbed/sympy/crypto/crypto.py",
  "output_mode": "content",
  "head_limit": 3
}
```

**tool result**

```
/testbed/sympy/crypto/crypto.py:morse_char = {
/testbed/sympy/crypto/crypto.py:char_morse = {v: k for k, v in morse_char.items()}
/testbed/sympy/crypto/crypto.py:    mapping = mapping or morse_char
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n -A20 '^morse_char' sympy/crypto/crypto.py"
}
```

**tool result**

```
1509:morse_char = {
1510-    ".-": "A", "-...": "B",
1511-    "-.-.": "C", "-..": "D",
1512-    ".": "E", "..-.": "F",
1513-    "--.": "G", "....": "H",
1514-    "..": "I", ".---": "J",
1515-    "-.-": "K", ".-..": "L",
1516-    "--": "M", "-.": "N",
1517-    "---": "O", ".--.": "P",
1518-    "--.-": "Q", ".-.": "R",
1519-    "...": "S", "-": "T",
1520-    "..-": "U", "...-": "V",
1521-    ".--": "W", "-..-": "X",
1522-    "-.--": "Y", "--..": "Z",
1523-    "-----": "0", "----": "1",
1524-    "..---": "2", "...--": "3",
1525-    "....-": "4", ".....": "5",
1526-    "-....": "6", "--...": "7",
1527-    "---..": "8", "----.": "9",
1528-    ".-.-.-": ".", "--..--": ",",
1529-    "---...": ":", "-.-.-.": ";",
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sympy/crypto/crypto.py\n@@\n-    \"-----\": \"0\", \"----\": \"1\",\n+    \"-----\": \"0\", \".----\": \"1\",\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sympy/crypto/crypto.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sympy/crypto/crypto.py now (2527 lines), around the change:
1520:    "..-": "U", "...-": "V",
1521:    ".--": "W", "-..-": "X",
1522:    "-.--": "Y", "--..": "Z",
1523:    "-----": "0", ".----": "1",
1524:    "..---": "2", "...--": "3",
1525:    "....-": "4", ".....": "5",
1526:    "-....": "6", "--...": "7",
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"from sympy.crypto.crypto import encode_morse, decode_morse; print(encode_morse('1')); print(decode_morse('.----')); print(encode_morse('0123456789'))\" && python -m pytest sympy/crypto/tests/test_crypto.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/testbed/sympy/solvers/diophantine.py:3185: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if feasible is 1:  # it's prime and k == 2
/testbed/sympy/plotting/plot.py:645: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if self.xscale is 'log':
/testbed/sympy/plotting/plot.py:674: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if self.xscale is 'log':
/testbed/sympy/plotting/plot.py:681: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if self.xscale is 'log':
.----
1
-----|.----|..---|...--|....-|.....|-....|--...|---..|----.
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport sympy.crypto.tests.test_crypto as t\nimport inspect\nfor name, fn in inspect.getmembers(t, inspect.isfunction):\n    if name.startswith('test_'):\n        fn()\nprint('all tests passed')\n\" 2>&1 | tail -5"
}
```

**tool result**

```
all tests passed
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n -A12 'def test_encode_morse' sympy/crypto/tests/test_crypto.py"
}
```

**tool result**

`````
241:def test_encode_morse():
242-    assert encode_morse('ABC') == '.-|-...|-.-.'
243-    assert encode_morse('SMS ') == '...|--|...||'
244-    assert encode_morse('SMS\n') == '...|--|...||'
245-    assert encode_morse('') == ''
246-    assert encode_morse(' ') == '||'
247-    assert encode_morse(' ', sep='`') == '``'
248-    assert encode_morse(' ', sep='``') == '````'
249-    assert encode_morse('!@#$%^&*()_+') == '-.-.--|.--.-.|...-..-|-.--.|-.--.-|..--.-|.-.-.'
250-
251-
252-def test_decode_morse():
253-    assert decode_morse('-.-|.|-.--') == 'KEY'
`````

**assistant → tool `apply_patch`**

`````json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sympy/crypto/tests/test_crypto.py\n@@\n     assert encode_morse(' ', sep='``') == '````'\n     assert encode_morse('!@#$%^&*()_+') == '-.-.--|.--.-.|...-..-|-.--.|-.--.-|..--.-|.-.-.'\n+    assert encode_morse('1') == '.----'\n@@\n def test_decode_morse():\n     assert decode_morse('-.-|.|-.--') == 'KEY'\n+    assert decode_morse('.----') == '1'\n*** End Patch\n"
}
`````

**tool result**

`````
Patch applied. added=[] modified=[/testbed/sympy/crypto/tests/test_crypto.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sympy/crypto/tests/test_crypto.py now (404 lines), around the change:
247:    assert encode_morse(' ', sep='`') == '``'
248:    assert encode_morse(' ', sep='``') == '````'
249:    assert encode_morse('!@#$%^&*()_+') == '-.-.--|.--.-.|...-..-|-.--.|-.--.-|..--.-|.-.-.'
250:    assert encode_morse('1') == '.----'
251:
252:
253:def test_decode_morse():
254:    assert decode_morse('-.-|.|-.--') == 'KEY'
255:    assert decode_morse('.----') == '1'
256:    assert decode_morse('.-.|..-|-.||') == 'RUN'
257:    raises(KeyError, lambda: decode_morse('.....----'))
258:
`````

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport sympy.crypto.tests.test_crypto as t\nimport inspect\nfor name, fn in inspect.getmembers(t, inspect.isfunction):\n    if name.startswith('test_'):\n        fn()\nprint('all crypto tests passed')\n\" 2>&1 | tail -3 && git diff --stat"
}
```

**tool result**

```
all crypto tests passed
 sympy/crypto/crypto.py            | 2 +-
 sympy/crypto/tests/test_crypto.py | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)
```

**assistant**

```
Fixed the Morse mapping for `"1"`.

**Changes:**
- `sympy/crypto/crypto.py`: changed `"----": "1"` to `".----": "1"` in `morse_char`.
- `sympy/crypto/tests/test_crypto.py`: added regression assertions that `encode_morse('1') == '.----'` and `decode_morse('.----') == '1'`.

**Verification:** `encode_morse('1')` now returns `.----`, `decode_morse('.----')` returns `1`, and the full crypto test module passes. No commits or tree changes beyond the working-tree edits.
```

## Run folder `team-solve-2026-11-06T134234`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
9ba7150ce0b8c4c3b23d6d83e4601210f4289e79
```

### `baseline-check.log`

```
check: python -m pytest sympy/crypto/tests/test_crypto.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

`````diff
diff --git a/sympy/crypto/crypto.py b/sympy/crypto/crypto.py
index ca552191c..0c556b6ef 100644
--- a/sympy/crypto/crypto.py
+++ b/sympy/crypto/crypto.py
@@ -1520,7 +1520,7 @@ def decipher_kid_rsa(msg, key):
     "..-": "U", "...-": "V",
     ".--": "W", "-..-": "X",
     "-.--": "Y", "--..": "Z",
-    "-----": "0", "----": "1",
+    "-----": "0", ".----": "1",
     "..---": "2", "...--": "3",
     "....-": "4", ".....": "5",
     "-....": "6", "--...": "7",
diff --git a/sympy/crypto/tests/test_crypto.py b/sympy/crypto/tests/test_crypto.py
index 6220e7d28..01fb4a1a5 100644
--- a/sympy/crypto/tests/test_crypto.py
+++ b/sympy/crypto/tests/test_crypto.py
@@ -247,10 +247,12 @@ def test_encode_morse():
     assert encode_morse(' ', sep='`') == '``'
     assert encode_morse(' ', sep='``') == '````'
     assert encode_morse('!@#$%^&*()_+') == '-.-.--|.--.-.|...-..-|-.--.|-.--.-|..--.-|.-.-.'
+    assert encode_morse('1') == '.----'
 
 
 def test_decode_morse():
     assert decode_morse('-.-|.|-.--') == 'KEY'
+    assert decode_morse('.----') == '1'
     assert decode_morse('.-.|..-|-.||') == 'RUN'
     raises(KeyError, lambda: decode_morse('.....----'))
`````

### `check-kind.txt`

```
judge
```

### `context.md`

````
# task.md

# Task

## Prompt

Morse encoding for "1" is not correct
The current Morse mapping in simpy.crypto.crypto contains an incorrect mapping of 
`"----": "1"`   

The correct mapping is `".----": "1"`.

## Deliverable

changes to this tree

## Check

`python -m pytest sympy/crypto/tests/test_crypto.py`

## Scope

`sympy/crypto/crypto.py`
`sympy/crypto/tests/`

## Done when

- The Morse mapping in `sympy/crypto/crypto.py` maps `".----"` to `"1"`.
- The incorrect mapping `"----": "1"` is no longer present.
- (inferred) `encode_morse('1')` returns `".----"` and `decode_morse('".----"')` returns `'1'`.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest sympy/crypto/tests/test_crypto.py`

## Scope
`sympy/crypto/crypto.py`
`sympy/crypto/tests/`

## Done when
- The Morse mapping in `sympy/crypto/crypto.py` maps `".----"` to `"1"`.
- The incorrect mapping `"----": "1"` is no longer present.
- (inferred) `encode_morse('1')` returns `".----"` and `decode_morse('".----"')` returns `'1'`.

## Approach
Decompose by locating the Morse character table in `sympy/crypto/crypto.py`, replacing only the digit-1 entry, and checking any surrounding Morse encode/decode behavior. Candidate approaches: (1) direct one-line dictionary correction, lowest risk; (2) search the tree for other `"----"` Morse mappings and correct only the digit-1 occurrence; (3) add or adjust a focused regression test in `sympy/crypto/tests/test_crypto.py` if existing coverage does not exercise digit `1`. Prefer the direct correction, then run the scoped crypto tests; if they do not cover the change, add the smallest regression test in the existing crypto test module.


# sympy/crypto/crypto.py

```
# -*- coding: utf-8 -*-

"""
This file contains some classical ciphers and routines
implementing a linear-feedback shift register (LFSR)
and the Diffie-Hellman key exchange.

.. warning::

   This module is intended for educational purposes only. Do not use the
   functions in this module for real cryptographic applications. If you wish
   to encrypt real data, we recommend using something like the `cryptography
   <https://cryptography.io/en/latest/>`_ module.

"""

from __future__ import print_function

from string import whitespace, ascii_uppercase as uppercase, printable

from sympy import nextprime
from sympy.core import Rational, Symbol
from sympy.core.numbers import igcdex, mod_inverse
from sympy.core.compatibility import range
from sympy.matrices import Matrix
from sympy.ntheory import isprime, totient, primitive_root
from sympy.polys.domains import FF
from sympy.polys.polytools import gcd, Poly
from sympy.utilities.misc import filldedent, translate
from sympy.utilities.iterables import uniq
from sympy.utilities.randtest import _randrange, _randint
from sympy.utilities.exceptions import SymPyDeprecationWarning


def AZ(s=None):
    """Return the letters of ``s`` in uppercase. In case more than
    one string is passed, each of them will be processed and a list
    of upper case strings will be returned.

    Examples
    ========

    >>> from sympy.crypto.crypto import AZ
    >>> AZ('Hello, world!')
    'HELLOWORLD'
    >>> AZ('Hello, world!'.split())
    ['HELLO', 'WORLD']

    See Also
    ========
    check_and_join
    """
    if not s:
        return uppercase
    t = type(s) is str
    if t:
        s = [s]
    rv = [check_and_join(i.upper().split(), uppercase, filter=True)
        for i in s]
    if t:
        return rv[0]
    return rv

bifid5 = AZ().replace('J', '')
bifid6 = AZ() + '0123456789'
bifid10 = printable


def padded_key(key, symbols, filter=True):
    """Return a string of the distinct characters of ``symbols`` with
    those of ``key`` appearing first, omitting characters in ``key``
    that are not in ``symbols``. A ValueError is raised if a) there are
    duplicate characters in ``symbols`` or b) there are characters
    in ``key`` that are  not in ``symbols``.

    Examples
    ========

    >>> from sympy.crypto.crypto import padded_key
    >>> padded_key('PUPPY', 'OPQRSTUVWXY')
    'PUYOQRSTVWX'
    >>> padded_key('RSA', 'ARTIST')
    Traceback (most recent call last):
    ...
    ValueError: duplicate characters in symbols: T
    """
    syms = list(uniq(symbols))
    if len(syms) != len(symbols):
        extra = ''.join(sorted(set(
            [i for i in symbols if symbols.count(i) > 1])))
        raise ValueError('duplicate characters in symbols: %s' % extra)
    extra = set(key) - set(syms)
    if extra:
        raise ValueError(
            'characters in key but not symbols: %s' % ''.join(
            sorted(extra)))
    key0 = ''.join(list(uniq(key)))
    return key0 + ''.join([i for i in syms if i not in key0])


def check_and_join(phrase, symbols=None, filter=None):
    """
    Joins characters of `phrase` and if ``symbols`` is given, raises
    an error if any character in ``phrase`` is not in ``symbols``.

    Parameters
    ==========

    phrase:     string or list of strings to be returned as a string
    symbols:    iterable of characters allowed in ``phrase``;
                if ``symbols`` is None, no checking is performed

    Examples
    ========

    >>> from sympy.crypto.crypto import check_and_join
    >>> check_and_join('a phrase')
    'a phrase'
    >>> check_and_join('a phrase'.upper().split())
    'APHRASE'
    >>> check_and_join('a phrase!'.upper().split(), 'ARE', filter=True)
    'ARAE'
    >>> check_and_join('a phrase!'.upper().split(), 'ARE')
    Traceback (most recent call last):
    ...
    ValueError: characters in phrase but not symbols: "!HPS"

    """
    rv = ''.join(''.join(phrase))
    if symbols is not None:
        symbols = check_and_join(symbols)
        missing = ''.join(list(sorted(set(rv) - set(symbols))))
        if missing:
            if not filter:
                raise ValueError(
                    'characters in phrase but not symbols: "%s"' % missing)
            rv = translate(rv, None, missing)
    return rv


def _prep(msg, key, alp, default=None):
    if not alp:
        if not default:
            alp = AZ()
            msg = AZ(msg)
            key = AZ(key)
        else:
            alp = default
    else:
        alp = ''.join(alp)
    key = check_and_join(key, alp, filter=True)
    msg = check_and_join(msg, alp, filter=True)
    return msg, key, alp


def cycle_list(k, n):
    """
    Returns the elements of the list ``range(n)`` shifted to the
    left by ``k`` (so the list starts with ``k`` (mod ``n``)).

    Examples
    ========

    >>> from sympy.crypto.crypto import cycle_list
    >>> cycle_list(3, 10)
    [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]

    """
    k = k % n
    return list(range(k, n)) + list(range(k))


######## shift cipher examples ############


def encipher_shift(msg, key, symbols=None):
    """
    Performs shift cipher encryption on plaintext msg, and returns the
    ciphertext.

    Notes
    =====

    The shift cipher is also called the Caesar cipher, after
    Julius Caesar, who, according to Suetonius, used it with a
    shift of three to protect messages of military significance.
    Caesar's nephew Augustus reportedly used a similar cipher, but
    with a right shift of 1.


    ALGORITHM:

        INPUT:

            ``key``: an integer (the secret key)

            ``msg``: plaintext of upper-case letters

        OUTPUT:

            ``ct``: ciphertext of upper-case letters

        STEPS:
            0. Number the letters of the alphabet from 0, ..., N
            1. Compute from the string ``msg`` a list ``L1`` of
               corresponding integers.
            2. Compute from the list ``L1`` a new list ``L2``, given by
               adding ``(k mod 26)`` to each element in ``L1``.
            3. Compute from the list ``L2`` a string ``ct`` of
               corresponding letters.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_shift, decipher_shift
    >>> msg = "GONAVYBEATARMY"
    >>> ct = encipher_shift(msg, 1); ct
    'HPOBWZCFBUBSNZ'

    To decipher the shifted text, change the sign of the key:

    >>> encipher_shift(ct, -1)
    'GONAVYBEATARMY'

    There is also a convenience function that does this with the
    original key:

    >>> decipher_shift(ct, 1)
    'GONAVYBEATARMY'
    """
    msg, _, A = _prep(msg, '', symbols)
    shift = len(A) - key % len(A)
    key = A[shift:] + A[:shift]
    return translate(msg, key, A)


def decipher_shift(msg, key, symbols=None):
    """
    Return the text by shifting the characters of ``msg`` to the
    left by the amount given by ``key``.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_shift, decipher_shift
    >>> msg = "GONAVYBEATARMY"
    >>> ct = encipher_shift(msg, 1); ct
    'HPOBWZCFBUBSNZ'

    To decipher the shifted text, change the sign of the key:

    >>> encipher_shift(ct, -1)
    'GONAVYBEATARMY'

    Or use this function with the original key:

    >>> decipher_shift(ct, 1)
    'GONAVYBEATARMY'
    """
    return encipher_shift(msg, -key, symbols)

def encipher_rot13(msg, symbols=None):
    """
    Performs the ROT13 encryption on a given plaintext ``msg``.

    Notes
    =====

    ROT13 is a substitution cipher which substitutes each letter
    in the plaintext message for the letter furthest away from it
    in the English alphabet.

    Equivalently, it is just a Caeser (shift) cipher with a shift
    key of 13 (midway point of the alphabet).

    See Also
    ========

    decipher_rot13
    """
    return encipher_shift(msg, 13, symbols)

def decipher_rot13(msg, symbols=None):
    """
    Performs the ROT13 decryption on a given plaintext ``msg``.

    Notes
    =====

    ``decipher_rot13`` is equivalent to ``encipher_rot13`` as both
    ``decipher_shift`` with a key of 13 and ``encipher_shift`` key with a
    key of 13 will return the same results. Nonetheless,
    ``decipher_rot13`` has nonetheless been explicitly defined here for
    consistency.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_rot13, decipher_rot13
    >>> msg = 'GONAVYBEATARMY'
    >>> ciphertext = encipher_rot13(msg);ciphertext
    'TBANILORNGNEZL'
    >>> decipher_rot13(ciphertext)
    'GONAVYBEATARMY'
    >>> encipher_rot13(msg) == decipher_rot13(msg)
    True
    >>> msg == decipher_rot13(ciphertext)
    True
    """
    return decipher_shift(msg, 13, symbols)

######## affine cipher examples ############


def encipher_affine(msg, key, symbols=None, _inverse=False):
    r"""
    Performs the affine cipher encryption on plaintext ``msg``, and
    returns the ciphertext.

    Encryption is based on the map `x \rightarrow ax+b` (mod `N`)
    where ``N`` is the number of characters in the alphabet.
    Decryption is based on the map `x \rightarrow cx+d` (mod `N`),
    where `c = a^{-1}` (mod `N`) and `d = -a^{-1}b` (mod `N`).
    In particular, for the map to be invertible, we need
    `\mathrm{gcd}(a, N) = 1` and an error will be raised if this is
    not true.

    Notes
    =====

    This is a straightforward generalization of the shift cipher with
    the added complexity of requiring 2 characters to be deciphered in
    order to recover the key.

    ALGORITHM:

        INPUT:

            ``msg``: string of characters that appear in ``symbols``

            ``a, b``: a pair integers, with ``gcd(a, N) = 1``
            (the secret key)

            ``symbols``: string of characters (default = uppercase
            letters). When no symbols are given, ``msg`` is converted
            to upper case letters and all other charactes are ignored.

        OUTPUT:

            ``ct``: string of characters (the ciphertext message)

        STEPS:
            0. Number the letters of the alphabet from 0, ..., N
            1. Compute from the string ``msg`` a list ``L1`` of
               corresponding integers.
            2. Compute from the list ``L1`` a new list ``L2``, given by
               replacing ``x`` by ``a*x + b (mod N)``, for each element
               ``x`` in ``L1``.
            3. Compute from the list ``L2`` a string ``ct`` of
               corresponding letters.

    See Also
    ========
    decipher_affine

    """
    msg, _, A = _prep(msg, '', symbols)
    N = len(A)
    a, b = key
    assert gcd(a, N) == 1
    if _inverse:
        c = mod_inverse(a, N)
        d = -b*c
        a, b = c, d
    B = ''.join([A[(a*i + b) % N] for i in range(N)])
    return translate(msg, A, B)


def decipher_affine(msg, key, symbols=None):
    r"""
    Return the deciphered text that was made from the mapping,
    `x \rightarrow ax+b` (mod `N`), where ``N`` is the
    number of characters in the alphabet. Deciphering is done by
    reciphering with a new key: `x \rightarrow cx+d` (mod `N`),
    where `c = a^{-1}` (mod `N`) and `d = -a^{-1}b` (mod `N`).

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_affine, decipher_affine
    >>> msg = "GO NAVY BEAT ARMY"
    >>> key = (3, 1)
    >>> encipher_affine(msg, key)
    'TROBMVENBGBALV'
    >>> decipher_affine(_, key)
    'GONAVYBEATARMY'

    """
    return encipher_affine(msg, key, symbols, _inverse=True)

def encipher_atbash(msg, symbols=None):
    r"""
    Enciphers a given ``msg`` into its Atbash ciphertext and returns it.

    Notes
    =====

    Atbash is a substitution cipher originally used to encrypt the Hebrew
    alphabet. Atbash works on the principle of mapping each alphabet to its
    reverse / counterpart (i.e. a would map to z, b to y etc.)

    Atbash is functionally equivalent to the affine cipher with ``a = 25``
    and ``b = 25``

    See Also
    ========

    decipher_atbash
    """
    return encipher_affine(msg, (25,25), symbols)

def decipher_atbash(msg, symbols=None):
    r"""
    Deciphers a given ``msg`` using Atbash cipher and returns it.

    Notes
    =====

    ``decipher_atbash`` is functionally equivalent to ``encipher_atbash``.
    However, it has still been added as a separate function to maintain
    consistency.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_atbash, decipher_atbash
    >>> msg = 'GONAVYBEATARMY'
    >>> encipher_atbash(msg)
    'TLMZEBYVZGZINB'
    >>> decipher_atbash(msg)
    'TLMZEBYVZGZINB'
    >>> encipher_atbash(msg) == decipher_atbash(msg)
    True
    >>> msg == encipher_atbash(encipher_atbash(msg))
    True
    """
    return decipher_affine(msg, (25,25), symbols)

#################### substitution cipher ###########################


def encipher_substitution(msg, old, new=None):
    r"""
    Returns the ciphertext obtained by replacing each character that
    appears in ``old`` with the corresponding character in ``new``.
    If ``old`` is a mapping, then new is ignored and the replacements
    defined by ``old`` are used.

    Notes
    =====

    This is a more general than the affine cipher in that the key can
    only be recovered by determining the mapping for each symbol.
    Though in practice, once a few symbols are recognized the mappings
    for other characters can be quickly guessed.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_substitution, AZ
    >>> old = 'OEYAG'
    >>> new = '034^6'
    >>> msg = AZ("go navy! beat army!")
    >>> ct = encipher_substitution(msg, old, new); ct
    '60N^V4B3^T^RM4'

    To decrypt a substitution, reverse the last two arguments:

    >>> encipher_substitution(ct, new, old)
    'GONAVYBEATARMY'

    In the special case where ``old`` and ``new`` are a permutation of
    order 2 (representing a transposition of characters) their order
    is immaterial:

    >>> old = 'NAVY'
    >>> new = 'ANYV'
    >>> encipher = lambda x: encipher_substitution(x, old, new)
    >>> encipher('NAVY')
    'ANYV'
    >>> encipher(_)
    'NAVY'

    The substitution cipher, in general, is a method
    whereby "units" (not necessarily single characters) of plaintext
    are replaced with ciphertext according to a regular system.

    >>> ords = dict(zip('abc', ['\\%i' % ord(i) for i in 'abc']))
    >>> print(encipher_substitution('abc', ords))
    \97\98\99
    """
    return translate(msg, old, new)


######################################################################
#################### Vigenère cipher examples ########################
######################################################################

def encipher_vigenere(msg, key, symbols=None):
    """
    Performs the Vigenère cipher encryption on plaintext ``msg``, and
    returns the ciphertext.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_vigenere, AZ
    >>> key = "encrypt"
    >>> msg = "meet me on monday"
    >>> encipher_vigenere(msg, key)
    'QRGKKTHRZQEBPR'

    Section 1 of the Kryptos sculpture at the CIA headquarters
    uses this cipher and also changes the order of the the
    alphabet [2]_. Here is the first line of that section of
    the sculpture:

    >>> from sympy.crypto.crypto import decipher_vigenere, padded_key
    >>> alp = padded_key('KRYPTOS', AZ())
    >>> key = 'PALIMPSEST'
    >>> msg = 'EMUFPHZLRFAXYUSDJKZLDKRNSHGNFIVJ'
    >>> decipher_vigenere(msg, key, alp)
    'BETWEENSUBTLESHADINGANDTHEABSENC'

    Notes
    =====

    The Vigenère cipher is named after Blaise de Vigenère, a sixteenth
    century diplomat and cryptographer, by a historical accident.
    Vigenère actually invented a different and more complicated cipher.
    The so-called *Vigenère cipher* was actually invented
    by Giovan Batista Belaso in 1553.

    This cipher was used in the 1800's, for example, during the American
    Civil War. The Confederacy used a brass cipher disk to implement the
    Vigenère cipher (now on display in the NSA Museum in Fort
    Meade) [1]_.

    The Vigenère cipher is a generalization of the shift cipher.
    Whereas the shift cipher shifts each letter by the same amount
    (that amount being the key of the shift cipher) the Vigenère
    cipher shifts a letter by an amount determined by the key (which is
    a word or phrase known only to the sender and receiver).

    For example, if the key was a single letter, such as "C", then the
    so-called Vigenere cipher is actually a shift cipher with a
    shift of `2` (since "C" is the 2nd letter of the alphabet, if
    you start counting at `0`). If the key was a word with two
    letters, such as "CA", then the so-called Vigenère cipher will
    shift letters in even positions by `2` and letters in odd positions
    are left alone (shifted by `0`, since "A" is the 0th letter, if
    you start counting at `0`).


    ALGORITHM:

        INPUT:

            ``msg``: string of characters that appear in ``symbols``
            (the plaintext)

            ``key``: a string of characters that appear in ``symbols``
            (the secret key)

            ``symbols``: a string of letters defining the alphabet


        OUTPUT:

            ``ct``: string of characters (the ciphertext message)

        STEPS:
            0. Number the letters of the alphabet from 0, ..., N
            1. Compute from the string ``key`` a list ``L1`` of
               corresponding integers. Let ``n1 = len(L1)``.
            2. Compute from the string ``msg`` a list ``L2`` of
               corresponding integers. Let ``n2 = len(L2)``.
            3. Break ``L2`` up sequentially into sublists of size
               ``n1``; the last sublist may be smaller than ``n1``
            4. For each of these sublists ``L`` of ``L2``, compute a
               new list ``C`` given by ``C[i] = L[i] + L1[i] (mod N)``
               to the ``i``-th element in the sublist, for each ``i``.
            5. Assemble these lists ``C`` by concatenation into a new
               list of length ``n2``.
            6. Compute from the new list a string ``ct`` of
               corresponding letters.

    Once it is known that the key is, say, `n` characters long,
    frequency analysis can be applied to every `n`-th letter of
    the ciphertext to determine the plaintext. This method is
    called *Kasiski examination* (although it was first discovered
    by Babbage). If they key is as long as the message and is
    comprised of randomly selected characters -- a one-time pad -- the
    message is theoretically unbreakable.

    The cipher Vigenère actually discovered is an "auto-key" cipher
    described as follows.

    ALGORITHM:

        INPUT:

          ``key``: a string of letters (the secret key)

          ``msg``: string of letters (the plaintext message)

        OUTPUT:

          ``ct``: string of upper-case letters (the ciphertext message)

        STEPS:
            0. Number the letters of the alphabet from 0, ..., N
            1. Compute from the string ``msg`` a list ``L2`` of
               corresponding integers. Let ``n2 = len(L2)``.
            2. Let ``n1`` be the length of the key. Append to the
               string ``key`` the first ``n2 - n1`` characters of
               the plaintext message. Compute from this string (also of
               length ``n2``) a list ``L1`` of integers corresponding
               to the letter numbers in the first step.
            3. Compute a new list ``C`` given by
               ``C[i] = L1[i] + L2[i] (mod N)``.
            4. Compute from the new list a string ``ct`` of letters
               corresponding to the new integers.

    To decipher the auto-key ciphertext, the key is used to decipher
    the first ``n1`` characters and then those characters become the
    key to  decipher the next ``n1`` characters, etc...:

    >>> m = AZ('go navy, beat army! yes you can'); m
    'GONAVYBEATARMYYESYOUCAN'
    >>> key = AZ('gold bug'); n1 = len(key); n2 = len(m)
    >>> auto_key = key + m[:n2 - n1]; auto_key
    'GOLDBUGGONAVYBEATARMYYE'
    >>> ct = encipher_vigenere(m, auto_key); ct
    'MCYDWSHKOGAMKZCELYFGAYR'
    >>> n1 = len(key)
    >>> pt = []
    >>> while ct:
    ...     part, ct = ct[:n1], ct[n1:]
    ...     pt.append(decipher_vigenere(part, key))
    ...     key = pt[-1]
    ...
    >>> ''.join(pt) == m
    True

    References
    ==========

    .. [1] https://en.wikipedia.org/wiki/Vigenere_cipher
    .. [2] http://web.archive.org/web/20071116100808/
       http://filebox.vt.edu/users/batman/kryptos.html
       (short URL: https://goo.gl/ijr22d)

    """
    msg, key, A = _prep(msg, key, symbols)
    map = {c: i for i, c in enumerate(A)}
    key = [map[c] for c in key]
    N = len(map)
    k = len(key)
    rv = []
    for i, m in enumerate(msg):
        rv.append(A[(map[m] + key[i % k]) % N])
    rv = ''.join(rv)
    return rv


def decipher_vigenere(msg, key, symbols=None):
    """
    Decode using the Vigenère cipher.

    Examples
    ========

    >>> from sympy.crypto.crypto import decipher_vigenere
    >>> key = "encrypt"
    >>> ct = "QRGK kt HRZQE BPR"
    >>> decipher_vigenere(ct, key)
    'MEETMEONMONDAY'
    """
    msg, key, A = _prep(msg, key, symbols)
    map = {c: i for i, c in enumerate(A)}
    N = len(A)   # normally, 26
    K = [map[c] for c in key]
    n = len(K)
    C = [map[c] for c in msg]
    rv = ''.join([A[(-K[i % n] + c) % N] for i, c in enumerate(C)])
    return rv


#################### Hill cipher  ########################


def encipher_hill(msg, key, symbols=None, pad="Q"):
    r"""
    Return the Hill cipher encryption of ``msg``.

    Notes
    =====

    The Hill cipher [1]_, invented by Lester S. Hill in the 1920's [2]_,
    was the first polygraphic cipher in which it was practical
    (though barely) to operate on more than three symbols at once.
    The following discussion assumes an elementary knowledge of
    matrices.

    First, each letter is first encoded as a number starting with 0.
    Suppose your message `msg` consists of `n` capital letters, with no
    spaces. This may be regarded an `n`-tuple M of elements of
    `Z_{26}` (if the letters are those of the English alphabet). A key
    in the Hill cipher is a `k x k` matrix `K`, all of whose entries
    are in `Z_{26}`, such that the matrix `K` is invertible (i.e., the
    linear transformation `K: Z_{N}^k \rightarrow Z_{N}^k`
    is one-to-one).

    ALGORITHM:

        INPUT:

            ``msg``: plaintext message of `n` upper-case letters

            ``key``: a `k x k` invertible matrix `K`, all of whose
            entries are in `Z_{26}` (or whatever number of symbols
            are being used).

            ``pad``: character (default "Q") to use to make length
            of text be a multiple of ``k``

        OUTPUT:

            ``ct``: ciphertext of upper-case letters

        STEPS:
            0. Number the letters of the alphabet from 0, ..., N
            1. Compute from the string ``msg`` a list ``L`` of
               corresponding integers. Let ``n = len(L)``.
            2. Break the list ``L`` up into ``t = ceiling(n/k)``
               sublists ``L_1``, ..., ``L_t`` of size ``k`` (with
               the last list "padded" to ensure its size is
               ``k``).
            3. Compute new list ``C_1``, ..., ``C_t`` given by
               ``C[i] = K*L_i`` (arithmetic is done mod N), for each
               ``i``.
            4. Concatenate these into a list ``C = C_1 + ... + C_t``.
            5. Compute from ``C`` a string ``ct`` of corresponding
               letters. This has length ``k*t``.

    References
    ==========

    .. [1] en.wikipedia.org/wiki/Hill_cipher
    .. [2] Lester S. Hill, Cryptography in an Algebraic Alphabet,
       The American Mathematical Monthly Vol.36, June-July 1929,
       pp.306-312.

    See Also
    ========
    decipher_hill

    """
    assert key.is_square
    assert len(pad) == 1
    msg, pad, A = _prep(msg, pad, symbols)
    map = {c: i for i, c in enumerate(A)}
    P = [map[c] for c in msg]
    N = len(A)
    k = key.cols
    n = len(P)
    m, r = divmod(n, k)
    if r:
        P = P + [map[pad]]*(k - r)
        m += 1
    rv = ''.join([A[c % N] for j in range(m) for c in
        list(key*Matrix(k, 1, [P[i]
        for i in range(k*j, k*(j + 1))]))])
    return rv


def decipher_hill(msg, key, symbols=None):
    """
    Deciphering is the same as enciphering but using the inverse of the
    key matrix.

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_hill, decipher_hill
    >>> from sympy import Matrix

    >>> key = Matrix([[1, 2], [3, 5]])
    >>> encipher_hill("meet me on monday", key)
    'UEQDUEODOCTCWQ'
    >>> decipher_hill(_, key)
    'MEETMEONMONDAY'

    When the length of the plaintext (stripped of invalid characters)
    is not a multiple of the key dimension, extra characters will
    appear at the end of the enciphered and deciphered text. In order to
    decipher the text, those characters must be included in the text to
    be deciphered. In the following, the key has a dimension of 4 but
    the text is 2 short of being a multiple of 4 so two characters will
    be added.

    >>> key = Matrix([[1, 1, 1, 2], [0, 1, 1, 0],
    ...               [2, 2, 3, 4], [1, 1, 0, 1]])
    >>> msg = "ST"
    >>> encipher_hill(msg, key)
    'HJEB'
    >>> decipher_hill(_, key)
    'STQQ'
    >>> encipher_hill(msg, key, pad="Z")
    'ISPK'
    >>> decipher_hill(_, key)
    'STZZ'

    If the last two characters of the ciphertext were ignored in
    either case, the wrong plaintext would be recovered:

    >>> decipher_hill("HD", key)
    'ORMV'
    >>> decipher_hill("IS", key)
    'UIKY'

    """
    assert key.is_square
    msg, _, A = _prep(msg, '', symbols)
    map = {c: i for i, c in enumerate(A)}
    C = [map[c] for c in msg]
    N = len(A)
    k = key.cols
    n = len(C)
    m, r = divmod(n, k)
    if r:
        C = C + [0]*(k - r)
        m += 1
    key_inv = key.inv_mod(N)
    rv = ''.join([A[p % N] for j in range(m) for p in
        list(key_inv*Matrix(
        k, 1, [C[i] for i in range(k*j, k*(j + 1))]))])
    return rv


#################### Bifid cipher  ########################


def encipher_bifid(msg, key, symbols=None):
    r"""
    Performs the Bifid cipher encryption on plaintext ``msg``, and
    returns the ciphertext.

    This is the version of the Bifid cipher that uses an `n \times n`
    Polybius square.

        INPUT:

            ``msg``: plaintext string

            ``key``: short string for key; duplicate characters are
            ignored and then it is padded with the characters in
            ``symbols`` that were not in the short key

            ``symbols``: `n \times n` characters defining the alphabet
            (default is string.printable)

        OUTPUT:

            ciphertext (using Bifid5 cipher without spaces)

    See Also
    ========
    decipher_bifid, encipher_bifid5, encipher_bifid6

    """
    msg, key, A = _prep(msg, key, symbols, bifid10)
    long_key = ''.join(uniq(key)) or A

    n = len(A)**.5
    if n != int(n):
        raise ValueError(
            'Length of alphabet (%s) is not a square number.' % len(A))
    N = int(n)
    if len(long_key) < N**2:
      long_key = list(long_key) + [x for x in A if x not in long_key]

    # the fractionalization
    row_col = {ch: divmod(i, N) for i, ch in enumerate(long_key)}
    r, c = zip(*[row_col[x] for x in msg])
    rc = r + c
    ch = {i: ch for ch, i in row_col.items()}
    rv = ''.join((ch[i] for i in zip(rc[::2], rc[1::2])))
    return rv


def decipher_bifid(msg, key, symbols=None):
    r"""
    Performs the Bifid cipher decryption on ciphertext ``msg``, and
    returns the plaintext.

    This is the version of the Bifid cipher that uses the `n \times n`
    Polybius square.

        INPUT:

            ``msg``: ciphertext string

            ``key``: short string for key; duplicate characters are
            ignored and then it is padded with the characters in
            ``symbols`` that were not in the short key

            ``symbols``: `n \times n` characters defining the alphabet
            (default=string.printable, a `10 \times 10` matrix)

        OUTPUT:

            deciphered text

    Examples
    ========

    >>> from sympy.crypto.crypto import (
    ...     encipher_bifid, decipher_bifid, AZ)

    Do an encryption using the bifid5 alphabet:

    >>> alp = AZ().replace('J', '')
    >>> ct = AZ("meet me on monday!")
    >>> key = AZ("gold bug")
    >>> encipher_bifid(ct, key, alp)
    'IEILHHFSTSFQYE'

    When entering the text or ciphertext, spaces are ignored so it
    can be formatted as desired. Re-entering the ciphertext from the
    preceding, putting 4 characters per line and padding with an extra
    J, does not cause problems for the deciphering:

    >>> decipher_bifid('''
    ... IEILH
    ... HFSTS
    ... FQYEJ''', key, alp)
    'MEETMEONMONDAY'

    When no alphabet is given, all 100 printable characters will be
    used:

    >>> key = ''
    >>> encipher_bifid('hello world!', key)
    'bmtwmg-bIo*w'
    >>> decipher_bifid(_, key)
    'hello world!'

    If the key is changed, a different encryption is obtained:

    >>> key = 'gold bug'
    >>> encipher_bifid('hello world!', 'gold_bug')
    'hg2sfuei7t}w'

    And if the key used to decrypt the message is not exact, the
    original text will not be perfectly obtained:

    >>> decipher_bifid(_, 'gold pug')
    'heldo~wor6d!'

    """
    msg, _, A = _prep(msg, '', symbols, bifid10)
    long_key = ''.join(uniq(key)) or A

    n = len(A)**.5
    if n != int(n):
        raise ValueError(
            'Length of alphabet (%s) is not a square number.' % len(A))
    N = int(n)
    if len(long_key) < N**2:
        long_key = list(long_key) + [x for x in A if x not in long_key]

    # the reverse fractionalization
    row_col = dict(
        [(ch, divmod(i, N)) for i, ch in enumerate(long_key)])
    rc = [i for c in msg for i in row_col[c]]
    n = len(msg)
    rc = zip(*(rc[:n], rc[n:]))
    ch = {i: ch for ch, i in row_col.items()}
    rv = ''.join((ch[i] for i in rc))
    return rv


def bifid_square(key):
    """Return characters of ``key`` arranged in a square.

    Examples
    ========

    >>> from sympy.crypto.crypto import (
    ...    bifid_square, AZ, padded_key, bifid5)
    >>> bifid_square(AZ().replace('J', ''))
    Matrix([
    [A, B, C, D, E],
    [F, G, H, I, K],
    [L, M, N, O, P],
    [Q, R, S, T, U],
    [V, W, X, Y, Z]])

    >>> bifid_square(padded_key(AZ('gold bug!'), bifid5))
    Matrix([
    [G, O, L, D, B],
    [U, A, C, E, F],
    [H, I, K, M, N],
    [P, Q, R, S, T],
    [V, W, X, Y, Z]])

    See Also
    ========
    padded_key
    """
    A = ''.join(uniq(''.join(key)))
    n = len(A)**.5
    if n != int(n):
        raise ValueError(
            'Length of alphabet (%s) is not a square number.' % len(A))
    n = int(n)
    f = lambda i, j: Symbol(A[n*i + j])
    rv = Matrix(n, n, f)
    return rv


def encipher_bifid5(msg, key):
    r"""
    Performs the Bifid cipher encryption on plaintext ``msg``, and
    returns the ciphertext.

    This is the version of the Bifid cipher that uses the `5 \times 5`
    Polybius square. The letter "J" is ignored so it must be replaced
    with something else (traditionally an "I") before encryption.

    Notes
    =====

    The Bifid cipher was invented around 1901 by Felix Delastelle.
    It is a *fractional substitution* cipher, where letters are
    replaced by pairs of symbols from a smaller alphabet. The
    cipher uses a `5 \times 5` square filled with some ordering of the
    alphabet, except that "J" is replaced with "I" (this is a so-called
    Polybius square; there is a `6 \times 6` analog if you add back in
    "J" and also append onto the usual 26 letter alphabet, the digits
    0, 1, ..., 9).
    According to Helen Gaines' book *Cryptanalysis*, this type of cipher
    was used in the field by the German Army during World War I.

    ALGORITHM: (5x5 case)

        INPUT:

            ``msg``: plaintext string; converted to upper case and
            filtered of anything but all letters except J.

            ``key``: short string for key; non-alphabetic letters, J
            and duplicated characters are ignored and then, if the
            length is less than 25 characters, it is padded with other
            letters of the alphabet (in alphabetical order).

        OUTPUT:

            ciphertext (all caps, no spaces)

        STEPS:
            0. Create the `5 \times 5` Polybius square ``S`` associated
               to ``key`` as follows:

                a) moving from left-to-right, top-to-bottom,
                   place the letters of the key into a `5 \times 5`
                   matrix,
                b) if the key has less than 25 letters, add the
                   letters of the alphabet not in the key until the
                   `5 \times 5` square is filled.

            1. Create a list ``P`` of pairs of numbers which are the
               coordinates in the Polybius square of the letters in
               ``msg``.
            2. Let ``L1`` be the list of all first coordinates of ``P``
               (length of ``L1 = n``), let ``L2`` be the list of all
               second coordinates of ``P`` (so the length of ``L2``
               is also ``n``).
            3. Let ``L`` be the concatenation of ``L1`` and ``L2``
               (length ``L = 2*n``), except that consecutive numbers
               are paired ``(L[2*i], L[2*i + 1])``. You can regard
               ``L`` as a list of pairs of length ``n``.
            4. Let ``C`` be the list of all letters which are of the
               form ``S[i, j]``, for all ``(i, j)`` in ``L``. As a
               string, this is the ciphertext of ``msg``.

    Examples
    ========

    >>> from sympy.crypto.crypto import (
    ...     encipher_bifid5, decipher_bifid5)

    "J" will be omitted unless it is replaced with something else:

    >>> round_trip = lambda m, k: \
    ...     decipher_bifid5(encipher_bifid5(m, k), k)
    >>> key = 'a'
    >>> msg = "JOSIE"
    >>> round_trip(msg, key)
    'OSIE'
    >>> round_trip(msg.replace("J", "I"), key)
    'IOSIE'
    >>> j = "QIQ"
    >>> round_trip(msg.replace("J", j), key).replace(j, "J")
    'JOSIE'

    See Also
    ========
    decipher_bifid5, encipher_bifid

    """
    msg, key, _ = _prep(msg.upper(), key.upper(), None, bifid5)
    key = padded_key(key, bifid5)
    return encipher_bifid(msg, '', key)


def decipher_bifid5(msg, key):
    r"""
    Return the Bifid cipher decryption of ``msg``.

    This is the version of the Bifid cipher that uses the `5 \times 5`
    Polybius square; the letter "J" is ignored unless a ``key`` of
    length 25 is used.

    INPUT:

        ``msg``: ciphertext string

        ``key``: short string for key; duplicated characters are
        ignored and if the length is less then 25 characters, it
        will be padded with other letters from the alphabet omitting
        "J". Non-alphabetic characters are ignored.

    OUTPUT:

        plaintext from Bifid5 cipher (all caps, no spaces)

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_bifid5, decipher_bifid5
    >>> key = "gold bug"
    >>> encipher_bifid5('meet me on friday', key)
    'IEILEHFSTSFXEE'
    >>> encipher_bifid5('meet me on monday', key)
    'IEILHHFSTSFQYE'
    >>> decipher_bifid5(_, key)
    'MEETMEONMONDAY'

    """
    msg, key, _ = _prep(msg.upper(), key.upper(), None, bifid5)
    key = padded_key(key, bifid5)
    return decipher_bifid(msg, '', key)


def bifid5_square(key=None):
    r"""
    5x5 Polybius square.

    Produce the Polybius square for the `5 \times 5` Bifid cipher.

    Examples
    ========

    >>> from sympy.crypto.crypto import bifid5_square
    >>> bifid5_square("gold bug")
    Matrix([
    [G, O, L, D, B],
    [U, A, C, E, F],
    [H, I, K, M, N],
    [P, Q, R, S, T],
    [V, W, X, Y, Z]])

    """
    if not key:
        key = bifid5
    else:
        _, key, _ = _prep('', key.upper(), None, bifid5)
        key = padded_key(key, bifid5)
    return bifid_square(key)


def encipher_bifid6(msg, key):
    r"""
    Performs the Bifid cipher encryption on plaintext ``msg``, and
    returns the ciphertext.

    This is the version of the Bifid cipher that uses the `6 \times 6`
    Polybius square.

    INPUT:

        ``msg``: plaintext string (digits okay)

        ``key``: short string for key (digits okay). If ``key`` is
        less than 36 characters long, the square will be filled with
        letters A through Z and digits 0 through 9.

    OUTPUT:

        ciphertext from Bifid cipher (all caps, no spaces)

    See Also
    ========
    decipher_bifid6, encipher_bifid

    """
    msg, key, _ = _prep(msg.upper(), key.upper(), None, bifid6)
    key = padded_key(key, bifid6)
    return encipher_bifid(msg, '', key)


def decipher_bifid6(msg, key):
    r"""
    Performs the Bifid cipher decryption on ciphertext ``msg``, and
    returns the plaintext.

    This is the version of the Bifid cipher that uses the `6 \times 6`
    Polybius square.

    INPUT:

        ``msg``: ciphertext string (digits okay); converted to upper case

        ``key``: short string for key (digits okay). If ``key`` is
        less than 36 characters long, the square will be filled with
        letters A through Z and digits 0 through 9. All letters are
        converted to uppercase.

    OUTPUT:

        plaintext from Bifid cipher (all caps, no spaces)

    Examples
    ========

    >>> from sympy.crypto.crypto import encipher_bifid6, decipher_bifid6
    >>> key = "gold bug"
    >>> encipher_bifid6('meet me on monday at 8am', key)
    'KFKLJJHF5MMMKTFRGPL'
    >>> decipher_bifid6(_, key)
    'MEETMEONMONDAYAT8AM'

    """
    msg, key, _ = _prep(msg.upper(), key.upper(), None, bifid6)
    key = padded_key(key, bifid6)
    return decipher_bifid(msg, '', key)


def bifid6_square(key=None):
    r"""
    6x6 Polybius square.

    Produces the Polybius square for the `6 \times 6` Bifid cipher.
    Assumes alphabet of symbols is "A", ..., "Z", "0", ..., "9".

    Examples
    ========

    >>> from sympy.crypto.crypto import bifid6_square
    >>> key = "gold bug"
    >>> bifid6_square(key)
    Matrix([
    [G, O, L, D, B, U],
    [A, C, E, F, H, I],
    [J, K, M, N, P, Q],
    [R, S, T, V, W, X],
    [Y, Z, 0, 1, 2, 3],
    [4, 5, 6, 7, 8, 9]])
    """
    if not key:
        key = bifid6
    else:
        _, key, _ = _prep('', key.upper(), None, bifid6)
        key = padded_key(key, bifid6)
    return bifid_square(key)


#################### RSA  #############################


def rsa_public_key(p, q, e):
    r"""
    Return the RSA *public key* pair, `(n, e)`, where `n`
    is a product of two primes and `e` is relatively
    prime (coprime) to the Euler totient `\phi(n)`. False
    is returned if any assumption is violated.

    Examples
    ========

    >>> from sympy.crypto.crypto import rsa_public_key
    >>> p, q, e = 3, 5, 7
    >>> rsa_public_key(p, q, e)
    (15, 7)
    >>> rsa_public_key(p, q, 30)
    False

    """
    n = p*q
    if isprime(p) and isprime(q):
        if p == q:
            SymPyDeprecationWarning(
                feature="Using non-distinct primes for rsa_public_key",
                useinstead="distinct primes",
                issue=16162,
                deprecated_since_version="1.4").warn()
            phi = p * (p - 1)
        else:
            phi = (p - 1) * (q - 1)
        if gcd(e, phi) == 1:
            return n, e
    return False


def rsa_private_key(p, q, e):
    r"""
    Return the RSA *private key*, `(n,d)`, where `n`
    is a product of two primes and `d` is the inverse of
    `e` (mod `\phi(n)`). False is returned if any assumption
    is violated.

    Examples
    ========

    
```


# sympy/crypto/tests (the files in it)

sympy/crypto/tests/__init__.py
sympy/crypto/tests/test_crypto.py


# The last commit

```
9ba7150ce SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest sympy/crypto/tests/test_crypto.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/crypto/crypto.py sympy/crypto/tests
changed: sympy/crypto/crypto.py +1 -1
changed: sympy/crypto/tests/test_crypto.py +2 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

`````diff
diff --git a/sympy/crypto/crypto.py b/sympy/crypto/crypto.py
index ca552191c..0c556b6ef 100644
--- a/sympy/crypto/crypto.py
+++ b/sympy/crypto/crypto.py
@@ -1520,7 +1520,7 @@ def decipher_kid_rsa(msg, key):
     "..-": "U", "...-": "V",
     ".--": "W", "-..-": "X",
     "-.--": "Y", "--..": "Z",
-    "-----": "0", "----": "1",
+    "-----": "0", ".----": "1",
     "..---": "2", "...--": "3",
     "....-": "4", ".....": "5",
     "-....": "6", "--...": "7",
diff --git a/sympy/crypto/tests/test_crypto.py b/sympy/crypto/tests/test_crypto.py
index 6220e7d28..01fb4a1a5 100644
--- a/sympy/crypto/tests/test_crypto.py
+++ b/sympy/crypto/tests/test_crypto.py
@@ -247,10 +247,12 @@ def test_encode_morse():
     assert encode_morse(' ', sep='`') == '``'
     assert encode_morse(' ', sep='``') == '````'
     assert encode_morse('!@#$%^&*()_+') == '-.-.--|.--.-.|...-..-|-.--.|-.--.-|..--.-|.-.-.'
+    assert encode_morse('1') == '.----'
 
 
 def test_decode_morse():
     assert decode_morse('-.-|.|-.--') == 'KEY'
+    assert decode_morse('.----') == '1'
     assert decode_morse('.-.|..-|-.||') == 'RUN'
     raises(KeyError, lambda: decode_morse('.....----'))
`````

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
check: python -m pytest sympy/crypto/tests/test_crypto.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/crypto/crypto.py sympy/crypto/tests
changed: sympy/crypto/crypto.py +1 -1
changed: sympy/crypto/tests/test_crypto.py +2 -0
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
# Notes, run 2026-11-06T134234

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Morse encoding for "1" is not correct
The current Morse mapping in simpy.crypto.crypto contains an incorrect mapping of 
`"----": "1"`   

The correct mapping is `".----": "1"`.


# The files of the project

```
.ci/README.rst
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
bin/test_executable.py
bin/test_external_imports.py
bin/test_import
bin/test_import.py
bin/test_isolated
bin/test_setup.py
bin/test_travis.sh
codecov.yml
conftest.py
coveragerc_travis
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
doc/src/modules/algebras.rst
doc/src/modules/assumptions/ask.rst
doc/src/modules/assumptions/assume.rst
doc/src/modules/assumptions/handlers/calculus.rst
doc/src/modules/assumptions/handlers/common.rst
doc/src/modules/assumptions/handlers/index.rst
doc/src/modules/assumptions/handlers/matrices.rst
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
doc/src/modules/matrices/common.rst
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
pytest.ini
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
sympy/codegen/array_utils.py
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
sympy/codegen/tests/test_array_utils.py
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
```


# The last commit

```
9ba7150ce SWE-bench


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
`python -m pytest sympy/crypto/tests/test_crypto.py`

## Scope
`sympy/crypto/crypto.py`
`sympy/crypto/tests/`

## Done when
- The Morse mapping in `sympy/crypto/crypto.py` maps `".----"` to `"1"`.
- The incorrect mapping `"----": "1"` is no longer present.
- (inferred) `encode_morse('1')` returns `".----"` and `decode_morse('".----"')` returns `'1'`.

## Approach
Decompose by locating the Morse character table in `sympy/crypto/crypto.py`, replacing only the digit-1 entry, and checking any surrounding Morse encode/decode behavior. Candidate approaches: (1) direct one-line dictionary correction, lowest risk; (2) search the tree for other `"----"` Morse mappings and correct only the digit-1 occurrence; (3) add or adjust a focused regression test in `sympy/crypto/tests/test_crypto.py` if existing coverage does not exercise digit `1`. Prefer the direct correction, then run the scoped crypto tests; if they do not cover the change, add the smallest regression test in the existing crypto test module.
```

### `prompt.md`

```
Morse encoding for "1" is not correct
The current Morse mapping in simpy.crypto.crypto contains an incorrect mapping of 
`"----": "1"`   

The correct mapping is `".----": "1"`.
```

### `review.md`

```
verdict: PASS
The mapping in sympy/crypto/crypto.py is corrected from `"----": "1"` to `".----": "1"`.
The incorrect mapping `"----": "1"` is removed.
The added tests cover `encode_morse('1') == '.----'` and `decode_morse('.----') == '1'`.
Only scoped files changed: sympy/crypto/crypto.py and sympy/crypto/tests/test_crypto.py.
The check could not run because pytest is not installed in the environment; this is an environment limitation, not a defect in the change.
```

### `scope.txt`

```
scope: sympy/crypto/crypto.py sympy/crypto/tests
changed: sympy/crypto/crypto.py +1 -1
changed: sympy/crypto/tests/test_crypto.py +2 -0
```

### `task.md`

```
# Task

## Prompt

Morse encoding for "1" is not correct
The current Morse mapping in simpy.crypto.crypto contains an incorrect mapping of 
`"----": "1"`   

The correct mapping is `".----": "1"`.

## Deliverable

changes to this tree

## Check

`python -m pytest sympy/crypto/tests/test_crypto.py`

## Scope

`sympy/crypto/crypto.py`
`sympy/crypto/tests/`

## Done when

- The Morse mapping in `sympy/crypto/crypto.py` maps `".----"` to `"1"`.
- The incorrect mapping `"----": "1"` is no longer present.
- (inferred) `encode_morse('1')` returns `".----"` and `decode_morse('".----"')` returns `'1'`.
```

### `test-output.log`

```
check: python -m pytest sympy/crypto/tests/test_crypto.py
/opt/miniconda3/envs/testbed/bin/python: No module named pytest

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: sympy/crypto/crypto.py sympy/crypto/tests
changed: sympy/crypto/crypto.py +1 -1
changed: sympy/crypto/tests/test_crypto.py +2 -0
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
- `sympy/crypto/crypto.py` now maps `".----"` to `"1"`, matching the Prompt.
- The incorrect `"----": "1"` entry is removed, matching Done when.
- `encode_morse('1')` and `decode_morse('.----')` tests are added, covering the inferred behavior.
- Changes stay within `sympy/crypto/crypto.py` and `sympy/crypto/tests/`.
- No unrelated content removals or out-of-scope edits are present.
```
