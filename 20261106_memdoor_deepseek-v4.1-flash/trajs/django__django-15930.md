# django__django-15930 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 107s 35 lines cost=0.003014 in=191878 cached=176128 out=4907 calls=19`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:41:46 weboff: chief: web_fetch,web_search
17:41:46 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Case() crashes with ~Q(pk__in=[]).
Description
	
The following code generates a syntax error. 
User.objects.annotate(
	_a=Case(
		When(~Q(pk__in=[]), then=Value(True)),
		default=Value(False),
		output_field=BooleanField(),
	)
).order_by("-a").values("pk")
The error is: 
ProgrammingError: syntax error at or near "THEN"
LINE 1: ..._user"."id" FROM "users_user" ORDER BY CASE WHEN THEN true ...
The generated SQL is: 
SELECT "users_user"."id" FROM "users_user" ORDER BY CASE WHEN THEN True ELSE False END ASC
I expected behavior to annotate all rows with the value True since they all match.
Relevant because ~Q(pkin=[]) is a sentinel value that is sometimes returned by application code.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log --oneline -3"
}
```

**tool result**

```
AUTHORS
CONTRIBUTING.rst
Django.egg-info
Gruntfile.js
INSTALL
LICENSE
LICENSE.python
MANIFEST.in
README.rst
django
docs
extras
js_tests
package.json
pyproject.toml
scripts
setup.cfg
setup.py
tests
tox.ini
?? .memdoor/
e5e897457d SWE-bench
63884829ac Fixed #33902 -- Fixed Meta.constraints validation crash with F() expressions.
c614e811f8 Fixed typo in docs/topics/i18n/translation.txt.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"class When\\|class Case\" django/db/models/expressions.py"
}
```

**tool result**

```
1245:class When(Expression):
1319:class Case(SQLiteNumericMixin, Expression):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/expressions.py",
  "offset": 1245,
  "limit": 180
}
```

**tool result**

```
class When(Expression):
    template = "WHEN %(condition)s THEN %(result)s"
    # This isn't a complete conditional expression, must be used in Case().
    conditional = False

    def __init__(self, condition=None, then=None, **lookups):
        if lookups:
            if condition is None:
                condition, lookups = Q(**lookups), None
            elif getattr(condition, "conditional", False):
                condition, lookups = Q(condition, **lookups), None
        if condition is None or not getattr(condition, "conditional", False) or lookups:
            raise TypeError(
                "When() supports a Q object, a boolean expression, or lookups "
                "as a condition."
            )
        if isinstance(condition, Q) and not condition:
            raise ValueError("An empty Q() can't be used as a When() condition.")
        super().__init__(output_field=None)
        self.condition = condition
        self.result = self._parse_expressions(then)[0]

    def __str__(self):
        return "WHEN %r THEN %r" % (self.condition, self.result)

    def __repr__(self):
        return "<%s: %s>" % (self.__class__.__name__, self)

    def get_source_expressions(self):
        return [self.condition, self.result]

    def set_source_expressions(self, exprs):
        self.condition, self.result = exprs

    def get_source_fields(self):
        # We're only interested in the fields of the result expressions.
        return [self.result._output_field_or_none]

    def resolve_expression(
        self, query=None, allow_joins=True, reuse=None, summarize=False, for_save=False
    ):
        c = self.copy()
        c.is_summary = summarize
        if hasattr(c.condition, "resolve_expression"):
            c.condition = c.condition.resolve_expression(
                query, allow_joins, reuse, summarize, False
            )
        c.result = c.result.resolve_expression(
            query, allow_joins, reuse, summarize, for_save
        )
        return c

    def as_sql(self, compiler, connection, template=None, **extra_context):
        connection.ops.check_expression_support(self)
        template_params = extra_context
        sql_params = []
        condition_sql, condition_params = compiler.compile(self.condition)
        template_params["condition"] = condition_sql
        sql_params.extend(condition_params)
        result_sql, result_params = compiler.compile(self.result)
        template_params["result"] = result_sql
        sql_params.extend(result_params)
        template = template or self.template
        return template % template_params, sql_params

    def get_group_by_cols(self, alias=None):
        # This is not a complete expression and cannot be used in GROUP BY.
        cols = []
        for source in self.get_source_expressions():
            cols.extend(source.get_group_by_cols())
        return cols


