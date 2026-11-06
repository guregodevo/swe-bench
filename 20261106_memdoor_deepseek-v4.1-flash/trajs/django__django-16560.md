# django__django-16560 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 122s 500 lines cost=0.009033 in=897633 cached=857088 out=11782 calls=34`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Allow to customize the code attribute of ValidationError raised by BaseConstraint.validate
Description
	
It is currently possible to customize the violation_error_message of a ValidationError raised by a constraint but not the code.
I'd like to add a new violation_error_message parameter to BaseConstraint to allow to easily add one.
Currently, to achieve the same result, you have to subclass the constraint to tweak validate to catch and reraise the ValidationError.
Since the documentation recommends to Provide a descriptive error code to the constructor: when raising a ValidationError in ​https://docs.djangoproject.com/en/4.1/ref/forms/validation/#raising-validationerror , I think it would make sense to provide this possibility for errors raised by constraints.
If you think it would be a good idea, I'd be happy to work on a PR.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain -- . ':(exclude).memdoor' | head"
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
/testbed
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
  "limit": 430
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

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\" tests docs | head -80"
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
tests/postgres_tests/test_constraints.py:392:            violation_error_message="Overlapping must be excluded",
tests/postgres_tests/test_constraints.py:398:            "violation_error_message='Overlapping must be excluded'>",
tests/postgres_tests/test_constraints.py:462:            violation_error_message="custom error",
tests/postgres_tests/test_constraints.py:471:            violation_error_message="other custom error",
tests/postgres_tests/test_constraints.py:763:            violation_error_message="Custom error message.",
docs/ref/contrib/postgres/constraints.txt:15:.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)
docs/ref/contrib/postgres/constraints.txt:136:``violation_error_message``
docs/ref/contrib/postgres/constraints.txt:141::attr:`.BaseConstraint.violation_error_message`.
docs/ref/models/constraints.txt:51:.. class:: BaseConstraint(*, name, violation_error_message=None)
docs/ref/models/constraints.txt:71:``violation_error_message``
docs/ref/models/constraints.txt:74:.. attribute:: BaseConstraint.violation_error_message
docs/ref/models/constraints.txt:97:.. class:: CheckConstraint(*, check, name, violation_error_message=None)
docs/ref/models/constraints.txt:124:.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)
docs/ref/models/constraints.txt:245:``violation_error_message``
docs/ref/models/constraints.txt:248:.. attribute:: UniqueConstraint.violation_error_message
docs/ref/models/constraints.txt:252::attr:`.BaseConstraint.violation_error_message`.
docs/releases/5.0.txt:270:* Passing positional arguments  ``name`` and ``violation_error_message`` to
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"violation_error_message\\|def __init__\\|def validate\\|def __repr__\\|def __eq__\\|def deconstruct\" django/contrib/postgres/constraints.py | head -60"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,180p' tests/constraints/tests.py"
}
```

**tool result**

```
26:    def __init__(
35:        violation_error_message=None,
63:        super().__init__(name=name, violation_error_message=violation_error_message)
130:    def deconstruct(self):
143:    def __eq__(self, other):
152:                and self.violation_error_message == other.violation_error_message
156:    def __repr__(self):
167:                if self.violation_error_message is None
168:                or self.violation_error_message == self.default_violation_error_message
169:                else " violation_error_message=%r" % self.violation_error_message
173:    def validate(self, model, instance, exclude=None, using=DEFAULT_DB_ALIAS):
207:                raise ValidationError(self.get_violation_error_message())
212:                raise ValidationError(self.get_violation_error_message())
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
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"VERSION\\|__version__\" django/__init__.py; sed -n '1,230p' django/contrib/postgres/constraints.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '40,110p' docs/ref/models/constraints.txt; sed -n '235,260p' docs/ref/models/constraints.txt; sed -n '125,150p' docs/ref/contrib/postgres/constraints.txt"
}
```

**tool result**

```
3:VERSION = (5, 0, 0, "alpha", 0)
5:__version__ = get_version(VERSION)
from types import NoneType

from django.contrib.postgres.indexes import OpClass
from django.core.exceptions import ValidationError
from django.db import DEFAULT_DB_ALIAS, NotSupportedError
from django.db.backends.ddl_references import Expressions, Statement, Table
from django.db.models import BaseConstraint, Deferrable, F, Q
from django.db.models.expressions import Exists, ExpressionList
from django.db.models.indexes import IndexExpression
from django.db.models.lookups import PostgresOperatorLookup
from django.db.models.sql import Query

__all__ = ["ExclusionConstraint"]


class ExclusionConstraintExpression(IndexExpression):
    template = "%(expressions)s WITH %(operator)s"


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
```

**tool result**

```
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
.. attribute:: ExclusionConstraint.include

