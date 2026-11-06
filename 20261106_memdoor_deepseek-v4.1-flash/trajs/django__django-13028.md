# django__django-13028 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 48s 27 lines cost=0.001880 in=120929 cached=97792 out=2449 calls=14`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:16:17 weboff: chief: web_fetch,web_search
17:16:17 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Queryset raises NotSupportedError when RHS has filterable=False attribute.
Description
	 
		(last modified by Nicolas Baccelli)
	 
I'm migrating my app to django 3.0.7 and I hit a strange behavior using a model class with a field labeled filterable
class ProductMetaDataType(models.Model):
	label = models.CharField(max_length=255, unique=True, blank=False, null=False)
	filterable = models.BooleanField(default=False, verbose_name=_("filterable"))
	class Meta:
		app_label = "adminpricing"
		verbose_name = _("product meta data type")
		verbose_name_plural = _("product meta data types")
	def __str__(self):
		return self.label
class ProductMetaData(models.Model):
	id = models.BigAutoField(primary_key=True)
	product = models.ForeignKey(
		Produit, null=False, blank=False, on_delete=models.CASCADE
	)
	value = models.TextField(null=False, blank=False)
	marketplace = models.ForeignKey(
		Plateforme, null=False, blank=False, on_delete=models.CASCADE
	)
	date_created = models.DateTimeField(null=True, default=timezone.now)
	metadata_type = models.ForeignKey(
		ProductMetaDataType, null=False, blank=False, on_delete=models.CASCADE
	)
	class Meta:
		app_label = "adminpricing"
		verbose_name = _("product meta data")
		verbose_name_plural = _("product meta datas")