@deconstructible(path="django.db.models.Case")
class Case(SQLiteNumericMixin, Expression):
    """
    An SQL searched CASE expression:

        CASE
            WHEN n > 0
                THEN 'positive'
            WHEN n < 0
                THEN 'negative'
            ELSE 'zero'
        END
    """

    template = "CASE %(cases)s ELSE %(default)s END"
    case_joiner = " "

    def __init__(self, *cases, default=None, output_field=None, **extra):
        if not all(isinstance(case, When) for case in cases):
            raise TypeError("Positional arguments must all be When objects.")
        super().__init__(output_field)
        self.cases = list(cases)
        self.default = self._parse_expressions(default)[0]
        self.extra = extra

    def __str__(self):
        return "CASE %s, ELSE %r" % (
            ", ".join(str(c) for c in self.cases),
            self.default,
        )

    def __repr__(self):
        return "<%s: %s>" % (self.__class__.__name__, self)

    def get_source_expressions(self):
        return self.cases + [self.default]

    def set_source_expressions(self, exprs):
        *self.cases, self.default = exprs

    def resolve_expression(
        self, query=None, allow_joins=True, reuse=None, summarize=False, for_save=False
    ):
        c = self.copy()
        c.is_summary = summarize
        for pos, case in enumerate(c.cases):
            c.cases[pos] = case.resolve_expression(
                query, allow_joins, reuse, summarize, for_save
            )
        c.default = c.default.resolve_expression(
            query, allow_joins, reuse, summarize, for_save
        )
        return c

    def copy(self):
        c = super().copy()
        c.cases = c.cases[:]
        return c

    def as_sql(
        self, compiler, connection, template=None, case_joiner=None, **extra_context
    ):
        connection.ops.check_expression_support(self)
        if not self.cases:
            return compiler.compile(self.default)
        template_params = {**self.extra, **extra_context}
        case_parts = []
        sql_params = []
        for case in self.cases:
            try:
                case_sql, case_params = compiler.compile(case)
            except EmptyResultSet:
                continue
            case_parts.append(case_sql)
            sql_params.extend(case_params)
        default_sql, default_params = compiler.compile(self.default)
        if not case_parts:
            return default_sql, default_params
        case_joiner = case_joiner or self.case_joiner
        template_params["cases"] = case_joiner.join(case_parts)
        template_params["default"] = default_sql
        sql_params.extend(default_params)
        template = template or template_params.get("template", self.template)
        sql = template % template_params
        if self._output_field_or_none is not None:
            sql = connection.ops.unification_cast_sql(self.output_field) % sql
        return sql, sql_params

    def get_group_by_cols(self, alias=None):
        if not self.cases:
            return self.default.get_group_by_cols(alias)
        return super().get_group_by_cols(alias)


class Subquery(BaseExpression, Combinable):
    """
    An explicit subquery. It may contain OuterRef() references to the outer
    query which will be resolved when it is applied to that query.
    """

    template = "(%(subquery)s)"
    contains_aggregate = False
    empty_result_set_value = None

    def __init__(self, queryset, output_field=None, **extra):
        # Allow the usage of both QuerySet and sql.Query objects.
        self.query = getattr(queryset, "query", queryset).clone()

