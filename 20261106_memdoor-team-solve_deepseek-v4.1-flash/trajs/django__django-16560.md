# django__django-16560 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 252s 465 lines cost=0.018416 in=1213042 cached=1128960 out=30127 calls=47`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Allow to customize the code attribute of ValidationError raised by BaseConstraint.validate
Description
	
It is currently possible to customize the violation_error_message of a ValidationError raised by a constraint but not the code.
I'd like to add a new violation_error_message parameter to BaseConstraint to allow to easily add one.
Currently, to achieve the same result, you have to subclass the constraint to tweak validate to catch and reraise the ValidationError.
Since the documentation recommends to Provide a descriptive error code to the constructor: when raising a ValidationError in ​https://docs.djangoproject.com/en/4.1/ref/forms/validation/#raising-validationerror , I think it would make sense to provide this possibility for errors raised by constraints.
If you think it would be a good idea, I'd be happy to work on a PR.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\" django/db/models/constraints.py | head -50"
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
becf6f8b61 SWE-bench
51c9bb7cd1 Refs #33829 -- Added violation_error_message to constraints' __repr__().
dcd9746983 Fixed #34363 -- Fixed floatformat crash on zero with trailing zeros.
?? .memdoor/
```

**tool result**

```
20:    default_violation_error_message = _("Constraint “%(name)s” is violated.")
21:    violation_error_message = None
24:    # def __init__(self, *, name, violation_error_message=None):
25:    def __init__(self, *args, name=None, violation_error_message=None):
33:        if violation_error_message is not None:
34:            self.violation_error_message = violation_error_message
36:            self.violation_error_message = self.default_violation_error_message
45:            for arg, attr in zip(args, ["name", "violation_error_message"]):
65:    def get_violation_error_message(self):
66:        return self.violation_error_message % {"name": self.name}
73:            self.violation_error_message is not None
74:            and self.violation_error_message != self.default_violation_error_message
76:            kwargs["violation_error_message"] = self.violation_error_message
85:    def __init__(self, *, check, name, violation_error_message=None):
91:        super().__init__(name=name, violation_error_message=violation_error_message)
115:                raise ValidationError(self.get_violation_error_message())
126:                if self.violation_error_message is None
127:                or self.violation_error_message == self.default_violation_error_message
128:                else " violation_error_message=%r" % self.violation_error_message
137:                and self.violation_error_message == other.violation_error_message
166:        violation_error_message=None,
216:        super().__init__(name=name, violation_error_message=violation_error_message)
307:                if self.violation_error_message is None
308:                or self.violation_error_message == self.default_violation_error_message
309:                else " violation_error_message=%r" % self.violation_error_message
323:                and self.violation_error_message == other.violation_error_message
388:                    raise ValidationError(self.get_violation_error_message())
403:                    raise ValidationError(self.get_violation_error_message())
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/constraints.py",
  "limit": 150
}
```

**tool result**

```
import warnings
from enum import Enum
from types import NoneType

from django.core.exceptions import FieldError, ValidationError
from django.db import connections
from django.db.models.expressions import Exists, ExpressionList, F, OrderBy
from django.db.models.indexes import IndexExpression
from django.db.models.lookups import Exact
from django.db.models.query_utils import Q
from django.db.models.sql.query import Query
from django.db.utils import DEFAULT_DB_ALIAS
from django.utils.deprecation import RemovedInDjango60Warning
from django.utils.translation import gettext_lazy as _

__all__ = ["BaseConstraint", "CheckConstraint", "Deferrable", "UniqueConstraint"]


class BaseConstraint:
    default_violation_error_message = _("Constraint “%(name)s” is violated.")
    violation_error_message = None

    # RemovedInDjango60Warning: When the deprecation ends, replace with:
    # def __init__(self, *, name, violation_error_message=None):
    def __init__(self, *args, name=None, violation_error_message=None):
        # RemovedInDjango60Warning.
        if name is None and not args:
            raise TypeError(
                f"{self.__class__.__name__}.__init__() missing 1 required keyword-only "
                f"argument: 'name'"
            )
        self.name = name
        if violation_error_message is not None:
            self.violation_error_message = violation_error_message
        else:
            self.violation_error_message = self.default_violation_error_message
        # RemovedInDjango60Warning.
        if args:
            warnings.warn(
                f"Passing positional arguments to {self.__class__.__name__} is "
                f"deprecated.",
                RemovedInDjango60Warning,
                stacklevel=2,
            )
            for arg, attr in zip(args, ["name", "violation_error_message"]):
                if arg:
                    setattr(self, attr, arg)

    @property
    def contains_expressions(self):
        return False

    def constraint_sql(self, model, schema_editor):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def create_sql(self, model, schema_editor):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def remove_sql(self, model, schema_editor):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def get_violation_error_message(self):
        return self.violation_error_message % {"name": self.name}

    def deconstruct(self):
        path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
        path = path.replace("django.db.models.constraints", "django.db.models")
        kwargs = {"name": self.name}
        if (
            self.violation_error_message is not None
            and self.violation_error_message != self.default_violation_error_message
        ):
            kwargs["violation_error_message"] = self.violation_error_message
        return (path, (), kwargs)

    def clone(self):
        _, args, kwargs = self.deconstruct()
        return self.__class__(*args, **kwargs)


class CheckConstraint(BaseConstraint):
    def __init__(self, *, check, name, violation_error_message=None):
        self.check = check
        if not getattr(check, "conditional", False):
            raise TypeError(
                "CheckConstraint.check must be a Q instance or boolean expression."
            )
        super().__init__(name=name, violation_error_message=violation_error_message)

    def _get_check_sql(self, model, schema_editor):
        query = Query(model=model, alias_cols=False)
        where = query.build_where(self.check)
        compiler = query.get_compiler(connection=schema_editor.connection)
        sql, params = where.as_sql(compiler, schema_editor.connection)
        return sql % tuple(schema_editor.quote_value(p) for p in params)

    def constraint_sql(self, model, schema_editor):
        check = self._get_check_sql(model, schema_editor)
        return schema_editor._check_sql(self.name, check)

    def create_sql(self, model, schema_editor):
        check = self._get_check_sql(model, schema_editor)
        return schema_editor._create_check_sql(model, self.name, check)

    def remove_sql(self, model, schema_editor):
        return schema_editor._delete_check_sql(model, self.name)

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
        try:
            if not Q(self.check).check(against, using=using):
                raise ValidationError(self.get_violation_error_message())
        except FieldError:
            pass

    def __repr__(self):
        return "<%s: check=%s name=%s%s>" % (
            self.__class__.__qualname__,
            self.check,
            repr(self.name),
            (
                ""
                if self.violation_error_message is None
                or self.violation_error_message == self.default_violation_error_message
                else " violation_error_message=%r" % self.violation_error_message
            ),
        )

    def __eq__(self, other):
        if isinstance(other, CheckConstraint):
            return (
                self.name == other.name
                and self.check == other.check
                and self.violation_error_message == other.violation_error_message
            )
        return super().__eq__(other)

    def deconstruct(self):
        path, args, kwargs = super().deconstruct()
        kwargs["check"] = self.check
        return path, args, kwargs


class Deferrable(Enum):
    DEFERRED = "deferred"
    IMMEDIATE = "immediate"


[255 more lines in /testbed/django/db/models/constraints.py (405 in all). read_file with offset: 151 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/constraints.py",
  "offset": 150,
  "limit": 260
}
```

**tool result**

```

    # A similar format was proposed for Python 3.10.
    def __repr__(self):
        return f"{self.__class__.__qualname__}.{self._name_}"


class UniqueConstraint(BaseConstraint):
    def __init__(
        self,
        *expressions,
        fields=(),
        name=None,
        condition=None,
        deferrable=None,
        include=None,
        opclasses=(),
        violation_error_message=None,
    ):
        if not name:
            raise ValueError("A unique constraint must be named.")
        if not expressions and not fields:
            raise ValueError(
                "At least one field or expression is required to define a "
                "unique constraint."
            )
        if expressions and fields:
            raise ValueError(
                "UniqueConstraint.fields and expressions are mutually exclusive."
            )
        if not isinstance(condition, (NoneType, Q)):
            raise ValueError("UniqueConstraint.condition must be a Q instance.")
        if condition and deferrable:
            raise ValueError("UniqueConstraint with conditions cannot be deferred.")
        if include and deferrable:
            raise ValueError("UniqueConstraint with include fields cannot be deferred.")
        if opclasses and deferrable:
            raise ValueError("UniqueConstraint with opclasses cannot be deferred.")
        if expressions and deferrable:
            raise ValueError("UniqueConstraint with expressions cannot be deferred.")
        if expressions and opclasses:
            raise ValueError(
                "UniqueConstraint.opclasses cannot be used with expressions. "
                "Use django.contrib.postgres.indexes.OpClass() instead."
            )
        if not isinstance(deferrable, (NoneType, Deferrable)):
            raise ValueError(
                "UniqueConstraint.deferrable must be a Deferrable instance."
            )
        if not isinstance(include, (NoneType, list, tuple)):
            raise ValueError("UniqueConstraint.include must be a list or tuple.")
        if not isinstance(opclasses, (list, tuple)):
            raise ValueError("UniqueConstraint.opclasses must be a list or tuple.")
        if opclasses and len(fields) != len(opclasses):
            raise ValueError(
                "UniqueConstraint.fields and UniqueConstraint.opclasses must "
                "have the same number of elements."
            )
        self.fields = tuple(fields)
        self.condition = condition
        self.deferrable = deferrable
        self.include = tuple(include) if include else ()
        self.opclasses = opclasses
        self.expressions = tuple(
            F(expression) if isinstance(expression, str) else expression
            for expression in expressions
        )
        super().__init__(name=name, violation_error_message=violation_error_message)

    @property
    def contains_expressions(self):
        return bool(self.expressions)

    def _get_condition_sql(self, model, schema_editor):
        if self.condition is None:
            return None
        query = Query(model=model, alias_cols=False)
        where = query.build_where(self.condition)
        compiler = query.get_compiler(connection=schema_editor.connection)
        sql, params = where.as_sql(compiler, schema_editor.connection)
        return sql % tuple(schema_editor.quote_value(p) for p in params)

    def _get_index_expressions(self, model, schema_editor):
        if not self.expressions:
            return None
        index_expressions = []
        for expression in self.expressions:
            index_expression = IndexExpression(expression)
            index_expression.set_wrapper_classes(schema_editor.connection)
            index_expressions.append(index_expression)
        return ExpressionList(*index_expressions).resolve_expression(
            Query(model, alias_cols=False),
        )

    def constraint_sql(self, model, schema_editor):
        fields = [model._meta.get_field(field_name) for field_name in self.fields]
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        condition = self._get_condition_sql(model, schema_editor)
        expressions = self._get_index_expressions(model, schema_editor)
        return schema_editor._unique_sql(
            model,
            fields,
            self.name,
            condition=condition,
            deferrable=self.deferrable,
            include=include,
            opclasses=self.opclasses,
            expressions=expressions,
        )

    def create_sql(self, model, schema_editor):
        fields = [model._meta.get_field(field_name) for field_name in self.fields]
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        condition = self._get_condition_sql(model, schema_editor)
        expressions = self._get_index_expressions(model, schema_editor)
        return schema_editor._create_unique_sql(
            model,
            fields,
            self.name,
            condition=condition,
            deferrable=self.deferrable,
            include=include,
            opclasses=self.opclasses,
            expressions=expressions,
        )

    def remove_sql(self, model, schema_editor):
        condition = self._get_condition_sql(model, schema_editor)
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        expressions = self._get_index_expressions(model, schema_editor)
        return schema_editor._delete_unique_sql(
            model,
            self.name,
            condition=condition,
            deferrable=self.deferrable,
            include=include,
            opclasses=self.opclasses,
            expressions=expressions,
        )

    def __repr__(self):
        return "<%s:%s%s%s%s%s%s%s%s>" % (
            self.__class__.__qualname__,
            "" if not self.fields else " fields=%s" % repr(self.fields),
            "" if not self.expressions else " expressions=%s" % repr(self.expressions),
            " name=%s" % repr(self.name),
            "" if self.condition is None else " condition=%s" % self.condition,
            "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
            "" if not self.include else " include=%s" % repr(self.include),
            "" if not self.opclasses else " opclasses=%s" % repr(self.opclasses),
            (
                ""
                if self.violation_error_message is None
                or self.violation_error_message == self.default_violation_error_message
                else " violation_error_message=%r" % self.violation_error_message
            ),
        )

    def __eq__(self, other):
        if isinstance(other, UniqueConstraint):
            return (
                self.name == other.name
                and self.fields == other.fields
                and self.condition == other.condition
                and self.deferrable == other.deferrable
                and self.include == other.include
                and self.opclasses == other.opclasses
                and self.expressions == other.expressions
                and self.violation_error_message == other.violation_error_message
            )
        return super().__eq__(other)

    def deconstruct(self):
        path, args, kwargs = super().deconstruct()
        if self.fields:
            kwargs["fields"] = self.fields
        if self.condition:
            kwargs["condition"] = self.condition
        if self.deferrable:
            kwargs["deferrable"] = self.deferrable
        if self.include:
            kwargs["include"] = self.include
        if self.opclasses:
            kwargs["opclasses"] = self.opclasses
        return path, self.expressions, kwargs

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        queryset = model._default_manager.using(using)
        if self.fields:
            lookup_kwargs = {}
            for field_name in self.fields:
                if exclude and field_name in exclude:
                    return
                field = model._meta.get_field(field_name)
                lookup_value = getattr(instance, field.attname)
                if lookup_value is None or (
                    lookup_value == ""
                    and connections[using].features.interprets_empty_strings_as_nulls
                ):
                    # A composite constraint containing NULL value cannot cause
                    # a violation since NULL != NULL in SQL.
                    return
                lookup_kwargs[field.name] = lookup_value
            queryset = queryset.filter(**lookup_kwargs)
        else:
            # Ignore constraints with excluded fields.
            if exclude:
                for expression in self.expressions:
                    if hasattr(expression, "flatten"):
                        for expr in expression.flatten():
                            if isinstance(expr, F) and expr.name in exclude:
                                return
                    elif isinstance(expression, F) and expression.name in exclude:
                        return
            replacements = {
                F(field): value
                for field, value in instance._get_field_value_map(
                    meta=model._meta, exclude=exclude
                ).items()
            }
            expressions = []
            for expr in self.expressions:
                # Ignore ordering.
                if isinstance(expr, OrderBy):
                    expr = expr.expression
                expressions.append(Exact(expr, expr.replace_expressions(replacements)))
            queryset = queryset.filter(*expressions)
        model_class_pk = instance._get_pk_val(model._meta)
        if not instance._state.adding and model_class_pk is not None:
            queryset = queryset.exclude(pk=model_class_pk)
        if not self.condition:
            if queryset.exists():
                if self.expressions:
                    raise ValidationError(self.get_violation_error_message())
                # When fields are defined, use the unique_error_message() for
                # backward compatibility.
                for model, constraints in instance.get_constraints():
                    for constraint in constraints:
                        if constraint is self:
                            raise ValidationError(
                                instance.unique_error_message(model, self.fields)
                            )
        else:
            against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
            try:
                if (self.condition & Exists(queryset.filter(self.condition))).check(
                    against, using=using
                ):
                    raise ValidationError(self.get_violation_error_message())
            except FieldError:
                pass

[lines 150-405 of /testbed/django/db/models/constraints.py, the end]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"violation_error_message\\|violation_error_code\" docs/ref/models/constraints.txt tests/constraints/tests.py | head -80"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\" docs/releases/4.1.txt docs/releases/5.0.txt 2>/dev/null | head"
}
```

**tool result**

```
docs/ref/models/constraints.txt:51:.. class:: BaseConstraint(*, name, violation_error_message=None)
docs/ref/models/constraints.txt:71:``violation_error_message``
docs/ref/models/constraints.txt:74:.. attribute:: BaseConstraint.violation_error_message
docs/ref/models/constraints.txt:97:.. class:: CheckConstraint(*, check, name, violation_error_message=None)
docs/ref/models/constraints.txt:124:.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)
docs/ref/models/constraints.txt:245:``violation_error_message``
docs/ref/models/constraints.txt:248:.. attribute:: UniqueConstraint.violation_error_message
docs/ref/models/constraints.txt:252::attr:`.BaseConstraint.violation_error_message`.
tests/constraints/tests.py:58:    def test_default_violation_error_message(self):
tests/constraints/tests.py:61:            c.get_violation_error_message(), "Constraint “name” is violated."
tests/constraints/tests.py:64:    def test_custom_violation_error_message(self):
tests/constraints/tests.py:66:            name="base_name", violation_error_message="custom %(name)s message"
tests/constraints/tests.py:68:        self.assertEqual(c.get_violation_error_message(), "custom base_name message")
tests/constraints/tests.py:70:    def test_custom_violation_error_message_clone(self):
tests/constraints/tests.py:73:            violation_error_message="custom %(name)s message",
tests/constraints/tests.py:76:            constraint.get_violation_error_message(),
tests/constraints/tests.py:83:            violation_error_message="custom %(name)s message",
tests/constraints/tests.py:90:            {"name": "base_name", "violation_error_message": "custom %(name)s message"},
tests/constraints/tests.py:108:        self.assertEqual(c.get_violation_error_message(), "custom name message")
tests/constraints/tests.py:132:                check=check1, name="price", violation_error_message="custom error"
tests/constraints/tests.py:137:                check=check1, name="price", violation_error_message="custom error"
tests/constraints/tests.py:140:                check=check1, name="price", violation_error_message="other custom error"
tests/constraints/tests.py:145:                check=check1, name="price", violation_error_message="custom error"
tests/constraints/tests.py:148:                check=check1, name="price", violation_error_message="custom error"
tests/constraints/tests.py:163:    def test_repr_with_violation_error_message(self):
tests/constraints/tests.py:167:            violation_error_message="More than 1",
tests/constraints/tests.py:172:            "violation_error_message='More than 1'>",
tests/constraints/tests.py:317:                violation_error_message="custom error",
tests/constraints/tests.py:324:                violation_error_message="custom error",
tests/constraints/tests.py:329:                violation_error_message="other custom error",
tests/constraints/tests.py:336:                violation_error_message="custom error",
tests/constraints/tests.py:341:                violation_error_message="custom error",
tests/constraints/tests.py:501:    def test_repr_with_violation_error_message(self):
tests/constraints/tests.py:505:            violation_error_message="BAZ",
tests/constraints/tests.py:511:                "name='unique_lower_baz' violation_error_message='BAZ'>"
```

**tool result**

```
docs/releases/5.0.txt:270:* Passing positional arguments  ``name`` and ``violation_error_message`` to
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/constraints/tests.py",
  "limit": 190
}
```

**assistant → tool `read_file`**

```json
{
  "path": "docs/ref/models/constraints.txt",
  "limit": 270
}
```

**tool result**

```
from unittest import mock

from django.core.exceptions import ValidationError
from django.db import IntegrityError, connection, models
from django.db.models import F
from django.db.models.constraints import BaseConstraint, UniqueConstraint
from django.db.models.functions import Lower
from django.db.transaction import atomic
from django.test import SimpleTestCase, TestCase, skipIfDBFeature, skipUnlessDBFeature
from django.test.utils import ignore_warnings
from django.utils.deprecation import RemovedInDjango60Warning

from .models import (
    ChildModel,
    ChildUniqueConstraintProduct,
    Product,
    UniqueConstraintConditionProduct,
    UniqueConstraintDeferrable,
    UniqueConstraintInclude,
    UniqueConstraintProduct,
)


def get_constraints(table):
    with connection.cursor() as cursor:
        return connection.introspection.get_constraints(cursor, table)


class BaseConstraintTests(SimpleTestCase):
    def test_constraint_sql(self):
        c = BaseConstraint(name="name")
        msg = "This method must be implemented by a subclass."
        with self.assertRaisesMessage(NotImplementedError, msg):
            c.constraint_sql(None, None)

    def test_contains_expressions(self):
        c = BaseConstraint(name="name")
        self.assertIs(c.contains_expressions, False)

    def test_create_sql(self):
        c = BaseConstraint(name="name")
        msg = "This method must be implemented by a subclass."
        with self.assertRaisesMessage(NotImplementedError, msg):
            c.create_sql(None, None)

    def test_remove_sql(self):
        c = BaseConstraint(name="name")
        msg = "This method must be implemented by a subclass."
        with self.assertRaisesMessage(NotImplementedError, msg):
            c.remove_sql(None, None)

    def test_validate(self):
        c = BaseConstraint(name="name")
        msg = "This method must be implemented by a subclass."
        with self.assertRaisesMessage(NotImplementedError, msg):
            c.validate(None, None)

    def test_default_violation_error_message(self):
        c = BaseConstraint(name="name")
        self.assertEqual(
            c.get_violation_error_message(), "Constraint “name” is violated."
        )

    def test_custom_violation_error_message(self):
        c = BaseConstraint(
            name="base_name", violation_error_message="custom %(name)s message"
        )
        self.assertEqual(c.get_violation_error_message(), "custom base_name message")

    def test_custom_violation_error_message_clone(self):
        constraint = BaseConstraint(
            name="base_name",
            violation_error_message="custom %(name)s message",
        ).clone()
        self.assertEqual(
            constraint.get_violation_error_message(),
            "custom base_name message",
        )

    def test_deconstruction(self):
        constraint = BaseConstraint(
            name="base_name",
            violation_error_message="custom %(name)s message",
        )
        path, args, kwargs = constraint.deconstruct()
        self.assertEqual(path, "django.db.models.BaseConstraint")
        self.assertEqual(args, ())
        self.assertEqual(
            kwargs,
            {"name": "base_name", "violation_error_message": "custom %(name)s message"},
        )

    def test_deprecation(self):
        msg = "Passing positional arguments to BaseConstraint is deprecated."
        with self.assertRaisesMessage(RemovedInDjango60Warning, msg):
            BaseConstraint("name", "violation error message")

    def test_name_required(self):
        msg = (
            "BaseConstraint.__init__() missing 1 required keyword-only argument: 'name'"
        )
        with self.assertRaisesMessage(TypeError, msg):
            BaseConstraint()

    @ignore_warnings(category=RemovedInDjango60Warning)
    def test_positional_arguments(self):
        c = BaseConstraint("name", "custom %(name)s message")
        self.assertEqual(c.get_violation_error_message(), "custom name message")


class CheckConstraintTests(TestCase):
    def test_eq(self):
        check1 = models.Q(price__gt=models.F("discounted_price"))
        check2 = models.Q(price__lt=models.F("discounted_price"))
        self.assertEqual(
            models.CheckConstraint(check=check1, name="price"),
            models.CheckConstraint(check=check1, name="price"),
        )
        self.assertEqual(models.CheckConstraint(check=check1, name="price"), mock.ANY)
        self.assertNotEqual(
            models.CheckConstraint(check=check1, name="price"),
            models.CheckConstraint(check=check1, name="price2"),
        )
        self.assertNotEqual(
            models.CheckConstraint(check=check1, name="price"),
            models.CheckConstraint(check=check2, name="price"),
        )
        self.assertNotEqual(models.CheckConstraint(check=check1, name="price"), 1)
        self.assertNotEqual(
            models.CheckConstraint(check=check1, name="price"),
            models.CheckConstraint(
                check=check1, name="price", violation_error_message="custom error"
            ),
        )
        self.assertNotEqual(
            models.CheckConstraint(
                check=check1, name="price", violation_error_message="custom error"
            ),
            models.CheckConstraint(
                check=check1, name="price", violation_error_message="other custom error"
            ),
        )
        self.assertEqual(
            models.CheckConstraint(
                check=check1, name="price", violation_error_message="custom error"
            ),
            models.CheckConstraint(
                check=check1, name="price", violation_error_message="custom error"
            ),
        )

    def test_repr(self):
        constraint = models.CheckConstraint(
            check=models.Q(price__gt=models.F("discounted_price")),
            name="price_gt_discounted_price",
        )
        self.assertEqual(
            repr(constraint),
            "<CheckConstraint: check=(AND: ('price__gt', F(discounted_price))) "
            "name='price_gt_discounted_price'>",
        )

    def test_repr_with_violation_error_message(self):
        constraint = models.CheckConstraint(
            check=models.Q(price__lt=1),
            name="price_lt_one",
            violation_error_message="More than 1",
        )
        self.assertEqual(
            repr(constraint),
            "<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' "
            "violation_error_message='More than 1'>",
        )

    def test_invalid_check_types(self):
        msg = "CheckConstraint.check must be a Q instance or boolean expression."
        with self.assertRaisesMessage(TypeError, msg):
            models.CheckConstraint(check=models.F("discounted_price"), name="check")

    def test_deconstruction(self):
        check = models.Q(price__gt=models.F("discounted_price"))
        name = "price_gt_discounted_price"
        constraint = models.CheckConstraint(check=check, name=name)
        path, args, kwargs = constraint.deconstruct()
        self.assertEqual(path, "django.db.models.CheckConstraint")
        self.assertEqual(args, ())
        self.assertEqual(kwargs, {"check": check, "name": name})

    @skipUnlessDBFeature("supports_table_check_constraints")
    def test_database_constraint(self):

