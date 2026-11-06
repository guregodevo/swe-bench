# django__django-11964 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 33s 39 lines cost=0.001239 in=90473 cached=78848 out=1670 calls=11`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

The value of a TextChoices/IntegerChoices field has a differing type
Description
	
If we create an instance of a model having a CharField or IntegerField with the keyword choices pointing to IntegerChoices or TextChoices, the value returned by the getter of the field will be of the same type as the one created by enum.Enum (enum value).
For example, this model:
from django.db import models
from django.utils.translation import gettext_lazy as _
class MyChoice(models.TextChoices):
	FIRST_CHOICE = "first", _("The first choice, it is")
	SECOND_CHOICE = "second", _("The second choice, it is")
class MyObject(models.Model):
	my_str_value = models.CharField(max_length=10, choices=MyChoice.choices)
Then this test:
from django.test import TestCase
from testing.pkg.models import MyObject, MyChoice
class EnumTest(TestCase):
	def setUp(self) -> None:
		self.my_object = MyObject.objects.create(my_str_value=MyChoice.FIRST_CHOICE)
	def test_created_object_is_str(self):
		my_object = self.my_object
		self.assertIsInstance(my_object.my_str_value, str)
		self.assertEqual(str(my_object.my_str_value), "first")
	def test_retrieved_object_is_str(self):
		my_object = MyObject.objects.last()
		self.assertIsInstance(my_object.my_str_value, str)
		self.assertEqual(str(my_object.my_str_value), "first")
And then the results:
(django30-venv) ➜ django30 ./manage.py test
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
F.
======================================================================
FAIL: test_created_object_is_str (testing.tests.EnumTest)
----------------------------------------------------------------------
Traceback (most recent call last):
 File "/Users/mikailkocak/Development/django30/testing/tests.py", line 14, in test_created_object_is_str
	self.assertEqual(str(my_object.my_str_value), "first")
AssertionError: 'MyChoice.FIRST_CHOICE' != 'first'
- MyChoice.FIRST_CHOICE
+ first
----------------------------------------------------------------------
Ran 2 tests in 0.002s
FAILED (failures=1)
We notice when invoking __str__(...) we don't actually get the value property of the enum value which can lead to some unexpected issues, especially when communicating to an external API with a freshly created instance that will send MyEnum.MyValue, and the one that was retrieved would send my_value.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain -- . ':(exclude).memdoor' | head -50"
}
```

**tool result**

```
/testbed
AUTHORS
CONTRIBUTING.rst
Django.egg-info
FUNDING.yml
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
```

**assistant → tool `bash`**

```json
{
  "command": "cat django/db/models/enums.py && grep -n \"choices\" django/db/models/fields/__init__.py | head -40"
}
```

**tool result**

```
import enum

from django.utils.functional import Promise

__all__ = ['Choices', 'IntegerChoices', 'TextChoices']


class ChoicesMeta(enum.EnumMeta):
    """A metaclass for creating a enum choices."""

    def __new__(metacls, classname, bases, classdict):
        labels = []
        for key in classdict._member_names:
            value = classdict[key]
            if (
                isinstance(value, (list, tuple)) and
                len(value) > 1 and
                isinstance(value[-1], (Promise, str))
            ):
                *value, label = value
                value = tuple(value)
            else:
                label = key.replace('_', ' ').title()
            labels.append(label)
            # Use dict.__setitem__() to suppress defenses against double
            # assignment in enum's classdict.
            dict.__setitem__(classdict, key, value)
        cls = super().__new__(metacls, classname, bases, classdict)
        cls._value2label_map_ = dict(zip(cls._value2member_map_, labels))
        # Add a label property to instances of enum which uses the enum member
        # that is passed in as "self" as the value to use when looking up the
        # label in the choices.
        cls.label = property(lambda self: cls._value2label_map_.get(self.value))
        return enum.unique(cls)

    def __contains__(cls, member):
        if not isinstance(member, enum.Enum):
            # Allow non-enums to match against member values.
            return member in {x.value for x in cls}
        return super().__contains__(member)

    @property
    def names(cls):
        empty = ['__empty__'] if hasattr(cls, '__empty__') else []
        return empty + [member.name for member in cls]

    @property
    def choices(cls):
        empty = [(None, cls.__empty__)] if hasattr(cls, '__empty__') else []
        return empty + [(member.value, member.label) for member in cls]

    @property
    def labels(cls):
        return [label for _, label in cls.choices]

    @property
    def values(cls):
        return [value for value, _ in cls.choices]


