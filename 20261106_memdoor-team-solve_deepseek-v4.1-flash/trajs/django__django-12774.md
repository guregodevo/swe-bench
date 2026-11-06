# django__django-12774 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=2 1685s 75 lines cost=0.025956 in=752872 cached=539648 out=47765 calls=49`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Allow QuerySet.in_bulk() for fields with total UniqueConstraints.
Description
	
If a field is unique by UniqueConstraint instead of unique=True running in_bulk() on that field will fail.
Consider:
class Article(models.Model):
	slug = models.CharField(max_length=255)
	
	class Meta:
		constraints = [
			models.UniqueConstraint(fields=["slug"], name="%(app_label)s_%(class)s_slug_unq")
		]
>>> Article.objects.in_bulk(field_name="slug")
Traceback (most recent call last):
 File "/usr/local/lib/python3.8/code.py", line 90, in runcode
	exec(code, self.locals)
 File "<console>", line 1, in <module>
 File "/app/venv/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/app/venv/lib/python3.8/site-packages/django/db/models/query.py", line 680, in in_bulk
	raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
ValueError: in_bulk()'s field_name must be a unique field but 'slug' isn't.
It should be pretty simple to fix this and I have a patch if accepted.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --short && git log -1 --oneline"
}
```

**assistant → tool `grep`**

```json
{
  "pattern": "def in_bulk",
  "path": "django/db/models/query.py",
  "output_mode": "content",
  "head_limit": 10
}
```

**tool result**

```
/testbed
?? .memdoor/
fa3a0522ec SWE-bench
```

**tool result**

```
/testbed/django/db/models/query.py:    def in_bulk(self, id_list=None, *, field_name='pk'):
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/django/db/models/query.py",
  "offset": 650,
  "limit": 75
}
```

**tool result**

```
            order_by = fields
        else:
            order_by = getattr(self.model._meta, 'get_latest_by')
            if order_by and not isinstance(order_by, (tuple, list)):
                order_by = (order_by,)
        if order_by is None:
            raise ValueError(
                "earliest() and latest() require either fields as positional "
                "arguments or 'get_latest_by' in the model's Meta."
            )

        assert not self.query.is_sliced, \
            "Cannot change a query once a slice has been taken."
        obj = self._chain()
        obj.query.set_limits(high=1)
        obj.query.clear_ordering(force_empty=True)
        obj.query.add_ordering(*order_by)
        return obj.get()

    def earliest(self, *fields):
        return self._earliest(*fields)

    def latest(self, *fields):
        return self.reverse()._earliest(*fields)

    def first(self):
        """Return the first object of a query or None if no match is found."""
        for obj in (self if self.ordered else self.order_by('pk'))[:1]:
            return obj

    def last(self):
        """Return the last object of a query or None if no match is found."""
        for obj in (self.reverse() if self.ordered else self.order_by('-pk'))[:1]:
            return obj

    def in_bulk(self, id_list=None, *, field_name='pk'):
        """
        Return a dictionary mapping each of the given IDs to the object with
        that ID. If `id_list` isn't provided, evaluate the entire QuerySet.
        """
        assert not self.query.is_sliced, \
            "Cannot use 'limit' or 'offset' with in_bulk"
        if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
        if id_list is not None:
            if not id_list:
                return {}
            filter_key = '{}__in'.format(field_name)
            batch_size = connections[self.db].features.max_query_params
            id_list = tuple(id_list)
            # If the database has a limit on the number of query parameters
            # (e.g. SQLite), retrieve objects in batches if necessary.
            if batch_size and batch_size < len(id_list):
                qs = ()
                for offset in range(0, len(id_list), batch_size):
                    batch = id_list[offset:offset + batch_size]
                    qs += tuple(self.filter(**{filter_key: batch}).order_by())
            else:
                qs = self.filter(**{filter_key: id_list}).order_by()
        else:
            qs = self._chain()
        return {getattr(obj, field_name): obj for obj in qs}

    def delete(self):
        """Delete the records in the current QuerySet."""
        self._not_support_combined_queries('delete')
        assert not self.query.is_sliced, \
            "Cannot use 'limit' or 'offset' with delete."

        if self._fields is not None:
            raise TypeError("Cannot call delete() after .values() or .values_list()")

        del_query = self._chain()

        # The delete is actually 2 queries - one to find related objects,

[1242 more lines in /testbed/django/db/models/query.py (1966 in all). read_file with offset: 725 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"total_unique_constraints\\|unique_together\\|UniqueConstraint\" django/db/models/options.py django/db/models/constraints.py | head -50"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"in_bulk\" tests | head -30"
}
```

**tool result**

```
django/db/models/options.py:10:from django.db.models import AutoField, Manager, OrderWrt, UniqueConstraint
django/db/models/options.py:28:    'unique_together', 'permissions', 'get_latest_by', 'order_with_respect_to',
django/db/models/options.py:89:        self.unique_together = []
django/db/models/options.py:179:            self.unique_together = normalize_together(self.unique_together)
django/db/models/options.py:832:    def total_unique_constraints(self):
django/db/models/options.py:840:            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
django/db/models/constraints.py:4:__all__ = ['CheckConstraint', 'UniqueConstraint']
django/db/models/constraints.py:72:class UniqueConstraint(BaseConstraint):
django/db/models/constraints.py:77:            raise ValueError('UniqueConstraint.condition must be a Q instance.')
django/db/models/constraints.py:112:        if isinstance(other, UniqueConstraint):
```

**tool result**

```
tests/or_lookups/tests.py:238:            Article.objects.filter(Q(headline__startswith='Hello')).in_bulk([self.a1, self.a2]),
tests/prefetch_related/tests.py:1209:    def test_in_bulk(self):
tests/prefetch_related/tests.py:1218:            bulk = Employee.objects.prefetch_related('serfs').in_bulk([boss1.pk, boss2.pk])
tests/basic/tests.py:579:        'in_bulk',
tests/lookup/tests.py:145:    def test_in_bulk(self):
tests/lookup/tests.py:146:        # in_bulk() takes a list of IDs and returns a dictionary mapping IDs to objects.
tests/lookup/tests.py:147:        arts = Article.objects.in_bulk([self.a1.id, self.a2.id])
tests/lookup/tests.py:151:            Article.objects.in_bulk(),
tests/lookup/tests.py:162:        self.assertEqual(Article.objects.in_bulk([self.a3.id]), {self.a3.id: self.a3})
tests/lookup/tests.py:163:        self.assertEqual(Article.objects.in_bulk({self.a3.id}), {self.a3.id: self.a3})
tests/lookup/tests.py:164:        self.assertEqual(Article.objects.in_bulk(frozenset([self.a3.id])), {self.a3.id: self.a3})
tests/lookup/tests.py:165:        self.assertEqual(Article.objects.in_bulk((self.a3.id,)), {self.a3.id: self.a3})
tests/lookup/tests.py:166:        self.assertEqual(Article.objects.in_bulk([1000]), {})
tests/lookup/tests.py:167:        self.assertEqual(Article.objects.in_bulk([]), {})
tests/lookup/tests.py:168:        self.assertEqual(Article.objects.in_bulk(iter([self.a1.id])), {self.a1.id: self.a1})
tests/lookup/tests.py:169:        self.assertEqual(Article.objects.in_bulk(iter([])), {})
tests/lookup/tests.py:171:            Article.objects.in_bulk(headline__startswith='Blah')
tests/lookup/tests.py:173:    def test_in_bulk_lots_of_ids(self):
tests/lookup/tests.py:180:            self.assertEqual(Author.objects.in_bulk(authors), authors)
tests/lookup/tests.py:182:    def test_in_bulk_with_field(self):
tests/lookup/tests.py:184:            Article.objects.in_bulk([self.a1.slug, self.a2.slug, self.a3.slug], field_name='slug'),
tests/lookup/tests.py:192:    def test_in_bulk_non_unique_field(self):
tests/lookup/tests.py:193:        msg = "in_bulk()'s field_name must be a unique field but 'author' isn't."
tests/lookup/tests.py:195:            Article.objects.in_bulk([self.au1], field_name='author')
tests/custom_pk/tests.py:151:    def test_in_bulk(self):
tests/custom_pk/tests.py:153:        Custom pks work with in_bulk, both for integer and non-integer types
tests/custom_pk/tests.py:155:        emps = Employee.objects.in_bulk([123, 456])
tests/custom_pk/tests.py:158:        self.assertEqual(Business.objects.in_bulk(["Sears"]), {
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/django/db/models/options.py",
  "offset": 820,
  "limit": 35
}
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/tests/lookup/tests.py",
  "offset": 180,
  "limit": 25
}
```

**tool result**

```
            if topmost_call:
                fields += self.private_fields

        # In order to avoid list manipulation. Always
        # return a shallow copy of the results
        fields = make_immutable_fields_list("get_fields()", fields)

        # Store result into cache for later access
        self._get_fields_cache[cache_key] = fields
        return fields

    @cached_property
    def total_unique_constraints(self):
        """
        Return a list of total unique constraints. Useful for determining set
        of fields guaranteed to be unique for all rows.
        """
        return [
            constraint
            for constraint in self.constraints
            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
        ]

    @cached_property
    def _property_names(self):
        """Return a set of the names of the properties defined on the model."""
        names = []
        for name in dir(self.model):
            attr = inspect.getattr_static(self.model, name)
            if isinstance(attr, property):
                names.append(name)
        return frozenset(names)

    @cached_property
    def db_returning_fields(self):

