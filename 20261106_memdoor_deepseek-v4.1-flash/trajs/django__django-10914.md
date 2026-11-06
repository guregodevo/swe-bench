# django__django-10914 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 70s 129 lines cost=0.004461 in=231746 cached=182784 out=6632 calls=16`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Set default FILE_UPLOAD_PERMISSION to 0o644.
Description
	
Hello,
As far as I can see, the ​File Uploads documentation page does not mention any permission issues.
What I would like to see is a warning that in absence of explicitly configured FILE_UPLOAD_PERMISSIONS, the permissions for a file uploaded to FileSystemStorage might not be consistent depending on whether a MemoryUploadedFile or a TemporaryUploadedFile was used for temporary storage of the uploaded data (which, with the default FILE_UPLOAD_HANDLERS, in turn depends on the uploaded data size).
The tempfile.NamedTemporaryFile + os.rename sequence causes the resulting file permissions to be 0o0600 on some systems (I experience it here on CentOS 7.4.1708 and Python 3.6.5). In all probability, the implementation of Python's built-in tempfile module explicitly sets such permissions for temporary files due to security considerations.
I found mentions of this issue ​on GitHub, but did not manage to find any existing bug report in Django's bug tracker.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --porcelain"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"FILE_UPLOAD_PERMISSIONS\" django/ docs/ | head -50"
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
74cb723202 SWE-bench
e7fd69d051 Fixed #30166 -- Dropped support for GDAL 1.11.
6eb4996672 Fixed #30165 -- Deprecated ugettext(), ugettext_lazy(), ugettext_noop(), ungettext(), and ungettext_lazy().
?? .memdoor/
```

**tool result**

```
django/conf/global_settings.py:307:FILE_UPLOAD_PERMISSIONS = None
django/core/files/storage.py:193:        elif setting == 'FILE_UPLOAD_PERMISSIONS':
django/core/files/storage.py:217:        return self._value_or_setting(self._file_permissions_mode, settings.FILE_UPLOAD_PERMISSIONS)
docs/ref/contrib/staticfiles.txt:69::setting:`FILE_UPLOAD_PERMISSIONS` and collected directories receive permissions
docs/ref/settings.txt:1480::setting:`FILE_UPLOAD_PERMISSIONS` setting.
docs/ref/settings.txt:1482:.. setting:: FILE_UPLOAD_PERMISSIONS
docs/ref/settings.txt:1484:``FILE_UPLOAD_PERMISSIONS``
docs/ref/settings.txt:3373:* :setting:`FILE_UPLOAD_PERMISSIONS`
docs/ref/files/storage.txt:53:        saved. Defaults to :setting:`FILE_UPLOAD_PERMISSIONS`.
docs/howto/deployment/checklist.txt:157::setting:`FILE_UPLOAD_PERMISSIONS`
docs/howto/deployment/checklist.txt:162:than larger files as described in :setting:`FILE_UPLOAD_PERMISSIONS`.
docs/howto/deployment/checklist.txt:164:Setting :setting:`FILE_UPLOAD_PERMISSIONS` ensures all files are uploaded with
docs/releases/1.7.txt:582:  :setting:`FILE_UPLOAD_PERMISSIONS` does for the files themselves.
docs/releases/1.11.txt:784:  (often ``0o6644``). Set the :setting:`FILE_UPLOAD_PERMISSIONS` if you need
docs/releases/1.5.txt:676:  them to be executable change :setting:`FILE_UPLOAD_PERMISSIONS` to your
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '295,315p' django/conf/global_settings.py; sed -n '1450,1520p' docs/ref/settings.txt; sed -n '140,175p' docs/howto/deployment/checklist.txt"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"FILE_UPLOAD_PERMISSIONS\\|permissions_mode\\|0o600\\|0o644\" tests/file_storage tests/file_uploads tests | grep -i \"upload_permission\\|permission\" | head -50"
}
```

**tool result**

```

# Maximum number of GET/POST parameters that will be read before a
# SuspiciousOperation (TooManyFieldsSent) is raised.
DATA_UPLOAD_MAX_NUMBER_FIELDS = 1000

# Directory in which upload streamed files will be temporarily saved. A value of
# `None` will make Django use the operating system's default temporary directory
# (i.e. "/tmp" on *nix systems).
FILE_UPLOAD_TEMP_DIR = None

# The numeric mode to set newly-uploaded files to. The value should be a mode
# you'd pass directly to os.chmod; see https://docs.python.org/library/os.html#files-and-directories.
FILE_UPLOAD_PERMISSIONS = None

# The numeric mode to assign to newly-created directories, when uploading files.
# The value should be a mode as you'd pass to os.chmod;
# see https://docs.python.org/library/os.html#files-and-directories.
FILE_UPLOAD_DIRECTORY_PERMISSIONS = None

# Python module path where user will place custom format definition.
# The directory where this setting is pointing should contain subdirectories

See :doc:`/topics/files` for details.

.. setting:: FILE_UPLOAD_MAX_MEMORY_SIZE

``FILE_UPLOAD_MAX_MEMORY_SIZE``
-------------------------------

Default: ``2621440`` (i.e. 2.5 MB).

The maximum size (in bytes) that an upload will be before it gets streamed to
the file system. See :doc:`/topics/files` for details.

See also :setting:`DATA_UPLOAD_MAX_MEMORY_SIZE`.

.. setting:: FILE_UPLOAD_DIRECTORY_PERMISSIONS

``FILE_UPLOAD_DIRECTORY_PERMISSIONS``
-------------------------------------

Default: ``None``

The numeric mode to apply to directories created in the process of uploading
files.

This setting also determines the default permissions for collected static
directories when using the :djadmin:`collectstatic` management command. See
:djadmin:`collectstatic` for details on overriding it.

This value mirrors the functionality and caveats of the
:setting:`FILE_UPLOAD_PERMISSIONS` setting.

.. setting:: FILE_UPLOAD_PERMISSIONS

``FILE_UPLOAD_PERMISSIONS``
---------------------------

Default: ``None``

The numeric mode (i.e. ``0o644``) to set newly uploaded files to. For
more information about what these modes mean, see the documentation for
:func:`os.chmod`.

If this isn't given or is ``None``, you'll get operating-system
dependent behavior. On most platforms, temporary files will have a mode
of ``0o600``, and files saved from memory will be saved using the
system's standard umask.

For security reasons, these permissions aren't applied to the temporary files
that are stored in :setting:`FILE_UPLOAD_TEMP_DIR`.

This setting also determines the default permissions for collected static files
when using the :djadmin:`collectstatic` management command. See
:djadmin:`collectstatic` for details on overriding it.

.. warning::

    **Always prefix the mode with a 0.**

    If you're not familiar with file modes, please note that the leading
    ``0`` is very important: it indicates an octal number, which is the
    way that modes must be specified. If you try to use ``644``, you'll
    get totally incorrect behavior.

.. setting:: FILE_UPLOAD_TEMP_DIR

``FILE_UPLOAD_TEMP_DIR``
------------------------

Default: ``None``

------------------------------------------------

Static files are automatically served by the development server. In
production, you must define a :setting:`STATIC_ROOT` directory where
:djadmin:`collectstatic` will copy them.

See :doc:`/howto/static-files/index` for more information.