[379 more lines in /testbed/django/db/models/expressions.py (1803 in all). read_file with offset: 1425 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Q\\|def resolve_expression\\|def _add_q\\|EmptyResultSet\\|def as_sql\" django/db/models/query_utils.py | head -50"
}
```

**tool result**

```
35:class Q(tree.Node):
82:    def resolve_expression(
369:    def resolve_expression(self, *args, **kwargs):
376:    def as_sql(self, compiler, connection):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/query_utils.py",
  "offset": 35,
  "limit": 130
}
```

**tool result**

```
class Q(tree.Node):
    """
    Encapsulate filters as objects that can then be combined logically (using
    `&` and `|`).
    """

    # Connection types
    AND = "AND"
    OR = "OR"
    XOR = "XOR"
    default = AND
    conditional = True

    def __init__(self, *args, _connector=None, _negated=False, **kwargs):
        super().__init__(
            children=[*args, *sorted(kwargs.items())],
            connector=_connector,
            negated=_negated,
        )

    def _combine(self, other, conn):
        if getattr(other, "conditional", False) is False:
            raise TypeError(other)
        if not self:
            return other.copy()
        if not other and isinstance(other, Q):
            return self.copy()

        obj = self.create(connector=conn)
        obj.add(self, conn)
        obj.add(other, conn)
        return obj

    def __or__(self, other):
        return self._combine(other, self.OR)

    def __and__(self, other):
        return self._combine(other, self.AND)

    def __xor__(self, other):
        return self._combine(other, self.XOR)

    def __invert__(self):
        obj = self.copy()
        obj.negate()
        return obj

    def resolve_expression(
        self, query=None, allow_joins=True, reuse=None, summarize=False, for_save=False
    ):
        # We must promote any new joins to left outer joins so that when Q is
        # used as an expression, rows aren't filtered due to joins.
        clause, joins = query._add_q(
            self,
            reuse,
            allow_joins=allow_joins,
            split_subq=False,
            check_filterable=False,
        )
        query.promote_joins(joins)
        return clause

    def flatten(self):
        """
        Recursively yield this Q object and all subexpressions, in depth-first
        order.
        """
        yield self
        for child in self.children:
            if isinstance(child, tuple):
                # Use the lookup.
                child = child[1]
            if hasattr(child, "flatten"):
                yield from child.flatten()
            else:
                yield child

    def check(self, against, using=DEFAULT_DB_ALIAS):
        """
        Do a database query to check if the expressions of the Q instance
        matches against the expressions.
        """
        # Avoid circular imports.
        from django.db.models import Value
        from django.db.models.sql import Query
        from django.db.models.sql.constants import SINGLE

        query = Query(None)
        for name, value in against.items():
            if not hasattr(value, "resolve_expression"):
                value = Value(value)
            query.add_annotation(value, name, select=False)
        query.add_annotation(Value(1), "_check")
        # This will raise a FieldError if a field is missing in "against".
        query.add_q(self)
        compiler = query.get_compiler(using=using)
        try:
            return compiler.execute_sql(SINGLE) is not None
        except DatabaseError as e:
            logger.warning("Got a database error calling check() on %r: %s", self, e)
            return True

    def deconstruct(self):
        path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
        if path.startswith("django.db.models.query_utils"):
            path = path.replace("django.db.models.query_utils", "django.db.models")
        args = tuple(self.children)
        kwargs = {}
        if self.connector != self.default:
            kwargs["_connector"] = self.connector
        if self.negated:
            kwargs["_negated"] = True
        return path, args, kwargs


class DeferredAttribute:
    """
    A wrapper for a deferred-loading field. When the value is read from this
    object the first time, the query is executed.
    """

    def __init__(self, field):
        self.field = field

    def __get__(self, instance, cls=None):
        """
        Retrieve and caches the value from the datastore on the first lookup.
        Return the cached value.
        """
        if instance is None:

[216 more lines in /testbed/django/db/models/query_utils.py (380 in all). read_file with offset: 165 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"EmptyResultSet\\|def as_sql\\|def _add_q\\|def build_filter\" django/db/models/sql/query.py | head -60; grep -n \"class WhereNode\\|EmptyResultSet\\|def as_sql\" django/db/models/sql/where.py"
}
```

**tool result**

```
1174:    def as_sql(self, compiler, connection):
1349:    def build_filter(
1546:    def _add_q(
1580:    def build_filtered_relation_q(
7:from django.core.exceptions import EmptyResultSet
19:class WhereNode(tree.Node):
81:    def as_sql(self, compiler, connection):
85:        None, [] if this node is empty, and raise EmptyResultSet if this
113:            except EmptyResultSet:
130:                    raise EmptyResultSet
133:                    raise EmptyResultSet
254:    def as_sql(self, compiler=None, connection=None):
255:        raise EmptyResultSet
266:    def as_sql(self, compiler=None, connection=None):
283:    def as_sql(self, compiler, connection):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/sql/where.py",
  "offset": 19,
  "limit": 150
}
```

**tool result**

```
class WhereNode(tree.Node):
    """
    An SQL WHERE clause.

    The class is tied to the Query class that created it (in order to create
    the correct SQL).

    A child is usually an expression producing boolean values. Most likely the
    expression is a Lookup instance.

    However, a child could also be any class with as_sql() and either
    relabeled_clone() method or relabel_aliases() and clone() methods and
    contains_aggregate attribute.
    """

    default = AND
    resolved = False
    conditional = True

    def split_having(self, negated=False):
        """
        Return two possibly None nodes: one for those parts of self that
        should be included in the WHERE clause and one for those parts of
        self that must be included in the HAVING clause.
        """
        if not self.contains_aggregate:
            return self, None
        in_negated = negated ^ self.negated
        # If the effective connector is OR or XOR and this node contains an
        # aggregate, then we need to push the whole branch to HAVING clause.
        may_need_split = (
            (in_negated and self.connector == AND)
            or (not in_negated and self.connector == OR)
            or self.connector == XOR
        )
        if may_need_split and self.contains_aggregate:
            return None, self
        where_parts = []
        having_parts = []
        for c in self.children:
            if hasattr(c, "split_having"):
                where_part, having_part = c.split_having(in_negated)
                if where_part is not None:
                    where_parts.append(where_part)
                if having_part is not None:
                    having_parts.append(having_part)
            elif c.contains_aggregate:
                having_parts.append(c)
            else:
                where_parts.append(c)
        having_node = (
            self.create(having_parts, self.connector, self.negated)
            if having_parts
            else None
        )
        where_node = (
            self.create(where_parts, self.connector, self.negated)
            if where_parts
            else None
        )
        return where_node, having_node

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
                    return "", []
                else:
                    raise EmptyResultSet
            if full_needed == 0:
                if self.negated:
                    raise EmptyResultSet
                else:
                    return "", []
        conn = " %s " % self.connector
        sql_string = conn.join(result)
        if sql_string:
            if self.negated:
                # Some backends (Oracle at least) need parentheses
                # around the inner SQL in the negated case, even if the
                # inner SQL contains just a single expression.
                sql_string = "NOT (%s)" % sql_string
            elif len(result) > 1 or self.resolved:
                sql_string = "(%s)" % sql_string
        return sql_string, result_params

    def get_group_by_cols(self, alias=None):
        cols = []
        for child in self.children:
            cols.extend(child.get_group_by_cols())
        return cols

    def get_source_expressions(self):
        return self.children[:]

    def set_source_expressions(self, children):
        assert len(children) == len(self.children)
        self.children = children

    def relabel_aliases(self, change_map):
        """
        Relabel the alias values of any children. 'change_map' is a dictionary
        mapping old (current) alias values to the new values.
        """
        for pos, child in enumerate(self.children):
            if hasattr(child, "relabel_aliases"):
                # For example another WhereNode

[119 more lines in /testbed/django/db/models/sql/where.py (287 in all). read_file with offset: 169 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"pk__in=\\[\\]\\|in=\\[\\]\\|EmptyResultSet\" tests/expressions tests/expressions_case tests/queries 2>/dev/null | head -40"
}
```

**tool result**

```
tests/expressions_case/tests.py:411:                When(pk__in=[], then=Value("selected")),
tests/expressions_case/tests.py:1645:            Case(When(Q(pk__in=[])), object())
tests/queries/test_qs_combinators.py:68:        qs3 = Number.objects.filter(pk__in=[])
tests/queries/test_qs_combinators.py:80:        qs3 = Number.objects.filter(pk__in=[])
tests/queries/test_qs_combinators.py:102:        qs3 = Number.objects.filter(pk__in=[])
tests/queries/test_qs_combinators.py:352:        qs = Number.objects.filter(pk__in=[])
tests/queries/test_qs_combinators.py:385:        qs = Number.objects.filter(pk__in=[])
tests/queries/tests.py:8:from django.core.exceptions import EmptyResultSet, FieldError
tests/queries/tests.py:307:        self.assertSequenceEqual(Author.objects.filter(Q(id__in=[])), [])
tests/queries/tests.py:308:        self.assertSequenceEqual(Author.objects.filter(Q(id__in=[]) | Q(id__in=[])), [])
tests/queries/tests.py:1625:        # Avoid raising an EmptyResultSet if an inner query is probably
tests/queries/tests.py:1628:            Tag.objects.filter(id__in=Tag.objects.filter(id__in=[])), []
tests/queries/tests.py:3441:            NullableName.objects.exclude(name__in=[]),
tests/queries/tests.py:3546:        with self.assertRaises(EmptyResultSet):
tests/queries/tests.py:3555:        with self.assertRaises(EmptyResultSet):
tests/queries/tests.py:3563:        with self.assertRaises(EmptyResultSet):
tests/queries/tests.py:3582:        with self.assertRaises(EmptyResultSet):
tests/queries/tests.py:3585:        with self.assertRaises(EmptyResultSet):
tests/queries/tests.py:3592:        with self.assertRaises(EmptyResultSet):
tests/queries/tests.py:4141:        # ~Q(pk__in=[]) will always be True.
tests/queries/tests.py:4142:        qs = Paragraph.objects.filter((Q(pk=p2.pk) | ~Q(pk__in=[])) & Q(pk=p1.pk))
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/expressions_case/tests.py",
  "offset": 390,
  "limit": 50
}
```

**tool result**

```

    def test_annotate_values_not_in_order_by(self):
        self.assertEqual(
            list(
                CaseTestModel.objects.annotate(
                    test=Case(
                        When(integer=1, then=Value("one")),
                        When(integer=2, then=Value("two")),
                        When(integer=3, then=Value("three")),
                        default=Value("other"),
                    )
                )
                .order_by("test")
                .values_list("integer", flat=True)
            ),
            [1, 4, 3, 3, 3, 2, 2],
        )

    def test_annotate_with_empty_when(self):
        objects = CaseTestModel.objects.annotate(
            selected=Case(
                When(pk__in=[], then=Value("selected")),
                default=Value("not selected"),
            )
        )
        self.assertEqual(len(objects), CaseTestModel.objects.count())
        self.assertTrue(all(obj.selected == "not selected" for obj in objects))

    def test_combined_expression(self):
        self.assertQuerysetEqual(
            CaseTestModel.objects.annotate(
                test=Case(
                    When(integer=1, then=2),
                    When(integer=2, then=1),
                    default=3,
                )
                + 1,
            ).order_by("pk"),
            [(1, 3), (2, 2), (3, 4), (2, 2), (3, 4), (3, 4), (4, 4)],
            transform=attrgetter("integer", "test"),
        )

    def test_in_subquery(self):
        self.assertQuerysetEqual(
            CaseTestModel.objects.filter(
                pk__in=CaseTestModel.objects.annotate(
                    test=Case(
                        When(integer=F("integer2"), then="pk"),
                        When(integer=4, then="pk"),
                    ),

[1225 more lines in /testbed/tests/expressions_case/tests.py (1664 in all). read_file with offset: 440 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/expressions_case/tests.py",
  "offset": 1620,
  "limit": 44
}
```

**tool result**

```
            When(account_type__in=[Client.REGULAR, Client.GOLD], then=1),
            default=2,
            output_field=IntegerField(),
        )
        expression_2 = Case(
            When(account_type__in=(Client.REGULAR, Client.GOLD), then=1),
            default=2,
            output_field=IntegerField(),
        )
        expression_3 = Case(
            When(account_type__in=[Client.REGULAR, Client.GOLD], then=1), default=2
        )
        expression_4 = Case(
            When(account_type__in=[Client.PLATINUM, Client.GOLD], then=2), default=1
        )
        self.assertEqual(hash(expression_1), hash(expression_2))
        self.assertNotEqual(hash(expression_2), hash(expression_3))
        self.assertNotEqual(hash(expression_1), hash(expression_4))
        self.assertNotEqual(hash(expression_3), hash(expression_4))


class CaseWhenTests(SimpleTestCase):
    def test_only_when_arguments(self):
        msg = "Positional arguments must all be When objects."
        with self.assertRaisesMessage(TypeError, msg):
            Case(When(Q(pk__in=[])), object())

    def test_invalid_when_constructor_args(self):
        msg = (
            "When() supports a Q object, a boolean expression, or lookups as "
            "a condition."
        )
        with self.assertRaisesMessage(TypeError, msg):
            When(condition=object())
        with self.assertRaisesMessage(TypeError, msg):
            When(condition=Value(1))
        with self.assertRaisesMessage(TypeError, msg):
            When(Value(1), string="1")
        with self.assertRaisesMessage(TypeError, msg):
            When()

    def test_empty_q_object(self):
        msg = "An empty Q() can't be used as a When() condition."
        with self.assertRaisesMessage(ValueError, msg):

[1 more lines in /testbed/tests/expressions_case/tests.py (1664 in all). read_file with offset: 1664 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"1=1\\|WHEN 1\\|always true\\|matches everything\" django/db/models tests/expressions_case | head -30"
}
```

**tool result**

```
django/db/models/expressions.py:1498:                    return "1=1", ()
django/db/models/sql/where.py:84:        substituted in. Return '', [] if this node matches everything,
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/expressions.py",
  "offset": 1470,
  "limit": 50
}
```

**tool result**

```

class Exists(Subquery):
    template = "EXISTS(%(subquery)s)"
    output_field = fields.BooleanField()

    def __init__(self, queryset, negated=False, **kwargs):
        self.negated = negated
        super().__init__(queryset, **kwargs)

    def __invert__(self):
        clone = self.copy()
        clone.negated = not self.negated
        return clone

    def as_sql(self, compiler, connection, template=None, **extra_context):
        query = self.query.exists(using=connection.alias)
        try:
            sql, params = super().as_sql(
                compiler,
                connection,
                template=template,
                query=query,
                **extra_context,
            )
        except EmptyResultSet:
            if self.negated:
                features = compiler.connection.features
                if not features.supports_boolean_expr_in_select_clause:
                    return "1=1", ()
                return compiler.compile(Value(True))
            raise
        if self.negated:
            sql = "NOT {}".format(sql)
        return sql, params

    def select_format(self, compiler, sql, params):
        # Wrap EXISTS() with a CASE WHEN expression if a database backend
        # (e.g. Oracle) doesn't support boolean expression in SELECT or GROUP
        # BY list.
        if not compiler.connection.features.supports_boolean_expr_in_select_clause:
            sql = "CASE WHEN {} THEN 1 ELSE 0 END".format(sql)
        return sql, params


@deconstructible(path="django.db.models.OrderBy")
class OrderBy(Expression):
    template = "%(expression)s %(ordering)s"
    conditional = False

    def __init__(self, expression, descending=False, nulls_first=None, nulls_last=None):

[284 more lines in /testbed/django/db/models/expressions.py (1803 in all). read_file with offset: 1520 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/expressions.py\n@@\n         template_params = extra_context\n         sql_params = []\n         condition_sql, condition_params = compiler.compile(self.condition)\n+        if not condition_sql:\n+            condition_sql = \"1=1\"\n         template_params[\"condition\"] = condition_sql\n         sql_params.extend(condition_params)\n*** Update File: tests/expressions_case/tests.py\n@@\n     def test_annotate_with_empty_when(self):\n         objects = CaseTestModel.objects.annotate(\n             selected=Case(\n                 When(pk__in=[], then=Value(\"selected\")),\n                 default=Value(\"not selected\"),\n             )\n         )\n         self.assertEqual(len(objects), CaseTestModel.objects.count())\n         self.assertTrue(all(obj.selected == \"not selected\" for obj in objects))\n \n+    def test_annotate_with_always_true_when(self):\n+        objects = CaseTestModel.objects.annotate(\n+            selected=Case(\n+                When(~Q(pk__in=[]), then=Value(True)),\n+                default=Value(False),\n+                output_field=BooleanField(),\n+            )\n+        )\n+        self.assertEqual(len(objects), CaseTestModel.objects.count())\n+        self.assertTrue(all(obj.selected for obj in objects))\n+\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/expressions.py tests/expressions_case/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/expressions.py now (1805 lines), around the change:
1299:        template_params = extra_context
1300:        sql_params = []
1301:        condition_sql, condition_params = compiler.compile(self.condition)
1302:        if not condition_sql:
1303:            condition_sql = "1=1"
1304:        template_params["condition"] = condition_sql
1305:        sql_params.extend(condition_params)
1306:        result_sql, result_params = compiler.compile(self.result)

tests/expressions_case/tests.py now (1675 lines), around the change:
414:        )
415:        self.assertEqual(len(objects), CaseTestModel.objects.count())
416:        self.assertTrue(all(obj.selected == "not selected" for obj in objects))
417:
418:    def test_annotate_with_always_true_when(self):
419:        objects = CaseTestModel.objects.annotate(
420:            selected=Case(
421:                When(~Q(pk__in=[]), then=Value(True)),
422:                default=Value(False),
423:                output_field=BooleanField(),
424:            )
425:        )
426:        self.assertEqual(len(objects), CaseTestModel.objects.count())
427:        self.assertTrue(all(obj.selected for obj in objects))
428:
429:    def test_combined_expression(self):
430:        self.assertQuerysetEqual(
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' tests/expressions_case/tests.py"
}
```

**tool result**

```
import unittest
from datetime import date, datetime, time, timedelta
from decimal import Decimal
from operator import attrgetter, itemgetter
from uuid import UUID

from django.core.exceptions import FieldError
from django.db import connection
from django.db.models import (
    BinaryField,
    BooleanField,
    Case,
    Count,
    DecimalField,
    F,
    GenericIPAddressField,
    IntegerField,
    Max,
    Min,
    Q,
    Sum,
    TextField,
    Value,
    When,
)
from django.test import SimpleTestCase, TestCase

from .models import CaseTestModel, Client, FKCaseTestModel, O2OCaseTestModel

try:
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py expressions_case.CaseExpressionTests.test_annotate_with_always_true_when expressions_case.CaseExpressionTests.test_annotate_with_empty_when 2>&1 | tail -20"
}
```

**tool result**

```
E
======================================================================
ERROR: CaseExpressionTests (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: CaseExpressionTests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.9/unittest/loader.py", line 154, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'expressions_case.CaseExpressionTests'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 1 test(s).
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py expressions_case 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 89 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.........................................................................................
----------------------------------------------------------------------
Ran 89 tests in 0.191s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries expressions 2>&1 | tail -8; cd .. && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
TASK_OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries expressions 2>&1 | grep -E \"^(OK|FAILED|Ran )\""
}
```

**tool result**

```
Ran 642 tests in 0.707s
OK (skipped=12, expected failures=3)
```

**assistant**

```
Fixed. `When.as_sql()` now substitutes `1=1` when the compiled condition is empty (which happens for always-true conditions like `~Q(pk__in=[])`), instead of emitting `WHEN THEN ...`.

Added a regression test in `tests/expressions_case/tests.py`; the `expressions_case`, `queries`, and `expressions` suites pass, and the required `git status` check exits 0.
```

## Run folder `single-2026-11-06T174146`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Case() crashes with ~Q(pk__in=[]).
Description
	
The following code generates a syntax error. 
User.objects.annotate(
	_a=Case(
		When(~Q(pk__in=[]), then=Value(True)),
		default=Value(False),
		output_field=BooleanField(),
	)
).order_by("-a").values("pk")
The error is: 
ProgrammingError: syntax error at or near "THEN"
LINE 1: ..._user"."id" FROM "users_user" ORDER BY CASE WHEN THEN true ...
The generated SQL is: 
SELECT "users_user"."id" FROM "users_user" ORDER BY CASE WHEN THEN True ELSE False END ASC
I expected behavior to annotate all rows with the value True since they all match.
Relevant because ~Q(pkin=[]) is a sentinel value that is sometimes returned by application code.
```