[8 more lines in /testbed/django/db/models/options.py (862 in all). read_file with offset: 855 to continue]
```

**tool result**

```
            self.assertEqual(Author.objects.in_bulk(authors), authors)

    def test_in_bulk_with_field(self):
        self.assertEqual(
            Article.objects.in_bulk([self.a1.slug, self.a2.slug, self.a3.slug], field_name='slug'),
            {
                self.a1.slug: self.a1,
                self.a2.slug: self.a2,
                self.a3.slug: self.a3,
            }
        )

    def test_in_bulk_non_unique_field(self):
        msg = "in_bulk()'s field_name must be a unique field but 'author' isn't."
        with self.assertRaisesMessage(ValueError, msg):
            Article.objects.in_bulk([self.au1], field_name='author')

    def test_values(self):
        # values() returns a list of dictionaries instead of object instances --
        # and you can specify which fields you want to retrieve.
        self.assertSequenceEqual(
            Article.objects.values('headline'),
            [
                {'headline': 'Article 5'},
                {'headline': 'Article 6'},

[788 more lines in /testbed/tests/lookup/tests.py (992 in all). read_file with offset: 205 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/db/models/query.py\n@@\n         assert not self.query.is_sliced, \\\n             \"Cannot use 'limit' or 'offset' with in_bulk\"\n         if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:\n-            raise ValueError(\"in_bulk()'s field_name must be a unique field but %r isn't.\" % field_name)\n+            field_names = [\n+                field_name\n+                for constraint in self.model._meta.total_unique_constraints\n+                if len(constraint.fields) == 1\n+                for field_name in constraint.fields\n+            ]\n+            if field_name not in field_names:\n+                raise ValueError(\n+                    \"in_bulk()'s field_name must be a unique field but %r \"\n+                    \"isn't.\" % field_name\n+                )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/db/models/query.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/db/models/query.py now (1976 lines), around the change:
690:        assert not self.query.is_sliced, \
691:            "Cannot use 'limit' or 'offset' with in_bulk"
692:        if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
693:            field_names = [
694:                field_name
695:                for constraint in self.model._meta.total_unique_constraints
696:                if len(constraint.fields) == 1
697:                for field_name in constraint.fields
698:            ]
699:            if field_name not in field_names:
700:                raise ValueError(
701:                    "in_bulk()'s field_name must be a unique field but %r "
702:                    "isn't." % field_name
703:                )
704:        if id_list is not None:
705:            if not id_list:
706:                return {}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py lookup.tests.LookupTests.test_in_bulk lookup.tests.LookupTests.test_in_bulk_non_unique_field lookup.tests.LookupTests.test_in_bulk_with_field --verbosity 1"
}
```

**tool result**

```
Creating test database for alias 'default'...
...
----------------------------------------------------------------------
Ran 3 tests in 0.013s

OK
Destroying test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"class Article\\|slug = models\\|UniqueConstraint\\|constraints\" tests/lookup/models.py | head -40 && sed -n '1,90p' tests/lookup/models.py"
}
```

**tool result**

```
27:class Article(models.Model):
31:    slug = models.SlugField(unique=True, blank=True, null=True)
"""
The lookup API

This demonstrates features of the database API.
"""

from django.db import models
from django.db.models.lookups import IsNull


class Alarm(models.Model):
    desc = models.CharField(max_length=100)
    time = models.TimeField()

    def __str__(self):
        return '%s (%s)' % (self.time, self.desc)


class Author(models.Model):
    name = models.CharField(max_length=100)
    alias = models.CharField(max_length=50, null=True, blank=True)

    class Meta:
        ordering = ('name',)


class Article(models.Model):
    headline = models.CharField(max_length=100)
    pub_date = models.DateTimeField()
    author = models.ForeignKey(Author, models.SET_NULL, blank=True, null=True)
    slug = models.SlugField(unique=True, blank=True, null=True)

    class Meta:
        ordering = ('-pub_date', 'headline')

    def __str__(self):
        return self.headline


class Tag(models.Model):
    articles = models.ManyToManyField(Article)
    name = models.CharField(max_length=100)

    class Meta:
        ordering = ('name',)


class NulledTextField(models.TextField):
    def get_prep_value(self, value):
        return None if value == '' else value


@NulledTextField.register_lookup
class NulledTransform(models.Transform):
    lookup_name = 'nulled'
    template = 'NULL'


@NulledTextField.register_lookup
class IsNullWithNoneAsRHS(IsNull):
    lookup_name = 'isnull_none_rhs'
    can_use_none_as_rhs = True


class Season(models.Model):
    year = models.PositiveSmallIntegerField()
    gt = models.IntegerField(null=True, blank=True)
    nulled_text_field = NulledTextField(null=True)

    def __str__(self):
        return str(self.year)


class Game(models.Model):
    season = models.ForeignKey(Season, models.CASCADE, related_name='games')
    home = models.CharField(max_length=100)
    away = models.CharField(max_length=100)

    def __str__(self):
        return "%s at %s" % (self.away, self.home)


class Player(models.Model):
    name = models.CharField(max_length=100)
    games = models.ManyToManyField(Game, related_name='players')

    def __str__(self):
        return self.name
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/lookup/models.py\n@@\n class Article(models.Model):\n@@\n     def __str__(self):\n         return self.headline\n \n \n+class UniqueConstraintArticle(models.Model):\n+    slug = models.SlugField()\n+\n+    class Meta:\n+        constraints = [\n+            models.UniqueConstraint(\n+                fields=['slug'],\n+                name='lookup_unique_constraint_article_slug',\n+            ),\n+        ]\n+\n+\n class Tag(models.Model):\n*** Update File: /testbed/tests/lookup/tests.py\n@@\n-from .models import Article, Author, Game, Player, Season, Tag\n+from .models import Article, Author, Game, Player, Season, Tag, UniqueConstraintArticle\n@@\n     def test_in_bulk_non_unique_field(self):\n         msg = \"in_bulk()'s field_name must be a unique field but 'author' isn't.\"\n         with self.assertRaisesMessage(ValueError, msg):\n             Article.objects.in_bulk([self.au1], field_name='author')\n \n+    def test_in_bulk_unique_constraint_field(self):\n+        obj1 = UniqueConstraintArticle.objects.create(slug='a')\n+        obj2 = UniqueConstraintArticle.objects.create(slug='b')\n+        self.assertEqual(\n+            UniqueConstraintArticle.objects.in_bulk(\n+                [obj1.slug, obj2.slug], field_name='slug',\n+            ),\n+            {obj1.slug: obj1, obj2.slug: obj2},\n+        )\n+\n     def test_values(self):\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update /testbed/tests/lookup/tests.py: failed to find expected lines in /testbed/tests/lookup/tests.py:
from .models import Article, Author, Game, Player, Season, Tag

The file's ACTUAL current content is below. Copy your context lines from THIS exact text — do not edit from memory:
1	import collections.abc
2	from datetime import datetime
3	from math import ceil
4	from operator import attrgetter
5	
6	from django.core.exceptions import FieldError
7	from django.db import connection
8	from django.db.models import Exists, Max, OuterRef
9	from django.db.models.functions import Substr
10	from django.test import TestCase, skipUnlessDBFeature
11	from django.utils.deprecation import RemovedInDjango40Warning
12	
13	from .models import (
14	    Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,
15	)
16	
17	
18	class LookupTests(TestCase):
19	
20	    @classmethod
21	    def setUpTestData(cls):
22	        # Create a few Authors.
23	        cls.au1 = Author.objects.create(name='Author 1', alias='a1')
24	        cls.au2 = Author.objects.create(name='Author 2', alias='a2')
25	        # Create a few Articles.
26	        cls.a1 = Article.objects.create(
27	            headline='Article 1',
28	            pub_date=datetime(2005, 7, 26),
29	            author=cls.au1,
30	            slug='a1',
31	        )
32	        cls.a2 = Article.objects.create(
33	            headline='Article 2',
34	            pub_date=datetime(2005, 7, 27),
35	            author=cls.au1,
36	            slug='a2',
37	        )
38	        cls.a3 = Article.objects.create(
39	            headline='Article 3',
40	            pub_date=datetime(2005, 7, 27),
41	            author=cls.au1,
42	            slug='a3',
43	        )
44	        cls.a4 = Article.objects.create(
45	            headline='Article 4',
46	            pub_date=datetime(2005, 7, 28),
47	            author=cls.au1,
48	            slug='a4',
49	        )
50	        cls.a5 = Article.objects.create(
51	            headline='Article 5',
52	            pub_date=datetime(2005, 8, 1, 9, 0),
53	            author=cls.au2,
54	            slug='a5',
55	        )
56	        cls.a6 = Article.objects.create(
57	            headline='Article 6',
58	            pub_date=datetime(2005, 8, 1, 8, 0),
59	            author=cls.au2,
60	            slug='a6',
61	        )
62	        cls.a7 = Article.objects.create(
63	            headline='Article 7',
64	            pub_date=datetime(2005, 7, 27),
65	            author=cls.au2,
66	            slug='a7',
67	        )
68	        # Create a few Tags.
69	        cls.t1 = Tag.objects.create(name='Tag 1')
70	        cls.t1.articles.add(cls.a1, cls.a2, cls.a3)
71	        cls.t2 = Tag.objects.create(name='Tag 2')
72	        cls.t2.articles.add(cls.a3, cls.a4, cls.a5)
73	        cls.t3 = Tag.objects.create(name='Tag 3')
74	        cls.t3.articles.add(cls.a5, cls.a6, cls.a7)
75	
76	    def test_exists(self):
77	        # We can use .exists() to check that there are some
78	        self.assertTrue(Article.objects.exists())
79	        for a in Article.objects.all():
80	            a.delete()
81	        # There should be none now!
82	        self.assertFalse(Article.objects.exists())
83	
84	    def test_lookup_int_as_str(self):
85	        # Integer value can be queried using string
86	        self.assertQuerysetEqual(Article.objects.filter(id__iexact=str(self.a1.id)),
87	                                 ['<Article: Article 1>'])
88	
89	    @skipUnlessDBFeature('supports_date_lookup_using_string')
90	    def test_lookup_date_as_str(self):
91	        # A date lookup can be performed using a string search
92	        self.assertQuerysetEqual(
93	            Article.objects.filter(pub_date__startswith='2005'),
94	            [
95	                '<Article: Article 5>',
96	                '<Article: Article 6>',
97	                '<Article: Article 4>',
98	                '<Article: Article 2>',
99	                '<Article: Article 3>',
100	                '<Article: Article 7>',
101	                '<Article: Article 1>',
102	            ]
103	        )
104	
105	    def test_iterator(self):
106	        # Each QuerySet gets iterator(), which is a generator that "lazily"
107	        # returns results using database-level iteration.
108	        self.assertIsInstance(Article.objects.iterator(), collections.abc.Iterator)
109	
110	        self.assertQuerysetEqual(
111	            Article.objects.iterator(),
112	            [
113	                'Article 5',
114	                'Article 6',
115	                'Article 4',
116	                'Article 2',
117	                'Article 3',
118	                'Article 7',
119	                'Article 1',
120	            ],
121	            transform=attrgetter('headline')
122	        )
123	        # iterator() can be used on any QuerySet.
124	        self.assertQuerysetEqual(
125	            Article.objects.filter(headline__endswith='4').iterator(),
126	            ['Article 4'],
127	            transform=attrgetter('headline'))
128	
129	    def test_count(self):
130	        # count() returns the number of objects matching search criteria.
131	        self.assertEqual(Article.objects.count(), 7)
132	        self.assertEqual(Article.objects.filter(pub_date__exact=datetime(2005, 7, 27)).count(), 3)
133	        self.assertEqual(Article.objects.filter(headline__startswith='Blah blah').count(), 0)
134	
135	        # count() should respect sliced query sets.
136	        articles = Article.objects.all()
137	        self.assertEqual(articles.count(), 7)
138	        self.assertEqual(articles[:4].count(), 4)
139	        self.assertEqual(articles[1:100].count(), 6)
140	        self.assertEqual(articles[10:100].count(), 0)
141	
142	        # Date and date/time lookups can also be done with strings.
143	        self.assertEqual(Article.objects.filter(pub_date__exact='2005-07-27 00:00:00').count(), 3)
144	
145	    def test_in_bulk(self):
146	        # in_bulk() takes a list of IDs and returns a dictionary mapping IDs to objects.
147	        arts = Article.objects.in_bulk([self.a1.id, self.a2.id])
148	        self.assertEqual(arts[self.a1.id], self.a1)
149	        self.assertEqual(arts[self.a2.id], self.a2)
150	        self.assertEqual(
151	            Article.objects.in_bulk(),
152	            {
153	                self.a1.id: self.a1,
154	                self.a2.id: self.a2,
155	                self.a3.id: self.a3,
156	                self.a4.id: self.a4,
157	                self.a5.id: self.a5,
158	                self.a6.id: self.a6,
159	                self.a7.id: self.a7,
160	            }
161	        )
162	        self.assertEqual(Article.objects.in_bulk([self.a3.id]), {self.a3.id: self.a3})
163	        self.assertEqual(Article.objects.in_bulk({self.a3.id}), {self.a3.id: self.a3})
164	        self.assertEqual(Article.objects.in_bulk(frozenset([self.a3.id])), {self.a3.id: self.a3})
165	        self.assertEqual(Article.objects.in_bulk((self.a3.id,)), {self.a3.id: self.a3})
166	        self.assertEqual(Article.objects.in_bulk([1000]), {})
167	        self.assertEqual(Article.objects.in_bulk([]), {})
168	        self.assertEqual(Article.objects.in_bulk(iter([self.a1.id])), {self.a1.id: self.a1})
169	        self.assertEqual(Article.objects.in_bulk(iter([])), {})
170	        with self.assertRaises(TypeError):
171	            Article.objects.in_bulk(headline__startswith='Blah')
172	
173	    def test_in_bulk_lots_of_ids(self):
174	        test_range = 2000
175	        max_query_params = connection.features.max_query_params
176	        expected_num_queries = ceil(test_range / max_query_params) if max_query_params else 1
177	        Author.objects.bulk_create([Author() for i in range(test_range - Author.objects.count())])
178	        authors = {author.pk: author for author in Author.objects.all()}
179	        with self.assertNumQueries(expected_num_queries):
180	            self.assertEqual(Author.objects.in_bulk(authors), authors)
181	
182	    def test_in_bulk_with_field(self):
183	        self.assertEqual(
184	            Article.objects.in_bulk([self.a1.slug, self.a2.slug, self.a3.slug], field_name='slug'),
185	            {
186	                self.a1.slug: self.a1,
... (truncated; read_file for the rest)


Nothing in this patch was written — not /testbed/tests/lookup/models.py, /testbed/tests/lookup/tests.py. Fix it and resend the whole patch.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/lookup/models.py\n@@\n class Article(models.Model):\n@@\n     def __str__(self):\n         return self.headline\n \n \n+class UniqueConstraintArticle(models.Model):\n+    slug = models.SlugField()\n+\n+    class Meta:\n+        constraints = [\n+            models.UniqueConstraint(\n+                fields=['slug'],\n+                name='lookup_unique_constraint_article_slug',\n+            ),\n+        ]\n+\n+\n class Tag(models.Model):\n*** Update File: /testbed/tests/lookup/tests.py\n@@\n from .models import (\n-    Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,\n+    Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,\n+    UniqueConstraintArticle,\n )\n@@\n     def test_in_bulk_non_unique_field(self):\n         msg = \"in_bulk()'s field_name must be a unique field but 'author' isn't.\"\n         with self.assertRaisesMessage(ValueError, msg):\n             Article.objects.in_bulk([self.au1], field_name='author')\n \n+    def test_in_bulk_unique_constraint_field(self):\n+        obj1 = UniqueConstraintArticle.objects.create(slug='a')\n+        obj2 = UniqueConstraintArticle.objects.create(slug='b')\n+        self.assertEqual(\n+            UniqueConstraintArticle.objects.in_bulk(\n+                [obj1.slug, obj2.slug], field_name='slug',\n+            ),\n+            {obj1.slug: obj1, obj2.slug: obj2},\n+        )\n+\n     def test_values(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/lookup/models.py /testbed/tests/lookup/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/lookup/models.py now (122 lines), around the change:
35:
36:    def __str__(self):
37:        return self.headline
38:
39:
40:class UniqueConstraintArticle(models.Model):
41:    slug = models.SlugField()
42:
43:    class Meta:
44:        constraints = [
45:            models.UniqueConstraint(
46:                fields=['slug'],
47:                name='lookup_unique_constraint_article_slug',
48:            ),
49:        ]
50:
51:
52:class Tag(models.Model):

/testbed/tests/lookup/tests.py now (1003 lines), around the change:
12:
13:from .models import (
14:    Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,
15:    UniqueConstraintArticle,
16:)
17:
18:
…
194:        msg = "in_bulk()'s field_name must be a unique field but 'author' isn't."
195:        with self.assertRaisesMessage(ValueError, msg):
196:            Article.objects.in_bulk([self.au1], field_name='author')
197:
198:    def test_in_bulk_unique_constraint_field(self):
199:        obj1 = UniqueConstraintArticle.objects.create(slug='a')
200:        obj2 = UniqueConstraintArticle.objects.create(slug='b')
201:        self.assertEqual(
202:            UniqueConstraintArticle.objects.in_bulk(
203:                [obj1.slug, obj2.slug], field_name='slug',
204:            ),
205:            {obj1.slug: obj1, obj2.slug: obj2},
206:        )
207:
208:    def test_values(self):
209:        # values() returns a list of dictionaries instead of object instances --
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py lookup --verbosity 1 2>&1 | tail -15"
}
```

**tool result**

```
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
.................................................
----------------------------------------------------------------------
Ran 49 tests in 0.328s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant**

```
Implemented the fix.

**Change** in `django/db/models/query.py` — `QuerySet.in_bulk()` now accepts a field covered by a total single-field `UniqueConstraint` in addition to fields with `unique=True` / primary keys. Composite unique constraints are correctly not treated as unique per-field.

**Tests added** in `tests/lookup/`:
- `UniqueConstraintArticle` model whose `slug` is unique via `Meta.constraints`.
- `test_in_bulk_unique_constraint_field` verifies `in_bulk(field_name='slug')` works and returns the expected mapping.

Full `lookup` test suite passes: **49 tests, OK**. No commits, checkouts, resets, or stashes were performed.
```

### Step `repair` (agent)

**user**

```
Workflow team-solve, task repair.

You are the single repair worker in a fresh context. The run's files are in .memdoor/runs/team-solve-2026-11-06T105729/: task.md (the task: the prompt
and what plan settled), plan.md, notes.md (the ledger every role writes
to). They are never part of the work and never committed. Keep
no rule with the notes tool: it writes the project's AGENTS.md.
Do not commit, check out, reset or stash: the tree's HEAD stays where it is.
Read review.md, test-status.txt and notes.md there. If review.md says
`verdict: PASS`, change nothing and report that repair was unnecessary.
Otherwise read task.md, plan.md, changes.diff and test-output.log, then
correct the work using the manager's instructions, as the task needs. Undo a change outside the Scope only when the review names it as one the
task does not need; a change the fix needs stays, wherever it is.
Run the Check to verify the correction. Write
.memdoor/runs/team-solve-2026-11-06T105729/repair.md: what you changed
and what the Check printed, and append a short repair note to notes.md. Do not start another repair round and do not change
task.md, the prompt, test inputs or expected outputs. The final check
alone decides the run. Do not spawn agents or rely on chat history.

This task is done when this command exits 0 in the project: bash .memdoor/runs/team-solve-{{.partition}}/done.sh repair .memdoor/runs/team-solve-{{.partition}}
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls -la .memdoor/runs/team-solve-2026-11-06T105729/"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/review.md"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/test-status.txt"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/notes.md"
}
```

**tool result**

```
total 192
drwxr-xr-x 2 root root  4096 Nov  6 10:58 .
drwxr-xr-x 4 root root  4096 Nov  6 10:57 ..
-rw-r--r-- 1 root root    41 Nov  6 10:57 base.txt
-rw-r--r-- 1 root root  2295 Nov  6 10:58 baseline-check.log
-rw-r--r-- 1 root root     2 Nov  6 10:58 baseline-status.txt
-rw-r--r-- 1 root root  2831 Nov  6 10:58 changes.diff
-rw-r--r-- 1 root root     6 Nov  6 10:58 check-kind.txt
-rw-r--r-- 1 root root 79953 Nov  6 10:58 context.md
-rw-r--r-- 1 root root  2783 Nov  6 10:58 direct-check.log
-rw-r--r-- 1 root root     2 Nov  6 10:58 direct-status.txt
-rw-r--r-- 1 root root  2831 Nov  6 10:58 direct.patch
-rwxr-xr-x 1 root root  2190 Nov  6 10:57 done.sh
-rw-r--r-- 1 root root     5 Nov  6 10:57 head.txt
-rw-r--r-- 1 root root    73 Nov  6 10:58 notes.md
-rw-r--r-- 1 root root 28172 Nov  6 10:57 outline.md
-rw-r--r-- 1 root root  1806 Nov  6 10:58 plan.md
-rw-r--r-- 1 root root  1094 Nov  6 10:57 prompt.md
-rw-r--r-- 1 root root  1455 Nov  6 10:58 review.md
-rw-r--r-- 1 root root   370 Nov  6 10:58 scope.txt
-rw-r--r-- 1 root root     0 Nov  6 10:57 start
-rw-r--r-- 1 root root  1819 Nov  6 10:58 task.md
-rw-r--r-- 1 root root  2783 Nov  6 10:58 test-output.log
-rw-r--r-- 1 root root     5 Nov  6 10:58 test-status.txt
-rw-r--r-- 1 root root  1934 Nov  6 10:57 untracked-before.txt
```

**tool result**

```
verdict: FAIL

- `django/db/models/query.py` now reads `self.model._meta.total_unique_constraints`, but `django/db/models/options.py` was not changed and no `Options.total_unique_constraints` property was added. On a model whose field is unique only via `UniqueConstraint`, `in_bulk()` will hit `AttributeError` instead of succeeding.
- Because `total_unique_constraints` is missing, the change does not satisfy the required behavior for conditional, expression-based, and multi-field constraints either; those must be excluded by the new `Options` property.
- The added tests are in `tests/lookup/`, which is outside the stated scope and is not exercised by `./tests/runtests.py queries.tests model_options.tests`. The scoped suites contain no regression test for this behavior.

Repair:
- In `django/db/models/options.py`, add `Options.total_unique_constraints` returning the model’s `UniqueConstraint`s that are total: exclude constraints with `condition is not None` and exclude expression-based constraints. Import `UniqueConstraint` if needed.
- Keep `in_bulk()`’s single-field filtering in `django/db/models/query.py` so multi-field total unique constraints do not make an individual field unique.
- Remove the out-of-scope `tests/lookup/` changes, or at minimum move the regression tests into `tests/queries/` or `tests/model_options/` and add cases proving conditional, expression-based, and multi-field constraints still raise `ValueError`.
```

**tool result**

```
none
```

**tool result**

```
# Notes, run 2026-11-06T105729

## Solver decision

## Review

## Repair
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/task.md"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/plan.md"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/changes.diff"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/test-output.log"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/scope.txt"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T105729/done.sh"
}
```

**tool result**

```
# Task

## Prompt

Allow QuerySet.in_bulk() for fields with total UniqueConstraints.
Description
	
If a field is unique by UniqueConstraint instead of unique=True running in_bulk() on that field will fail.
Consider:
class Article(models.Model):
	slug = models.CharField(max_length=255)
	
	class Meta:
		constraints = [
			models.UniqueConstraint(fields=["slug"], name="%(app_label)s_%(class)s_slug_unq")
		]
>>> Article.objects.in_bulk(field_name="slug")
Traceback (most recent call last):
 File "/usr/local/lib/python3.8/code.py", line 90, in runcode
	exec(code, self.locals)
 File "<console>", line 1, in <module>
 File "/app/venv/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/app/venv/lib/python3.8/site-packages/django/db/models/query.py", line 680, in in_bulk
	raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
ValueError: in_bulk()'s field_name must be a unique field but 'slug' isn't.
It should be pretty simple to fix this and I have a patch if accepted.

## Deliverable

changes to this tree

## Check

`./tests/runtests.py queries.tests model_options.tests`

## Scope

`django/db/models/options.py`
`django/db/models/query.py`
`tests/queries/`
`tests/model_options/`

## Done when

- `QuerySet.in_bulk(field_name="slug")` succeeds when `slug` is covered by a total single-field `UniqueConstraint`.
- `in_bulk()` still raises `ValueError` for a field that is not unique by `unique=True` or a total single-field `UniqueConstraint`.
- Conditional, expression-based, and multi-field `UniqueConstraint`s are not treated as making an individual field total-unique.
- `Options.total_unique_constraints` exposes the model’s total `UniqueConstraint`s. `(inferred)`
```

**tool result**

```
## Deliverable
changes to this tree

## Check
`./tests/runtests.py queries.tests model_options.tests`

## Scope
`django/db/models/options.py`
`django/db/models/query.py`
`tests/queries/`
`tests/model_options/`

## Done when
- `QuerySet.in_bulk(field_name="slug")` succeeds when `slug` is covered by a total single-field `UniqueConstraint`.
- `in_bulk()` still raises `ValueError` for a field that is not unique by `unique=True` or a total single-field `UniqueConstraint`.
- Conditional, expression-based, and multi-field `UniqueConstraint`s are not treated as making an individual field total-unique.
- `Options.total_unique_constraints` exposes the model’s total `UniqueConstraint`s. `(inferred)`

## Approach
Add a cached `Options.total_unique_constraints` property that filters `Meta.constraints` to `UniqueConstraint` objects without a `condition` and without expressions. In `QuerySet.in_bulk()`, collect the field names from those constraints where `len(constraint.fields) == 1`, then allow `field_name` when it is `pk`, has `field.unique`, or appears in that collected set. Keep the existing `ValueError` for everything else.

Candidate approaches:
- Preferred: reusable `Options.total_unique_constraints` plus a small check in `in_bulk()`; matches Django’s metadata layer and supports future callers.
- Inline scan of `self.model._meta.constraints` inside `in_bulk()` only; fewer files, but duplicates constraint-filtering logic.
- Use only `field.unique` plus raw `constraint.fields` matching; simpler, but risks treating partial or expression constraints as total unique.

If the first attempt fails, inspect whether `UniqueConstraint` exposes `condition`/`contains_expressions` as expected, and verify the test models actually attach the constraint to the field being passed to `in_bulk()`.


(this is the fourth time you have made nearly this same read_file call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**tool result**

```
diff --git a/django/db/models/query.py b/django/db/models/query.py
index d9c9b0db04..933ab613f4 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -690,7 +690,17 @@ class QuerySet:
         assert not self.query.is_sliced, \
             "Cannot use 'limit' or 'offset' with in_bulk"
         if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
-            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
+            field_names = [
+                field_name
+                for constraint in self.model._meta.total_unique_constraints
+                if len(constraint.fields) == 1
+                for field_name in constraint.fields
+            ]
+            if field_name not in field_names:
+                raise ValueError(
+                    "in_bulk()'s field_name must be a unique field but %r "
+                    "isn't." % field_name
+                )
         if id_list is not None:
             if not id_list:
                 return {}
diff --git a/tests/lookup/models.py b/tests/lookup/models.py
index fbc9fa606f..b87b30b376 100644
--- a/tests/lookup/models.py
+++ b/tests/lookup/models.py
@@ -37,6 +37,18 @@ class Article(models.Model):
         return self.headline
 
 
+class UniqueConstraintArticle(models.Model):
+    slug = models.SlugField()
+
+    class Meta:
+        constraints = [
+            models.UniqueConstraint(
+                fields=['slug'],
+                name='lookup_unique_constraint_article_slug',
+            ),
+        ]
+
+
 class Tag(models.Model):
     articles = models.ManyToManyField(Article)
     name = models.CharField(max_length=100)
diff --git a/tests/lookup/tests.py b/tests/lookup/tests.py
index baefdf9701..e7930bf115 100644
--- a/tests/lookup/tests.py
+++ b/tests/lookup/tests.py
@@ -12,6 +12,7 @@ from django.utils.deprecation import RemovedInDjango40Warning
 
 from .models import (
     Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,
+    UniqueConstraintArticle,
 )
 
 
@@ -194,6 +195,16 @@ class LookupTests(TestCase):
         with self.assertRaisesMessage(ValueError, msg):
             Article.objects.in_bulk([self.au1], field_name='author')
 
+    def test_in_bulk_unique_constraint_field(self):
+        obj1 = UniqueConstraintArticle.objects.create(slug='a')
+        obj2 = UniqueConstraintArticle.objects.create(slug='b')
+        self.assertEqual(
+            UniqueConstraintArticle.objects.in_bulk(
+                [obj1.slug, obj2.slug], field_name='slug',
+            ),
+            {obj1.slug: obj1, obj2.slug: obj2},
+        )
+
     def test_values(self):
         # values() returns a list of dictionaries instead of object instances --
         # and you can specify which fields you want to retrieve.


(this is the fifth time you have made nearly this same read_file call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**tool result**

```
check: ./tests/runtests.py queries.tests model_options.tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
........s.......s............x.........x.............................................................................s......................................................E...............................................................................................................
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.634s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: django/db/models/options.py django/db/models/query.py tests/queries tests/model_options
changed: django/db/models/query.py +11 -1
OUTSIDE THE SCOPE: tests/lookup/models.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/lookup/tests.py +11 -0 (undo it: git checkout the file, or delete it when the run made it)
```

**tool result**

```
scope: django/db/models/options.py django/db/models/query.py tests/queries tests/model_options
changed: django/db/models/query.py +11 -1
OUTSIDE THE SCOPE: tests/lookup/models.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/lookup/tests.py +11 -0 (undo it: git checkout the file, or delete it when the run made it)


(this is the seventh time you have made nearly this same read_file call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**tool result**

```
not run: the loop-breaker tripped earlier in this same reply. STOP issuing tool calls and answer with what you have.
```

**user**

```
⚠ The same tool call keeps failing the same way. Do not repeat it. Change your approach, or tell the person what is blocking you and end your turn.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"unique_constraints\\|class Options\\|def _\" django/db/models/options.py | head -50; echo ---; sed -n '680,710p' django/db/models/query.py; echo ---; ls tests/model_options/ 2>&1; echo ---; ls tests/queries/ | head; echo ---; cat .memdoor/runs/team-solve-2026-11-06T105729/baseline-check.log"
}
```

**tool result**

```
63:class Options:
73:    def __init__(self, meta, app_label=None):
208:    def _format_names_with_class(self, cls, objs):
220:    def _prepare(self, model):
304:    def __repr__(self):
307:    def __str__(self):
525:    def _forward_fields_map(self):
679:    def _populate_directed_relation_graph(self):
717:    def _relation_tree(self):
720:    def _expire_cache(self, forward=True, reverse=True):
747:    def _get_fields(self, forward=True, reverse=True, include_parents=True, include_hidden=False,
832:    def total_unique_constraints(self):
844:    def _property_names(self):
---
    def last(self):
        """Return the last object of a query or None if no match is found."""
        for obj in (self.reverse() if self.ordered else self.order_by('-pk'))[:1]:
            return obj

    def in_bulk(self, id_list=None, *, field_name='pk'):
        """
        Return a dictionary mapping each of the given IDs to the object with
        that ID. If `id_list` isn't provided, evaluate the entire QuerySet.
        """
        assert not self.query.is_sliced, \
            "Cannot use 'limit' or 'offset' with in_bulk"
        if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
            field_names = [
                field_name
                for constraint in self.model._meta.total_unique_constraints
                if len(constraint.fields) == 1
                for field_name in constraint.fields
            ]
            if field_name not in field_names:
                raise ValueError(
                    "in_bulk()'s field_name must be a unique field but %r "
                    "isn't." % field_name
                )
        if id_list is not None:
            if not id_list:
                return {}
            filter_key = '{}__in'.format(field_name)
            batch_size = connections[self.db].features.max_query_params
            id_list = tuple(id_list)
            # If the database has a limit on the number of query parameters
---
__init__.py
__pycache__
models
test_default_related_name.py
test_tablespaces.py
---
__init__.py
__pycache__
models.py
test_bulk_update.py
test_db_returning.py
test_deprecation.py
test_explain.py
test_iterator.py
test_q.py
test_qs_combinators.py
---
check: ./tests/runtests.py queries.tests model_options.tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
...s..........s.......x..................x..................................................................................s..............................E................................................................................................................................
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.638s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '820,845p' django/db/models/options.py; echo ---; git diff --stat; echo ---; git status --short; echo ---; sed -n '1,200p' .memdoor/runs/team-solve-2026-11-06T105729/done.sh"
}
```

**tool result**

```
            if topmost_call:
                fields += self.private_fields

        # In order to avoid list manipulation. Always
        # return a shallow copy of the results
        fields = make_immutable_fields_list("get_fields()", fields)

        # Store result into cache for later access
        self._get_fields_cache[cache_key] = fields
        return fields

    @cached_property
    def total_unique_constraints(self):
        """
        Return a list of total unique constraints. Useful for determining set
        of fields guaranteed to be unique for all rows.
        """
        return [
            constraint
            for constraint in self.constraints
            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
        ]

    @cached_property
    def _property_names(self):
        """Return a set of the names of the properties defined on the model."""
---
 django/db/models/query.py | 12 +++++++++++-
 tests/lookup/models.py    | 12 ++++++++++++
 tests/lookup/tests.py     | 11 +++++++++++
 3 files changed, 34 insertions(+), 1 deletion(-)
---
 M django/db/models/query.py
 M tests/lookup/models.py
 M tests/lookup/tests.py
?? .memdoor/
---
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

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"UniqueConstraint\\|contains_expressions\\|condition\" django/db/models/options.py | head -30; echo ---; git show HEAD:django/db/models/options.py | grep -n \"total_unique_constraints\" ; echo ---; grep -rn \"total_unique_constraints\" django/ | head -30; echo ---; grep -rn \"in_bulk\" tests/queries/models.py tests/model_options/models/*.py 2>/dev/null | head"
}
```

**tool result**

```
10:from django.db.models import AutoField, Manager, OrderWrt, UniqueConstraint
840:            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
---
832:    def total_unique_constraints(self):
---
grep: django/contrib/admin/views/__pycache__/main.cpython-36.pyc: binary file matches
grep: django/db/models/fields/__pycache__/related.cpython-36.pyc: binary file matches
grep: django/db/models/__pycache__/base.cpython-36.pyc: binary file matches
grep: django/db/models/__pycache__/query.cpython-36.pyc: binary file matches
grep: django/db/models/__pycache__/options.cpython-36.pyc: binary file matches
django/contrib/admin/views/main.py:376:                    for constraint in self.lookup_opts.total_unique_constraints
django/db/models/fields/related.py:533:            for uc in self.remote_field.model._meta.total_unique_constraints
django/db/models/options.py:832:    def total_unique_constraints(self):
django/db/models/base.py:1027:        constraints = [(self.__class__, self._meta.total_unique_constraints)]
django/db/models/base.py:1031:            if parent_class._meta.total_unique_constraints:
django/db/models/base.py:1033:                    (parent_class, parent_class._meta.total_unique_constraints)
django/db/models/query.py:695:                for constraint in self.model._meta.total_unique_constraints
---
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class UniqueConstraint\" -A 90 django/db/models/constraints.py | sed -n '1,100p'; echo ---; sed -n '1,30p' django/db/models/options.py"
}
```

**tool result**

```
72:class UniqueConstraint(BaseConstraint):
73-    def __init__(self, *, fields, name, condition=None):
74-        if not fields:
75-            raise ValueError('At least one field is required to define a unique constraint.')
76-        if not isinstance(condition, (type(None), Q)):
77-            raise ValueError('UniqueConstraint.condition must be a Q instance.')
78-        self.fields = tuple(fields)
79-        self.condition = condition
80-        super().__init__(name)
81-
82-    def _get_condition_sql(self, model, schema_editor):
83-        if self.condition is None:
84-            return None
85-        query = Query(model=model, alias_cols=False)
86-        where = query.build_where(self.condition)
87-        compiler = query.get_compiler(connection=schema_editor.connection)
88-        sql, params = where.as_sql(compiler, schema_editor.connection)
89-        return sql % tuple(schema_editor.quote_value(p) for p in params)
90-
91-    def constraint_sql(self, model, schema_editor):
92-        fields = [model._meta.get_field(field_name).column for field_name in self.fields]
93-        condition = self._get_condition_sql(model, schema_editor)
94-        return schema_editor._unique_sql(model, fields, self.name, condition=condition)
95-
96-    def create_sql(self, model, schema_editor):
97-        fields = [model._meta.get_field(field_name).column for field_name in self.fields]
98-        condition = self._get_condition_sql(model, schema_editor)
99-        return schema_editor._create_unique_sql(model, fields, self.name, condition=condition)
100-
101-    def remove_sql(self, model, schema_editor):
102-        condition = self._get_condition_sql(model, schema_editor)
103-        return schema_editor._delete_unique_sql(model, self.name, condition=condition)
104-
105-    def __repr__(self):
106-        return '<%s: fields=%r name=%r%s>' % (
107-            self.__class__.__name__, self.fields, self.name,
108-            '' if self.condition is None else ' condition=%s' % self.condition,
109-        )
110-
111-    def __eq__(self, other):
112-        if isinstance(other, UniqueConstraint):
113-            return (
114-                self.name == other.name and
115-                self.fields == other.fields and
116-                self.condition == other.condition
117-            )
118-        return super().__eq__(other)
119-
120-    def deconstruct(self):
121-        path, args, kwargs = super().deconstruct()
122-        kwargs['fields'] = self.fields
123-        if self.condition:
124-            kwargs['condition'] = self.condition
125-        return path, args, kwargs
---
import bisect
import copy
import inspect
from collections import defaultdict

