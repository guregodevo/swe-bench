# django__django-17029 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 39s 30 lines cost=0.002292 in=175452 cached=131072 out=1978 calls=16`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Apps.clear_cache() does not clear get_swappable_settings_name cache.
Description
	
We use apps.clear_cache() in django-stubs to be able to reset the previous state on consequential mypy runs.
Code: ​https://github.com/typeddjango/django-stubs/pull/1601/files#diff-c49d8fe2cd0a58fad3c36ab3a88c7745e9622f3098e60cd512953eb17b8a1994R63-R64
But, looks like we don't clear all the object's cache this way, because get_swappable_settings_name (which is a functools._lru_cache_wrapper) is not cleared.
I think that this is not correct. .clear_cache doc states: Clear all internal caches, for methods that alter the app registry.
Looks like that is not the case.
I propose to add: self.get_swappable_settings_name.cache_clear() line to def clear_cache.
If others agree, I will make a PR.
Original discussion: ​https://github.com/typeddjango/django-stubs/pull/1601#discussion_r1246344533

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && grep -rn \"get_swappable_settings_name\\|def clear_cache\" django/apps/registry.py | head -30"
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
284:    def get_swappable_settings_name(self, to_string):
370:    def clear_cache(self):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/apps/registry.py",
  "offset": 270,
  "limit": 120
}
```

**tool result**

```
    def get_registered_model(self, app_label, model_name):
        """
        Similar to get_model(), but doesn't require that an app exists with
        the given app_label.

        It's safe to call this method at import time, even while the registry
        is being populated.
        """
        model = self.all_models[app_label].get(model_name.lower())
        if model is None:
            raise LookupError("Model '%s.%s' not registered." % (app_label, model_name))
        return model

    @functools.cache
    def get_swappable_settings_name(self, to_string):
        """
        For a given model string (e.g. "auth.User"), return the name of the
        corresponding settings name if it refers to a swappable model. If the
        referred model is not swappable, return None.

        This method is decorated with @functools.cache because it's performance
        critical when it comes to migrations. Since the swappable settings don't
        change after Django has loaded the settings, there is no reason to get
        the respective settings attribute over and over again.
        """
        to_string = to_string.lower()
        for model in self.get_models(include_swapped=True):
            swapped = model._meta.swapped
            # Is this model swapped out for the model given by to_string?
            if swapped and swapped.lower() == to_string:
                return model._meta.swappable
            # Is this model swappable and the one given by to_string?
            if model._meta.swappable and model._meta.label_lower == to_string:
                return model._meta.swappable
        return None

    def set_available_apps(self, available):
        """
        Restrict the set of installed apps used by get_app_config[s].

        available must be an iterable of application names.

        set_available_apps() must be balanced with unset_available_apps().

        Primarily used for performance optimization in TransactionTestCase.

        This method is safe in the sense that it doesn't trigger any imports.
        """
        available = set(available)
        installed = {app_config.name for app_config in self.get_app_configs()}
        if not available.issubset(installed):
            raise ValueError(
                "Available apps isn't a subset of installed apps, extra apps: %s"
                % ", ".join(available - installed)
            )

        self.stored_app_configs.append(self.app_configs)
        self.app_configs = {
            label: app_config
            for label, app_config in self.app_configs.items()
            if app_config.name in available
        }
        self.clear_cache()

    def unset_available_apps(self):
        """Cancel a previous call to set_available_apps()."""
        self.app_configs = self.stored_app_configs.pop()
        self.clear_cache()

    def set_installed_apps(self, installed):
        """
        Enable a different set of installed apps for get_app_config[s].

        installed must be an iterable in the same format as INSTALLED_APPS.

        set_installed_apps() must be balanced with unset_installed_apps(),
        even if it exits with an exception.

        Primarily used as a receiver of the setting_changed signal in tests.

        This method may trigger new imports, which may add new models to the
        registry of all imported models. They will stay in the registry even
        after unset_installed_apps(). Since it isn't possible to replay
        imports safely (e.g. that could lead to registering listeners twice),
        models are registered when they're imported and never removed.
        """
        if not self.ready:
            raise AppRegistryNotReady("App registry isn't ready yet.")
        self.stored_app_configs.append(self.app_configs)
        self.app_configs = {}
        self.apps_ready = self.models_ready = self.loading = self.ready = False
        self.clear_cache()
        self.populate(installed)

    def unset_installed_apps(self):
        """Cancel a previous call to set_installed_apps()."""
        self.app_configs = self.stored_app_configs.pop()
        self.apps_ready = self.models_ready = self.ready = True
        self.clear_cache()

    def clear_cache(self):
        """
        Clear all internal caches, for methods that alter the app registry.

        This is mostly used in tests.
        """
        # Call expire cache on each model. This will purge
        # the relation tree and the fields cache.
        self.get_models.cache_clear()
        if self.ready:
            # Circumvent self.get_models() to prevent that the cache is refilled.
            # This particularly prevents that an empty value is cached while cloning.
            for app_config in self.app_configs.values():
                for model in app_config.get_models(include_auto_created=True):
                    model._meta._expire_cache()

    def lazy_model_operation(self, function, *model_keys):
        """
        Take a function and a number of ("app_label", "modelname") tuples, and
        when all the corresponding models have been imported and registered,

[47 more lines in /testbed/django/apps/registry.py (436 in all). read_file with offset: 390 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"clear_cache\\|get_swappable_settings_name\" tests/apps tests | head -30"
}
```

**tool result**

```
tests/contenttypes_tests/test_views.py:62:        Site.objects.clear_cache()
tests/contenttypes_tests/test_views.py:141:        Site.objects.clear_cache()
tests/contenttypes_tests/test_models.py:13:        ContentType.objects.clear_cache()
tests/contenttypes_tests/test_models.py:16:        ContentType.objects.clear_cache()
tests/contenttypes_tests/test_models.py:38:        ContentType.objects.clear_cache()
tests/contenttypes_tests/test_models.py:43:        ContentType.objects.clear_cache()
tests/contenttypes_tests/test_models.py:270:        ContentType.objects.clear_cache()
tests/contenttypes_tests/test_models.py:326:        ContentType.objects.clear_cache()
tests/contenttypes_tests/test_fields.py:46:    def test_clear_cached_generic_relation(self):
tests/auth_tests/test_forms.py:1031:        Site.objects.clear_cache()
tests/auth_tests/test_auth_backends.py:109:        ContentType.objects.clear_cache()
tests/auth_tests/test_auth_backends.py:489:        ContentType.objects.clear_cache()
tests/auth_tests/test_management.py:1417:        ContentType.objects.clear_cache()
tests/sitemaps_tests/base.py:31:        Site.objects.clear_cache()
tests/syndication_tests/tests.py:88:        Site.objects.clear_cache()
tests/field_deconstruction/tests.py:308:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/field_deconstruction/tests.py:320:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/field_deconstruction/tests.py:528:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/model_meta/tests.py:229:        apps.clear_cache()
tests/model_meta/tests.py:231:    def test_clear_cache_clears_relation_tree(self):
tests/model_meta/tests.py:232:        # The apps.clear_cache is setUp() should have deleted all trees.
tests/model_options/test_tablespaces.py:48:        apps.clear_cache()
tests/admin_views/tests.py:7213:        ContentType.objects.clear_cache()
tests/admin_views/tests.py:7261:        ContentType.objects.clear_cache()
tests/fixtures/tests.py:136:        apps.clear_cache()
tests/migrations/test_autodetector.py:3438:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/migrations/test_autodetector.py:3465:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/migrations/test_autodetector.py:3495:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/migrations/test_autodetector.py:3503:        with isolate_lru_cache(apps.get_swappable_settings_name):
tests/migrations/test_autodetector.py:4271:        with isolate_lru_cache(apps.get_swappable_settings_name):
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/model_meta/tests.py",
  "offset": 1,
  "limit": 60
}
```

**tool result**

```
from django.apps import apps
from django.contrib.contenttypes.fields import GenericForeignKey, GenericRelation
from django.core.exceptions import FieldDoesNotExist
from django.db.models import CharField, Field, ForeignObjectRel, ManyToManyField
from django.db.models.options import EMPTY_RELATION_TREE, IMMUTABLE_WARNING
from django.test import SimpleTestCase

from .models import (
    AbstractPerson,
    BasePerson,
    Child,
    CommonAncestor,
    FirstParent,
    Person,
    ProxyPerson,
    Relating,
    Relation,
    SecondParent,
)
from .results import TEST_RESULTS


class OptionsBaseTests(SimpleTestCase):
    def _map_related_query_names(self, res):
        return tuple((o.name, m) for o, m in res)

    def _map_names(self, res):
        return tuple((f.name, m) for f, m in res)

    def _model(self, current_model, field):
        model = field.model._meta.concrete_model
        return None if model == current_model else model

    def _details(self, current_model, relation):
        direct = isinstance(relation, (Field, GenericForeignKey))
        model = relation.model._meta.concrete_model
        if model == current_model:
            model = None

        field = relation if direct else relation.field
        return (
            relation,
            model,
            direct,
            bool(field.many_to_many),
        )  # many_to_many can be None


class GetFieldsTests(OptionsBaseTests):
    def test_get_fields_is_immutable(self):
        msg = IMMUTABLE_WARNING % "get_fields()"
        for _ in range(2):
            # Running unit test twice to ensure both non-cached and cached result
            # are immutable.
            fields = Person._meta.get_fields()
            with self.assertRaisesMessage(AttributeError, msg):
                fields += ["errors"]


class LabelTests(OptionsBaseTests):

[287 more lines in /testbed/tests/model_meta/tests.py (347 in all). read_file with offset: 61 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/model_meta/tests.py",
  "offset": 210,
  "limit": 50
}
```

**tool result**

```
        try:
            # 'data_abstract' is a forward field, and therefore will be found
            self.assertTrue(opts.get_field("data_abstract"))
            msg = (
                "Person has no field named 'relating_baseperson'. The app "
                "cache isn't ready yet, so if this is an auto-created related "
                "field, it won't be available yet."
            )
            # 'data_abstract' is a reverse field, and will raise an exception
            with self.assertRaisesMessage(FieldDoesNotExist, msg):
                opts.get_field("relating_baseperson")
        finally:
            opts.apps.models_ready = True


class RelationTreeTests(SimpleTestCase):
    all_models = (Relation, AbstractPerson, BasePerson, Person, ProxyPerson, Relating)

    def setUp(self):
        apps.clear_cache()

    def test_clear_cache_clears_relation_tree(self):
        # The apps.clear_cache is setUp() should have deleted all trees.
        # Exclude abstract models that are not included in the Apps registry
        # and have no cache.
        all_models_with_cache = (m for m in self.all_models if not m._meta.abstract)
        for m in all_models_with_cache:
            self.assertNotIn("_relation_tree", m._meta.__dict__)

    def test_first_relation_tree_access_populates_all(self):
        # On first access, relation tree should have populated cache.
        self.assertTrue(self.all_models[0]._meta._relation_tree)

        # AbstractPerson does not have any relations, so relation_tree
        # should just return an EMPTY_RELATION_TREE.
        self.assertEqual(AbstractPerson._meta._relation_tree, EMPTY_RELATION_TREE)

        # All the other models should already have their relation tree
        # in the internal __dict__ .
        all_models_but_abstractperson = (
            m for m in self.all_models if m is not AbstractPerson
        )
        for m in all_models_but_abstractperson:
            self.assertIn("_relation_tree", m._meta.__dict__)

    def test_relations_related_objects(self):
        # Testing non hidden related objects
        self.assertEqual(
            sorted(
                field.related_query_name()

[88 more lines in /testbed/tests/model_meta/tests.py (347 in all). read_file with offset: 260 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "ls tests/apps && grep -n \"clear_cache\\|swappable\" tests/apps/*.py"
}
```

**tool result**

```
__init__.py
apps.py
models.py
namespace_package_base
namespace_package_other_base
no_config_app
one_config_app
tests.py
two_configs_app
two_configs_one_default_app
two_default_configs_app

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/apps/tests.py"
}
```

**tool result**

```
import os

from django.apps import AppConfig, apps
from django.apps.registry import Apps
from django.contrib.admin.models import LogEntry
from django.core.exceptions import AppRegistryNotReady, ImproperlyConfigured
from django.db import models
from django.test import SimpleTestCase, override_settings
from django.test.utils import extend_sys_path, isolate_apps

from .models import SoAlternative, TotallyNormal, new_apps
from .one_config_app.apps import OneConfig
from .two_configs_one_default_app.apps import TwoConfig

# Small list with a variety of cases for tests that iterate on installed apps.
# Intentionally not in alphabetical order to check if the order is preserved.

SOME_INSTALLED_APPS = [
    "apps.apps.MyAdmin",
    "apps.apps.MyAuth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

SOME_INSTALLED_APPS_NAMES = [
    "django.contrib.admin",
    "django.contrib.auth",
] + SOME_INSTALLED_APPS[2:]

HERE = os.path.dirname(__file__)


class AppsTests(SimpleTestCase):
    def test_singleton_main(self):
        """
        Only one main registry can exist.
        """
        with self.assertRaises(RuntimeError):
            Apps(installed_apps=None)

    def test_ready(self):
        """
        Tests the ready property of the main registry.
        """
        # The main app registry is always ready when the tests run.
        self.assertIs(apps.ready, True)
        # Non-main app registries are populated in __init__.
        self.assertIs(Apps().ready, True)
        # The condition is set when apps are ready
        self.assertIs(apps.ready_event.is_set(), True)
        self.assertIs(Apps().ready_event.is_set(), True)

    def test_bad_app_config(self):
        """
        Tests when INSTALLED_APPS contains an incorrect app config.
        """
        msg = "'apps.apps.BadConfig' must supply a name attribute."
        with self.assertRaisesMessage(ImproperlyConfigured, msg):
            with self.settings(INSTALLED_APPS=["apps.apps.BadConfig"]):
                pass

    def test_not_an_app_config(self):
        """
        Tests when INSTALLED_APPS contains a class that isn't an app config.
        """
        msg = "'apps.apps.NotAConfig' isn't a subclass of AppConfig."
        with self.assertRaisesMessage(ImproperlyConfigured, msg):
            with self.settings(INSTALLED_APPS=["apps.apps.NotAConfig"]):
                pass

    def test_no_such_app(self):
        """
        Tests when INSTALLED_APPS contains an app that doesn't exist, either
        directly or via an app config.
        """
        with self.assertRaises(ImportError):
            with self.settings(INSTALLED_APPS=["there is no such app"]):
                pass
        msg = (
            "Cannot import 'there is no such app'. Check that "
            "'apps.apps.NoSuchApp.name' is correct."
        )
        with self.assertRaisesMessage(ImproperlyConfigured, msg):
            with self.settings(INSTALLED_APPS=["apps.apps.NoSuchApp"]):
                pass

    def test_no_such_app_config(self):
        msg = "Module 'apps' does not contain a 'NoSuchConfig' class."
        with self.assertRaisesMessage(ImportError, msg):
            with self.settings(INSTALLED_APPS=["apps.NoSuchConfig"]):
                pass

    def test_no_such_app_config_with_choices(self):
        msg = (
            "Module 'apps.apps' does not contain a 'NoSuchConfig' class. "
            "Choices are: 'BadConfig', 'ModelPKAppsConfig', 'MyAdmin', "
            "'MyAuth', 'NoSuchApp', 'PlainAppsConfig', 'RelabeledAppsConfig'."
        )
        with self.assertRaisesMessage(ImportError, msg):
            with self.settings(INSTALLED_APPS=["apps.apps.NoSuchConfig"]):
                pass

    def test_no_config_app(self):
        """Load an app that doesn't provide an AppConfig class."""
        with self.settings(INSTALLED_APPS=["apps.no_config_app"]):
            config = apps.get_app_config("no_config_app")
        self.assertIsInstance(config, AppConfig)

    def test_one_config_app(self):
        """Load an app that provides an AppConfig class."""
        with self.settings(INSTALLED_APPS=["apps.one_config_app"]):
            config = apps.get_app_config("one_config_app")
        self.assertIsInstance(config, OneConfig)

    def test_two_configs_app(self):
        """Load an app that provides two AppConfig classes."""
        with self.settings(INSTALLED_APPS=["apps.two_configs_app"]):
            config = apps.get_app_config("two_configs_app")
        self.assertIsInstance(config, AppConfig)

    def test_two_default_configs_app(self):
        """Load an app that provides two default AppConfig classes."""
        msg = (
            "'apps.two_default_configs_app.apps' declares more than one "
            "default AppConfig: 'TwoConfig', 'TwoConfigBis'."
        )
        with self.assertRaisesMessage(RuntimeError, msg):
            with self.settings(INSTALLED_APPS=["apps.two_default_configs_app"]):
                pass

    def test_two_configs_one_default_app(self):
        """
        Load an app that provides two AppConfig classes, one being the default.
        """
        with self.settings(INSTALLED_APPS=["apps.two_configs_one_default_app"]):
            config = apps.get_app_config("two_configs_one_default_app")
        self.assertIsInstance(config, TwoConfig)

    @override_settings(INSTALLED_APPS=SOME_INSTALLED_APPS)
    def test_get_app_configs(self):
        """
        Tests apps.get_app_configs().
        """
        app_configs = apps.get_app_configs()
        self.assertEqual(
            [app_config.name for app_config in app_configs], SOME_INSTALLED_APPS_NAMES
        )

    @override_settings(INSTALLED_APPS=SOME_INSTALLED_APPS)
    def test_get_app_config(self):
        """
        Tests apps.get_app_config().
        """
        app_config = apps.get_app_config("admin")
        self.assertEqual(app_config.name, "django.contrib.admin")

        app_config = apps.get_app_config("staticfiles")
        self.assertEqual(app_config.name, "django.contrib.staticfiles")

        with self.assertRaises(LookupError):
            apps.get_app_config("admindocs")

        msg = "No installed app with label 'django.contrib.auth'. Did you mean 'myauth'"
        with self.assertRaisesMessage(LookupError, msg):
            apps.get_app_config("django.contrib.auth")

    @override_settings(INSTALLED_APPS=SOME_INSTALLED_APPS)
    def test_is_installed(self):
        """
        Tests apps.is_installed().
        """
        self.assertIs(apps.is_installed("django.contrib.admin"), True)
        self.assertIs(apps.is_installed("django.contrib.auth"), True)
        self.assertIs(apps.is_installed("django.contrib.staticfiles"), True)
        self.assertIs(apps.is_installed("django.contrib.admindocs"), False)

    @override_settings(INSTALLED_APPS=SOME_INSTALLED_APPS)
    def test_get_model(self):
        """
        Tests apps.get_model().
        """
        self.assertEqual(apps.get_model("admin", "LogEntry"), LogEntry)
        with self.assertRaises(LookupError):
            apps.get_model("admin", "LogExit")

        # App label is case-sensitive, Model name is case-insensitive.
        self.assertEqual(apps.get_model("admin", "loGentrY"), LogEntry)
        with self.assertRaises(LookupError):
            apps.get_model("Admin", "LogEntry")

        # A single argument is accepted.
        self.assertEqual(apps.get_model("admin.LogEntry"), LogEntry)
        with self.assertRaises(LookupError):
            apps.get_model("admin.LogExit")
        with self.assertRaises(ValueError):
            apps.get_model("admin_LogEntry")

    @override_settings(INSTALLED_APPS=["apps.apps.RelabeledAppsConfig"])
    def test_relabeling(self):
        self.assertEqual(apps.get_app_config("relabeled").name, "apps")

    def test_duplicate_labels(self):
        with self.assertRaisesMessage(
            ImproperlyConfigured, "Application labels aren't unique"
        ):
            with self.settings(INSTALLED_APPS=["apps.apps.PlainAppsConfig", "apps"]):
                pass

    def test_duplicate_names(self):
        with self.assertRaisesMessage(
            ImproperlyConfigured, "Application names aren't unique"
        ):
            with self.settings(
                INSTALLED_APPS=["apps.apps.RelabeledAppsConfig", "apps"]
            ):
                pass

    def test_import_exception_is_not_masked(self):
        """
        App discovery should preserve stack traces. Regression test for #22920.
        """
        with self.assertRaisesMessage(ImportError, "Oops"):
            with self.settings(INSTALLED_APPS=["import_error_package"]):
                pass

    def test_models_py(self):
        """
        The models in the models.py file were loaded correctly.
        """
        self.assertEqual(apps.get_model("apps", "TotallyNormal"), TotallyNormal)
        with self.assertRaises(LookupError):
            apps.get_model("apps", "SoAlternative")

        with self.assertRaises(LookupError):
            new_apps.get_model("apps", "TotallyNormal")
        self.assertEqual(new_apps.get_model("apps", "SoAlternative"), SoAlternative)

    def test_models_not_loaded(self):
        """
        apps.get_models() raises an exception if apps.models_ready isn't True.
        """
        apps.models_ready = False
        try:
            # The cache must be cleared to trigger the exception.
            apps.get_models.cache_clear()
            with self.assertRaisesMessage(
                AppRegistryNotReady, "Models aren't loaded yet."
            ):
                apps.get_models()
        finally:
            apps.models_ready = True

    def test_dynamic_load(self):
        """
        Makes a new model at runtime and ensures it goes into the right place.
        """
        old_models = list(apps.get_app_config("apps").get_models())
        # Construct a new model in a new app registry
        body = {}
        new_apps = Apps(["apps"])
        meta_contents = {
            "app_label": "apps",
            "apps": new_apps,
        }
        meta = type("Meta", (), meta_contents)
        body["Meta"] = meta
        body["__module__"] = TotallyNormal.__module__
        temp_model = type("SouthPonies", (models.Model,), body)
        # Make sure it appeared in the right place!
        self.assertEqual(list(apps.get_app_config("apps").get_models()), old_models)
        with self.assertRaises(LookupError):
            apps.get_model("apps", "SouthPonies")
        self.assertEqual(new_apps.get_model("apps", "SouthPonies"), temp_model)

    def test_model_clash(self):
        """
        Test for behavior when two models clash in the app registry.
        """
        new_apps = Apps(["apps"])
        meta_contents = {
            "app_label": "apps",
            "apps": new_apps,
        }

        body = {}
        body["Meta"] = type("Meta", (), meta_contents)
        body["__module__"] = TotallyNormal.__module__
        type("SouthPonies", (models.Model,), body)

        # When __name__ and __module__ match we assume the module
        # was reloaded and issue a warning. This use-case is
        # useful for REPL. Refs #23621.
        body = {}
        body["Meta"] = type("Meta", (), meta_contents)
        body["__module__"] = TotallyNormal.__module__
        msg = (
            "Model 'apps.southponies' was already registered. "
            "Reloading models is not advised as it can lead to inconsistencies, "

[230 more lines in /testbed/tests/apps/tests.py (530 in all). read_file with offset: 301 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '301,530p' tests/apps/tests.py; echo ----; grep -n \"class .*Models\\|swappable\\|SoAlternative\\|class .*TestCase\\|def setUp\" tests/apps/tests.py tests/apps/models.py"
}
```

**tool result**

```
            "most notably with related models."
        )
        with self.assertRaisesMessage(RuntimeWarning, msg):
            type("SouthPonies", (models.Model,), body)

        # If it doesn't appear to be a reloaded module then we expect
        # a RuntimeError.
        body = {}
        body["Meta"] = type("Meta", (), meta_contents)
        body["__module__"] = TotallyNormal.__module__ + ".whatever"
        with self.assertRaisesMessage(
            RuntimeError, "Conflicting 'southponies' models in application 'apps':"
        ):
            type("SouthPonies", (models.Model,), body)

    def test_get_containing_app_config_apps_not_ready(self):
        """
        apps.get_containing_app_config() should raise an exception if
        apps.apps_ready isn't True.
        """
        apps.apps_ready = False
        try:
            with self.assertRaisesMessage(
                AppRegistryNotReady, "Apps aren't loaded yet"
            ):
                apps.get_containing_app_config("foo")
        finally:
            apps.apps_ready = True

    @isolate_apps("apps", kwarg_name="apps")
    def test_lazy_model_operation(self, apps):
        """
        Tests apps.lazy_model_operation().
        """
        model_classes = []
        initial_pending = set(apps._pending_operations)

        def test_func(*models):
            model_classes[:] = models

        class LazyA(models.Model):
            pass

        # Test models appearing twice, and models appearing consecutively
        model_keys = [
            ("apps", model_name)
            for model_name in ["lazya", "lazyb", "lazyb", "lazyc", "lazya"]
        ]
        apps.lazy_model_operation(test_func, *model_keys)

        # LazyModelA shouldn't be waited on since it's already registered,
        # and LazyModelC shouldn't be waited on until LazyModelB exists.
        self.assertEqual(
            set(apps._pending_operations) - initial_pending, {("apps", "lazyb")}
        )

        # Multiple operations can wait on the same model
        apps.lazy_model_operation(test_func, ("apps", "lazyb"))

        class LazyB(models.Model):
            pass

        self.assertEqual(model_classes, [LazyB])

        # Now we are just waiting on LazyModelC.
        self.assertEqual(
            set(apps._pending_operations) - initial_pending, {("apps", "lazyc")}
        )

        class LazyC(models.Model):
            pass

        # Everything should be loaded - make sure the callback was executed properly.
        self.assertEqual(model_classes, [LazyA, LazyB, LazyB, LazyC, LazyA])


