# django__django-16901 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 59s 55 lines cost=0.002182 in=146664 cached=135168 out=3472 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

On databases lacking XOR, Q(…) ^ Q(…) ^ Q(…) wrongly interpreted as exactly-one rather than parity
Description
	
On databases that don’t natively support XOR, such as PostgreSQL, Django generates incorrect fallback SQL for Q(…) ^ Q(…) ^ Q(…) with more than 2 arguments. The ​correct interpretation, and the interpretation of databases natively supporting XOR (e.g. ​MySQL), is that a ^ b ^ c is true when an odd number of the arguments are true. But Django’s fallback interpretation is that a ^ b ^ c is true when exactly one argument is true:
>>> from django.db.models import Q
>>> from my_app.models import Client
>>> Client.objects.filter(Q(id=37)).count()
1
>>> Client.objects.filter(Q(id=37) ^ Q(id=37)).count()
0
>>> Client.objects.filter(Q(id=37) ^ Q(id=37) ^ Q(id=37)).count()
0
>>> Client.objects.filter(Q(id=37) ^ Q(id=37) ^ Q(id=37) ^ Q(id=37)).count()
0
>>> Client.objects.filter(Q(id=37) ^ Q(id=37) ^ Q(id=37) ^ Q(id=37) ^ Q(id=37)).count()
0
(Expected: 1, 0, 1, 0, 1.)
This was introduced in #29865.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --porcelain && git log --oneline -5"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"XOR\" django/db/models/query_utils.py django/db/models/sql/where.py | head -50"
}
```

**tool result**

```
/testbed
?? .memdoor/
613f83961a SWE-bench
ee36e101e8 Optimized lazy() by removing use of @total_ordering.
a57d5d9bbc Made bytes and str return types no longer mutually exclusive in lazy().
459f30f73e Removed unnecessary wrapping of __bytes__ in proxy class in lazy().
c7ba2e3cbb Removed unnecessary branch in __mod__() from proxy class in lazy().
```

**tool result**

```
django/db/models/query_utils.py:44:    XOR = "XOR"
django/db/models/query_utils.py:75:        return self._combine(other, self.XOR)
django/db/models/sql/where.py:16:XOR = "XOR"
django/db/models/sql/where.py:53:            or self.connector == XOR
django/db/models/sql/where.py:128:        if self.connector == XOR and not connection.features.supports_logical_xor:
django/db/models/sql/where.py:129:            # Convert if the database doesn't support XOR:
django/db/models/sql/where.py:130:            #   a XOR b XOR c XOR ...
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/sql/where.py",
  "offset": 100,
  "limit": 80
}
```

**tool result**

```
            else None
        )
        having_node = (
            self.create(having_parts, self.connector, self.negated)
            if having_parts
            else None
        )
        qualify_node = (
            self.create(qualify_parts, self.connector, self.negated)
            if qualify_parts
            else None
        )
        return where_node, having_node, qualify_node

    def as_sql(self, compiler, connection):
        """
        Return the SQL version of the where clause and the value to be
        substituted in. Return '', [] if this node matches everything,
        None, [] if this node is empty, and raise EmptyResultSet if this
        node can't match anything.
        """
        result = []
        result_params = []
        if self.connector == AND:
            full_needed, empty_needed = len(self.children), 1
        else:
            full_needed, empty_needed = 1, len(self.children)

        if self.connector == XOR and not connection.features.supports_logical_xor:
            # Convert if the database doesn't support XOR:
            #   a XOR b XOR c XOR ...
            # to:
            #   (a OR b OR c OR ...) AND (a + b + c + ...) == 1
            lhs = self.__class__(self.children, OR)
            rhs_sum = reduce(
                operator.add,
                (Case(When(c, then=1), default=0) for c in self.children),
            )
            rhs = Exact(1, rhs_sum)
            return self.__class__([lhs, rhs], AND, self.negated).as_sql(
                compiler, connection
            )

        for child in self.children:
            try:
                sql, params = compiler.compile(child)
            except EmptyResultSet:
                empty_needed -= 1
            except FullResultSet:
                full_needed -= 1
            else:
                if sql:
                    result.append(sql)
                    result_params.extend(params)
                else:
                    full_needed -= 1
            # Check if this node matches nothing or everything.
            # First check the amount of full nodes and empty nodes
            # to make this node empty/full.
            # Now, check if this node is full/empty using the
            # counts.
            if empty_needed == 0:
                if self.negated:
                    raise FullResultSet
                else:
                    raise EmptyResultSet
            if full_needed == 0:
                if self.negated:
                    raise EmptyResultSet
                else:
                    raise FullResultSet
        conn = " %s " % self.connector
        sql_string = conn.join(result)
        if not sql_string:
            raise FullResultSet
        if self.negated:
            # Some backends (Oracle at least) need parentheses around the inner
            # SQL in the negated case, even if the inner SQL contains just a
            # single expression.
            sql_string = "NOT (%s)" % sql_string