from django.apps import apps
from django.conf import settings
from django.core.exceptions import FieldDoesNotExist
from django.db import connections
from django.db.models import AutoField, Manager, OrderWrt, UniqueConstraint
from django.db.models.query_utils import PathInfo
from django.utils.datastructures import ImmutableList, OrderedSet
from django.utils.functional import cached_property
from django.utils.text import camel_case_to_spaces, format_lazy
from django.utils.translation import override

PROXY_PARENTS = object()

EMPTY_RELATION_TREE = ()

IMMUTABLE_WARNING = (
    "The return type of '%s' should never be mutated. If you want to manipulate this list "
    "for your own use, make a copy first."
)

DEFAULT_NAMES = (
    'verbose_name', 'verbose_name_plural', 'db_table', 'ordering',
    'unique_together', 'permissions', 'get_latest_by', 'order_with_respect_to',
    'app_label', 'db_tablespace', 'abstract', 'managed', 'proxy', 'swappable',
    'auto_created', 'index_together', 'apps', 'default_permissions',
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"UniqueConstraint\" tests/queries tests/model_options | head -40; echo ---; grep -n \"in_bulk\" -n tests/queries/tests.py | head -20; echo ---; sed -n '1,40p' tests/model_options/models/__init__.py 2>/dev/null; ls tests/model_options/models; echo ---; python -c \"import django; print(django.get_version())\""
}
```

**tool result**

```
---
---
__init__.py
__pycache__
default_related_name.py
tablespaces.py
---
3.1
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"expression\\|contains_expressions\\|fields\" django/db/models/constraints.py; echo ---; sed -n '1,60p' tests/queries/models.py; echo ---; grep -n \"class .*Model\\|class .*Article\\|constraints\" tests/queries/models.py | head -40"
}
```

**tool result**

```
36:                'expression.'
73:    def __init__(self, *, fields, name, condition=None):
74:        if not fields:
78:        self.fields = tuple(fields)
92:        fields = [model._meta.get_field(field_name).column for field_name in self.fields]
94:        return schema_editor._unique_sql(model, fields, self.name, condition=condition)
97:        fields = [model._meta.get_field(field_name).column for field_name in self.fields]
99:        return schema_editor._create_unique_sql(model, fields, self.name, condition=condition)
106:        return '<%s: fields=%r name=%r%s>' % (
107:            self.__class__.__name__, self.fields, self.name,
115:                self.fields == other.fields and
122:        kwargs['fields'] = self.fields
---
"""
Various complex queries that have been problematic in the past.
"""
import threading

from django.db import models
from django.db.models.functions import Now


class DumbCategory(models.Model):
    pass


class ProxyCategory(DumbCategory):
    class Meta:
        proxy = True


class NamedCategory(DumbCategory):
    name = models.CharField(max_length=10)

    def __str__(self):
        return self.name


class Tag(models.Model):
    name = models.CharField(max_length=10)
    parent = models.ForeignKey(
        'self',
        models.SET_NULL,
        blank=True, null=True,
        related_name='children',
    )
    category = models.ForeignKey(NamedCategory, models.SET_NULL, null=True, default=None)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class Note(models.Model):
    note = models.CharField(max_length=100)
    misc = models.CharField(max_length=10)
    tag = models.ForeignKey(Tag, models.SET_NULL, blank=True, null=True)

    class Meta:
        ordering = ['note']

    def __str__(self):
        return self.note

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Regression for #13227 -- having an attribute that
        # is unpicklable doesn't stop you from cloning queries
        # that use objects of that type as an argument.
        self.lock = threading.Lock()

---
10:class DumbCategory(models.Model):
26:class Tag(models.Model):
43:class Note(models.Model):
62:class Annotation(models.Model):
71:class DateTimePK(models.Model):
75:class ExtraInfo(models.Model):
88:class Author(models.Model):
100:class Item(models.Model):
115:class Report(models.Model):
123:class ReportComment(models.Model):
127:class Ranking(models.Model):
139:class Cover(models.Model):
150:class Number(models.Model):
161:class Valid(models.Model):
172:class X(models.Model):
176:class Y(models.Model):
183:class LoopX(models.Model):
190:class LoopY(models.Model):
197:class LoopZ(models.Model):
213:class ManagedModel(models.Model):
227:class Detail(models.Model):
236:class Member(models.Model):
243:class Child(models.Model):
250:class CustomPk(models.Model):
258:class Related(models.Model):
262:class CustomPkTag(models.Model):
271:class Celebrity(models.Model):
283:class Fan(models.Model):
289:class LeafA(models.Model):
296:class LeafB(models.Model):
300:class Join(models.Model):
305:class ReservedName(models.Model):
315:class SharedConnection(models.Model):
322:class PointerA(models.Model):
326:class PointerB(models.Model):
332:class SingleObject(models.Model):
342:class RelatedObject(models.Model):
350:class Plaything(models.Model):
361:class Article(models.Model):
369:class Food(models.Model):
```

**assistant → tool `bash`**

```json
{
  "command": "git diff django/db/models/options.py; echo \"diff-exit:$?\"; git log --oneline -3; echo ---; git show HEAD:django/db/models/options.py | sed -n '825,845p'; echo ---; sed -n '820,845p' django/db/models/options.py"
}
```

**tool result**

```
diff-exit:0
fa3a0522ec SWE-bench
67f9d076cf Avoided unnecessary recompilation of ordering clause regex in SQLCompiler.
060d9d4229 Added link to Mozilla's infosec page on web security.
---
        fields = make_immutable_fields_list("get_fields()", fields)

        # Store result into cache for later access
        self._get_fields_cache[cache_key] = fields
        return fields

    @cached_property
    def total_unique_constraints(self):
        """
        Return a list of total unique constraints. Useful for determining set
        of fields guaranteed to be unique for all rows.
        """
        return [
            constraint
            for constraint in self.constraints
            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
        ]

    @cached_property
    def _property_names(self):
        """Return a set of the names of the properties defined on the model."""
---
            if topmost_call:
                fields += self.private_fields

        # In order to avoid list manipulation. Always
        # return a shallow copy of the results
        fields = make_immutable_fields_list("get_fields()", fields)

        # Store result into cache for later access
        self._get_fields_cache[cache_key] = fields
        return fields

    @cached_property
    def total_unique_constraints(self):
        """
        Return a list of total unique constraints. Useful for determining set
        of fields guaranteed to be unique for all rows.
        """
        return [
            constraint
            for constraint in self.constraints
            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
        ]

    @cached_property
    def _property_names(self):
        """Return a set of the names of the properties defined on the model."""
```

**assistant → tool `bash`**

```json
{
  "command": "git show HEAD:tests/lookup/models.py > tests/lookup/models.py && git show HEAD:tests/lookup/tests.py > tests/lookup/tests.py && git status --short && git diff --stat"
}
```

**tool result**

```
 M django/db/models/query.py
?? .memdoor/
 django/db/models/query.py | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)
```

**assistant → tool `bash`**

```json
{
  "command": "git ls-tree -r HEAD --name-only tests/model_options | head -30; echo ---; grep -rn \"total_unique_constraints\" tests/ | head; echo ---; git log --oneline -1 -- django/db/models/options.py"
}
```

**tool result**

```
tests/model_options/__init__.py
tests/model_options/models/__init__.py
tests/model_options/models/default_related_name.py
tests/model_options/models/tablespaces.py
tests/model_options/test_default_related_name.py
tests/model_options/test_tablespaces.py
---
---
1d16c5d562 Refs #27666 -- Ensured relationship consistency on delayed reloads.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,72p' django/db/models/constraints.py; echo ---; grep -rn \"UniqueConstraint(.*expression\\|expression=\" tests | head"
}
```

**tool result**

```
from django.db.models.query_utils import Q
from django.db.models.sql.query import Query

__all__ = ['CheckConstraint', 'UniqueConstraint']


class BaseConstraint:
    def __init__(self, name):
        self.name = name

    def constraint_sql(self, model, schema_editor):
        raise NotImplementedError('This method must be implemented by a subclass.')

    def create_sql(self, model, schema_editor):
        raise NotImplementedError('This method must be implemented by a subclass.')

    def remove_sql(self, model, schema_editor):
        raise NotImplementedError('This method must be implemented by a subclass.')

    def deconstruct(self):
        path = '%s.%s' % (self.__class__.__module__, self.__class__.__name__)
        path = path.replace('django.db.models.constraints', 'django.db.models')
        return (path, (), {'name': self.name})

    def clone(self):
        _, args, kwargs = self.deconstruct()
        return self.__class__(*args, **kwargs)


class CheckConstraint(BaseConstraint):
    def __init__(self, *, check, name):
        self.check = check
        if not getattr(check, 'conditional', False):
            raise TypeError(
                'CheckConstraint.check must be a Q instance or boolean '
                'expression.'
            )
        super().__init__(name)

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

    def __repr__(self):
        return "<%s: check='%s' name=%r>" % (self.__class__.__name__, self.check, self.name)

    def __eq__(self, other):
        if isinstance(other, CheckConstraint):
            return self.name == other.name and self.check == other.check
        return super().__eq__(other)

    def deconstruct(self):
        path, args, kwargs = super().deconstruct()
        kwargs['check'] = self.check
        return path, args, kwargs


class UniqueConstraint(BaseConstraint):
---
tests/db_functions/window/test_validation.py:9:            NthValue(expression='salary', nth=-1)
tests/db_functions/window/test_validation.py:14:            NthValue(expression=None)
tests/db_functions/window/test_validation.py:19:            Lag(expression='salary', offset=-1)
tests/db_functions/window/test_validation.py:24:            Lead(expression='salary', offset=-1)
tests/db_functions/window/test_validation.py:29:            Lead(expression=None)
tests/db_functions/window/test_validation.py:34:            Lag(expression=None)
tests/expressions_window/tests.py:43:            expression=DenseRank(),
tests/expressions_window/tests.py:63:            expression=Sum('salary'),
tests/expressions_window/tests.py:89:            expression=Rank(),
tests/expressions_window/tests.py:115:            expression=RowNumber(),
```

**assistant → tool `bash`**

```json
{
  "command": "cat tests/model_options/__init__.py; echo ---; cat tests/model_options/models/__init__.py; echo ---; sed -n '1,50p' tests/model_options/test_default_related_name.py; echo ---; grep -n \"in_bulk\" tests/queries/tests.py | head"
}
```

**tool result**

```
---
---
from django.core.exceptions import FieldError
from django.test import TestCase

from .models.default_related_name import Author, Book, Editor


class DefaultRelatedNameTests(TestCase):

    @classmethod
    def setUpTestData(cls):
        cls.author = Author.objects.create(first_name='Dave', last_name='Loper')
        cls.editor = Editor.objects.create(name='Test Editions', bestselling_author=cls.author)
        cls.book = Book.objects.create(title='Test Book', editor=cls.editor)
        cls.book.authors.add(cls.author)

    def test_no_default_related_name(self):
        self.assertEqual(list(self.author.editor_set.all()), [self.editor])

    def test_default_related_name(self):
        self.assertEqual(list(self.author.books.all()), [self.book])

    def test_default_related_name_in_queryset_lookup(self):
        self.assertEqual(Author.objects.get(books=self.book), self.author)

    def test_model_name_not_available_in_queryset_lookup(self):
        msg = "Cannot resolve keyword 'book' into field."
        with self.assertRaisesMessage(FieldError, msg):
            Author.objects.get(book=self.book)

    def test_related_name_overrides_default_related_name(self):
        self.assertEqual(list(self.editor.edited_books.all()), [self.book])

    def test_inheritance(self):
        # model_options is the name of the application for this test.
        self.assertEqual(list(self.book.model_options_bookstores.all()), [])

    def test_inheritance_with_overridden_default_related_name(self):
        self.assertEqual(list(self.book.editor_stores.all()), [])
---
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed 2>/dev/null || true; pwd; timeout 300 ./tests/runtests.py queries.tests model_options.tests 2>&1 | tail -30"
}
```

**tool result**

```
/testbed
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.660s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '355,395p' tests/queries/models.py; echo ---; grep -n \"def test_in_bulk\\|class Queries1Tests\\|class Queries\" tests/queries/tests.py | head -20; echo ---; grep -n \"in_bulk\" tests/queries/tests.py"
}
```

**tool result**

```
ordering = ['others']

    def __str__(self):
        return self.name


class Article(models.Model):
    name = models.CharField(max_length=20)
    created = models.DateTimeField()

    def __str__(self):
        return self.name


class Food(models.Model):
    name = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return self.name


class Eaten(models.Model):
    food = models.ForeignKey(Food, models.SET_NULL, to_field="name", null=True)
    meal = models.CharField(max_length=20)

    def __str__(self):
        return "%s at %s" % (self.food, self.meal)


class Node(models.Model):
    num = models.IntegerField(unique=True)
    parent = models.ForeignKey("self", models.SET_NULL, to_field="num", null=True)

    def __str__(self):
        return "%s" % self.num

# Bug #12252


class ObjectA(models.Model):
    name = models.CharField(max_length=50)
---
37:class Queries1Tests(TestCase):
1213:class Queries2Tests(TestCase):
1322:class Queries3Tests(TestCase):
1341:class Queries4Tests(TestCase):
1623:class Queries5Tests(TestCase):
1853:class Queries6Tests(TestCase):
---

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' tests/queries/tests.py; echo ---; grep -n \"from .models import\" -A 30 tests/queries/tests.py | head -40; echo ---; grep -n \"def test_\" tests/queries/tests.py | head -5; echo ---; grep -n \"import\" django/db/models/query.py | head"
}
```

**tool result**

```
import datetime
import pickle
import sys
import unittest
from operator import attrgetter

from django.core.exceptions import EmptyResultSet, FieldError
from django.db import DEFAULT_DB_ALIAS, connection
from django.db.models import Count, Exists, F, OuterRef, Q
from django.db.models.expressions import RawSQL
from django.db.models.sql.constants import LOUTER
from django.db.models.sql.where import NothingNode, WhereNode
from django.test import SimpleTestCase, TestCase, skipUnlessDBFeature
from django.test.utils import CaptureQueriesContext, ignore_warnings
from django.utils.deprecation import RemovedInDjango40Warning

from .models import (
    FK1, Annotation, Article, Author, BaseA, Book, CategoryItem,
    CategoryRelationship, Celebrity, Channel, Chapter, Child, ChildObjectA,
    Classroom, CommonMixedCaseForeignKeys, Company, Cover, CustomPk,
    CustomPkTag, DateTimePK, Detail, DumbCategory, Eaten, Employment,
    ExtraInfo, Fan, Food, Identifier, Individual, Item, Job,
    JobResponsibilities, Join, LeafA, LeafB, LoopX, LoopZ, ManagedModel,
    Member, MixedCaseDbColumnCategoryItem, MixedCaseFieldCategoryItem, ModelA,
    ModelB, ModelC, ModelD, MyObject, NamedCategory, Node, Note, NullableName,
    Number, ObjectA, ObjectB, ObjectC, OneToOneCategory, Order, OrderItem,
    Page, Paragraph, Person, Plaything, PointerA, Program, ProxyCategory,
    ProxyObjectA, ProxyObjectB, Ranking, Related, RelatedIndividual,
    RelatedObject, Report, ReportComment, ReservedName, Responsibility, School,
    SharedConnection, SimpleCategory, SingleObject, SpecialCategory, Staff,
    StaffUser, Student, Tag, Task, Teacher, Ticket21203Child,
    Ticket21203Parent, Ticket23605A, Ticket23605B, Ticket23605C, TvChef, Valid,
    X,
)


class Queries1Tests(TestCase):
    @classmethod
    def setUpTestData(cls):
        generic = NamedCategory.objects.create(name="Generic")
---
17:from .models import (
18-    FK1, Annotation, Article, Author, BaseA, Book, CategoryItem,
19-    CategoryRelationship, Celebrity, Channel, Chapter, Child, ChildObjectA,
20-    Classroom, CommonMixedCaseForeignKeys, Company, Cover, CustomPk,
21-    CustomPkTag, DateTimePK, Detail, DumbCategory, Eaten, Employment,
22-    ExtraInfo, Fan, Food, Identifier, Individual, Item, Job,
23-    JobResponsibilities, Join, LeafA, LeafB, LoopX, LoopZ, ManagedModel,
24-    Member, MixedCaseDbColumnCategoryItem, MixedCaseFieldCategoryItem, ModelA,
25-    ModelB, ModelC, ModelD, MyObject, NamedCategory, Node, Note, NullableName,
26-    Number, ObjectA, ObjectB, ObjectC, OneToOneCategory, Order, OrderItem,
27-    Page, Paragraph, Person, Plaything, PointerA, Program, ProxyCategory,
28-    ProxyObjectA, ProxyObjectB, Ranking, Related, RelatedIndividual,
29-    RelatedObject, Report, ReportComment, ReservedName, Responsibility, School,
30-    SharedConnection, SimpleCategory, SingleObject, SpecialCategory, Staff,
31-    StaffUser, Student, Tag, Task, Teacher, Ticket21203Child,
32-    Ticket21203Parent, Ticket23605A, Ticket23605B, Ticket23605C, TvChef, Valid,
33-    X,
34-)
35-
36-
37-class Queries1Tests(TestCase):
38-    @classmethod
39-    def setUpTestData(cls):
40-        generic = NamedCategory.objects.create(name="Generic")
41-        cls.t1 = Tag.objects.create(name='t1', category=generic)
42-        cls.t2 = Tag.objects.create(name='t2', parent=cls.t1, category=generic)
43-        cls.t3 = Tag.objects.create(name='t3', parent=cls.t1)
44-        t4 = Tag.objects.create(name='t4', parent=cls.t3)
45-        cls.t5 = Tag.objects.create(name='t5', parent=cls.t3)
46-
47-        cls.n1 = Note.objects.create(note='n1', misc='foo', id=1)
---
89:    def test_subquery_condition(self):
102:    def test_ticket1050(self):
112:    def test_ticket1801(self):
126:    def test_ticket2306(self):
162:    def test_ticket4464(self):
---
5:import copy
6:import operator
7:import warnings
8:from collections import namedtuple
9:from functools import lru_cache
10:from itertools import chain
12:from django.conf import settings
13:from django.core import exceptions
14:from django.db import (
18:from django.db.models import AutoField, DateField, DateTimeField, sql
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -S'total_unique_constraints' -- django/db/models/options.py | head; echo ---; git show HEAD:django/db/models/query.py | sed -n '686,700p'; echo ---; git diff HEAD -- django/db/models/query.py"
}
```

**tool result**

```
d270c10a72 Refs #31187 -- Added total_unique_constraints property to model's Options.
---
        """
        Return a dictionary mapping each of the given IDs to the object with
        that ID. If `id_list` isn't provided, evaluate the entire QuerySet.
        """
        assert not self.query.is_sliced, \
            "Cannot use 'limit' or 'offset' with in_bulk"
        if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
        if id_list is not None:
            if not id_list:
                return {}
            filter_key = '{}__in'.format(field_name)
            batch_size = connections[self.db].features.max_query_params
            id_list = tuple(id_list)
            # If the database has a limit on the number of query parameters
---
diff --git a/django/db/models/query.py b/django/db/models/query.py
index d9c9b0db04..933ab613f4 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -690,7 +690,17 @@ class QuerySet:
         assert not self.query.is_sliced, \
             "Cannot use 'limit' or 'offset' with in_bulk"
         if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
-            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
+            field_names = [
+                field_name
+                for constraint in self.model._meta.total_unique_constraints
+                if len(constraint.fields) == 1
+                for field_name in constraint.fields
+            ]
+            if field_name not in field_names:
+                raise ValueError(
+                    "in_bulk()'s field_name must be a unique field but %r "
+                    "isn't." % field_name
+                )
         if id_list is not None:
             if not id_list:
                 return {}
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline --all -- tests/model_options/tests.py | head; echo ---; git log --oneline --all -- tests/model_options | head; echo ---; git branch -a; echo ---; cat .memdoor/runs/team-solve-2026-11-06T105729/base.txt; cat .memdoor/runs/team-solve-2026-11-06T105729/check-kind.txt"
}
```

**tool result**

```
---
315357ad25 Fixed #30023 -- Prevented SQLite schema alterations while foreign key checks are enabled.
3b429c9673 Refs #25530 -- Tracked references of deferred SQL statements.
cde31daf88 Sorted imports per isort 4.2.9.
d7b9aaa366 Refs #23919 -- Removed encoding preambles and future imports
bfe0d54514 Refs #26230 -- Removed support for model name query lookups when using Meta.default_related_name.
967be82443 Fixed E305 flake8 warnings.
92053acbb9 Fixed E128 flake8 warnings in tests/.
b84f5ab4ec Fixed #26230 -- Made default_related_name affect related_query_name.
7fec264e46 Removed try/fail antipattern from model_options tests.
93452a70e8 Fixed many spelling mistakes in code, comments, and docs.
---
* main
---
fa3a0522ec44568d3af6f9cdc3194afadc76f070
judge
```

**assistant → tool `bash`**

```json
{
  "command": "tail -40 tests/queries/models.py; echo ---; sed -n '37,60p' tests/queries/tests.py; echo ---; grep -n \"class Queries1Tests\" -A 5 tests/queries/tests.py"
}
```

**tool result**

```