[775 more lines in /testbed/tests/constraints/tests.py (965 in all). read_file with offset: 191 to continue]
```

**tool result**

```
=====================
Constraints reference
=====================

.. module:: django.db.models.constraints

.. currentmodule:: django.db.models

The classes defined in this module create database constraints. They are added
in the model :attr:`Meta.constraints <django.db.models.Options.constraints>`
option.

.. admonition:: Referencing built-in constraints

    Constraints are defined in ``django.db.models.constraints``, but for
    convenience they're imported into :mod:`django.db.models`. The standard
    convention is to use ``from django.db import models`` and refer to the
    constraints as ``models.<Foo>Constraint``.

.. admonition:: Constraints in abstract base classes

    You must always specify a unique name for the constraint. As such, you
    cannot normally specify a constraint on an abstract base class, since the
    :attr:`Meta.constraints <django.db.models.Options.constraints>` option is
    inherited by subclasses, with exactly the same values for the attributes
    (including ``name``) each time. To work around name collisions, part of the
    name may contain ``'%(app_label)s'`` and ``'%(class)s'``, which are
    replaced, respectively, by the lowercased app label and class name of the
    concrete model. For example ``CheckConstraint(check=Q(age__gte=18),
    name='%(app_label)s_%(class)s_is_adult')``.

.. admonition:: Validation of Constraints

    Constraints are checked during the :ref:`model validation
    <validating-objects>`.

.. admonition:: Validation of Constraints with ``JSONField``

    Constraints containing :class:`~django.db.models.JSONField` may not raise
    validation errors as key, index, and path transforms have many
    database-specific caveats. This :ticket:`may be fully supported later
    <34059>`.

    You should always check that there are no log messages, in the
    ``django.db.models`` logger, like *"Got a database error calling check() on
    …"* to confirm it's validated properly.

``BaseConstraint``
==================

.. class:: BaseConstraint(*, name, violation_error_message=None)

    Base class for all constraints. Subclasses must implement
    ``constraint_sql()``, ``create_sql()``, ``remove_sql()`` and
    ``validate()`` methods.

    .. deprecated:: 5.0

        Support for passing positional arguments is deprecated.

All constraints have the following parameters in common:

``name``
--------

.. attribute:: BaseConstraint.name

The name of the constraint. You must always specify a unique name for the
constraint.

``violation_error_message``
---------------------------

.. attribute:: BaseConstraint.violation_error_message

The error message used when ``ValidationError`` is raised during
:ref:`model validation <validating-objects>`. Defaults to
``"Constraint “%(name)s” is violated."``.

``validate()``
--------------

.. method:: BaseConstraint.validate(model, instance, exclude=None, using=DEFAULT_DB_ALIAS)

Validates that the constraint, defined on ``model``, is respected on the
``instance``. This will do a query on the database to ensure that the
constraint is respected. If fields in the ``exclude`` list are needed to
validate the constraint, the constraint is ignored.

Raise a ``ValidationError`` if the constraint is violated.

This method must be implemented by a subclass.

``CheckConstraint``
===================

.. class:: CheckConstraint(*, check, name, violation_error_message=None)

    Creates a check constraint in the database.

``check``
---------

.. attribute:: CheckConstraint.check

A :class:`Q` object or boolean :class:`~django.db.models.Expression` that
specifies the check you want the constraint to enforce.

For example, ``CheckConstraint(check=Q(age__gte=18), name='age_gte_18')``
ensures the age field is never less than 18.

.. admonition:: Oracle

    Checks with nullable fields on Oracle must include a condition allowing for
    ``NULL`` values in order for :meth:`validate() <BaseConstraint.validate>`
    to behave the same as check constraints validation. For example, if ``age``
    is a nullable field::

        CheckConstraint(check=Q(age__gte=18) | Q(age__isnull=True), name='age_gte_18')

``UniqueConstraint``
====================

.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)

    Creates a unique constraint in the database.

``expressions``
---------------

.. attribute:: UniqueConstraint.expressions

Positional argument ``*expressions`` allows creating functional unique
constraints on expressions and database functions.

For example::

    UniqueConstraint(Lower('name').desc(), 'category', name='unique_lower_name_category')

creates a unique constraint on the lowercased value of the ``name`` field in
descending order and the ``category`` field in the default ascending order.

Functional unique constraints have the same database restrictions as
:attr:`Index.expressions`.

``fields``
----------

.. attribute:: UniqueConstraint.fields

A list of field names that specifies the unique set of columns you want the
constraint to enforce.

For example, ``UniqueConstraint(fields=['room', 'date'],
name='unique_booking')`` ensures each room can only be booked once for each
date.

``condition``
-------------

.. attribute:: UniqueConstraint.condition

A :class:`Q` object that specifies the condition you want the constraint to
enforce.

For example::

    UniqueConstraint(fields=['user'], condition=Q(status='DRAFT'), name='unique_draft_user')

ensures that each user only has one draft.

These conditions have the same database restrictions as
:attr:`Index.condition`.

``deferrable``
--------------

.. attribute:: UniqueConstraint.deferrable

Set this parameter to create a deferrable unique constraint. Accepted values
are ``Deferrable.DEFERRED`` or ``Deferrable.IMMEDIATE``. For example::

    from django.db.models import Deferrable, UniqueConstraint

    UniqueConstraint(
        name='unique_order',
        fields=['order'],
        deferrable=Deferrable.DEFERRED,
    )

By default constraints are not deferred. A deferred constraint will not be
enforced until the end of the transaction. An immediate constraint will be
enforced immediately after every command.

.. admonition:: MySQL, MariaDB, and SQLite.

    Deferrable unique constraints are ignored on MySQL, MariaDB, and SQLite as
    neither supports them.

.. warning::

    Deferred unique constraints may lead to a `performance penalty
    <https://www.postgresql.org/docs/current/sql-createtable.html#id-1.9.3.85.9.4>`_.

``include``
-----------

.. attribute:: UniqueConstraint.include

A list or tuple of the names of the fields to be included in the covering
unique index as non-key columns. This allows index-only scans to be used for
queries that select only included fields (:attr:`~UniqueConstraint.include`)
and filter only by unique fields (:attr:`~UniqueConstraint.fields`).

For example::

    UniqueConstraint(name='unique_booking', fields=['room', 'date'], include=['full_name'])

will allow filtering on ``room`` and ``date``, also selecting ``full_name``,
while fetching data only from the index.

``include`` is supported only on PostgreSQL.

Non-key columns have the same database restrictions as :attr:`Index.include`.


``opclasses``
-------------

.. attribute:: UniqueConstraint.opclasses

The names of the `PostgreSQL operator classes
<https://www.postgresql.org/docs/current/indexes-opclass.html>`_ to use for
this unique index. If you require a custom operator class, you must provide one
for each field in the index.

For example::

    UniqueConstraint(name='unique_username', fields=['username'], opclasses=['varchar_pattern_ops'])

creates a unique index on ``username`` using ``varchar_pattern_ops``.

``opclasses`` are ignored for databases besides PostgreSQL.

``violation_error_message``
---------------------------

.. attribute:: UniqueConstraint.violation_error_message

The error message used when ``ValidationError`` is raised during
:ref:`model validation <validating-objects>`. Defaults to
:attr:`.BaseConstraint.violation_error_message`.

This message is *not used* for :class:`UniqueConstraint`\s with
:attr:`~UniqueConstraint.fields` and without a
:attr:`~UniqueConstraint.condition`. Such :class:`~UniqueConstraint`\s show the
same message as constraints defined with
:attr:`.Field.unique` or in
:attr:`Meta.unique_together <django.db.models.Options.constraints>`.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_validate\\|ValidationError\\|violation_error\" tests/constraints/tests.py | sed -n '1,120p'"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_code\" . --exclude-dir=.git --exclude-dir=.memdoor | head"
}
```

**tool result**

```
3:from django.core.exceptions import ValidationError
52:    def test_validate(self):
58:    def test_default_violation_error_message(self):
61:            c.get_violation_error_message(), "Constraint “name” is violated."
64:    def test_custom_violation_error_message(self):
66:            name="base_name", violation_error_message="custom %(name)s message"
68:        self.assertEqual(c.get_violation_error_message(), "custom base_name message")
70:    def test_custom_violation_error_message_clone(self):
73:            violation_error_message="custom %(name)s message",
76:            constraint.get_violation_error_message(),
83:            violation_error_message="custom %(name)s message",
90:            {"name": "base_name", "violation_error_message": "custom %(name)s message"},
108:        self.assertEqual(c.get_violation_error_message(), "custom name message")
132:                check=check1, name="price", violation_error_message="custom error"
137:                check=check1, name="price", violation_error_message="custom error"
140:                check=check1, name="price", violation_error_message="other custom error"
145:                check=check1, name="price", violation_error_message="custom error"
148:                check=check1, name="price", violation_error_message="custom error"
163:    def test_repr_with_violation_error_message(self):
167:            violation_error_message="More than 1",
172:            "violation_error_message='More than 1'>",
220:    def test_validate(self):
225:        with self.assertRaises(ValidationError):
227:        with self.assertRaises(ValidationError):
240:    def test_validate_boolean_expressions(self):
249:        with self.assertRaisesMessage(ValidationError, msg):
254:    def test_validate_rawsql_expressions_noop(self):
269:    def test_validate_nullable_field_with_none(self):
278:    def test_validate_nullable_field_with_isnull(self):
317:                violation_error_message="custom error",
324:                violation_error_message="custom error",
329:                violation_error_message="other custom error",
336:                violation_error_message="custom error",
341:                violation_error_message="custom error",
501:    def test_repr_with_violation_error_message(self):
505:            violation_error_message="BAZ",
511:                "name='unique_lower_baz' violation_error_message='BAZ'>"
617:        with self.assertRaisesMessage(ValidationError, msg):
634:        with self.assertRaisesMessage(ValidationError, msg):
640:                raise ValidationError({"name": ValidationError("Already exists.")})
654:        with self.assertRaisesMessage(ValidationError, msg):
657:    def test_validate(self):
663:        with self.assertRaisesMessage(ValidationError, msg):
689:        with self.assertRaisesMessage(ValidationError, msg):
696:    def test_validate_condition(self):
700:        with self.assertRaisesMessage(ValidationError, msg):
719:    def test_validate_expression(self):
722:        with self.assertRaisesMessage(ValidationError, msg):
740:    def test_validate_ordered_expression(self):
745:        with self.assertRaisesMessage(ValidationError, msg):
763:    def test_validate_expression_condition(self):
771:        with self.assertRaisesMessage(ValidationError, msg):
793:    def test_validate_expression_str(self):
796:        with self.assertRaisesMessage(ValidationError, msg):
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"constraint\\|Constraint\" docs/releases/5.0.txt | head -30"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '200,260p' tests/constraints/tests.py; sed -n '600,730p' tests/constraints/tests.py"
}
```

**tool result**

```
271:  :class:`~django.db.models.BaseConstraint` is deprecated in favor of
341:  ``django.contrib.postgres.constraints.ExclusionConstraint`` is removed.
```

**tool result**

```

    @skipUnlessDBFeature(
        "supports_table_check_constraints", "can_introspect_check_constraints"
    )
    def test_name(self):
        constraints = get_constraints(Product._meta.db_table)
        for expected_name in (
            "price_gt_discounted_price",
            "constraints_product_price_gt_0",
        ):
            with self.subTest(expected_name):
                self.assertIn(expected_name, constraints)

    @skipUnlessDBFeature(
        "supports_table_check_constraints", "can_introspect_check_constraints"
    )
    def test_abstract_name(self):
        constraints = get_constraints(ChildModel._meta.db_table)
        self.assertIn("constraints_childmodel_adult", constraints)

    def test_validate(self):
        check = models.Q(price__gt=models.F("discounted_price"))
        constraint = models.CheckConstraint(check=check, name="price")
        # Invalid product.
        invalid_product = Product(price=10, discounted_price=42)
        with self.assertRaises(ValidationError):
            constraint.validate(Product, invalid_product)
        with self.assertRaises(ValidationError):
            constraint.validate(Product, invalid_product, exclude={"unit"})
        # Fields used by the check constraint are excluded.
        constraint.validate(Product, invalid_product, exclude={"price"})
        constraint.validate(Product, invalid_product, exclude={"discounted_price"})
        constraint.validate(
            Product,
            invalid_product,
            exclude={"discounted_price", "price"},
        )
        # Valid product.
        constraint.validate(Product, Product(price=10, discounted_price=5))

    def test_validate_boolean_expressions(self):
        constraint = models.CheckConstraint(
            check=models.expressions.ExpressionWrapper(
                models.Q(price__gt=500) | models.Q(price__lt=500),
                output_field=models.BooleanField(),
            ),
            name="price_neq_500_wrap",
        )
        msg = f"Constraint “{constraint.name}” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(Product, Product(price=500, discounted_price=5))
        constraint.validate(Product, Product(price=501, discounted_price=5))
        constraint.validate(Product, Product(price=499, discounted_price=5))

    def test_validate_rawsql_expressions_noop(self):
        constraint = models.CheckConstraint(
            check=models.expressions.RawSQL(
                "price < %s OR price > %s",
                (500, 500),
                output_field=models.BooleanField(),
            ),
        self.assertEqual(kwargs, {"name": name})

    def test_database_constraint(self):
        with self.assertRaises(IntegrityError):
            UniqueConstraintProduct.objects.create(
                name=self.p1.name, color=self.p1.color
            )

    @skipUnlessDBFeature("supports_partial_indexes")
    def test_database_constraint_with_condition(self):
        UniqueConstraintConditionProduct.objects.create(name="p1")
        UniqueConstraintConditionProduct.objects.create(name="p2")
        with self.assertRaises(IntegrityError):
            UniqueConstraintConditionProduct.objects.create(name="p1")

    def test_model_validation(self):
        msg = "Unique constraint product with this Name and Color already exists."
        with self.assertRaisesMessage(ValidationError, msg):
            UniqueConstraintProduct(
                name=self.p1.name, color=self.p1.color
            ).validate_constraints()

    @skipUnlessDBFeature("supports_partial_indexes")
    def test_model_validation_with_condition(self):
        """
        Partial unique constraints are not ignored by
        Model.validate_constraints().
        """
        obj1 = UniqueConstraintConditionProduct.objects.create(name="p1", color="red")
        obj2 = UniqueConstraintConditionProduct.objects.create(name="p2")
        UniqueConstraintConditionProduct(
            name=obj1.name, color="blue"
        ).validate_constraints()
        msg = "Constraint “name_without_color_uniq” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            UniqueConstraintConditionProduct(name=obj2.name).validate_constraints()

    def test_model_validation_constraint_no_code_error(self):
        class ValidateNoCodeErrorConstraint(UniqueConstraint):
            def validate(self, model, instance, **kwargs):
                raise ValidationError({"name": ValidationError("Already exists.")})

        class NoCodeErrorConstraintModel(models.Model):
            name = models.CharField(max_length=255)

            class Meta:
                constraints = [
                    ValidateNoCodeErrorConstraint(
                        Lower("name"),
                        name="custom_validate_no_code_error",
                    )
                ]

        msg = "{'name': ['Already exists.']}"
        with self.assertRaisesMessage(ValidationError, msg):
            NoCodeErrorConstraintModel(name="test").validate_constraints()

    def test_validate(self):
        constraint = UniqueConstraintProduct._meta.constraints[0]
        msg = "Unique constraint product with this Name and Color already exists."
        non_unique_product = UniqueConstraintProduct(
            name=self.p1.name, color=self.p1.color
        )
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(UniqueConstraintProduct, non_unique_product)
        # Null values are ignored.
        constraint.validate(
            UniqueConstraintProduct,
            UniqueConstraintProduct(name=self.p2.name, color=None),
        )
        # Existing instances have their existing row excluded.
        constraint.validate(UniqueConstraintProduct, self.p1)
        # Unique fields are excluded.
        constraint.validate(
            UniqueConstraintProduct,
            non_unique_product,
            exclude={"name"},
        )
        constraint.validate(
            UniqueConstraintProduct,
            non_unique_product,
            exclude={"color"},
        )
        constraint.validate(
            UniqueConstraintProduct,
            non_unique_product,
            exclude={"name", "color"},
        )
        # Validation on a child instance.
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintProduct,
                ChildUniqueConstraintProduct(name=self.p1.name, color=self.p1.color),
            )

    @skipUnlessDBFeature("supports_partial_indexes")
    def test_validate_condition(self):
        p1 = UniqueConstraintConditionProduct.objects.create(name="p1")
        constraint = UniqueConstraintConditionProduct._meta.constraints[0]
        msg = "Constraint “name_without_color_uniq” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintConditionProduct,
                UniqueConstraintConditionProduct(name=p1.name, color=None),
            )
        # Values not matching condition are ignored.
        constraint.validate(
            UniqueConstraintConditionProduct,
            UniqueConstraintConditionProduct(name=p1.name, color="anything-but-none"),
        )
        # Existing instances have their existing row excluded.
        constraint.validate(UniqueConstraintConditionProduct, p1)
        # Unique field is excluded.
        constraint.validate(
            UniqueConstraintConditionProduct,
            UniqueConstraintConditionProduct(name=p1.name, color=None),
            exclude={"name"},
        )

    def test_validate_expression(self):
        constraint = models.UniqueConstraint(Lower("name"), name="name_lower_uniq")
        msg = "Constraint “name_lower_uniq” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintProduct,
                UniqueConstraintProduct(name=self.p1.name.upper()),
            )
        constraint.validate(
            UniqueConstraintProduct,
            UniqueConstraintProduct(name="another-name"),
        )
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '250,290p' docs/releases/5.0.txt; grep -n \"Models\" docs/releases/5.0.txt | head"
}
```

**tool result**

```

Miscellaneous
-------------

* The ``instance`` argument of the undocumented
  ``BaseModelFormSet.save_existing()`` method is renamed to ``obj``.

* The undocumented ``django.contrib.admin.helpers.checkbox`` is removed.

.. _deprecated-features-5.0:

Features deprecated in 5.0
==========================

Miscellaneous
-------------

* The ``DjangoDivFormRenderer`` and ``Jinja2DivFormRenderer`` transitional form
  renderers are deprecated.

* Passing positional arguments  ``name`` and ``violation_error_message`` to
  :class:`~django.db.models.BaseConstraint` is deprecated in favor of
  keyword-only arguments.

Features removed in 5.0
=======================

These features have reached the end of their deprecation cycle and are removed
in Django 5.0.

See :ref:`deprecated-features-4.0` for details on these changes, including how
to remove usage of these features.

* The ``SERIALIZE`` test setting is removed.

* The undocumented ``django.utils.baseconv`` module is removed.

* The undocumented ``django.utils.datetime_safe`` module is removed.

* The default value of the ``USE_TZ`` setting is changed from ``False`` to
  ``True``.
178:Models
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '170,250p' docs/releases/5.0.txt"
}
```

**tool result**

```

* ...

Migrations
~~~~~~~~~~

* ...

Models
~~~~~~