class Choices(enum.Enum, metaclass=ChoicesMeta):
    """Class for creating enumerated choices."""
    pass


class IntegerChoices(int, Choices):
    """Class for creating enumerated integer choices."""
    pass


class TextChoices(str, Choices):
    """Class for creating enumerated string choices."""

    def _generate_next_value_(name, start, count, last_values):
        return name
51:# of most "choices" lists.
135:                 unique_for_year=None, choices=None, help_text='', db_column=None,
152:        if isinstance(choices, collections.abc.Iterator):
153:            choices = list(choices)
154:        self.choices = choices
200:            *self._check_choices(),
240:    def _check_choices(self):
241:        if not self.choices:
247:        if is_value(self.choices, accept_promise=False):
250:                    "'choices' must be an iterable (e.g., a list or tuple).",
258:        for choices_group in self.choices:
260:                group_name, group_choices = choices_group
267:                    for value, human_name in group_choices
270:                if self.max_length is not None and group_choices:
273:                        *(len(value) for value, _ in group_choices if isinstance(value, str)),
276:                # No groups, choices in the form [value, display]
277:                value, human_name = group_name, group_choices
283:            # Special case: choices=['ab']
284:            if isinstance(choices_group, str):
291:                        "in 'choices' (%d characters)." % choice_max_length,
300:                "'choices' must be an iterable containing "
461:            "choices": None,
476:        equals_comparison = {"choices", "validators"}
479:            # Unroll anything iterable for choices into a concrete list
480:            if name == "choices" and isinstance(value, collections.abc.Iterable):
616:        if self.choices is not None and value not in self.empty_values:
617:            for option_key, option_value in self.choices:
765:        if self.choices is not None:
830:    def get_choices(self, include_blank=True, blank_choice=BLANK_CHOICE_DASH, limit_choices_to=None, ordering=()):
832:        Return choices with a default blank choices included, for use
833:        as <select> choices for this field.
835:        if self.choices is not None:
836:            choices = list(self.choices)
838:                blank_defined = any(choice in ('', None) for choice, _ in self.flatchoices)
840:                    choices = blank_choice + choices
841:            return choices
843:        limit_choices_to = limit_choices_to or self.get_limit_choices_to()
849:        qs = rel_model._default_manager.complex_filter(limit_choices_to)
863:    def _get_flatchoices(self):
864:        """Flattened version of choices tuple."""
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"TextChoices\\|IntegerChoices\\|Choices\" tests/model_enums/ | head -60; ls tests/model_enums/"
}
```

**tool result**

```
tests/model_enums/tests.py:12:class Suit(models.IntegerChoices):
tests/model_enums/tests.py:19:class YearInSchool(models.TextChoices):
tests/model_enums/tests.py:27:class Vehicle(models.IntegerChoices):
tests/model_enums/tests.py:35:class Gender(models.TextChoices):
tests/model_enums/tests.py:43:class ChoicesTests(SimpleTestCase):
tests/model_enums/tests.py:56:        self.assertIsInstance(Suit, type(models.Choices))
tests/model_enums/tests.py:73:        Place = models.IntegerChoices('Place', 'FIRST SECOND THIRD')
tests/model_enums/tests.py:97:        self.assertIsInstance(YearInSchool, type(models.Choices))
tests/model_enums/tests.py:114:        Medal = models.TextChoices('Medal', 'GOLD SILVER BRONZE')
tests/model_enums/tests.py:125:        class BlankStr(models.TextChoices):
tests/model_enums/tests.py:136:            class InvalidArgumentEnum(models.IntegerChoices):
tests/model_enums/tests.py:142:            class Fruit(models.IntegerChoices):
tests/model_enums/tests.py:147:class Separator(bytes, models.Choices):
tests/model_enums/tests.py:154:class Constants(float, models.Choices):
tests/model_enums/tests.py:159:class Set(frozenset, models.Choices):
tests/model_enums/tests.py:167:class MoonLandings(datetime.date, models.Choices):
tests/model_enums/tests.py:176:class DateAndTime(datetime.datetime, models.Choices):
tests/model_enums/tests.py:182:class MealTimes(datetime.time, models.Choices):
tests/model_enums/tests.py:188:class Frequency(datetime.timedelta, models.Choices):
tests/model_enums/tests.py:196:class Number(decimal.Decimal, models.Choices):
tests/model_enums/tests.py:202:class IPv4Address(ipaddress.IPv4Address, models.Choices):
tests/model_enums/tests.py:208:class IPv6Address(ipaddress.IPv6Address, models.Choices):
tests/model_enums/tests.py:213:class IPv4Network(ipaddress.IPv4Network, models.Choices):
tests/model_enums/tests.py:219:class IPv6Network(ipaddress.IPv6Network, models.Choices):
tests/model_enums/tests.py:226:class CustomChoicesTests(SimpleTestCase):
tests/model_enums/tests.py:240:            class Boolean(bool, models.Choices):
tests/model_enums/tests.py:246:            class Timezone(datetime.timezone, models.Choices):
tests/model_enums/tests.py:252:            class Identifier(uuid.UUID, models.Choices):
__init__.py
tests.py
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,60p' tests/model_enums/tests.py; sed -n '220,270p' tests/model_enums/tests.py"
}
```

**tool result**

```
import datetime
import decimal
import ipaddress
import uuid