class Stub:
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)


class AppConfigTests(SimpleTestCase):
    """Unit tests for AppConfig class."""

    def test_path_set_explicitly(self):
        """If subclass sets path as class attr, no module attributes needed."""

        class MyAppConfig(AppConfig):
            path = "foo"

        ac = MyAppConfig("label", Stub())

        self.assertEqual(ac.path, "foo")

    def test_explicit_path_overrides(self):
        """If path set as class attr, overrides __path__ and __file__."""

        class MyAppConfig(AppConfig):
            path = "foo"

        ac = MyAppConfig("label", Stub(__path__=["a"], __file__="b/__init__.py"))

        self.assertEqual(ac.path, "foo")

    def test_dunder_path(self):
        """If single element in __path__, use it (in preference to __file__)."""
        ac = AppConfig("label", Stub(__path__=["a"], __file__="b/__init__.py"))

        self.assertEqual(ac.path, "a")

    def test_no_dunder_path_fallback_to_dunder_file(self):
        """If there is no __path__ attr, use __file__."""
        ac = AppConfig("label", Stub(__file__="b/__init__.py"))

        self.assertEqual(ac.path, "b")

    def test_empty_dunder_path_fallback_to_dunder_file(self):
        """If the __path__ attr is empty, use __file__ if set."""
        ac = AppConfig("label", Stub(__path__=[], __file__="b/__init__.py"))

        self.assertEqual(ac.path, "b")

    def test_multiple_dunder_path_fallback_to_dunder_file(self):
        """If the __path__ attr is length>1, use __file__ if set."""
        ac = AppConfig("label", Stub(__path__=["a", "b"], __file__="c/__init__.py"))

        self.assertEqual(ac.path, "c")

    def test_no_dunder_path_or_dunder_file(self):
        """If there is no __path__ or __file__, raise ImproperlyConfigured."""
        with self.assertRaises(ImproperlyConfigured):
            AppConfig("label", Stub())

    def test_empty_dunder_path_no_dunder_file(self):
        """If the __path__ attr is empty and there is no __file__, raise."""
        with self.assertRaises(ImproperlyConfigured):
            AppConfig("label", Stub(__path__=[]))

    def test_multiple_dunder_path_no_dunder_file(self):
        """If the __path__ attr is length>1 and there is no __file__, raise."""
        with self.assertRaises(ImproperlyConfigured):
            AppConfig("label", Stub(__path__=["a", "b"]))

    def test_duplicate_dunder_path_no_dunder_file(self):
        """
        If the __path__ attr contains duplicate paths and there is no
        __file__, they duplicates should be deduplicated (#25246).
        """
        ac = AppConfig("label", Stub(__path__=["a", "a"]))
        self.assertEqual(ac.path, "a")

    def test_repr(self):
        ac = AppConfig("label", Stub(__path__=["a"]))
        self.assertEqual(repr(ac), "<AppConfig: label>")

    def test_invalid_label(self):
        class MyAppConfig(AppConfig):
            label = "invalid.label"

        msg = "The app label 'invalid.label' is not a valid Python identifier."
        with self.assertRaisesMessage(ImproperlyConfigured, msg):
            MyAppConfig("test_app", Stub())

    @override_settings(
        INSTALLED_APPS=["apps.apps.ModelPKAppsConfig"],
        DEFAULT_AUTO_FIELD="django.db.models.SmallAutoField",
    )
    def test_app_default_auto_field(self):
        apps_config = apps.get_app_config("apps")
        self.assertEqual(
            apps_config.default_auto_field,
            "django.db.models.BigAutoField",
        )
        self.assertIs(apps_config._is_default_auto_field_overridden, True)

    @override_settings(
        INSTALLED_APPS=["apps.apps.PlainAppsConfig"],
        DEFAULT_AUTO_FIELD="django.db.models.SmallAutoField",
    )
    def test_default_auto_field_setting(self):
        apps_config = apps.get_app_config("apps")
        self.assertEqual(
            apps_config.default_auto_field,
            "django.db.models.SmallAutoField",
        )
        self.assertIs(apps_config._is_default_auto_field_overridden, False)