* The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`
  and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different
  field values for the create operation.

Requests and Responses
~~~~~~~~~~~~~~~~~~~~~~

* ...

Security
~~~~~~~~

* ...

Serialization
~~~~~~~~~~~~~

* ...

Signals
~~~~~~~

* ...

Templates
~~~~~~~~~

* ...

Tests
~~~~~

* ...

URLs
~~~~

* ...

Utilities
~~~~~~~~~

* ...

Validators
~~~~~~~~~~

* ...

.. _backwards-incompatible-5.0:

Backwards incompatible changes in 5.0
=====================================

Database backend API
--------------------

This section describes changes that may be needed in third-party database
backends.

* ...

Using ``create_defaults__exact`` may now be required with ``QuerySet.update_or_create()``
-----------------------------------------------------------------------------------------

:meth:`.QuerySet.update_or_create` now supports the parameter
``create_defaults``. As a consequence, any models that have a field named
``create_defaults`` that are used with an ``update_or_create()`` should specify
the field in the lookup with ``create_defaults__exact``.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n class BaseConstraint:\n     default_violation_error_message = _(\"Constraint “%(name)s” is violated.\")\n+    violation_error_code = None\n     violation_error_message = None\n \n     # RemovedInDjango60Warning: When the deprecation ends, replace with:\n-    # def __init__(self, *, name, violation_error_message=None):\n-    def __init__(self, *args, name=None, violation_error_message=None):\n+    # def __init__(self, *, name, violation_error_code=None, violation_error_message=None):\n+    def __init__(\n+        self, *args, name=None, violation_error_code=None, violation_error_message=None\n+    ):\n@@\n         self.name = name\n+        if violation_error_code is not None:\n+            self.violation_error_code = violation_error_code\n         if violation_error_message is not None:\n             self.violation_error_message = violation_error_message\n         else:\n@@\n-            for arg, attr in zip(args, [\"name\", \"violation_error_message\"]):\n+            for arg, attr in zip(\n+                args, [\"name\", \"violation_error_message\", \"violation_error_code\"]\n+            ):\n                 if arg:\n                     setattr(self, attr, arg)\n@@\n         kwargs = {\"name\": self.name}\n+        if self.violation_error_code is not None:\n+            kwargs[\"violation_error_code\"] = self.violation_error_code\n         if (\n             self.violation_error_message is not None\n             and self.violation_error_message != self.default_violation_error_message\n@@\n class CheckConstraint(BaseConstraint):\n-    def __init__(self, *, check, name, violation_error_message=None):\n+    def __init__(\n+        self, *, check, name, violation_error_code=None, violation_error_message=None\n+    ):\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n             if not Q(self.check).check(against, using=using):\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(), code=self.violation_error_code\n+                )\n@@\n-        return \"<%s: check=%s name=%s%s>\" % (\n+        return \"<%s: check=%s name=%s%s%s>\" % (\n             self.__class__.__qualname__,\n             self.check,\n             repr(self.name),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n                 self.name == other.name\n                 and self.check == other.check\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n         include=None,\n         opclasses=(),\n+        violation_error_code=None,\n         violation_error_message=None,\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n-        return \"<%s:%s%s%s%s%s%s%s%s>\" % (\n+        return \"<%s:%s%s%s%s%s%s%s%s%s>\" % (\n             self.__class__.__qualname__,\n             \"\" if not self.fields else \" fields=%s\" % repr(self.fields),\n             \"\" if not self.expressions else \" expressions=%s\" % repr(self.expressions),\n@@\n             \"\" if not self.include else \" include=%s\" % repr(self.include),\n             \"\" if not self.opclasses else \" opclasses=%s\" % repr(self.opclasses),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n                 and self.opclasses == other.opclasses\n                 and self.expressions == other.expressions\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n                 if self.expressions:\n-                    raise ValidationError(self.get_violation_error_message())\n+                    raise ValidationError(\n+                        self.get_violation_error_message(),\n+                        code=self.violation_error_code,\n+                    )\n@@\n                 ):\n-                    raise ValidationError(self.get_violation_error_message())\n+                    raise ValidationError(\n+                        self.get_violation_error_message(),\n+                        code=self.violation_error_code,\n+                    )\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update django/db/models/constraints.py: the lines to change in /testbed/django/db/models/constraints.py appear more than once (lines 91 and 216): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n class BaseConstraint:\n     default_violation_error_message = _(\"Constraint “%(name)s” is violated.\")\n+    violation_error_code = None\n     violation_error_message = None\n \n     # RemovedInDjango60Warning: When the deprecation ends, replace with:\n-    # def __init__(self, *, name, violation_error_message=None):\n-    def __init__(self, *args, name=None, violation_error_message=None):\n+    # def __init__(self, *, name, violation_error_code=None, violation_error_message=None):\n+    def __init__(\n+        self, *args, name=None, violation_error_code=None, violation_error_message=None\n+    ):\n@@\n         self.name = name\n+        if violation_error_code is not None:\n+            self.violation_error_code = violation_error_code\n         if violation_error_message is not None:\n             self.violation_error_message = violation_error_message\n         else:\n@@\n-            for arg, attr in zip(args, [\"name\", \"violation_error_message\"]):\n+            for arg, attr in zip(\n+                args, [\"name\", \"violation_error_message\", \"violation_error_code\"]\n+            ):\n                 if arg:\n                     setattr(self, attr, arg)\n@@\n         kwargs = {\"name\": self.name}\n+        if self.violation_error_code is not None:\n+            kwargs[\"violation_error_code\"] = self.violation_error_code\n         if (\n             self.violation_error_message is not None\n             and self.violation_error_message != self.default_violation_error_message\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/constraints.py now (414 lines), around the change:
18:
19:class BaseConstraint:
20:    default_violation_error_message = _("Constraint “%(name)s” is violated.")
21:    violation_error_code = None
22:    violation_error_message = None
23:
24:    # RemovedInDjango60Warning: When the deprecation ends, replace with:
25:    # def __init__(self, *, name, violation_error_code=None, violation_error_message=None):
26:    def __init__(
27:        self, *args, name=None, violation_error_code=None, violation_error_message=None
28:    ):
29:        # RemovedInDjango60Warning.
30:        if name is None and not args:
31:            raise TypeError(
…
33:                f"argument: 'name'"
34:            )
35:        self.name = name
36:        if violation_error_code is not None:
37:            self.violation_error_code = violation_error_code
38:        if violation_error_message is not None:
39:            self.violation_error_message = violation_error_message
40:        else:
…
47:                RemovedInDjango60Warning,
48:                stacklevel=2,
49:            )
50:            for arg, attr in zip(
51:                args, ["name", "violation_error_message", "violation_error_code"]
52:            ):
53:                if arg:
54:                    setattr(self, attr, arg)
55:
…
76:        path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
77:        path = path.replace("django.db.models.constraints", "django.db.models")
78:        kwargs = {"name": self.name}
79:        if self.violation_error_code is not None:
80:            kwargs["violation_error_code"] = self.violation_error_code
81:        if (
82:            self.violation_error_message is not None
83:            and self.violation_error_message != self.default_violation_error_message
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n class CheckConstraint(BaseConstraint):\n-    def __init__(self, *, check, name, violation_error_message=None):\n+    def __init__(\n+        self, *, check, name, violation_error_code=None, violation_error_message=None\n+    ):\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n             if not Q(self.check).check(against, using=using):\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(), code=self.violation_error_code\n+                )\n@@\n-        return \"<%s: check=%s name=%s%s>\" % (\n+        return \"<%s: check=%s name=%s%s%s>\" % (\n             self.__class__.__qualname__,\n             self.check,\n             repr(self.name),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n                 self.name == other.name\n                 and self.check == other.check\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update django/db/models/constraints.py: the lines to change in /testbed/django/db/models/constraints.py appear more than once (lines 100 and 225): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n class CheckConstraint(BaseConstraint):\n-    def __init__(self, *, check, name, violation_error_message=None):\n+    def __init__(\n+        self, *, check, name, violation_error_code=None, violation_error_message=None\n+    ):\n         self.check = check\n         if not getattr(check, \"conditional\", False):\n             raise TypeError(\n                 \"CheckConstraint.check must be a Q instance or boolean expression.\"\n             )\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n     def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):\n         against = instance._get_field_value_map(meta=model._meta, exclude=exclude)\n         try:\n             if not Q(self.check).check(against, using=using):\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(), code=self.violation_error_code\n+                )\n         except FieldError:\n             pass\n \n     def __repr__(self):\n-        return \"<%s: check=%s name=%s%s>\" % (\n+        return \"<%s: check=%s name=%s%s%s>\" % (\n             self.__class__.__qualname__,\n             self.check,\n             repr(self.name),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n             return (\n                 self.name == other.name\n                 and self.check == other.check\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/constraints.py now (428 lines), around the change:
91:
92:
93:class CheckConstraint(BaseConstraint):
94:    def __init__(
95:        self, *, check, name, violation_error_code=None, violation_error_message=None
96:    ):
97:        self.check = check
98:        if not getattr(check, "conditional", False):
99:            raise TypeError(
100:                "CheckConstraint.check must be a Q instance or boolean expression."
101:            )
102:        super().__init__(
103:            name=name,
104:            violation_error_code=violation_error_code,
105:            violation_error_message=violation_error_message,
106:        )
107:
108:    def _get_check_sql(self, model, schema_editor):
109:        query = Query(model=model, alias_cols=False)
…
127:        against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
128:        try:
129:            if not Q(self.check).check(against, using=using):
130:                raise ValidationError(
131:                    self.get_violation_error_message(), code=self.violation_error_code
132:                )
133:        except FieldError:
134:            pass
135:
136:    def __repr__(self):
137:        return "<%s: check=%s name=%s%s%s>" % (
138:            self.__class__.__qualname__,
139:            self.check,
140:            repr(self.name),
141:            (
142:                ""
143:                if self.violation_error_code is None
144:                else " violation_error_code=%r" % self.violation_error_code
145:            ),
146:            (
147:                ""
148:                if self.violation_error_message is None
…
156:            return (
157:                self.name == other.name
158:                and self.check == other.check
159:                and self.violation_error_code == other.violation_error_code
160:                and self.violation_error_message == other.violation_error_message
161:            )
162:        return super().__eq__(other)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n         include=None,\n         opclasses=(),\n+        violation_error_code=None,\n         violation_error_message=None,\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n-        return \"<%s:%s%s%s%s%s%s%s%s>\" % (\n+        return \"<%s:%s%s%s%s%s%s%s%s%s>\" % (\n             self.__class__.__qualname__,\n             \"\" if not self.fields else \" fields=%s\" % repr(self.fields),\n             \"\" if not self.expressions else \" expressions=%s\" % repr(self.expressions),\n@@\n             \"\" if not self.include else \" include=%s\" % repr(self.include),\n             \"\" if not self.opclasses else \" opclasses=%s\" % repr(self.opclasses),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n                 and self.opclasses == other.opclasses\n                 and self.expressions == other.expressions\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n                 if self.expressions:\n-                    raise ValidationError(self.get_violation_error_message())\n+                    raise ValidationError(\n+                        self.get_violation_error_message(),\n+                        code=self.violation_error_code,\n+                    )\n@@\n                 ):\n-                    raise ValidationError(self.get_violation_error_message())\n+                    raise ValidationError(\n+                        self.get_violation_error_message(),\n+                        code=self.violation_error_code,\n+                    )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/constraints.py now (445 lines), around the change:
186:        deferrable=None,
187:        include=None,
188:        opclasses=(),
189:        violation_error_code=None,
190:        violation_error_message=None,
191:    ):
192:        if not name:
…
237:            F(expression) if isinstance(expression, str) else expression
238:            for expression in expressions
239:        )
240:        super().__init__(
241:            name=name,
242:            violation_error_code=violation_error_code,
243:            violation_error_message=violation_error_message,
244:        )
245:
246:    @property
247:    def contains_expressions(self):
…
321:        )
322:
323:    def __repr__(self):
324:        return "<%s:%s%s%s%s%s%s%s%s%s>" % (
325:            self.__class__.__qualname__,
326:            "" if not self.fields else " fields=%s" % repr(self.fields),
327:            "" if not self.expressions else " expressions=%s" % repr(self.expressions),
…
332:            "" if not self.opclasses else " opclasses=%s" % repr(self.opclasses),
333:            (
334:                ""
335:                if self.violation_error_code is None
336:                else " violation_error_code=%r" % self.violation_error_code
337:            ),
338:            (
339:                ""
340:                if self.violation_error_message is None
341:                or self.violation_error_message == self.default_violation_error_message
342:                else " violation_error_message=%r" % self.violation_error_message
…
353:                and self.include == other.include
354:                and self.opclasses == other.opclasses
355:                and self.expressions == other.expressions
356:                and self.violation_error_code == other.violation_error_code
357:                and self.violation_error_message == other.violation_error_message
358:            )
359:        return super().__eq__(other)
…
419:        if not self.condition:
420:            if queryset.exists():
421:                if self.expressions:
422:                    raise ValidationError(
423:                        self.get_violation_error_message(),
424:                        code=self.violation_error_code,
425:                    )
426:                # When fields are defined, use the unique_error_message() for
427:                # backward compatibility.
428:                for model, constraints in instance.get_constraints():
…
437:                if (self.condition & Exists(queryset.filter(self.condition))).check(
438:                    against, using=using
439:                ):
440:                    raise ValidationError(
441:                        self.get_violation_error_message(),
442:                        code=self.violation_error_code,
443:                    )
444:            except FieldError:
445:                pass
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/ref/models/constraints.txt\n@@\n-.. class:: BaseConstraint(*, name, violation_error_message=None)\n+.. class:: BaseConstraint(*, name, violation_error_code=None, violation_error_message=None)\n@@\n ``violation_error_message``\n ---------------------------\n \n .. attribute:: BaseConstraint.violation_error_message\n \n The error message used when ``ValidationError`` is raised during\n :ref:`model validation <validating-objects>`. Defaults to\n ``\"Constraint “%(name)s” is violated.\"``.\n \n+``violation_error_code``\n+------------------------\n+\n+.. attribute:: BaseConstraint.violation_error_code\n+\n+The error code used when ``ValidationError`` is raised during\n+:ref:`model validation <validating-objects>`. Defaults to ``None``.\n+\n@@\n-.. class:: CheckConstraint(*, check, name, violation_error_message=None)\n+.. class:: CheckConstraint(*, check, name, violation_error_code=None, violation_error_message=None)\n@@\n-.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)\n+.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_code=None, violation_error_message=None)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/ref/models/constraints.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/ref/models/constraints.txt now (267 lines), around the change:
48:``BaseConstraint``
49:==================
50:
51:.. class:: BaseConstraint(*, name, violation_error_code=None, violation_error_message=None)
52:
53:    Base class for all constraints. Subclasses must implement
54:    ``constraint_sql()``, ``create_sql()``, ``remove_sql()`` and
…
76:The error message used when ``ValidationError`` is raised during
77::ref:`model validation <validating-objects>`. Defaults to
78:``"Constraint “%(name)s” is violated."``.
79:
80:``violation_error_code``
81:------------------------
82:
83:.. attribute:: BaseConstraint.violation_error_code
84:
85:The error code used when ``ValidationError`` is raised during
86::ref:`model validation <validating-objects>`. Defaults to ``None``.
87:
88:``validate()``
89:--------------
…
102:``CheckConstraint``
103:===================
104:
105:.. class:: CheckConstraint(*, check, name, violation_error_code=None, violation_error_message=None)
106:
107:    Creates a check constraint in the database.
108:
…
129:``UniqueConstraint``
130:====================
131:
132:.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_code=None, violation_error_message=None)
133:
134:    Creates a unique constraint in the database.
135:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_custom_violation_error_message(self):\n         c = BaseConstraint(\n             name=\"base_name\", violation_error_message=\"custom %(name)s message\"\n         )\n         self.assertEqual(c.get_violation_error_message(), \"custom base_name message\")\n \n+    def test_custom_violation_error_code(self):\n+        c = BaseConstraint(name=\"base_name\", violation_error_code=\"custom_code\")\n+        self.assertEqual(c.violation_error_code, \"custom_code\")\n+\n+    def test_custom_violation_error_code_clone(self):\n+        constraint = BaseConstraint(\n+            name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n+        ).clone()\n+        self.assertEqual(constraint.violation_error_code, \"custom_code\")\n+\n@@\n     def test_deconstruction(self):\n         constraint = BaseConstraint(\n             name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n             violation_error_message=\"custom %(name)s message\",\n         )\n         path, args, kwargs = constraint.deconstruct()\n         self.assertEqual(path, \"django.db.models.BaseConstraint\")\n         self.assertEqual(args, ())\n         self.assertEqual(\n             kwargs,\n-            {\"name\": \"base_name\", \"violation_error_message\": \"custom %(name)s message\"},\n+            {\n+                \"name\": \"base_name\",\n+                \"violation_error_code\": \"custom_code\",\n+                \"violation_error_message\": \"custom %(name)s message\",\n+            },\n         )\n@@\n     def test_repr_with_violation_error_message(self):\n         constraint = models.CheckConstraint(\n             check=models.Q(price__lt=1),\n             name=\"price_lt_one\",\n             violation_error_message=\"More than 1\",\n@@\n             \"violation_error_message='More than 1'>\",\n         )\n \n+    def test_repr_with_violation_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__lt=1),\n+            name=\"price_lt_one\",\n+            violation_error_code=\"more_than_one\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            \"<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' \"\n+            \"violation_error_code='more_than_one'>\",\n+        )\n+\n@@\n     def test_validate_boolean_expressions(self):\n         constraint = models.CheckConstraint(\n             check=models.expressions.ExpressionWrapper(\n                 models.Q(price__gt=500) | models.Q(price__lt=500),\n                 output_field=models.BooleanField(),\n@@\n         constraint.validate(Product, Product(price=501, discounted_price=5))\n         constraint.validate(Product, Product(price=499, discounted_price=5))\n \n+    def test_validate_custom_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__gt=models.F(\"discounted_price\")),\n+            name=\"price_gt_discounted_price\",\n+            violation_error_code=\"invalid_price\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(Product, Product(price=10, discounted_price=42))\n+        self.assertEqual(cm.exception.code, \"invalid_price\")\n+\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/constraints/tests.py: the lines to change in /testbed/tests/constraints/tests.py appear more than once (lines 251 and 265): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_custom_violation_error_message(self):\n         c = BaseConstraint(\n             name=\"base_name\", violation_error_message=\"custom %(name)s message\"\n         )\n         self.assertEqual(c.get_violation_error_message(), \"custom base_name message\")\n \n+    def test_custom_violation_error_code(self):\n+        c = BaseConstraint(name=\"base_name\", violation_error_code=\"custom_code\")\n+        self.assertEqual(c.violation_error_code, \"custom_code\")\n+\n+    def test_custom_violation_error_code_clone(self):\n+        constraint = BaseConstraint(\n+            name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n+        ).clone()\n+        self.assertEqual(constraint.violation_error_code, \"custom_code\")\n+\n@@\n     def test_deconstruction(self):\n         constraint = BaseConstraint(\n             name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n             violation_error_message=\"custom %(name)s message\",\n         )\n         path, args, kwargs = constraint.deconstruct()\n         self.assertEqual(path, \"django.db.models.BaseConstraint\")\n         self.assertEqual(args, ())\n         self.assertEqual(\n             kwargs,\n-            {\"name\": \"base_name\", \"violation_error_message\": \"custom %(name)s message\"},\n+            {\n+                \"name\": \"base_name\",\n+                \"violation_error_code\": \"custom_code\",\n+                \"violation_error_message\": \"custom %(name)s message\",\n+            },\n         )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (981 lines), around the change:
67:        )
68:        self.assertEqual(c.get_violation_error_message(), "custom base_name message")
69:
70:    def test_custom_violation_error_code(self):
71:        c = BaseConstraint(name="base_name", violation_error_code="custom_code")
72:        self.assertEqual(c.violation_error_code, "custom_code")
73:
74:    def test_custom_violation_error_code_clone(self):
75:        constraint = BaseConstraint(
76:            name="base_name",
77:            violation_error_code="custom_code",
78:        ).clone()
79:        self.assertEqual(constraint.violation_error_code, "custom_code")
80:
81:    def test_custom_violation_error_message_clone(self):
82:        constraint = BaseConstraint(
83:            name="base_name",
…
91:    def test_deconstruction(self):
92:        constraint = BaseConstraint(
93:            name="base_name",
94:            violation_error_code="custom_code",
95:            violation_error_message="custom %(name)s message",
96:        )
97:        path, args, kwargs = constraint.deconstruct()
…
99:        self.assertEqual(args, ())
100:        self.assertEqual(
101:            kwargs,
102:            {
103:                "name": "base_name",
104:                "violation_error_code": "custom_code",
105:                "violation_error_message": "custom %(name)s message",
106:            },
107:        )
108:
109:    def test_deprecation(self):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_repr_with_violation_error_message(self):\n         constraint = models.CheckConstraint(\n             check=models.Q(price__lt=1),\n             name=\"price_lt_one\",\n             violation_error_message=\"More than 1\",\n@@\n             \"violation_error_message='More than 1'>\",\n         )\n \n+    def test_repr_with_violation_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__lt=1),\n+            name=\"price_lt_one\",\n+            violation_error_code=\"more_than_one\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            \"<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' \"\n+            \"violation_error_code='more_than_one'>\",\n+        )\n+\n     def test_invalid_check_types(self):\n@@\n     def test_validate_boolean_expressions(self):\n         constraint = models.CheckConstraint(\n             check=models.expressions.ExpressionWrapper(\n                 models.Q(price__gt=500) | models.Q(price__lt=500),\n                 output_field=models.BooleanField(),\n@@\n         constraint.validate(Product, Product(price=501, discounted_price=5))\n         constraint.validate(Product, Product(price=499, discounted_price=5))\n \n+    def test_validate_custom_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__gt=models.F(\"discounted_price\")),\n+            name=\"price_gt_discounted_price\",\n+            violation_error_code=\"invalid_price\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(Product, Product(price=10, discounted_price=42))\n+        self.assertEqual(cm.exception.code, \"invalid_price\")\n+\n     def test_validate_rawsql_expressions_noop(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (1003 lines), around the change:
186:            repr(constraint),
187:            "<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' "
188:            "violation_error_message='More than 1'>",
189:        )
190:
191:    def test_repr_with_violation_error_code(self):
192:        constraint = models.CheckConstraint(
193:            check=models.Q(price__lt=1),
194:            name="price_lt_one",
195:            violation_error_code="more_than_one",
196:        )
197:        self.assertEqual(
198:            repr(constraint),
199:            "<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' "
200:            "violation_error_code='more_than_one'>",
201:        )
202:
203:    def test_invalid_check_types(self):
…
278:            constraint.validate(Product, Product(price=500, discounted_price=5))
279:        constraint.validate(Product, Product(price=501, discounted_price=5))
280:        constraint.validate(Product, Product(price=499, discounted_price=5))
281:
282:    def test_validate_custom_error_code(self):
283:        constraint = models.CheckConstraint(
284:            check=models.Q(price__gt=models.F("discounted_price")),
285:            name="price_gt_discounted_price",
286:            violation_error_code="invalid_price",
287:        )
288:        with self.assertRaises(ValidationError) as cm:
289:            constraint.validate(Product, Product(price=10, discounted_price=42))
290:        self.assertEqual(cm.exception.code, "invalid_price")
291:
292:    def test_validate_rawsql_expressions_noop(self):
293:        constraint = models.CheckConstraint(
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '700,790p' tests/constraints/tests.py"
}
```

**tool result**

```
        )
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(UniqueConstraintProduct, non_unique_product)
        # Null values are ignored.
        constraint.validate(
            UniqueConstraintProduct,
            UniqueConstraintProduct(name=self.p2.name, color=None),
        )
        # Existing instances have their existing row excluded.
        constraint.validate(UniqueConstraintProduct, self.p1)
        # Unique fields are excluded.
        constraint.validate(
            UniqueConstraintProduct,
            non_unique_product,
            exclude={"name"},
        )
        constraint.validate(
            UniqueConstraintProduct,
            non_unique_product,
            exclude={"color"},
        )
        constraint.validate(
            UniqueConstraintProduct,
            non_unique_product,
            exclude={"name", "color"},
        )
        # Validation on a child instance.
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintProduct,
                ChildUniqueConstraintProduct(name=self.p1.name, color=self.p1.color),
            )

    @skipUnlessDBFeature("supports_partial_indexes")
    def test_validate_condition(self):
        p1 = UniqueConstraintConditionProduct.objects.create(name="p1")
        constraint = UniqueConstraintConditionProduct._meta.constraints[0]
        msg = "Constraint “name_without_color_uniq” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintConditionProduct,
                UniqueConstraintConditionProduct(name=p1.name, color=None),
            )
        # Values not matching condition are ignored.
        constraint.validate(
            UniqueConstraintConditionProduct,
            UniqueConstraintConditionProduct(name=p1.name, color="anything-but-none"),
        )
        # Existing instances have their existing row excluded.
        constraint.validate(UniqueConstraintConditionProduct, p1)
        # Unique field is excluded.
        constraint.validate(
            UniqueConstraintConditionProduct,
            UniqueConstraintConditionProduct(name=p1.name, color=None),
            exclude={"name"},
        )

    def test_validate_expression(self):
        constraint = models.UniqueConstraint(Lower("name"), name="name_lower_uniq")
        msg = "Constraint “name_lower_uniq” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintProduct,
                UniqueConstraintProduct(name=self.p1.name.upper()),
            )
        constraint.validate(
            UniqueConstraintProduct,
            UniqueConstraintProduct(name="another-name"),
        )
        # Existing instances have their existing row excluded.
        constraint.validate(UniqueConstraintProduct, self.p1)
        # Unique field is excluded.
        constraint.validate(
            UniqueConstraintProduct,
            UniqueConstraintProduct(name=self.p1.name.upper()),
            exclude={"name"},
        )

    def test_validate_ordered_expression(self):
        constraint = models.UniqueConstraint(
            Lower("name").desc(), name="name_lower_uniq_desc"
        )
        msg = "Constraint “name_lower_uniq_desc” is violated."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(
                UniqueConstraintProduct,
                UniqueConstraintProduct(name=self.p1.name.upper()),
            )
        constraint.validate(
            UniqueConstraintProduct,
            UniqueConstraintProduct(name="another-name"),
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_validate_expression(self):\n         constraint = models.UniqueConstraint(Lower(\"name\"), name=\"name_lower_uniq\")\n         msg = \"Constraint “name_lower_uniq” is violated.\"\n         with self.assertRaisesMessage(ValidationError, msg):\n             constraint.validate(\n@@\n             UniqueConstraintProduct(name=self.p1.name.upper()),\n             exclude={\"name\"},\n         )\n \n+    def test_validate_expression_custom_error_code(self):\n+        constraint = models.UniqueConstraint(\n+            Lower(\"name\"),\n+            name=\"name_lower_uniq\",\n+            violation_error_code=\"duplicate_name\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(\n+                UniqueConstraintProduct,\n+                UniqueConstraintProduct(name=self.p1.name.upper()),\n+            )\n+        self.assertEqual(cm.exception.code, \"duplicate_name\")\n+\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/constraints/tests.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file tests.py and REWRITE it with *** Add File: tests.py using its ACTUAL content plus your change
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_validate_ordered_expression(self):\n         constraint = models.UniqueConstraint(\n             Lower(\"name\").desc(), name=\"name_lower_uniq_desc\"\n         )\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/constraints/tests.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file tests.py and REWRITE it with *** Add File: tests.py using its ACTUAL content plus your change
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n-    def test_validate_ordered_expression(self):\n+    def test_validate_expression_custom_error_code(self):\n+        constraint = models.UniqueConstraint(\n+            Lower(\"name\"),\n+            name=\"name_lower_uniq\",\n+            violation_error_code=\"duplicate_name\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(\n+                UniqueConstraintProduct,\n+                UniqueConstraintProduct(name=self.p1.name.upper()),\n+            )\n+        self.assertEqual(cm.exception.code, \"duplicate_name\")\n+\n+    def test_validate_ordered_expression(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (1016 lines), around the change:
775:            exclude={"name"},
776:        )
777:
778:    def test_validate_expression_custom_error_code(self):
779:        constraint = models.UniqueConstraint(
780:            Lower("name"),
781:            name="name_lower_uniq",
782:            violation_error_code="duplicate_name",
783:        )
784:        with self.assertRaises(ValidationError) as cm:
785:            constraint.validate(
786:                UniqueConstraintProduct,
787:                UniqueConstraintProduct(name=self.p1.name.upper()),
788:            )
789:        self.assertEqual(cm.exception.code, "duplicate_name")
790:
791:    def test_validate_ordered_expression(self):
792:        constraint = models.UniqueConstraint(
793:            Lower("name").desc(), name="name_lower_uniq_desc"
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\\|super().__init__\" django/contrib/postgres/constraints.py | head -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\" django --include=*.py | grep -v \"db/models/constraints.py\" | head -30"
}
```

**tool result**

```
35:        violation_error_message=None,
63:        super().__init__(name=name, violation_error_message=violation_error_message)
152:                and self.violation_error_message == other.violation_error_message
167:                if self.violation_error_message is None
168:                or self.violation_error_message == self.default_violation_error_message
169:                else " violation_error_message=%r" % self.violation_error_message
207:                raise ValidationError(self.get_violation_error_message())
212:                raise ValidationError(self.get_violation_error_message())
```

**tool result**

```
django/contrib/postgres/constraints.py:35:        violation_error_message=None,
django/contrib/postgres/constraints.py:63:        super().__init__(name=name, violation_error_message=violation_error_message)
django/contrib/postgres/constraints.py:152:                and self.violation_error_message == other.violation_error_message
django/contrib/postgres/constraints.py:167:                if self.violation_error_message is None
django/contrib/postgres/constraints.py:168:                or self.violation_error_message == self.default_violation_error_message
django/contrib/postgres/constraints.py:169:                else " violation_error_message=%r" % self.violation_error_message
django/contrib/postgres/constraints.py:207:                raise ValidationError(self.get_violation_error_message())
django/contrib/postgres/constraints.py:212:                raise ValidationError(self.get_violation_error_message())
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/postgres/constraints.py",
  "offset": 20,
  "limit": 200
}
```

**tool result**