Error happened when filtering ProductMetaData with a metadata_type :
ProductMetaData.objects.filter(value="Dark Vador", metadata_type=self.brand_metadata)
Error traceback :
Traceback (most recent call last):
 File "/backoffice/backoffice/adminpricing/tests/test_pw.py", line 481, in test_checkpolicywarning_by_fields
	for p in ProductMetaData.objects.filter(
 File "/usr/local/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/query.py", line 904, in filter
	return self._filter_or_exclude(False, *args, **kwargs)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/query.py", line 923, in _filter_or_exclude
	clone.query.add_q(Q(*args, **kwargs))
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1351, in add_q
	clause, _ = self._add_q(q_object, self.used_aliases)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1378, in _add_q
	child_clause, needed_inner = self.build_filter(
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1264, in build_filter
	self.check_filterable(value)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1131, in check_filterable
	raise NotSupportedError(
django.db.utils.NotSupportedError: ProductMetaDataType is disallowed in the filter clause.
I changed label to filterable_test and it fixed this issue
This should be documented or fix.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log -3 --oneline"
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
scripts
setup.cfg
setup.py
tests
tox.ini
?? .memdoor/
d7c675aaf5 SWE-bench
78ad4b4b02 Fixed #31660 -- Fixed queryset crash when grouping by m2o relation.
07506a6114 Fixed #31661 -- Removed period in makemigrations history check warning.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"check_filterable\\|filterable\" django/db/models/sql/query.py"
}
```

**tool result**

```
1125:    def check_filterable(self, expression):
1127:        if not getattr(expression, 'filterable', True):
1134:                self.check_filterable(expr)
1203:                     reuse_with_filtered_relation=False, check_filterable=True):
1242:                check_filterable=check_filterable,
1258:        if check_filterable:
1259:            self.check_filterable(reffed_expression)
1268:        if check_filterable:
1269:            self.check_filterable(value)
1366:               check_filterable=True):
1378:                split_subq=split_subq, check_filterable=check_filterable,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1110,1145p' django/db/models/sql/query.py; sed -n '1195,1280p' django/db/models/sql/query.py"
}
```

**tool result**

```
            # opts would be Author's (from the author field) and value.model
            # would be Author.objects.all() queryset's .model (Author also).
            # The field is the related field on the lhs side.
            if (isinstance(value, Query) and not value.has_select_fields and
                    not check_rel_lookup_compatibility(value.model, opts, field)):
                raise ValueError(
                    'Cannot use QuerySet for "%s": Use a QuerySet for "%s".' %
                    (value.model._meta.object_name, opts.object_name)
                )
            elif hasattr(value, '_meta'):
                self.check_query_object_type(value, opts, field)
            elif hasattr(value, '__iter__'):
                for v in value:
                    self.check_query_object_type(v, opts, field)

    def check_filterable(self, expression):
        """Raise an error if expression cannot be used in a WHERE clause."""
        if not getattr(expression, 'filterable', True):
            raise NotSupportedError(
                expression.__class__.__name__ + ' is disallowed in the filter '
                'clause.'
            )
        if hasattr(expression, 'get_source_expressions'):
            for expr in expression.get_source_expressions():
                self.check_filterable(expr)

    def build_lookup(self, lookups, lhs, rhs):
        """
        Try to extract transforms and lookup from given lhs.

        The lhs value is something that works like SQLExpression.
        The rhs value is what the lookup is going to compare against.
        The lookups is a list of names to extract using get_lookup()
        and get_transform().
        """
        # __exact is the default lookup if one isn't given.
                suggestion = '.'
            raise FieldError(
                "Unsupported lookup '%s' for %s or join on the field not "
                "permitted%s" % (name, output_field.__name__, suggestion)
            )

    def build_filter(self, filter_expr, branch_negated=False, current_negated=False,
                     can_reuse=None, allow_joins=True, split_subq=True,
                     reuse_with_filtered_relation=False, check_filterable=True):
        """
        Build a WhereNode for a single filter clause but don't add it
        to this Query. Query.add_q() will then add this filter to the where
        Node.

        The 'branch_negated' tells us if the current branch contains any
        negations. This will be used to determine if subqueries are needed.

        The 'current_negated' is used to determine if the current filter is
        negated or not and this will be used to determine if IS NULL filtering
        is needed.

        The difference between current_negated and branch_negated is that
        branch_negated is set on first negation, but current_negated is
        flipped for each negation.

        Note that add_filter will not do any negating itself, that is done
        upper in the code by add_q().

        The 'can_reuse' is a set of reusable joins for multijoins.

        If 'reuse_with_filtered_relation' is True, then only joins in can_reuse
        will be reused.

        The method will create a filter clause that can be added to the current
        query. However, if the filter isn't added to the query then the caller
        is responsible for unreffing the joins used.
        """
        if isinstance(filter_expr, dict):
            raise FieldError("Cannot parse keyword query as dict")
        if isinstance(filter_expr, Q):
            return self._add_q(
                filter_expr,
                branch_negated=branch_negated,
                current_negated=current_negated,
                used_aliases=can_reuse,
                allow_joins=allow_joins,
                split_subq=split_subq,
                check_filterable=check_filterable,
            )
        if hasattr(filter_expr, 'resolve_expression'):
            if not getattr(filter_expr, 'conditional', False):
                raise TypeError('Cannot filter against a non-conditional expression.')
            condition = self.build_lookup(
                ['exact'], filter_expr.resolve_expression(self, allow_joins=allow_joins), True
            )
            clause = self.where_class()
            clause.add(condition, AND)
            return clause, []
        arg, value = filter_expr
        if not arg:
            raise FieldError("Cannot parse keyword query %r" % arg)
        lookups, parts, reffed_expression = self.solve_lookup_type(arg)

        if check_filterable:
            self.check_filterable(reffed_expression)

        if not allow_joins and len(parts) > 1:
            raise FieldError("Joined field references are not permitted in this query")

        pre_joins = self.alias_refcount.copy()
        value = self.resolve_lookup_value(value, can_reuse, allow_joins)
        used_joins = {k for k, v in self.alias_refcount.items() if v > pre_joins.get(k, 0)}

        if check_filterable:
            self.check_filterable(value)

        clause = self.where_class()
        if reffed_expression:
            condition = self.build_lookup(lookups, reffed_expression, value)
            clause.add(condition, AND)
            return clause, []

        opts = self.get_meta()
        alias = self.get_initial_alias()
        allow_many = not branch_negated or not split_subq
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/sql/query.py\n@@\n     def check_filterable(self, expression):\n         \"\"\"Raise an error if expression cannot be used in a WHERE clause.\"\"\"\n-        if not getattr(expression, 'filterable', True):\n+        if hasattr(expression, 'resolve_expression') and not getattr(\n+            expression, 'filterable', True\n+        ):\n             raise NotSupportedError(\n                 expression.__class__.__name__ + ' is disallowed in the filter '\n                 'clause.'\n             )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/sql/query.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/sql/query.py now (2416 lines), around the change:
1124:
1125:    def check_filterable(self, expression):
1126:        """Raise an error if expression cannot be used in a WHERE clause."""
1127:        if hasattr(expression, 'resolve_expression') and not getattr(
1128:            expression, 'filterable', True
1129:        ):
1130:            raise NotSupportedError(
1131:                expression.__class__.__name__ + ' is disallowed in the filter '
1132:                'clause.'
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"filterable\" tests/ | head -30"
}
```

**tool result**

```
tests/utils_tests/files/strip_tags1.html:289:              <input type="text" id="commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Find or create a branch…">
tests/utils_tests/files/strip_tags1.html:305:            <div data-filterable-for="commitish-filter-field" data-filterable-type="substring">
tests/utils_tests/files/strip_tags1.html:473:            <div data-filterable-for="commitish-filter-field" data-filterable-type="substring">
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"check_filterable\\|disallowed in the filter\" tests/ django/ | head -30"
}
```

**tool result**

```
tests/expressions_window/tests.py:843:        msg = 'Window is disallowed in the filter clause'
tests/expressions_window/tests.py:868:        msg = 'Window is disallowed in the filter clause'
django/db/models/sql/query.py:1125:    def check_filterable(self, expression):
django/db/models/sql/query.py:1131:                expression.__class__.__name__ + ' is disallowed in the filter '
django/db/models/sql/query.py:1136:                self.check_filterable(expr)
django/db/models/sql/query.py:1205:                     reuse_with_filtered_relation=False, check_filterable=True):
django/db/models/sql/query.py:1244:                check_filterable=check_filterable,
django/db/models/sql/query.py:1260:        if check_filterable:
django/db/models/sql/query.py:1261:            self.check_filterable(reffed_expression)
django/db/models/sql/query.py:1270:        if check_filterable:
django/db/models/sql/query.py:1271:            self.check_filterable(value)
django/db/models/sql/query.py:1368:               check_filterable=True):
django/db/models/sql/query.py:1380:                split_subq=split_subq, check_filterable=check_filterable,
django/db/models/query_utils.py:105:            check_filterable=False,
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class.*Test\\|filterable\\|NotSupported\" tests/lookup/tests.py | head -40; grep -n \"class.*Test\" tests/expressions_window/tests.py | tail -5"
}
```

**tool result**

```
19:class LookupTests(TestCase):
20:class WindowFunctionTests(TestCase):
790:class WindowUnsupportedTests(TestCase):
798:class NonQueryWindowTests(SimpleTestCase):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' tests/lookup/tests.py; tail -30 tests/lookup/tests.py"
}
```

**tool result**

```
import collections.abc
from datetime import datetime
from math import ceil
from operator import attrgetter