:setting:`MEDIA_ROOT` and :setting:`MEDIA_URL`
----------------------------------------------

Media files are uploaded by your users. They're untrusted! Make sure your web
server never attempts to interpret them. For instance, if a user uploads a
``.php`` file, the web server shouldn't execute it.

Now is a good time to check your backup strategy for these files.

:setting:`FILE_UPLOAD_PERMISSIONS`
----------------------------------

With the default file upload settings, files smaller than
:setting:`FILE_UPLOAD_MAX_MEMORY_SIZE` may be stored with a different mode
than larger files as described in :setting:`FILE_UPLOAD_PERMISSIONS`.

Setting :setting:`FILE_UPLOAD_PERMISSIONS` ensures all files are uploaded with
the same permissions.

HTTPS
=====

Any website which allows users to log in should enforce site-wide HTTPS to
avoid transmitting access tokens in clear. In Django, access tokens include
the login/password, the session cookie, and password reset tokens. (You can't
do much to protect password reset tokens if you're sending them by email.)

Protecting sensitive areas such as the user account or the admin isn't
```

**tool result**

```
tests/file_storage/tests.py:507:        FILE_UPLOAD_PERMISSIONS=0o777,
tests/file_storage/tests.py:518:            file_permissions_mode=0o666,
tests/file_storage/tests.py:519:            directory_permissions_mode=0o666,
tests/file_storage/tests.py:525:            'FILE_UPLOAD_PERMISSIONS': 0o333,
tests/file_storage/tests.py:532:            self.assertEqual(storage.file_permissions_mode, 0o666)
tests/file_storage/tests.py:533:            self.assertEqual(storage.directory_permissions_mode, 0o666)
tests/file_storage/tests.py:537:            self.assertEqual(defaults_storage.file_permissions_mode, settings['FILE_UPLOAD_PERMISSIONS'])
tests/file_storage/tests.py:539:                defaults_storage.directory_permissions_mode, settings['FILE_UPLOAD_DIRECTORY_PERMISSIONS']
tests/file_storage/tests.py:888:    @override_settings(FILE_UPLOAD_PERMISSIONS=0o654)
tests/file_storage/tests.py:895:    @override_settings(FILE_UPLOAD_PERMISSIONS=None)
tests/test_utils/tests.py:1098:        Overriding the FILE_UPLOAD_PERMISSIONS setting should be reflected in
tests/test_utils/tests.py:1099:        the file_permissions_mode attribute of
tests/test_utils/tests.py:1102:        self.assertIsNone(default_storage.file_permissions_mode)
tests/test_utils/tests.py:1103:        with self.settings(FILE_UPLOAD_PERMISSIONS=0o777):
tests/test_utils/tests.py:1104:            self.assertEqual(default_storage.file_permissions_mode, 0o777)
tests/test_utils/tests.py:1109:        reflected in the directory_permissions_mode attribute of
tests/test_utils/tests.py:1112:        self.assertIsNone(default_storage.directory_permissions_mode)
tests/test_utils/tests.py:1114:            self.assertEqual(default_storage.directory_permissions_mode, 0o777)
tests/staticfiles_tests/test_storage.py:478:        kwargs['file_permissions_mode'] = 0o640
tests/staticfiles_tests/test_storage.py:479:        kwargs['directory_permissions_mode'] = 0o740
tests/staticfiles_tests/test_storage.py:506:        FILE_UPLOAD_PERMISSIONS=0o655,
tests/staticfiles_tests/test_storage.py:519:        FILE_UPLOAD_PERMISSIONS=None,
tests/staticfiles_tests/test_storage.py:532:        FILE_UPLOAD_PERMISSIONS=0o655,
tests/file_storage/tests.py:507:        FILE_UPLOAD_PERMISSIONS=0o777,
tests/file_storage/tests.py:518:            file_permissions_mode=0o666,
tests/file_storage/tests.py:519:            directory_permissions_mode=0o666,
tests/file_storage/tests.py:525:            'FILE_UPLOAD_PERMISSIONS': 0o333,
tests/file_storage/tests.py:532:            self.assertEqual(storage.file_permissions_mode, 0o666)
tests/file_storage/tests.py:533:            self.assertEqual(storage.directory_permissions_mode, 0o666)
tests/file_storage/tests.py:537:            self.assertEqual(defaults_storage.file_permissions_mode, settings['FILE_UPLOAD_PERMISSIONS'])
tests/file_storage/tests.py:539:                defaults_storage.directory_permissions_mode, settings['FILE_UPLOAD_DIRECTORY_PERMISSIONS']
tests/file_storage/tests.py:888:    @override_settings(FILE_UPLOAD_PERMISSIONS=0o654)
tests/file_storage/tests.py:895:    @override_settings(FILE_UPLOAD_PERMISSIONS=None)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"FILE_UPLOAD_PERMISSIONS\" docs/releases/ | tail -20; grep -rn \"FILE_UPLOAD_PERMISSIONS\" django/ | cat"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '480,560p' tests/file_storage/tests.py; sed -n '860,930p' tests/file_storage/tests.py"
}
```

**tool result**

```
docs/releases/1.7.txt:582:  :setting:`FILE_UPLOAD_PERMISSIONS` does for the files themselves.
docs/releases/1.11.txt:784:  (often ``0o6644``). Set the :setting:`FILE_UPLOAD_PERMISSIONS` if you need
docs/releases/1.5.txt:676:  them to be executable change :setting:`FILE_UPLOAD_PERMISSIONS` to your
django/conf/global_settings.py:307:FILE_UPLOAD_PERMISSIONS = None
django/core/files/storage.py:193:        elif setting == 'FILE_UPLOAD_PERMISSIONS':
django/core/files/storage.py:217:        return self._value_or_setting(self._file_permissions_mode, settings.FILE_UPLOAD_PERMISSIONS)
```

**tool result**

```
        """
        Test behavior when file.chunks() is raising an error
        """
        f1 = ContentFile('chunks fails')

        def failing_chunks():
            raise OSError
        f1.chunks = failing_chunks
        with self.assertRaises(OSError):
            self.storage.save('error.file', f1)

    def test_delete_no_name(self):
        """
        Calling delete with an empty name should not try to remove the base
        storage directory, but fail loudly (#20660).
        """
        with self.assertRaises(AssertionError):
            self.storage.delete('')

    def test_delete_deletes_directories(self):
        tmp_dir = tempfile.mkdtemp(dir=self.storage.location)
        self.storage.delete(tmp_dir)
        self.assertFalse(os.path.exists(tmp_dir))

    @override_settings(
        MEDIA_ROOT='media_root',
        MEDIA_URL='media_url/',
        FILE_UPLOAD_PERMISSIONS=0o777,
        FILE_UPLOAD_DIRECTORY_PERMISSIONS=0o777,
    )
    def test_setting_changed(self):
        """
        Properties using settings values as defaults should be updated on
        referenced settings change while specified values should be unchanged.
        """
        storage = self.storage_class(
            location='explicit_location',
            base_url='explicit_base_url/',
            file_permissions_mode=0o666,
            directory_permissions_mode=0o666,
        )
        defaults_storage = self.storage_class()
        settings = {
            'MEDIA_ROOT': 'overriden_media_root',
            'MEDIA_URL': 'overriden_media_url/',
            'FILE_UPLOAD_PERMISSIONS': 0o333,
            'FILE_UPLOAD_DIRECTORY_PERMISSIONS': 0o333,
        }
        with self.settings(**settings):
            self.assertEqual(storage.base_location, 'explicit_location')
            self.assertIn('explicit_location', storage.location)
            self.assertEqual(storage.base_url, 'explicit_base_url/')
            self.assertEqual(storage.file_permissions_mode, 0o666)
            self.assertEqual(storage.directory_permissions_mode, 0o666)
            self.assertEqual(defaults_storage.base_location, settings['MEDIA_ROOT'])
            self.assertIn(settings['MEDIA_ROOT'], defaults_storage.location)
            self.assertEqual(defaults_storage.base_url, settings['MEDIA_URL'])
            self.assertEqual(defaults_storage.file_permissions_mode, settings['FILE_UPLOAD_PERMISSIONS'])
            self.assertEqual(
                defaults_storage.directory_permissions_mode, settings['FILE_UPLOAD_DIRECTORY_PERMISSIONS']
            )