```
class ExclusionConstraint(BaseConstraint):
    template = (
        "CONSTRAINT %(name)s EXCLUDE USING %(index_type)s "
        "(%(expressions)s)%(include)s%(where)s%(deferrable)s"
    )

    def __init__(
        self,
        *,
        name,
        expressions,
        index_type=None,
        condition=None,
        deferrable=None,
        include=None,
        violation_error_message=None,
    ):
        if index_type and index_type.lower() not in {"gist", "spgist"}:
            raise ValueError(
                "Exclusion constraints only support GiST or SP-GiST indexes."
            )
        if not expressions:
            raise ValueError(
                "At least one expression is required to define an exclusion "
                "constraint."
            )
        if not all(
            isinstance(expr, (list, tuple)) and len(expr) == 2 for expr in expressions
        ):
            raise ValueError("The expressions must be a list of 2-tuples.")
        if not isinstance(condition, (NoneType, Q)):
            raise ValueError("ExclusionConstraint.condition must be a Q instance.")
        if not isinstance(deferrable, (NoneType, Deferrable)):
            raise ValueError(
                "ExclusionConstraint.deferrable must be a Deferrable instance."
            )
        if not isinstance(include, (NoneType, list, tuple)):
            raise ValueError("ExclusionConstraint.include must be a list or tuple.")
        self.expressions = expressions
        self.index_type = index_type or "GIST"
        self.condition = condition
        self.deferrable = deferrable
        self.include = tuple(include) if include else ()
        super().__init__(name=name, violation_error_message=violation_error_message)

    def _get_expressions(self, schema_editor, query):
        expressions = []
        for idx, (expression, operator) in enumerate(self.expressions):
            if isinstance(expression, str):
                expression = F(expression)
            expression = ExclusionConstraintExpression(expression, operator=operator)
            expression.set_wrapper_classes(schema_editor.connection)
            expressions.append(expression)
        return ExpressionList(*expressions).resolve_expression(query)

    def _get_condition_sql(self, compiler, schema_editor, query):
        if self.condition is None:
            return None
        where = query.build_where(self.condition)
        sql, params = where.as_sql(compiler, schema_editor.connection)
        return sql % tuple(schema_editor.quote_value(p) for p in params)

    def constraint_sql(self, model, schema_editor):
        query = Query(model, alias_cols=False)
        compiler = query.get_compiler(connection=schema_editor.connection)
        expressions = self._get_expressions(schema_editor, query)
        table = model._meta.db_table
        condition = self._get_condition_sql(compiler, schema_editor, query)
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        return Statement(
            self.template,
            table=Table(table, schema_editor.quote_name),
            name=schema_editor.quote_name(self.name),
            index_type=self.index_type,
            expressions=Expressions(
                table, expressions, compiler, schema_editor.quote_value
            ),
            where=" WHERE (%s)" % condition if condition else "",
            include=schema_editor._index_include_sql(model, include),
            deferrable=schema_editor._deferrable_constraint_sql(self.deferrable),
        )

    def create_sql(self, model, schema_editor):
        self.check_supported(schema_editor)
        return Statement(
            "ALTER TABLE %(table)s ADD %(constraint)s",
            table=Table(model._meta.db_table, schema_editor.quote_name),
            constraint=self.constraint_sql(model, schema_editor),
        )

    def remove_sql(self, model, schema_editor):
        return schema_editor._delete_constraint_sql(
            schema_editor.sql_delete_check,
            model,
            schema_editor.quote_name(self.name),
        )

    def check_supported(self, schema_editor):
        if (
            self.include
            and self.index_type.lower() == "spgist"
            and not schema_editor.connection.features.supports_covering_spgist_indexes
        ):
            raise NotSupportedError(
                "Covering exclusion constraints using an SP-GiST index "
                "require PostgreSQL 14+."
            )

    def deconstruct(self):
        path, args, kwargs = super().deconstruct()
        kwargs["expressions"] = self.expressions
        if self.condition is not None:
            kwargs["condition"] = self.condition
        if self.index_type.lower() != "gist":
            kwargs["index_type"] = self.index_type
        if self.deferrable:
            kwargs["deferrable"] = self.deferrable
        if self.include:
            kwargs["include"] = self.include
        return path, args, kwargs

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return (
                self.name == other.name
                and self.index_type == other.index_type
                and self.expressions == other.expressions
                and self.condition == other.condition
                and self.deferrable == other.deferrable
                and self.include == other.include
                and self.violation_error_message == other.violation_error_message
            )
        return super().__eq__(other)

    def __repr__(self):
        return "<%s: index_type=%s expressions=%s name=%s%s%s%s%s>" % (
            self.__class__.__qualname__,
            repr(self.index_type),
            repr(self.expressions),
            repr(self.name),
            "" if self.condition is None else " condition=%s" % self.condition,
            "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
            "" if not self.include else " include=%s" % repr(self.include),
            (
                ""
                if self.violation_error_message is None
                or self.violation_error_message == self.default_violation_error_message
                else " violation_error_message=%r" % self.violation_error_message
            ),
        )

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        queryset = model._default_manager.using(using)
        replacement_map = instance._get_field_value_map(
            meta=model._meta, exclude=exclude
        )
        replacements = {F(field): value for field, value in replacement_map.items()}
        lookups = []
        for idx, (expression, operator) in enumerate(self.expressions):
            if isinstance(expression, str):
                expression = F(expression)
            if exclude:
                if isinstance(expression, F):
                    if expression.name in exclude:
                        return
                else:
                    for expr in expression.flatten():
                        if isinstance(expr, F) and expr.name in exclude:
                            return
            rhs_expression = expression.replace_expressions(replacements)
            # Remove OpClass because it only has sense during the constraint
            # creation.
            if isinstance(expression, OpClass):
                expression = expression.get_source_expressions()[0]
            if isinstance(rhs_expression, OpClass):
                rhs_expression = rhs_expression.get_source_expressions()[0]
            lookup = PostgresOperatorLookup(lhs=expression, rhs=rhs_expression)
            lookup.postgres_operator = operator
            lookups.append(lookup)
        queryset = queryset.filter(*lookups)
        model_class_pk = instance._get_pk_val(model._meta)
        if not instance._state.adding and model_class_pk is not None:
            queryset = queryset.exclude(pk=model_class_pk)
        if not self.condition:
            if queryset.exists():
                raise ValidationError(self.get_violation_error_message())
        else:
            if (self.condition & Exists(queryset.filter(self.condition))).check(
                replacement_map, using=using
            ):
                raise ValidationError(self.get_violation_error_message())

[lines 20-212 of /testbed/django/contrib/postgres/constraints.py, the end]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/postgres/constraints.py\n@@\n         deferrable=None,\n         include=None,\n+        violation_error_code=None,\n         violation_error_message=None,\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n                 and self.deferrable == other.deferrable\n                 and self.include == other.include\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n-        return \"<%s: index_type=%s expressions=%s name=%s%s%s%s%s>\" % (\n+        return \"<%s: index_type=%s expressions=%s name=%s%s%s%s%s%s>\" % (\n             self.__class__.__qualname__,\n             repr(self.index_type),\n             repr(self.expressions),\n             repr(self.name),\n             \"\" if self.condition is None else \" condition=%s\" % self.condition,\n             \"\" if self.deferrable is None else \" deferrable=%r\" % self.deferrable,\n             \"\" if not self.include else \" include=%s\" % repr(self.include),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n         if not self.condition:\n             if queryset.exists():\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(), code=self.violation_error_code\n+                )\n         else:\n             if (self.condition & Exists(queryset.filter(self.condition))).check(\n                 replacement_map, using=using\n             ):\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(), code=self.violation_error_code\n+                )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/postgres/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/postgres/constraints.py now (227 lines), around the change:
32:        condition=None,
33:        deferrable=None,
34:        include=None,
35:        violation_error_code=None,
36:        violation_error_message=None,
37:    ):
38:        if index_type and index_type.lower() not in {"gist", "spgist"}:
…
61:        self.condition = condition
62:        self.deferrable = deferrable
63:        self.include = tuple(include) if include else ()
64:        super().__init__(
65:            name=name,
66:            violation_error_code=violation_error_code,
67:            violation_error_message=violation_error_message,
68:        )
69:
70:    def _get_expressions(self, schema_editor, query):
71:        expressions = []
…
154:                and self.condition == other.condition
155:                and self.deferrable == other.deferrable
156:                and self.include == other.include
157:                and self.violation_error_code == other.violation_error_code
158:                and self.violation_error_message == other.violation_error_message
159:            )
160:        return super().__eq__(other)
161:
162:    def __repr__(self):
163:        return "<%s: index_type=%s expressions=%s name=%s%s%s%s%s%s>" % (
164:            self.__class__.__qualname__,
165:            repr(self.index_type),
166:            repr(self.expressions),
…
168:            "" if self.condition is None else " condition=%s" % self.condition,
169:            "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
170:            "" if not self.include else " include=%s" % repr(self.include),
171:            (
172:                ""
173:                if self.violation_error_code is None
174:                else " violation_error_code=%r" % self.violation_error_code
175:            ),
176:            (
177:                ""
178:                if self.violation_error_message is None
…
215:            queryset = queryset.exclude(pk=model_class_pk)
216:        if not self.condition:
217:            if queryset.exists():
218:                raise ValidationError(
219:                    self.get_violation_error_message(), code=self.violation_error_code
220:                )
221:        else:
222:            if (self.condition & Exists(queryset.filter(self.condition))).check(
223:                replacement_map, using=using
224:            ):
225:                raise ValidationError(
226:                    self.get_violation_error_message(), code=self.violation_error_code
227:                )
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/constraints/tests.py -q 2>&1 | tail -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"violation_error_message\\|ExclusionConstraint(\" docs/ref/contrib/postgres/constraints.txt | head"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**tool result**

```
15:.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)
105:    ExclusionConstraint(
136:``violation_error_message``
141::attr:`.BaseConstraint.violation_error_message`.
165:                ExclusionConstraint(
207:                ExclusionConstraint(
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py constraints --parallel 1 2>&1 | tail -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' docs/ref/contrib/postgres/constraints.txt; sed -n '130,150p' docs/ref/contrib/postgres/constraints.txt"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django'
Found 78 test(s).
System check identified no issues (0 silenced).
.............s.......................sss......................................
----------------------------------------------------------------------
Ran 78 tests in 0.066s

OK (skipped=4)
Destroying test database for alias 'default'...
```

**tool result**

```
========================================
PostgreSQL specific database constraints
========================================

.. module:: django.contrib.postgres.constraints
   :synopsis: PostgreSQL specific database constraint

PostgreSQL supports additional data integrity constraints available from the
``django.contrib.postgres.constraints`` module. They are added in the model
:attr:`Meta.constraints <django.db.models.Options.constraints>` option.

``ExclusionConstraint``
=======================

.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)

    Creates an exclusion constraint in the database. Internally, PostgreSQL
    implements exclusion constraints using indexes. The default index type is
    `GiST <https://www.postgresql.org/docs/current/gist.html>`_. To use them,
    you need to activate the `btree_gist extension
    <https://www.postgresql.org/docs/current/btree-gist.html>`_ on PostgreSQL.
    You can install it using the
    :class:`~django.contrib.postgres.operations.BtreeGistExtension` migration
    operation.

    If you attempt to insert a new row that conflicts with an existing row, an
    :exc:`~django.db.IntegrityError` is raised. Similarly, when update
    conflicts with an existing row.

    Exclusion constraints are checked during the :ref:`model validation
(:attr:`~ExclusionConstraint.include`) and filter only by indexed fields
(:attr:`~ExclusionConstraint.expressions`).

``include`` is supported for GiST indexes. PostgreSQL 14+ also supports
``include`` for SP-GiST indexes.

``violation_error_message``
---------------------------

The error message used when ``ValidationError`` is raised during
:ref:`model validation <validating-objects>`. Defaults to
:attr:`.BaseConstraint.violation_error_message`.

Examples
--------

The following example restricts overlapping reservations in the same room, not
taking canceled reservations into account::

    from django.contrib.postgres.constraints import ExclusionConstraint
    from django.contrib.postgres.fields import DateTimeRangeField, RangeOperators
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/ref/contrib/postgres/constraints.txt\n@@\n-.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)\n+.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_code=None, violation_error_message=None)\n@@\n ``violation_error_message``\n ---------------------------\n \n The error message used when ``ValidationError`` is raised during\n :ref:`model validation <validating-objects>`. Defaults to\n :attr:`.BaseConstraint.violation_error_message`.\n \n+``violation_error_code``\n+------------------------\n+\n+The error code used when ``ValidationError`` is raised during\n+:ref:`model validation <validating-objects>`. Defaults to\n+:attr:`.BaseConstraint.violation_error_code`.\n+\n Examples\n --------\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/ref/contrib/postgres/constraints.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/ref/contrib/postgres/constraints.txt now (222 lines), around the change:
12:``ExclusionConstraint``
13:=======================
14:
15:.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_code=None, violation_error_message=None)
16:
17:    Creates an exclusion constraint in the database. Internally, PostgreSQL
18:    implements exclusion constraints using indexes. The default index type is
…
139:The error message used when ``ValidationError`` is raised during
140::ref:`model validation <validating-objects>`. Defaults to
141::attr:`.BaseConstraint.violation_error_message`.
142:
143:``violation_error_code``
144:------------------------
145:
146:The error code used when ``ValidationError`` is raised during
147::ref:`model validation <validating-objects>`. Defaults to
148::attr:`.BaseConstraint.violation_error_code`.
149:
150:Examples
151:--------
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/releases/5.0.txt\n@@\n Models\n ~~~~~~\n \n+* The new ``violation_error_code`` argument of\n+  :class:`~django.db.models.BaseConstraint`,\n+  :class:`~django.db.models.CheckConstraint`, and\n+  :class:`~django.db.models.UniqueConstraint` allows customizing the error code\n+  of the ``ValidationError`` raised during model validation.\n+\n * The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`\n   and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different\n   field values for the create operation.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/releases/5.0.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/releases/5.0.txt now (384 lines), around the change:
177:
178:Models
179:~~~~~~
180:
181:* The new ``violation_error_code`` argument of
182:  :class:`~django.db.models.BaseConstraint`,
183:  :class:`~django.db.models.CheckConstraint`, and
184:  :class:`~django.db.models.UniqueConstraint` allows customizing the error code
185:  of the ``ValidationError`` raised during model validation.
186:
187:* The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`
188:  and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def validate_constraints\" -A 40 django/db/models/base.py"
}
```

**tool result**

```
1437:    def validate_constraints(self, exclude=None):
1438-        constraints = self.get_constraints()
1439-        using = router.db_for_write(self.__class__, instance=self)
1440-
1441-        errors = {}
1442-        for model_class, model_constraints in constraints:
1443-            for constraint in model_constraints:
1444-                try:
1445-                    constraint.validate(model_class, self, exclude=exclude, using=using)
1446-                except ValidationError as e:
1447-                    if (
1448-                        getattr(e, "code", None) == "unique"
1449-                        and len(constraint.fields) == 1
1450-                    ):
1451-                        errors.setdefault(constraint.fields[0], []).append(e)
1452-                    else:
1453-                        errors = e.update_error_dict(errors)
1454-        if errors:
1455-            raise ValidationError(errors)
1456-
1457-    def full_clean(self, exclude=None, validate_unique=True, validate_constraints=True):
1458-        """
1459-        Call clean_fields(), clean(), validate_unique(), and
1460-        validate_constraints() on the model. Raise a ValidationError for any
1461-        errors that occur.
1462-        """
1463-        errors = {}
1464-        if exclude is None:
1465-            exclude = set()
1466-        else:
1467-            exclude = set(exclude)
1468-
1469-        try:
1470-            self.clean_fields(exclude=exclude)
1471-        except ValidationError as e:
1472-            errors = e.update_error_dict(errors)
1473-
1474-        # Form.clean() is run even if other validation fails, so do the
1475-        # same with Model.clean() for consistency.
1476-        try:
1477-            self.clean()
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py constraints postgres_tests.test_constraints model_validation --parallel 1 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django'
Found 128 test(s).
System check identified no issues (0 silenced).
E.............s.......................sss........................sssssssssssssssssssssssssssssssssssssssssssssssss..............
======================================================================
ERROR: model_validation (unittest.loader._FailedTest.model_validation)
----------------------------------------------------------------------
ImportError: Failed to import test module: model_validation
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.11/unittest/loader.py", line 162, in loadTestsFromName
    module = __import__(module_name)
             ^^^^^^^^^^^^^^^^^^^^^^^
ModuleNotFoundError: No module named 'model_validation'


----------------------------------------------------------------------
Ran 128 tests in 0.068s

FAILED (errors=1, skipped=53)
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py model_validation --parallel 1 2>&1 | tail -8"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py constraints postgres_tests.test_constraints --parallel 1 2>&1 | tail -8"
}
```

**tool result**

```
             ^^^^^^^^^^^^^^^^^^^^^^^
ModuleNotFoundError: No module named 'model_validation'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
```

**tool result**

```
Found 127 test(s).
System check identified no issues (0 silenced).
.............s.......................sss........................sssssssssssssssssssssssssssssssssssssssssssssssss..............
----------------------------------------------------------------------
Ran 127 tests in 0.093s

OK (skipped=53)
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\" tests --include=*.py | grep -v \"tests/constraints/tests.py\" | head -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py validation --parallel 1 2>&1 | tail -8"
}
```

**tool result**

```
tests/postgres_tests/test_constraints.py:392:            violation_error_message="Overlapping must be excluded",
tests/postgres_tests/test_constraints.py:398:            "violation_error_message='Overlapping must be excluded'>",
tests/postgres_tests/test_constraints.py:462:            violation_error_message="custom error",
tests/postgres_tests/test_constraints.py:471:            violation_error_message="other custom error",
tests/postgres_tests/test_constraints.py:763:            violation_error_message="Custom error message.",
```

**tool result**

```
Found 61 test(s).
System check identified no issues (0 silenced).
.............................................................
----------------------------------------------------------------------
Ran 61 tests in 0.083s

OK
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '375,480p' tests/postgres_tests/test_constraints.py; sed -n '740,780p' tests/postgres_tests/test_constraints.py"
}
```

**tool result**

```
            "include=('cancelled', 'room')>",
        )
        constraint = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                (OpClass("datespan", name="range_ops"), RangeOperators.ADJACENT_TO),
            ],
        )
        self.assertEqual(
            repr(constraint),
            "<ExclusionConstraint: index_type='GIST' expressions=["
            "(OpClass(F(datespan), name=range_ops), '-|-')] "
            "name='exclude_overlapping'>",
        )
        constraint = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[(F("datespan"), RangeOperators.ADJACENT_TO)],
            violation_error_message="Overlapping must be excluded",
        )
        self.assertEqual(
            repr(constraint),
            "<ExclusionConstraint: index_type='GIST' expressions=["
            "(F(datespan), '-|-')] name='exclude_overlapping' "
            "violation_error_message='Overlapping must be excluded'>",
        )

    def test_eq(self):
        constraint_1 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                (F("datespan"), RangeOperators.OVERLAPS),
                (F("room"), RangeOperators.EQUAL),
            ],
            condition=Q(cancelled=False),
        )
        constraint_2 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
        )
        constraint_3 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[("datespan", RangeOperators.OVERLAPS)],
            condition=Q(cancelled=False),
        )
        constraint_4 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
            deferrable=Deferrable.DEFERRED,
        )
        constraint_5 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
            deferrable=Deferrable.IMMEDIATE,
        )
        constraint_6 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
            deferrable=Deferrable.IMMEDIATE,
            include=["cancelled"],
        )
        constraint_7 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
            include=["cancelled"],
        )
        constraint_10 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                (F("datespan"), RangeOperators.OVERLAPS),
                (F("room"), RangeOperators.EQUAL),
            ],
            condition=Q(cancelled=False),
            violation_error_message="custom error",
        )
        constraint_11 = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                (F("datespan"), RangeOperators.OVERLAPS),
                (F("room"), RangeOperators.EQUAL),
            ],
            condition=Q(cancelled=False),
            violation_error_message="other custom error",
        )
        self.assertEqual(constraint_1, constraint_1)
        self.assertEqual(constraint_1, mock.ANY)
        self.assertNotEqual(constraint_1, constraint_2)
        self.assertNotEqual(constraint_1, constraint_3)
        self.assertNotEqual(constraint_1, constraint_4)
        self.assertNotEqual(constraint_1, constraint_10)
        self.assertNotEqual(constraint_2, constraint_3)
        self.assertNotEqual(constraint_2, constraint_4)
        constraint = ExclusionConstraint(
            name=constraint_name,
            expressions=[("ints", RangeOperators.ADJACENT_TO)],
        )
        with connection.schema_editor() as editor:
            editor.add_constraint(RangesModel, constraint)
        self.assertIn(constraint_name, self.get_constraints(RangesModel._meta.db_table))
        RangesModel.objects.create(ints=(20, 50))
        with self.assertRaises(IntegrityError), transaction.atomic():
            RangesModel.objects.create(ints=(10, 20))
        RangesModel.objects.create(ints=(10, 19))
        RangesModel.objects.create(ints=(51, 60))
        # Drop the constraint.
        with connection.schema_editor() as editor:
            editor.remove_constraint(RangesModel, constraint)
        self.assertNotIn(
            constraint_name, self.get_constraints(RangesModel._meta.db_table)
        )

    def test_validate_range_adjacent(self):
        constraint = ExclusionConstraint(
            name="ints_adjacent",
            expressions=[("ints", RangeOperators.ADJACENT_TO)],
            violation_error_message="Custom error message.",
        )
        range_obj = RangesModel.objects.create(ints=(20, 50))
        constraint.validate(RangesModel, range_obj)
        msg = "Custom error message."
        with self.assertRaisesMessage(ValidationError, msg):
            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))
        constraint.validate(RangesModel, RangesModel(ints=(10, 19)))
        constraint.validate(RangesModel, RangesModel(ints=(51, 60)))
        constraint.validate(RangesModel, RangesModel(ints=(10, 20)), exclude={"ints"})

    def test_expressions_with_params(self):
        constraint_name = "scene_left_equal"
        self.assertNotIn(constraint_name, self.get_constraints(Scene._meta.db_table))
        constraint = ExclusionConstraint(
            name=constraint_name,
            expressions=[(Left("scene", 4), RangeOperators.EQUAL)],
        )
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/postgres_tests/test_constraints.py\n@@\n         self.assertEqual(\n             repr(constraint),\n             \"<ExclusionConstraint: index_type='GIST' expressions=[\"\n             \"(F(datespan), '-|-')] name='exclude_overlapping' \"\n             \"violation_error_message='Overlapping must be excluded'>\",\n         )\n+        constraint = ExclusionConstraint(\n+            name=\"exclude_overlapping\",\n+            expressions=[(F(\"datespan\"), RangeOperators.ADJACENT_TO)],\n+            violation_error_code=\"overlapping\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            \"<ExclusionConstraint: index_type='GIST' expressions=[\"\n+            \"(F(datespan), '-|-')] name='exclude_overlapping' \"\n+            \"violation_error_code='overlapping'>\",\n+        )\n@@\n     def test_validate_range_adjacent(self):\n         constraint = ExclusionConstraint(\n             name=\"ints_adjacent\",\n             expressions=[(\"ints\", RangeOperators.ADJACENT_TO)],\n             violation_error_message=\"Custom error message.\",\n@@\n         constraint.validate(RangesModel, RangesModel(ints=(51, 60)))\n         constraint.validate(RangesModel, RangesModel(ints=(10, 20)), exclude={\"ints\"})\n \n+    def test_validate_custom_error_code(self):\n+        constraint = ExclusionConstraint(\n+            name=\"ints_adjacent\",\n+            expressions=[(\"ints\", RangeOperators.ADJACENT_TO)],\n+            violation_error_code=\"adjacent_ints\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))\n+        self.assertEqual(cm.exception.code, \"adjacent_ints\")\n+\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/postgres_tests/test_constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/postgres_tests/test_constraints.py now (1153 lines), around the change:
396:            "<ExclusionConstraint: index_type='GIST' expressions=["
397:            "(F(datespan), '-|-')] name='exclude_overlapping' "
398:            "violation_error_message='Overlapping must be excluded'>",
399:        )
400:        constraint = ExclusionConstraint(
401:            name="exclude_overlapping",
402:            expressions=[(F("datespan"), RangeOperators.ADJACENT_TO)],
403:            violation_error_code="overlapping",
404:        )
405:        self.assertEqual(
406:            repr(constraint),
407:            "<ExclusionConstraint: index_type='GIST' expressions=["
408:            "(F(datespan), '-|-')] name='exclude_overlapping' "
409:            "violation_error_code='overlapping'>",
410:        )
411:
412:    def test_eq(self):
…
782:        constraint.validate(RangesModel, RangesModel(ints=(51, 60)))
783:        constraint.validate(RangesModel, RangesModel(ints=(10, 20)), exclude={"ints"})
784:
785:    def test_validate_custom_error_code(self):
786:        constraint = ExclusionConstraint(
787:            name="ints_adjacent",
788:            expressions=[("ints", RangeOperators.ADJACENT_TO)],
789:            violation_error_code="adjacent_ints",
790:        )
791:        with self.assertRaises(ValidationError) as cm:
792:            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))
793:        self.assertEqual(cm.exception.code, "adjacent_ints")
794:
795:    def test_expressions_with_params(self):
796:        constraint_name = "scene_left_equal"
797:        self.assertNotIn(constraint_name, self.get_constraints(Scene._meta.db_table))
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n-            for arg, attr in zip(\n-                args, [\"name\", \"violation_error_message\", \"violation_error_code\"]\n-            ):\n+            for arg, attr in zip(args, [\"name\", \"violation_error_message\"]):\n                 if arg:\n                     setattr(self, attr, arg)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/constraints.py now (443 lines), around the change:
47:                RemovedInDjango60Warning,
48:                stacklevel=2,
49:            )
50:            for arg, attr in zip(args, ["name", "violation_error_message"]):
51:                if arg:
52:                    setattr(self, attr, arg)
53:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"__eq__\\|__hash__\" django/db/models/constraints.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py constraints postgres_tests.test_constraints --parallel 1 2>&1 | tail -8"
}
```

**tool result**

```
152:    def __eq__(self, other):
160:        return super().__eq__(other)
344:    def __eq__(self, other):
357:        return super().__eq__(other)
```

**tool result**

```
Found 128 test(s).
System check identified no issues (0 silenced).
.............s.......................sss........................ssssssssssssssssssssssssssssssssssssssssssssssssss..............
----------------------------------------------------------------------
Ran 128 tests in 0.101s

OK (skipped=54)
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rln \"validate_constraints\" tests | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py migrations --parallel 1 2>&1 | tail -6"
}
```

**tool result**

```
tests/validation/test_constraints.py
tests/validation/__pycache__/test_constraints.cpython-311.pyc
tests/constraints/tests.py
tests/constraints/__pycache__/tests.cpython-311.pyc
```

**tool result**

```
----------------------------------------------------------------------
Ran 712 tests in 19.141s

OK (skipped=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'other'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py validation.test_constraints --parallel 1 2>&1 | tail -6"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"violation_error\\|def test\" tests/validation/test_constraints.py | head -40"
}
```

**tool result**

```
.......
----------------------------------------------------------------------
Ran 7 tests in 0.013s

OK
Destroying test database for alias 'default'...


(this is the fourth time you have made nearly this same bash call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**tool result**

```
15:    def test_full_clean_with_check_constraints(self):
29:    def test_full_clean_with_check_constraints_on_child_model(self):
43:    def test_full_clean_with_check_constraints_disabled(self):
47:    def test_full_clean_with_unique_constraints(self):
71:    def test_full_clean_with_unique_constraints_disabled(self):
77:    def test_full_clean_with_partial_unique_constraints(self):
92:    def test_full_clean_with_partial_unique_constraints_disabled(self):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m black --check django/db/models/constraints.py django/contrib/postgres/constraints.py tests/constraints/tests.py tests/postgres_tests/test_constraints.py 2>&1 | tail -5; python -m flake8 django/db/models/constraints.py django/contrib/postgres/constraints.py tests/constraints/tests.py tests/postgres_tests/test_constraints.py 2>&1 | tail -10"
}
```

**tool result**

```
All done! ✨ 🍰 ✨
4 files would be left unchanged.
/opt/miniconda3/envs/testbed/bin/python: No module named flake8
```

**assistant → tool `bash`**

```json
{
  "command": "git diff --stat && git diff django/db/models/constraints.py | head -120"
}
```

**tool result**

```
 django/contrib/postgres/constraints.py    | 23 +++++++++---
 django/db/models/constraints.py           | 58 +++++++++++++++++++++++++------
 docs/ref/contrib/postgres/constraints.txt |  9 ++++-
 docs/ref/models/constraints.txt           | 14 ++++++--
 docs/releases/5.0.txt                     |  6 ++++
 tests/constraints/tests.py                | 53 +++++++++++++++++++++++++++-
 tests/postgres_tests/test_constraints.py  | 21 +++++++++++
 7 files changed, 165 insertions(+), 19 deletions(-)
diff --git a/django/db/models/constraints.py b/django/db/models/constraints.py
index 075ecee1be..57c9ad65a7 100644
--- a/django/db/models/constraints.py
+++ b/django/db/models/constraints.py
@@ -18,11 +18,14 @@ __all__ = ["BaseConstraint", "CheckConstraint", "Deferrable", "UniqueConstraint"
 
 class BaseConstraint:
     default_violation_error_message = _("Constraint “%(name)s” is violated.")
+    violation_error_code = None
     violation_error_message = None
 
     # RemovedInDjango60Warning: When the deprecation ends, replace with:
-    # def __init__(self, *, name, violation_error_message=None):
-    def __init__(self, *args, name=None, violation_error_message=None):
+    # def __init__(self, *, name, violation_error_code=None, violation_error_message=None):
+    def __init__(
+        self, *args, name=None, violation_error_code=None, violation_error_message=None
+    ):
         # RemovedInDjango60Warning.
         if name is None and not args:
             raise TypeError(
@@ -30,6 +33,8 @@ class BaseConstraint:
                 f"argument: 'name'"
             )
         self.name = name
+        if violation_error_code is not None:
+            self.violation_error_code = violation_error_code
         if violation_error_message is not None:
             self.violation_error_message = violation_error_message
         else:
@@ -69,6 +74,8 @@ class BaseConstraint:
         path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
         path = path.replace("django.db.models.constraints", "django.db.models")
         kwargs = {"name": self.name}
+        if self.violation_error_code is not None:
+            kwargs["violation_error_code"] = self.violation_error_code
         if (
             self.violation_error_message is not None
             and self.violation_error_message != self.default_violation_error_message
@@ -82,13 +89,19 @@ class BaseConstraint:
 
 
 class CheckConstraint(BaseConstraint):
-    def __init__(self, *, check, name, violation_error_message=None):
+    def __init__(
+        self, *, check, name, violation_error_code=None, violation_error_message=None
+    ):
         self.check = check
         if not getattr(check, "conditional", False):
             raise TypeError(
                 "CheckConstraint.check must be a Q instance or boolean expression."
             )
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     def _get_check_sql(self, model, schema_editor):
         query = Query(model=model, alias_cols=False)
@@ -112,15 +125,22 @@ class CheckConstraint(BaseConstraint):
         against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
         try:
             if not Q(self.check).check(against, using=using):
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
         except FieldError:
             pass
 
     def __repr__(self):
-        return "<%s: check=%s name=%s%s>" % (
+        return "<%s: check=%s name=%s%s%s>" % (
             self.__class__.__qualname__,
             self.check,
             repr(self.name),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -134,6 +154,7 @@ class CheckConstraint(BaseConstraint):
             return (
                 self.name == other.name
                 and self.check == other.check
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
@@ -163,6 +184,7 @@ class UniqueConstraint(BaseConstraint):
         deferrable=None,
         include=None,
         opclasses=(),
+        violation_error_code=None,
         violation_error_message=None,
     ):
         if not name:
@@ -213,7 +235,11 @@ class UniqueConstraint(BaseConstraint):
             F(expression) if isinstance(expression, str) else expression
             for expression in expressions
         )
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     @property
     def contains_expressions(self):
@@ -293,7 +319,7 @@ class UniqueConstraint(BaseConstraint):
         )
 
     def __repr__(self):
-        return "<%s:%s%s%s%s%s%s%s%s>" % (
```

**assistant → tool `bash`**

```json
{
  "command": "awk 'length>88 {print FILENAME\":\"FNR\": \"length}' django/db/models/constraints.py django/contrib/postgres/constraints.py tests/constraints/tests.py tests/postgres_tests/test_constraints.py"
}
```

**tool result**

```
django/db/models/constraints.py:25: 91
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n-    # def __init__(self, *, name, violation_error_code=None, violation_error_message=None):\n+    # def __init__(\n+    #     self, *, name, violation_error_code=None, violation_error_message=None\n+    # ):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/constraints.py now (445 lines), around the change:
22:    violation_error_message = None
23:
24:    # RemovedInDjango60Warning: When the deprecation ends, replace with:
25:    # def __init__(
26:    #     self, *, name, violation_error_code=None, violation_error_message=None
27:    # ):
28:    def __init__(
29:        self, *args, name=None, violation_error_code=None, violation_error_message=None
30:    ):
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py constraints postgres_tests.test_constraints validation.test_constraints --parallel 1 2>&1 | tail -6"
}
```

**tool result**

```
.............s.......................sss........................ssssssssssssssssssssssssssssssssssssssssssssssssss.....................
----------------------------------------------------------------------
Ran 135 tests in 0.101s

OK (skipped=54)
Destroying test database for alias 'default'...


(this is the fifth time you have made nearly this same bash call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**assistant**

```
Implemented `violation_error_code` support for constraints.

Changes:
- `django/db/models/constraints.py`
  - Added `BaseConstraint.violation_error_code` (default `None`) and a `violation_error_code` keyword argument to `BaseConstraint`, `CheckConstraint`, and `UniqueConstraint`.
  - Included it in `deconstruct()`, `__repr__()`, and `__eq__()`.
  - Passed it as `code=` to every `ValidationError` raised by `CheckConstraint.validate()` and `UniqueConstraint.validate()`.
- `django/contrib/postgres/constraints.py`
  - Added the same argument to `ExclusionConstraint`, including deconstruction/repr/equality and raised errors.
- Docs: updated constraint reference pages and the Django 5.0 release notes.
- Tests: added coverage for custom codes, cloning/deconstruction, repr, and validation for check, unique, and exclusion constraints.

Verification: `constraints`, `postgres_tests.test_constraints`, and `validation.test_constraints` all pass (135 tests, 54 skipped); `migrations` suite passes; Black reports no formatting changes.
```

## Run folder `team-solve-2026-11-06T112651`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
becf6f8b613d4206f95411821ed66e5e0f428edc
```

### `baseline-check.log`

```
check: ./tests/runtests.py constraints
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 73 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.......................s.......................sss.......................
----------------------------------------------------------------------
Ran 73 tests in 0.145s

OK (skipped=4)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/contrib/postgres/constraints.py b/django/contrib/postgres/constraints.py
index ad3a5f61f5..c61072b5a5 100644
--- a/django/contrib/postgres/constraints.py
+++ b/django/contrib/postgres/constraints.py
@@ -32,6 +32,7 @@ class ExclusionConstraint(BaseConstraint):
         condition=None,
         deferrable=None,
         include=None,
+        violation_error_code=None,
         violation_error_message=None,
     ):
         if index_type and index_type.lower() not in {"gist", "spgist"}:
@@ -60,7 +61,11 @@ class ExclusionConstraint(BaseConstraint):
         self.condition = condition
         self.deferrable = deferrable
         self.include = tuple(include) if include else ()
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     def _get_expressions(self, schema_editor, query):
         expressions = []
@@ -149,12 +154,13 @@ class ExclusionConstraint(BaseConstraint):
                 and self.condition == other.condition
                 and self.deferrable == other.deferrable
                 and self.include == other.include
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
 
     def __repr__(self):
-        return "<%s: index_type=%s expressions=%s name=%s%s%s%s%s>" % (
+        return "<%s: index_type=%s expressions=%s name=%s%s%s%s%s%s>" % (
             self.__class__.__qualname__,
             repr(self.index_type),
             repr(self.expressions),
@@ -162,6 +168,11 @@ class ExclusionConstraint(BaseConstraint):
             "" if self.condition is None else " condition=%s" % self.condition,
             "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
             "" if not self.include else " include=%s" % repr(self.include),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -204,9 +215,13 @@ class ExclusionConstraint(BaseConstraint):
             queryset = queryset.exclude(pk=model_class_pk)
         if not self.condition:
             if queryset.exists():
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
         else:
             if (self.condition & Exists(queryset.filter(self.condition))).check(
                 replacement_map, using=using
             ):
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
diff --git a/django/db/models/constraints.py b/django/db/models/constraints.py
index 075ecee1be..23dab686fc 100644
--- a/django/db/models/constraints.py
+++ b/django/db/models/constraints.py
@@ -18,11 +18,16 @@ __all__ = ["BaseConstraint", "CheckConstraint", "Deferrable", "UniqueConstraint"
 
 class BaseConstraint:
     default_violation_error_message = _("Constraint “%(name)s” is violated.")
+    violation_error_code = None
     violation_error_message = None
 
     # RemovedInDjango60Warning: When the deprecation ends, replace with:
-    # def __init__(self, *, name, violation_error_message=None):
-    def __init__(self, *args, name=None, violation_error_message=None):
+    # def __init__(
+    #     self, *, name, violation_error_code=None, violation_error_message=None
+    # ):
+    def __init__(
+        self, *args, name=None, violation_error_code=None, violation_error_message=None
+    ):
         # RemovedInDjango60Warning.
         if name is None and not args:
             raise TypeError(
@@ -30,6 +35,8 @@ class BaseConstraint:
                 f"argument: 'name'"
             )
         self.name = name
+        if violation_error_code is not None:
+            self.violation_error_code = violation_error_code
         if violation_error_message is not None:
             self.violation_error_message = violation_error_message
         else:
@@ -69,6 +76,8 @@ class BaseConstraint:
         path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
         path = path.replace("django.db.models.constraints", "django.db.models")
         kwargs = {"name": self.name}
+        if self.violation_error_code is not None:
+            kwargs["violation_error_code"] = self.violation_error_code
         if (
             self.violation_error_message is not None
             and self.violation_error_message != self.default_violation_error_message
@@ -82,13 +91,19 @@ class BaseConstraint:
 
 
 class CheckConstraint(BaseConstraint):
-    def __init__(self, *, check, name, violation_error_message=None):
+    def __init__(
+        self, *, check, name, violation_error_code=None, violation_error_message=None
+    ):
         self.check = check
         if not getattr(check, "conditional", False):
             raise TypeError(
                 "CheckConstraint.check must be a Q instance or boolean expression."
             )
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     def _get_check_sql(self, model, schema_editor):
         query = Query(model=model, alias_cols=False)
@@ -112,15 +127,22 @@ class CheckConstraint(BaseConstraint):
         against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
         try:
             if not Q(self.check).check(against, using=using):
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
         except FieldError:
             pass
 
     def __repr__(self):
-        return "<%s: check=%s name=%s%s>" % (
+        return "<%s: check=%s name=%s%s%s>" % (
             self.__class__.__qualname__,
             self.check,
             repr(self.name),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -134,6 +156,7 @@ class CheckConstraint(BaseConstraint):
             return (
                 self.name == other.name
                 and self.check == other.check
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
@@ -163,6 +186,7 @@ class UniqueConstraint(BaseConstraint):
         deferrable=None,
         include=None,
         opclasses=(),
+        violation_error_code=None,
         violation_error_message=None,
     ):
         if not name:
@@ -213,7 +237,11 @@ class UniqueConstraint(BaseConstraint):
             F(expression) if isinstance(expression, str) else expression
             for expression in expressions
         )
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     @property
     def contains_expressions(self):
@@ -293,7 +321,7 @@ class UniqueConstraint(BaseConstraint):
         )
 
     def __repr__(self):
-        return "<%s:%s%s%s%s%s%s%s%s>" % (
+        return "<%s:%s%s%s%s%s%s%s%s%s>" % (
             self.__class__.__qualname__,
             "" if not self.fields else " fields=%s" % repr(self.fields),
             "" if not self.expressions else " expressions=%s" % repr(self.expressions),
@@ -302,6 +330,11 @@ class UniqueConstraint(BaseConstraint):
             "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
             "" if not self.include else " include=%s" % repr(self.include),
             "" if not self.opclasses else " opclasses=%s" % repr(self.opclasses),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -320,6 +353,7 @@ class UniqueConstraint(BaseConstraint):
                 and self.include == other.include
                 and self.opclasses == other.opclasses
                 and self.expressions == other.expressions
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
@@ -385,7 +419,10 @@ class UniqueConstraint(BaseConstraint):
         if not self.condition:
             if queryset.exists():
                 if self.expressions:
-                    raise ValidationError(self.get_violation_error_message())
+                    raise ValidationError(
+                        self.get_violation_error_message(),
+                        code=self.violation_error_code,
+                    )
                 # When fields are defined, use the unique_error_message() for
                 # backward compatibility.
                 for model, constraints in instance.get_constraints():
@@ -400,6 +437,9 @@ class UniqueConstraint(BaseConstraint):
                 if (self.condition & Exists(queryset.filter(self.condition))).check(
                     against, using=using
                 ):
-                    raise ValidationError(self.get_violation_error_message())
+                    raise ValidationError(
+                        self.get_violation_error_message(),
+                        code=self.violation_error_code,
+                    )
             except FieldError:
                 pass
diff --git a/docs/ref/contrib/postgres/constraints.txt b/docs/ref/contrib/postgres/constraints.txt
index fcf50b8b5f..78b96be4a4 100644
--- a/docs/ref/contrib/postgres/constraints.txt
+++ b/docs/ref/contrib/postgres/constraints.txt
@@ -12,7 +12,7 @@ PostgreSQL supports additional data integrity constraints available from the
 ``ExclusionConstraint``
 =======================
 
-.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)
+.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_code=None, violation_error_message=None)
 
     Creates an exclusion constraint in the database. Internally, PostgreSQL
     implements exclusion constraints using indexes. The default index type is
@@ -140,6 +140,13 @@ The error message used when ``ValidationError`` is raised during
 :ref:`model validation <validating-objects>`. Defaults to
 :attr:`.BaseConstraint.violation_error_message`.
 
+``violation_error_code``
+------------------------
+
+The error code used when ``ValidationError`` is raised during
+:ref:`model validation <validating-objects>`. Defaults to
+:attr:`.BaseConstraint.violation_error_code`.
+
 Examples
 --------
 
diff --git a/docs/ref/models/constraints.txt b/docs/ref/models/constraints.txt
index baaacd8754..bb7ec01946 100644
--- a/docs/ref/models/constraints.txt
+++ b/docs/ref/models/constraints.txt
@@ -48,7 +48,7 @@ option.
 ``BaseConstraint``
 ==================
 
-.. class:: BaseConstraint(*, name, violation_error_message=None)
+.. class:: BaseConstraint(*, name, violation_error_code=None, violation_error_message=None)
 
     Base class for all constraints. Subclasses must implement
     ``constraint_sql()``, ``create_sql()``, ``remove_sql()`` and
@@ -77,6 +77,14 @@ The error message used when ``ValidationError`` is raised during
 :ref:`model validation <validating-objects>`. Defaults to
 ``"Constraint “%(name)s” is violated."``.
 
+``violation_error_code``
+------------------------
+
+.. attribute:: BaseConstraint.violation_error_code
+
+The error code used when ``ValidationError`` is raised during
+:ref:`model validation <validating-objects>`. Defaults to ``None``.
+
 ``validate()``
 --------------
 
@@ -94,7 +102,7 @@ This method must be implemented by a subclass.
 ``CheckConstraint``
 ===================
 
-.. class:: CheckConstraint(*, check, name, violation_error_message=None)
+.. class:: CheckConstraint(*, check, name, violation_error_code=None, violation_error_message=None)
 
     Creates a check constraint in the database.
 
@@ -121,7 +129,7 @@ ensures the age field is never less than 18.
 ``UniqueConstraint``
 ====================
 
-.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)
+.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_code=None, violation_error_message=None)
 
     Creates a unique constraint in the database.
 
diff --git a/docs/releases/5.0.txt b/docs/releases/5.0.txt
index 14e767cfd8..44d1fcaedf 100644
--- a/docs/releases/5.0.txt
+++ b/docs/releases/5.0.txt
@@ -178,6 +178,12 @@ Migrations
 Models
 ~~~~~~
 
+* The new ``violation_error_code`` argument of
+  :class:`~django.db.models.BaseConstraint`,
+  :class:`~django.db.models.CheckConstraint`, and
+  :class:`~django.db.models.UniqueConstraint` allows customizing the error code
+  of the ``ValidationError`` raised during model validation.
+
 * The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`
   and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different
   field values for the create operation.
diff --git a/tests/constraints/tests.py b/tests/constraints/tests.py
index b45dc6499a..3208ffb857 100644
--- a/tests/constraints/tests.py
+++ b/tests/constraints/tests.py
@@ -67,6 +67,17 @@ class BaseConstraintTests(SimpleTestCase):
         )
         self.assertEqual(c.get_violation_error_message(), "custom base_name message")
 
+    def test_custom_violation_error_code(self):
+        c = BaseConstraint(name="base_name", violation_error_code="custom_code")
+        self.assertEqual(c.violation_error_code, "custom_code")
+
+    def test_custom_violation_error_code_clone(self):
+        constraint = BaseConstraint(
+            name="base_name",
+            violation_error_code="custom_code",
+        ).clone()
+        self.assertEqual(constraint.violation_error_code, "custom_code")
+
     def test_custom_violation_error_message_clone(self):
         constraint = BaseConstraint(
             name="base_name",
@@ -80,6 +91,7 @@ class BaseConstraintTests(SimpleTestCase):
     def test_deconstruction(self):
         constraint = BaseConstraint(
             name="base_name",
+            violation_error_code="custom_code",
             violation_error_message="custom %(name)s message",
         )
         path, args, kwargs = constraint.deconstruct()
@@ -87,7 +99,11 @@ class BaseConstraintTests(SimpleTestCase):
         self.assertEqual(args, ())
         self.assertEqual(
             kwargs,
-            {"name": "base_name", "violation_error_message": "custom %(name)s message"},
+            {
+                "name": "base_name",
+                "violation_error_code": "custom_code",
+                "violation_error_message": "custom %(name)s message",
+            },
         )
 
     def test_deprecation(self):
@@ -172,6 +188,18 @@ class CheckConstraintTests(TestCase):
             "violation_error_message='More than 1'>",
         )
 
+    def test_repr_with_violation_error_code(self):
+        constraint = models.CheckConstraint(
+            check=models.Q(price__lt=1),
+            name="price_lt_one",
+            violation_error_code="more_than_one",
+        )
+        self.assertEqual(
+            repr(constraint),
+            "<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' "
+            "violation_error_code='more_than_one'>",
+        )
+
     def test_invalid_check_types(self):
         msg = "CheckConstraint.check must be a Q instance or boolean expression."
         with self.assertRaisesMessage(TypeError, msg):
@@ -251,6 +279,16 @@ class CheckConstraintTests(TestCase):
         constraint.validate(Product, Product(price=501, discounted_price=5))
         constraint.validate(Product, Product(price=499, discounted_price=5))
 
+    def test_validate_custom_error_code(self):
+        constraint = models.CheckConstraint(
+            check=models.Q(price__gt=models.F("discounted_price")),
+            name="price_gt_discounted_price",
+            violation_error_code="invalid_price",
+        )
+        with self.assertRaises(ValidationError) as cm:
+            constraint.validate(Product, Product(price=10, discounted_price=42))
+        self.assertEqual(cm.exception.code, "invalid_price")
+
     def test_validate_rawsql_expressions_noop(self):
         constraint = models.CheckConstraint(
             check=models.expressions.RawSQL(
@@ -737,6 +775,19 @@ class UniqueConstraintTests(TestCase):
             exclude={"name"},
         )
 
+    def test_validate_expression_custom_error_code(self):
+        constraint = models.UniqueConstraint(
+            Lower("name"),
+            name="name_lower_uniq",
+            violation_error_code="duplicate_name",
+        )
+        with self.assertRaises(ValidationError) as cm:
+            constraint.validate(
+                UniqueConstraintProduct,
+                UniqueConstraintProduct(name=self.p1.name.upper()),
+            )
+        self.assertEqual(cm.exception.code, "duplicate_name")
+
     def test_validate_ordered_expression(self):
         constraint = models.UniqueConstraint(
             Lower("name").desc(), name="name_lower_uniq_desc"
diff --git a/tests/postgres_tests/test_constraints.py b/tests/postgres_tests/test_constraints.py
index a5248e1491..c296812f64 100644
--- a/tests/postgres_tests/test_constraints.py
+++ b/tests/postgres_tests/test_constraints.py
@@ -397,6 +397,17 @@ class ExclusionConstraintTests(PostgreSQLTestCase):
             "(F(datespan), '-|-')] name='exclude_overlapping' "
             "violation_error_message='Overlapping must be excluded'>",
         )
+        constraint = ExclusionConstraint(
+            name="exclude_overlapping",
+            expressions=[(F("datespan"), RangeOperators.ADJACENT_TO)],
+            violation_error_code="overlapping",
+        )
+        self.assertEqual(
+            repr(constraint),
+            "<ExclusionConstraint: index_type='GIST' expressions=["
+            "(F(datespan), '-|-')] name='exclude_overlapping' "
+            "violation_error_code='overlapping'>",
+        )
 
     def test_eq(self):
         constraint_1 = ExclusionConstraint(
@@ -771,6 +782,16 @@ class ExclusionConstraintTests(PostgreSQLTestCase):
         constraint.validate(RangesModel, RangesModel(ints=(51, 60)))
         constraint.validate(RangesModel, RangesModel(ints=(10, 20)), exclude={"ints"})
 
+    def test_validate_custom_error_code(self):
+        constraint = ExclusionConstraint(
+            name="ints_adjacent",
+            expressions=[("ints", RangeOperators.ADJACENT_TO)],
+            violation_error_code="adjacent_ints",
+        )
+        with self.assertRaises(ValidationError) as cm:
+            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))
+        self.assertEqual(cm.exception.code, "adjacent_ints")
+
     def test_expressions_with_params(self):
         constraint_name = "scene_left_equal"
         self.assertNotIn(constraint_name, self.get_constraints(Scene._meta.db_table))
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

Allow to customize the code attribute of ValidationError raised by BaseConstraint.validate
Description
	
It is currently possible to customize the violation_error_message of a ValidationError raised by a constraint but not the code.
I'd like to add a new violation_error_message parameter to BaseConstraint to allow to easily add one.
Currently, to achieve the same result, you have to subclass the constraint to tweak validate to catch and reraise the ValidationError.
Since the documentation recommends to Provide a descriptive error code to the constructor: when raising a ValidationError in ​https://docs.djangoproject.com/en/4.1/ref/forms/validation/#raising-validationerror , I think it would make sense to provide this possibility for errors raised by constraints.
If you think it would be a good idea, I'd be happy to work on a PR.

## Deliverable

changes to this tree

## Check

`./tests/runtests.py constraints`

## Scope

`django/db/models/constraints.py`
`tests/constraints/`
`docs/ref/models/constraints.txt`

## Done when

- `BaseConstraint` accepts a `violation_error_code` keyword argument and stores it, defaulting to `None`.
- `CheckConstraint` and `UniqueConstraint` accept and forward `violation_error_code` to `BaseConstraint`.
- A constraint validation failure raises `ValidationError` with `code` equal to the configured `violation_error_code`.
- When `violation_error_code` is unset, the raised `ValidationError.code` remains `"constraint"`.
- `(inferred)` `deconstruct()` includes `violation_error_code` when it is not `None`, so migrations preserve it.
- `(inferred)` constraint equality accounts for `violation_error_code`.



# plan.md

## Deliverable
changes to this tree

## Check
`./tests/runtests.py constraints`

## Scope
`django/db/models/constraints.py`
`tests/constraints/`
`docs/ref/models/constraints.txt`

## Done when
- `BaseConstraint` accepts a `violation_error_code` keyword argument and stores it, defaulting to `None`.
- `CheckConstraint` and `UniqueConstraint` accept and forward `violation_error_code` to `BaseConstraint`.
- A constraint validation failure raises `ValidationError` with `code` equal to the configured `violation_error_code`.
- When `violation_error_code` is unset, the raised `ValidationError.code` remains `"constraint"`.
- `(inferred)` `deconstruct()` includes `violation_error_code` when it is not `None`, so migrations preserve it.
- `(inferred)` constraint equality accounts for `violation_error_code`.

## Approach
Decompose into: add the option to `BaseConstraint`; thread it through `CheckConstraint` and `UniqueConstraint`; apply it to the `ValidationError` raised during validation; serialize it in `deconstruct()`; update equality; add focused tests in `tests/constraints/`; document the new argument.

Candidate approaches:
1. Central rewrite in `BaseConstraint._check()`: catch `ValidationError`, and when its code is the default `"constraint"`, replace it with `self.violation_error_code or "constraint"`. This keeps subclass `validate()` methods unchanged and avoids duplication.
2. Pass the code directly in each subclass `validate()` call: `code=self.violation_error_code or "constraint"`. This is explicit but duplicates logic across `CheckConstraint` and `UniqueConstraint`.
3. Add the option only to subclasses without `BaseConstraint`. This is less consistent and does not satisfy the request to customize errors raised by `BaseConstraint.validate`.

Prefer approach 1, with `deconstruct()` and equality updated so migrations and model state remain correct.


# django/db/models/constraints.py

```
import warnings
from enum import Enum
from types import NoneType

from django.core.exceptions import FieldError, ValidationError
from django.db import connections
from django.db.models.expressions import Exists, ExpressionList, F, OrderBy
from django.db.models.indexes import IndexExpression
from django.db.models.lookups import Exact
from django.db.models.query_utils import Q
from django.db.models.sql.query import Query
from django.db.utils import DEFAULT_DB_ALIAS
from django.utils.deprecation import RemovedInDjango60Warning
from django.utils.translation import gettext_lazy as _

__all__ = ["BaseConstraint", "CheckConstraint", "Deferrable", "UniqueConstraint"]


class BaseConstraint:
    default_violation_error_message = _("Constraint “%(name)s” is violated.")
    violation_error_message = None

    # RemovedInDjango60Warning: When the deprecation ends, replace with:
    # def __init__(self, *, name, violation_error_message=None):
    def __init__(self, *args, name=None, violation_error_message=None):
        # RemovedInDjango60Warning.
        if name is None and not args:
            raise TypeError(
                f"{self.__class__.__name__}.__init__() missing 1 required keyword-only "
                f"argument: 'name'"
            )
        self.name = name
        if violation_error_message is not None:
            self.violation_error_message = violation_error_message
        else:
            self.violation_error_message = self.default_violation_error_message
        # RemovedInDjango60Warning.
        if args:
            warnings.warn(
                f"Passing positional arguments to {self.__class__.__name__} is "
                f"deprecated.",
                RemovedInDjango60Warning,
                stacklevel=2,
            )
            for arg, attr in zip(args, ["name", "violation_error_message"]):
                if arg:
                    setattr(self, attr, arg)

    @property
    def contains_expressions(self):
        return False

    def constraint_sql(self, model, schema_editor):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def create_sql(self, model, schema_editor):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def remove_sql(self, model, schema_editor):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        raise NotImplementedError("This method must be implemented by a subclass.")

    def get_violation_error_message(self):
        return self.violation_error_message % {"name": self.name}

    def deconstruct(self):
        path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
        path = path.replace("django.db.models.constraints", "django.db.models")
        kwargs = {"name": self.name}
        if (
            self.violation_error_message is not None
            and self.violation_error_message != self.default_violation_error_message
        ):
            kwargs["violation_error_message"] = self.violation_error_message
        return (path, (), kwargs)

    def clone(self):
        _, args, kwargs = self.deconstruct()
        return self.__class__(*args, **kwargs)


class CheckConstraint(BaseConstraint):
    def __init__(self, *, check, name, violation_error_message=None):
        self.check = check
        if not getattr(check, "conditional", False):
            raise TypeError(
                "CheckConstraint.check must be a Q instance or boolean expression."
            )
        super().__init__(name=name, violation_error_message=violation_error_message)

    def _get_check_sql(self, model, schema_editor):
        query = Query(model=model, alias_cols=False)
        where = query.build_where(self.check)
        compiler = query.get_compiler(connection=schema_editor.connection)
        sql, params = where.as_sql(compiler, schema_editor.connection)
        return sql % tuple(schema_editor.quote_value(p) for p in params)

    def constraint_sql(self, model, schema_editor):
        check = self._get_check_sql(model, schema_editor)
        return schema_editor._check_sql(self.name, check)

    def create_sql(self, model, schema_editor):
        check = self._get_check_sql(model, schema_editor)
        return schema_editor._create_check_sql(model, self.name, check)

    def remove_sql(self, model, schema_editor):
        return schema_editor._delete_check_sql(model, self.name)

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
        try:
            if not Q(self.check).check(against, using=using):
                raise ValidationError(self.get_violation_error_message())
        except FieldError:
            pass

    def __repr__(self):
        return "<%s: check=%s name=%s%s>" % (
            self.__class__.__qualname__,
            self.check,
            repr(self.name),
            (
                ""
                if self.violation_error_message is None
                or self.violation_error_message == self.default_violation_error_message
                else " violation_error_message=%r" % self.violation_error_message
            ),
        )

    def __eq__(self, other):
        if isinstance(other, CheckConstraint):
            return (
                self.name == other.name
                and self.check == other.check
                and self.violation_error_message == other.violation_error_message
            )
        return super().__eq__(other)

    def deconstruct(self):
        path, args, kwargs = super().deconstruct()
        kwargs["check"] = self.check
        return path, args, kwargs


class Deferrable(Enum):
    DEFERRED = "deferred"
    IMMEDIATE = "immediate"

    # A similar format was proposed for Python 3.10.
    def __repr__(self):
        return f"{self.__class__.__qualname__}.{self._name_}"


class UniqueConstraint(BaseConstraint):
    def __init__(
        self,
        *expressions,
        fields=(),
        name=None,
        condition=None,
        deferrable=None,
        include=None,
        opclasses=(),
        violation_error_message=None,
    ):
        if not name:
            raise ValueError("A unique constraint must be named.")
        if not expressions and not fields:
            raise ValueError(
                "At least one field or expression is required to define a "
                "unique constraint."
            )
        if expressions and fields:
            raise ValueError(
                "UniqueConstraint.fields and expressions are mutually exclusive."
            )
        if not isinstance(condition, (NoneType, Q)):
            raise ValueError("UniqueConstraint.condition must be a Q instance.")
        if condition and deferrable:
            raise ValueError("UniqueConstraint with conditions cannot be deferred.")
        if include and deferrable:
            raise ValueError("UniqueConstraint with include fields cannot be deferred.")
        if opclasses and deferrable:
            raise ValueError("UniqueConstraint with opclasses cannot be deferred.")
        if expressions and deferrable:
            raise ValueError("UniqueConstraint with expressions cannot be deferred.")
        if expressions and opclasses:
            raise ValueError(
                "UniqueConstraint.opclasses cannot be used with expressions. "
                "Use django.contrib.postgres.indexes.OpClass() instead."
            )
        if not isinstance(deferrable, (NoneType, Deferrable)):
            raise ValueError(
                "UniqueConstraint.deferrable must be a Deferrable instance."
            )
        if not isinstance(include, (NoneType, list, tuple)):
            raise ValueError("UniqueConstraint.include must be a list or tuple.")
        if not isinstance(opclasses, (list, tuple)):
            raise ValueError("UniqueConstraint.opclasses must be a list or tuple.")
        if opclasses and len(fields) != len(opclasses):
            raise ValueError(
                "UniqueConstraint.fields and UniqueConstraint.opclasses must "
                "have the same number of elements."
            )
        self.fields = tuple(fields)
        self.condition = condition
        self.deferrable = deferrable
        self.include = tuple(include) if include else ()
        self.opclasses = opclasses
        self.expressions = tuple(
            F(expression) if isinstance(expression, str) else expression
            for expression in expressions
        )
        super().__init__(name=name, violation_error_message=violation_error_message)

    @property
    def contains_expressions(self):
        return bool(self.expressions)

    def _get_condition_sql(self, model, schema_editor):
        if self.condition is None:
            return None
        query = Query(model=model, alias_cols=False)
        where = query.build_where(self.condition)
        compiler = query.get_compiler(connection=schema_editor.connection)
        sql, params = where.as_sql(compiler, schema_editor.connection)
        return sql % tuple(schema_editor.quote_value(p) for p in params)

    def _get_index_expressions(self, model, schema_editor):
        if not self.expressions:
            return None
        index_expressions = []
        for expression in self.expressions:
            index_expression = IndexExpression(expression)
            index_expression.set_wrapper_classes(schema_editor.connection)
            index_expressions.append(index_expression)
        return ExpressionList(*index_expressions).resolve_expression(
            Query(model, alias_cols=False),
        )

    def constraint_sql(self, model, schema_editor):
        fields = [model._meta.get_field(field_name) for field_name in self.fields]
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        condition = self._get_condition_sql(model, schema_editor)
        expressions = self._get_index_expressions(model, schema_editor)
        return schema_editor._unique_sql(
            model,
            fields,
            self.name,
            condition=condition,
            deferrable=self.deferrable,
            include=include,
            opclasses=self.opclasses,
            expressions=expressions,
        )

    def create_sql(self, model, schema_editor):
        fields = [model._meta.get_field(field_name) for field_name in self.fields]
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        condition = self._get_condition_sql(model, schema_editor)
        expressions = self._get_index_expressions(model, schema_editor)
        return schema_editor._create_unique_sql(
            model,
            fields,
            self.name,
            condition=condition,
            deferrable=self.deferrable,
            include=include,
            opclasses=self.opclasses,
            expressions=expressions,
        )

    def remove_sql(self, model, schema_editor):
        condition = self._get_condition_sql(model, schema_editor)
        include = [
            model._meta.get_field(field_name).column for field_name in self.include
        ]
        expressions = self._get_index_expressions(model, schema_editor)
        return schema_editor._delete_unique_sql(
            model,
            self.name,
            condition=condition,
            deferrable=self.deferrable,
            include=include,
            opclasses=self.opclasses,
            expressions=expressions,
        )

    def __repr__(self):
        return "<%s:%s%s%s%s%s%s%s%s>" % (
            self.__class__.__qualname__,
            "" if not self.fields else " fields=%s" % repr(self.fields),
            "" if not self.expressions else " expressions=%s" % repr(self.expressions),
            " name=%s" % repr(self.name),
            "" if self.condition is None else " condition=%s" % self.condition,
            "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
            "" if not self.include else " include=%s" % repr(self.include),
            "" if not self.opclasses else " opclasses=%s" % repr(self.opclasses),
            (
                ""
                if self.violation_error_message is None
                or self.violation_error_message == self.default_violation_error_message
                else " violation_error_message=%r" % self.violation_error_message
            ),
        )

    def __eq__(self, other):
        if isinstance(other, UniqueConstraint):
            return (
                self.name == other.name
                and self.fields == other.fields
                and self.condition == other.condition
                and self.deferrable == other.deferrable
                and self.include == other.include
                and self.opclasses == other.opclasses
                and self.expressions == other.expressions
                and self.violation_error_message == other.violation_error_message
            )
        return super().__eq__(other)

    def deconstruct(self):
        path, args, kwargs = super().deconstruct()
        if self.fields:
            kwargs["fields"] = self.fields
        if self.condition:
            kwargs["condition"] = self.condition
        if self.deferrable:
            kwargs["deferrable"] = self.deferrable
        if self.include:
            kwargs["include"] = self.include
        if self.opclasses:
            kwargs["opclasses"] = self.opclasses
        return path, self.expressions, kwargs

    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
        queryset = model._default_manager.using(using)
        if self.fields:
            lookup_kwargs = {}
            for field_name in self.fields:
                if exclude and field_name in exclude:
                    return
                field = model._meta.get_field(field_name)
                lookup_value = getattr(instance, field.attname)
                if lookup_value is None or (
                    lookup_value == ""
                    and connections[using].features.interprets_empty_strings_as_nulls
                ):
                    # A composite constraint containing NULL value cannot cause
                    # a violation since NULL != NULL in SQL.
                    return
                lookup_kwargs[field.name] = lookup_value
            queryset = queryset.filter(**lookup_kwargs)
        else:
            # Ignore constraints with excluded fields.
            if exclude:
                for expression in self.expressions:
                    if hasattr(expression, "flatten"):
                        for expr in expression.flatten():
                            if isinstance(expr, F) and expr.name in exclude:
                                return
                    elif isinstance(expression, F) and expression.name in exclude:
                        return
            replacements = {
                F(field): value
                for field, value in instance._get_field_value_map(
                    meta=model._meta, exclude=exclude
                ).items()
            }
            expressions = []
            for expr in self.expressions:
                # Ignore ordering.
                if isinstance(expr, OrderBy):
                    expr = expr.expression
                expressions.append(Exact(expr, expr.replace_expressions(replacements)))
            queryset = queryset.filter(*expressions)
        model_class_pk = instance._get_pk_val(model._meta)
        if not instance._state.adding and model_class_pk is not None:
            queryset = queryset.exclude(pk=model_class_pk)
        if not self.condition:
            if queryset.exists():
                if self.expressions:
                    raise ValidationError(self.get_violation_error_message())
                # When fields are defined, use the unique_error_message() for
                # backward compatibility.
                for model, constraints in instance.get_constraints():
                    for constraint in constraints:
                        if constraint is self:
                            raise ValidationError(
                                instance.unique_error_message(model, self.fields)
                            )
        else:
            against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
            try:
                if (self.condition & Exists(queryset.filter(self.condition))).check(
                    against, using=using
                ):
                    raise ValidationError(self.get_violation_error_message())
            except FieldError:
                pass

```


# tests/constraints (the files in it)

tests/constraints/__init__.py
tests/constraints/models.py
tests/constraints/tests.py


# docs/ref/models/constraints.txt

```
=====================
Constraints reference
=====================

.. module:: django.db.models.constraints

.. currentmodule:: django.db.models

The classes defined in this module create database constraints. They are added
in the model :attr:`Meta.constraints <django.db.models.Options.constraints>`
option.

.. admonition:: Referencing built-in constraints

    Constraints are defined in ``django.db.models.constraints``, but for
    convenience they're imported into :mod:`django.db.models`. The standard
    convention is to use ``from django.db import models`` and refer to the
    constraints as ``models.<Foo>Constraint``.

.. admonition:: Constraints in abstract base classes

    You must always specify a unique name for the constraint. As such, you
    cannot normally specify a constraint on an abstract base class, since the
    :attr:`Meta.constraints <django.db.models.Options.constraints>` option is
    inherited by subclasses, with exactly the same values for the attributes
    (including ``name``) each time. To work around name collisions, part of the
    name may contain ``'%(app_label)s'`` and ``'%(class)s'``, which are
    replaced, respectively, by the lowercased app label and class name of the
    concrete model. For example ``CheckConstraint(check=Q(age__gte=18),
    name='%(app_label)s_%(class)s_is_adult')``.

.. admonition:: Validation of Constraints

    Constraints are checked during the :ref:`model validation
    <validating-objects>`.

.. admonition:: Validation of Constraints with ``JSONField``

    Constraints containing :class:`~django.db.models.JSONField` may not raise
    validation errors as key, index, and path transforms have many
    database-specific caveats. This :ticket:`may be fully supported later
    <34059>`.

    You should always check that there are no log messages, in the
    ``django.db.models`` logger, like *"Got a database error calling check() on
    …"* to confirm it's validated properly.

``BaseConstraint``
==================

.. class:: BaseConstraint(*, name, violation_error_message=None)

    Base class for all constraints. Subclasses must implement
    ``constraint_sql()``, ``create_sql()``, ``remove_sql()`` and
    ``validate()`` methods.

    .. deprecated:: 5.0

        Support for passing positional arguments is deprecated.

All constraints have the following parameters in common:

``name``
--------

.. attribute:: BaseConstraint.name

The name of the constraint. You must always specify a unique name for the
constraint.

``violation_error_message``
---------------------------

.. attribute:: BaseConstraint.violation_error_message

The error message used when ``ValidationError`` is raised during
:ref:`model validation <validating-objects>`. Defaults to
``"Constraint “%(name)s” is violated."``.

``validate()``
--------------

.. method:: BaseConstraint.validate(model, instance, exclude=None, using=DEFAULT_DB_ALIAS)

Validates that the constraint, defined on ``model``, is respected on the
``instance``. This will do a query on the database to ensure that the
constraint is respected. If fields in the ``exclude`` list are needed to
validate the constraint, the constraint is ignored.

Raise a ``ValidationError`` if the constraint is violated.

This method must be implemented by a subclass.

``CheckConstraint``
===================

.. class:: CheckConstraint(*, check, name, violation_error_message=None)

    Creates a check constraint in the database.

``check``
---------

.. attribute:: CheckConstraint.check

A :class:`Q` object or boolean :class:`~django.db.models.Expression` that
specifies the check you want the constraint to enforce.

For example, ``CheckConstraint(check=Q(age__gte=18), name='age_gte_18')``
ensures the age field is never less than 18.

.. admonition:: Oracle

    Checks with nullable fields on Oracle must include a condition allowing for
    ``NULL`` values in order for :meth:`validate() <BaseConstraint.validate>`
    to behave the same as check constraints validation. For example, if ``age``
    is a nullable field::

        CheckConstraint(check=Q(age__gte=18) | Q(age__isnull=True), name='age_gte_18')

``UniqueConstraint``
====================

.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)

    Creates a unique constraint in the database.

``expressions``
---------------

.. attribute:: UniqueConstraint.expressions

Positional argument ``*expressions`` allows creating functional unique
constraints on expressions and database functions.

For example::

    UniqueConstraint(Lower('name').desc(), 'category', name='unique_lower_name_category')

creates a unique constraint on the lowercased value of the ``name`` field in
descending order and the ``category`` field in the default ascending order.

Functional unique constraints have the same database restrictions as
:attr:`Index.expressions`.

``fields``
----------

.. attribute:: UniqueConstraint.fields

A list of field names that specifies the unique set of columns you want the
constraint to enforce.

For example, ``UniqueConstraint(fields=['room', 'date'],
name='unique_booking')`` ensures each room can only be booked once for each
date.

``condition``
-------------

.. attribute:: UniqueConstraint.condition

A :class:`Q` object that specifies the condition you want the constraint to
enforce.

For example::

    UniqueConstraint(fields=['user'], condition=Q(status='DRAFT'), name='unique_draft_user')

ensures that each user only has one draft.

These conditions have the same database restrictions as
:attr:`Index.condition`.

``deferrable``
--------------

.. attribute:: UniqueConstraint.deferrable

Set this parameter to create a deferrable unique constraint. Accepted values
are ``Deferrable.DEFERRED`` or ``Deferrable.IMMEDIATE``. For example::

    from django.db.models import Deferrable, UniqueConstraint

    UniqueConstraint(
        name='unique_order',
        fields=['order'],
        deferrable=Deferrable.DEFERRED,
    )

By default constraints are not deferred. A deferred constraint will not be
enforced until the end of the transaction. An immediate constraint will be
enforced immediately after every command.

.. admonition:: MySQL, MariaDB, and SQLite.

    Deferrable unique constraints are ignored on MySQL, MariaDB, and SQLite as
    neither supports them.

.. warning::

    Deferred unique constraints may lead to a `performance penalty
    <https://www.postgresql.org/docs/current/sql-createtable.html#id-1.9.3.85.9.4>`_.

``include``
-----------

.. attribute:: UniqueConstraint.include

A list or tuple of the names of the fields to be included in the covering
unique index as non-key columns. This allows index-only scans to be used for
queries that select only included fields (:attr:`~UniqueConstraint.include`)
and filter only by unique fields (:attr:`~UniqueConstraint.fields`).

For example::

    UniqueConstraint(name='unique_booking', fields=['room', 'date'], include=['full_name'])

will allow filtering on ``room`` and ``date``, also selecting ``full_name``,
while fetching data only from the index.

``include`` is supported only on PostgreSQL.

Non-key columns have the same database restrictions as :attr:`Index.include`.


``opclasses``
-------------

.. attribute:: UniqueConstraint.opclasses

The names of the `PostgreSQL operator classes
<https://www.postgresql.org/docs/current/indexes-opclass.html>`_ to use for
this unique index. If you require a custom operator class, you must provide one
for each field in the index.

For example::

    UniqueConstraint(name='unique_username', fields=['username'], opclasses=['varchar_pattern_ops'])

creates a unique index on ``username`` using ``varchar_pattern_ops``.

``opclasses`` are ignored for databases besides PostgreSQL.

``violation_error_message``
---------------------------

.. attribute:: UniqueConstraint.violation_error_message

The error message used when ``ValidationError`` is raised during
:ref:`model validation <validating-objects>`. Defaults to
:attr:`.BaseConstraint.violation_error_message`.

This message is *not used* for :class:`UniqueConstraint`\s with
:attr:`~UniqueConstraint.fields` and without a
:attr:`~UniqueConstraint.condition`. Such :class:`~UniqueConstraint`\s show the
same message as constraints defined with
:attr:`.Field.unique` or in
:attr:`Meta.unique_together <django.db.models.Options.constraints>`.

```


# The last commit

```
becf6f8b61 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: ./tests/runtests.py constraints
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 78 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
...........................s.......................sss........................
----------------------------------------------------------------------
Ran 78 tests in 0.105s

OK (skipped=4)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/models/constraints.py tests/constraints docs/ref/models/constraints.txt
OUTSIDE THE SCOPE: django/contrib/postgres/constraints.py +19 -4 (undo it: git checkout the file, or delete it when the run made it)
changed: django/db/models/constraints.py +50 -10
OUTSIDE THE SCOPE: docs/ref/contrib/postgres/constraints.txt +8 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: docs/ref/models/constraints.txt +11 -3
OUTSIDE THE SCOPE: docs/releases/5.0.txt +6 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/constraints/tests.py +52 -1
OUTSIDE THE SCOPE: tests/postgres_tests/test_constraints.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/postgres/constraints.py b/django/contrib/postgres/constraints.py
index ad3a5f61f5..c61072b5a5 100644
--- a/django/contrib/postgres/constraints.py
+++ b/django/contrib/postgres/constraints.py
@@ -32,6 +32,7 @@ class ExclusionConstraint(BaseConstraint):
         condition=None,
         deferrable=None,
         include=None,
+        violation_error_code=None,
         violation_error_message=None,
     ):
         if index_type and index_type.lower() not in {"gist", "spgist"}:
@@ -60,7 +61,11 @@ class ExclusionConstraint(BaseConstraint):
         self.condition = condition
         self.deferrable = deferrable
         self.include = tuple(include) if include else ()
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     def _get_expressions(self, schema_editor, query):
         expressions = []
@@ -149,12 +154,13 @@ class ExclusionConstraint(BaseConstraint):
                 and self.condition == other.condition
                 and self.deferrable == other.deferrable
                 and self.include == other.include
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
 
     def __repr__(self):
-        return "<%s: index_type=%s expressions=%s name=%s%s%s%s%s>" % (
+        return "<%s: index_type=%s expressions=%s name=%s%s%s%s%s%s>" % (
             self.__class__.__qualname__,
             repr(self.index_type),
             repr(self.expressions),
@@ -162,6 +168,11 @@ class ExclusionConstraint(BaseConstraint):
             "" if self.condition is None else " condition=%s" % self.condition,
             "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
             "" if not self.include else " include=%s" % repr(self.include),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -204,9 +215,13 @@ class ExclusionConstraint(BaseConstraint):
             queryset = queryset.exclude(pk=model_class_pk)
         if not self.condition:
             if queryset.exists():
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
         else:
             if (self.condition & Exists(queryset.filter(self.condition))).check(
                 replacement_map, using=using
             ):
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
diff --git a/django/db/models/constraints.py b/django/db/models/constraints.py
index 075ecee1be..23dab686fc 100644
--- a/django/db/models/constraints.py
+++ b/django/db/models/constraints.py
@@ -18,11 +18,16 @@ __all__ = ["BaseConstraint", "CheckConstraint", "Deferrable", "UniqueConstraint"
 
 class BaseConstraint:
     default_violation_error_message = _("Constraint “%(name)s” is violated.")
+    violation_error_code = None
     violation_error_message = None
 
     # RemovedInDjango60Warning: When the deprecation ends, replace with:
-    # def __init__(self, *, name, violation_error_message=None):
-    def __init__(self, *args, name=None, violation_error_message=None):
+    # def __init__(
+    #     self, *, name, violation_error_code=None, violation_error_message=None
+    # ):
+    def __init__(
+        self, *args, name=None, violation_error_code=None, violation_error_message=None
+    ):
         # RemovedInDjango60Warning.
         if name is None and not args:
             raise TypeError(
@@ -30,6 +35,8 @@ class BaseConstraint:
                 f"argument: 'name'"
             )
         self.name = name
+        if violation_error_code is not None:
+            self.violation_error_code = violation_error_code
         if violation_error_message is not None:
             self.violation_error_message = violation_error_message
         else:
@@ -69,6 +76,8 @@ class BaseConstraint:
         path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
         path = path.replace("django.db.models.constraints", "django.db.models")
         kwargs = {"name": self.name}
+        if self.violation_error_code is not None:
+            kwargs["violation_error_code"] = self.violation_error_code
         if (
             self.violation_error_message is not None
             and self.violation_error_message != self.default_violation_error_message
@@ -82,13 +91,19 @@ class BaseConstraint:
 
 
 class CheckConstraint(BaseConstraint):
-    def __init__(self, *, check, name, violation_error_message=None):
+    def __init__(
+        self, *, check, name, violation_error_code=None, violation_error_message=None
+    ):
         self.check = check
         if not getattr(check, "conditional", False):
             raise TypeError(
                 "CheckConstraint.check must be a Q instance or boolean expression."
             )
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     def _get_check_sql(self, model, schema_editor):
         query = Query(model=model, alias_cols=False)
@@ -112,15 +127,22 @@ class CheckConstraint(BaseConstraint):
         against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
         try:
             if not Q(self.check).check(against, using=using):
-                raise ValidationError(self.get_violation_error_message())
+                raise ValidationError(
+                    self.get_violation_error_message(), code=self.violation_error_code
+                )
         except FieldError:
             pass
 
     def __repr__(self):
-        return "<%s: check=%s name=%s%s>" % (
+        return "<%s: check=%s name=%s%s%s>" % (
             self.__class__.__qualname__,
             self.check,
             repr(self.name),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -134,6 +156,7 @@ class CheckConstraint(BaseConstraint):
             return (
                 self.name == other.name
                 and self.check == other.check
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
@@ -163,6 +186,7 @@ class UniqueConstraint(BaseConstraint):
         deferrable=None,
         include=None,
         opclasses=(),
+        violation_error_code=None,
         violation_error_message=None,
     ):
         if not name:
@@ -213,7 +237,11 @@ class UniqueConstraint(BaseConstraint):
             F(expression) if isinstance(expression, str) else expression
             for expression in expressions
         )
-        super().__init__(name=name, violation_error_message=violation_error_message)
+        super().__init__(
+            name=name,
+            violation_error_code=violation_error_code,
+            violation_error_message=violation_error_message,
+        )
 
     @property
     def contains_expressions(self):
@@ -293,7 +321,7 @@ class UniqueConstraint(BaseConstraint):
         )
 
     def __repr__(self):
-        return "<%s:%s%s%s%s%s%s%s%s>" % (
+        return "<%s:%s%s%s%s%s%s%s%s%s>" % (
             self.__class__.__qualname__,
             "" if not self.fields else " fields=%s" % repr(self.fields),
             "" if not self.expressions else " expressions=%s" % repr(self.expressions),
@@ -302,6 +330,11 @@ class UniqueConstraint(BaseConstraint):
             "" if self.deferrable is None else " deferrable=%r" % self.deferrable,
             "" if not self.include else " include=%s" % repr(self.include),
             "" if not self.opclasses else " opclasses=%s" % repr(self.opclasses),
+            (
+                ""
+                if self.violation_error_code is None
+                else " violation_error_code=%r" % self.violation_error_code
+            ),
             (
                 ""
                 if self.violation_error_message is None
@@ -320,6 +353,7 @@ class UniqueConstraint(BaseConstraint):
                 and self.include == other.include
                 and self.opclasses == other.opclasses
                 and self.expressions == other.expressions
+                and self.violation_error_code == other.violation_error_code
                 and self.violation_error_message == other.violation_error_message
             )
         return super().__eq__(other)
@@ -385,7 +419,10 @@ class UniqueConstraint(BaseConstraint):
         if not self.condition:
             if queryset.exists():
                 if self.expressions:
-                    raise ValidationError(self.get_violation_error_message())
+                    raise ValidationError(
+                        self.get_violation_error_message(),
+                        code=self.violation_error_code,
+                    )
                 # When fields are defined, use the unique_error_message() for
                 # backward compatibility.
                 for model, constraints in instance.get_constraints():
@@ -400,6 +437,9 @@ class UniqueConstraint(BaseConstraint):
                 if (self.condition & Exists(queryset.filter(self.condition))).check(
                     against, using=using
                 ):
-                    raise ValidationError(self.get_violation_error_message())
+                    raise ValidationError(
+                        self.get_violation_error_message(),
+                        code=self.violation_error_code,
+                    )
             except FieldError:
                 pass
diff --git a/docs/ref/contrib/postgres/constraints.txt b/docs/ref/contrib/postgres/constraints.txt
index fcf50b8b5f..78b96be4a4 100644
--- a/docs/ref/contrib/postgres/constraints.txt
+++ b/docs/ref/contrib/postgres/constraints.txt
@@ -12,7 +12,7 @@ PostgreSQL supports additional data integrity constraints available from the
 ``ExclusionConstraint``
 =======================
 
-.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)
+.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_code=None, violation_error_message=None)
 
     Creates an exclusion constraint in the database. Internally, PostgreSQL
     implements exclusion constraints using indexes. The default index type is
@@ -140,6 +140,13 @@ The error message used when ``ValidationError`` is raised during
 :ref:`model validation <validating-objects>`. Defaults to
 :attr:`.BaseConstraint.violation_error_message`.
 
+``violation_error_code``
+------------------------
+
+The error code used when ``ValidationError`` is raised during
+:ref:`model validation <validating-objects>`. Defaults to
+:attr:`.BaseConstraint.violation_error_code`.
+
 Examples
 --------
 
diff --git a/docs/ref/models/constraints.txt b/docs/ref/models/constraints.txt
index baaacd8754..bb7ec01946 100644
--- a/docs/ref/models/constraints.txt
+++ b/docs/ref/models/constraints.txt
@@ -48,7 +48,7 @@ option.
 ``BaseConstraint``
 ==================
 
-.. class:: BaseConstraint(*, name, violation_error_message=None)
+.. class:: BaseConstraint(*, name, violation_error_code=None, violation_error_message=None)
 
     Base class for all constraints. Subclasses must implement
     ``constraint_sql()``, ``create_sql()``, ``remove_sql()`` and
@@ -77,6 +77,14 @@ The error message used when ``ValidationError`` is raised during
 :ref:`model validation <validating-objects>`. Defaults to
 ``"Constraint “%(name)s” is violated."``.
 
+``violation_error_code``
+------------------------
+
+.. attribute:: BaseConstraint.violation_error_code
+
+The error code used when ``ValidationError`` is raised during
+:ref:`model validation <validating-objects>`. Defaults to ``None``.
+
 ``validate()``
 --------------
 
@@ -94,7 +102,7 @@ This method must be implemented by a subclass.
 ``CheckConstraint``
 ===================
 
-.. class:: CheckConstraint(*, check, name, violation_error_message=None)
+.. class:: CheckConstraint(*, check, name, violation_error_code=None, violation_error_message=None)
 
     Creates a check constraint in the database.
 
@@ -121,7 +129,7 @@ ensures the age field is never less than 18.
 ``UniqueConstraint``
 ====================
 
-.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)
+.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_code=None, violation_error_message=None)
 
     Creates a unique constraint in the database.
 
diff --git a/docs/releases/5.0.txt b/docs/releases/5.0.txt
index 14e767cfd8..44d1fcaedf 100644
--- a/docs/releases/5.0.txt
+++ b/docs/releases/5.0.txt
@@ -178,6 +178,12 @@ Migrations
 Models
 ~~~~~~
 
+* The new ``violation_error_code`` argument of
+  :class:`~django.db.models.BaseConstraint`,
+  :class:`~django.db.models.CheckConstraint`, and
+  :class:`~django.db.models.UniqueConstraint` allows customizing the error code
+  of the ``ValidationError`` raised during model validation.
+
 * The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`
   and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different
   field values for the create operation.
diff --git a/tests/constraints/tests.py b/tests/constraints/tests.py
index b45dc6499a..3208ffb857 100644
--- a/tests/constraints/tests.py
+++ b/tests/constraints/tests.py
@@ -67,6 +67,17 @@ class BaseConstraintTests(SimpleTestCase):
         )
         self.assertEqual(c.get_violation_error_message(), "custom base_name message")
 
+    def test_custom_violation_error_code(self):
+        c = BaseConstraint(name="base_name", violation_error_code="custom_code")
+        self.assertEqual(c.violation_error_code, "custom_code")
+
+    def test_custom_violation_error_code_clone(self):
+        constraint = BaseConstraint(
+            name="base_name",
+            violation_error_code="custom_code",
+        ).clone()
+        self.assertEqual(constraint.violation_error_code, "custom_code")
+
     def test_custom_violation_error_message_clone(self):
         constraint = BaseConstraint(
             name="base_name",
@@ -80,6 +91,7 @@ class BaseConstraintTests(SimpleTestCase):
     def test_deconstruction(self):
         constraint = BaseConstraint(
             name="base_name",
+            violation_error_code="custom_code",
             violation_error_message="custom %(name)s message",
         )
         path, args, kwargs = constraint.deconstruct()
@@ -87,7 +99,11 @@ class BaseConstraintTests(SimpleTestCase):
         self.assertEqual(args, ())
         self.assertEqual(
             kwargs,
-            {"name": "base_name", "violation_error_message": "custom %(name)s message"},
+            {
+                "name": "base_name",
+                "violation_error_code": "custom_code",
+                "violation_error_message": "custom %(name)s message",
+            },
         )
 
     def test_deprecation(self):
@@ -172,6 +188,18 @@ class CheckConstraintTests(TestCase):
             "violation_error_message='More than 1'>",
         )
 
+    def test_repr_with_violation_error_code(self):
+        constraint = models.CheckConstraint(
+            check=models.Q(price__lt=1),
+            name="price_lt_one",
+            violation_error_code="more_than_one",
+        )
+        self.assertEqual(
+            repr(constraint),
+            "<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' "
+            "violation_error_code='more_than_one'>",
+        )
+
     def test_invalid_check_types(self):
         msg = "CheckConstraint.check must be a Q instance or boolean expression."
         with self.assertRaisesMessage(TypeError, msg):
@@ -251,6 +279,16 @@ class CheckConstraintTests(TestCase):
         constraint.validate(Product, Product(price=501, discounted_price=5))
         constraint.validate(Product, Product(price=499, discounted_price=5))
 
+    def test_validate_custom_error_code(self):
+        constraint = models.CheckConstraint(
+            check=models.Q(price__gt=models.F("discounted_price")),
+            name="price_gt_discounted_price",
+            violation_error_code="invalid_price",
+        )
+        with self.assertRaises(ValidationError) as cm:
+            constraint.validate(Product, Product(price=10, discounted_price=42))
+        self.assertEqual(cm.exception.code, "invalid_price")
+
     def test_validate_rawsql_expressions_noop(self):
         constraint = models.CheckConstraint(
             check=models.expressions.RawSQL(
@@ -737,6 +775,19 @@ class UniqueConstraintTests(TestCase):
             exclude={"name"},
         )
 
+    def test_validate_expression_custom_error_code(self):
+        constraint = models.UniqueConstraint(
+            Lower("name"),
+            name="name_lower_uniq",
+            violation_error_code="duplicate_name",
+        )
+        with self.assertRaises(ValidationError) as cm:
+            constraint.validate(
+                UniqueConstraintProduct,
+                UniqueConstraintProduct(name=self.p1.name.upper()),
+            )
+        self.assertEqual(cm.exception.code, "duplicate_name")
+
     def test_validate_ordered_expression(self):
         constraint = models.UniqueConstraint(
             Lower("name").desc(), name="name_lower_uniq_desc"
diff --git a/tests/postgres_tests/test_constraints.py b/tests/postgres_tests/test_constraints.py
index a5248e1491..c296812f64 100644
--- a/tests/postgres_tests/test_constraints.py
+++ b/tests/postgres_tests/test_constraints.py
@@ -397,6 +397,17 @@ class ExclusionConstraintTests(PostgreSQLTestCase):
             "(F(datespan), '-|-')] name='exclude_overlapping' "
             "violation_error_message='Overlapping must be excluded'>",
         )
+        constraint = ExclusionConstraint(
+            name="exclude_overlapping",
+            expressions=[(F("datespan"), RangeOperators.ADJACENT_TO)],
+            violation_error_code="overlapping",
+        )
+        self.assertEqual(
+            repr(constraint),
+            "<ExclusionConstraint: index_type='GIST' expressions=["
+            "(F(datespan), '-|-')] name='exclude_overlapping' "
+            "violation_error_code='overlapping'>",
+        )
 
     def test_eq(self):
         constraint_1 = ExclusionConstraint(
@@ -771,6 +782,16 @@ class ExclusionConstraintTests(PostgreSQLTestCase):
         constraint.validate(RangesModel, RangesModel(ints=(51, 60)))
         constraint.validate(RangesModel, RangesModel(ints=(10, 20)), exclude={"ints"})
 
+    def test_validate_custom_error_code(self):
+        constraint = ExclusionConstraint(
+            name="ints_adjacent",
+            expressions=[("ints", RangeOperators.ADJACENT_TO)],
+            violation_error_code="adjacent_ints",
+        )
+        with self.assertRaises(ValidationError) as cm:
+            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))
+        self.assertEqual(cm.exception.code, "adjacent_ints")
+
     def test_expressions_with_params(self):
         constraint_name = "scene_left_equal"
         self.assertNotIn(constraint_name, self.get_constraints(Scene._meta.db_table))
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
check: ./tests/runtests.py constraints
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 78 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
...........................s.......................sss........................
----------------------------------------------------------------------
Ran 78 tests in 0.108s

OK (skipped=4)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/models/constraints.py tests/constraints docs/ref/models/constraints.txt
OUTSIDE THE SCOPE: django/contrib/postgres/constraints.py +19 -4 (undo it: git checkout the file, or delete it when the run made it)
changed: django/db/models/constraints.py +50 -10
OUTSIDE THE SCOPE: docs/ref/contrib/postgres/constraints.txt +8 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: docs/ref/models/constraints.txt +11 -3
OUTSIDE THE SCOPE: docs/releases/5.0.txt +6 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/constraints/tests.py +52 -1
OUTSIDE THE SCOPE: tests/postgres_tests/test_constraints.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `final-status.txt`

```
0
```

### `head.txt`

```
main
```

### `keep.txt`

```
kept: the direct attempt, untouched
```

### `notes.md`

```
# Notes, run 2026-11-06T112651

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Allow to customize the code attribute of ValidationError raised by BaseConstraint.validate
Description
	
It is currently possible to customize the violation_error_message of a ValidationError raised by a constraint but not the code.
I'd like to add a new violation_error_message parameter to BaseConstraint to allow to easily add one.
Currently, to achieve the same result, you have to subclass the constraint to tweak validate to catch and reraise the ValidationError.
Since the documentation recommends to Provide a descriptive error code to the constructor: when raising a ValidationError in ​https://docs.djangoproject.com/en/4.1/ref/forms/validation/#raising-validationerror , I think it would make sense to provide this possibility for errors raised by constraints.
If you think it would be a good idea, I'd be happy to work on a PR.


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.git-blame-ignore-revs
.gitattributes
.github/CODE_OF_CONDUCT.md
.github/FUNDING.yml
.github/SECURITY.md
.github/workflows/benchmark.yml
.github/workflows/docs.yml
.github/workflows/linters.yml
.github/workflows/new_contributor_pr.yml
.github/workflows/schedule_tests.yml
.github/workflows/schedules.yml
.github/workflows/tests.yml
.gitignore
.pre-commit-config.yaml
.readthedocs.yml
.tx/config
AUTHORS
CONTRIBUTING.rst
Gruntfile.js
INSTALL
LICENSE
LICENSE.python
MANIFEST.in
README.rst
django/__init__.py
django/__main__.py
django/apps/__init__.py
django/apps/config.py
django/apps/registry.py
django/conf/__init__.py
django/conf/app_template/__init__.py-tpl
django/conf/app_template/admin.py-tpl
django/conf/app_template/apps.py-tpl
django/conf/app_template/migrations/__init__.py-tpl
django/conf/app_template/models.py-tpl
django/conf/app_template/tests.py-tpl
django/conf/app_template/views.py-tpl
django/conf/global_settings.py
django/conf/locale/__init__.py
django/conf/locale/af/LC_MESSAGES/django.mo
django/conf/locale/af/LC_MESSAGES/django.po
django/conf/locale/ar/LC_MESSAGES/django.mo
django/conf/locale/ar/LC_MESSAGES/django.po
django/conf/locale/ar/__init__.py
django/conf/locale/ar/formats.py
django/conf/locale/ar_DZ/LC_MESSAGES/django.mo
django/conf/locale/ar_DZ/LC_MESSAGES/django.po
django/conf/locale/ar_DZ/__init__.py
django/conf/locale/ar_DZ/formats.py
django/conf/locale/ast/LC_MESSAGES/django.mo
django/conf/locale/ast/LC_MESSAGES/django.po
django/conf/locale/az/LC_MESSAGES/django.mo
django/conf/locale/az/LC_MESSAGES/django.po
django/conf/locale/az/__init__.py
django/conf/locale/az/formats.py
django/conf/locale/be/LC_MESSAGES/django.mo
django/conf/locale/be/LC_MESSAGES/django.po
django/conf/locale/bg/LC_MESSAGES/django.mo
django/conf/locale/bg/LC_MESSAGES/django.po
django/conf/locale/bg/__init__.py
django/conf/locale/bg/formats.py
django/conf/locale/bn/LC_MESSAGES/django.mo
django/conf/locale/bn/LC_MESSAGES/django.po
django/conf/locale/bn/__init__.py
django/conf/locale/bn/formats.py
django/conf/locale/br/LC_MESSAGES/django.mo
django/conf/locale/br/LC_MESSAGES/django.po
django/conf/locale/bs/LC_MESSAGES/django.mo
django/conf/locale/bs/LC_MESSAGES/django.po
django/conf/locale/bs/__init__.py
django/conf/locale/bs/formats.py
django/conf/locale/ca/LC_MESSAGES/django.mo
django/conf/locale/ca/LC_MESSAGES/django.po
django/conf/locale/ca/__init__.py
django/conf/locale/ca/formats.py
django/conf/locale/ckb/__init__.py
django/conf/locale/ckb/formats.py
django/conf/locale/cs/LC_MESSAGES/django.mo
django/conf/locale/cs/LC_MESSAGES/django.po
django/conf/locale/cs/__init__.py
django/conf/locale/cs/formats.py
django/conf/locale/cy/LC_MESSAGES/django.mo
django/conf/locale/cy/LC_MESSAGES/django.po
django/conf/locale/cy/__init__.py
django/conf/locale/cy/formats.py
django/conf/locale/da/LC_MESSAGES/django.mo
django/conf/locale/da/LC_MESSAGES/django.po
django/conf/locale/da/__init__.py
django/conf/locale/da/formats.py
django/conf/locale/de/LC_MESSAGES/django.mo
django/conf/locale/de/LC_MESSAGES/django.po
django/conf/locale/de/__init__.py
django/conf/locale/de/formats.py
django/conf/locale/de_CH/__init__.py
django/conf/locale/de_CH/formats.py
django/conf/locale/dsb/LC_MESSAGES/django.mo
django/conf/locale/dsb/LC_MESSAGES/django.po
django/conf/locale/el/LC_MESSAGES/django.mo
django/conf/locale/el/LC_MESSAGES/django.po
django/conf/locale/el/__init__.py
django/conf/locale/el/formats.py
django/conf/locale/en/LC_MESSAGES/django.mo
django/conf/locale/en/LC_MESSAGES/django.po
django/conf/locale/en/__init__.py
django/conf/locale/en/formats.py
django/conf/locale/en_AU/LC_MESSAGES/django.mo
django/conf/locale/en_AU/LC_MESSAGES/django.po
django/conf/locale/en_AU/__init__.py
django/conf/locale/en_AU/formats.py
django/conf/locale/en_GB/LC_MESSAGES/django.mo
django/conf/locale/en_GB/LC_MESSAGES/django.po
django/conf/locale/en_GB/__init__.py
django/conf/locale/en_GB/formats.py
django/conf/locale/eo/LC_MESSAGES/django.mo
django/conf/locale/eo/LC_MESSAGES/django.po
django/conf/locale/eo/__init__.py
django/conf/locale/eo/formats.py
django/conf/locale/es/LC_MESSAGES/django.mo
django/conf/locale/es/LC_MESSAGES/django.po
django/conf/locale/es/__init__.py
django/conf/locale/es/formats.py
django/conf/locale/es_AR/LC_MESSAGES/django.mo
django/conf/locale/es_AR/LC_MESSAGES/django.po
django/conf/locale/es_AR/__init__.py
django/conf/locale/es_AR/formats.py
django/conf/locale/es_CO/LC_MESSAGES/django.mo
django/conf/locale/es_CO/LC_MESSAGES/django.po
django/conf/locale/es_CO/__init__.py
django/conf/locale/es_CO/formats.py
django/conf/locale/es_MX/LC_MESSAGES/django.mo
django/conf/locale/es_MX/LC_MESSAGES/django.po
django/conf/locale/es_MX/__init__.py
django/conf/locale/es_MX/formats.py
django/conf/locale/es_NI/__init__.py
django/conf/locale/es_NI/formats.py
django/conf/locale/es_PR/__init__.py
django/conf/locale/es_PR/formats.py
django/conf/locale/es_VE/LC_MESSAGES/django.mo
django/conf/locale/es_VE/LC_MESSAGES/django.po
django/conf/locale/et/LC_MESSAGES/django.mo
django/conf/locale/et/LC_MESSAGES/django.po
django/conf/locale/et/__init__.py
django/conf/locale/et/formats.py
django/conf/locale/eu/LC_MESSAGES/django.mo
django/conf/locale/eu/LC_MESSAGES/django.po
django/conf/locale/eu/__init__.py
django/conf/locale/eu/formats.py
django/conf/locale/fa/LC_MESSAGES/django.mo
django/conf/locale/fa/LC_MESSAGES/django.po
django/conf/locale/fa/__init__.py
django/conf/locale/fa/formats.py
django/conf/locale/fi/LC_MESSAGES/django.mo
django/conf/locale/fi/LC_MESSAGES/django.po
django/conf/locale/fi/__init__.py
django/conf/locale/fi/formats.py
django/conf/locale/fr/LC_MESSAGES/django.mo
django/conf/locale/fr/LC_MESSAGES/django.po
django/conf/locale/fr/__init__.py
django/conf/locale/fr/formats.py
django/conf/locale/fy/LC_MESSAGES/django.mo
django/conf/locale/fy/LC_MESSAGES/django.po
django/conf/locale/fy/__init__.py
django/conf/locale/fy/formats.py
django/conf/locale/ga/LC_MESSAGES/django.mo
django/conf/locale/ga/LC_MESSAGES/django.po
django/conf/locale/ga/__init__.py
django/conf/locale/ga/formats.py
django/conf/locale/gd/LC_MESSAGES/django.mo
django/conf/locale/gd/LC_MESSAGES/django.po
django/conf/locale/gd/__init__.py
django/conf/locale/gd/formats.py
django/conf/locale/gl/LC_MESSAGES/django.mo
django/conf/locale/gl/LC_MESSAGES/django.po
django/conf/locale/gl/__init__.py
django/conf/locale/gl/formats.py
django/conf/locale/he/LC_MESSAGES/django.mo
django/conf/locale/he/LC_MESSAGES/django.po
django/conf/locale/he/__init__.py
django/conf/locale/he/formats.py
django/conf/locale/hi/LC_MESSAGES/django.mo
django/conf/locale/hi/LC_MESSAGES/django.po
django/conf/locale/hi/__init__.py
django/conf/locale/hi/formats.py
django/conf/locale/hr/LC_MESSAGES/django.mo
django/conf/locale/hr/LC_MESSAGES/django.po
django/conf/locale/hr/__init__.py
django/conf/locale/hr/formats.py
django/conf/locale/hsb/LC_MESSAGES/django.mo
django/conf/locale/hsb/LC_MESSAGES/django.po
django/conf/locale/hu/LC_MESSAGES/django.mo
django/conf/locale/hu/LC_MESSAGES/django.po
django/conf/locale/hu/__init__.py
django/conf/locale/hu/formats.py
django/conf/locale/hy/LC_MESSAGES/django.mo
django/conf/locale/hy/LC_MESSAGES/django.po
django/conf/locale/ia/LC_MESSAGES/django.mo
django/conf/locale/ia/LC_MESSAGES/django.po
django/conf/locale/id/LC_MESSAGES/django.mo
django/conf/locale/id/LC_MESSAGES/django.po
django/conf/locale/id/__init__.py
django/conf/locale/id/formats.py
django/conf/locale/ig/LC_MESSAGES/django.mo
django/conf/locale/ig/LC_MESSAGES/django.po
django/conf/locale/ig/__init__.py
django/conf/locale/ig/formats.py
django/conf/locale/io/LC_MESSAGES/django.mo
django/conf/locale/io/LC_MESSAGES/django.po
django/conf/locale/is/LC_MESSAGES/django.mo
django/conf/locale/is/LC_MESSAGES/django.po
django/conf/locale/is/__init__.py
django/conf/locale/is/formats.py
django/conf/locale/it/LC_MESSAGES/django.mo
django/conf/locale/it/LC_MESSAGES/django.po
django/conf/locale/it/__init__.py
django/conf/locale/it/formats.py
django/conf/locale/ja/LC_MESSAGES/django.mo
django/conf/locale/ja/LC_MESSAGES/django.po
django/conf/locale/ja/__init__.py
django/conf/locale/ja/formats.py
django/conf/locale/ka/LC_MESSAGES/django.mo
django/conf/locale/ka/LC_MESSAGES/django.po
django/conf/locale/ka/__init__.py
django/conf/locale/ka/formats.py
django/conf/locale/kab/LC_MESSAGES/django.mo
django/conf/locale/kab/LC_MESSAGES/django.po
django/conf/locale/kk/LC_MESSAGES/django.mo
django/conf/locale/kk/LC_MESSAGES/django.po
django/conf/locale/km/LC_MESSAGES/django.mo
django/conf/locale/km/LC_MESSAGES/django.po
django/conf/locale/km/__init__.py
django/conf/locale/km/formats.py
django/conf/locale/kn/LC_MESSAGES/django.mo
django/conf/locale/kn/LC_MESSAGES/django.po
django/conf/locale/kn/__init__.py
django/conf/locale/kn/formats.py
django/conf/locale/ko/LC_MESSAGES/django.mo
django/conf/locale/ko/LC_MESSAGES/django.po
django/conf/locale/ko/__init__.py
django/conf/locale/ko/formats.py
django/conf/locale/ky/LC_MESSAGES/django.mo
django/conf/locale/ky/LC_MESSAGES/django.po
django/conf/locale/ky/__init__.py
django/conf/locale/ky/formats.py
django/conf/locale/lb/LC_MESSAGES/django.mo
django/conf/locale/lb/LC_MESSAGES/django.po
django/conf/locale/lt/LC_MESSAGES/django.mo
django/conf/locale/lt/LC_MESSAGES/django.po
django/conf/locale/lt/__init__.py
django/conf/locale/lt/formats.py
django/conf/locale/lv/LC_MESSAGES/django.mo
django/conf/locale/lv/LC_MESSAGES/django.po
django/conf/locale/lv/__init__.py
django/conf/locale/lv/formats.py
django/conf/locale/mk/LC_MESSAGES/django.mo
django/conf/locale/mk/LC_MESSAGES/django.po
django/conf/locale/mk/__init__.py
django/conf/locale/mk/formats.py
django/conf/locale/ml/LC_MESSAGES/django.mo
django/conf/locale/ml/LC_MESSAGES/django.po
django/conf/locale/ml/__init__.py
django/conf/locale/ml/formats.py
django/conf/locale/mn/LC_MESSAGES/django.mo
django/conf/locale/mn/LC_MESSAGES/django.po
django/conf/locale/mn/__init__.py
django/conf/locale/mn/formats.py
django/conf/locale/mr/LC_MESSAGES/django.mo
django/conf/locale/mr/LC_MESSAGES/django.po
django/conf/locale/ms/LC_MESSAGES/django.mo
django/conf/locale/ms/LC_MESSAGES/django.po
django/conf/locale/ms/__init__.py
django/conf/locale/ms/formats.py
django/conf/locale/my/LC_MESSAGES/django.mo
django/conf/locale/my/LC_MESSAGES/django.po
django/conf/locale/nb/LC_MESSAGES/django.mo
django/conf/locale/nb/LC_MESSAGES/django.po
django/conf/locale/nb/__init__.py
django/conf/locale/nb/formats.py
django/conf/locale/ne/LC_MESSAGES/django.mo
django/conf/locale/ne/LC_MESSAGES/django.po
django/conf/locale/nl/LC_MESSAGES/django.mo
django/conf/locale/nl/LC_MESSAGES/django.po
django/conf/locale/nl/__init__.py
django/conf/locale/nl/formats.py
django/conf/locale/nn/LC_MESSAGES/django.mo
django/conf/locale/nn/LC_MESSAGES/django.po
django/conf/locale/nn/__init__.py
django/conf/locale/nn/formats.py
django/conf/locale/os/LC_MESSAGES/django.mo
django/conf/locale/os/LC_MESSAGES/django.po
django/conf/locale/pa/LC_MESSAGES/django.mo
django/conf/locale/pa/LC_MESSAGES/django.po
django/conf/locale/pl/LC_MESSAGES/django.mo
django/conf/locale/pl/LC_MESSAGES/django.po
django/conf/locale/pl/__init__.py
django/conf/locale/pl/formats.py
django/conf/locale/pt/LC_MESSAGES/django.mo
django/conf/locale/pt/LC_MESSAGES/django.po
django/conf/locale/pt/__init__.py
django/conf/locale/pt/formats.py
django/conf/locale/pt_BR/LC_MESSAGES/django.mo
django/conf/locale/pt_BR/LC_MESSAGES/django.po
django/conf/locale/pt_BR/__init__.py
django/conf/locale/pt_BR/formats.py
django/conf/locale/ro/LC_MESSAGES/django.mo
django/conf/locale/ro/LC_MESSAGES/django.po
django/conf/locale/ro/__init__.py
django/conf/locale/ro/formats.py
django/conf/locale/ru/LC_MESSAGES/django.mo
django/conf/locale/ru/LC_MESSAGES/django.po
django/conf/locale/ru/__init__.py
django/conf/locale/ru/formats.py
django/conf/locale/sk/LC_MESSAGES/django.mo
django/conf/locale/sk/LC_MESSAGES/django.po
django/conf/locale/sk/__init__.py
django/conf/locale/sk/formats.py
django/conf/locale/sl/LC_MESSAGES/django.mo
django/conf/locale/sl/LC_MESSAGES/django.po
django/conf/locale/sl/__init__.py
django/conf/locale/sl/formats.py
django/conf/locale/sq/LC_MESSAGES/django.mo
django/conf/locale/sq/LC_MESSAGES/django.po
django/conf/locale/sq/__init__.py
django/conf/locale/sq/formats.py
django/conf/locale/sr/LC_MESSAGES/django.mo
django/conf/locale/sr/LC_MESSAGES/django.po
django/conf/locale/sr/__init__.py
django/conf/locale/sr/formats.py
django/conf/locale/sr_Latn/LC_MESSAGES/django.mo
django/conf/locale/sr_Latn/LC_MESSAGES/django.po
django/conf/locale/sr_Latn/__init__.py
django/conf/locale/sr_Latn/formats.py
django/conf/locale/sv/LC_MESSAGES/django.mo
django/conf/locale/sv/LC_MESSAGES/django.po
django/conf/locale/sv/__init__.py
django/conf/locale/sv/formats.py
django/conf/locale/sw/LC_MESSAGES/django.mo
django/conf/locale/sw/LC_MESSAGES/django.po
django/conf/locale/ta/LC_MESSAGES/django.mo
django/conf/locale/ta/LC_MESSAGES/django.po
django/conf/locale/ta/__init__.py
django/conf/locale/ta/formats.py
django/conf/locale/te/LC_MESSAGES/django.mo
django/conf/locale/te/LC_MESSAGES/django.po
django/conf/locale/te/__init__.py
django/conf/locale/te/formats.py
django/conf/locale/tg/LC_MESSAGES/django.mo
django/conf/locale/tg/LC_MESSAGES/django.po
django/conf/locale/tg/__init__.py
django/conf/locale/tg/formats.py
django/conf/locale/th/LC_MESSAGES/django.mo
django/conf/locale/th/LC_MESSAGES/django.po
django/conf/locale/th/__init__.py
django/conf/locale/th/formats.py
django/conf/locale/tk/LC_MESSAGES/django.mo
django/conf/locale/tk/LC_MESSAGES/django.po
django/conf/locale/tk/__init__.py
django/conf/locale/tk/formats.py
django/conf/locale/tr/LC_MESSAGES/django.mo
django/conf/locale/tr/LC_MESSAGES/django.po
django/conf/locale/tr/__init__.py
django/conf/locale/tr/formats.py
django/conf/locale/tt/LC_MESSAGES/django.mo
django/conf/locale/tt/LC_MESSAGES/django.po
django/conf/locale/udm/LC_MESSAGES/django.mo
django/conf/locale/udm/LC_MESSAGES/django.po
django/conf/locale/uk/LC_MESSAGES/django.mo
django/conf/locale/uk/LC_MESSAGES/django.po
django/conf/locale/uk/__init__.py
django/conf/locale/uk/formats.py
django/conf/locale/ur/LC_MESSAGES/django.mo
django/conf/locale/ur/LC_MESSAGES/django.po
django/conf/locale/uz/LC_MESSAGES/django.mo
django/conf/locale/uz/LC_MESSAGES/django.po
django/conf/locale/uz/__init__.py
django/conf/locale/uz/formats.py
django/conf/locale/vi/LC_MESSAGES/django.mo
django/conf/locale/vi/LC_MESSAGES/django.po
django/conf/locale/vi/__init__.py
django/conf/locale/vi/formats.py
django/conf/locale/zh_Hans/LC_MESSAGES/django.mo
django/conf/locale/zh_Hans/LC_MESSAGES/django.po
django/conf/locale/zh_Hans/__init__.py
django/conf/locale/zh_Hans/formats.py
django/conf/locale/zh_Hant/LC_MESSAGES/django.mo
django/conf/locale/zh_Hant/LC_MESSAGES/django.po
django/conf/locale/zh_Hant/__init__.py
django/conf/locale/zh_Hant/formats.py
django/conf/project_template/manage.py-tpl
django/conf/project_template/project_name/__init__.py-tpl
django/conf/project_template/project_name/asgi.py-tpl
django/conf/project_template/project_name/settings.py-tpl
django/conf/project_template/project_name/urls.py-tpl
django/conf/project_template/project_name/wsgi.py-tpl
django/conf/urls/__init__.py
django/conf/urls/i18n.py
django/conf/urls/static.py
django/contrib/__init__.py
django/contrib/admin/__init__.py
django/contrib/admin/actions.py
django/contrib/admin/apps.py
django/contrib/admin/checks.py
django/contrib/admin/decorators.py
django/contrib/admin/exceptions.py
django/contrib/admin/filters.py
django/contrib/admin/forms.py
django/contrib/admin/helpers.py
django/contrib/admin/locale/af/LC_MESSAGES/django.mo
django/contrib/admin/locale/af/LC_MESSAGES/django.po
django/contrib/admin/locale/af/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/af/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/am/LC_MESSAGES/django.mo
django/contrib/admin/locale/am/LC_MESSAGES/django.po
django/contrib/admin/locale/ar/LC_MESSAGES/django.mo
django/contrib/admin/locale/ar/LC_MESSAGES/django.po
django/contrib/admin/locale/ar/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ar/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/django.mo
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/django.po
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ast/LC_MESSAGES/django.mo
django/contrib/admin/locale/ast/LC_MESSAGES/django.po
django/contrib/admin/locale/ast/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ast/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/az/LC_MESSAGES/django.mo
django/contrib/admin/locale/az/LC_MESSAGES/django.po
django/contrib/admin/locale/az/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/az/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/be/LC_MESSAGES/django.mo
django/contrib/admin/locale/be/LC_MESSAGES/django.po
django/contrib/admin/locale/be/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/be/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/bg/LC_MESSAGES/django.mo
django/contrib/admin/locale/bg/LC_MESSAGES/django.po
django/contrib/admin/locale/bg/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/bg/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/bn/LC_MESSAGES/django.mo
django/contrib/admin/locale/bn/LC_MESSAGES/django.po
django/contrib/admin/locale/bn/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/bn/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/br/LC_MESSAGES/django.mo
django/contrib/admin/locale/br/LC_MESSAGES/django.po
django/contrib/admin/locale/br/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/br/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/bs/LC_MESSAGES/django.mo
django/contrib/admin/locale/bs/LC_MESSAGES/django.po
django/contrib/admin/locale/bs/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/bs/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ca/LC_MESSAGES/django.mo
django/contrib/admin/locale/ca/LC_MESSAGES/django.po
django/contrib/admin/locale/ca/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ca/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/cs/LC_MESSAGES/django.mo
django/contrib/admin/locale/cs/LC_MESSAGES/django.po
django/contrib/admin/locale/cs/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/cs/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/cy/LC_MESSAGES/django.mo
django/contrib/admin/locale/cy/LC_MESSAGES/django.po
django/contrib/admin/locale/cy/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/cy/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/da/LC_MESSAGES/django.mo
django/contrib/admin/locale/da/LC_MESSAGES/django.po
django/contrib/admin/locale/da/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/da/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/de/LC_MESSAGES/django.mo
django/contrib/admin/locale/de/LC_MESSAGES/django.po
django/contrib/admin/locale/de/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/de/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/dsb/LC_MESSAGES/django.mo
django/contrib/admin/locale/dsb/LC_MESSAGES/django.po
django/contrib/admin/locale/dsb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/dsb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/el/LC_MESSAGES/django.mo
django/contrib/admin/locale/el/LC_MESSAGES/django.po
django/contrib/admin/locale/el/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/el/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/en/LC_MESSAGES/django.mo
django/contrib/admin/locale/en/LC_MESSAGES/django.po
django/contrib/admin/locale/en/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/en/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/en_AU/LC_MESSAGES/django.mo
django/contrib/admin/locale/en_AU/LC_MESSAGES/django.po
django/contrib/admin/locale/en_AU/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/en_AU/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/en_GB/LC_MESSAGES/django.mo
django/contrib/admin/locale/en_GB/LC_MESSAGES/django.po
django/contrib/admin/locale/en_GB/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/en_GB/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/eo/LC_MESSAGES/django.mo
django/contrib/admin/locale/eo/LC_MESSAGES/django.po
django/contrib/admin/locale/eo/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/eo/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es/LC_MESSAGES/django.mo
django/contrib/admin/locale/es/LC_MESSAGES/django.po
django/contrib/admin/locale/es/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_AR/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_AR/LC_MESSAGES/django.po
django/contrib/admin/locale/es_AR/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_AR/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_CO/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_CO/LC_MESSAGES/django.po
django/contrib/admin/locale/es_CO/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_CO/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_MX/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_MX/LC_MESSAGES/django.po
django/contrib/admin/locale/es_MX/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_MX/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_VE/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_VE/LC_MESSAGES/django.po
django/contrib/admin/locale/es_VE/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_VE/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/et/LC_MESSAGES/django.mo
django/contrib/admin/locale/et/LC_MESSAGES/django.po
django/contrib/admin/locale/et/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/et/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/eu/LC_MESSAGES/django.mo
django/contrib/admin/locale/eu/LC_MESSAGES/django.po
django/contrib/admin/locale/eu/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/eu/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fa/LC_MESSAGES/django.mo
django/contrib/admin/locale/fa/LC_MESSAGES/django.po
django/contrib/admin/locale/fa/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fa/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fi/LC_MESSAGES/django.mo
django/contrib/admin/locale/fi/LC_MESSAGES/django.po
django/contrib/admin/locale/fi/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fi/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fr/LC_MESSAGES/django.mo
django/contrib/admin/locale/fr/LC_MESSAGES/django.po
django/contrib/admin/locale/fr/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fr/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fy/LC_MESSAGES/django.mo
django/contrib/admin/locale/fy/LC_MESSAGES/django.po
django/contrib/admin/locale/fy/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fy/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ga/LC_MESSAGES/django.mo
django/contrib/admin/locale/ga/LC_MESSAGES/django.po
django/contrib/admin/locale/ga/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ga/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/gd/LC_MESSAGES/django.mo
django/contrib/admin/locale/gd/LC_MESSAGES/django.po
django/contrib/admin/locale/gd/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/gd/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/gl/LC_MESSAGES/django.mo
django/contrib/admin/locale/gl/LC_MESSAGES/django.po
django/contrib/admin/locale/gl/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/gl/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/he/LC_MESSAGES/django.mo
django/contrib/admin/locale/he/LC_MESSAGES/django.po
django/contrib/admin/locale/he/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/he/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hi/LC_MESSAGES/django.mo
django/contrib/admin/locale/hi/LC_MESSAGES/django.po
django/contrib/admin/locale/hi/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hi/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hr/LC_MESSAGES/django.mo
django/contrib/admin/locale/hr/LC_MESSAGES/django.po
django/contrib/admin/locale/hr/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hr/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hsb/LC_MESSAGES/django.mo
django/contrib/admin/locale/hsb/LC_MESSAGES/django.po
django/contrib/admin/locale/hsb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hsb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hu/LC_MESSAGES/django.mo
django/contrib/admin/locale/hu/LC_MESSAGES/django.po
django/contrib/admin/locale/hu/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hu/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hy/LC_MESSAGES/django.mo
django/contrib/admin/locale/hy/LC_MESSAGES/django.po
django/contrib/admin/locale/hy/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hy/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ia/LC_MESSAGES/django.mo
django/contrib/admin/locale/ia/LC_MESSAGES/django.po
django/contrib/admin/locale/ia/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ia/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/id/LC_MESSAGES/django.mo
django/contrib/admin/locale/id/LC_MESSAGES/django.po
django/contrib/admin/locale/id/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/id/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/io/LC_MESSAGES/django.mo
django/contrib/admin/locale/io/LC_MESSAGES/django.po
django/contrib/admin/locale/io/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/io/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/is/LC_MESSAGES/django.mo
django/contrib/admin/locale/is/LC_MESSAGES/django.po
django/contrib/admin/locale/is/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/is/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/it/LC_MESSAGES/django.mo
django/contrib/admin/locale/it/LC_MESSAGES/django.po
django/contrib/admin/locale/it/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/it/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ja/LC_MESSAGES/django.mo
django/contrib/admin/locale/ja/LC_MESSAGES/django.po
django/contrib/admin/locale/ja/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ja/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ka/LC_MESSAGES/django.mo
```


# The last commit

```
becf6f8b61 SWE-bench


```

```diff

```


# package.json (the start)

```
{
  "name": "Django",
  "private": true,
  "scripts": {
    "pretest": "eslint .",
    "test": "grunt test --verbose"
  },
  "engines": {
    "npm": ">=1.3.0"
  },
  "devDependencies": {
    "eslint": "^8.34.0",
    "puppeteer": "^19.7.0",
    "grunt": "^1.6.1",
    "grunt-cli": "^1.4.3",
    "grunt-contrib-qunit": "^7.0.0",
    "qunit": "^2.19.4"
  }
}

```


# pyproject.toml (the start)

```
[build-system]
requires = ['setuptools>=40.8.0']
build-backend = 'setuptools.build_meta'

[tool.black]
target-version = ['py38']
force-exclude = 'tests/test_runner_apps/tagged/tests_syntax_error.py'

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`./tests/runtests.py constraints`

## Scope
`django/db/models/constraints.py`
`tests/constraints/`
`docs/ref/models/constraints.txt`

## Done when
- `BaseConstraint` accepts a `violation_error_code` keyword argument and stores it, defaulting to `None`.
- `CheckConstraint` and `UniqueConstraint` accept and forward `violation_error_code` to `BaseConstraint`.
- A constraint validation failure raises `ValidationError` with `code` equal to the configured `violation_error_code`.
- When `violation_error_code` is unset, the raised `ValidationError.code` remains `"constraint"`.
- `(inferred)` `deconstruct()` includes `violation_error_code` when it is not `None`, so migrations preserve it.
- `(inferred)` constraint equality accounts for `violation_error_code`.

## Approach
Decompose into: add the option to `BaseConstraint`; thread it through `CheckConstraint` and `UniqueConstraint`; apply it to the `ValidationError` raised during validation; serialize it in `deconstruct()`; update equality; add focused tests in `tests/constraints/`; document the new argument.

Candidate approaches:
1. Central rewrite in `BaseConstraint._check()`: catch `ValidationError`, and when its code is the default `"constraint"`, replace it with `self.violation_error_code or "constraint"`. This keeps subclass `validate()` methods unchanged and avoids duplication.
2. Pass the code directly in each subclass `validate()` call: `code=self.violation_error_code or "constraint"`. This is explicit but duplicates logic across `CheckConstraint` and `UniqueConstraint`.
3. Add the option only to subclasses without `BaseConstraint`. This is less consistent and does not satisfy the request to customize errors raised by `BaseConstraint.validate`.

Prefer approach 1, with `deconstruct()` and equality updated so migrations and model state remain correct.
```

### `prompt.md`

```
Allow to customize the code attribute of ValidationError raised by BaseConstraint.validate
Description
	
It is currently possible to customize the violation_error_message of a ValidationError raised by a constraint but not the code.
I'd like to add a new violation_error_message parameter to BaseConstraint to allow to easily add one.
Currently, to achieve the same result, you have to subclass the constraint to tweak validate to catch and reraise the ValidationError.
Since the documentation recommends to Provide a descriptive error code to the constructor: when raising a ValidationError in ​https://docs.djangoproject.com/en/4.1/ref/forms/validation/#raising-validationerror , I think it would make sense to provide this possibility for errors raised by constraints.
If you think it would be a good idea, I'd be happy to work on a PR.
```

### `review.md`

```
verdict: PASS
- `BaseConstraint` accepts and stores `violation_error_code` (default `None`), and `deconstruct()`, equality, and repr account for it.
- `CheckConstraint` and `UniqueConstraint` accept and forward `violation_error_code`; validation raises `ValidationError` with the configured code on the covered paths.
- The constraints test run is green: 78 tests, OK (4 skipped).
- The PostgreSQL `ExclusionConstraint`, related docs, and release-note changes are outside the stated scope but are a related sibling implementation of the same feature, not an unrelated change; they do not block.
- Note: the Done-when wording about the unset code remaining `"constraint"` does not match this tree’s pre-existing behavior, where unset passes `None`; this is a note, not a failure, since the Prompt only asks for customization.
```

### `scope.txt`

```
scope: django/db/models/constraints.py tests/constraints docs/ref/models/constraints.txt
OUTSIDE THE SCOPE: django/contrib/postgres/constraints.py +19 -4 (undo it: git checkout the file, or delete it when the run made it)
changed: django/db/models/constraints.py +50 -10
OUTSIDE THE SCOPE: docs/ref/contrib/postgres/constraints.txt +8 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: docs/ref/models/constraints.txt +11 -3
OUTSIDE THE SCOPE: docs/releases/5.0.txt +6 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/constraints/tests.py +52 -1
OUTSIDE THE SCOPE: tests/postgres_tests/test_constraints.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `task.md`

```
# Task

## Prompt

Allow to customize the code attribute of ValidationError raised by BaseConstraint.validate
Description
	
It is currently possible to customize the violation_error_message of a ValidationError raised by a constraint but not the code.
I'd like to add a new violation_error_message parameter to BaseConstraint to allow to easily add one.
Currently, to achieve the same result, you have to subclass the constraint to tweak validate to catch and reraise the ValidationError.
Since the documentation recommends to Provide a descriptive error code to the constructor: when raising a ValidationError in ​https://docs.djangoproject.com/en/4.1/ref/forms/validation/#raising-validationerror , I think it would make sense to provide this possibility for errors raised by constraints.
If you think it would be a good idea, I'd be happy to work on a PR.

## Deliverable

changes to this tree

## Check

`./tests/runtests.py constraints`

## Scope

`django/db/models/constraints.py`
`tests/constraints/`
`docs/ref/models/constraints.txt`

## Done when

- `BaseConstraint` accepts a `violation_error_code` keyword argument and stores it, defaulting to `None`.
- `CheckConstraint` and `UniqueConstraint` accept and forward `violation_error_code` to `BaseConstraint`.
- A constraint validation failure raises `ValidationError` with `code` equal to the configured `violation_error_code`.
- When `violation_error_code` is unset, the raised `ValidationError.code` remains `"constraint"`.
- `(inferred)` `deconstruct()` includes `violation_error_code` when it is not `None`, so migrations preserve it.
- `(inferred)` constraint equality accounts for `violation_error_code`.
```

### `test-output.log`

```
check: ./tests/runtests.py constraints
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 78 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
...........................s.......................sss........................
----------------------------------------------------------------------
Ran 78 tests in 0.099s

OK (skipped=4)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/models/constraints.py tests/constraints docs/ref/models/constraints.txt
OUTSIDE THE SCOPE: django/contrib/postgres/constraints.py +19 -4 (undo it: git checkout the file, or delete it when the run made it)
changed: django/db/models/constraints.py +50 -10
OUTSIDE THE SCOPE: docs/ref/contrib/postgres/constraints.txt +8 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: docs/ref/models/constraints.txt +11 -3
OUTSIDE THE SCOPE: docs/releases/5.0.txt +6 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/constraints/tests.py +52 -1
OUTSIDE THE SCOPE: tests/postgres_tests/test_constraints.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
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