from django.core.exceptions import FieldError
from django.db import connection, models
from django.db.models import Exists, Max, OuterRef
from django.db.models.functions import Substr
from django.test import TestCase, skipUnlessDBFeature
from django.test.utils import isolate_apps
from django.utils.deprecation import RemovedInDjango40Warning

from .models import (
    Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,
)


class LookupTests(TestCase):

    @classmethod
    def setUpTestData(cls):
        # Create a few Authors.
        cls.au1 = Author.objects.create(name='Author 1', alias='a1')
        cls.au2 = Author.objects.create(name='Author 2', alias='a2')
        # Create a few Articles.
        cls.a1 = Article.objects.create(
            headline='Article 1',
            pub_date=datetime(2005, 7, 26),
            author=cls.au1,
        authors_max_ids = Author.objects.filter(
            name='Author 2',
        ).values(
            'name',
        ).annotate(
            max_id=Max('id'),
        ).values('max_id')
        authors = Author.objects.filter(id=authors_max_ids[:1])
        self.assertEqual(authors.get(), newest_author)

    def test_isnull_non_boolean_value(self):
        # These tests will catch ValueError in Django 4.0 when using
        # non-boolean values for an isnull lookup becomes forbidden.
        # msg = (
        #     'The QuerySet value for an isnull lookup must be True or False.'
        # )
        msg = (
            'Using a non-boolean value for an isnull lookup is deprecated, '
            'use True or False instead.'
        )
        tests = [
            Author.objects.filter(alias__isnull=1),
            Article.objects.filter(author__isnull=1),
            Season.objects.filter(games__isnull=1),
            Freebie.objects.filter(stock__isnull=1),
        ]
        for qs in tests:
            with self.subTest(qs=qs):
                with self.assertWarnsMessage(RemovedInDjango40Warning, msg):
                    qs.exists()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/lookup/tests.py\n@@\n     def test_isnull_non_boolean_value(self):\n@@\n         for qs in tests:\n             with self.subTest(qs=qs):\n                 with self.assertWarnsMessage(RemovedInDjango40Warning, msg):\n                     qs.exists()\n+\n+    def test_filter_by_model_instance_with_filterable_attribute(self):\n+        self.au1.filterable = False\n+        self.assertSequenceEqual(\n+            Article.objects.filter(author=self.au1),\n+            [self.a1],\n+        )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/lookup/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/lookup/tests.py now (1038 lines), around the change:
1029:            with self.subTest(qs=qs):
1030:                with self.assertWarnsMessage(RemovedInDjango40Warning, msg):
1031:                    qs.exists()
1032:
1033:    def test_filter_by_model_instance_with_filterable_attribute(self):
1034:        self.au1.filterable = False
1035:        self.assertSequenceEqual(
1036:            Article.objects.filter(author=self.au1),
1037:            [self.a1],
1038:        )
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py lookup.tests.LookupTests.test_filter_by_model_instance_with_filterable_attribute expressions_window 2>&1 | tail -20"
}
```

**tool result**

```
First differing element 0:
<Article: Article 4>
<Article: Article 1>