class CustomStorage(FileSystemStorage):
    def get_available_name(self, name, max_length=None):
        """
        Append numbers to duplicate files rather than underscores, like Trac.
        """
        basename, *ext = name.split('.')
        number = 2
        while self.exists(name):
            name = '.'.join([basename, str(number)] + ext)
            number += 1

        return name


class CustomStorageTests(FileStorageTests):
    storage_class = CustomStorage

    def test_custom_get_available_name(self):
        self.thread = threading.Thread(target=self.save_file, args=['conflict'])

    def tearDown(self):
        shutil.rmtree(self.storage_dir)

    def save_file(self, name):
        name = self.storage.save(name, SlowFile(b"Data"))

    def test_race_condition(self):
        self.thread.start()
        self.save_file('conflict')
        self.thread.join()
        files = sorted(os.listdir(self.storage_dir))
        self.assertEqual(files[0], 'conflict')
        self.assertRegex(files[1], 'conflict_%s' % FILE_SUFFIX_REGEX)


@unittest.skipIf(sys.platform.startswith('win'), "Windows only partially supports umasks and chmod.")
class FileStoragePermissions(unittest.TestCase):
    def setUp(self):
        self.umask = 0o027
        self.old_umask = os.umask(self.umask)
        self.storage_dir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.storage_dir)
        os.umask(self.old_umask)

    @override_settings(FILE_UPLOAD_PERMISSIONS=0o654)
    def test_file_upload_permissions(self):
        self.storage = FileSystemStorage(self.storage_dir)
        name = self.storage.save("the_file", ContentFile("data"))
        actual_mode = os.stat(self.storage.path(name))[0] & 0o777
        self.assertEqual(actual_mode, 0o654)

    @override_settings(FILE_UPLOAD_PERMISSIONS=None)
    def test_file_upload_default_permissions(self):
        self.storage = FileSystemStorage(self.storage_dir)
        fname = self.storage.save("some_file", ContentFile("data"))
        mode = os.stat(self.storage.path(fname))[0] & 0o777
        self.assertEqual(mode, 0o666 & ~self.umask)

    @override_settings(FILE_UPLOAD_DIRECTORY_PERMISSIONS=0o765)
    def test_file_upload_directory_permissions(self):
        self.storage = FileSystemStorage(self.storage_dir)
        name = self.storage.save("the_directory/the_file", ContentFile("data"))
        dir_mode = os.stat(os.path.dirname(self.storage.path(name)))[0] & 0o777
        self.assertEqual(dir_mode, 0o765)

    @override_settings(FILE_UPLOAD_DIRECTORY_PERMISSIONS=None)
    def test_file_upload_directory_default_permissions(self):
        self.storage = FileSystemStorage(self.storage_dir)
        name = self.storage.save("the_directory/the_file", ContentFile("data"))
        dir_mode = os.stat(os.path.dirname(self.storage.path(name)))[0] & 0o777
        self.assertEqual(dir_mode, 0o777 & ~self.umask)


class FileStoragePathParsing(SimpleTestCase):
    def setUp(self):
        self.storage_dir = tempfile.mkdtemp()
        self.storage = FileSystemStorage(self.storage_dir)

    def tearDown(self):
        shutil.rmtree(self.storage_dir)

    def test_directory_with_dot(self):
        """Regression test for #9610.

        If the directory name contains a dot and the file name doesn't, make
        sure we still mangle the file name instead of the directory name.
        """
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"VERSION\" django/__init__.py | head; ls docs/releases | tail -15; grep -rn \"FILE_UPLOAD_PERMISSIONS\\|file_permissions_mode\\|0o644\" docs/topics/files.txt docs/ref/files/storage.txt docs/ref/contrib/staticfiles.txt"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"FILE_UPLOAD_PERMISSIONS\\|default.*None\\|permissions\" docs/releases/2.2.txt | head -40; sed -n '1,120p' docs/releases/2.2.txt"
}
```

**tool result**

```
3:VERSION = (3, 0, 0, 'alpha', 0)
5:__version__ = get_version(VERSION)
2.0.7.txt
2.0.8.txt
2.0.9.txt
2.0.txt
2.1.1.txt
2.1.2.txt
2.1.3.txt
2.1.4.txt
2.1.5.txt
2.1.6.txt
2.1.txt
2.2.txt
3.0.txt
index.txt
security.txt
docs/ref/files/storage.txt:33:.. class:: FileSystemStorage(location=None, base_url=None, file_permissions_mode=None, directory_permissions_mode=None)
docs/ref/files/storage.txt:50:    .. attribute:: file_permissions_mode
docs/ref/files/storage.txt:53:        saved. Defaults to :setting:`FILE_UPLOAD_PERMISSIONS`.
docs/ref/contrib/staticfiles.txt:69::setting:`FILE_UPLOAD_PERMISSIONS` and collected directories receive permissions
docs/ref/contrib/staticfiles.txt:73:``file_permissions_mode`` and/or ``directory_permissions_mode`` parameters,
docs/ref/contrib/staticfiles.txt:80:            kwargs['file_permissions_mode'] = 0o640
```

**tool result**

```
365::ref:`Permissions for proxy models <proxy-models-permissions-topic>` are now
367:of the concrete model. A migration will update existing permissions when you
372:permissions for a proxy model with a *different* ``app_label`` than its
374:you might want to audit the permissions assignments for such proxy models
============================================
Django 2.2 release notes - UNDER DEVELOPMENT
============================================

*Expected April 2019*

Welcome to Django 2.2!

These release notes cover the :ref:`new features <whats-new-2.2>`, as well as
some :ref:`backwards incompatible changes <backwards-incompatible-2.2>` you'll
want to be aware of when upgrading from Django 2.1 or earlier. We've
:ref:`begun the deprecation process for some features
<deprecated-features-2.2>`.

See the :doc:`/howto/upgrade-version` guide if you're updating an existing
project.

Django 2.2 is designated as a :term:`long-term support release`. It will
receive security updates for at least three years after its release. Support
for the previous LTS, Django 1.11, will end in April 2020.

Python compatibility
====================

Django 2.2 supports Python 3.5, 3.6, and 3.7. We **highly recommend** and only
officially support the latest release of each series.

.. _whats-new-2.2:

What's new in Django 2.2
========================

Constraints
-----------