class Ticket23605C(models.Model):
    field_c0 = models.FloatField()


# db_table names have capital letters to ensure they are quoted in queries.
class Individual(models.Model):
    alive = models.BooleanField()

    class Meta:
        db_table = 'Individual'


class RelatedIndividual(models.Model):
    related = models.ForeignKey(Individual, models.CASCADE, related_name='related_individual')

    class Meta:
        db_table = 'RelatedIndividual'


class CustomDbColumn(models.Model):
    custom_column = models.IntegerField(db_column='custom_name', null=True)
    ip_address = models.GenericIPAddressField(null=True)


class CreatedField(models.DateTimeField):
    db_returning = True

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('default', Now)
        super().__init__(*args, **kwargs)


class ReturningModel(models.Model):
    created = CreatedField(editable=False)


class NonIntegerPKReturningModel(models.Model):
    created = CreatedField(editable=False, primary_key=True)
---
class Queries1Tests(TestCase):
    @classmethod
    def setUpTestData(cls):
        generic = NamedCategory.objects.create(name="Generic")
        cls.t1 = Tag.objects.create(name='t1', category=generic)
        cls.t2 = Tag.objects.create(name='t2', parent=cls.t1, category=generic)
        cls.t3 = Tag.objects.create(name='t3', parent=cls.t1)
        t4 = Tag.objects.create(name='t4', parent=cls.t3)
        cls.t5 = Tag.objects.create(name='t5', parent=cls.t3)

        cls.n1 = Note.objects.create(note='n1', misc='foo', id=1)
        cls.n2 = Note.objects.create(note='n2', misc='bar', id=2)
        cls.n3 = Note.objects.create(note='n3', misc='foo', id=3)

        ann1 = Annotation.objects.create(name='a1', tag=cls.t1)
        ann1.notes.add(cls.n1)
        ann2 = Annotation.objects.create(name='a2', tag=t4)
        ann2.notes.add(cls.n2, cls.n3)

        # Create these out of order so that sorting by 'id' will be different to sorting
        # by 'info'. Helps detect some problems later.
        cls.e2 = ExtraInfo.objects.create(info='e2', note=cls.n2, value=41)
        e1 = ExtraInfo.objects.create(info='e1', note=cls.n1, value=42)

---
37:class Queries1Tests(TestCase):
38-    @classmethod
39-    def setUpTestData(cls):
40-        generic = NamedCategory.objects.create(name="Generic")
41-        cls.t1 = Tag.objects.create(name='t1', category=generic)
42-        cls.t2 = Tag.objects.create(name='t2', parent=cls.t1, category=generic)
```

**assistant → tool `bash`**

```json
{
  "command": "git show --stat d270c10a72; echo ---; git show d270c10a72 -- django/db/models/query.py django/db/models/options.py | head -150"
}
```

**tool result**

```
commit d270c10a723ca04e467e08d6d8b38ae392191f2d
Author: Mariusz Felisiak <felisiak.mariusz@gmail.com>
Date:   Wed Feb 19 08:14:35 2020 +0100

    Refs #31187 -- Added total_unique_constraints property to model's Options.

 django/db/models/base.py    | 15 +++++++--------
 django/db/models/options.py | 14 +++++++++++++-
 2 files changed, 20 insertions(+), 9 deletions(-)
---
commit d270c10a723ca04e467e08d6d8b38ae392191f2d
Author: Mariusz Felisiak <felisiak.mariusz@gmail.com>
Date:   Wed Feb 19 08:14:35 2020 +0100

    Refs #31187 -- Added total_unique_constraints property to model's Options.

diff --git a/django/db/models/options.py b/django/db/models/options.py
index ae2b073df9..f027a74976 100644
--- a/django/db/models/options.py
+++ b/django/db/models/options.py
@@ -7,7 +7,7 @@ from django.apps import apps
 from django.conf import settings
 from django.core.exceptions import FieldDoesNotExist
 from django.db import connections
-from django.db.models import AutoField, Manager, OrderWrt
+from django.db.models import AutoField, Manager, OrderWrt, UniqueConstraint
 from django.db.models.query_utils import PathInfo
 from django.utils.datastructures import ImmutableList, OrderedSet
 from django.utils.functional import cached_property
@@ -827,6 +827,18 @@ class Options:
         self._get_fields_cache[cache_key] = fields
         return fields
 
+    @cached_property
+    def total_unique_constraints(self):
+        """
+        Return a list of total unique constraints. Useful for determining set
+        of fields guaranteed to be unique for all rows.
+        """
+        return [
+            constraint
+            for constraint in self.constraints
+            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
+        ]
+
     @cached_property
     def _property_names(self):
         """Return a set of the names of the properties defined on the model."""
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline -S\"in_bulk()'s field_name must be a unique field\" -- django/db/models/query.py | head; echo ---; git log --all --oneline --grep=\"in_bulk\" | head -20"
}
```

**tool result**

```
3159ad4df6 Fixed #27970 -- Allowed QuerySet.in_bulk() to fetch on fields besides primary key.
---
3159ad4df6 Fixed #27970 -- Allowed QuerySet.in_bulk() to fetch on fields besides primary key.
1b6f05e91f Fixed #21160 -- Fixed QuerySet.in_bulk() crash on SQLite when requesting more than 999 ids.
62ca2dea04 Fixed #8065 -- Made id_list an optional argument for QuerySet.in_bulk().
b7c3b044fc Cleaned up the implementation of in_bulk
de9942a667 Fixed #17668 - prefetch_related does not work in in_bulk
15295a852f Fixed #15647 -- Changed in_bulk() not to type check its input, which now allows for passing any iterable. Thanks, calvinspealman
340eaded4e Fixed #15116 -- Strip ordering clause from in_bulk() queries, since ordering information will be lost. Thanks to lamby for the report and patch.
7efd96844d Fixed #12251 - QuerySet.in_bulk() should accept set/frozenset
bbfc645337 Fixed #1181 -- get_in_bulk no longer fails on empty input. Also added unit tests. Thanks, akaihola
f82e64c6b2 Fixed #681 -- get_in_bulk no longer assumes PK fields are called id. Also added unit tests to confirm. Thanks, Jeremy Dunck
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' tests/model_options/models/tablespaces.py; echo ---; cat tests/model_options/models/default_related_name.py | head -30; echo ---; grep -rn \"model_options\" tests/runtests.py setup.cfg 2>/dev/null | head; echo ---; ls tests/model_options/models/__pycache__"
}
```

**tool result**

```
from django.db import models

# Since the test database doesn't have tablespaces, it's impossible for Django
# to create the tables for models where db_tablespace is set. To avoid this
# problem, we mark the models as unmanaged, and temporarily revert them to
# managed during each test. We also set them to use the same tables as the
# "reference" models to avoid errors when other tests run 'migrate'
# (proxy_models_inheritance does).


class ScientistRef(models.Model):
    name = models.CharField(max_length=50)


class ArticleRef(models.Model):
    title = models.CharField(max_length=50, unique=True)
    code = models.CharField(max_length=50, unique=True)
    authors = models.ManyToManyField(ScientistRef, related_name='articles_written_set')
    reviewers = models.ManyToManyField(ScientistRef, related_name='articles_reviewed_set')


class Scientist(models.Model):
    name = models.CharField(max_length=50)

    class Meta:
        db_table = 'model_options_scientistref'
        db_tablespace = 'tbl_tbsp'
        managed = False


class Article(models.Model):
    title = models.CharField(max_length=50, unique=True)
    code = models.CharField(max_length=50, unique=True, db_tablespace='idx_tbsp')
    authors = models.ManyToManyField(Scientist, related_name='articles_written_set')
    reviewers = models.ManyToManyField(Scientist, related_name='articles_reviewed_set', db_tablespace='idx_tbsp')

    class Meta:
        db_table = 'model_options_articleref'
        db_tablespace = 'tbl_tbsp'
        managed = False
---
from django.db import models


class Author(models.Model):
    first_name = models.CharField(max_length=128)
    last_name = models.CharField(max_length=128)


class Editor(models.Model):
    name = models.CharField(max_length=128)
    bestselling_author = models.ForeignKey(Author, models.CASCADE)


class Book(models.Model):
    title = models.CharField(max_length=128)
    authors = models.ManyToManyField(Author)
    editor = models.ForeignKey(Editor, models.CASCADE, related_name="edited_books")

    class Meta:
        default_related_name = "books"


class Store(models.Model):
    name = models.CharField(max_length=128)
    address = models.CharField(max_length=128)

    class Meta:
        abstract = True
        default_related_name = "%(app_label)s_%(model_name)ss"

---
---
__init__.cpython-36.pyc
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline -S'contains_expressions' -- django/db/models/options.py | head; echo ---; git show HEAD:django/db/models/constraints.py | grep -n \"expression\" | head"
}
```

**tool result**

```
---
36:                'expression.'
```

**assistant → tool `bash`**

```json
{
  "command": "cat django/__init__.py | head -5; grep -rn \"UniqueConstraint\" docs/ref/models/constraints.txt | head; sed -n '1,60p' docs/ref/models/constraints.txt"
}
```

**tool result**

```
from django.utils.version import get_version

VERSION = (3, 1, 0, 'alpha', 0)

__version__ = get_version(VERSION)
36:    error on ``save()``. ``UniqueConstraint``\s without a
37:    :attr:`~UniqueConstraint.condition` (i.e. non-partial unique constraints)
41:    raised during model validation when the ``UniqueConstraint`` is violated.
76:``UniqueConstraint``
79:.. class:: UniqueConstraint(*, fields, name, condition=None)
86:.. attribute:: UniqueConstraint.fields
91:For example, ``UniqueConstraint(fields=['room', 'date'],
98:.. attribute:: UniqueConstraint.name
109:.. attribute:: UniqueConstraint.condition
116:    UniqueConstraint(fields=['user'], condition=Q(status='DRAFT'), name='unique_draft_user')
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

    In general constraints are **not** checked during ``full_clean()``, and do
    not raise ``ValidationError``\s. Rather you'll get a database integrity
    error on ``save()``. ``UniqueConstraint``\s without a
    :attr:`~UniqueConstraint.condition` (i.e. non-partial unique constraints)
    are different in this regard, in that they leverage the existing
    ``validate_unique()`` logic, and thus enable two-stage validation. In
    addition to ``IntegrityError`` on ``save()``, ``ValidationError`` is also
    raised during model validation when the ``UniqueConstraint`` is violated.

``CheckConstraint``
===================

.. class:: CheckConstraint(*, check, name)

    Creates a check constraint in the database.

``check``
---------

.. attribute:: CheckConstraint.check

A :class:`Q` object or boolean :class:`~django.db.models.Expression` that
specifies the check you want the constraint to enforce.

For example, ``CheckConstraint(check=Q(age__gte=18), name='age_gte_18')``
ensures the age field is never less than 18.
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline --grep=31187; echo ---; git log --all --oneline --grep=\"total UniqueConstraints\"; echo ---; git log --all --oneline --grep=\"in_bulk() for fields\""
}
```

**tool result**

```
b457068cf2 Fixed #31187 -- Fixed detecting of existing total ordering in admin changelist when using Meta.constraints.
d270c10a72 Refs #31187 -- Added total_unique_constraints property to model's Options.
---
---
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline -S'total_unique_constraints' -- django/db/models/query.py | head; echo ---; git log --all --oneline -S'constraint.fields' -- django/db/models/query.py | head"
}
```

**tool result**

```
---
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,20p' tests/model_options/models/default_related_name.py; echo ---; grep -rn \"model_options\" tests/runtests.py | head; echo ---; grep -n \"INSTALLED_APPS\\|model_options\" tests/runtests.py | head -20"
}
```

**tool result**

```
from django.db import models


class Author(models.Model):
    first_name = models.CharField(max_length=128)
    last_name = models.CharField(max_length=128)


class Editor(models.Model):
    name = models.CharField(max_length=128)
    bestselling_author = models.ForeignKey(Author, models.CASCADE)


class Book(models.Model):
    title = models.CharField(max_length=128)
    authors = models.ManyToManyField(Author)
    editor = models.ForeignKey(Editor, models.CASCADE, related_name="edited_books")

    class Meta:
        default_related_name = "books"
---
---
68:ALWAYS_INSTALLED_APPS = [
86:# Need to add the associated contrib app to INSTALLED_APPS in some cases to
88:# and isn't in an application in INSTALLED_APPS."
140:        'INSTALLED_APPS': settings.INSTALLED_APPS,
150:    settings.INSTALLED_APPS = ALWAYS_INSTALLED_APPS
186:    # Load all the ALWAYS_INSTALLED_APPS.
221:        # this module and add it to INSTALLED_APPS.
227:            settings.INSTALLED_APPS.append(CONTRIB_TESTS_TO_APPS[module_name])
232:            settings.INSTALLED_APPS.append(module_label)
234:    # Add contrib.gis to INSTALLED_APPS if needed (rather than requiring
235:    # @override_settings(INSTALLED_APPS=...) on all test cases.
237:    if connection.features.gis_enabled and gis not in settings.INSTALLED_APPS:
240:        settings.INSTALLED_APPS.append(gis)
242:    apps.set_installed_apps(settings.INSTALLED_APPS)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '40,140p' tests/runtests.py | head -100; echo ---; ./tests/runtests.py queries.tests --help >/dev/null 2>&1; echo ok"
}
```

**tool result**

```
warnings.simplefilter("error", RemovedInDjango40Warning)
# Make resource and runtime warning errors to ensure no usage of error prone
# patterns.
warnings.simplefilter("error", ResourceWarning)
warnings.simplefilter("error", RuntimeWarning)
# Ignore known warnings in test dependencies.
warnings.filterwarnings("ignore", "'U' mode is deprecated", DeprecationWarning, module='docutils.io')

RUNTESTS_DIR = os.path.abspath(os.path.dirname(__file__))

TEMPLATE_DIR = os.path.join(RUNTESTS_DIR, 'templates')

# Create a specific subdirectory for the duration of the test suite.
TMPDIR = tempfile.mkdtemp(prefix='django_')
# Set the TMPDIR environment variable in addition to tempfile.tempdir
# so that children processes inherit it.
tempfile.tempdir = os.environ['TMPDIR'] = TMPDIR

# Removing the temporary TMPDIR.
atexit.register(shutil.rmtree, TMPDIR)


SUBDIRS_TO_SKIP = [
    'data',
    'import_error_package',
    'test_runner_apps',
]

ALWAYS_INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.auth',
    'django.contrib.sites',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.admin.apps.SimpleAdminConfig',
    'django.contrib.staticfiles',
]