class NamespacePackageAppTests(SimpleTestCase):
    # We need nsapp to be top-level so our multiple-paths tests can add another
    # location for it (if its inside a normal package with an __init__.py that
    # isn't possible). In order to avoid cluttering the already-full tests/ dir
    # (which is on sys.path), we add these new entries to sys.path temporarily.
    base_location = os.path.join(HERE, "namespace_package_base")
    other_location = os.path.join(HERE, "namespace_package_other_base")
    app_path = os.path.join(base_location, "nsapp")

    def test_single_path(self):
        """
        A Py3.3+ namespace package can be an app if it has only one path.
        """
        with extend_sys_path(self.base_location):
            with self.settings(INSTALLED_APPS=["nsapp"]):
                app_config = apps.get_app_config("nsapp")
                self.assertEqual(app_config.path, self.app_path)

    def test_multiple_paths(self):
        """
        A Py3.3+ namespace package with multiple locations cannot be an app.

        (Because then we wouldn't know where to load its templates, static
        assets, etc. from.)
        """
        # Temporarily add two directories to sys.path that both contain
        # components of the "nsapp" package.
        with extend_sys_path(self.base_location, self.other_location):
            with self.assertRaises(ImproperlyConfigured):
                with self.settings(INSTALLED_APPS=["nsapp"]):
                    pass

    def test_multiple_paths_explicit_path(self):
        """
        Multiple locations are ok only if app-config has explicit path.
        """
        # Temporarily add two directories to sys.path that both contain
        # components of the "nsapp" package.
        with extend_sys_path(self.base_location, self.other_location):
            with self.settings(INSTALLED_APPS=["nsapp.apps.NSAppConfig"]):
                app_config = apps.get_app_config("nsapp")
                self.assertEqual(app_config.path, self.app_path)