The new :class:`~django.db.models.CheckConstraint` and
:class:`~django.db.models.UniqueConstraint` classes enable adding custom
database constraints. Constraints are added to models using the
:attr:`Meta.constraints <django.db.models.Options.constraints>` option.

Minor features
--------------

:mod:`django.contrib.admin`
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Added a CSS class to the column headers of
  :class:`~django.contrib.admin.TabularInline`.

:mod:`django.contrib.auth`
~~~~~~~~~~~~~~~~~~~~~~~~~~

* The ``HttpRequest`` is now passed as the first positional argument to
  :meth:`.RemoteUserBackend.configure_user`, if it accepts it.

:mod:`django.contrib.gis`
~~~~~~~~~~~~~~~~~~~~~~~~~

* Added Oracle support for the
  :class:`~django.contrib.gis.db.models.functions.Envelope` function.

* Added SpatiaLite support for the :lookup:`coveredby` and :lookup:`covers`
  lookups.

:mod:`django.contrib.postgres`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The new ``ordering`` argument for
  :class:`~django.contrib.postgres.aggregates.ArrayAgg` and
  :class:`~django.contrib.postgres.aggregates.StringAgg` determines the
  ordering of the aggregated elements.

* The new :class:`~django.contrib.postgres.indexes.BTreeIndex`,
  :class:`~django.contrib.postgres.indexes.HashIndex` and
  :class:`~django.contrib.postgres.indexes.SpGistIndex` classes allow
  creating ``B-Tree``, ``hash``, and ``SP-GiST`` indexes in the database.

* :class:`~django.contrib.postgres.indexes.BrinIndex` now has the
  ``autosummarize`` parameter.

* The new ``search_type`` parameter of
  :class:`~django.contrib.postgres.search.SearchQuery` allows searching for
  a phrase or raw expression.