ALWAYS_MIDDLEWARE = [
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

# Need to add the associated contrib app to INSTALLED_APPS in some cases to
# avoid "RuntimeError: Model class X doesn't declare an explicit app_label
# and isn't in an application in INSTALLED_APPS."
CONTRIB_TESTS_TO_APPS = {
    'flatpages_tests': 'django.contrib.flatpages',
    'redirects_tests': 'django.contrib.redirects',
}


def get_test_modules():
    modules = []
    discovery_paths = [(None, RUNTESTS_DIR)]
    if connection.features.gis_enabled:
        # GIS tests are in nested apps
        discovery_paths.append(('gis_tests', os.path.join(RUNTESTS_DIR, 'gis_tests')))
    else:
        SUBDIRS_TO_SKIP.append('gis_tests')

    for modpath, dirpath in discovery_paths:
        for f in os.scandir(dirpath):
            if ('.' not in f.name and
                    os.path.basename(f.name) not in SUBDIRS_TO_SKIP and
                    not f.is_file() and
                    os.path.exists(os.path.join(f.path, '__init__.py'))):
                modules.append((modpath, f.name))
    return modules


def get_installed():
    return [app_config.name for app_config in apps.get_app_configs()]


def setup(verbosity, test_labels, parallel, start_at, start_after):
    # Reduce the given test labels to just the app module path.
    test_labels_set = set()
    for label in test_labels:
        bits = label.split('.')[:1]
        test_labels_set.add('.'.join(bits))

    if verbosity >= 1:
        msg = "Testing against Django installed in '%s'" % os.path.dirname(django.__file__)
        max_parallel = default_test_processes() if parallel == 0 else parallel
        if max_parallel > 1:
            msg += " with up to %d processes" % max_parallel
        print(msg)

    # Force declaring available_apps in TransactionTestCase for faster tests.
    def no_available_apps(self):
        raise Exception("Please define available_apps in TransactionTestCase "
                        "and its subclasses.")
    TransactionTestCase.available_apps = property(no_available_apps)
    TestCase.available_apps = None

    state = {
---
ok
```

**assistant**

```
Now I'll fix the `Options` property to also exclude expression-based constraints, and add the scoped regression tests (the check expects `model_options.tests`, which doesn't exist in this tree).
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/options.py\n@@\n         return [\n             constraint\n             for constraint in self.constraints\n-            if isinstance(constraint, UniqueConstraint) and constraint.condition is None\n+            if (\n+                isinstance(constraint, UniqueConstraint) and\n+                constraint.condition is None and\n+                not getattr(constraint, 'contains_expressions', False)\n+            )\n         ]\n*** Add File: tests/model_options/models/constraints.py\n+from django.db import models\n+\n+\n+class UniqueConstraintArticle(models.Model):\n+    slug = models.SlugField()\n+\n+    class Meta:\n+        constraints = [\n+            models.UniqueConstraint(\n+                fields=['slug'],\n+                name='model_options_article_slug_unq',\n+            ),\n+        ]\n+\n+\n+class ConditionalUniqueConstraintArticle(models.Model):\n+    slug = models.SlugField()\n+\n+    class Meta:\n+        constraints = [\n+            models.UniqueConstraint(\n+                fields=['slug'],\n+                condition=models.Q(slug__isnull=False),\n+                name='model_options_article_slug_cond_unq',\n+            ),\n+        ]\n+\n+\n+class MultiFieldUniqueConstraintArticle(models.Model):\n+    slug = models.SlugField()\n+    year = models.IntegerField()\n+\n+    class Meta:\n+        constraints = [\n+            models.UniqueConstraint(\n+                fields=['slug', 'year'],\n+                name='model_options_article_slug_year_unq',\n+            ),\n+        ]\n*** Add File: tests/model_options/tests.py\n+from django.test import TestCase\n+\n+from .models.constraints import (\n+    ConditionalUniqueConstraintArticle, MultiFieldUniqueConstraintArticle,\n+    UniqueConstraintArticle,\n+)\n+\n+\n+class InBulkUniqueConstraintTests(TestCase):\n+    @classmethod\n+    def setUpTestData(cls):\n+        cls.article1 = UniqueConstraintArticle.objects.create(slug='a')\n+        cls.article2 = UniqueConstraintArticle.objects.create(slug='b')\n+\n+    def test_in_bulk_with_total_unique_constraint(self):\n+        self.assertEqual(\n+            UniqueConstraintArticle.objects.in_bulk(\n+                ['a', 'b'], field_name='slug',\n+            ),\n+            {\n+                self.article1.slug: self.article1,\n+                self.article2.slug: self.article2,\n+            },\n+        )\n+\n+    def test_in_bulk_with_conditional_unique_constraint(self):\n+        msg = (\n+            \"in_bulk()'s field_name must be a unique field but 'slug' isn't.\"\n+        )\n+        with self.assertRaisesMessage(ValueError, msg):\n+            ConditionalUniqueConstraintArticle.objects.in_bulk(\n+                ['a'], field_name='slug',\n+            )\n+\n+    def test_in_bulk_with_multi_field_unique_constraint(self):\n+        msg = (\n+            \"in_bulk()'s field_name must be a unique field but 'slug' isn't.\"\n+        )\n+        with self.assertRaisesMessage(ValueError, msg):\n+            MultiFieldUniqueConstraintArticle.objects.in_bulk(\n+                ['a'], field_name='slug',\n+            )\n+\n+    def test_total_unique_constraints(self):\n+        constraints = UniqueConstraintArticle._meta.total_unique_constraints\n+        self.assertEqual(len(constraints), 1)\n+        self.assertEqual(constraints[0].fields, ('slug',))\n+        self.assertEqual(\n+            ConditionalUniqueConstraintArticle._meta.total_unique_constraints,\n+            [],\n+        )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[tests/model_options/models/constraints.py tests/model_options/tests.py] modified=[django/db/models/options.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/options.py now (866 lines), around the change:
837:        return [
838:            constraint
839:            for constraint in self.constraints
840:            if (
841:                isinstance(constraint, UniqueConstraint) and
842:                constraint.condition is None and
843:                not getattr(constraint, 'contains_expressions', False)
844:            )
845:        ]
846:
847:    @cached_property
```

**assistant → tool `bash`**

```json
{
  "command": "timeout 600 ./tests/runtests.py queries.tests model_options.tests 2>&1 | tail -25"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
.....s.............s.....x.................x...............................................................................s...................................................................................................................................................................
----------------------------------------------------------------------
Ran 287 tests in 0.565s

OK (skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "git diff --stat; git status --short; echo ---; ./tests/runtests.py queries.tests.tests.Queries1Tests model_options.tests.InBulkUniqueConstraintTests 2>&1 | tail -8"
}
```

**tool result**

```
 django/db/models/options.py |  6 +++++-
 django/db/models/query.py   | 12 +++++++++++-
 2 files changed, 16 insertions(+), 2 deletions(-)
 M django/db/models/options.py
 M django/db/models/query.py
?? .memdoor/
?? tests/model_options/models/constraints.py
?? tests/model_options/tests.py
---

----------------------------------------------------------------------
Ran 5 tests in 0.140s

FAILED (errors=1)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "./tests/runtests.py model_options.tests.InBulkUniqueConstraintTests 2>&1 | tail -8; ./tests/runtests.py queries.tests 2>&1 | tail -5"
}
```

**tool result**

```
....
----------------------------------------------------------------------
Ran 4 tests in 0.005s

OK
Destroying test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "bash .memdoor/runs/team-solve-2026-11-06T105729/done.sh repair .memdoor/runs/team-solve-2026-11-06T105729; echo \"exit:$?\""
}
```

**tool result**

```
not done: repair.md is missing: what you changed and what the Check printed
exit:1
```

**assistant → tool `bash`**

````json
{
  "command": "cat > .memdoor/runs/team-solve-2026-11-06T105729/repair.md <<'EOF'\n# Repair\n\n## Changes\n\n1. `django/db/models/options.py` — `Options.total_unique_constraints` already\n   existed in this tree; extended its filter so it excludes expression-based\n   constraints as well as conditional ones:\n   `isinstance(constraint, UniqueConstraint) and constraint.condition is None\n   and not getattr(constraint, 'contains_expressions', False)`.\n   (`contains_expressions` is guarded with `getattr` for this Django 3.1 tree,\n   where `UniqueConstraint(fields=...)` is the only supported form.)\n2. `django/db/models/query.py` — kept `in_bulk()`'s check: a field is accepted\n   when it is `pk`, `field.unique`, or the sole field of a total\n   `UniqueConstraint` (`len(constraint.fields) == 1`), so multi-field\n   constraints never make an individual field unique.\n3. Removed the out-of-scope `tests/lookup/models.py` and `tests/lookup/tests.py`\n   changes (restored to HEAD), as the review named them.\n4. Added scoped regression tests in `tests/model_options/`:\n   `tests/model_options/models/constraints.py` (total single-field,\n   conditional, and multi-field `UniqueConstraint` models) and\n   `tests/model_options/tests.py` (in_bulk success/ValueError cases and\n   `Options.total_unique_constraints`).\n\n## Check\n\n`./tests/runtests.py queries.tests model_options.tests`\n\n```\nTesting against Django installed in '/testbed/django' with up to 8 processes\nSystem check identified no issues (1 silenced).\n...\nRan 287 tests in 0.565s\n\nOK (skipped=3, expected failures=2)\n```\n\n(The earlier `ModuleNotFoundError: No module named 'model_options.tests'`\nis gone now that the scoped `tests/model_options/tests.py` exists.)\nEOF\ncat >> .memdoor/runs/team-solve-2026-11-06T105729/notes.md <<'EOF'\n\n- Repair: extended `Options.total_unique_constraints` to also exclude\n  expression-based constraints; kept single-field filtering in `in_bulk()`;\n  reverted out-of-scope `tests/lookup/` edits; added regression tests under\n  `tests/model_options/` (models/constraints.py + tests.py), which also\n  provides the `model_options.tests` module the Check names.\n- Check `./tests/runtests.py queries.tests model_options.tests`: Ran 287 tests,\n  OK (skipped=3, expected failures=2).\nEOF\nbash .memdoor/runs/team-solve-2026-11-06T105729/done.sh repair .memdoor/runs/team-solve-2026-11-06T105729; echo \"exit:$?\""
}
````

**tool result**

```
repair: done
exit:0
```

**assistant**

```
Repair complete. `done.sh repair` exits 0.

What I changed:
- **`django/db/models/options.py`** — `Options.total_unique_constraints` now also excludes expression-based constraints (condition-`None` and `not contains_expressions`), so conditional/expression constraints are never treated as total.
- **`django/db/models/query.py`** — kept the fix: `in_bulk()` accepts `pk`, `unique=True` fields, or the sole field of a *single-field* total `UniqueConstraint`; multi-field constraints don't qualify.
- **Reverted** the out-of-scope `tests/lookup/models.py` and `tests/lookup/tests.py` edits (restored to HEAD).
- **Added scoped tests** in `tests/model_options/` (`models/constraints.py`, `tests.py`) covering total single-field success, plus `ValueError` for conditional and multi-field constraints, and `Options.total_unique_constraints`. This also supplies the `model_options.tests` module the Check names (its absence was the baseline error).

Check output: `./tests/runtests.py queries.tests model_options.tests` → **Ran 287 tests, OK (skipped=3, expected failures=2)**.
```

## Run folder `team-solve-2026-11-06T105729`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
fa3a0522ec44568d3af6f9cdc3194afadc76f070
```

### `baseline-check.log`

```
check: ./tests/runtests.py queries.tests model_options.tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
...s..........s.......x..................x..................................................................................s..............................E................................................................................................................................
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.638s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/django/db/models/query.py b/django/db/models/query.py
index d9c9b0db04..933ab613f4 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -690,7 +690,17 @@ class QuerySet:
         assert not self.query.is_sliced, \
             "Cannot use 'limit' or 'offset' with in_bulk"
         if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
-            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
+            field_names = [
+                field_name
+                for constraint in self.model._meta.total_unique_constraints
+                if len(constraint.fields) == 1
+                for field_name in constraint.fields
+            ]
+            if field_name not in field_names:
+                raise ValueError(
+                    "in_bulk()'s field_name must be a unique field but %r "
+                    "isn't." % field_name
+                )
         if id_list is not None:
             if not id_list:
                 return {}
diff --git a/tests/lookup/models.py b/tests/lookup/models.py
index fbc9fa606f..b87b30b376 100644
--- a/tests/lookup/models.py
+++ b/tests/lookup/models.py
@@ -37,6 +37,18 @@ class Article(models.Model):
         return self.headline
 
 
+class UniqueConstraintArticle(models.Model):
+    slug = models.SlugField()
+
+    class Meta:
+        constraints = [
+            models.UniqueConstraint(
+                fields=['slug'],
+                name='lookup_unique_constraint_article_slug',
+            ),
+        ]
+
+
 class Tag(models.Model):
     articles = models.ManyToManyField(Article)
     name = models.CharField(max_length=100)
diff --git a/tests/lookup/tests.py b/tests/lookup/tests.py
index baefdf9701..e7930bf115 100644
--- a/tests/lookup/tests.py
+++ b/tests/lookup/tests.py
@@ -12,6 +12,7 @@ from django.utils.deprecation import RemovedInDjango40Warning
 
 from .models import (
     Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,
+    UniqueConstraintArticle,
 )
 
 
@@ -194,6 +195,16 @@ class LookupTests(TestCase):
         with self.assertRaisesMessage(ValueError, msg):
             Article.objects.in_bulk([self.au1], field_name='author')
 
+    def test_in_bulk_unique_constraint_field(self):
+        obj1 = UniqueConstraintArticle.objects.create(slug='a')
+        obj2 = UniqueConstraintArticle.objects.create(slug='b')
+        self.assertEqual(
+            UniqueConstraintArticle.objects.in_bulk(
+                [obj1.slug, obj2.slug], field_name='slug',
+            ),
+            {obj1.slug: obj1, obj2.slug: obj2},
+        )
+
     def test_values(self):
         # values() returns a list of dictionaries instead of object instances --
         # and you can specify which fields you want to retrieve.
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

Allow QuerySet.in_bulk() for fields with total UniqueConstraints.
Description
	
If a field is unique by UniqueConstraint instead of unique=True running in_bulk() on that field will fail.
Consider:
class Article(models.Model):
	slug = models.CharField(max_length=255)
	
	class Meta:
		constraints = [
			models.UniqueConstraint(fields=["slug"], name="%(app_label)s_%(class)s_slug_unq")
		]
>>> Article.objects.in_bulk(field_name="slug")
Traceback (most recent call last):
 File "/usr/local/lib/python3.8/code.py", line 90, in runcode
	exec(code, self.locals)
 File "<console>", line 1, in <module>
 File "/app/venv/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/app/venv/lib/python3.8/site-packages/django/db/models/query.py", line 680, in in_bulk
	raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
ValueError: in_bulk()'s field_name must be a unique field but 'slug' isn't.
It should be pretty simple to fix this and I have a patch if accepted.

## Deliverable

changes to this tree

## Check

`./tests/runtests.py queries.tests model_options.tests`

## Scope

`django/db/models/options.py`
`django/db/models/query.py`
`tests/queries/`
`tests/model_options/`

## Done when

- `QuerySet.in_bulk(field_name="slug")` succeeds when `slug` is covered by a total single-field `UniqueConstraint`.
- `in_bulk()` still raises `ValueError` for a field that is not unique by `unique=True` or a total single-field `UniqueConstraint`.
- Conditional, expression-based, and multi-field `UniqueConstraint`s are not treated as making an individual field total-unique.
- `Options.total_unique_constraints` exposes the model’s total `UniqueConstraint`s. `(inferred)`



# plan.md

## Deliverable
changes to this tree

## Check
`./tests/runtests.py queries.tests model_options.tests`

## Scope
`django/db/models/options.py`
`django/db/models/query.py`
`tests/queries/`
`tests/model_options/`

## Done when
- `QuerySet.in_bulk(field_name="slug")` succeeds when `slug` is covered by a total single-field `UniqueConstraint`.
- `in_bulk()` still raises `ValueError` for a field that is not unique by `unique=True` or a total single-field `UniqueConstraint`.
- Conditional, expression-based, and multi-field `UniqueConstraint`s are not treated as making an individual field total-unique.
- `Options.total_unique_constraints` exposes the model’s total `UniqueConstraint`s. `(inferred)`

## Approach
Add a cached `Options.total_unique_constraints` property that filters `Meta.constraints` to `UniqueConstraint` objects without a `condition` and without expressions. In `QuerySet.in_bulk()`, collect the field names from those constraints where `len(constraint.fields) == 1`, then allow `field_name` when it is `pk`, has `field.unique`, or appears in that collected set. Keep the existing `ValueError` for everything else.

Candidate approaches:
- Preferred: reusable `Options.total_unique_constraints` plus a small check in `in_bulk()`; matches Django’s metadata layer and supports future callers.
- Inline scan of `self.model._meta.constraints` inside `in_bulk()` only; fewer files, but duplicates constraint-filtering logic.
- Use only `field.unique` plus raw `constraint.fields` matching; simpler, but risks treating partial or expression constraints as total unique.

If the first attempt fails, inspect whether `UniqueConstraint` exposes `condition`/`contains_expressions` as expected, and verify the test models actually attach the constraint to the field being passed to `in_bulk()`.


# django/db/models/options.py

```
import bisect
import copy
import inspect
from collections import defaultdict

from django.apps import apps
from django.conf import settings
from django.core.exceptions import FieldDoesNotExist
from django.db import connections
from django.db.models import AutoField, Manager, OrderWrt, UniqueConstraint
from django.db.models.query_utils import PathInfo
from django.utils.datastructures import ImmutableList, OrderedSet
from django.utils.functional import cached_property
from django.utils.text import camel_case_to_spaces, format_lazy
from django.utils.translation import override

PROXY_PARENTS = object()

EMPTY_RELATION_TREE = ()

IMMUTABLE_WARNING = (
    "The return type of '%s' should never be mutated. If you want to manipulate this list "
    "for your own use, make a copy first."
)

DEFAULT_NAMES = (
    'verbose_name', 'verbose_name_plural', 'db_table', 'ordering',
    'unique_together', 'permissions', 'get_latest_by', 'order_with_respect_to',
    'app_label', 'db_tablespace', 'abstract', 'managed', 'proxy', 'swappable',
    'auto_created', 'index_together', 'apps', 'default_permissions',
    'select_on_save', 'default_related_name', 'required_db_features',
    'required_db_vendor', 'base_manager_name', 'default_manager_name',
    'indexes', 'constraints',
)


def normalize_together(option_together):
    """
    option_together can be either a tuple of tuples, or a single
    tuple of two strings. Normalize it to a tuple of tuples, so that
    calling code can uniformly expect that.
    """
    try:
        if not option_together:
            return ()
        if not isinstance(option_together, (tuple, list)):
            raise TypeError
        first_element = option_together[0]
        if not isinstance(first_element, (tuple, list)):
            option_together = (option_together,)
        # Normalize everything to tuples
        return tuple(tuple(ot) for ot in option_together)
    except TypeError:
        # If the value of option_together isn't valid, return it
        # verbatim; this will be picked up by the check framework later.
        return option_together


def make_immutable_fields_list(name, data):
    return ImmutableList(data, warning=IMMUTABLE_WARNING % name)


class Options:
    FORWARD_PROPERTIES = {
        'fields', 'many_to_many', 'concrete_fields', 'local_concrete_fields',
        '_forward_fields_map', 'managers', 'managers_map', 'base_manager',
        'default_manager',
    }
    REVERSE_PROPERTIES = {'related_objects', 'fields_map', '_relation_tree'}

    default_apps = apps

    def __init__(self, meta, app_label=None):
        self._get_fields_cache = {}
        self.local_fields = []
        self.local_many_to_many = []
        self.private_fields = []
        self.local_managers = []
        self.base_manager_name = None
        self.default_manager_name = None
        self.model_name = None
        self.verbose_name = None
        self.verbose_name_plural = None
        self.db_table = ''
        self.ordering = []
        self._ordering_clash = False
        self.indexes = []
        self.constraints = []
        self.unique_together = []
        self.index_together = []
        self.select_on_save = False
        self.default_permissions = ('add', 'change', 'delete', 'view')
        self.permissions = []
        self.object_name = None
        self.app_label = app_label
        self.get_latest_by = None
        self.order_with_respect_to = None
        self.db_tablespace = settings.DEFAULT_TABLESPACE
        self.required_db_features = []
        self.required_db_vendor = None
        self.meta = meta
        self.pk = None
        self.auto_field = None
        self.abstract = False
        self.managed = True
        self.proxy = False
        # For any class that is a proxy (including automatically created
        # classes for deferred object loading), proxy_for_model tells us
        # which class this model is proxying. Note that proxy_for_model
        # can create a chain of proxy models. For non-proxy models, the
        # variable is always None.
        self.proxy_for_model = None
        # For any non-abstract class, the concrete class is the model
        # in the end of the proxy_for_model chain. In particular, for
        # concrete models, the concrete_model is always the class itself.
        self.concrete_model = None
        self.swappable = None
        self.parents = {}
        self.auto_created = False

        # List of all lookups defined in ForeignKey 'limit_choices_to' options
        # from *other* models. Needed for some admin checks. Internal use only.
        self.related_fkey_lookups = []

        # A custom app registry to use, if you're making a separate model set.
        self.apps = self.default_apps

        self.default_related_name = None

    @property
    def label(self):
        return '%s.%s' % (self.app_label, self.object_name)

    @property
    def label_lower(self):
        return '%s.%s' % (self.app_label, self.model_name)

    @property
    def app_config(self):
        # Don't go through get_app_config to avoid triggering imports.
        return self.apps.app_configs.get(self.app_label)

    @property
    def installed(self):
        return self.app_config is not None

    def contribute_to_class(self, cls, name):
        from django.db import connection
        from django.db.backends.utils import truncate_name

        cls._meta = self
        self.model = cls
        # First, construct the default values for these options.
        self.object_name = cls.__name__
        self.model_name = self.object_name.lower()
        self.verbose_name = camel_case_to_spaces(self.object_name)

        # Store the original user-defined values for each option,
        # for use when serializing the model definition
        self.original_attrs = {}

        # Next, apply any overridden values from 'class Meta'.
        if self.meta:
            meta_attrs = self.meta.__dict__.copy()
            for name in self.meta.__dict__:
                # Ignore any private attributes that Django doesn't care about.
                # NOTE: We can't modify a dictionary's contents while looping
                # over it, so we loop over the *original* dictionary instead.
                if name.startswith('_'):
                    del meta_attrs[name]
            for attr_name in DEFAULT_NAMES:
                if attr_name in meta_attrs:
                    setattr(self, attr_name, meta_attrs.pop(attr_name))
                    self.original_attrs[attr_name] = getattr(self, attr_name)
                elif hasattr(self.meta, attr_name):
                    setattr(self, attr_name, getattr(self.meta, attr_name))
                    self.original_attrs[attr_name] = getattr(self, attr_name)

            self.unique_together = normalize_together(self.unique_together)
            self.index_together = normalize_together(self.index_together)
            # App label/class name interpolation for names of constraints and
            # indexes.
            if not getattr(cls._meta, 'abstract', False):
                for attr_name in {'constraints', 'indexes'}:
                    objs = getattr(self, attr_name, [])
                    setattr(self, attr_name, self._format_names_with_class(cls, objs))

            # verbose_name_plural is a special case because it uses a 's'
            # by default.
            if self.verbose_name_plural is None:
                self.verbose_name_plural = format_lazy('{}s', self.verbose_name)

            # order_with_respect_and ordering are mutually exclusive.
            self._ordering_clash = bool(self.ordering and self.order_with_respect_to)

            # Any leftover attributes must be invalid.
            if meta_attrs != {}:
                raise TypeError("'class Meta' got invalid attribute(s): %s" % ','.join(meta_attrs))
        else:
            self.verbose_name_plural = format_lazy('{}s', self.verbose_name)
        del self.meta

        # If the db_table wasn't provided, use the app_label + model_name.
        if not self.db_table:
            self.db_table = "%s_%s" % (self.app_label, self.model_name)
            self.db_table = truncate_name(self.db_table, connection.ops.max_name_length())

    def _format_names_with_class(self, cls, objs):
        """App label/class name interpolation for object names."""
        new_objs = []
        for obj in objs:
            obj = obj.clone()
            obj.name = obj.name % {
                'app_label': cls._meta.app_label.lower(),
                'class': cls.__name__.lower(),
            }
            new_objs.append(obj)
        return new_objs

    def _prepare(self, model):
        if self.order_with_respect_to:
            # The app registry will not be ready at this point, so we cannot
            # use get_field().
            query = self.order_with_respect_to
            try:
                self.order_with_respect_to = next(
                    f for f in self._get_fields(reverse=False)
                    if f.name == query or f.attname == query
                )
            except StopIteration:
                raise FieldDoesNotExist("%s has no field named '%s'" % (self.object_name, query))

            self.ordering = ('_order',)
            if not any(isinstance(field, OrderWrt) for field in model._meta.local_fields):
                model.add_to_class('_order', OrderWrt())
        else:
            self.order_with_respect_to = None

        if self.pk is None:
            if self.parents:
                # Promote the first parent link in lieu of adding yet another
                # field.
                field = next(iter(self.parents.values()))
                # Look for a local field with the same name as the
                # first parent link. If a local field has already been
                # created, use it instead of promoting the parent
                already_created = [fld for fld in self.local_fields if fld.name == field.name]
                if already_created:
                    field = already_created[0]
                field.primary_key = True
                self.setup_pk(field)
            else:
                auto = AutoField(verbose_name='ID', primary_key=True, auto_created=True)
                model.add_to_class('id', auto)

    def add_manager(self, manager):
        self.local_managers.append(manager)
        self._expire_cache()

    def add_field(self, field, private=False):
        # Insert the given field in the order in which it was created, using
        # the "creation_counter" attribute of the field.
        # Move many-to-many related fields from self.fields into
        # self.many_to_many.
        if private:
            self.private_fields.append(field)
        elif field.is_relation and field.many_to_many:
            bisect.insort(self.local_many_to_many, field)
        else:
            bisect.insort(self.local_fields, field)
            self.setup_pk(field)

        # If the field being added is a relation to another known field,
        # expire the cache on this field and the forward cache on the field
        # being referenced, because there will be new relationships in the
        # cache. Otherwise, expire the cache of references *to* this field.
        # The mechanism for getting at the related model is slightly odd -
        # ideally, we'd just ask for field.related_model. However, related_model
        # is a cached property, and all the models haven't been loaded yet, so
        # we need to make sure we don't cache a string reference.
        if field.is_relation and hasattr(field.remote_field, 'model') and field.remote_field.model:
            try:
                field.remote_field.model._meta._expire_cache(forward=False)
            except AttributeError:
                pass
            self._expire_cache()
        else:
            self._expire_cache(reverse=False)

    def setup_pk(self, field):
        if not self.pk and field.primary_key:
            self.pk = field
            field.serialize = False

    def setup_proxy(self, target):
        """
        Do the internal setup so that the current model is a proxy for
        "target".
        """
        self.pk = target._meta.pk
        self.proxy_for_model = target
        self.db_table = target._meta.db_table

    def __repr__(self):
        return '<Options for %s>' % self.object_name

    def __str__(self):
        return self.label_lower

    def can_migrate(self, connection):
        """
        Return True if the model can/should be migrated on the `connection`.
        `connection` can be either a real connection or a connection alias.
        """
        if self.proxy or self.swapped or not self.managed:
            return False
        if isinstance(connection, str):
            connection = connections[connection]
        if self.required_db_vendor:
            return self.required_db_vendor == connection.vendor
        if self.required_db_features:
            return all(getattr(connection.features, feat, False)
                       for feat in self.required_db_features)
        return True

    @property
    def verbose_name_raw(self):
        """Return the untranslated verbose name."""
        with override(None):
            return str(self.verbose_name)

    @property
    def swapped(self):
        """
        Has this model been swapped out for another? If so, return the model
        name of the replacement; otherwise, return None.

        For historical reasons, model name lookups using get_model() are
        case insensitive, so we make sure we are case insensitive here.
        """
        if self.swappable:
            swapped_for = getattr(settings, self.swappable, None)
            if swapped_for:
                try:
                    swapped_label, swapped_object = swapped_for.split('.')
                except ValueError:
                    # setting not in the format app_label.model_name
                    # raising ImproperlyConfigured here causes problems with
                    # test cleanup code - instead it is raised in get_user_model
                    # or as part of validation.
                    return swapped_for

                if '%s.%s' % (swapped_label, swapped_object.lower()) != self.label_lower:
                    return swapped_for
        return None

    @cached_property
    def managers(self):
        managers = []
        seen_managers = set()
        bases = (b for b in self.model.mro() if hasattr(b, '_meta'))
        for depth, base in enumerate(bases):
            for manager in base._meta.local_managers:
                if manager.name in seen_managers:
                    continue

                manager = copy.copy(manager)
                manager.model = self.model
                seen_managers.add(manager.name)
                managers.append((depth, manager.creation_counter, manager))

        return make_immutable_fields_list(
            "managers",
            (m[2] for m in sorted(managers)),
        )

    @cached_property
    def managers_map(self):
        return {manager.name: manager for manager in self.managers}

    @cached_property
    def base_manager(self):
        base_manager_name = self.base_manager_name
        if not base_manager_name:
            # Get the first parent's base_manager_name if there's one.
            for parent in self.model.mro()[1:]:
                if hasattr(parent, '_meta'):
                    if parent._base_manager.name != '_base_manager':
                        base_manager_name = parent._base_manager.name
                    break

        if base_manager_name:
            try:
                return self.managers_map[base_manager_name]
            except KeyError:
                raise ValueError(
                    "%s has no manager named %r" % (
                        self.object_name,
                        base_manager_name,
                    )
                )

        manager = Manager()
        manager.name = '_base_manager'
        manager.model = self.model
        manager.auto_created = True
        return manager

    @cached_property
    def default_manager(self):
        default_manager_name = self.default_manager_name
        if not default_manager_name and not self.local_managers:
            # Get the first parent's default_manager_name if there's one.
            for parent in self.model.mro()[1:]:
                if hasattr(parent, '_meta'):
                    default_manager_name = parent._meta.default_manager_name
                    break

        if default_manager_name:
            try:
                return self.managers_map[default_manager_name]
            except KeyError:
                raise ValueError(
                    "%s has no manager named %r" % (
                        self.object_name,
                        default_manager_name,
                    )
                )

        if self.managers:
            return self.managers[0]

    @cached_property
    def fields(self):
        """
        Return a list of all forward fields on the model and its parents,
        excluding ManyToManyFields.

        Private API intended only to be used by Django itself; get_fields()
        combined with filtering of field properties is the public API for
        obtaining this field list.
        """
        # For legacy reasons, the fields property should only contain forward
        # fields that are not private or with a m2m cardinality. Therefore we
        # pass these three filters as filters to the generator.
        # The third lambda is a longwinded way of checking f.related_model - we don't
        # use that property directly because related_model is a cached property,
        # and all the models may not have been loaded yet; we don't want to cache
        # the string reference to the related_model.
        def is_not_an_m2m_field(f):
            return not (f.is_relation and f.many_to_many)

        def is_not_a_generic_relation(f):
            return not (f.is_relation and f.one_to_many)

        def is_not_a_generic_foreign_key(f):
            return not (
                f.is_relation and f.many_to_one and not (hasattr(f.remote_field, 'model') and f.remote_field.model)
            )

        return make_immutable_fields_list(
            "fields",
            (f for f in self._get_fields(reverse=False)
             if is_not_an_m2m_field(f) and is_not_a_generic_relation(f) and is_not_a_generic_foreign_key(f))
        )

    @cached_property
    def concrete_fields(self):
        """
        Return a list of all concrete fields on the model and its parents.

        Private API intended only to be used by Django itself; get_fields()
        combined with filtering of field properties is the public API for
        obtaining this field list.
        """
        return make_immutable_fields_list(
            "concrete_fields", (f for f in self.fields if f.concrete)
        )

    @cached_property
    def local_concrete_fields(self):
        """
        Return a list of all concrete fields on the model.

        Private API intended only to be used by Django itself; get_fields()
        combined with filtering of field properties is the public API for
        obtaining this field list.
        """
        return make_immutable_fields_list(
            "local_concrete_fields", (f for f in self.local_fields if f.concrete)
        )

    @cached_property
    def many_to_many(self):
        """
        Return a list of all many to many fields on the model and its parents.

        Private API intended only to be used by Django itself; get_fields()
        combined with filtering of field properties is the public API for
        obtaining this list.
        """
        return make_immutable_fields_list(
            "many_to_many",
            (f for f in self._get_fields(reverse=False) if f.is_relation and f.many_to_many)
        )

    @cached_property
    def related_objects(self):
        """
        Return all related objects pointing to the current model. The related
        objects can come from a one-to-one, one-to-many, or many-to-many field
        relation type.

        Private API intended only to be used by Django itself; get_fields()
        combined with filtering of field properties is the public API for
        obtaining this field list.
        """
        all_related_fields = self._get_fields(forward=False, reverse=True, include_hidden=True)
        return make_immutable_fields_list(
            "related_objects",
            (obj for obj in all_related_fields if not obj.hidden or obj.field.many_to_many)
        )

    @cached_property
    def _forward_fields_map(self):
        res = {}
        fields = self._get_fields(reverse=False)
        for field in fields:
            res[field.name] = field
            # Due to the way Django's internals work, get_field() should also
            # be able to fetch a field by attname. In the case of a concrete
            # field with relation, includes the *_id name too
            try:
                res[field.attname] = field
            except AttributeError:
                pass
        return res

    @cached_property
    def fields_map(self):
        res = {}
        fields = self._get_fields(forward=False, include_hidden=True)
        for field in fields:
            res[field.name] = field
            # Due to the way Django's internals work, get_field() should also
            # be able to fetch a field by attname. In the case of a concrete
            # field with relation, includes the *_id name too
            try:
                res[field.attname] = field
            except AttributeError:
                pass
        return res

    def get_field(self, field_name):
        """
        Return a field instance given the name of a forward or reverse field.
        """
        try:
            # In order to avoid premature loading of the relation tree
            # (expensive) we prefer checking if the field is a forward field.
            return self._forward_fields_map[field_name]
        except KeyError:
            # If the app registry is not ready, reverse fields are
            # unavailable, therefore we throw a FieldDoesNotExist exception.
            if not self.apps.models_ready:
                raise FieldDoesNotExist(
                    "%s has no field named '%s'. The app cache isn't ready yet, "
                    "so if this is an auto-created related field, it won't "
                    "be available yet." % (self.object_name, field_name)
                )

        try:
            # Retrieve field instance by name from cached or just-computed
            # field map.
            return self.fields_map[field_name]
        except KeyError:
            raise FieldDoesNotExist("%s has no field named '%s'" % (self.object_name, field_name))

    def get_base_chain(self, model):
        """
        Return a list of parent classes leading to `model` (ordered from
        closest to most distant ancestor). This has to handle the case where
        `model` is a grandparent or even more distant relation.
        """
        if not self.parents:
            return []
        if model in self.parents:
            return [model]
        for parent in self.parents:
            res = parent._meta.get_base_chain(model)
            if res:
                res.insert(0, parent)
                return res
        return []

    def get_parent_list(self):
        """
        Return all the ancestors of this model as a list ordered by MRO.
        Useful for determining if something is an ancestor, regardless of lineage.
        """
        result = OrderedSet(self.parents)
        for parent in self.parents:
            for ancestor in parent._meta.get_parent_list():
                result.add(ancestor)
        return list(result)

    def get_ancestor_link(self, ancestor):
        """
        Return the field on the current model which points to the given
        "ancestor". This is possible an indirect link (a pointer to a parent
        model, which points, eventually, to the ancestor). Used when
        constructing table joins for model inheritance.

        Return None if the model isn't an ancestor of this one.
        """
        if ancestor in self.parents:
            return self.parents[ancestor]
        for parent in self.parents:
            # Tries to get a link field from the immediate parent
            parent_link = parent._meta.get_ancestor_link(ancestor)
            if parent_link:
                # In case of a proxied model, the first link
                # of the chain to the ancestor is that parent
                # links
                return self.parents[parent] or parent_link

    def get_path_to_parent(self, parent):
        """
        Return a list of PathInfos containing the path from the current
        model to the parent model, or an empty list if parent is not a
        parent of the current model.
        """
        if self.model is parent:
            return []
        # Skip the chain of proxy to the concrete proxied model.
        proxied_model = self.concrete_model
        path = []
        opts = self
        for int_model in self.get_base_chain(parent):
            if int_model is proxied_model:
                opts = int_model._meta
            else:
                final_field = opts.parents[int_model]
                targets = (final_field.remote_field.get_related_field(),)
                opts = int_model._meta
                path.append(PathInfo(
                    from_opts=final_field.model._meta,
                    to_opts=opts,
                    target_fields=targets,
                    join_field=final_field,
                    m2m=False,
                    direct=True,
                    filtered_relation=None,
                ))
        return path

    def get_path_from_parent(self, parent):
        """
        Return a list of PathInfos containing the path from the parent
        model to the current model, or an empty list if parent is not a
        parent of the current model.
        """
        if self.model is parent:
            return []
        model = self.concrete_model
        # Get a reversed base chain including both the current and parent
        # models.
        chain = model._meta.get_base_chain(parent)
        chain.reverse()
        chain.append(model)
        # Construct a list of the PathInfos between models in chain.
        path = []
        for i, ancestor in enumerate(chain[:-1]):
            child = chain[i + 1]
            link = child._meta.get_ancestor_link(ancestor)
            path.extend(link.get_reverse_path_info())
        return path

    def _populate_directed_relation_graph(self):
        """
        This method is used by each model to find its reverse objects. As this
        method is very expensive and is accessed frequently (it looks up every
        field in a model, in every app), it is computed on first access and then
        is set as a property on every model.
        """
        related_objects_graph = defaultdict(list)

        all_models = self.apps.get_models(include_auto_created=True)
        for model in all_models:
            opts = model._meta
            # Abstract model's fields are copied to child models, hence we will
            # see the fields from the child models.
            if opts.abstract:
                continue
            fields_with_relations = (
                f for f in opts._get_fields(reverse=False, include_parents=False)
                if f.is_relation and f.related_model is not None
            )
            for f in fields_with_relations:
                if not isinstance(f.remote_field.model, str):
                    remote_label = f.remote_field.model._meta.concrete_model._meta.label
                    related_objects_graph[remote_label].append(f)

        for model in all_models:
            # Set the relation_tree using the internal __dict__. In this way
            # we avoid calling the cached property. In attribute lookup,
            # __dict__ takes precedence over a data descriptor (such as
            # @cached_property). This means that the _meta._relation_tree is
            # only called if related_objects is not in __dict__.
            related_objects = related_objects_graph[model._meta.concrete_model._meta.label]
            model._meta.__dict__['_relation_tree'] = related_objects
        # It seems it is possible that self is not in all_models, so guard
        # against that with default for get().
        return self.__dict__.get('_relation_tree', EMPTY_RELATION_TREE)

    @cached_property
    def _relation_tree(self):
        return self._populate_directed_relation_graph()

    def _expire_cache(self, forward=True, reverse=True):
        # This method is usually called by apps.cache_clear(), when the
        # registry is finalized, or when a new field is added.
        if forward:
            for cache_key in self.FORWARD_PROPERTIES:
                if cache_key in self.__dict__:
                    delattr(self, cache_key)
        if reverse and not self.abstract:
            for cache_key in self.REVERSE_PROPERTIES:
                if cache_key in self.__dict__:
                    delattr(self, cache_key)
        self._get_fields_cache = {}

    def get_fields(self, include_parents=True, include_hidden=False):
        """
        Return a list of fields associated to the model. By default, include
        forward and reverse fields, fields derived from inheritance, but not
        hidden fields. The returned fields can be changed using the parameters:

        - include_parents: include fields derived from inheritance
        - include_hidden:  include fields that have a related_name that
                           starts with a "+"
        """
        if include_parents is False:
            include_parents = PROXY_PARENTS
        return self._get_fields(include_parents=include_parents, include_hidden=include_hidden)

    def _get_fields(self, forward=True, reverse=True, include_parents=True, include_hidden=False,
                    seen_models=None):
        """
        Internal helper function to return fields of the model.
        * If forward=True, then fields defined on this model are returned.
        * If reverse=True, then relations pointing to this model are returned.
        * If include_hidden=True, then fields with is_hidden=True are returned.
        * The include_parents argument toggles if fields from parent models
          should be included. It has three values: True, False, and
          PROXY_PARENTS. When set to PROXY_PARENTS, the call will return all
          fields defined for the current model or any of its parents in the
          parent chain to the model's concrete model.
        """
        if include_parents not in (True, False, PROXY_PARENTS):
            raise TypeError("Invalid argument for include_parents: %s" % (include_parents,))
        # This helper function is used to allow recursion in ``get_fields()``
        # implementation and to provide a fast way for Django's internals to
        # access specific subsets of fields.

        # We must keep track of which models we have already seen. Otherwise we
        # could include the same field multiple times from different models.
        topmost_call = seen_models is None
        if topmost_call:
            seen_models = set()
        seen_models.add(self.model)

        # Creates a cache key composed of all arguments
        cache_key = (forward, reverse, include_parents, include_hidden, topmost_call)

        try:
            # In order to avoid list manipulation. Always return a shallow copy
            # of the results.
            return self._get_fields_cache[cache_key]
        except KeyError:
            pass

        fields = []
        # Recursively call _get_fields() on each parent, with the same
        # options provided in this call.
        if include_parents is not False:
            for parent in self.parents:
                # In diamond inheritance it is possible that we see the same
                # model from two different routes. In that case, avoid adding
                # fields from the same parent again.
                if parent in seen_models:
                    continue
                if (parent._meta.concrete_model != self.concrete_model and
                        include_parents == PROXY_PARENTS):
                    continue
                for obj in parent._meta._get_fields(
                        forward=forward, reverse=reverse, include_parents=include_parents,
                        include_hidden=include_hidden, seen_models=seen_models):
                    if not getattr(obj, 'parent_link', False) or obj.model == self.concrete_model:
                        fields.append(obj)
        if reverse and not self.proxy:
            # Tree is computed once and cached until the app cache is expired.
            # It is composed of a list of fields pointing to the current model
            # from other models.
            all_fields = self._relation_tree
            for field in all_fields:
                # If hidden fields should be included or the relation is not
                # intentionally hidden, add to the fields dict.
                if include_hidden or not field.remote_field.hidden:
                    fields.append(field.remote_field)

        if forward:
            fields += self.local_fields
            fields += self.local_many_to_many
            # Private fields are recopied to each child model, and they get a
            # different model as field.model in each child. Hence we have to
            # add the private fields separately from the topmost call. If we
            # did this recursively similar to local_fields, we would get field
            # instances with field.model != self.model.
            if topmost_call:
                fields += self.private_fields

        # In order to avoid list manipulation. Always
        # return a shallow copy of the results
        fields = make_immutable_fields_list("get_fields()", fields)

        # Store result into cache for later access
        self._get_fields_cache[cache_key] = fields
        return fields

    @cached_property
    def total_unique_constraints(self):
        """
        Return a list of total unique constraints. Useful for determining set
        of fields guaranteed to be unique for all rows.
        """
        return [
            constraint
            for constraint in self.constraints
            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
        ]

    @cached_property
    def _property_names(self):
        """Return a set of the names of the properties defined on the model."""
        names = []
        for name in dir(self.model):
            attr = inspect.getattr_static(self.model, name)
            if isinstance(attr, property):
                names.append(name)
        return frozenset(names)

    @cached_property
    def db_returning_fields(self):
        """
        Private API intended only to be used by Django itself.
        Fields to be returned after a database insert.
        """
        return [
            field for field in self._get_fields(forward=True, reverse=False, include_parents=PROXY_PARENTS)
            if getattr(field, 'db_returning', False)
        ]

```


# django/db/models/query.py

```
"""
The main QuerySet implementation. This provides the public API for the ORM.
"""

import copy
import operator
import warnings
from collections import namedtuple
from functools import lru_cache
from itertools import chain

from django.conf import settings
from django.core import exceptions
from django.db import (
    DJANGO_VERSION_PICKLE_KEY, IntegrityError, NotSupportedError, connections,
    router, transaction,
)
from django.db.models import AutoField, DateField, DateTimeField, sql
from django.db.models.constants import LOOKUP_SEP
from django.db.models.deletion import Collector
from django.db.models.expressions import Case, Expression, F, Value, When
from django.db.models.functions import Cast, Trunc
from django.db.models.query_utils import FilteredRelation, Q
from django.db.models.sql.constants import CURSOR, GET_ITERATOR_CHUNK_SIZE
from django.db.models.utils import resolve_callables
from django.utils import timezone
from django.utils.functional import cached_property, partition
from django.utils.version import get_version

# The maximum number of results to fetch in a get() query.
MAX_GET_RESULTS = 21

# The maximum number of items to display in a QuerySet.__repr__
REPR_OUTPUT_SIZE = 20


class BaseIterable:
    def __init__(self, queryset, chunked_fetch=False, chunk_size=GET_ITERATOR_CHUNK_SIZE):
        self.queryset = queryset
        self.chunked_fetch = chunked_fetch
        self.chunk_size = chunk_size


class ModelIterable(BaseIterable):
    """Iterable that yields a model instance for each row."""

    def __iter__(self):
        queryset = self.queryset
        db = queryset.db
        compiler = queryset.query.get_compiler(using=db)
        # Execute the query. This will also fill compiler.select, klass_info,
        # and annotations.
        results = compiler.execute_sql(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size)
        select, klass_info, annotation_col_map = (compiler.select, compiler.klass_info,
                                                  compiler.annotation_col_map)
        model_cls = klass_info['model']
        select_fields = klass_info['select_fields']
        model_fields_start, model_fields_end = select_fields[0], select_fields[-1] + 1
        init_list = [f[0].target.attname
                     for f in select[model_fields_start:model_fields_end]]
        related_populators = get_related_populators(klass_info, select, db)
        known_related_objects = [
            (field, related_objs, operator.attrgetter(*[
                field.attname
                if from_field == 'self' else
                queryset.model._meta.get_field(from_field).attname
                for from_field in field.from_fields
            ])) for field, related_objs in queryset._known_related_objects.items()
        ]
        for row in compiler.results_iter(results):
            obj = model_cls.from_db(db, init_list, row[model_fields_start:model_fields_end])
            for rel_populator in related_populators:
                rel_populator.populate(row, obj)
            if annotation_col_map:
                for attr_name, col_pos in annotation_col_map.items():
                    setattr(obj, attr_name, row[col_pos])

            # Add the known related objects to the model.
            for field, rel_objs, rel_getter in known_related_objects:
                # Avoid overwriting objects loaded by, e.g., select_related().
                if field.is_cached(obj):
                    continue
                rel_obj_id = rel_getter(obj)
                try:
                    rel_obj = rel_objs[rel_obj_id]
                except KeyError:
                    pass  # May happen in qs1 | qs2 scenarios.
                else:
                    setattr(obj, field.name, rel_obj)

            yield obj


class ValuesIterable(BaseIterable):
    """
    Iterable returned by QuerySet.values() that yields a dict for each row.
    """

    def __iter__(self):
        queryset = self.queryset
        query = queryset.query
        compiler = query.get_compiler(queryset.db)

        # extra(select=...) cols are always at the start of the row.
        names = [
            *query.extra_select,
            *query.values_select,
            *query.annotation_select,
        ]
        indexes = range(len(names))
        for row in compiler.results_iter(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size):
            yield {names[i]: row[i] for i in indexes}


class ValuesListIterable(BaseIterable):
    """
    Iterable returned by QuerySet.values_list(flat=False) that yields a tuple
    for each row.
    """

    def __iter__(self):
        queryset = self.queryset
        query = queryset.query
        compiler = query.get_compiler(queryset.db)

        if queryset._fields:
            # extra(select=...) cols are always at the start of the row.
            names = [
                *query.extra_select,
                *query.values_select,
                *query.annotation_select,
            ]
            fields = [*queryset._fields, *(f for f in query.annotation_select if f not in queryset._fields)]
            if fields != names:
                # Reorder according to fields.
                index_map = {name: idx for idx, name in enumerate(names)}
                rowfactory = operator.itemgetter(*[index_map[f] for f in fields])
                return map(
                    rowfactory,
                    compiler.results_iter(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size)
                )
        return compiler.results_iter(tuple_expected=True, chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size)


class NamedValuesListIterable(ValuesListIterable):
    """
    Iterable returned by QuerySet.values_list(named=True) that yields a
    namedtuple for each row.
    """

    @staticmethod
    @lru_cache()
    def create_namedtuple_class(*names):
        # Cache namedtuple() with @lru_cache() since it's too slow to be
        # called for every QuerySet evaluation.
        return namedtuple('Row', names)

    def __iter__(self):
        queryset = self.queryset
        if queryset._fields:
            names = queryset._fields
        else:
            query = queryset.query
            names = [*query.extra_select, *query.values_select, *query.annotation_select]
        tuple_class = self.create_namedtuple_class(*names)
        new = tuple.__new__
        for row in super().__iter__():
            yield new(tuple_class, row)


class FlatValuesListIterable(BaseIterable):
    """
    Iterable returned by QuerySet.values_list(flat=True) that yields single
    values.
    """

    def __iter__(self):
        queryset = self.queryset
        compiler = queryset.query.get_compiler(queryset.db)
        for row in compiler.results_iter(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size):
            yield row[0]


class QuerySet:
    """Represent a lazy database lookup for a set of objects."""

    def __init__(self, model=None, query=None, using=None, hints=None):
        self.model = model
        self._db = using
        self._hints = hints or {}
        self._query = query or sql.Query(self.model)
        self._result_cache = None
        self._sticky_filter = False
        self._for_write = False
        self._prefetch_related_lookups = ()
        self._prefetch_done = False
        self._known_related_objects = {}  # {rel_field: {pk: rel_obj}}
        self._iterable_class = ModelIterable
        self._fields = None
        self._defer_next_filter = False
        self._deferred_filter = None

    @property
    def query(self):
        if self._deferred_filter:
            negate, args, kwargs = self._deferred_filter
            self._filter_or_exclude_inplace(negate, *args, **kwargs)
            self._deferred_filter = None
        return self._query

    @query.setter
    def query(self, value):
        self._query = value

    def as_manager(cls):
        # Address the circular dependency between `Queryset` and `Manager`.
        from django.db.models.manager import Manager
        manager = Manager.from_queryset(cls)()
        manager._built_with_as_manager = True
        return manager
    as_manager.queryset_only = True
    as_manager = classmethod(as_manager)

    ########################
    # PYTHON MAGIC METHODS #
    ########################

    def __deepcopy__(self, memo):
        """Don't populate the QuerySet's cache."""
        obj = self.__class__()
        for k, v in self.__dict__.items():
            if k == '_result_cache':
                obj.__dict__[k] = None
            else:
                obj.__dict__[k] = copy.deepcopy(v, memo)
        return obj

    def __getstate__(self):
        # Force the cache to be fully populated.
        self._fetch_all()
        return {**self.__dict__, DJANGO_VERSION_PICKLE_KEY: get_version()}

    def __setstate__(self, state):
        msg = None
        pickled_version = state.get(DJANGO_VERSION_PICKLE_KEY)
        if pickled_version:
            current_version = get_version()
            if current_version != pickled_version:
                msg = (
                    "Pickled queryset instance's Django version %s does not "
                    "match the current version %s." % (pickled_version, current_version)
                )
        else:
            msg = "Pickled queryset instance's Django version is not specified."

        if msg:
            warnings.warn(msg, RuntimeWarning, stacklevel=2)

        self.__dict__.update(state)

    def __repr__(self):
        data = list(self[:REPR_OUTPUT_SIZE + 1])
        if len(data) > REPR_OUTPUT_SIZE:
            data[-1] = "...(remaining elements truncated)..."
        return '<%s %r>' % (self.__class__.__name__, data)

    def __len__(self):
        self._fetch_all()
        return len(self._result_cache)

    def __iter__(self):
        """
        The queryset iterator protocol uses three nested iterators in the
        default case:
            1. sql.compiler.execute_sql()
               - Returns 100 rows at time (constants.GET_ITERATOR_CHUNK_SIZE)
                 using cursor.fetchmany(). This part is responsible for
                 doing some column masking, and returning the rows in chunks.
            2. sql.compiler.results_iter()
               - Returns one row at time. At this point the rows are still just
                 tuples. In some cases the return values are converted to
                 Python values at this location.
            3. self.iterator()
               - Responsible for turning the rows into model objects.
        """
        self._fetch_all()
        return iter(self._result_cache)

    def __bool__(self):
        self._fetch_all()
        return bool(self._result_cache)

    def __getitem__(self, k):
        """Retrieve an item or slice from the set of results."""
        if not isinstance(k, (int, slice)):
            raise TypeError(
                'QuerySet indices must be integers or slices, not %s.'
                % type(k).__name__
            )
        assert ((not isinstance(k, slice) and (k >= 0)) or
                (isinstance(k, slice) and (k.start is None or k.start >= 0) and
                 (k.stop is None or k.stop >= 0))), \
            "Negative indexing is not supported."

        if self._result_cache is not None:
            return self._result_cache[k]

        if isinstance(k, slice):
            qs = self._chain()
            if k.start is not None:
                start = int(k.start)
            else:
                start = None
            if k.stop is not None:
                stop = int(k.stop)
            else:
                stop = None
            qs.query.set_limits(start, stop)
            return list(qs)[::k.step] if k.step else qs

        qs = self._chain()
        qs.query.set_limits(k, k + 1)
        qs._fetch_all()
        return qs._result_cache[0]

    def __class_getitem__(cls, *args, **kwargs):
        return cls

    def __and__(self, other):
        self._merge_sanity_check(other)
        if isinstance(other, EmptyQuerySet):
            return other
        if isinstance(self, EmptyQuerySet):
            return self
        combined = self._chain()
        combined._merge_known_related_objects(other)
        combined.query.combine(other.query, sql.AND)
        return combined

    def __or__(self, other):
        self._merge_sanity_check(other)
        if isinstance(self, EmptyQuerySet):
            return other
        if isinstance(other, EmptyQuerySet):
            return self
        query = self if self.query.can_filter() else self.model._base_manager.filter(pk__in=self.values('pk'))
        combined = query._chain()
        combined._merge_known_related_objects(other)
        if not other.query.can_filter():
            other = other.model._base_manager.filter(pk__in=other.values('pk'))
        combined.query.combine(other.query, sql.OR)
        return combined

    ####################################
    # METHODS THAT DO DATABASE QUERIES #
    ####################################

    def _iterator(self, use_chunked_fetch, chunk_size):
        yield from self._iterable_class(self, chunked_fetch=use_chunked_fetch, chunk_size=chunk_size)

    def iterator(self, chunk_size=2000):
        """
        An iterator over the results from applying this QuerySet to the
        database.
        """
        if chunk_size <= 0:
            raise ValueError('Chunk size must be strictly positive.')
        use_chunked_fetch = not connections[self.db].settings_dict.get('DISABLE_SERVER_SIDE_CURSORS')
        return self._iterator(use_chunked_fetch, chunk_size)

    def aggregate(self, *args, **kwargs):
        """
        Return a dictionary containing the calculations (aggregation)
        over the current queryset.

        If args is present the expression is passed as a kwarg using
        the Aggregate object's default alias.
        """
        if self.query.distinct_fields:
            raise NotImplementedError("aggregate() + distinct(fields) not implemented.")
        self._validate_values_are_expressions((*args, *kwargs.values()), method_name='aggregate')
        for arg in args:
            # The default_alias property raises TypeError if default_alias
            # can't be set automatically or AttributeError if it isn't an
            # attribute.
            try:
                arg.default_alias
            except (AttributeError, TypeError):
                raise TypeError("Complex aggregates require an alias")
            kwargs[arg.default_alias] = arg

        query = self.query.chain()
        for (alias, aggregate_expr) in kwargs.items():
            query.add_annotation(aggregate_expr, alias, is_summary=True)
            if not query.annotations[alias].contains_aggregate:
                raise TypeError("%s is not an aggregate expression" % alias)
        return query.get_aggregation(self.db, kwargs)

    def count(self):
        """
        Perform a SELECT COUNT() and return the number of records as an
        integer.

        If the QuerySet is already fully cached, return the length of the
        cached results set to avoid multiple SELECT COUNT(*) calls.
        """
        if self._result_cache is not None:
            return len(self._result_cache)

        return self.query.get_count(using=self.db)

    def get(self, *args, **kwargs):
        """
        Perform the query and return a single object matching the given
        keyword arguments.
        """
        clone = self._chain() if self.query.combinator else self.filter(*args, **kwargs)
        if self.query.can_filter() and not self.query.distinct_fields:
            clone = clone.order_by()
        limit = None
        if not clone.query.select_for_update or connections[clone.db].features.supports_select_for_update_with_limit:
            limit = MAX_GET_RESULTS
            clone.query.set_limits(high=limit)
        num = len(clone)
        if num == 1:
            return clone._result_cache[0]
        if not num:
            raise self.model.DoesNotExist(
                "%s matching query does not exist." %
                self.model._meta.object_name
            )
        raise self.model.MultipleObjectsReturned(
            'get() returned more than one %s -- it returned %s!' % (
                self.model._meta.object_name,
                num if not limit or num < limit else 'more than %s' % (limit - 1),
            )
        )

    def create(self, **kwargs):
        """
        Create a new object with the given kwargs, saving it to the database
        and returning the created object.
        """
        obj = self.model(**kwargs)
        self._for_write = True
        obj.save(force_insert=True, using=self.db)
        return obj

    def _populate_pk_values(self, objs):
        for obj in objs:
            if obj.pk is None:
                obj.pk = obj._meta.pk.get_pk_value_on_save(obj)

    def bulk_create(self, objs, batch_size=None, ignore_conflicts=False):
        """
        Insert each of the instances into the database. Do *not* call
        save() on each of the instances, do not send any pre/post_save
        signals, and do not set the primary key attribute if it is an
        autoincrement field (except if features.can_return_rows_from_bulk_insert=True).
        Multi-table models are not supported.
        """
        # When you bulk insert you don't get the primary keys back (if it's an
        # autoincrement, except if can_return_rows_from_bulk_insert=True), so
        # you can't insert into the child tables which references this. There
        # are two workarounds:
        # 1) This could be implemented if you didn't have an autoincrement pk
        # 2) You could do it by doing O(n) normal inserts into the parent
        #    tables to get the primary keys back and then doing a single bulk
        #    insert into the childmost table.
        # We currently set the primary keys on the objects when using
        # PostgreSQL via the RETURNING ID clause. It should be possible for
        # Oracle as well, but the semantics for extracting the primary keys is
        # trickier so it's not done yet.
        assert batch_size is None or batch_size > 0
        # Check that the parents share the same concrete model with the our
        # model to detect the inheritance pattern ConcreteGrandParent ->
        # MultiTableParent -> ProxyChild. Simply checking self.model._meta.proxy
        # would not identify that case as involving multiple tables.
        for parent in self.model._meta.get_parent_list():
            if parent._meta.concrete_model is not self.model._meta.concrete_model:
                raise ValueError("Can't bulk create a multi-table inherited model")
        if not objs:
            return objs
        self._for_write = True
        connection = connections[self.db]
        opts = self.model._meta
        fields = opts.concrete_fields
        objs = list(objs)
        self._populate_pk_values(objs)
        with transaction.atomic(using=self.db, savepoint=False):
            objs_with_pk, objs_without_pk = partition(lambda o: o.pk is None, objs)
            if objs_with_pk:
                returned_columns = self._batched_insert(
                    objs_with_pk, fields, batch_size, ignore_conflicts=ignore_conflicts,
                )
                for obj_with_pk, results in zip(objs_with_pk, returned_columns):
                    for result, field in zip(results, opts.db_returning_fields):
                        if field != opts.pk:
                            setattr(obj_with_pk, field.attname, result)
                for obj_with_pk in objs_with_pk:
                    obj_with_pk._state.adding = False
                    obj_with_pk._state.db = self.db
            if objs_without_pk:
                fields = [f for f in fields if not isinstance(f, AutoField)]
                returned_columns = self._batched_insert(
                    objs_without_pk, fields, batch_size, ignore_conflicts=ignore_conflicts,
                )
                if connection.features.can_return_rows_from_bulk_insert and not ignore_conflicts:
                    assert len(returned_columns) == len(objs_without_pk)
                for obj_without_pk, results in zip(objs_without_pk, returned_columns):
                    for result, field in zip(results, opts.db_returning_fields):
                        setattr(obj_without_pk, field.attname, result)
                    obj_without_pk._state.adding = False
                    obj_without_pk._state.db = self.db

        return objs

    def bulk_update(self, objs, fields, batch_size=None):
        """
        Update the given fields in each of the given objects in the database.
        """
        if batch_size is not None and batch_size < 0:
            raise ValueError('Batch size must be a positive integer.')
        if not fields:
            raise ValueError('Field names must be given to bulk_update().')
        objs = tuple(objs)
        if any(obj.pk is None for obj in objs):
            raise ValueError('All bulk_update() objects must have a primary key set.')
        fields = [self.model._meta.get_field(name) for name in fields]
        if any(not f.concrete or f.many_to_many for f in fields):
            raise ValueError('bulk_update() can only be used with concrete fields.')
        if any(f.primary_key for f in fields):
            raise ValueError('bulk_update() cannot be used with primary key fields.')
        if not objs:
            return
        # PK is used twice in the resulting update query, once in the filter
        # and once in the WHEN. Each field will also have one CAST.
        max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
        batch_size = min(batch_size, max_batch_size) if batch_size else max_batch_size
        requires_casting = connections[self.db].features.requires_casted_case_in_updates
        batches = (objs[i:i + batch_size] for i in range(0, len(objs), batch_size))
        updates = []
        for batch_objs in batches:
            update_kwargs = {}
            for field in fields:
                when_statements = []
                for obj in batch_objs:
                    attr = getattr(obj, field.attname)
                    if not isinstance(attr, Expression):
                        attr = Value(attr, output_field=field)
                    when_statements.append(When(pk=obj.pk, then=attr))
                case_statement = Case(*when_statements, output_field=field)
                if requires_casting:
                    case_statement = Cast(case_statement, output_field=field)
                update_kwargs[field.attname] = case_statement
            updates.append(([obj.pk for obj in batch_objs], update_kwargs))
        with transaction.atomic(using=self.db, savepoint=False):
            for pks, update_kwargs in updates:
                self.filter(pk__in=pks).update(**update_kwargs)
    bulk_update.alters_data = True

    def get_or_create(self, defaults=None, **kwargs):
        """
        Look up an object with the given kwargs, creating one if necessary.
        Return a tuple of (object, created), where created is a boolean
        specifying whether an object was created.
        """
        # The get() needs to be targeted at the write database in order
        # to avoid potential transaction consistency problems.
        self._for_write = True
        try:
            return self.get(**kwargs), False
        except self.model.DoesNotExist:
            params = self._extract_model_params(defaults, **kwargs)
            return self._create_object_from_params(kwargs, params)

    def update_or_create(self, defaults=None, **kwargs):
        """
        Look up an object with the given kwargs, updating one with defaults
        if it exists, otherwise create a new one.
        Return a tuple (object, created), where created is a boolean
        specifying whether an object was created.
        """
        defaults = defaults or {}
        self._for_write = True
        with transaction.atomic(using=self.db):
            try:
                obj = self.select_for_update().get(**kwargs)
            except self.model.DoesNotExist:
                params = self._extract_model_params(defaults, **kwargs)
                # Lock the row so that a concurrent update is blocked until
                # after update_or_create() has performed its save.
                obj, created = self._create_object_from_params(kwargs, params, lock=True)
                if created:
                    return obj, created
            for k, v in resolve_callables(defaults):
                setattr(obj, k, v)
            obj.save(using=self.db)
        return obj, False

    def _create_object_from_params(self, lookup, params, lock=False):
        """
        Try to create an object using passed params. Used by get_or_create()
        and update_or_create().
        """
        try:
            with transaction.atomic(using=self.db):
                params = dict(resolve_callables(params))
                obj = self.create(**params)
            return obj, True
        except IntegrityError:
            try:
                qs = self.select_for_update() if lock else self
                return qs.get(**lookup), False
            except self.model.DoesNotExist:
                pass
            raise

    def _extract_model_params(self, defaults, **kwargs):
        """
        Prepare `params` for creating a model instance based on the given
        kwargs; for use by get_or_create() and update_or_create().
        """
        defaults = defaults or {}
        params = {k: v for k, v in kwargs.items() if LOOKUP_SEP not in k}
        params.update(defaults)
        property_names = self.model._meta._property_names
        invalid_params = []
        for param in params:
            try:
                self.model._meta.get_field(param)
            except exceptions.FieldDoesNotExist:
                # It's okay to use a model's property if it has a setter.
                if not (param in property_names and getattr(self.model, param).fset):
                    invalid_params.append(param)
        if invalid_params:
            raise exceptions.FieldError(
                "Invalid field name(s) for model %s: '%s'." % (
                    self.model._meta.object_name,
                    "', '".join(sorted(invalid_params)),
                ))
        return params

    def _earliest(self, *fields):
        """
        Return the earliest object according to fields (if given) or by the
        model's Meta.get_latest_by.
        """
        if fields:
            order_by = fields
        else:
            order_by = getattr(self.model._meta, 'get_latest_by')
            if order_by and not isinstance(order_by, (tuple, list)):
                order_by = (order_by,)
        if order_by is None:
            raise ValueError(
                "earliest() and latest() require either fields as positional "
                "arguments or 'get_latest_by' in the model's Meta."
            )

        assert not self.query.is_sliced, \
            "Cannot change a query once a slice has been taken."
        obj = self._chain()
        obj.query.set_limits(high=1)
        obj.query.clear_ordering(force_empty=True)
        obj.query.add_ordering(*order_by)
        return obj.get()

    def earliest(self, *fields):
        return self._earliest(*fields)

    def latest(self, *fields):
        return self.reverse()._earliest(*fields)

    def first(self):
        """Return the first object of a query or None if no match is found."""
        for obj in (self if self.ordered else self.order_by('pk'))[:1]:
            return obj

    def last(self):
        """Return the last object of a query or None if no match is found."""
        for obj in (self.reverse() if self.ordered else self.order_by('-pk'))[:1]:
            return obj

    def in_bulk(self, id_list=None, *, field_name='pk'):
        """
        Return a dictionary mapping each of the given IDs to the object with
        that ID. If `id_list` isn't provided, evaluate the entire QuerySet.
        """
        assert not self.query.is_sliced, \
            "Cannot use 'limit' or 'offset' with in_bulk"
        if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
            field_names = [
                field_name
                for constraint in self.model._meta.total_unique_constraints
                if len(constraint.fields) == 1
                for field_name in constraint.fields
            ]
            if field_name not in field_names:
                raise ValueError(
                    "in_bulk()'s field_name must be a unique field but %r "
                    "isn't." % field_name
                )
        if id_list is not None:
            if not id_list:
                return {}
            filter_key = '{}__in'.format(field_name)
            batch_size = connections[self.db].features.max_query_params
            id_list = tuple(id_list)
            # If the database has a limit on the number of query parameters
            # (e.g. SQLite), retrieve objects in batches if necessary.
            if batch_size and batch_size < len(id_list):
                qs = ()
                for offset in range(0, len(id_list), batch_size):
                    batch = id_list[offset:offset + batch_size]
                    qs += tuple(self.filter(**{filter_key: batch}).order_by())
            else:
                qs = self.filter(**{filter_key: id_list}).order_by()
        else:
            qs = self._chain()
        return {getattr(obj, field_name): obj for obj in qs}

    def delete(self):
        """Delete the records in the current QuerySet."""
        self._not_support_combined_queries('delete')
        assert not self.query.is_sliced, \
            "Cannot use 'limit' or 'offset' with delete."

        if self._fields is not None:
            raise TypeError("Cannot call delete() after .values() or .values_list()")

        del_query = self._chain()

        # The delete is actually 2 queries - one to find related objects,
        # and one to delete. Make sure that the discovery of related
        # objects is performed on the same database as the deletion.
        del_query._for_write = True

        # Disable non-supported fields.
        del_query.query.select_for_update = False
        del_query.query.select_related = False
        del_query.query.clear_ordering(force_empty=True)

        collector = Collector(using=del_query.db)
        collector.collect(del_query)
        deleted, _rows_count = collector.delete()

        # Clear the result cache, in case this QuerySet gets reused.
        self._result_cache = None
        return deleted, _rows_count

    delete.alters_data = True
    delete.queryset_only = True

    def _raw_delete(self, using):
        """
        Delete objects found from the given queryset in single direct SQL
        query. No signals are sent and there is no protection for cascades.
        """
        query = self.query.clone()
        query.__class__ = sql.DeleteQuery
        cursor = query.get_compiler(using).execute_sql(CURSOR)
        if cursor:
            with cursor:
                return cursor.rowcount
        return 0
    _raw_delete.alters_data = True

    def update(self, **kwargs):
        """
        Update all elements in the current QuerySet, setting all the given
        fields to the appropriate values.
        """
        self._not_support_combined_queries('update')
        assert not self.query.is_sliced, \
            "Cannot update a query once a slice has been taken."
        self._for_write = True
        query = self.query.chain(sql.UpdateQuery)
        query.add_update_values(kwargs)
        # Clear any annotations so that they won't be present in subqueries.
        query.annotations = {}
        with transaction.mark_for_rollback_on_error(using=self.db):
            rows = query.get_compiler(self.db).execute_sql(CURSOR)
        self._result_cache = None
        return rows
    update.alters_data = True

    def _update(self, values):
        """
        A version of update() that accepts field objects instead of field names.
        Used primarily for model saving and not intended for use by general
        code (it requires too much poking around at model internals to be
        useful at that level).
        """
        assert not self.query.is_sliced, \
            "Cannot update a query once a slice has been taken."
        query = self.query.chain(sql.UpdateQuery)
        query.add_update_fields(values)
        # Clear any annotations so that they won't be present in subqueries.
        query.annotations = {}
        self._result_cache = None
        return query.get_compiler(self.db).execute_sql(CURSOR)
    _update.alters_data = True
    _update.queryset_only = False

    def exists(self):
        if self._result_cache is None:
            return self.query.has_results(using=self.db)
        return bool(self._result_cache)

    def _prefetch_related_objects(self):
        # This method can only be called once the result cache has been filled.
        prefetch_related_objects(self._result_cache, *self._prefetch_related_lookups)
        self._prefetch_done = True

    def explain(self, *, format=None, **options):
        return self.query.explain(using=self.db, format=format, **options)

    ##################################################
    # PUBLIC METHODS THAT RETURN A QUERYSET SUBCLASS #
    ##################################################

    def raw(self, raw_query, params=None, translations=None, using=None):
        if using is None:
            using = self.db
        qs = RawQuerySet(raw_query, model=self.model, params=params, translations=translations, using=using)
        qs._prefetch_related_lookups = self._prefetch_related_lookups[:]
        return qs

    def _values(self, *fields, **expressions):
        clone = self._chain()
        if expressions:
            clone = clone.annotate(**expressions)
        clone._fields = fields
        clone.query.set_values(fields)
        return clone

    def values(self, *fields, **expressions):
        fields += tuple(expressions)
        clone = self._values(*fields, **expressions)
        clone._iterable_class = ValuesIterable
        return clone

    def values_list(self, *fields, flat=False, named=False):
        if flat and named:
            raise TypeError("'flat' and 'named' can't be used together.")
        if flat and len(fields) > 1:
            raise TypeError("'flat' is not valid when values_list is called with more than one field.")

        field_names = {f for f in fields if not hasattr(f, 'resolve_expression')}
        _fields = []
        expressions = {}
        counter = 1
        for field in fields:
            if hasattr(field, 'resolve_expression'):
                field_id_prefix = getattr(field, 'default_alias', field.__class__.__name__.lower())
                while True:
                    field_id = field_id_prefix + str(counter)
                    counter += 1
                    if field_id not in field_names:
                        break
                expressions[field_id] = field
                _fields.append(field_id)
            else:
                _fields.append(field)

        clone = self._values(*_fields, **expressions)
        clone._iterable_class = (
            NamedValuesListIterable if named
            else FlatValuesListIterable if flat
            else ValuesListIterable
        )
        return clone

    def dates(self, field_name, kind, order='ASC'):
        """
        Return a list of date objects representing all available dates for
        the given field_name, scoped to 'kind'.
        """
        assert kind in ('year', 'month', 'week', 'day'), \
            "'kind' must be one of 'year', 'month', 'week', or 'day'."
        assert order in ('ASC', 'DESC'), \
            "'order' must be either 'ASC' or 'DESC'."
        return self.annotate(
            datefield=Trunc(field_name, kind, output_field=DateField()),
            plain_field=F(field_name)
        ).values_list(
            'datefield', flat=True
        ).distinct().filter(plain_field__isnull=False).order_by(('-' if order == 'DESC' else '') + 'datefield')

    def datetimes(self, field_name, kind, order='ASC', tzinfo=None, is_dst=None):
        """
        Return a list of datetime objects representing all available
        datetimes for the given field_name, scoped to 'kind'.
        """
        assert kind in ('year', 'month', 'week', 'day', 'hour', 'minute', 'second'), \
            "'kind' must be one of 'year', 'month', 'week', 'day', 'hour', 'minute', or 'second'."
        assert order in ('ASC', 'DESC'), \
            "'order' must be either 'ASC' or 'DESC'."
        if settings.USE_TZ:
            if tzinfo is None:
                tzinfo = timezone.get_current_timezone()
        else:
            tzinfo = None
        return self.annotate(
            datetimefield=Trunc(
                field_name,
                kind,
                output_field=DateTimeField(),
                tzinfo=tzinfo,
                is_dst=is_dst,
            ),
            plain_field=F(field_name)
        ).values_list(
            'datetimefield', flat=True
        ).distinct().filter(plain_field__isnull=False).order_by(('-' if order == 'DESC' else '') + 'datetimefield')

    def none(self):
        """Return an empty QuerySet."""
        clone = self._chain()
        clone.query.set_empty()
        return clone

    ##################################################################
    # PUBLIC METHODS THAT ALTER ATTRIBUTES AND RETURN A NEW QUERYSET #
    ##################################################################

    def all(self):
        """
        Return a new QuerySet that is a copy of the current one. This allows a
        QuerySet to proxy for a model manager in some cases.
        """
        return self._chain()

    def filter(self, *args, **kwargs):
        """
        Return a new QuerySet instance with the args ANDed to the existing
        set.
        """
        self._not_support_combined_queries('filter')
        return self._filter_or_exclude(False, *args, **kwargs)

    def exclude(self, *args, **kwargs):
        """
        Return a new QuerySet instance with NOT (args) ANDed to the existing
        set.
        """
        self._not_support_combined_queries('exclude')
        return self._filter_or_exclude(True, *args, **kwargs)

    def _filter_or_exclude(self, negate, *args, **kwargs):
        if args or kwargs:
            assert not self.query.is_sliced, \
                "Cannot filter a query once a slice has been taken."

        clone = self._chain()
        if self._defer_next_filter:
            self._defer_next_filter = False
            clone._deferred_filter = negate, args, kwargs
        else:
            clone._filter_or_exclude_inplace(negate, *args, **kwargs)
        return clone

    def _filter_or_exclude_inplace(self, negate, *args, **kwargs):
        if negate:
            self._query.add_q(~Q(*args, **kwargs))
        else:
            self._query.add_q(Q(*args, **kwargs))

    def complex_filter(self, filter_obj):
        """
        Return a new QuerySet instance with filter_obj added to the filters.

        filter_obj can be a Q object or a dictionary of keyword lookup
        arguments.

        This exists to support framework features such as 'limit_choices_to',
        and usually it will be more natural to use other methods.
        """
        if isinstance(filter_obj, Q):
            clone = self._chain()
            clone.query.add_q(filter_obj)
            return clone
        else:
            return self._filter_or_exclude(False, **filter_obj)

    def _combinator_query(sel
```


# tests/queries (the files in it)

tests/queries/__init__.py
tests/queries/models.py
tests/queries/test_bulk_update.py
tests/queries/test_db_returning.py
tests/queries/test_deprecation.py
tests/queries/test_explain.py
tests/queries/test_iterator.py
tests/queries/test_q.py
tests/queries/test_qs_combinators.py
tests/queries/test_query.py
tests/queries/tests.py


# tests/model_options (the files in it)

tests/model_options/__init__.py
tests/model_options/models/__init__.py
tests/model_options/models/default_related_name.py
tests/model_options/models/tablespaces.py
tests/model_options/test_default_related_name.py
tests/model_options/test_tablespaces.py


# The last commit

```
fa3a0522ec SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: ./tests/runtests.py queries.tests model_options.tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..s...............s............x...................................x................................................s........................................................................E..............................................................................................
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.537s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: django/db/models/options.py django/db/models/query.py tests/queries tests/model_options
changed: django/db/models/query.py +11 -1
OUTSIDE THE SCOPE: tests/lookup/models.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/lookup/tests.py +11 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/db/models/query.py b/django/db/models/query.py
index d9c9b0db04..933ab613f4 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -690,7 +690,17 @@ class QuerySet:
         assert not self.query.is_sliced, \
             "Cannot use 'limit' or 'offset' with in_bulk"
         if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
-            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
+            field_names = [
+                field_name
+                for constraint in self.model._meta.total_unique_constraints
+                if len(constraint.fields) == 1
+                for field_name in constraint.fields
+            ]
+            if field_name not in field_names:
+                raise ValueError(
+                    "in_bulk()'s field_name must be a unique field but %r "
+                    "isn't." % field_name
+                )
         if id_list is not None:
             if not id_list:
                 return {}
diff --git a/tests/lookup/models.py b/tests/lookup/models.py
index fbc9fa606f..b87b30b376 100644
--- a/tests/lookup/models.py
+++ b/tests/lookup/models.py
@@ -37,6 +37,18 @@ class Article(models.Model):
         return self.headline
 
 
+class UniqueConstraintArticle(models.Model):
+    slug = models.SlugField()
+
+    class Meta:
+        constraints = [
+            models.UniqueConstraint(
+                fields=['slug'],
+                name='lookup_unique_constraint_article_slug',
+            ),
+        ]
+
+
 class Tag(models.Model):
     articles = models.ManyToManyField(Article)
     name = models.CharField(max_length=100)
diff --git a/tests/lookup/tests.py b/tests/lookup/tests.py
index baefdf9701..e7930bf115 100644
--- a/tests/lookup/tests.py
+++ b/tests/lookup/tests.py
@@ -12,6 +12,7 @@ from django.utils.deprecation import RemovedInDjango40Warning
 
 from .models import (
     Article, Author, Freebie, Game, IsNullWithNoneAsRHS, Player, Season, Tag,
+    UniqueConstraintArticle,
 )
 
 
@@ -194,6 +195,16 @@ class LookupTests(TestCase):
         with self.assertRaisesMessage(ValueError, msg):
             Article.objects.in_bulk([self.au1], field_name='author')
 
+    def test_in_bulk_unique_constraint_field(self):
+        obj1 = UniqueConstraintArticle.objects.create(slug='a')
+        obj2 = UniqueConstraintArticle.objects.create(slug='b')
+        self.assertEqual(
+            UniqueConstraintArticle.objects.in_bulk(
+                [obj1.slug, obj2.slug], field_name='slug',
+            ),
+            {obj1.slug: obj1, obj2.slug: obj2},
+        )
+
     def test_values(self):
         # values() returns a list of dictionaries instead of object instances --
         # and you can specify which fields you want to retrieve.
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
check: ./tests/runtests.py queries.tests model_options.tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..............s.......sx........x..........................................................................................s....................................E...........................................................................................................................
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.532s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: django/db/models/options.py django/db/models/query.py tests/queries tests/model_options
changed: django/db/models/query.py +11 -1
OUTSIDE THE SCOPE: tests/lookup/models.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/lookup/tests.py +11 -0 (undo it: git checkout the file, or delete it when the run made it)
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
put back: the direct attempt, which passed test-0 (the repair after the review is in .memdoor/runs/team-solve-2026-11-06T105729/repair.patch, not applied: check 0, judge PASS)
```

### `notes.md`

```
# Notes, run 2026-11-06T105729

## Solver decision

## Review

## Repair

- Repair: extended `Options.total_unique_constraints` to also exclude
  expression-based constraints; kept single-field filtering in `in_bulk()`;
  reverted out-of-scope `tests/lookup/` edits; added regression tests under
  `tests/model_options/` (models/constraints.py + tests.py), which also
  provides the `model_options.tests` module the Check names.
- Check `./tests/runtests.py queries.tests model_options.tests`: Ran 287 tests,
  OK (skipped=3, expected failures=2).
```

### `outline.md`

````
# The prompt

Allow QuerySet.in_bulk() for fields with total UniqueConstraints.
Description
	
If a field is unique by UniqueConstraint instead of unique=True running in_bulk() on that field will fail.
Consider:
class Article(models.Model):
	slug = models.CharField(max_length=255)
	
	class Meta:
		constraints = [
			models.UniqueConstraint(fields=["slug"], name="%(app_label)s_%(class)s_slug_unq")
		]
>>> Article.objects.in_bulk(field_name="slug")
Traceback (most recent call last):
 File "/usr/local/lib/python3.8/code.py", line 90, in runcode
	exec(code, self.locals)
 File "<console>", line 1, in <module>
 File "/app/venv/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/app/venv/lib/python3.8/site-packages/django/db/models/query.py", line 680, in in_bulk
	raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
ValueError: in_bulk()'s field_name must be a unique field but 'slug' isn't.
It should be pretty simple to fix this and I have a patch if accepted.


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.github/FUNDING.yml
.gitignore
.hgignore
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
django/bin/django-admin.py
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
django/conf/locale/th/LC_MESSAGES/django.mo
django/conf/locale/th/LC_MESSAGES/django.po
django/conf/locale/th/__init__.py
django/conf/locale/th/formats.py
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
django/contrib/admin/bin/compress.py
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
django/contrib/admin/locale/ka/LC_MESSAGES/django.po
django/contrib/admin/locale/ka/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ka/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/kab/LC_MESSAGES/django.mo
django/contrib/admin/locale/kab/LC_MESSAGES/django.po
django/contrib/admin/locale/kab/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kab/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/kk/LC_MESSAGES/django.mo
django/contrib/admin/locale/kk/LC_MESSAGES/django.po
django/contrib/admin/locale/kk/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kk/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/km/LC_MESSAGES/django.mo
django/contrib/admin/locale/km/LC_MESSAGES/django.po
django/contrib/admin/locale/km/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/km/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/kn/LC_MESSAGES/django.mo
django/contrib/admin/locale/kn/LC_MESSAGES/django.po
django/contrib/admin/locale/kn/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kn/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ko/LC_MESSAGES/django.mo
django/contrib/admin/locale/ko/LC_MESSAGES/django.po
django/contrib/admin/locale/ko/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ko/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lb/LC_MESSAGES/django.mo
django/contrib/admin/locale/lb/LC_MESSAGES/django.po
django/contrib/admin/locale/lb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lt/LC_MESSAGES/django.mo
django/contrib/admin/locale/lt/LC_MESSAGES/django.po
django/contrib/admin/locale/lt/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lt/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lv/LC_MESSAGES/django.mo
django/contrib/admin/locale/lv/LC_MESSAGES/django.po
django/contrib/admin/locale/lv/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lv/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/mk/LC_MESSAGES/django.mo
django/contrib/admin/locale/mk/LC_MESSAGES/django.po
```


# The last commit

```
fa3a0522ec SWE-bench


```

```diff

```


# package.json (the start)

```
{
  "name": "Django",
  "private": true,
  "scripts": {
    "pretest": "eslint django/ js_tests/admin/ js_tests/gis/",
    "test": "grunt test --verbose"
  },
  "engines": {
    "npm": ">=1.3.0 <3.0.0"
  },
  "devDependencies": {
    "eslint": "^6.8.0",
    "grunt": "^1.0.1",
    "grunt-cli": "^1.2.0",
    "grunt-contrib-qunit": "^3.1.0",
    "qunit": "^2.9.3"
  }
}

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`./tests/runtests.py queries.tests model_options.tests`

## Scope
`django/db/models/options.py`
`django/db/models/query.py`
`tests/queries/`
`tests/model_options/`

## Done when
- `QuerySet.in_bulk(field_name="slug")` succeeds when `slug` is covered by a total single-field `UniqueConstraint`.
- `in_bulk()` still raises `ValueError` for a field that is not unique by `unique=True` or a total single-field `UniqueConstraint`.
- Conditional, expression-based, and multi-field `UniqueConstraint`s are not treated as making an individual field total-unique.
- `Options.total_unique_constraints` exposes the model’s total `UniqueConstraint`s. `(inferred)`

## Approach
Add a cached `Options.total_unique_constraints` property that filters `Meta.constraints` to `UniqueConstraint` objects without a `condition` and without expressions. In `QuerySet.in_bulk()`, collect the field names from those constraints where `len(constraint.fields) == 1`, then allow `field_name` when it is `pk`, has `field.unique`, or appears in that collected set. Keep the existing `ValueError` for everything else.

Candidate approaches:
- Preferred: reusable `Options.total_unique_constraints` plus a small check in `in_bulk()`; matches Django’s metadata layer and supports future callers.
- Inline scan of `self.model._meta.constraints` inside `in_bulk()` only; fewer files, but duplicates constraint-filtering logic.
- Use only `field.unique` plus raw `constraint.fields` matching; simpler, but risks treating partial or expression constraints as total unique.

If the first attempt fails, inspect whether `UniqueConstraint` exposes `condition`/`contains_expressions` as expected, and verify the test models actually attach the constraint to the field being passed to `in_bulk()`.
```

### `prompt.md`

```
Allow QuerySet.in_bulk() for fields with total UniqueConstraints.
Description
	
If a field is unique by UniqueConstraint instead of unique=True running in_bulk() on that field will fail.
Consider:
class Article(models.Model):
	slug = models.CharField(max_length=255)
	
	class Meta:
		constraints = [
			models.UniqueConstraint(fields=["slug"], name="%(app_label)s_%(class)s_slug_unq")
		]
>>> Article.objects.in_bulk(field_name="slug")
Traceback (most recent call last):
 File "/usr/local/lib/python3.8/code.py", line 90, in runcode
	exec(code, self.locals)
 File "<console>", line 1, in <module>
 File "/app/venv/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/app/venv/lib/python3.8/site-packages/django/db/models/query.py", line 680, in in_bulk
	raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
ValueError: in_bulk()'s field_name must be a unique field but 'slug' isn't.
It should be pretty simple to fix this and I have a patch if accepted.
```

### `repair.md`

````
# Repair

## Changes

1. `django/db/models/options.py` — `Options.total_unique_constraints` already
   existed in this tree; extended its filter so it excludes expression-based
   constraints as well as conditional ones:
   `isinstance(constraint, UniqueConstraint) and constraint.condition is None
   and not getattr(constraint, 'contains_expressions', False)`.
   (`contains_expressions` is guarded with `getattr` for this Django 3.1 tree,
   where `UniqueConstraint(fields=...)` is the only supported form.)
2. `django/db/models/query.py` — kept `in_bulk()`'s check: a field is accepted
   when it is `pk`, `field.unique`, or the sole field of a total
   `UniqueConstraint` (`len(constraint.fields) == 1`), so multi-field
   constraints never make an individual field unique.
3. Removed the out-of-scope `tests/lookup/models.py` and `tests/lookup/tests.py`
   changes (restored to HEAD), as the review named them.
4. Added scoped regression tests in `tests/model_options/`:
   `tests/model_options/models/constraints.py` (total single-field,
   conditional, and multi-field `UniqueConstraint` models) and
   `tests/model_options/tests.py` (in_bulk success/ValueError cases and
   `Options.total_unique_constraints`).

## Check

`./tests/runtests.py queries.tests model_options.tests`

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
...
Ran 287 tests in 0.565s

OK (skipped=3, expected failures=2)
```

(The earlier `ModuleNotFoundError: No module named 'model_options.tests'`
is gone now that the scoped `tests/model_options/tests.py` exists.)
````

### `repair.patch`

```diff
diff --git a/django/db/models/options.py b/django/db/models/options.py
index 0e28b6812a..80f8c78254 100644
--- a/django/db/models/options.py
+++ b/django/db/models/options.py
@@ -837,7 +837,11 @@ class Options:
         return [
             constraint
             for constraint in self.constraints
-            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
+            if (
+                isinstance(constraint, UniqueConstraint) and
+                constraint.condition is None and
+                not getattr(constraint, 'contains_expressions', False)
+            )
         ]
 
     @cached_property
diff --git a/django/db/models/query.py b/django/db/models/query.py
index d9c9b0db04..933ab613f4 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -690,7 +690,17 @@ class QuerySet:
         assert not self.query.is_sliced, \
             "Cannot use 'limit' or 'offset' with in_bulk"
         if field_name != 'pk' and not self.model._meta.get_field(field_name).unique:
-            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
+            field_names = [
+                field_name
+                for constraint in self.model._meta.total_unique_constraints
+                if len(constraint.fields) == 1
+                for field_name in constraint.fields
+            ]
+            if field_name not in field_names:
+                raise ValueError(
+                    "in_bulk()'s field_name must be a unique field but %r "
+                    "isn't." % field_name
+                )
         if id_list is not None:
             if not id_list:
                 return {}
diff --git a/tests/model_options/models/constraints.py b/tests/model_options/models/constraints.py
new file mode 100644
index 0000000000..a5e2a4f2ef
--- /dev/null
+++ b/tests/model_options/models/constraints.py
@@ -0,0 +1,39 @@
+from django.db import models
+
+
+class UniqueConstraintArticle(models.Model):
+    slug = models.SlugField()
+
+    class Meta:
+        constraints = [
+            models.UniqueConstraint(
+                fields=['slug'],
+                name='model_options_article_slug_unq',
+            ),
+        ]
+
+
+class ConditionalUniqueConstraintArticle(models.Model):
+    slug = models.SlugField()
+
+    class Meta:
+        constraints = [
+            models.UniqueConstraint(
+                fields=['slug'],
+                condition=models.Q(slug__isnull=False),
+                name='model_options_article_slug_cond_unq',
+            ),
+        ]
+
+
+class MultiFieldUniqueConstraintArticle(models.Model):
+    slug = models.SlugField()
+    year = models.IntegerField()
+
+    class Meta:
+        constraints = [
+            models.UniqueConstraint(
+                fields=['slug', 'year'],
+                name='model_options_article_slug_year_unq',
+            ),
+        ]
diff --git a/tests/model_options/tests.py b/tests/model_options/tests.py
new file mode 100644
index 0000000000..ad80cfa22e
--- /dev/null
+++ b/tests/model_options/tests.py
@@ -0,0 +1,51 @@
+from django.test import TestCase
+
+from .models.constraints import (
+    ConditionalUniqueConstraintArticle, MultiFieldUniqueConstraintArticle,
+    UniqueConstraintArticle,
+)
+
+
+class InBulkUniqueConstraintTests(TestCase):
+    @classmethod
+    def setUpTestData(cls):
+        cls.article1 = UniqueConstraintArticle.objects.create(slug='a')
+        cls.article2 = UniqueConstraintArticle.objects.create(slug='b')
+
+    def test_in_bulk_with_total_unique_constraint(self):
+        self.assertEqual(
+            UniqueConstraintArticle.objects.in_bulk(
+                ['a', 'b'], field_name='slug',
+            ),
+            {
+                self.article1.slug: self.article1,
+                self.article2.slug: self.article2,
+            },
+        )
+
+    def test_in_bulk_with_conditional_unique_constraint(self):
+        msg = (
+            "in_bulk()'s field_name must be a unique field but 'slug' isn't."
+        )
+        with self.assertRaisesMessage(ValueError, msg):
+            ConditionalUniqueConstraintArticle.objects.in_bulk(
+                ['a'], field_name='slug',
+            )
+
+    def test_in_bulk_with_multi_field_unique_constraint(self):
+        msg = (
+            "in_bulk()'s field_name must be a unique field but 'slug' isn't."
+        )
+        with self.assertRaisesMessage(ValueError, msg):
+            MultiFieldUniqueConstraintArticle.objects.in_bulk(
+                ['a'], field_name='slug',
+            )
+
+    def test_total_unique_constraints(self):
+        constraints = UniqueConstraintArticle._meta.total_unique_constraints
+        self.assertEqual(len(constraints), 1)
+        self.assertEqual(constraints[0].fields, ('slug',))
+        self.assertEqual(
+            ConditionalUniqueConstraintArticle._meta.total_unique_constraints,
+            [],
+        )
```

### `review.md`

```
verdict: FAIL

- `django/db/models/query.py` now reads `self.model._meta.total_unique_constraints`, but `django/db/models/options.py` was not changed and no `Options.total_unique_constraints` property was added. On a model whose field is unique only via `UniqueConstraint`, `in_bulk()` will hit `AttributeError` instead of succeeding.
- Because `total_unique_constraints` is missing, the change does not satisfy the required behavior for conditional, expression-based, and multi-field constraints either; those must be excluded by the new `Options` property.
- The added tests are in `tests/lookup/`, which is outside the stated scope and is not exercised by `./tests/runtests.py queries.tests model_options.tests`. The scoped suites contain no regression test for this behavior.

Repair:
- In `django/db/models/options.py`, add `Options.total_unique_constraints` returning the model’s `UniqueConstraint`s that are total: exclude constraints with `condition is not None` and exclude expression-based constraints. Import `UniqueConstraint` if needed.
- Keep `in_bulk()`’s single-field filtering in `django/db/models/query.py` so multi-field total unique constraints do not make an individual field unique.
- Remove the out-of-scope `tests/lookup/` changes, or at minimum move the regression tests into `tests/queries/` or `tests/model_options/` and add cases proving conditional, expression-based, and multi-field constraints still raise `ValueError`.
```

### `scope.txt`

```
scope: django/db/models/options.py django/db/models/query.py tests/queries tests/model_options
changed: django/db/models/query.py +11 -1
OUTSIDE THE SCOPE: tests/lookup/models.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/lookup/tests.py +11 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `task.md`

```
# Task

## Prompt

Allow QuerySet.in_bulk() for fields with total UniqueConstraints.
Description
	
If a field is unique by UniqueConstraint instead of unique=True running in_bulk() on that field will fail.
Consider:
class Article(models.Model):
	slug = models.CharField(max_length=255)
	
	class Meta:
		constraints = [
			models.UniqueConstraint(fields=["slug"], name="%(app_label)s_%(class)s_slug_unq")
		]
>>> Article.objects.in_bulk(field_name="slug")
Traceback (most recent call last):
 File "/usr/local/lib/python3.8/code.py", line 90, in runcode
	exec(code, self.locals)
 File "<console>", line 1, in <module>
 File "/app/venv/lib/python3.8/site-packages/django/db/models/manager.py", line 82, in manager_method
	return getattr(self.get_queryset(), name)(*args, **kwargs)
 File "/app/venv/lib/python3.8/site-packages/django/db/models/query.py", line 680, in in_bulk
	raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
ValueError: in_bulk()'s field_name must be a unique field but 'slug' isn't.
It should be pretty simple to fix this and I have a patch if accepted.

## Deliverable

changes to this tree

## Check

`./tests/runtests.py queries.tests model_options.tests`

## Scope

`django/db/models/options.py`
`django/db/models/query.py`
`tests/queries/`
`tests/model_options/`

## Done when

- `QuerySet.in_bulk(field_name="slug")` succeeds when `slug` is covered by a total single-field `UniqueConstraint`.
- `in_bulk()` still raises `ValueError` for a field that is not unique by `unique=True` or a total single-field `UniqueConstraint`.
- Conditional, expression-based, and multi-field `UniqueConstraint`s are not treated as making an individual field total-unique.
- `Options.total_unique_constraints` exposes the model’s total `UniqueConstraint`s. `(inferred)`
```

### `test-output.log`

```
check: ./tests/runtests.py queries.tests model_options.tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
........s.......s............x.........x.............................................................................s......................................................E...............................................................................................................
======================================================================
ERROR: tests (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: tests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'model_options.tests'


----------------------------------------------------------------------
Ran 284 tests in 0.634s

FAILED (errors=1, skipped=3, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: django/db/models/options.py django/db/models/query.py tests/queries tests/model_options
changed: django/db/models/query.py +11 -1
OUTSIDE THE SCOPE: tests/lookup/models.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/lookup/tests.py +11 -0 (undo it: git checkout the file, or delete it when the run made it)
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
- `Options.total_unique_constraints` now excludes conditional and expression-based constraints, exposing only total `UniqueConstraint`s.
- `in_bulk()` accepts a field when it is `unique=True` or is the sole field of a total `UniqueConstraint`.
- Multi-field constraints are excluded by `len(constraint.fields) == 1`, so they do not make an individual field total-unique.
- Conditional constraints are excluded by `condition is None`; expression constraints by `contains_expressions`.
- The original `ValueError` path remains for fields that are not unique by either mechanism.
- Added tests cover total, conditional, and multi-field constraints plus `total_unique_constraints`.
```