from django.db import models
from django.test import SimpleTestCase
from django.utils.functional import Promise
from django.utils.translation import gettext_lazy as _


class Suit(models.IntegerChoices):
    DIAMOND = 1, _('Diamond')
    SPADE = 2, _('Spade')
    HEART = 3, _('Heart')
    CLUB = 4, _('Club')


class YearInSchool(models.TextChoices):
    FRESHMAN = 'FR', _('Freshman')
    SOPHOMORE = 'SO', _('Sophomore')
    JUNIOR = 'JR', _('Junior')
    SENIOR = 'SR', _('Senior')
    GRADUATE = 'GR', _('Graduate')


class Vehicle(models.IntegerChoices):
    CAR = 1, 'Carriage'
    TRUCK = 2
    JET_SKI = 3

    __empty__ = _('(Unknown)')


class Gender(models.TextChoices):
    MALE = 'M'
    FEMALE = 'F'
    NOT_SPECIFIED = 'X'

    __empty__ = '(Undeclared)'


class ChoicesTests(SimpleTestCase):
    def test_integerchoices(self):
        self.assertEqual(Suit.choices, [(1, 'Diamond'), (2, 'Spade'), (3, 'Heart'), (4, 'Club')])
        self.assertEqual(Suit.labels, ['Diamond', 'Spade', 'Heart', 'Club'])
        self.assertEqual(Suit.values, [1, 2, 3, 4])
        self.assertEqual(Suit.names, ['DIAMOND', 'SPADE', 'HEART', 'CLUB'])

        self.assertEqual(repr(Suit.DIAMOND), '<Suit.DIAMOND: 1>')
        self.assertEqual(Suit.DIAMOND.label, 'Diamond')
        self.assertEqual(Suit.DIAMOND.value, 1)
        self.assertEqual(Suit['DIAMOND'], Suit.DIAMOND)
        self.assertEqual(Suit(1), Suit.DIAMOND)

        self.assertIsInstance(Suit, type(models.Choices))
        self.assertIsInstance(Suit.DIAMOND, Suit)
        self.assertIsInstance(Suit.DIAMOND.label, Promise)
        self.assertIsInstance(Suit.DIAMOND.value, int)

    LOOPBACK = '::1/128', 'Loopback'
    UNSPECIFIED = '::/128', 'Unspecified'
    UNIQUE_LOCAL = 'fc00::/7', 'Unique-Local'
    LINK_LOCAL_UNICAST = 'fe80::/10', 'Link-Local Unicast'