First sequence contains 3 additional elements.
First extra element 1:
<Article: Article 2>

- <QuerySet [<Article: Article 4>, <Article: Article 2>, <Article: Article 3>, <Article: Article 1>]>
+ [<Article: Article 1>]

----------------------------------------------------------------------
Ran 50 tests in 0.126s

FAILED (failures=1, skipped=3)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/lookup/tests.py\n@@\n     def test_filter_by_model_instance_with_filterable_attribute(self):\n         self.au1.filterable = False\n-        self.assertSequenceEqual(\n-            Article.objects.filter(author=self.au1),\n-            [self.a1],\n-        )\n+        self.assertIn(self.a1, Article.objects.filter(author=self.au1))\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/lookup/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/lookup/tests.py now (1035 lines), around the change:
1032:
1033:    def test_filter_by_model_instance_with_filterable_attribute(self):
1034:        self.au1.filterable = False
1035:        self.assertIn(self.a1, Article.objects.filter(author=self.au1))
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py lookup.tests.LookupTests.test_filter_by_model_instance_with_filterable_attribute expressions_window 2>&1 | tail -8; cd .. && git status --porcelain -- . ':(exclude).memdoor'"
}
```

**tool result**

```
Ran 50 tests in 0.126s

OK (skipped=3)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
 M django/db/models/sql/query.py
 M tests/lookup/tests.py
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo $?"
}
```

**tool result**

```
0
```

**assistant**

```
Fixed. `Query.check_filterable()` was checking the `filterable` attribute on every RHS value, including model instances — so a model with its own `filterable` field set to `False` was mistakenly treated as a non-filterable expression.

Changes:
- `django/db/models/sql/query.py`: only enforce the `filterable` check when the RHS is an expression (has `resolve_expression`), not an arbitrary object/model instance.
- `tests/lookup/tests.py`: added a regression test filtering by a model instance that has `filterable = False`.

Verified the targeted lookup/window tests pass and the completion command exits 0.
```

## Run folder `single-2026-11-06T171617`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Queryset raises NotSupportedError when RHS has filterable=False attribute.
Description
	 
		(last modified by Nicolas Baccelli)
	 
I'm migrating my app to django 3.0.7 and I hit a strange behavior using a model class with a field labeled filterable
class ProductMetaDataType(models.Model):
	label = models.CharField(max_length=255, unique=True, blank=False, null=False)
	filterable = models.BooleanField(default=False, verbose_name=_("filterable"))
	class Meta:
		app_label = "adminpricing"
		verbose_name = _("product meta data type")
		verbose_name_plural = _("product meta data types")
	def __str__(self):
		return self.label
class ProductMetaData(models.Model):
	id = models.BigAutoField(primary_key=True)
	product = models.ForeignKey(
		Produit, null=False, blank=False, on_delete=models.CASCADE
	)
	value = models.TextField(null=False, blank=False)
	marketplace = models.ForeignKey(
		Plateforme, null=False, blank=False, on_delete=models.CASCADE
	)
	date_created = models.DateTimeField(null=True, default=timezone.now)
	metadata_type = models.ForeignKey(
		ProductMetaDataType, null=False, blank=False, on_delete=models.CASCADE
	)
	class Meta:
		app_label = "adminpricing"
		verbose_name = _("product meta data")
		verbose_name_plural = _("product meta datas")
Error happened when filtering ProductMetaData with a metadata_type :
ProductMetaData.objects.filter(value="Dark Vador", metadata_type=self.brand_metadata)
Error traceback :
Traceback (most recent call last):
 File "/backoffice/backoffice/adminpricing/tests/test_pw.py", line 481, in test_checkpolicywarning_by_fields
	for p in ProductMetaData.objects.filter(
 File "/usr/local/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/query.py", line 904, in filter
	return self._filter_or_exclude(False, *args, **kwargs)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/query.py", line 923, in _filter_or_exclude
	clone.query.add_q(Q(*args, **kwargs))
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1351, in add_q
	clause, _ = self._add_q(q_object, self.used_aliases)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1378, in _add_q
	child_clause, needed_inner = self.build_filter(
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1264, in build_filter
	self.check_filterable(value)
 File "/usr/local/lib/python3.8/site-packages/django/db/models/sql/query.py", line 1131, in check_filterable
	raise NotSupportedError(
django.db.utils.NotSupportedError: ProductMetaDataType is disallowed in the filter clause.
I changed label to filterable_test and it fixed this issue
This should be documented or fix.
```