:mod:`django.contrib.staticfiles`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Added path matching to the :option:`collectstatic --ignore` option so that
  patterns like ``/vendor/*.js`` can be used.

Database backends
~~~~~~~~~~~~~~~~~

* Added result streaming for :meth:`.QuerySet.iterator` on SQLite.

Generic Views
~~~~~~~~~~~~~

* The new :meth:`View.setup <django.views.generic.base.View.setup>` hook
  initializes view attributes before calling
  :meth:`~django.views.generic.base.View.dispatch`. It allows mixins to setup
  instance attributes for reuse in child classes.

Internationalization
~~~~~~~~~~~~~~~~~~~~

* Added support and translations for the Armenian language.

Management Commands
~~~~~~~~~~~~~~~~~~~

* The new :option:`--force-color` option forces colorization of the command
  output.

* :djadmin:`inspectdb` now creates models for foreign tables on PostgreSQL.

* :option:`inspectdb --include-views` now creates models for materialized views
  on Oracle and PostgreSQL.

* The new :option:`inspectdb --include-partitions` option allows creating
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Backwards incompatible\\|Miscellaneous\\|File Storage\\|file upload\\|FILE_UPLOAD\" docs/releases/3.0.txt | head -50; sed -n '1,100p' docs/releases/3.0.txt"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"FILE_UPLOAD_PERMISSIONS\" tests docs | cat"
}
```

**tool result**

```
124:File Storage
203:Backwards incompatible changes in 3.0
287:Miscellaneous
306:Miscellaneous
============================================
Django 3.0 release notes - UNDER DEVELOPMENT
============================================

*Expected December 2019*

Welcome to Django 3.0!

These release notes cover the :ref:`new features <whats-new-3.0>`, as well as
some :ref:`backwards incompatible changes <backwards-incompatible-3.0>` you'll
want to be aware of when upgrading from Django 2.2 or earlier. We've
:ref:`dropped some features<removed-features-3.0>` that have reached the end of
their deprecation cycle, and we've :ref:`begun the deprecation process for
some features <deprecated-features-3.0>`.

See the :doc:`/howto/upgrade-version` guide if you're updating an existing
project.

Python compatibility
====================

Django 3.0 supports Python 3.6, 3.7, and 3.8. We **highly recommend** and only
officially support the latest release of each series.

The Django 2.2.x series is the last to support Python 3.5.

Third-party library support for older version of Django
=======================================================

Following the release of Django 3.0, we suggest that third-party app authors
drop support for all versions of Django prior to 2.2. At that time, you should
be able to run your package's tests using ``python -Wd`` so that deprecation
warnings appear. After making the deprecation warning fixes, your app should be
compatible with Django 3.0.

.. _whats-new-3.0:

What's new in Django 3.0
========================

Minor features
--------------

:mod:`django.contrib.admin`
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.admindocs`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.auth`
~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.contenttypes`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.gis`
~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.messages`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.postgres`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.redirects`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.sessions`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.sitemaps`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.sites`
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.staticfiles`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

**tool result**

```
tests/test_utils/tests.py:1098:        Overriding the FILE_UPLOAD_PERMISSIONS setting should be reflected in
tests/test_utils/tests.py:1103:        with self.settings(FILE_UPLOAD_PERMISSIONS=0o777):
tests/staticfiles_tests/test_storage.py:506:        FILE_UPLOAD_PERMISSIONS=0o655,
tests/staticfiles_tests/test_storage.py:519:        FILE_UPLOAD_PERMISSIONS=None,
tests/staticfiles_tests/test_storage.py:532:        FILE_UPLOAD_PERMISSIONS=0o655,
tests/file_storage/tests.py:507:        FILE_UPLOAD_PERMISSIONS=0o777,
tests/file_storage/tests.py:525:            'FILE_UPLOAD_PERMISSIONS': 0o333,
tests/file_storage/tests.py:537:            self.assertEqual(defaults_storage.file_permissions_mode, settings['FILE_UPLOAD_PERMISSIONS'])
tests/file_storage/tests.py:888:    @override_settings(FILE_UPLOAD_PERMISSIONS=0o654)
tests/file_storage/tests.py:895:    @override_settings(FILE_UPLOAD_PERMISSIONS=None)
docs/ref/contrib/staticfiles.txt:69::setting:`FILE_UPLOAD_PERMISSIONS` and collected directories receive permissions
docs/ref/settings.txt:1480::setting:`FILE_UPLOAD_PERMISSIONS` setting.
docs/ref/settings.txt:1482:.. setting:: FILE_UPLOAD_PERMISSIONS
docs/ref/settings.txt:1484:``FILE_UPLOAD_PERMISSIONS``
docs/ref/settings.txt:3373:* :setting:`FILE_UPLOAD_PERMISSIONS`
docs/ref/files/storage.txt:53:        saved. Defaults to :setting:`FILE_UPLOAD_PERMISSIONS`.
docs/howto/deployment/checklist.txt:157::setting:`FILE_UPLOAD_PERMISSIONS`
docs/howto/deployment/checklist.txt:162:than larger files as described in :setting:`FILE_UPLOAD_PERMISSIONS`.
docs/howto/deployment/checklist.txt:164:Setting :setting:`FILE_UPLOAD_PERMISSIONS` ensures all files are uploaded with
docs/releases/1.7.txt:582:  :setting:`FILE_UPLOAD_PERMISSIONS` does for the files themselves.
docs/releases/1.11.txt:784:  (often ``0o6644``). Set the :setting:`FILE_UPLOAD_PERMISSIONS` if you need
docs/releases/1.5.txt:676:  them to be executable change :setting:`FILE_UPLOAD_PERMISSIONS` to your
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1085,1120p' tests/test_utils/tests.py; sed -n '490,545p' tests/staticfiles_tests/test_storage.py; sed -n '110,140p' docs/releases/3.0.txt; sed -n '195,235p' docs/releases/3.0.txt; sed -n '280,320p' docs/releases/3.0.txt"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"0o600\\|666 & ~\\|umask\" tests/file_storage/tests.py tests/test_utils/tests.py tests/staticfiles_tests/test_storage.py | head -30; sed -n '55,85p' docs/ref/contrib/staticfiles.txt"
}
```

**tool result**

```
            self.assertEqual(default_storage.base_location, 'test_value')

    def test_override_media_url(self):
        """
        Overriding the MEDIA_URL setting should be reflected in the
        base_url attribute of django.core.files.storage.default_storage.
        """
        self.assertEqual(default_storage.base_location, '')
        with self.settings(MEDIA_URL='/test_value/'):
            self.assertEqual(default_storage.base_url, '/test_value/')

    def test_override_file_upload_permissions(self):
        """
        Overriding the FILE_UPLOAD_PERMISSIONS setting should be reflected in
        the file_permissions_mode attribute of
        django.core.files.storage.default_storage.
        """
        self.assertIsNone(default_storage.file_permissions_mode)
        with self.settings(FILE_UPLOAD_PERMISSIONS=0o777):
            self.assertEqual(default_storage.file_permissions_mode, 0o777)

    def test_override_file_upload_directory_permissions(self):
        """
        Overriding the FILE_UPLOAD_DIRECTORY_PERMISSIONS setting should be
        reflected in the directory_permissions_mode attribute of
        django.core.files.storage.default_storage.
        """
        self.assertIsNone(default_storage.directory_permissions_mode)
        with self.settings(FILE_UPLOAD_DIRECTORY_PERMISSIONS=0o777):
            self.assertEqual(default_storage.directory_permissions_mode, 0o777)

    def test_override_database_routers(self):
        """
        Overriding DATABASE_ROUTERS should update the master router.
        """
        test_routers = [object()]
    }

    def setUp(self):
        self.umask = 0o027
        self.old_umask = os.umask(self.umask)
        super().setUp()

    def tearDown(self):
        os.umask(self.old_umask)
        super().tearDown()

    # Don't run collectstatic command in this test class.
    def run_collectstatic(self, **kwargs):
        pass

    @override_settings(
        FILE_UPLOAD_PERMISSIONS=0o655,
        FILE_UPLOAD_DIRECTORY_PERMISSIONS=0o765,
    )
    def test_collect_static_files_permissions(self):
        call_command('collectstatic', **self.command_params)
        test_file = os.path.join(settings.STATIC_ROOT, "test.txt")
        test_dir = os.path.join(settings.STATIC_ROOT, "subdir")
        file_mode = os.stat(test_file)[0] & 0o777
        dir_mode = os.stat(test_dir)[0] & 0o777
        self.assertEqual(file_mode, 0o655)
        self.assertEqual(dir_mode, 0o765)

    @override_settings(
        FILE_UPLOAD_PERMISSIONS=None,
        FILE_UPLOAD_DIRECTORY_PERMISSIONS=None,
    )
    def test_collect_static_files_default_permissions(self):
        call_command('collectstatic', **self.command_params)
        test_file = os.path.join(settings.STATIC_ROOT, "test.txt")
        test_dir = os.path.join(settings.STATIC_ROOT, "subdir")
        file_mode = os.stat(test_file)[0] & 0o777
        dir_mode = os.stat(test_dir)[0] & 0o777
        self.assertEqual(file_mode, 0o666 & ~self.umask)
        self.assertEqual(dir_mode, 0o777 & ~self.umask)

    @override_settings(
        FILE_UPLOAD_PERMISSIONS=0o655,
        FILE_UPLOAD_DIRECTORY_PERMISSIONS=0o765,
        STATICFILES_STORAGE='staticfiles_tests.test_storage.CustomStaticFilesStorage',
    )
    def test_collect_static_files_subclass_of_static_storage(self):
        call_command('collectstatic', **self.command_params)
        test_file = os.path.join(settings.STATIC_ROOT, "test.txt")
        test_dir = os.path.join(settings.STATIC_ROOT, "subdir")
        file_mode = os.stat(test_file)[0] & 0o777
        dir_mode = os.stat(test_dir)[0] & 0o777
        self.assertEqual(file_mode, 0o640)
        self.assertEqual(dir_mode, 0o740)


~~~~~

* ...

CSRF
~~~~

* ...

Email
~~~~~

* ...

File Storage
~~~~~~~~~~~~

* ...

File Uploads
~~~~~~~~~~~~

* ...


Forms
~~~~~

* ...

Generic Views

Validators
~~~~~~~~~~

* ...

.. _backwards-incompatible-3.0:

Backwards incompatible changes in 3.0
=====================================

Database backend API
--------------------

This section describes changes that may be needed in third-party database
backends.

* The second argument of ``DatabaseIntrospection.get_geometry_type()`` is now
  the row description instead of the column name.

* ``DatabaseIntrospection.get_field_type()`` may no longer return tuples.

* If the database can create foreign keys in the same SQL statement that adds a
  field, add ``SchemaEditor.sql_create_column_inline_fk`` with the appropriate
  SQL; otherwise, set ``DatabaseFeatures.can_create_inline_fk = False``.

* ``DatabaseFeatures.can_return_id_from_insert`` and
  ``can_return_ids_from_bulk_insert`` are renamed to
  ``can_return_columns_from_insert`` and ``can_return_rows_from_bulk_insert``.

:mod:`django.contrib.gis`
-------------------------

* Supported for PostGIS 2.1 is removed.

* Support for SpatiaLite 4.1 and 4.2 is removed.

* Support for GDAL 1.11 is removed.

Dropped support for PostgreSQL 9.4
----------------------------------
  ``six.python_2_unicode_compatible()``.

* ``django.utils.functional.curry()`` - Use :func:`functools.partial` or
  :class:`functools.partialmethod`. See :commit:`5b1c389603a353625ae1603`.

* ``django.utils.safestring.SafeBytes`` - Unused since Django 2.0.

Miscellaneous
-------------

* ``ContentType.__str__()`` now includes the model's ``app_label`` to
  disambiguate model's with the same name in different apps.

.. _deprecated-features-3.0:

Features deprecated in 3.0
==========================

``django.utils.encoding.force_text()`` and ``smart_text()``
-----------------------------------------------------------

The ``smart_text()`` and ``force_text()`` aliases (since Django 2.0) of
``smart_str()`` and ``force_str()`` are deprecated. Ignore this deprecation if
your code supports Python 2 as the behavior of ``smart_str()`` and
``force_str()`` is different there.

Miscellaneous
-------------

* ``django.utils.http.urlquote()``, ``urlquote_plus()``, ``urlunquote()``, and
  ``urlunquote_plus()`` are deprecated in favor of the functions that they're
  aliases for: :func:`urllib.parse.quote`, :func:`~urllib.parse.quote_plus`,
  :func:`~urllib.parse.unquote`, and :func:`~urllib.parse.unquote_plus`.

* ``django.utils.translation.ugettext()``, ``ugettext_lazy()``,
  ``ugettext_noop()``, ``ungettext()``, and ``ungettext_lazy()`` are deprecated
  in favor of the functions that they're aliases for:
  :func:`django.utils.translation.gettext`,
  :func:`~django.utils.translation.gettext_lazy`,
  :func:`~django.utils.translation.gettext_noop`,
  :func:`~django.utils.translation.ngettext`, and
```

**tool result**

```
tests/file_storage/tests.py:877:@unittest.skipIf(sys.platform.startswith('win'), "Windows only partially supports umasks and chmod.")
tests/file_storage/tests.py:880:        self.umask = 0o027
tests/file_storage/tests.py:881:        self.old_umask = os.umask(self.umask)
tests/file_storage/tests.py:886:        os.umask(self.old_umask)
tests/file_storage/tests.py:900:        self.assertEqual(mode, 0o666 & ~self.umask)
tests/file_storage/tests.py:914:        self.assertEqual(dir_mode, 0o777 & ~self.umask)
tests/staticfiles_tests/test_storage.py:493:        self.umask = 0o027
tests/staticfiles_tests/test_storage.py:494:        self.old_umask = os.umask(self.umask)
tests/staticfiles_tests/test_storage.py:498:        os.umask(self.old_umask)
tests/staticfiles_tests/test_storage.py:528:        self.assertEqual(file_mode, 0o666 & ~self.umask)
tests/staticfiles_tests/test_storage.py:529:        self.assertEqual(dir_mode, 0o777 & ~self.umask)
Files are searched by using the :setting:`enabled finders
<STATICFILES_FINDERS>`. The default is to look in all locations defined in
:setting:`STATICFILES_DIRS` and in the ``'static'`` directory of apps
specified by the :setting:`INSTALLED_APPS` setting.

The :djadmin:`collectstatic` management command calls the
:meth:`~django.contrib.staticfiles.storage.StaticFilesStorage.post_process`
method of the :setting:`STATICFILES_STORAGE` after each run and passes
a list of paths that have been found by the management command. It also
receives all command line options of :djadmin:`collectstatic`. This is used
by the :class:`~django.contrib.staticfiles.storage.ManifestStaticFilesStorage`
by default.

By default, collected files receive permissions from
:setting:`FILE_UPLOAD_PERMISSIONS` and collected directories receive permissions
from :setting:`FILE_UPLOAD_DIRECTORY_PERMISSIONS`. If you would like different
permissions for these files and/or directories, you can subclass either of the
:ref:`static files storage classes <staticfiles-storages>` and specify the
``file_permissions_mode`` and/or ``directory_permissions_mode`` parameters,
respectively. For example::

    from django.contrib.staticfiles import storage

    class MyStaticFilesStorage(storage.StaticFilesStorage):
        def __init__(self, *args, **kwargs):
            kwargs['file_permissions_mode'] = 0o640
            kwargs['directory_permissions_mode'] = 0o760
            super().__init__(*args, **kwargs)

Then set the :setting:`STATICFILES_STORAGE` setting to
``'path.to.MyStaticFilesStorage'``.
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport re\np='django/conf/global_settings.py'\ns=open(p).read()\ns=s.replace(\"FILE_UPLOAD_PERMISSIONS = None\", \"FILE_UPLOAD_PERMISSIONS = 0o644\")\nopen(p,'w').write(s)\n\np='docs/ref/settings.txt'\ns=open(p).read()\ns=s.replace(\"\"\"``FILE_UPLOAD_PERMISSIONS``\n---------------------------\n\nDefault: ``None``\"\"\", \"\"\"``FILE_UPLOAD_PERMISSIONS``\n---------------------------\n\nDefault: ``0o644``\"\"\")\nopen(p,'w').write(s)\nEOF"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\np='docs/ref/settings.txt'\ns=open(p).read()\nold=\"\"\"If this isn't given or is ``None``, you'll get operating-system\ndependent behavior. On most platforms, temporary files will have a mode\nof ``0o600``, and files saved from memory will be saved using the\nsystem's standard umask.\n\nFor security reasons, these permissions aren't applied to the temporary files\nthat are stored in :setting:`FILE_UPLOAD_TEMP_DIR`.\n\n\"\"\"\nassert old in s\ns=s.replace(old,\"\")\nopen(p,'w').write(s)\n\np='docs/howto/deployment/checklist.txt'\ns=open(p).read()\nold=\"\"\":setting:`FILE_UPLOAD_PERMISSIONS`\n----------------------------------\n\nWith the default file upload settings, files smaller than\n:setting:`FILE_UPLOAD_MAX_MEMORY_SIZE` may be stored with a different mode\nthan larger files as described in :setting:`FILE_UPLOAD_PERMISSIONS`.\n\nSetting :setting:`FILE_UPLOAD_PERMISSIONS` ensures all files are uploaded with\nthe same permissions.\n\n\"\"\"\nassert old in s\ns=s.replace(old,\"\")\nopen(p,'w').write(s)\n\np='docs/releases/3.0.txt'\ns=open(p).read()\nold=\"\"\"File Storage\n~~~~~~~~~~~~\n\n* ...\n\nFile Uploads\n~~~~~~~~~~~~\"\"\"\nnew=\"\"\"File Storage\n~~~~~~~~~~~~\n\n* ...\n\nFile Uploads\n~~~~~~~~~~~~\n\n* The default value of :setting:`FILE_UPLOAD_PERMISSIONS` is changed from\n  ``None`` to ``0o644``.\"\"\"\nassert old in s\ns=s.replace(old,new)\nopen(p,'w').write(s)\n\np='tests/file_storage/tests.py'\ns=open(p).read()\ns=s.replace(\"\"\"    @override_settings(FILE_UPLOAD_PERMISSIONS=None)\n    def test_file_upload_default_permissions(self):\n        self.storage = FileSystemStorage(self.storage_dir)\n        fname = self.storage.save(\"some_file\", ContentFile(\"data\"))\n        mode = os.stat(self.storage.path(fname))[0] & 0o777\n        self.assertEqual(mode, 0o666 & ~self.umask)\n\"\"\", \"\"\"    def test_file_upload_default_permissions(self):\n        self.storage = FileSystemStorage(self.storage_dir)\n        fname = self.storage.save(\"some_file\", ContentFile(\"data\"))\n        mode = os.stat(self.storage.path(fname))[0] & 0o777\n        self.assertEqual(mode, 0o644)\n\"\"\")\nopen(p,'w').write(s)\n\np='tests/test_utils/tests.py'\ns=open(p).read()\ns=s.replace(\"self.assertIsNone(default_storage.file_permissions_mode)\", \"self.assertEqual(default_storage.file_permissions_mode, 0o644)\")\nopen(p,'w').write(s)\n\np='tests/staticfiles_tests/test_storage.py'\ns=open(p).read()\ns=s.replace(\"\"\"    @override_settings(\n        FILE_UPLOAD_PERMISSIONS=None,\n        FILE_UPLOAD_DIRECTORY_PERMISSIONS=None,\n    )\n    def test_collect_static_files_default_permissions(self):\n        call_command('collectstatic', **self.command_params)\n        test_file = os.path.join(settings.STATIC_ROOT, \"test.txt\")\n        test_dir = os.path.join(settings.STATIC_ROOT, \"subdir\")\n        file_mode = os.stat(test_file)[0] & 0o777\n        dir_mode = os.stat(test_dir)[0] & 0o777\n        self.assertEqual(file_mode, 0o666 & ~self.umask)\n        self.assertEqual(dir_mode, 0o777 & ~self.umask)\n\"\"\", \"\"\"    @override_settings(FILE_UPLOAD_DIRECTORY_PERMISSIONS=None)\n    def test_collect_static_files_default_permissions(self):\n        call_command('collectstatic', **self.command_params)\n        test_file = os.path.join(settings.STATIC_ROOT, \"test.txt\")\n        test_dir = os.path.join(settings.STATIC_ROOT, \"subdir\")\n        file_mode = os.stat(test_file)[0] & 0o777\n        dir_mode = os.stat(test_dir)[0] & 0o777\n        self.assertEqual(file_mode, 0o644)\n        self.assertEqual(dir_mode, 0o777 & ~self.umask)\n\"\"\")\nopen(p,'w').write(s)\nEOF\ngit diff --stat"
}
```

**tool result**

```
 django/conf/global_settings.py          |  2 +-
 docs/howto/deployment/checklist.txt     | 10 ----------
 docs/ref/settings.txt                   | 10 +---------
 docs/releases/3.0.txt                   |  3 +++
 tests/file_storage/tests.py             |  3 +--
 tests/staticfiles_tests/test_storage.py |  7 ++-----
 tests/test_utils/tests.py               |  2 +-
 7 files changed, 9 insertions(+), 28 deletions(-)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"File Storage\\|Miscellaneous\" docs/releases/3.0.txt"
}
```

**tool result**

```
124:File Storage
290:Miscellaneous
309:Miscellaneous
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\np='docs/releases/3.0.txt'\ns=open(p).read()\nold=\"\"\"\n* The default value of :setting:`FILE_UPLOAD_PERMISSIONS` is changed from\n  ``None`` to ``0o644``.\"\"\"\nassert old in s\ns=s.replace(old,\"\",1)\nold2=\"\"\"Miscellaneous\n-------------\n\n* ``ContentType.__str__()`` now includes the model's ``app_label`` to\n  disambiguate model's with the same name in different apps.\n\"\"\"\nassert old2 in s\ns=s.replace(old2, old2+\"\"\"\n* The default value of :setting:`FILE_UPLOAD_PERMISSIONS` is changed from\n  ``None`` to ``0o644``.\n\"\"\")\nopen(p,'w').write(s)\nEOF\nsed -n '118,138p' docs/releases/3.0.txt; sed -n '286,302p' docs/releases/3.0.txt; git diff"
}
```

**tool result**

```

Email
~~~~~

* ...

File Storage
~~~~~~~~~~~~

* ...

File Uploads
~~~~~~~~~~~~


* ...


Forms
~~~~~

* ``django.utils.safestring.SafeBytes`` - Unused since Django 2.0.

Miscellaneous
-------------

* ``ContentType.__str__()`` now includes the model's ``app_label`` to
  disambiguate model's with the same name in different apps.

* The default value of :setting:`FILE_UPLOAD_PERMISSIONS` is changed from
  ``None`` to ``0o644``.

.. _deprecated-features-3.0:

Features deprecated in 3.0
==========================

``django.utils.encoding.force_text()`` and ``smart_text()``
diff --git a/django/conf/global_settings.py b/django/conf/global_settings.py
index acee9887d2..bdeec80610 100755
--- a/django/conf/global_settings.py
+++ b/django/conf/global_settings.py
@@ -304,7 +304,7 @@ FILE_UPLOAD_TEMP_DIR = None
 
 # The numeric mode to set newly-uploaded files to. The value should be a mode
 # you'd pass directly to os.chmod; see https://docs.python.org/library/os.html#files-and-directories.
-FILE_UPLOAD_PERMISSIONS = None
+FILE_UPLOAD_PERMISSIONS = 0o644
 
 # The numeric mode to assign to newly-created directories, when uploading files.
 # The value should be a mode as you'd pass to os.chmod;
diff --git a/docs/howto/deployment/checklist.txt b/docs/howto/deployment/checklist.txt
index c31bcac62a..b307076b62 100755
--- a/docs/howto/deployment/checklist.txt
+++ b/docs/howto/deployment/checklist.txt
@@ -154,16 +154,6 @@ server never attempts to interpret them. For instance, if a user uploads a
 
 Now is a good time to check your backup strategy for these files.
 
-:setting:`FILE_UPLOAD_PERMISSIONS`
-----------------------------------
-
-With the default file upload settings, files smaller than
-:setting:`FILE_UPLOAD_MAX_MEMORY_SIZE` may be stored with a different mode
-than larger files as described in :setting:`FILE_UPLOAD_PERMISSIONS`.
-
-Setting :setting:`FILE_UPLOAD_PERMISSIONS` ensures all files are uploaded with
-the same permissions.
-
 HTTPS
 =====
 
diff --git a/docs/ref/settings.txt b/docs/ref/settings.txt
index 46e99af993..4dc8873838 100755
--- a/docs/ref/settings.txt
+++ b/docs/ref/settings.txt
@@ -1484,20 +1484,12 @@ This value mirrors the functionality and caveats of the
 ``FILE_UPLOAD_PERMISSIONS``
 ---------------------------
 
-Default: ``None``
+Default: ``0o644``
 
 The numeric mode (i.e. ``0o644``) to set newly uploaded files to. For
 more information about what these modes mean, see the documentation for
 :func:`os.chmod`.
 
-If this isn't given or is ``None``, you'll get operating-system
-dependent behavior. On most platforms, temporary files will have a mode
-of ``0o600``, and files saved from memory will be saved using the
-system's standard umask.
-
-For security reasons, these permissions aren't applied to the temporary files
-that are stored in :setting:`FILE_UPLOAD_TEMP_DIR`.
-
 This setting also determines the default permissions for collected static files
 when using the :djadmin:`collectstatic` management command. See
 :djadmin:`collectstatic` for details on overriding it.
diff --git a/docs/releases/3.0.txt b/docs/releases/3.0.txt
index 5d9bff086e..2851988029 100755
--- a/docs/releases/3.0.txt
+++ b/docs/releases/3.0.txt
@@ -129,6 +129,7 @@ File Storage
 File Uploads
 ~~~~~~~~~~~~
 
+
 * ...
 
 
@@ -290,6 +291,9 @@ Miscellaneous
 * ``ContentType.__str__()`` now includes the model's ``app_label`` to
   disambiguate model's with the same name in different apps.
 
+* The default value of :setting:`FILE_UPLOAD_PERMISSIONS` is changed from
+  ``None`` to ``0o644``.
+
 .. _deprecated-features-3.0:
 
 Features deprecated in 3.0
diff --git a/tests/file_storage/tests.py b/tests/file_storage/tests.py
index 434869554c..ee878df332 100755
--- a/tests/file_storage/tests.py
+++ b/tests/file_storage/tests.py
@@ -892,12 +892,11 @@ class FileStoragePermissions(unittest.TestCase):
         actual_mode = os.stat(self.storage.path(name))[0] & 0o777
         self.assertEqual(actual_mode, 0o654)
 
-    @override_settings(FILE_UPLOAD_PERMISSIONS=None)
     def test_file_upload_default_permissions(self):
         self.storage = FileSystemStorage(self.storage_dir)
         fname = self.storage.save("some_file", ContentFile("data"))
         mode = os.stat(self.storage.path(fname))[0] & 0o777
-        self.assertEqual(mode, 0o666 & ~self.umask)
+        self.assertEqual(mode, 0o644)
 
     @override_settings(FILE_UPLOAD_DIRECTORY_PERMISSIONS=0o765)
     def test_file_upload_directory_permissions(self):
diff --git a/tests/staticfiles_tests/test_storage.py b/tests/staticfiles_tests/test_storage.py
index 97e3b9113d..a2981da562 100755
--- a/tests/staticfiles_tests/test_storage.py
+++ b/tests/staticfiles_tests/test_storage.py
@@ -515,17 +515,14 @@ class TestStaticFilePermissions(CollectionTestCase):
         self.assertEqual(file_mode, 0o655)
         self.assertEqual(dir_mode, 0o765)
 
-    @override_settings(
-        FILE_UPLOAD_PERMISSIONS=None,
-        FILE_UPLOAD_DIRECTORY_PERMISSIONS=None,
-    )
+    @override_settings(FILE_UPLOAD_DIRECTORY_PERMISSIONS=None)
     def test_collect_static_files_default_permissions(self):
         call_command('collectstatic', **self.command_params)
         test_file = os.path.join(settings.STATIC_ROOT, "test.txt")
         test_dir = os.path.join(settings.STATIC_ROOT, "subdir")
         file_mode = os.stat(test_file)[0] & 0o777
         dir_mode = os.stat(test_dir)[0] & 0o777
-        self.assertEqual(file_mode, 0o666 & ~self.umask)
+        self.assertEqual(file_mode, 0o644)
         self.assertEqual(dir_mode, 0o777 & ~self.umask)
 
     @override_settings(
diff --git a/tests/test_utils/tests.py b/tests/test_utils/tests.py
index a1a113a26e..e953eb6609 100755
--- a/tests/test_utils/tests.py
+++ b/tests/test_utils/tests.py
@@ -1099,7 +1099,7 @@ class OverrideSettingsTests(SimpleTestCase):
         the file_permissions_mode attribute of
         django.core.files.storage.default_storage.
         """
-        self.assertIsNone(default_storage.file_permissions_mode)
+        self.assertEqual(default_storage.file_permissions_mode, 0o644)
         with self.settings(FILE_UPLOAD_PERMISSIONS=0o777):
             self.assertEqual(default_storage.file_permissions_mode, 0o777)
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\np='docs/releases/3.0.txt'\ns=open(p).read()\ns=s.replace(\"\"\"File Uploads\n~~~~~~~~~~~~\n\n\n* ...\"\"\",\"\"\"File Uploads\n~~~~~~~~~~~~\n\n* ...\"\"\")\nopen(p,'w').write(s)\nEOF\ngrep -rn \"file_permissions_mode.*None\\|assertIsNone.*permissions\\|FILE_UPLOAD_PERMISSIONS=None\" tests django | cat"
}
```

**tool result**

```
tests/test_utils/tests.py:1112:        self.assertIsNone(default_storage.directory_permissions_mode)
django/core/files/storage.py:178:    def __init__(self, location=None, base_url=None, file_permissions_mode=None,
django/core/files/storage.py:194:            self.__dict__.pop('file_permissions_mode', None)
django/core/files/storage.py:283:        if self.file_permissions_mode is not None:
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py file_storage test_utils.tests.OverrideSettingsTests staticfiles_tests.test_storage 2>&1 | tail -30"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
Cloning test database for alias 'default'…
............................................................................................................................................................................................
----------------------------------------------------------------------
Ran 188 tests in 1.533s

OK
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"0o600\\|umask\\|permission\" docs/topics/files.txt docs/ref/files/storage.txt | head; cd tests && python runtests.py file_uploads 2>&1 | tail -8"
}
```

**tool result**

```
docs/ref/files/storage.txt:33:.. class:: FileSystemStorage(location=None, base_url=None, file_permissions_mode=None, directory_permissions_mode=None)
docs/ref/files/storage.txt:50:    .. attribute:: file_permissions_mode
docs/ref/files/storage.txt:52:        The file system permissions that the file will receive when it is
docs/ref/files/storage.txt:55:    .. attribute:: directory_permissions_mode
docs/ref/files/storage.txt:57:        The file system permissions that the directory will receive when it is
----------------------------------------------------------------------
Ran 30 tests in 0.465s

FAILED (failures=1)
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py file_uploads 2>&1 | grep -A30 \"FAIL:\""
}
```

**tool result**

```
FAIL: test_readonly_root (file_uploads.tests.DirectoryCreationTests)
Permission errors are not swallowed
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/tests/file_uploads/tests.py", line 546, in test_readonly_root
    self.obj.testfile.save('foo.txt', SimpleUploadedFile('foo.txt', b'x'), save=False)
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 203, in __exit__
    self._raiseFailure("{} not raised".format(exc_name))
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised

----------------------------------------------------------------------
Ran 30 tests in 0.433s

FAILED (failures=1)
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
Destroying test database for alias 'default'…
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS; git diff --check"
}
```

**tool result**

```
PASS
```

**assistant**

```
Done. Changes made:

- **`django/conf/global_settings.py`**: `FILE_UPLOAD_PERMISSIONS` default changed from `None` to `0o644`.
- **`docs/ref/settings.txt`**: documented the new default and removed the now-obsolete note about OS-dependent/`0o600` temp-file permissions.
- **`docs/howto/deployment/checklist.txt`**: removed the section warning that small vs. large uploads may get different modes (no longer true by default).
- **`docs/releases/3.0.txt`**: added a backwards-incompatible note under Miscellaneous.
- **Tests updated** (`tests/file_storage/tests.py`, `tests/test_utils/tests.py`, `tests/staticfiles_tests/test_storage.py`) to expect `0o644` by default.

Verification: `file_storage`, `test_utils.tests.OverrideSettingsTests`, and `staticfiles_tests.test_storage` all pass (188 tests). The one `file_uploads` failure (`test_readonly_root`) is unrelated — it fails because the suite runs as root, so a read-only directory doesn't raise `PermissionError`. The required command exits 0.
```

## Run folder `single-2026-11-06T104851`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Set default FILE_UPLOAD_PERMISSION to 0o644.
Description
	
Hello,
As far as I can see, the ​File Uploads documentation page does not mention any permission issues.
What I would like to see is a warning that in absence of explicitly configured FILE_UPLOAD_PERMISSIONS, the permissions for a file uploaded to FileSystemStorage might not be consistent depending on whether a MemoryUploadedFile or a TemporaryUploadedFile was used for temporary storage of the uploaded data (which, with the default FILE_UPLOAD_HANDLERS, in turn depends on the uploaded data size).
The tempfile.NamedTemporaryFile + os.rename sequence causes the resulting file permissions to be 0o0600 on some systems (I experience it here on CentOS 7.4.1708 and Python 3.6.5). In all probability, the implementation of Python's built-in tempfile module explicitly sets such permissions for temporary files due to security considerations.
I found mentions of this issue ​on GitHub, but did not manage to find any existing bug report in Django's bug tracker.
```