----
tests/apps/tests.py:11:from .models import SoAlternative, TotallyNormal, new_apps
tests/apps/tests.py:35:class AppsTests(SimpleTestCase):
tests/apps/tests.py:234:            apps.get_model("apps", "SoAlternative")
tests/apps/tests.py:238:        self.assertEqual(new_apps.get_model("apps", "SoAlternative"), SoAlternative)
tests/apps/tests.py:382:class AppConfigTests(SimpleTestCase):
tests/apps/tests.py:489:class NamespacePackageAppTests(SimpleTestCase):
tests/apps/models.py:13:class SoAlternative(models.Model):
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/apps/models.py"
}
```

**tool result**

```
from django.apps.registry import Apps
from django.db import models

# We're testing app registry presence on load, so this is handy.

new_apps = Apps(["apps"])


class TotallyNormal(models.Model):
    name = models.CharField(max_length=255)


class SoAlternative(models.Model):
    name = models.CharField(max_length=255)

    class Meta:
        apps = new_apps
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"from unittest\\|import mock\" tests/apps/tests.py; grep -n \"get_swappable_settings_name\" django/apps/registry.py"
}
```

**tool result**

```
284:    def get_swappable_settings_name(self, to_string):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/apps/registry.py\n@@\n         # Call expire cache on each model. This will purge\n         # the relation tree and the fields cache.\n         self.get_models.cache_clear()\n+        self.get_swappable_settings_name.cache_clear()\n         if self.ready:\n*** Update File: tests/apps/tests.py\n@@\n     def test_models_not_loaded(self):\n         \"\"\"\n         apps.get_models() raises an exception if apps.models_ready isn't True.\n         \"\"\"\n@@\n         finally:\n             apps.models_ready = True\n \n+    def test_clear_cache_clears_swappable_settings_name_cache(self):\n+        apps.get_swappable_settings_name.cache_clear()\n+        apps.get_swappable_settings_name(\"apps.totallynormal\")\n+        self.assertGreater(\n+            apps.get_swappable_settings_name.cache_info().currsize, 0\n+        )\n+        apps.clear_cache()\n+        self.assertEqual(apps.get_swappable_settings_name.cache_info().currsize, 0)\n+\n     def test_dynamic_load(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/apps/registry.py tests/apps/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/apps/registry.py now (437 lines), around the change:
376:        # Call expire cache on each model. This will purge
377:        # the relation tree and the fields cache.
378:        self.get_models.cache_clear()
379:        self.get_swappable_settings_name.cache_clear()
380:        if self.ready:
381:            # Circumvent self.get_models() to prevent that the cache is refilled.
382:            # This particularly prevents that an empty value is cached while cloning.