class CustomChoicesTests(SimpleTestCase):
    def test_labels_valid(self):
        enums = (
            Separator, Constants, Set, MoonLandings, DateAndTime, MealTimes,
            Frequency, Number, IPv4Address, IPv6Address, IPv4Network,
            IPv6Network,
        )
        for choice_enum in enums:
            with self.subTest(choice_enum.__name__):
                self.assertNotIn(None, choice_enum.labels)

    def test_bool_unsupported(self):
        msg = "type 'bool' is not an acceptable base type"
        with self.assertRaisesMessage(TypeError, msg):
            class Boolean(bool, models.Choices):
                pass

    def test_timezone_unsupported(self):
        msg = "type 'datetime.timezone' is not an acceptable base type"
        with self.assertRaisesMessage(TypeError, msg):
            class Timezone(datetime.timezone, models.Choices):
                pass

    def test_uuid_unsupported(self):
        msg = 'UUID objects are immutable'
        with self.assertRaisesMessage(TypeError, msg):
            class Identifier(uuid.UUID, models.Choices):
                A = '972ce4eb-a95f-4a56-9339-68c208a76f18'
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/db/models/enums.py\n@@\n class Choices(enum.Enum, metaclass=ChoicesMeta):\n     \"\"\"Class for creating enumerated choices.\"\"\"\n-    pass\n+\n+    def __str__(self):\n+        \"\"\"\n+        Use value when cast to str, so that Choices set as model instance\n+        attributes are rendered as expected in templates and similar contexts.\n+        \"\"\"\n+        return str(self.value)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/db/models/enums.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/db/models/enums.py now (81 lines), around the change:
60:
61:class Choices(enum.Enum, metaclass=ChoicesMeta):
62:    """Class for creating enumerated choices."""
63:
64:    def __str__(self):
65:        """
66:        Use value when cast to str, so that Choices set as model instance
67:        attributes are rendered as expected in templates and similar contexts.
68:        """
69:        return str(self.value)
70:
71:
72:class IntegerChoices(int, Choices):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/model_enums/tests.py -q 2>&1 | tail -20 || python tests/runtests.py model_enums 2>&1 | tail -30"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py model_enums 2>&1 | tail -30"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
................
----------------------------------------------------------------------
Ran 16 tests in 0.153s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '60,125p' tests/model_enums/tests.py"
}
```

**tool result**

```

    def test_integerchoices_auto_label(self):
        self.assertEqual(Vehicle.CAR.label, 'Carriage')
        self.assertEqual(Vehicle.TRUCK.label, 'Truck')
        self.assertEqual(Vehicle.JET_SKI.label, 'Jet Ski')

    def test_integerchoices_empty_label(self):
        self.assertEqual(Vehicle.choices[0], (None, '(Unknown)'))
        self.assertEqual(Vehicle.labels[0], '(Unknown)')
        self.assertEqual(Vehicle.values[0], None)
        self.assertEqual(Vehicle.names[0], '__empty__')

    def test_integerchoices_functional_api(self):
        Place = models.IntegerChoices('Place', 'FIRST SECOND THIRD')
        self.assertEqual(Place.labels, ['First', 'Second', 'Third'])
        self.assertEqual(Place.values, [1, 2, 3])
        self.assertEqual(Place.names, ['FIRST', 'SECOND', 'THIRD'])

    def test_integerchoices_containment(self):
        self.assertIn(Suit.DIAMOND, Suit)
        self.assertIn(1, Suit)
        self.assertNotIn(0, Suit)

    def test_textchoices(self):
        self.assertEqual(YearInSchool.choices, [
            ('FR', 'Freshman'), ('SO', 'Sophomore'), ('JR', 'Junior'), ('SR', 'Senior'), ('GR', 'Graduate'),
        ])
        self.assertEqual(YearInSchool.labels, ['Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate'])
        self.assertEqual(YearInSchool.values, ['FR', 'SO', 'JR', 'SR', 'GR'])
        self.assertEqual(YearInSchool.names, ['FRESHMAN', 'SOPHOMORE', 'JUNIOR', 'SENIOR', 'GRADUATE'])

        self.assertEqual(repr(YearInSchool.FRESHMAN), "<YearInSchool.FRESHMAN: 'FR'>")
        self.assertEqual(YearInSchool.FRESHMAN.label, 'Freshman')
        self.assertEqual(YearInSchool.FRESHMAN.value, 'FR')
        self.assertEqual(YearInSchool['FRESHMAN'], YearInSchool.FRESHMAN)
        self.assertEqual(YearInSchool('FR'), YearInSchool.FRESHMAN)

        self.assertIsInstance(YearInSchool, type(models.Choices))
        self.assertIsInstance(YearInSchool.FRESHMAN, YearInSchool)
        self.assertIsInstance(YearInSchool.FRESHMAN.label, Promise)
        self.assertIsInstance(YearInSchool.FRESHMAN.value, str)

    def test_textchoices_auto_label(self):
        self.assertEqual(Gender.MALE.label, 'Male')
        self.assertEqual(Gender.FEMALE.label, 'Female')
        self.assertEqual(Gender.NOT_SPECIFIED.label, 'Not Specified')

    def test_textchoices_empty_label(self):
        self.assertEqual(Gender.choices[0], (None, '(Undeclared)'))
        self.assertEqual(Gender.labels[0], '(Undeclared)')
        self.assertEqual(Gender.values[0], None)
        self.assertEqual(Gender.names[0], '__empty__')

    def test_textchoices_functional_api(self):
        Medal = models.TextChoices('Medal', 'GOLD SILVER BRONZE')
        self.assertEqual(Medal.labels, ['Gold', 'Silver', 'Bronze'])
        self.assertEqual(Medal.values, ['GOLD', 'SILVER', 'BRONZE'])
        self.assertEqual(Medal.names, ['GOLD', 'SILVER', 'BRONZE'])

    def test_textchoices_containment(self):
        self.assertIn(YearInSchool.FRESHMAN, YearInSchool)
        self.assertIn('FR', YearInSchool)
        self.assertNotIn('XX', YearInSchool)

    def test_textchoices_blank_value(self):
        class BlankStr(models.TextChoices):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/model_enums/tests.py\n@@\n         self.assertEqual(YearInSchool.FRESHMAN.label, 'Freshman')\n         self.assertEqual(YearInSchool.FRESHMAN.value, 'FR')\n+        self.assertEqual(str(YearInSchool.FRESHMAN), 'FR')\n         self.assertEqual(YearInSchool['FRESHMAN'], YearInSchool.FRESHMAN)\n         self.assertEqual(YearInSchool('FR'), YearInSchool.FRESHMAN)\n@@\n         self.assertEqual(Suit.DIAMOND.label, 'Diamond')\n         self.assertEqual(Suit.DIAMOND.value, 1)\n+        self.assertEqual(str(Suit.DIAMOND), '1')\n         self.assertEqual(Suit['DIAMOND'], Suit.DIAMOND)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/model_enums/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/model_enums/tests.py now (255 lines), around the change:
50:        self.assertEqual(repr(Suit.DIAMOND), '<Suit.DIAMOND: 1>')
51:        self.assertEqual(Suit.DIAMOND.label, 'Diamond')
52:        self.assertEqual(Suit.DIAMOND.value, 1)
53:        self.assertEqual(str(Suit.DIAMOND), '1')
54:        self.assertEqual(Suit['DIAMOND'], Suit.DIAMOND)
55:        self.assertEqual(Suit(1), Suit.DIAMOND)
56:
…
92:        self.assertEqual(repr(YearInSchool.FRESHMAN), "<YearInSchool.FRESHMAN: 'FR'>")
93:        self.assertEqual(YearInSchool.FRESHMAN.label, 'Freshman')
94:        self.assertEqual(YearInSchool.FRESHMAN.value, 'FR')
95:        self.assertEqual(str(YearInSchool.FRESHMAN), 'FR')
96:        self.assertEqual(YearInSchool['FRESHMAN'], YearInSchool.FRESHMAN)
97:        self.assertEqual(YearInSchool('FR'), YearInSchool.FRESHMAN)
98:
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py model_enums 2>&1 | tail -10; git status --porcelain -- . ':(exclude).memdoor'; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TARGET_OK"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
................
----------------------------------------------------------------------
Ran 16 tests in 0.171s