A list or tuple of the names of the fields to be included in the covering
exclusion constraint as non-key columns. This allows index-only scans to be
used for queries that select only included fields
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

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"get_violation_error_message\\|violation_error_message\" django --include=*.py"
}
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
django/db/models/constraints.py:20:    default_violation_error_message = _("Constraint “%(name)s” is violated.")
django/db/models/constraints.py:21:    violation_error_message = None
django/db/models/constraints.py:24:    # def __init__(self, *, name, violation_error_message=None):
django/db/models/constraints.py:25:    def __init__(self, *args, name=None, violation_error_message=None):
django/db/models/constraints.py:33:        if violation_error_message is not None:
django/db/models/constraints.py:34:            self.violation_error_message = violation_error_message
django/db/models/constraints.py:36:            self.violation_error_message = self.default_violation_error_message
django/db/models/constraints.py:45:            for arg, attr in zip(args, ["name", "violation_error_message"]):
django/db/models/constraints.py:65:    def get_violation_error_message(self):
django/db/models/constraints.py:66:        return self.violation_error_message % {"name": self.name}
django/db/models/constraints.py:73:            self.violation_error_message is not None
django/db/models/constraints.py:74:            and self.violation_error_message != self.default_violation_error_message
django/db/models/constraints.py:76:            kwargs["violation_error_message"] = self.violation_error_message
django/db/models/constraints.py:85:    def __init__(self, *, check, name, violation_error_message=None):
django/db/models/constraints.py:91:        super().__init__(name=name, violation_error_message=violation_error_message)
django/db/models/constraints.py:115:                raise ValidationError(self.get_violation_error_message())
django/db/models/constraints.py:126:                if self.violation_error_message is None
django/db/models/constraints.py:127:                or self.violation_error_message == self.default_violation_error_message
django/db/models/constraints.py:128:                else " violation_error_message=%r" % self.violation_error_message
django/db/models/constraints.py:137:                and self.violation_error_message == other.violation_error_message
django/db/models/constraints.py:166:        violation_error_message=None,
django/db/models/constraints.py:216:        super().__init__(name=name, violation_error_message=violation_error_message)
django/db/models/constraints.py:307:                if self.violation_error_message is None
django/db/models/constraints.py:308:                or self.violation_error_message == self.default_violation_error_message
django/db/models/constraints.py:309:                else " violation_error_message=%r" % self.violation_error_message
django/db/models/constraints.py:323:                and self.violation_error_message == other.violation_error_message
django/db/models/constraints.py:388:                    raise ValidationError(self.get_violation_error_message())
django/db/models/constraints.py:403:                    raise ValidationError(self.get_violation_error_message())
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/constraints.py\n@@\n class BaseConstraint:\n     default_violation_error_message = _(\"Constraint “%(name)s” is violated.\")\n+    violation_error_code = None\n     violation_error_message = None\n \n     # RemovedInDjango60Warning: When the deprecation ends, replace with:\n-    # def __init__(self, *, name, violation_error_message=None):\n-    def __init__(self, *args, name=None, violation_error_message=None):\n+    # def __init__(self, *, name, violation_error_code=None, violation_error_message=None):\n+    def __init__(\n+        self, *args, name=None, violation_error_code=None, violation_error_message=None\n+    ):\n@@\n         self.name = name\n+        self.violation_error_code = violation_error_code\n         if violation_error_message is not None:\n             self.violation_error_message = violation_error_message\n@@\n         path = \"%s.%s\" % (self.__class__.__module__, self.__class__.__name__)\n         path = path.replace(\"django.db.models.constraints\", \"django.db.models\")\n         kwargs = {\"name\": self.name}\n+        if self.violation_error_code is not None:\n+            kwargs[\"violation_error_code\"] = self.violation_error_code\n         if (\n             self.violation_error_message is not None\n             and self.violation_error_message != self.default_violation_error_message\n@@\n class CheckConstraint(BaseConstraint):\n-    def __init__(self, *, check, name, violation_error_message=None):\n+    def __init__(\n+        self, *, check, name, violation_error_code=None, violation_error_message=None\n+    ):\n         self.check = check\n         if not getattr(check, \"conditional\", False):\n             raise TypeError(\n                 \"CheckConstraint.check must be a Q instance or boolean expression.\"\n             )\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n         try:\n             if not Q(self.check).check(against, using=using):\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(), code=self.violation_error_code\n+                )\n         except FieldError:\n             pass\n \n     def __repr__(self):\n-        return \"<%s: check=%s name=%s%s>\" % (\n+        return \"<%s: check=%s name=%s%s%s>\" % (\n             self.__class__.__qualname__,\n             self.check,\n             repr(self.name),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n             return (\n                 self.name == other.name\n                 and self.check == other.check\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n         include=None,\n         opclasses=(),\n+        violation_error_code=None,\n         violation_error_message=None,\n     ):\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n     def __repr__(self):\n-        return \"<%s:%s%s%s%s%s%s%s%s>\" % (\n+        return \"<%s:%s%s%s%s%s%s%s%s%s>\" % (\n             self.__class__.__qualname__,\n             \"\" if not self.fields else \" fields=%s\" % repr(self.fields),\n             \"\" if not self.expressions else \" expressions=%s\" % repr(self.expressions),\n@@\n             \"\" if not self.include else \" include=%s\" % repr(self.include),\n             \"\" if not self.opclasses else \" opclasses=%s\" % repr(self.opclasses),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n                 and self.opclasses == other.opclasses\n                 and self.expressions == other.expressions\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n             if queryset.exists():\n                 if self.expressions:\n-                    raise ValidationError(self.get_violation_error_message())\n+                    raise ValidationError(\n+                        self.get_violation_error_message(),\n+                        code=self.violation_error_code,\n+                    )\n@@\n                 if (self.condition & Exists(queryset.filter(self.condition))).check(\n                     against, using=using\n                 ):\n-                    raise ValidationError(self.get_violation_error_message())\n+                    raise ValidationError(\n+                        self.get_violation_error_message(),\n+                        code=self.violation_error_code,\n+                    )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/constraints.py now (442 lines), around the change:
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
36:        self.violation_error_code = violation_error_code
37:        if violation_error_message is not None:
38:            self.violation_error_message = violation_error_message
39:        else:
…
73:        path = "%s.%s" % (self.__class__.__module__, self.__class__.__name__)
74:        path = path.replace("django.db.models.constraints", "django.db.models")
75:        kwargs = {"name": self.name}
76:        if self.violation_error_code is not None:
77:            kwargs["violation_error_code"] = self.violation_error_code
78:        if (
79:            self.violation_error_message is not None
80:            and self.violation_error_message != self.default_violation_error_message
…
88:
89:
90:class CheckConstraint(BaseConstraint):
91:    def __init__(
92:        self, *, check, name, violation_error_code=None, violation_error_message=None
93:    ):
94:        self.check = check
95:        if not getattr(check, "conditional", False):
96:            raise TypeError(
97:                "CheckConstraint.check must be a Q instance or boolean expression."
98:            )
99:        super().__init__(
100:            name=name,
101:            violation_error_code=violation_error_code,
102:            violation_error_message=violation_error_message,
103:        )
104:
105:    def _get_check_sql(self, model, schema_editor):
106:        query = Query(model=model, alias_cols=False)
…
124:        against = instance._get_field_value_map(meta=model._meta, exclude=exclude)
125:        try:
126:            if not Q(self.check).check(against, using=using):
127:                raise ValidationError(
128:                    self.get_violation_error_message(), code=self.violation_error_code
129:                )
130:        except FieldError:
131:            pass
132:
133:    def __repr__(self):
134:        return "<%s: check=%s name=%s%s%s>" % (
135:            self.__class__.__qualname__,
136:            self.check,
137:            repr(self.name),
138:            (
139:                ""
140:                if self.violation_error_code is None
141:                else " violation_error_code=%r" % self.violation_error_code
142:            ),
143:            (
144:                ""
145:                if self.violation_error_message is None
…
153:            return (
154:                self.name == other.name
155:                and self.check == other.check
156:                and self.violation_error_code == other.violation_error_code
157:                and self.violation_error_message == other.violation_error_message
158:            )
159:        return super().__eq__(other)
…
183:        deferrable=None,
184:        include=None,
185:        opclasses=(),
186:        violation_error_code=None,
187:        violation_error_message=None,
188:    ):
189:        if not name:
…
234:            F(expression) if isinstance(expression, str) else expression
235:            for expression in expressions
236:        )
237:        super().__init__(
238:            name=name,
239:            violation_error_code=violation_error_code,
240:            violation_error_message=violation_error_message,
241:        )
242:
243:    @property
244:    def contains_expressions(self):
…
318:        )
319:
320:    def __repr__(self):
321:        return "<%s:%s%s%s%s%s%s%s%s%s>" % (
322:            self.__class__.__qualname__,
323:            "" if not self.fields else " fields=%s" % repr(self.fields),
324:            "" if not self.expressions else " expressions=%s" % repr(self.expressions),
…
329:            "" if not self.opclasses else " opclasses=%s" % repr(self.opclasses),
330:            (
331:                ""
332:                if self.violation_error_code is None
333:                else " violation_error_code=%r" % self.violation_error_code
334:            ),
335:            (
336:                ""
337:                if self.violation_error_message is None
338:                or self.violation_error_message == self.default_violation_error_message
339:                else " violation_error_message=%r" % self.violation_error_message
…
350:                and self.include == other.include
351:                and self.opclasses == other.opclasses
352:                and self.expressions == other.expressions
353:                and self.violation_error_code == other.violation_error_code
354:                and self.violation_error_message == other.violation_error_message
355:            )
356:        return super().__eq__(other)
…
416:        if not self.condition:
417:            if queryset.exists():
418:                if self.expressions:
419:                    raise ValidationError(
420:                        self.get_violation_error_message(),
421:                        code=self.violation_error_code,
422:                    )
423:                # When fields are defined, use the unique_error_message() for
424:                # backward compatibility.
425:                for model, constraints in instance.get_constraints():
…
434:                if (self.condition & Exists(queryset.filter(self.condition))).check(
435:                    against, using=using
436:                ):
437:                    raise ValidationError(
438:                        self.get_violation_error_message(),
439:                        code=self.violation_error_code,
440:                    )
441:            except FieldError:
442:                pass
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/postgres/constraints.py\n@@\n         deferrable=None,\n         include=None,\n+        violation_error_code=None,\n         violation_error_message=None,\n     ):\n@@\n-        super().__init__(name=name, violation_error_message=violation_error_message)\n+        super().__init__(\n+            name=name,\n+            violation_error_code=violation_error_code,\n+            violation_error_message=violation_error_message,\n+        )\n@@\n                 and self.deferrable == other.deferrable\n                 and self.include == other.include\n+                and self.violation_error_code == other.violation_error_code\n                 and self.violation_error_message == other.violation_error_message\n             )\n@@\n-        return \"<%s: index_type=%s expressions=%s name=%s%s%s%s%s>\" % (\n+        return \"<%s: index_type=%s expressions=%s name=%s%s%s%s%s%s>\" % (\n             self.__class__.__qualname__,\n             repr(self.index_type),\n             repr(self.expressions),\n@@\n             \"\" if self.deferrable is None else \" deferrable=%r\" % self.deferrable,\n             \"\" if not self.include else \" include=%s\" % repr(self.include),\n+            (\n+                \"\"\n+                if self.violation_error_code is None\n+                else \" violation_error_code=%r\" % self.violation_error_code\n+            ),\n             (\n                 \"\"\n                 if self.violation_error_message is None\n@@\n         if not self.condition:\n             if queryset.exists():\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(),\n+                    code=self.violation_error_code,\n+                )\n         else:\n             if (self.condition & Exists(queryset.filter(self.condition))).check(\n                 replacement_map, using=using\n             ):\n-                raise ValidationError(self.get_violation_error_message())\n+                raise ValidationError(\n+                    self.get_violation_error_message(),\n+                    code=self.violation_error_code,\n+                )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/postgres/constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/postgres/constraints.py now (229 lines), around the change:
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
219:                    self.get_violation_error_message(),
220:                    code=self.violation_error_code,
221:                )
222:        else:
223:            if (self.condition & Exists(queryset.filter(self.condition))).check(
224:                replacement_map, using=using
225:            ):
226:                raise ValidationError(
227:                    self.get_violation_error_message(),
228:                    code=self.violation_error_code,
229:                )
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/ref/models/constraints.txt\n@@\n-.. class:: BaseConstraint(*, name, violation_error_message=None)\n+.. class:: BaseConstraint(*, name, violation_error_code=None, violation_error_message=None)\n@@\n ``violation_error_message``\n ---------------------------\n@@\n ``\"Constraint “%(name)s” is violated.\"``.\n+\n+``violation_error_code``\n+------------------------\n+\n+.. attribute:: BaseConstraint.violation_error_code\n+\n+The error code used when ``ValidationError`` is raised during\n+:ref:`model validation <validating-objects>`. Defaults to ``None``.\n@@\n-.. class:: CheckConstraint(*, check, name, violation_error_message=None)\n+.. class:: CheckConstraint(*, check, name, violation_error_code=None, violation_error_message=None)\n@@\n-.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_message=None)\n+.. class:: UniqueConstraint(*expressions, fields=(), name=None, condition=None, deferrable=None, include=None, opclasses=(), violation_error_code=None, violation_error_message=None)\n@@\n ``violation_error_message``\n ---------------------------\n@@\n :attr:`Meta.unique_together <django.db.models.Options.constraints>`.\n+\n+``violation_error_code``\n+------------------------\n+\n+.. attribute:: UniqueConstraint.violation_error_code\n+\n+The error code used when ``ValidationError`` is raised during\n+:ref:`model validation <validating-objects>`. Defaults to\n+:attr:`.BaseConstraint.violation_error_code`.\n*** Update File: docs/ref/contrib/postgres/constraints.txt\n@@\n-.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_message=None)\n+.. class:: ExclusionConstraint(*, name, expressions, index_type=None, condition=None, deferrable=None, include=None, violation_error_code=None, violation_error_message=None)\n@@\n ``violation_error_message``\n ---------------------------\n@@\n :attr:`.BaseConstraint.violation_error_message`.\n+\n+``violation_error_code``\n+------------------------\n+\n+The error code used when ``ValidationError`` is raised during\n+:ref:`model validation <validating-objects>`. Defaults to\n+:attr:`.BaseConstraint.violation_error_code`.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/ref/models/constraints.txt docs/ref/contrib/postgres/constraints.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/ref/models/constraints.txt now (276 lines), around the change:
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
…
265:same message as constraints defined with
266::attr:`.Field.unique` or in
267::attr:`Meta.unique_together <django.db.models.Options.constraints>`.
268:
269:``violation_error_code``
270:------------------------
271:
272:.. attribute:: UniqueConstraint.violation_error_code
273:
274:The error code used when ``ValidationError`` is raised during
275::ref:`model validation <validating-objects>`. Defaults to
276::attr:`.BaseConstraint.violation_error_code`.

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

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"violation_error_message\\|def test_validate\\|def test_repr\\|def test_eq\\|def test_deconstruct\" tests/constraints/tests.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '180,360p' tests/constraints/tests.py; sed -n '480,530p' tests/constraints/tests.py"
}
```

**tool result**

```
52:    def test_validate(self):
58:    def test_default_violation_error_message(self):
61:            c.get_violation_error_message(), "Constraint “name” is violated."
64:    def test_custom_violation_error_message(self):
66:            name="base_name", violation_error_message="custom %(name)s message"
68:        self.assertEqual(c.get_violation_error_message(), "custom base_name message")
70:    def test_custom_violation_error_message_clone(self):
73:            violation_error_message="custom %(name)s message",
76:            constraint.get_violation_error_message(),
80:    def test_deconstruction(self):
83:            violation_error_message="custom %(name)s message",
90:            {"name": "base_name", "violation_error_message": "custom %(name)s message"},
108:        self.assertEqual(c.get_violation_error_message(), "custom name message")
112:    def test_eq(self):
132:                check=check1, name="price", violation_error_message="custom error"
137:                check=check1, name="price", violation_error_message="custom error"
140:                check=check1, name="price", violation_error_message="other custom error"
145:                check=check1, name="price", violation_error_message="custom error"
148:                check=check1, name="price", violation_error_message="custom error"
152:    def test_repr(self):
163:    def test_repr_with_violation_error_message(self):
167:            violation_error_message="More than 1",
172:            "violation_error_message='More than 1'>",
180:    def test_deconstruction(self):
220:    def test_validate(self):
240:    def test_validate_boolean_expressions(self):
254:    def test_validate_rawsql_expressions_noop(self):
269:    def test_validate_nullable_field_with_none(self):
278:    def test_validate_nullable_field_with_isnull(self):
292:    def test_eq(self):
317:                violation_error_message="custom error",
324:                violation_error_message="custom error",
329:                violation_error_message="other custom error",
336:                violation_error_message="custom error",
341:                violation_error_message="custom error",
345:    def test_eq_with_condition(self):
371:    def test_eq_with_deferrable(self):
385:    def test_eq_with_include(self):
399:    def test_eq_with_opclasses(self):
413:    def test_eq_with_expressions(self):
432:    def test_repr(self):
441:    def test_repr_with_condition(self):
453:    def test_repr_with_deferrable(self):
465:    def test_repr_with_include(self):
477:    def test_repr_with_opclasses(self):
489:    def test_repr_with_expressions(self):
501:    def test_repr_with_violation_error_message(self):
505:            violation_error_message="BAZ",
511:                "name='unique_lower_baz' violation_error_message='BAZ'>"
515:    def test_deconstruction(self):
524:    def test_deconstruction_with_condition(self):
538:    def test_deconstruction_with_deferrable(self):
558:    def test_deconstruction_with_include(self):
575:    def test_deconstruction_with_opclasses(self):
594:    def test_deconstruction_with_expressions(self):
657:    def test_validate(self):
696:    def test_validate_condition(self):
719:    def test_validate_expression(self):
740:    def test_validate_ordered_expression(self):
763:    def test_validate_expression_condition(self):
793:    def test_validate_expression_str(self):
```

**tool result**

```
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
        Product.objects.create(price=10, discounted_price=5)
        with self.assertRaises(IntegrityError):
            Product.objects.create(price=10, discounted_price=20)

    @skipUnlessDBFeature("supports_table_check_constraints")
    def test_database_constraint_unicode(self):
        Product.objects.create(price=10, discounted_price=5, unit="μg/mL")
        with self.assertRaises(IntegrityError):
            Product.objects.create(price=10, discounted_price=7, unit="l")

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
            name="price_neq_500_raw",
        )
        # RawSQL can not be checked and is always considered valid.
        constraint.validate(Product, Product(price=500, discounted_price=5))
        constraint.validate(Product, Product(price=501, discounted_price=5))
        constraint.validate(Product, Product(price=499, discounted_price=5))

    @skipUnlessDBFeature("supports_comparing_boolean_expr")
    def test_validate_nullable_field_with_none(self):
        # Nullable fields should be considered valid on None values.
        constraint = models.CheckConstraint(
            check=models.Q(price__gte=0),
            name="positive_price",
        )
        constraint.validate(Product, Product())

    @skipIfDBFeature("supports_comparing_boolean_expr")
    def test_validate_nullable_field_with_isnull(self):
        constraint = models.CheckConstraint(
            check=models.Q(price__gte=0) | models.Q(price__isnull=True),
            name="positive_price",
        )
        constraint.validate(Product, Product())


class UniqueConstraintTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.p1 = UniqueConstraintProduct.objects.create(name="p1", color="red")
        cls.p2 = UniqueConstraintProduct.objects.create(name="p2")

    def test_eq(self):
        self.assertEqual(
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"),
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"),
        )
        self.assertEqual(
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"),
            mock.ANY,
        )
        self.assertNotEqual(
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"),
            models.UniqueConstraint(fields=["foo", "bar"], name="unique2"),
        )
        self.assertNotEqual(
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"),
            models.UniqueConstraint(fields=["foo", "baz"], name="unique"),
        )
        self.assertNotEqual(
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"), 1
        )
        self.assertNotEqual(
            models.UniqueConstraint(fields=["foo", "bar"], name="unique"),
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                violation_error_message="custom error",
            ),
        )
        self.assertNotEqual(
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                violation_error_message="custom error",
            ),
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                violation_error_message="other custom error",
            ),
        )
        self.assertEqual(
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                violation_error_message="custom error",
            ),
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                violation_error_message="custom error",
            ),
        )

    def test_eq_with_condition(self):
        self.assertEqual(
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                condition=models.Q(foo=models.F("bar")),
            ),
            models.UniqueConstraint(
                fields=["foo", "bar"],
                name="unique",
                condition=models.Q(foo=models.F("bar")),
            ),
        )
        self.assertNotEqual(
            models.UniqueConstraint(
                fields=["foo", "bar"],
            name="opclasses_fields",
            opclasses=["text_pattern_ops", "varchar_pattern_ops"],
        )
        self.assertEqual(
            repr(constraint),
            "<UniqueConstraint: fields=('foo', 'bar') name='opclasses_fields' "
            "opclasses=['text_pattern_ops', 'varchar_pattern_ops']>",
        )

    def test_repr_with_expressions(self):
        constraint = models.UniqueConstraint(
            Lower("title"),
            F("author"),
            name="book_func_uq",
        )
        self.assertEqual(
            repr(constraint),
            "<UniqueConstraint: expressions=(Lower(F(title)), F(author)) "
            "name='book_func_uq'>",
        )

    def test_repr_with_violation_error_message(self):
        constraint = models.UniqueConstraint(
            models.F("baz__lower"),
            name="unique_lower_baz",
            violation_error_message="BAZ",
        )
        self.assertEqual(
            repr(constraint),
            (
                "<UniqueConstraint: expressions=(F(baz__lower),) "
                "name='unique_lower_baz' violation_error_message='BAZ'>"
            ),
        )

    def test_deconstruction(self):
        fields = ["foo", "bar"]
        name = "unique_fields"
        constraint = models.UniqueConstraint(fields=fields, name=name)
        path, args, kwargs = constraint.deconstruct()
        self.assertEqual(path, "django.db.models.UniqueConstraint")
        self.assertEqual(args, ())
        self.assertEqual(kwargs, {"fields": tuple(fields), "name": name})

    def test_deconstruction_with_condition(self):
        fields = ["foo", "bar"]
        name = "unique_fields"
        condition = models.Q(foo=models.F("bar"))
        constraint = models.UniqueConstraint(
            fields=fields, name=name, condition=condition
        )
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"constraint\\|Constraint\" docs/releases/5.0.txt | head -30; sed -n '250,285p' docs/releases/5.0.txt"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '360,480p' tests/postgres_tests/test_constraints.py; sed -n '740,780p' tests/postgres_tests/test_constraints.py"
}
```

**tool result**

```
271:  :class:`~django.db.models.BaseConstraint` is deprecated in favor of
341:  ``django.contrib.postgres.constraints.ExclusionConstraint`` is removed.

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
```

**tool result**

```
        self.assertEqual(
            repr(constraint),
            "<ExclusionConstraint: index_type='GIST' expressions=["
            "(F(datespan), '-|-')] name='exclude_overlapping' "
            "deferrable=Deferrable.IMMEDIATE>",
        )
        constraint = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[(F("datespan"), RangeOperators.ADJACENT_TO)],
            include=["cancelled", "room"],
        )
        self.assertEqual(
            repr(constraint),
            "<ExclusionConstraint: index_type='GIST' expressions=["
            "(F(datespan), '-|-')] name='exclude_overlapping' "
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
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_custom_violation_error_message_clone(self):\n         constraint = BaseConstraint(\n             name=\"base_name\",\n             violation_error_message=\"custom %(name)s message\",\n         ).clone()\n@@\n             \"custom base_name message\",\n         )\n \n+    def test_custom_violation_error_code(self):\n+        c = BaseConstraint(name=\"base_name\", violation_error_code=\"custom_code\")\n+        self.assertEqual(c.violation_error_code, \"custom_code\")\n+\n+    def test_custom_violation_error_code_clone(self):\n+        constraint = BaseConstraint(\n+            name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n+        ).clone()\n+        self.assertEqual(constraint.violation_error_code, \"custom_code\")\n+\n     def test_deconstruction(self):\n         constraint = BaseConstraint(\n             name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n             violation_error_message=\"custom %(name)s message\",\n         )\n         path, args, kwargs = constraint.deconstruct()\n         self.assertEqual(path, \"django.db.models.BaseConstraint\")\n         self.assertEqual(args, ())\n         self.assertEqual(\n             kwargs,\n-            {\"name\": \"base_name\", \"violation_error_message\": \"custom %(name)s message\"},\n+            {\n+                \"name\": \"base_name\",\n+                \"violation_error_code\": \"custom_code\",\n+                \"violation_error_message\": \"custom %(name)s message\",\n+            },\n         )\n@@\n     def test_repr_with_violation_error_message(self):\n         constraint = models.CheckConstraint(\n             check=models.Q(price__lt=1),\n             name=\"price_lt_one\",\n             violation_error_message=\"More than 1\",\n@@\n             \"violation_error_message='More than 1'>\",\n         )\n \n+    def test_repr_with_violation_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__lt=1),\n+            name=\"price_lt_one\",\n+            violation_error_code=\"more_than_one\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            \"<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' \"\n+            \"violation_error_code='more_than_one'>\",\n+        )\n+\n@@\n     def test_validate_boolean_expressions(self):\n@@\n         constraint.validate(Product, Product(price=499, discounted_price=5))\n \n+    def test_validate_custom_violation_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__gt=models.F(\"discounted_price\")),\n+            name=\"price_gt_discounted_price\",\n+            violation_error_code=\"price_gt_discounted_price\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(Product, Product(price=10, discounted_price=42))\n+        self.assertEqual(\n+            cm.exception.code, \"price_gt_discounted_price\"\n+        )\n+\n@@\n     def test_repr_with_violation_error_message(self):\n@@\n             ),\n         )\n \n+    def test_repr_with_violation_error_code(self):\n+        constraint = models.UniqueConstraint(\n+            models.F(\"baz__lower\"),\n+            name=\"unique_lower_baz\",\n+            violation_error_code=\"unique_lower_baz\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            (\n+                \"<UniqueConstraint: expressions=(F(baz__lower),) \"\n+                \"name='unique_lower_baz' violation_error_code='unique_lower_baz'>\"\n+            ),\n+        )\n+\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/constraints/tests.py: the lines to change in /testbed/tests/constraints/tests.py appear more than once (lines 252 and 266): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_custom_violation_error_message_clone(self):\n         constraint = BaseConstraint(\n             name=\"base_name\",\n             violation_error_message=\"custom %(name)s message\",\n         ).clone()\n         self.assertEqual(\n             constraint.get_violation_error_message(),\n             \"custom base_name message\",\n         )\n \n+    def test_custom_violation_error_code(self):\n+        c = BaseConstraint(name=\"base_name\", violation_error_code=\"custom_code\")\n+        self.assertEqual(c.violation_error_code, \"custom_code\")\n+\n+    def test_custom_violation_error_code_clone(self):\n+        constraint = BaseConstraint(\n+            name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n+        ).clone()\n+        self.assertEqual(constraint.violation_error_code, \"custom_code\")\n+\n     def test_deconstruction(self):\n         constraint = BaseConstraint(\n             name=\"base_name\",\n+            violation_error_code=\"custom_code\",\n             violation_error_message=\"custom %(name)s message\",\n         )\n         path, args, kwargs = constraint.deconstruct()\n         self.assertEqual(path, \"django.db.models.BaseConstraint\")\n         self.assertEqual(args, ())\n         self.assertEqual(\n             kwargs,\n-            {\"name\": \"base_name\", \"violation_error_message\": \"custom %(name)s message\"},\n+            {\n+                \"name\": \"base_name\",\n+                \"violation_error_code\": \"custom_code\",\n+                \"violation_error_message\": \"custom %(name)s message\",\n+            },\n         )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (981 lines), around the change:
77:            "custom base_name message",
78:        )
79:
80:    def test_custom_violation_error_code(self):
81:        c = BaseConstraint(name="base_name", violation_error_code="custom_code")
82:        self.assertEqual(c.violation_error_code, "custom_code")
83:
84:    def test_custom_violation_error_code_clone(self):
85:        constraint = BaseConstraint(
86:            name="base_name",
87:            violation_error_code="custom_code",
88:        ).clone()
89:        self.assertEqual(constraint.violation_error_code, "custom_code")
90:
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
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_repr_with_violation_error_message(self):\n         constraint = models.CheckConstraint(\n             check=models.Q(price__lt=1),\n             name=\"price_lt_one\",\n             violation_error_message=\"More than 1\",\n@@\n             \"violation_error_message='More than 1'>\",\n         )\n \n+    def test_repr_with_violation_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__lt=1),\n+            name=\"price_lt_one\",\n+            violation_error_code=\"more_than_one\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            \"<CheckConstraint: check=(AND: ('price__lt', 1)) name='price_lt_one' \"\n+            \"violation_error_code='more_than_one'>\",\n+        )\n+\n     def test_invalid_check_types(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (993 lines), around the change:
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
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_validate_boolean_expressions(self):\n         constraint = models.CheckConstraint(\n             check=models.expressions.ExpressionWrapper(\n                 models.Q(price__gt=500) | models.Q(price__lt=500),\n                 output_field=models.BooleanField(),\n@@\n         constraint.validate(Product, Product(price=501, discounted_price=5))\n         constraint.validate(Product, Product(price=499, discounted_price=5))\n \n+    def test_validate_custom_violation_error_code(self):\n+        constraint = models.CheckConstraint(\n+            check=models.Q(price__gt=models.F(\"discounted_price\")),\n+            name=\"price_gt_discounted_price\",\n+            violation_error_code=\"price_gt_discounted_price\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(Product, Product(price=10, discounted_price=42))\n+        self.assertEqual(cm.exception.code, \"price_gt_discounted_price\")\n+\n     def test_validate_rawsql_expressions_noop(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (1003 lines), around the change:
278:            constraint.validate(Product, Product(price=500, discounted_price=5))
279:        constraint.validate(Product, Product(price=501, discounted_price=5))
280:        constraint.validate(Product, Product(price=499, discounted_price=5))
281:
282:    def test_validate_custom_violation_error_code(self):
283:        constraint = models.CheckConstraint(
284:            check=models.Q(price__gt=models.F("discounted_price")),
285:            name="price_gt_discounted_price",
286:            violation_error_code="price_gt_discounted_price",
287:        )
288:        with self.assertRaises(ValidationError) as cm:
289:            constraint.validate(Product, Product(price=10, discounted_price=42))
290:        self.assertEqual(cm.exception.code, "price_gt_discounted_price")
291:
292:    def test_validate_rawsql_expressions_noop(self):
293:        constraint = models.CheckConstraint(
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     def test_repr_with_violation_error_message(self):\n         constraint = models.UniqueConstraint(\n             models.F(\"baz__lower\"),\n             name=\"unique_lower_baz\",\n             violation_error_message=\"BAZ\",\n@@\n                 \"name='unique_lower_baz' violation_error_message='BAZ'>\"\n             ),\n         )\n \n+    def test_repr_with_violation_error_code(self):\n+        constraint = models.UniqueConstraint(\n+            models.F(\"baz__lower\"),\n+            name=\"unique_lower_baz\",\n+            violation_error_code=\"unique_lower_baz\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            (\n+                \"<UniqueConstraint: expressions=(F(baz__lower),) \"\n+                \"name='unique_lower_baz' violation_error_code='unique_lower_baz'>\"\n+            ),\n+        )\n+\n     def test_deconstruction(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (1017 lines), around the change:
547:            (
548:                "<UniqueConstraint: expressions=(F(baz__lower),) "
549:                "name='unique_lower_baz' violation_error_message='BAZ'>"
550:            ),
551:        )
552:
553:    def test_repr_with_violation_error_code(self):
554:        constraint = models.UniqueConstraint(
555:            models.F("baz__lower"),
556:            name="unique_lower_baz",
557:            violation_error_code="unique_lower_baz",
558:        )
559:        self.assertEqual(
560:            repr(constraint),
561:            (
562:                "<UniqueConstraint: expressions=(F(baz__lower),) "
563:                "name='unique_lower_baz' violation_error_code='unique_lower_baz'>"
564:            ),
565:        )
566:
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '700,760p' tests/constraints/tests.py"
}
```

**tool result**

```
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
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '640,710p' tests/constraints/tests.py; grep -rn \"violation_error_code\\|custom_validate_no_code_error\" tests/constraints tests/postgres_tests | head -30"
}
```

**tool result**

```
                "fields": tuple(fields),
                "name": name,
                "opclasses": opclasses,
            },
        )

    def test_deconstruction_with_expressions(self):
        name = "unique_fields"
        constraint = models.UniqueConstraint(Lower("title"), name=name)
        path, args, kwargs = constraint.deconstruct()
        self.assertEqual(path, "django.db.models.UniqueConstraint")
        self.assertEqual(args, (Lower("title"),))
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
tests/constraints/tests.py:80:    def test_custom_violation_error_code(self):
tests/constraints/tests.py:81:        c = BaseConstraint(name="base_name", violation_error_code="custom_code")
tests/constraints/tests.py:82:        self.assertEqual(c.violation_error_code, "custom_code")
tests/constraints/tests.py:84:    def test_custom_violation_error_code_clone(self):
tests/constraints/tests.py:87:            violation_error_code="custom_code",
tests/constraints/tests.py:89:        self.assertEqual(constraint.violation_error_code, "custom_code")
tests/constraints/tests.py:94:            violation_error_code="custom_code",
tests/constraints/tests.py:104:                "violation_error_code": "custom_code",
tests/constraints/tests.py:191:    def test_repr_with_violation_error_code(self):
tests/constraints/tests.py:195:            violation_error_code="more_than_one",
tests/constraints/tests.py:200:            "violation_error_code='more_than_one'>",
tests/constraints/tests.py:282:    def test_validate_custom_violation_error_code(self):
tests/constraints/tests.py:286:            violation_error_code="price_gt_discounted_price",
tests/constraints/tests.py:553:    def test_repr_with_violation_error_code(self):
tests/constraints/tests.py:557:            violation_error_code="unique_lower_baz",
tests/constraints/tests.py:563:                "name='unique_lower_baz' violation_error_code='unique_lower_baz'>"
tests/constraints/tests.py:701:                        name="custom_validate_no_code_error",
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def validate_constraints\" -A45 django/db/models/base.py"
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
1478-        except ValidationError as e:
1479-            errors = e.update_error_dict(errors)
1480-
1481-        # Run unique checks, but only for fields that passed validation.
1482-        if validate_unique:
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/constraints/tests.py -q 2>&1 | tail -30"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py constraints --verbosity 1 2>&1 | tail -40"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 78 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
...........................s.......................sss........................
----------------------------------------------------------------------
Ran 78 tests in 0.148s

OK (skipped=4)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Models\\|constraints\\|CheckConstraint\\|UniqueConstraint\" docs/releases/5.0.txt | head -30"
}
```

**tool result**

```
178:Models
341:  ``django.contrib.postgres.constraints.ExclusionConstraint`` is removed.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '170,230p' docs/releases/5.0.txt"
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
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/releases/5.0.txt\n@@\n Models\n ~~~~~~\n \n * The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`\n   and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different\n   field values for the create operation.\n \n+* The new ``violation_error_code`` argument of\n+  :class:`~django.db.models.BaseConstraint`,\n+  :class:`~django.db.models.CheckConstraint`,\n+  :class:`~django.db.models.UniqueConstraint`, and\n+  :class:`~django.contrib.postgres.constraints.ExclusionConstraint` allows\n+  customizing the error code of the ``ValidationError`` raised during model\n+  validation.\n+\n Requests and Responses\n ~~~~~~~~~~~~~~~~~~~~~~\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/releases/5.0.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/releases/5.0.txt now (386 lines), around the change:
181:* The new ``create_defaults`` argument of :meth:`.QuerySet.update_or_create`
182:  and :meth:`.QuerySet.aupdate_or_create` methods allows specifying a different
183:  field values for the create operation.
184:
185:* The new ``violation_error_code`` argument of
186:  :class:`~django.db.models.BaseConstraint`,
187:  :class:`~django.db.models.CheckConstraint`,
188:  :class:`~django.db.models.UniqueConstraint`, and
189:  :class:`~django.contrib.postgres.constraints.ExclusionConstraint` allows
190:  customizing the error code of the ``ValidationError`` raised during model
191:  validation.
192:
193:Requests and Responses
194:~~~~~~~~~~~~~~~~~~~~~~
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class UniqueConstraintConditionProduct\" -A20 tests/constraints/models.py"
}
```

**tool result**

```
45:class UniqueConstraintConditionProduct(models.Model):
46-    name = models.CharField(max_length=255)
47-    color = models.CharField(max_length=32, null=True)
48-
49-    class Meta:
50-        required_db_features = {"supports_partial_indexes"}
51-        constraints = [
52-            models.UniqueConstraint(
53-                fields=["name"],
54-                name="name_without_color_uniq",
55-                condition=models.Q(color__isnull=True),
56-            ),
57-        ]
58-
59-
60-class UniqueConstraintDeferrable(models.Model):
61-    name = models.CharField(max_length=255)
62-    shelf = models.CharField(max_length=31)
63-
64-    class Meta:
65-        required_db_features = {
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n     @skipUnlessDBFeature(\"supports_partial_indexes\")\n     def test_validate_condition(self):\n         p1 = UniqueConstraintConditionProduct.objects.create(name=\"p1\")\n         constraint = UniqueConstraintConditionProduct._meta.constraints[0]\n         msg = \"Constraint “name_without_color_uniq” is violated.\"\n@@\n                 UniqueConstraintConditionProduct(name=p1.name, color=None),\n             )\n         # Values not matching condition are ignored.\n         constraint.validate(\n             UniqueConstraintConditionProduct,\n             UniqueConstraintConditionProduct(name=p1.name, color=\"anything-but-none\"),\n         )\n+\n+    @skipUnlessDBFeature(\"supports_partial_indexes\")\n+    def test_validate_condition_custom_violation_error_code(self):\n+        p1 = UniqueConstraintConditionProduct.objects.create(name=\"p1\")\n+        constraint = models.UniqueConstraint(\n+            fields=[\"name\"],\n+            name=\"name_without_color_uniq\",\n+            condition=models.Q(color__isnull=True),\n+            violation_error_code=\"name_without_color_uniq\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(\n+                UniqueConstraintConditionProduct,\n+                UniqueConstraintConditionProduct(name=p1.name, color=None),\n+            )\n+        self.assertEqual(cm.exception.code, \"name_without_color_uniq\")\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/constraints/tests.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file tests.py and REWRITE it with *** Add File: tests.py using its ACTUAL content plus your change
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '735,790p' tests/constraints/tests.py"
}
```

**tool result**

```
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
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n         constraint.validate(\n             UniqueConstraintConditionProduct,\n             UniqueConstraintConditionProduct(name=p1.name, color=None),\n             exclude={\"name\"},\n         )\n \n+    @skipUnlessDBFeature(\"supports_partial_indexes\")\n+    def test_validate_condition_custom_violation_error_code(self):\n+        p1 = UniqueConstraintConditionProduct.objects.create(name=\"p1\")\n+        constraint = models.UniqueConstraint(\n+            fields=[\"name\"],\n+            name=\"name_without_color_uniq\",\n+            condition=models.Q(color__isnull=True),\n+            violation_error_code=\"name_without_color_uniq\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(\n+                UniqueConstraintConditionProduct,\n+                UniqueConstraintConditionProduct(name=p1.name, color=None),\n+            )\n+        self.assertEqual(cm.exception.code, \"name_without_color_uniq\")\n+\n     def test_validate_expression(self):\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/constraints/tests.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file tests.py and REWRITE it with *** Add File: tests.py using its ACTUAL content plus your change
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/constraints/tests.py\n@@\n-    def test_validate_expression(self):\n+    @skipUnlessDBFeature(\"supports_partial_indexes\")\n+    def test_validate_condition_custom_violation_error_code(self):\n+        p1 = UniqueConstraintConditionProduct.objects.create(name=\"p1\")\n+        constraint = models.UniqueConstraint(\n+            fields=[\"name\"],\n+            name=\"name_without_color_uniq\",\n+            condition=models.Q(color__isnull=True),\n+            violation_error_code=\"name_without_color_uniq\",\n+        )\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(\n+                UniqueConstraintConditionProduct,\n+                UniqueConstraintConditionProduct(name=p1.name, color=None),\n+            )\n+        self.assertEqual(cm.exception.code, \"name_without_color_uniq\")\n+\n+    def test_validate_expression(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/constraints/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/constraints/tests.py now (1033 lines), around the change:
768:            exclude={"name"},
769:        )
770:
771:    @skipUnlessDBFeature("supports_partial_indexes")
772:    def test_validate_condition_custom_violation_error_code(self):
773:        p1 = UniqueConstraintConditionProduct.objects.create(name="p1")
774:        constraint = models.UniqueConstraint(
775:            fields=["name"],
776:            name="name_without_color_uniq",
777:            condition=models.Q(color__isnull=True),
778:            violation_error_code="name_without_color_uniq",
779:        )
780:        with self.assertRaises(ValidationError) as cm:
781:            constraint.validate(
782:                UniqueConstraintConditionProduct,
783:                UniqueConstraintConditionProduct(name=p1.name, color=None),
784:            )
785:        self.assertEqual(cm.exception.code, "name_without_color_uniq")
786:
787:    def test_validate_expression(self):
788:        constraint = models.UniqueConstraint(Lower("name"), name="name_lower_uniq")
789:        msg = "Constraint “name_lower_uniq” is violated."
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '480,520p' tests/postgres_tests/test_constraints.py; grep -n \"def test_validate_range_adjacent\\|def test_repr\\|def test_eq\" tests/postgres_tests/test_constraints.py"
}
```

**tool result**

```
        self.assertNotEqual(constraint_2, constraint_4)
        self.assertNotEqual(constraint_2, constraint_7)
        self.assertNotEqual(constraint_4, constraint_5)
        self.assertNotEqual(constraint_5, constraint_6)
        self.assertNotEqual(constraint_1, object())
        self.assertNotEqual(constraint_10, constraint_11)
        self.assertEqual(constraint_10, constraint_10)

    def test_deconstruct(self):
        constraint = ExclusionConstraint(
            name="exclude_overlapping",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
        )
        path, args, kwargs = constraint.deconstruct()
        self.assertEqual(
            path, "django.contrib.postgres.constraints.ExclusionConstraint"
        )
        self.assertEqual(args, ())
        self.assertEqual(
            kwargs,
            {
                "name": "exclude_overlapping",
                "expressions": [
                    ("datespan", RangeOperators.OVERLAPS),
                    ("room", RangeOperators.EQUAL),
                ],
            },
        )

    def test_deconstruct_index_type(self):
        constraint = ExclusionConstraint(
            name="exclude_overlapping",
            index_type="SPGIST",
            expressions=[
                ("datespan", RangeOperators.OVERLAPS),
                ("room", RangeOperators.EQUAL),
            ],
        )
330:    def test_repr(self):
401:    def test_eq(self):
759:    def test_validate_range_adjacent(self):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/postgres_tests/test_constraints.py\n@@\n         self.assertEqual(\n             repr(constraint),\n             \"<ExclusionConstraint: index_type='GIST' expressions=[\"\n             \"(F(datespan), '-|-')] name='exclude_overlapping' \"\n             \"violation_error_message='Overlapping must be excluded'>\",\n         )\n+        constraint = ExclusionConstraint(\n+            name=\"exclude_overlapping\",\n+            expressions=[(F(\"datespan\"), RangeOperators.ADJACENT_TO)],\n+            violation_error_code=\"overlapping\",\n+        )\n+        self.assertEqual(\n+            repr(constraint),\n+            \"<ExclusionConstraint: index_type='GIST' expressions=[\"\n+            \"(F(datespan), '-|-')] name='exclude_overlapping' \"\n+            \"violation_error_code='overlapping'>\",\n+        )\n@@\n     def test_validate_range_adjacent(self):\n         constraint = ExclusionConstraint(\n             name=\"ints_adjacent\",\n             expressions=[(\"ints\", RangeOperators.ADJACENT_TO)],\n             violation_error_message=\"Custom error message.\",\n@@\n         constraint.validate(RangesModel, RangesModel(ints=(51, 60)))\n         constraint.validate(RangesModel, RangesModel(ints=(10, 20)), exclude={\"ints\"})\n \n+    def test_validate_range_adjacent_custom_violation_error_code(self):\n+        constraint = ExclusionConstraint(\n+            name=\"ints_adjacent\",\n+            expressions=[(\"ints\", RangeOperators.ADJACENT_TO)],\n+            violation_error_code=\"ints_adjacent\",\n+        )\n+        RangesModel.objects.create(ints=(20, 50))\n+        with self.assertRaises(ValidationError) as cm:\n+            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))\n+        self.assertEqual(cm.exception.code, \"ints_adjacent\")\n+\n     def test_expressions_with_params(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/postgres_tests/test_constraints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/postgres_tests/test_constraints.py now (1154 lines), around the change:
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
785:    def test_validate_range_adjacent_custom_violation_error_code(self):
786:        constraint = ExclusionConstraint(
787:            name="ints_adjacent",
788:            expressions=[("ints", RangeOperators.ADJACENT_TO)],
789:            violation_error_code="ints_adjacent",
790:        )
791:        RangesModel.objects.create(ints=(20, 50))
792:        with self.assertRaises(ValidationError) as cm:
793:            constraint.validate(RangesModel, RangesModel(ints=(10, 20)))
794:        self.assertEqual(cm.exception.code, "ints_adjacent")
795:
796:    def test_expressions_with_params(self):
797:        constraint_name = "scene_left_equal"
798:        self.assertNotIn(constraint_name, self.get_constraints(Scene._meta.db_table))
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py constraints --verbosity 1 2>&1 | tail -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python -m compileall -q django/db/models/constraints.py django/contrib/postgres/constraints.py && git diff --check"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 79 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
...........................s.......................sss.........................
----------------------------------------------------------------------
Ran 79 tests in 0.112s

OK (skipped=4)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain -- . ':(exclude).memdoor'; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
 M django/contrib/postgres/constraints.py
 M django/db/models/constraints.py
 M docs/ref/contrib/postgres/constraints.txt
 M docs/ref/models/constraints.txt
 M docs/releases/5.0.txt
 M tests/constraints/tests.py
 M tests/postgres_tests/test_constraints.py
TASK_OK
```

**assistant**

```
Implemented `violation_error_code` support for constraints.

Changes:
- Added `violation_error_code` to `BaseConstraint`, `CheckConstraint`, `UniqueConstraint`, and PostgreSQL `ExclusionConstraint`.
- Passed the code through to every `ValidationError` raised by constraint validation.
- Included the code in `deconstruct()`, `clone()`, `__eq__()`, and `__repr__()`.
- Updated model constraint documentation, PostgreSQL constraint docs, and Django 5.0 release notes.
- Added tests covering construction, cloning, deconstruction, repr, equality, and validation error codes.

Verification:
- `python tests/runtests.py constraints` — 79 tests passed (4 skipped).
- `git diff --check` — clean.
- Required task command exits 0.
```

## Run folder `single-2026-11-06T112617`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

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