[176 more lines in /testbed/django/db/models/sql/where.py (355 in all). read_file with offset: 180 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/sql/where.py",
  "limit": 30
}
```

**tool result**

```
"""
Code to manage the creation and SQL rendering of 'where' constraints.
"""
import operator
from functools import reduce

from django.core.exceptions import EmptyResultSet, FullResultSet
from django.db.models.expressions import Case, When
from django.db.models.lookups import Exact
from django.utils import tree
from django.utils.functional import cached_property

# Connection types
AND = "AND"
OR = "OR"
XOR = "XOR"


class WhereNode(tree.Node):
    """
    An SQL WHERE clause.

    The class is tied to the Query class that created it (in order to create
    the correct SQL).

    A child is usually an expression producing boolean values. Most likely the
    expression is a Lookup instance.

    However, a child could also be any class with as_sql() and either
    relabeled_clone() method or relabel_aliases() and clone() methods and

[325 more lines in /testbed/django/db/models/sql/where.py (355 in all). read_file with offset: 31 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"XOR\\|xor\" tests/ | grep -i \"where\\|lookup\\|query\" | head -40"
}
```

**tool result**

```
tests/queries/tests.py:2183:    def test_xor_subquery(self):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"supports_logical_xor\\|XOR\" tests/ django/db/backends/ | head -40"
}
```

**tool result**

```
tests/queries/test_q.py:131:        self.assertEqual(kwargs, {"_connector": Q.XOR})
tests/queries/test_q.py:221:        for connector in [Q.AND, Q.OR, Q.XOR]:
tests/expressions/tests.py:1492:        connection.vendor == "oracle", "Oracle doesn't support bitwise XOR."
tests/expressions/tests.py:1495:        msg = "Bitwise XOR is not supported in Oracle."
django/db/backends/mysql/features.py:58:    supports_logical_xor = True
django/db/backends/oracle/operations.py:644:            raise NotSupportedError("Bitwise XOR is not supported in Oracle.")
django/db/backends/oracle/features.py:108:        "Oracle doesn't support bitwise XOR.": {
django/db/backends/base/features.py:354:    # Does the backend support the logical XOR operator?
django/db/backends/base/features.py:355:    supports_logical_xor = False
django/db/backends/sqlite3/operations.py:373:            return "BITXOR(%s)" % ",".join(sub_expressions)
django/db/backends/sqlite3/_functions.py:62:    create_deterministic_function("BITXOR", 2, _sqlite_bitxor)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Mod\\|^class \" django/db/models/expressions.py | head -40; grep -rn \"Mod(\" django/db/models/ | head"
}
```

**tool result**

```
20:class SQLiteNumericMixin:
36:class Combinable:
168:class BaseExpression:
475:class Expression(BaseExpression, Combinable):
641:class CombinedExpression(SQLiteNumericMixin, Expression):
743:class DurationExpression(CombinedExpression):
794:class TemporalSubtraction(CombinedExpression):
810:class F(Combinable):
849:class ResolvedOuterRef(F):
886:class OuterRef(F):
899:class Func(SQLiteNumericMixin, Expression):
1004:class Value(SQLiteNumericMixin, Expression):
1084:class RawSQL(Expression):
1120:class Star(Expression):
1128:class DatabaseDefault(Expression):
1135:class Col(Expression):
1174:class Ref(Expression):
1213:class ExpressionList(Func):
1237:class OrderByList(Func):
1265:class ExpressionWrapper(SQLiteNumericMixin, Expression):
1301:class NegatedExpression(ExpressionWrapper):
1353:class When(Expression):
1433:class Case(SQLiteNumericMixin, Expression):
1535:class Subquery(BaseExpression, Combinable):
1588:class Exists(Subquery):
1607:class OrderBy(Expression):
1697:class Window(SQLiteNumericMixin, Expression):
1813:class WindowFrame(Expression):
1879:class RowRange(WindowFrame):
1886:class ValueRange(WindowFrame):
django/db/models/functions/math.py:124:class Mod(FixDecimalInputMixin, NumericOutputFieldMixin, Func):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rni \"xor\" tests/ | head -40"
}
```

**tool result**

```
tests/xor_lookups/tests.py:7:class XorLookupsTests(TestCase):
tests/queries/test_q.py:41:    def test_combine_xor_empty(self):
tests/queries/test_q.py:68:    def test_combine_xor_both_empty(self):
tests/queries/test_q.py:119:    def test_deconstruct_xor(self):
tests/queries/test_q.py:131:        self.assertEqual(kwargs, {"_connector": Q.XOR})
tests/queries/test_q.py:189:    def test_reconstruct_xor(self):
tests/queries/test_q.py:221:        for connector in [Q.AND, Q.OR, Q.XOR]:
tests/queries/test_qs_combinators.py:660:            ("^", operator.xor),
tests/queries/tests.py:2183:    def test_xor_subquery(self):
tests/queries/tests.py:2512:    def test_xor_with_rhs_slice(self):
tests/queries/tests.py:2518:    def test_xor_with_lhs_slice(self):
tests/queries/tests.py:2524:    def test_xor_with_both_slice(self):
tests/queries/tests.py:2530:    def test_xor_with_both_slice_and_ordering(self):
tests/aggregation_regress/tests.py:1720:    def test_filter_aggregates_xor_connector(self):
tests/aggregation_regress/tests.py:1730:    def test_filter_aggregates_negated_xor_connector(self):
tests/gis_tests/geos_tests/test_geos.py:738:            )  # __xor__ is symmetric difference operator
tests/gis_tests/geos_tests/test_geos.py:739:            a ^= b  # testing __ixor__
tests/gis_tests/gdal_tests/test_geom.py:423:            )  # __xor__ is symmetric difference operator
tests/gis_tests/gdal_tests/test_geom.py:424:            a ^= b  # testing __ixor__
tests/expressions/tests.py:1474:    def test_lefthand_bitwise_xor(self):
tests/expressions/tests.py:1475:        Number.objects.update(integer=F("integer").bitxor(48))
tests/expressions/tests.py:1479:    def test_lefthand_bitwise_xor_null(self):
tests/expressions/tests.py:1481:        Employee.objects.update(salary=F("salary").bitxor(48))
tests/expressions/tests.py:1485:    def test_lefthand_bitwise_xor_right_null(self):
tests/expressions/tests.py:1487:        Employee.objects.update(salary=F("salary").bitxor(None))
tests/expressions/tests.py:1492:        connection.vendor == "oracle", "Oracle doesn't support bitwise XOR."
tests/expressions/tests.py:1494:    def test_lefthand_bitwise_xor_not_supported(self):
tests/expressions/tests.py:1495:        msg = "Bitwise XOR is not supported in Oracle."
tests/expressions/tests.py:1497:            Number.objects.update(integer=F("integer").bitxor(48))
tests/expressions/tests.py:2395:        "Use .bitand(), .bitor(), and .bitxor() for bitwise logical operations."
tests/expressions/tests.py:2410:    def test_xor(self):
tests/expressions/tests.py:2422:    def test_reversed_xor(self):
tests/postgres_tests/test_aggregates.py:29:        BitXor,
tests/postgres_tests/test_aggregates.py:100:        if connection.features.has_bit_xor:
tests/postgres_tests/test_aggregates.py:101:            tests.append(BitXor("integer_field"))
tests/postgres_tests/test_aggregates.py:138:        if connection.features.has_bit_xor:
tests/postgres_tests/test_aggregates.py:139:            tests.append((BitXor("integer_field", default=0), 0))
tests/postgres_tests/test_aggregates.py:395:    @skipUnlessDBFeature("has_bit_xor")
tests/postgres_tests/test_aggregates.py:396:    def test_bit_xor_general(self):
tests/postgres_tests/test_aggregates.py:400:        ).aggregate(bitxor=BitXor("integer_field"))
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/xor_lookups/tests.py"
}
```

**tool result**

```
from django.db.models import Q
from django.test import TestCase

from .models import Number


class XorLookupsTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.numbers = [Number.objects.create(num=i) for i in range(10)]

    def test_filter(self):
        self.assertCountEqual(
            Number.objects.filter(num__lte=7) ^ Number.objects.filter(num__gte=3),
            self.numbers[:3] + self.numbers[8:],
        )
        self.assertCountEqual(
            Number.objects.filter(Q(num__lte=7) ^ Q(num__gte=3)),
            self.numbers[:3] + self.numbers[8:],
        )

    def test_filter_negated(self):
        self.assertCountEqual(
            Number.objects.filter(Q(num__lte=7) ^ ~Q(num__lt=3)),
            self.numbers[:3] + self.numbers[8:],
        )
        self.assertCountEqual(
            Number.objects.filter(~Q(num__gt=7) ^ ~Q(num__lt=3)),
            self.numbers[:3] + self.numbers[8:],
        )
        self.assertCountEqual(
            Number.objects.filter(Q(num__lte=7) ^ ~Q(num__lt=3) ^ Q(num__lte=1)),
            [self.numbers[2]] + self.numbers[8:],
        )
        self.assertCountEqual(
            Number.objects.filter(~(Q(num__lte=7) ^ ~Q(num__lt=3) ^ Q(num__lte=1))),
            self.numbers[:2] + self.numbers[3:8],
        )

    def test_exclude(self):
        self.assertCountEqual(
            Number.objects.exclude(Q(num__lte=7) ^ Q(num__gte=3)),
            self.numbers[3:8],
        )

    def test_stages(self):
        numbers = Number.objects.all()
        self.assertSequenceEqual(
            numbers.filter(num__gte=0) ^ numbers.filter(num__lte=11),
            [],
        )
        self.assertSequenceEqual(
            numbers.filter(num__gt=0) ^ numbers.filter(num__lt=11),
            [self.numbers[0]],
        )

    def test_pk_q(self):
        self.assertCountEqual(
            Number.objects.filter(Q(pk=self.numbers[0].pk) ^ Q(pk=self.numbers[1].pk)),
            self.numbers[:2],
        )

    def test_empty_in(self):
        self.assertCountEqual(
            Number.objects.filter(Q(pk__in=[]) ^ Q(num__gte=5)),
            self.numbers[5:],
        )
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/sql/where.py\n@@\n from django.core.exceptions import EmptyResultSet, FullResultSet\n from django.db.models.expressions import Case, When\n+from django.db.models.functions import Mod\n from django.db.models.lookups import Exact\n@@\n         if self.connector == XOR and not connection.features.supports_logical_xor:\n             # Convert if the database doesn't support XOR:\n             #   a XOR b XOR c XOR ...\n             # to:\n-            #   (a OR b OR c OR ...) AND (a + b + c + ...) == 1\n+            #   (a OR b OR c OR ...) AND MOD(a + b + c + ..., 2) == 1\n+            # The result of an n-ary XOR is true when an odd number of operands\n+            # are true.\n             lhs = self.__class__(self.children, OR)\n             rhs_sum = reduce(\n                 operator.add,\n                 (Case(When(c, then=1), default=0) for c in self.children),\n             )\n+            if len(self.children) > 2:\n+                rhs_sum = Mod(rhs_sum, 2)\n             rhs = Exact(1, rhs_sum)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/sql/where.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/sql/where.py now (360 lines), around the change:
6:
7:from django.core.exceptions import EmptyResultSet, FullResultSet
8:from django.db.models.expressions import Case, When
9:from django.db.models.functions import Mod
10:from django.db.models.lookups import Exact
11:from django.utils import tree
12:from django.utils.functional import cached_property
…
130:            # Convert if the database doesn't support XOR:
131:            #   a XOR b XOR c XOR ...
132:            # to:
133:            #   (a OR b OR c OR ...) AND MOD(a + b + c + ..., 2) == 1
134:            # The result of an n-ary XOR is true when an odd number of operands
135:            # are true.
136:            lhs = self.__class__(self.children, OR)
137:            rhs_sum = reduce(
138:                operator.add,
139:                (Case(When(c, then=1), default=0) for c in self.children),
140:            )
141:            if len(self.children) > 2:
142:                rhs_sum = Mod(rhs_sum, 2)
143:            rhs = Exact(1, rhs_sum)
144:            return self.__class__([lhs, rhs], AND, self.negated).as_sql(
145:                compiler, connection
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/xor_lookups/tests.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py xor_lookups 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 6 test(s).
System check identified no issues (0 silenced).
......
----------------------------------------------------------------------
Ran 6 tests in 0.022s

OK
Destroying test database for alias 'default'...
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/xor_lookups/tests.py\n@@\n     def test_filter(self):\n         self.assertCountEqual(\n             Number.objects.filter(num__lte=7) ^ Number.objects.filter(num__gte=3),\n             self.numbers[:3] + self.numbers[8:],\n         )\n@@\n             self.numbers[:3] + self.numbers[8:],\n         )\n \n+    def test_filter_multiple_args(self):\n+        for count, expected in [\n+            (1, self.numbers),\n+            (2, []),\n+            (3, self.numbers),\n+            (4, []),\n+            (5, self.numbers),\n+        ]:\n+            with self.subTest(count=count):\n+                query = Q(num__gte=0)\n+                for _ in range(count - 1):\n+                    query ^= Q(num__gte=0)\n+                self.assertCountEqual(Number.objects.filter(query), expected)\n+\n     def test_filter_negated(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/xor_lookups/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/xor_lookups/tests.py now (81 lines), around the change:
18:            Number.objects.filter(Q(num__lte=7) ^ Q(num__gte=3)),
19:            self.numbers[:3] + self.numbers[8:],
20:        )
21:
22:    def test_filter_multiple_args(self):
23:        for count, expected in [
24:            (1, self.numbers),
25:            (2, []),
26:            (3, self.numbers),
27:            (4, []),
28:            (5, self.numbers),
29:        ]:
30:            with self.subTest(count=count):
31:                query = Q(num__gte=0)
32:                for _ in range(count - 1):
33:                    query ^= Q(num__gte=0)
34:                self.assertCountEqual(Number.objects.filter(query), expected)
35:
36:    def test_filter_negated(self):
37:        self.assertCountEqual(
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py xor_lookups 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 7 test(s).
System check identified no issues (0 silenced).
.......
----------------------------------------------------------------------
Ran 7 tests in 0.021s

OK
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries aggregation_regress 2>&1 | tail -15"
}
```

**tool result**

```
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries aggregation_regress 2>&1 | grep -E \"Ran|OK|FAILED|ERROR\" | tail -10"
}
```

**tool result**

```
Ran 547 tests in 1.110s
OK (skipped=19, expected failures=2)
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS; git diff --stat"
}
```

**tool result**

```
PASS
 django/db/models/sql/where.py |  7 ++++++-
 tests/xor_lookups/tests.py    | 14 ++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)
```

**assistant**

```
Fixed the XOR fallback for databases without native XOR support.

**Change** (`django/db/models/sql/where.py`): the fallback now uses `MOD(a + b + c + ..., 2) == 1` for more than two operands, giving true parity semantics (odd number of true operands) instead of the previous `sum == 1` (exactly one). Two-operand XOR keeps the simpler `sum == 1` form.

**Test** (`tests/xor_lookups/tests.py`): added `test_filter_multiple_args` covering 1–5 chained XORs, expecting true/false alternating.

Verified: `xor_lookups` (7 tests) and `queries`/`aggregation_regress` (547 tests) pass, and the completion command exits 0.
```

## Run folder `single-2026-11-06T112812`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
On databases lacking XOR, Q(…) ^ Q(…) ^ Q(…) wrongly interpreted as exactly-one rather than parity
Description
	
On databases that don’t natively support XOR, such as PostgreSQL, Django generates incorrect fallback SQL for Q(…) ^ Q(…) ^ Q(…) with more than 2 arguments. The ​correct interpretation, and the interpretation of databases natively supporting XOR (e.g. ​MySQL), is that a ^ b ^ c is true when an odd number of the arguments are true. But Django’s fallback interpretation is that a ^ b ^ c is true when exactly one argument is true:
>>> from django.db.models import Q
>>> from my_app.models import Client
>>> Client.objects.filter(Q(id=37)).count()
1
>>> Client.objects.filter(Q(id=37) ^ Q(id=37)).count()
0
>>> Client.objects.filter(Q(id=37) ^ Q(id=37) ^ Q(id=37)).count()
0
>>> Client.objects.filter(Q(id=37) ^ Q(id=37) ^ Q(id=37) ^ Q(id=37)).count()
0
>>> Client.objects.filter(Q(id=37) ^ Q(id=37) ^ Q(id=37) ^ Q(id=37) ^ Q(id=37)).count()
0
(Expected: 1, 0, 1, 0, 1.)
This was introduced in #29865.
```