OK
 M django/db/models/enums.py
 M tests/model_enums/tests.py
TARGET_OK
```

**assistant**

```
Implemented the fix and verified it.

- Added `Choices.__str__()` in `django/db/models/enums.py` so enum members render as their underlying value (`"first"`, `"1"`) rather than `MyChoice.FIRST_CHOICE`.
- Added regression assertions for both `TextChoices` and `IntegerChoices` in `tests/model_enums/tests.py`.
- `python tests/runtests.py model_enums` passes (16 tests).
- The target command now exits 0.
```

## Run folder `single-2026-11-06T105634`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
The value of a TextChoices/IntegerChoices field has a differing type
Description
	
If we create an instance of a model having a CharField or IntegerField with the keyword choices pointing to IntegerChoices or TextChoices, the value returned by the getter of the field will be of the same type as the one created by enum.Enum (enum value).
For example, this model:
from django.db import models
from django.utils.translation import gettext_lazy as _
class MyChoice(models.TextChoices):
	FIRST_CHOICE = "first", _("The first choice, it is")
	SECOND_CHOICE = "second", _("The second choice, it is")
class MyObject(models.Model):
	my_str_value = models.CharField(max_length=10, choices=MyChoice.choices)
Then this test:
from django.test import TestCase
from testing.pkg.models import MyObject, MyChoice
class EnumTest(TestCase):
	def setUp(self) -> None:
		self.my_object = MyObject.objects.create(my_str_value=MyChoice.FIRST_CHOICE)
	def test_created_object_is_str(self):
		my_object = self.my_object
		self.assertIsInstance(my_object.my_str_value, str)
		self.assertEqual(str(my_object.my_str_value), "first")
	def test_retrieved_object_is_str(self):
		my_object = MyObject.objects.last()
		self.assertIsInstance(my_object.my_str_value, str)
		self.assertEqual(str(my_object.my_str_value), "first")
And then the results:
(django30-venv) ➜ django30 ./manage.py test
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
F.
======================================================================
FAIL: test_created_object_is_str (testing.tests.EnumTest)
----------------------------------------------------------------------
Traceback (most recent call last):
 File "/Users/mikailkocak/Development/django30/testing/tests.py", line 14, in test_created_object_is_str
	self.assertEqual(str(my_object.my_str_value), "first")
AssertionError: 'MyChoice.FIRST_CHOICE' != 'first'
- MyChoice.FIRST_CHOICE
+ first
----------------------------------------------------------------------
Ran 2 tests in 0.002s
FAILED (failures=1)
We notice when invoking __str__(...) we don't actually get the value property of the enum value which can lead to some unexpected issues, especially when communicating to an external API with a freshly created instance that will send MyEnum.MyValue, and the one that was retrieved would send my_value.
```