tests/apps/tests.py now (539 lines), around the change:
251:                apps.get_models()
252:        finally:
253:            apps.models_ready = True
254:
255:    def test_clear_cache_clears_swappable_settings_name_cache(self):
256:        apps.get_swappable_settings_name.cache_clear()
257:        apps.get_swappable_settings_name("apps.totallynormal")
258:        self.assertGreater(
259:            apps.get_swappable_settings_name.cache_info().currsize, 0
260:        )
261:        apps.clear_cache()
262:        self.assertEqual(apps.get_swappable_settings_name.cache_info().currsize, 0)
263:
264:    def test_dynamic_load(self):
265:        """
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py apps.tests.AppsTests.test_clear_cache_clears_swappable_settings_name_cache --verbosity 2 2>&1 | tail -30"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application apps
Found 1 test(s).
Skipping setup of unused database(s): default, other.
System check identified no issues (0 silenced).
test_clear_cache_clears_swappable_settings_name_cache (apps.tests.AppsTests.test_clear_cache_clears_swappable_settings_name_cache) ... ok

----------------------------------------------------------------------
Ran 1 test in 0.001s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py apps model_meta --verbosity 1 2>&1 | tail -15 && git status --porcelain -- . ':(exclude).memdoor'"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 70 test(s).
System check identified no issues (0 silenced).
......................................................................
----------------------------------------------------------------------
Ran 70 tests in 0.067s

OK
 M django/apps/registry.py
 M tests/apps/tests.py
```

**assistant → tool `bash`**

```json
{
  "command": "python -m black --check django/apps/registry.py tests/apps/tests.py 2>&1 | tail -5"
}
```

**tool result**

```
would reformat tests/apps/tests.py

Oh no! 💥 💔 💥
1 file would be reformatted, 1 file would be left unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "python -m black tests/apps/tests.py && git diff --stat && python tests/runtests.py apps --verbosity 0 2>&1 | tail -5"
}
```

**tool result**

```
reformatted tests/apps/tests.py

All done! ✨ 🍰 ✨
1 file reformatted.
 django/apps/registry.py | 1 +
 tests/apps/tests.py     | 7 +++++++
 2 files changed, 8 insertions(+)
System check identified no issues (0 silenced).
----------------------------------------------------------------------
Ran 44 tests in 0.049s

OK
```

**assistant**

```
Done.

- `django/apps/registry.py`: `clear_cache()` now calls `self.get_swappable_settings_name.cache_clear()` alongside `get_models.cache_clear()`.
- `tests/apps/tests.py`: added a regression test verifying the swappable settings name cache is populated before `clear_cache()` and empty after.

Verified the new test and the full `apps`/`model_meta` suites pass (70 tests), formatting is clean, and `git status` shows the changes.
```

## Run folder `single-2026-11-06T113118`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Apps.clear_cache() does not clear get_swappable_settings_name cache.
Description
	
We use apps.clear_cache() in django-stubs to be able to reset the previous state on consequential mypy runs.
Code: ​https://github.com/typeddjango/django-stubs/pull/1601/files#diff-c49d8fe2cd0a58fad3c36ab3a88c7745e9622f3098e60cd512953eb17b8a1994R63-R64
But, looks like we don't clear all the object's cache this way, because get_swappable_settings_name (which is a functools._lru_cache_wrapper) is not cleared.
I think that this is not correct. .clear_cache doc states: Clear all internal caches, for methods that alter the app registry.
Looks like that is not the case.
I propose to add: self.get_swappable_settings_name.cache_clear() line to def clear_cache.
If others agree, I will make a PR.
Original discussion: ​https://github.com/typeddjango/django-stubs/pull/1601#discussion_r1246344533
```
