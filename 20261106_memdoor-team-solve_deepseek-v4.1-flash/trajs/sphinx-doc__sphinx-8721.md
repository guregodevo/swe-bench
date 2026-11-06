# sphinx-doc__sphinx-8721 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 193s 34 lines cost=0.010017 in=292627 cached=193024 out=17635 calls=20`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`
**Describe the bug**
viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`

**To Reproduce**
```
$ make html epub
```

**Expected behavior**
module pages should not be created for epub by default.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions:  sphinx.ext.viewcode
- Extra tools: No

**Additional context**
No


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --short | head -20 && git log -1 --oneline"
}
```

**assistant → tool `glob`**

```json
{
  "pattern": "**/viewcode.py"
}
```

**tool result**

```
/testbed
AUTHORS
CHANGES
CHANGES.old
CODE_OF_CONDUCT
CONTRIBUTING.rst
EXAMPLES
LICENSE
MANIFEST.in
Makefile
README.rst
Sphinx.egg-info
babel.cfg
bindep.txt
doc
karma.conf.js
package-lock.json
package.json
setup.cfg
setup.py
sphinx
tests
tox.ini
utils
?? .memdoor/
10011eea7 SWE-bench
```

**tool result**

```
/testbed/sphinx/ext/viewcode.py
```

**assistant → tool `read_file`**

```json
{
  "path": "sphinx/ext/viewcode.py"
}
```

**tool result**

```
"""
    sphinx.ext.viewcode
    ~~~~~~~~~~~~~~~~~~~

    Add links to module code in Python object descriptions.

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import posixpath
import traceback
from os import path
from typing import Any, Dict, Generator, Iterable, Optional, Set, Tuple, cast

from docutils import nodes
from docutils.nodes import Element, Node

import sphinx
from sphinx import addnodes
from sphinx.application import Sphinx
from sphinx.builders.html import StandaloneHTMLBuilder
from sphinx.environment import BuildEnvironment
from sphinx.locale import _, __
from sphinx.pycode import ModuleAnalyzer
from sphinx.util import get_full_modname, logging, status_iterator
from sphinx.util.nodes import make_refnode

logger = logging.getLogger(__name__)


OUTPUT_DIRNAME = '_modules'


def _get_full_modname(app: Sphinx, modname: str, attribute: str) -> Optional[str]:
    try:
        return get_full_modname(modname, attribute)
    except AttributeError:
        # sphinx.ext.viewcode can't follow class instance attribute
        # then AttributeError logging output only verbose mode.
        logger.verbose('Didn\'t find %s in %s', attribute, modname)
        return None
    except Exception as e:
        # sphinx.ext.viewcode follow python domain directives.
        # because of that, if there are no real modules exists that specified
        # by py:function or other directives, viewcode emits a lot of warnings.
        # It should be displayed only verbose mode.
        logger.verbose(traceback.format_exc().rstrip())
        logger.verbose('viewcode can\'t import %s, failed with error "%s"', modname, e)
        return None


def doctree_read(app: Sphinx, doctree: Node) -> None:
    env = app.builder.env
    if not hasattr(env, '_viewcode_modules'):
        env._viewcode_modules = {}  # type: ignore
    if app.builder.name == "singlehtml":
        return
    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
        return

    def has_tag(modname: str, fullname: str, docname: str, refname: str) -> bool:
        entry = env._viewcode_modules.get(modname, None)  # type: ignore
        if entry is False:
            return False

        code_tags = app.emit_firstresult('viewcode-find-source', modname)
        if code_tags is None:
            try:
                analyzer = ModuleAnalyzer.for_module(modname)
                analyzer.find_tags()
            except Exception:
                env._viewcode_modules[modname] = False  # type: ignore
                return False

            code = analyzer.code
            tags = analyzer.tags
        else:
            code, tags = code_tags

        if entry is None or entry[0] != code:
            entry = code, tags, {}, refname
            env._viewcode_modules[modname] = entry  # type: ignore
        _, tags, used, _ = entry
        if fullname in tags:
            used[fullname] = docname
            return True

        return False

    for objnode in doctree.traverse(addnodes.desc):
        if objnode.get('domain') != 'py':
            continue
        names = set()  # type: Set[str]
        for signode in objnode:
            if not isinstance(signode, addnodes.desc_signature):
                continue
            modname = signode.get('module')
            fullname = signode.get('fullname')
            refname = modname
            if env.config.viewcode_follow_imported_members:
                new_modname = app.emit_firstresult(
                    'viewcode-follow-imported', modname, fullname,
                )
                if not new_modname:
                    new_modname = _get_full_modname(app, modname, fullname)
                modname = new_modname
            if not modname:
                continue
            fullname = signode.get('fullname')
            if not has_tag(modname, fullname, env.docname, refname):
                continue
            if fullname in names:
                # only one link per name, please
                continue
            names.add(fullname)
            pagename = posixpath.join(OUTPUT_DIRNAME, modname.replace('.', '/'))
            inline = nodes.inline('', _('[source]'), classes=['viewcode-link'])
            onlynode = addnodes.only(expr='html')
            onlynode += addnodes.pending_xref('', inline, reftype='viewcode', refdomain='std',
                                              refexplicit=False, reftarget=pagename,
                                              refid=fullname, refdoc=env.docname)
            signode += onlynode


def env_merge_info(app: Sphinx, env: BuildEnvironment, docnames: Iterable[str],
                   other: BuildEnvironment) -> None:
    if not hasattr(other, '_viewcode_modules'):
        return
    # create a _viewcode_modules dict on the main environment
    if not hasattr(env, '_viewcode_modules'):
        env._viewcode_modules = {}  # type: ignore
    # now merge in the information from the subprocess
    env._viewcode_modules.update(other._viewcode_modules)  # type: ignore


def missing_reference(app: Sphinx, env: BuildEnvironment, node: Element, contnode: Node
                      ) -> Optional[Node]:
    # resolve our "viewcode" reference nodes -- they need special treatment
    if node['reftype'] == 'viewcode':
        return make_refnode(app.builder, node['refdoc'], node['reftarget'],
                            node['refid'], contnode)

    return None


def get_module_filename(app: Sphinx, modname: str) -> Optional[str]:
    """Get module filename for *modname*."""
    source_info = app.emit_firstresult('viewcode-find-source', modname)
    if source_info:
        return None
    else:
        try:
            filename, source = ModuleAnalyzer.get_module_source(modname)
            return filename
        except Exception:
            return None


def should_generate_module_page(app: Sphinx, modname: str) -> bool:
    """Check generation of module page is needed."""
    module_filename = get_module_filename(app, modname)
    if module_filename is None:
        # Always (re-)generate module page when module filename is not found.
        return True

    builder = cast(StandaloneHTMLBuilder, app.builder)
    basename = modname.replace('.', '/') + builder.out_suffix
    page_filename = path.join(app.outdir, '_modules/', basename)

    try:
        if path.getmtime(module_filename) <= path.getmtime(page_filename):
            # generation is not needed if the HTML page is newer than module file.
            return False
    except IOError:
        pass

    return True


def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], None, None]:
    env = app.builder.env
    if not hasattr(env, '_viewcode_modules'):
        return
    highlighter = app.builder.highlighter  # type: ignore
    urito = app.builder.get_relative_uri

    modnames = set(env._viewcode_modules)  # type: ignore

    for modname, entry in status_iterator(
            sorted(env._viewcode_modules.items()),  # type: ignore
            __('highlighting module code... '), "blue",
            len(env._viewcode_modules),  # type: ignore
            app.verbosity, lambda x: x[0]):
        if not entry:
            continue
        if not should_generate_module_page(app, modname):
            continue

        code, tags, used, refname = entry
        # construct a page name for the highlighted source
        pagename = posixpath.join(OUTPUT_DIRNAME, modname.replace('.', '/'))
        # highlight the source using the builder's highlighter
        if env.config.highlight_language in ('python3', 'default', 'none'):
            lexer = env.config.highlight_language
        else:
            lexer = 'python'
        highlighted = highlighter.highlight_block(code, lexer, linenos=False)
        # split the code into lines
        lines = highlighted.splitlines()
        # split off wrap markup from the first line of the actual code
        before, after = lines[0].split('<pre>')
        lines[0:1] = [before + '<pre>', after]
        # nothing to do for the last line; it always starts with </pre> anyway
        # now that we have code lines (starting at index 1), insert anchors for
        # the collected tags (HACK: this only works if the tag boundaries are
        # properly nested!)
        maxindex = len(lines) - 1
        for name, docname in used.items():
            type, start, end = tags[name]
            backlink = urito(pagename, docname) + '#' + refname + '.' + name
            lines[start] = (
                '<div class="viewcode-block" id="%s"><a class="viewcode-back" '
                'href="%s">%s</a>' % (name, backlink, _('[docs]')) +
                lines[start])
            lines[min(end, maxindex)] += '</div>'
        # try to find parents (for submodules)
        parents = []
        parent = modname
        while '.' in parent:
            parent = parent.rsplit('.', 1)[0]
            if parent in modnames:
                parents.append({
                    'link': urito(pagename,
                                  posixpath.join(OUTPUT_DIRNAME, parent.replace('.', '/'))),
                    'title': parent})
        parents.append({'link': urito(pagename, posixpath.join(OUTPUT_DIRNAME, 'index')),
                        'title': _('Module code')})
        parents.reverse()
        # putting it all together
        context = {
            'parents': parents,
            'title': modname,
            'body': (_('<h1>Source code for %s</h1>') % modname +
                     '\n'.join(lines)),
        }
        yield (pagename, context, 'page.html')

    if not modnames:
        return

    html = ['\n']
    # the stack logic is needed for using nested lists for submodules
    stack = ['']
    for modname in sorted(modnames):
        if modname.startswith(stack[-1]):
            stack.append(modname + '.')
            html.append('<ul>')
        else:
            stack.pop()
            while not modname.startswith(stack[-1]):
                stack.pop()
                html.append('</ul>')
            stack.append(modname + '.')
        html.append('<li><a href="%s">%s</a></li>\n' % (
            urito(posixpath.join(OUTPUT_DIRNAME, 'index'),
                  posixpath.join(OUTPUT_DIRNAME, modname.replace('.', '/'))),
            modname))
    html.append('</ul>' * (len(stack) - 1))
    context = {
        'title': _('Overview: module code'),
        'body': (_('<h1>All modules for which code is available</h1>') +
                 ''.join(html)),
    }

    yield (posixpath.join(OUTPUT_DIRNAME, 'index'), context, 'page.html')


def setup(app: Sphinx) -> Dict[str, Any]:
    app.add_config_value('viewcode_import', None, False)
    app.add_config_value('viewcode_enable_epub', False, False)
    app.add_config_value('viewcode_follow_imported_members', True, False)
    app.connect('doctree-read', doctree_read)
    app.connect('env-merge-info', env_merge_info)
    app.connect('html-collect-pages', collect_pages)
    app.connect('missing-reference', missing_reference)
    # app.add_config_value('viewcode_include_modules', [], 'env')
    # app.add_config_value('viewcode_exclude_modules', [], 'env')
    app.add_event('viewcode-find-source')
    app.add_event('viewcode-follow-imported')
    return {
        'version': sphinx.__display_version__,
        'env_version': 1,
        'parallel_read_safe': True
    }
```

**assistant → tool `bash`**

```json
{
  "command": "ls tests/roots | grep -i viewcode; ls tests | grep -i viewcode; grep -rn \"viewcode_enable_epub\" tests doc sphinx | head -30"
}
```

**tool result**

```
test-ext-viewcode
test-ext-viewcode-find
test_ext_viewcode.py
doc/usage/extensions/viewcode.rst:37:support this extension (see :confval:`viewcode_enable_epub`).
doc/usage/extensions/viewcode.rst:53:.. confval:: viewcode_enable_epub
sphinx/ext/viewcode.py:59:    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
sphinx/ext/viewcode.py:281:    app.add_config_value('viewcode_enable_epub', False, False)
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/test_ext_viewcode.py"
}
```

**tool result**

```
"""
    test_ext_viewcode
    ~~~~~~~~~~~~~~~~~

    Test sphinx.ext.viewcode extension.

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re

import pytest


@pytest.mark.sphinx(testroot='ext-viewcode')
def test_viewcode(app, status, warning):
    app.builder.build_all()

    warnings = re.sub(r'\\+', '/', warning.getvalue())
    assert re.findall(
        r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
        r"file .*/spam/__init__.py'",
        warnings
    )

    result = (app.outdir / 'index.html').read_text()
    assert result.count('href="_modules/spam/mod1.html#func1"') == 2
    assert result.count('href="_modules/spam/mod2.html#func2"') == 2
    assert result.count('href="_modules/spam/mod1.html#Class1"') == 2
    assert result.count('href="_modules/spam/mod2.html#Class2"') == 2
    assert result.count('@decorator') == 1

    # test that the class attribute is correctly documented
    assert result.count('this is Class3') == 2
    assert 'this is the class attribute class_attr' in result
    # the next assert fails, until the autodoc bug gets fixed
    assert result.count('this is the class attribute class_attr') == 2

    result = (app.outdir / '_modules/spam/mod1.html').read_text()
    result = re.sub('<span class=".*?">', '<span>', result)  # filter pygments classes
    assert ('<div class="viewcode-block" id="Class1"><a class="viewcode-back" '
            'href="../../index.html#spam.Class1">[docs]</a>'
            '<span>@decorator</span>\n'
            '<span>class</span> <span>Class1</span>'
            '<span>(</span><span>object</span><span>):</span>\n'
            '    <span>&quot;&quot;&quot;</span>\n'
            '<span>    this is Class1</span>\n'
            '<span>    &quot;&quot;&quot;</span></div>\n') in result


@pytest.mark.sphinx(testroot='ext-viewcode', tags=['test_linkcode'])
def test_linkcode(app, status, warning):
    app.builder.build(['objects'])

    stuff = (app.outdir / 'objects.html').read_text()

    assert 'http://foobar/source/foolib.py' in stuff
    assert 'http://foobar/js/' in stuff
    assert 'http://foobar/c/' in stuff
    assert 'http://foobar/cpp/' in stuff


@pytest.mark.sphinx(testroot='ext-viewcode-find')
def test_local_source_files(app, status, warning):
    def find_source(app, modname):
        if modname == 'not_a_package':
            source = (app.srcdir / 'not_a_package/__init__.py').read_text()
            tags = {
                'func1': ('def', 1, 1),
                'Class1': ('class', 1, 1),
                'not_a_package.submodule.func1': ('def', 1, 1),
                'not_a_package.submodule.Class1': ('class', 1, 1),
            }
        else:
            source = (app.srcdir / 'not_a_package/submodule.py').read_text()
            tags = {
                'not_a_package.submodule.func1': ('def', 11, 15),
                'Class1': ('class', 19, 22),
                'not_a_package.submodule.Class1': ('class', 19, 22),
                'Class3': ('class', 25, 30),
                'not_a_package.submodule.Class3.class_attr': ('other', 29, 29),
            }
        return (source, tags)

    app.connect('viewcode-find-source', find_source)
    app.builder.build_all()

    warnings = re.sub(r'\\+', '/', warning.getvalue())
    assert re.findall(
        r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
        r"file .*/not_a_package/__init__.py'",
        warnings
    )

    result = (app.outdir / 'index.html').read_text()
    assert result.count('href="_modules/not_a_package.html#func1"') == 1
    assert result.count('href="_modules/not_a_package.html#not_a_package.submodule.func1"') == 1
    assert result.count('href="_modules/not_a_package/submodule.html#Class1"') == 1
    assert result.count('href="_modules/not_a_package/submodule.html#Class3"') == 1
    assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class1"') == 1

    assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class3.class_attr"') == 1
    assert result.count('This is the class attribute class_attr') == 1
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"epub\" tests/test_ext_viewcode.py tests/conftest.py tests/roots/test-ext-viewcode -r | head -40; ls tests/roots/test-ext-viewcode; cat tests/roots/test-ext-viewcode/conf.py; grep -rln \"epub\" tests/*.py | head"
}
```

**tool result**

```
conf.py
index.rst
objects.rst
spam
import os
import sys

source_dir = os.path.abspath('.')
if source_dir not in sys.path:
    sys.path.insert(0, source_dir)
extensions = ['sphinx.ext.autodoc', 'sphinx.ext.viewcode']
exclude_patterns = ['_build']


if 'test_linkcode' in tags:  # NOQA
    extensions.remove('sphinx.ext.viewcode')
    extensions.append('sphinx.ext.linkcode')

    def linkcode_resolve(domain, info):
        if domain == 'py':
            fn = info['module'].replace('.', '/')
            return "http://foobar/source/%s.py" % fn
        elif domain == "js":
            return "http://foobar/js/" + info['fullname']
        elif domain in ("c", "cpp"):
            return "http://foobar/%s/%s" % (domain,  "".join(info['names']))
        else:
            raise AssertionError()
tests/test_build.py
tests/test_build_epub.py
tests/test_quickstart.py
tests/test_theming.py
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,100p' tests/test_build_epub.py; grep -n \"epub\" tests/conftest.py | head -30"
}
```

**tool result**

```
"""
    test_build_html
    ~~~~~~~~~~~~~~~

    Test the HTML builder and check output against XPath.

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import subprocess
from subprocess import PIPE, CalledProcessError
from xml.etree import ElementTree

import pytest

from sphinx.util import docutils


# check given command is runnable
def runnable(command):
    try:
        subprocess.run(command, stdout=PIPE, stderr=PIPE, check=True)
        return True
    except (OSError, CalledProcessError):
        return False  # command not found or exit with non-zero


class EPUBElementTree:
    """Test helper for content.opf and toc.ncx"""
    namespaces = {
        'idpf': 'http://www.idpf.org/2007/opf',
        'dc': 'http://purl.org/dc/elements/1.1/',
        'ibooks': 'http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/',
        'ncx': 'http://www.daisy.org/z3986/2005/ncx/',
        'xhtml': 'http://www.w3.org/1999/xhtml',
        'epub': 'http://www.idpf.org/2007/ops'
    }

    def __init__(self, tree):
        self.tree = tree

    @classmethod
    def fromstring(cls, string):
        return cls(ElementTree.fromstring(string))

    def find(self, match):
        ret = self.tree.find(match, namespaces=self.namespaces)
        if ret is not None:
            return self.__class__(ret)
        else:
            return ret

    def findall(self, match):
        ret = self.tree.findall(match, namespaces=self.namespaces)
        return [self.__class__(e) for e in ret]

    def __getattr__(self, name):
        return getattr(self.tree, name)

    def __iter__(self):
        for child in self.tree:
            yield self.__class__(child)


@pytest.mark.sphinx('epub', testroot='basic')
def test_build_epub(app):
    app.build()
    assert (app.outdir / 'mimetype').read_text() == 'application/epub+zip'
    assert (app.outdir / 'META-INF' / 'container.xml').exists()

    # toc.ncx
    toc = EPUBElementTree.fromstring((app.outdir / 'toc.ncx').read_text())
    assert toc.find("./ncx:docTitle/ncx:text").text == 'Python'

    # toc.ncx / head
    meta = list(toc.find("./ncx:head"))
    assert meta[0].attrib == {'name': 'dtb:uid', 'content': 'unknown'}
    assert meta[1].attrib == {'name': 'dtb:depth', 'content': '1'}
    assert meta[2].attrib == {'name': 'dtb:totalPageCount', 'content': '0'}
    assert meta[3].attrib == {'name': 'dtb:maxPageNumber', 'content': '0'}

    # toc.ncx / navMap
    navpoints = toc.findall("./ncx:navMap/ncx:navPoint")
    assert len(navpoints) == 1
    assert navpoints[0].attrib == {'id': 'navPoint1', 'playOrder': '1'}
    assert navpoints[0].find("./ncx:content").attrib == {'src': 'index.xhtml'}

    navlabel = navpoints[0].find("./ncx:navLabel/ncx:text")
    assert navlabel.text == 'The basic Sphinx documentation for testing'

    # content.opf
    opf = EPUBElementTree.fromstring((app.outdir / 'content.opf').read_text())

    # content.opf / metadata
    metadata = opf.find("./idpf:metadata")
    assert metadata.find("./dc:language").text == 'en'
    assert metadata.find("./dc:title").text == 'Python'
    assert metadata.find("./dc:description").text == 'unknown'
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def make_app\\|def app\\|class SphinxTestApp\\|build_all\\|testroot\" tests/conftest.py | head -60; sed -n '1,260p' tests/conftest.py"
}
```

**tool result**

```
"""
    pytest config for sphinx/tests
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import shutil

import docutils
import pytest

import sphinx
from sphinx.testing import comparer
from sphinx.testing.path import path

pytest_plugins = 'sphinx.testing.fixtures'

# Exclude 'roots' dirs for pytest test collector
collect_ignore = ['roots']


@pytest.fixture(scope='session')
def rootdir():
    return path(__file__).parent.abspath() / 'roots'


def pytest_report_header(config):
    header = ("libraries: Sphinx-%s, docutils-%s" %
              (sphinx.__display_version__, docutils.__version__))
    if hasattr(config, '_tmp_path_factory'):
        header += "\nbase tempdir: %s" % config._tmp_path_factory.getbasetemp()

    return header


def pytest_assertrepr_compare(op, left, right):
    comparer.pytest_assertrepr_compare(op, left, right)


def _initialize_test_directory(session):
    if 'SPHINX_TEST_TEMPDIR' in os.environ:
        tempdir = os.path.abspath(os.getenv('SPHINX_TEST_TEMPDIR'))
        print('Temporary files will be placed in %s.' % tempdir)

        if os.path.exists(tempdir):
            shutil.rmtree(tempdir)

        os.makedirs(tempdir)


def pytest_sessionstart(session):
    _initialize_test_directory(session)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"html-collect-pages\\|collect_pages\" sphinx | head -30; grep -n \"class EpubBuilder\\|class StandaloneHTMLBuilder\\|collect_pages\" sphinx/builders/epub3.py sphinx/builders/html/__init__.py"
}
```

**tool result**

```
sphinx/builders/html/__init__.py:644:        for pagelist in self.events.emit('html-collect-pages'):
sphinx/builders/html/__init__.py:1264:    app.add_event('html-collect-pages')
sphinx/ext/viewcode.py:181:def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], None, None]:
sphinx/ext/viewcode.py:285:    app.connect('html-collect-pages', collect_pages)
sphinx/builders/html/__init__.py:176:class StandaloneHTMLBuilder(Builder):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '610,675p' sphinx/builders/html/__init__.py; grep -n \"html-collect-pages\" -r sphinx/builders; sed -n '1,170p' sphinx/builders/epub3.py"
}
```

**tool result**

```
        ctx = self.get_doc_context(docname, body, metatags)
        self.handle_page(docname, ctx, event_arg=doctree)

    def write_doc_serialized(self, docname: str, doctree: nodes.document) -> None:
        self.imgpath = relative_uri(self.get_target_uri(docname), self.imagedir)
        self.post_process_images(doctree)
        title_node = self.env.longtitles.get(docname)
        title = self.render_partial(title_node)['title'] if title_node else ''
        self.index_page(docname, doctree, title)

    def finish(self) -> None:
        self.finish_tasks.add_task(self.gen_indices)
        self.finish_tasks.add_task(self.gen_pages_from_extensions)
        self.finish_tasks.add_task(self.gen_additional_pages)
        self.finish_tasks.add_task(self.copy_image_files)
        self.finish_tasks.add_task(self.copy_download_files)
        self.finish_tasks.add_task(self.copy_static_files)
        self.finish_tasks.add_task(self.copy_extra_files)
        self.finish_tasks.add_task(self.write_buildinfo)

        # dump the search index
        self.handle_finish()

    @progress_message(__('generating indices'))
    def gen_indices(self) -> None:
        # the global general index
        if self.use_index:
            self.write_genindex()

        # the global domain-specific indices
        self.write_domain_indices()

    def gen_pages_from_extensions(self) -> None:
        # pages from extensions
        for pagelist in self.events.emit('html-collect-pages'):
            for pagename, context, template in pagelist:
                self.handle_page(pagename, context, template)

    @progress_message(__('writing additional pages'))
    def gen_additional_pages(self) -> None:
        # additional pages from conf.py
        for pagename, template in self.config.html_additional_pages.items():
            logger.info(pagename + ' ', nonl=True)
            self.handle_page(pagename, {}, template)

        # the search page
        if self.search:
            logger.info('search ', nonl=True)
            self.handle_page('search', {}, 'search.html')

        # the opensearch xml file
        if self.config.html_use_opensearch and self.search:
            logger.info('opensearch ', nonl=True)
            fn = path.join(self.outdir, '_static', 'opensearch.xml')
            self.handle_page('opensearch', {}, 'opensearch.xml', outfilename=fn)

    def write_genindex(self) -> None:
        # the total count of lines for each index letter, used to distribute
        # the entries into two columns
        genindex = IndexEntries(self.env).create_index(self)
        indexcounts = []
        for _k, entries in genindex:
            indexcounts.append(sum(1 + len(subitems)
                                   for _, (_, subitems, _) in entries))

        genindexcontext = {
sphinx/builders/html/__init__.py:644:        for pagelist in self.events.emit('html-collect-pages'):
sphinx/builders/html/__init__.py:1264:    app.add_event('html-collect-pages')
"""
    sphinx.builders.epub3
    ~~~~~~~~~~~~~~~~~~~~~

    Build epub3 files.
    Originally derived from epub.py.

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import html
import warnings
from collections import namedtuple
from os import path
from typing import Any, Dict, List, Set, Tuple

from sphinx import package_dir
from sphinx.application import Sphinx
from sphinx.builders import _epub_base
from sphinx.config import ENUM, Config
from sphinx.deprecation import RemovedInSphinx40Warning
from sphinx.locale import __
from sphinx.util import logging, xmlname_checker
from sphinx.util.fileutil import copy_asset_file
from sphinx.util.i18n import format_date
from sphinx.util.osutil import make_filename

logger = logging.getLogger(__name__)


NavPoint = namedtuple('NavPoint', ['text', 'refuri', 'children'])

# writing modes
PAGE_PROGRESSION_DIRECTIONS = {
    'horizontal': 'ltr',
    'vertical': 'rtl',
}
IBOOK_SCROLL_AXIS = {
    'horizontal': 'vertical',
    'vertical': 'horizontal',
}
THEME_WRITING_MODES = {
    'vertical': 'vertical-rl',
    'horizontal': 'horizontal-tb',
}

DOCTYPE = '''<!DOCTYPE html>'''

HTML_TAG = (
    '<html xmlns="http://www.w3.org/1999/xhtml" '
    'xmlns:epub="http://www.idpf.org/2007/ops">'
)


class Epub3Builder(_epub_base.EpubBuilder):
    """
    Builder that outputs epub3 files.

    It creates the metainfo files content.opf, nav.xhtml, toc.ncx, mimetype,
    and META-INF/container.xml. Afterwards, all necessary files are zipped to
    an epub file.
    """
    name = 'epub'
    epilog = __('The ePub file is in %(outdir)s.')

    supported_remote_images = False
    template_dir = path.join(package_dir, 'templates', 'epub3')
    doctype = DOCTYPE
    html_tag = HTML_TAG
    use_meta_charset = True

    # Finish by building the epub file
    def handle_finish(self) -> None:
        """Create the metainfo files and finally the epub."""
        self.get_toc()
        self.build_mimetype()
        self.build_container()
        self.build_content()
        self.build_navigation_doc()
        self.build_toc()
        self.build_epub()

    def validate_config_value(self) -> None:
        warnings.warn('Epub3Builder.validate_config_value() is deprecated.',
                      RemovedInSphinx40Warning, stacklevel=2)

    def content_metadata(self) -> Dict:
        """Create a dictionary with all metadata for the content.opf
        file properly escaped.
        """
        writing_mode = self.config.epub_writing_mode

        metadata = super().content_metadata()
        metadata['description'] = html.escape(self.config.epub_description)
        metadata['contributor'] = html.escape(self.config.epub_contributor)
        metadata['page_progression_direction'] = PAGE_PROGRESSION_DIRECTIONS.get(writing_mode)
        metadata['ibook_scroll_axis'] = IBOOK_SCROLL_AXIS.get(writing_mode)
        metadata['date'] = html.escape(format_date("%Y-%m-%dT%H:%M:%SZ"))
        metadata['version'] = html.escape(self.config.version)
        metadata['epub_version'] = self.config.epub_version
        return metadata

    def prepare_writing(self, docnames: Set[str]) -> None:
        super().prepare_writing(docnames)

        writing_mode = self.config.epub_writing_mode
        self.globalcontext['theme_writing_mode'] = THEME_WRITING_MODES.get(writing_mode)
        self.globalcontext['html_tag'] = self.html_tag
        self.globalcontext['use_meta_charset'] = self.use_meta_charset
        self.globalcontext['skip_ua_compatible'] = True

    def build_navlist(self, navnodes: List[Dict[str, Any]]) -> List[NavPoint]:
        """Create the toc navigation structure.

        This method is almost same as build_navpoints method in epub.py.
        This is because the logical navigation structure of epub3 is not
        different from one of epub2.

        The difference from build_navpoints method is templates which are used
        when generating navigation documents.
        """
        navstack = []  # type: List[NavPoint]
        navstack.append(NavPoint('', '', []))
        level = 0
        for node in navnodes:
            if not node['text']:
                continue
            file = node['refuri'].split('#')[0]
            if file in self.ignored_files:
                continue
            if node['level'] > self.config.epub_tocdepth:
                continue

            navpoint = NavPoint(node['text'], node['refuri'], [])
            if node['level'] == level:
                navstack.pop()
                navstack[-1].children.append(navpoint)
                navstack.append(navpoint)
            elif node['level'] == level + 1:
                level += 1
                navstack[-1].children.append(navpoint)
                navstack.append(navpoint)
            elif node['level'] < level:
                while node['level'] < len(navstack):
                    navstack.pop()
                level = node['level']
                navstack[-1].children.append(navpoint)
                navstack.append(navpoint)
            else:
                raise RuntimeError('Should never reach here. It might be a bug.')

        return navstack[0].children

    def navigation_doc_metadata(self, navlist: List[NavPoint]) -> Dict:
        """Create a dictionary with all metadata for the nav.xhtml file
        properly escaped.
        """
        metadata = {}  # type: Dict
        metadata['lang'] = html.escape(self.config.epub_language)
        metadata['toc_locale'] = html.escape(self.guide_titles['toc'])
        metadata['navlist'] = navlist
        return metadata

    def build_navigation_doc(self, outdir: str = None, outname: str = 'nav.xhtml') -> None:
        """Write the metainfo file nav.xhtml."""
        if outdir:
            warnings.warn('The arguments of Epub3Builder.build_navigation_doc() '
                          'is deprecated.', RemovedInSphinx40Warning, stacklevel=2)
        else:
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport sphinx.testing.fixtures, inspect\nprint(inspect.getsource(sphinx.testing.fixtures))\nEOF"
}
```

**tool result**

```
"""
    sphinx.testing.fixtures
    ~~~~~~~~~~~~~~~~~~~~~~~

    Sphinx test fixtures for pytest

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import subprocess
import sys
from collections import namedtuple
from io import StringIO
from subprocess import PIPE
from typing import Any, Callable, Dict, Generator, Tuple

import pytest

from sphinx.testing import util
from sphinx.testing.util import SphinxTestApp, SphinxTestAppWrapperForSkipBuilding

DEFAULT_ENABLED_MARKERS = [
    (
        'sphinx(builder, testroot=None, freshenv=False, confoverrides=None, tags=None,'
        ' docutilsconf=None, parallel=0): arguments to initialize the sphinx test application.'
    ),
    'test_params(shared_result=...): test parameters.',
]


def pytest_configure(config):
    # register custom markers
    for marker in DEFAULT_ENABLED_MARKERS:
        config.addinivalue_line('markers', marker)


@pytest.fixture(scope='session')
def rootdir() -> str:
    return None


class SharedResult:
    cache = {}  # type: Dict[str, Dict[str, str]]

    def store(self, key: str, app_: SphinxTestApp) -> Any:
        if key in self.cache:
            return
        data = {
            'status': app_._status.getvalue(),
            'warning': app_._warning.getvalue(),
        }
        self.cache[key] = data

    def restore(self, key: str) -> Dict[str, StringIO]:
        if key not in self.cache:
            return {}
        data = self.cache[key]
        return {
            'status': StringIO(data['status']),
            'warning': StringIO(data['warning']),
        }


@pytest.fixture
def app_params(request: Any, test_params: Dict, shared_result: SharedResult,
               sphinx_test_tempdir: str, rootdir: str) -> Tuple[Dict, Dict]:
    """
    parameters that is specified by 'pytest.mark.sphinx' for
    sphinx.application.Sphinx initialization
    """

    # ##### process pytest.mark.sphinx

    if hasattr(request.node, 'iter_markers'):  # pytest-3.6.0 or newer
        markers = request.node.iter_markers("sphinx")
    else:
        markers = request.node.get_marker("sphinx")
    pargs = {}
    kwargs = {}  # type: Dict[str, Any]

    if markers is not None:
        # to avoid stacking positional args
        for info in reversed(list(markers)):
            for i, a in enumerate(info.args):
                pargs[i] = a
            kwargs.update(info.kwargs)

    args = [pargs[i] for i in sorted(pargs.keys())]

    # ##### process pytest.mark.test_params

    if test_params['shared_result']:
        if 'srcdir' in kwargs:
            raise pytest.Exception('You can not specify shared_result and '
                                   'srcdir in same time.')
        kwargs['srcdir'] = test_params['shared_result']
        restore = shared_result.restore(test_params['shared_result'])
        kwargs.update(restore)

    # ##### prepare Application params

    testroot = kwargs.pop('testroot', 'root')
    kwargs['srcdir'] = srcdir = sphinx_test_tempdir / kwargs.get('srcdir', testroot)

    # special support for sphinx/tests
    if rootdir and not srcdir.exists():
        testroot_path = rootdir / ('test-' + testroot)
        testroot_path.copytree(srcdir)

    return namedtuple('app_params', 'args,kwargs')(args, kwargs)  # type: ignore


@pytest.fixture
def test_params(request: Any) -> Dict:
    """
    test parameters that is specified by 'pytest.mark.test_params'

    :param Union[str] shared_result:
       If the value is provided, app._status and app._warning objects will be
       shared in the parametrized test functions and/or test functions that
       have same 'shared_result' value.
       **NOTE**: You can not specify shared_result and srcdir in same time.
    """
    if hasattr(request.node, 'get_closest_marker'):  # pytest-3.6.0 or newer
        env = request.node.get_closest_marker('test_params')
    else:
        env = request.node.get_marker('test_params')
    kwargs = env.kwargs if env else {}
    result = {
        'shared_result': None,
    }
    result.update(kwargs)

    if (result['shared_result'] and not isinstance(result['shared_result'], str)):
        raise pytest.Exception('You can only provide a string type of value '
                               'for "shared_result" ')
    return result


@pytest.fixture(scope='function')
def app(test_params: Dict, app_params: Tuple[Dict, Dict], make_app: Callable,
        shared_result: SharedResult) -> Generator[SphinxTestApp, None, None]:
    """
    provides sphinx.application.Sphinx object
    """
    args, kwargs = app_params
    app_ = make_app(*args, **kwargs)
    yield app_

    print('# testroot:', kwargs.get('testroot', 'root'))
    print('# builder:', app_.builder.name)
    print('# srcdir:', app_.srcdir)
    print('# outdir:', app_.outdir)
    print('# status:', '\n' + app_._status.getvalue())
    print('# warning:', '\n' + app_._warning.getvalue())

    if test_params['shared_result']:
        shared_result.store(test_params['shared_result'], app_)


@pytest.fixture(scope='function')
def status(app: SphinxTestApp) -> StringIO:
    """
    compat for testing with previous @with_app decorator
    """
    return app._status


@pytest.fixture(scope='function')
def warning(app: SphinxTestApp) -> StringIO:
    """
    compat for testing with previous @with_app decorator
    """
    return app._warning


@pytest.fixture()
def make_app(test_params: Dict, monkeypatch: Any) -> Generator[Callable, None, None]:
    """
    provides make_app function to initialize SphinxTestApp instance.
    if you want to initialize 'app' in your test function. please use this
    instead of using SphinxTestApp class directory.
    """
    monkeypatch.setattr('sphinx.application.abspath', lambda x: x)

    apps = []
    syspath = sys.path[:]

    def make(*args, **kwargs):
        status, warning = StringIO(), StringIO()
        kwargs.setdefault('status', status)
        kwargs.setdefault('warning', warning)
        app_ = SphinxTestApp(*args, **kwargs)  # type: Any
        apps.append(app_)
        if test_params['shared_result']:
            app_ = SphinxTestAppWrapperForSkipBuilding(app_)
        return app_
    yield make

    sys.path[:] = syspath
    for app_ in reversed(apps):  # clean up applications from the new ones
        app_.cleanup()


@pytest.fixture
def shared_result() -> SharedResult:
    return SharedResult()


@pytest.fixture(scope='module', autouse=True)
def _shared_result_cache() -> None:
    SharedResult.cache.clear()


@pytest.fixture
def if_graphviz_found(app: SphinxTestApp) -> None:
    """
    The test will be skipped when using 'if_graphviz_found' fixture and graphviz
    dot command is not found.
    """
    graphviz_dot = getattr(app.config, 'graphviz_dot', '')
    try:
        if graphviz_dot:
            subprocess.run([graphviz_dot, '-V'], stdout=PIPE, stderr=PIPE)  # show version
            return
    except OSError:  # No such file or directory
        pass

    pytest.skip('graphviz "dot" is not available')


@pytest.fixture(scope='session')
def sphinx_test_tempdir(tmpdir_factory: Any) -> "util.path":
    """
    temporary directory that wrapped with `path` class.
    """
    tmpdir = os.environ.get('SPHINX_TEST_TEMPDIR')  # RemovedInSphinx40Warning
    if tmpdir is None:
        tmpdir = tmpdir_factory.getbasetemp()

    return util.path(tmpdir).abspath()


@pytest.fixture
def tempdir(tmpdir: str) -> "util.path":
    """
    temporary directory that wrapped with `path` class.
    this fixture is for compat with old test implementation.
    """
    return util.path(tmpdir)


@pytest.fixture
def rollback_sysmodules():
    """Rollback sys.modules to before testing to unload modules during tests."""
    try:
        sysmodules = list(sys.modules)
        yield
    finally:
        for modname in list(sys.modules):
            if modname not in sysmodules:
                sys.modules.pop(modname)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^html\\|^epub\\|BUILDDIR\\|doctrees\" Makefile | head -30; sed -n '45,65p' doc/usage/extensions/viewcode.rst"
}
```

**tool result**

```
   :event:`viewcode-follow-imported` event to resolve the name of the module
   by other extensions.  The default is ``True``.

   .. versionadded:: 1.3

   .. versionchanged:: 1.8
      Renamed from ``viewcode_import`` to ``viewcode_follow_imported_members``.

.. confval:: viewcode_enable_epub

   If this is ``True``, viewcode extension is also enabled even if you use
   epub builders. This extension generates pages outside toctree, but this
   is not preferred as epub format.

   Until 1.4.x, this extension is always enabled. If you want to generate
   epub as same as 1.4.x, you should set ``True``, but epub format checker's
   score becomes worse.

   The default is ``False``.

   .. versionadded:: 1.5
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class SphinxTestApp\\|def __init__\\|def build\" -n sphinx/testing/util.py | head -20; sed -n '100,220p' sphinx/testing/util.py"
}
```

**tool result**

```
96:    def __init__(self, **kwargs: Any) -> None:
100:class SphinxTestApp(application.Sphinx):
108:    def __init__(self, buildername: str = 'html', srcdir: path = None, freshenv: bool = False,
157:class SphinxTestAppWrapperForSkipBuilding:
164:    def __init__(self, app_: SphinxTestApp) -> None:
170:    def build(self, *args: Any, **kwargs: Any) -> None:
class SphinxTestApp(application.Sphinx):
    """
    A subclass of :class:`Sphinx` that runs on the test root, with some
    better default values for the initialization parameters.
    """
    _status = None  # type: StringIO
    _warning = None  # type: StringIO

    def __init__(self, buildername: str = 'html', srcdir: path = None, freshenv: bool = False,
                 confoverrides: Dict = None, status: IO = None, warning: IO = None,
                 tags: List[str] = None, docutilsconf: str = None, parallel: int = 0) -> None:

        if docutilsconf is not None:
            (srcdir / 'docutils.conf').write_text(docutilsconf)

        builddir = srcdir / '_build'
        confdir = srcdir
        outdir = builddir.joinpath(buildername)
        outdir.makedirs(exist_ok=True)
        doctreedir = builddir.joinpath('doctrees')
        doctreedir.makedirs(exist_ok=True)
        if confoverrides is None:
            confoverrides = {}
        warningiserror = False

        self._saved_path = sys.path[:]
        self._saved_directives = directives._directives.copy()  # type: ignore
        self._saved_roles = roles._roles.copy()  # type: ignore

        self._saved_nodeclasses = {v for v in dir(nodes.GenericNodeVisitor)
                                   if v.startswith('visit_')}

        try:
            super().__init__(srcdir, confdir, outdir, doctreedir,
                             buildername, confoverrides, status, warning,
                             freshenv, warningiserror, tags, parallel=parallel)
        except Exception:
            self.cleanup()
            raise

    def cleanup(self, doctrees: bool = False) -> None:
        ModuleAnalyzer.cache.clear()
        locale.translators.clear()
        sys.path[:] = self._saved_path
        sys.modules.pop('autodoc_fodder', None)
        directives._directives = self._saved_directives  # type: ignore
        roles._roles = self._saved_roles  # type: ignore
        for method in dir(nodes.GenericNodeVisitor):
            if method.startswith('visit_') and \
               method not in self._saved_nodeclasses:
                delattr(nodes.GenericNodeVisitor, 'visit_' + method[6:])
                delattr(nodes.GenericNodeVisitor, 'depart_' + method[6:])

    def __repr__(self) -> str:
        return '<%s buildername=%r>' % (self.__class__.__name__, self.builder.name)


class SphinxTestAppWrapperForSkipBuilding:
    """
    This class is a wrapper for SphinxTestApp to speed up the test by skipping
    `app.build` process if it is already built and there is even one output
    file.
    """

    def __init__(self, app_: SphinxTestApp) -> None:
        self.app = app_

    def __getattr__(self, name: str) -> Any:
        return getattr(self.app, name)

    def build(self, *args: Any, **kwargs: Any) -> None:
        if not self.app.outdir.listdir():  # type: ignore
            # if listdir is empty, do build.
            self.app.build(*args, **kwargs)
            # otherwise, we can use built cache


_unicode_literals_re = re.compile(r'u(".*?")|u(\'.*?\')')


def remove_unicode_literals(s: str) -> str:
    warnings.warn('remove_unicode_literals() is deprecated.',
                  RemovedInSphinx40Warning, stacklevel=2)
    return _unicode_literals_re.sub(lambda x: x.group(1) or x.group(2), s)


def find_files(root: str, suffix: bool = None) -> Generator[str, None, None]:
    for dirpath, dirs, files in os.walk(root, followlinks=True):
        dirpath = path(dirpath)
        for f in [f for f in files if not suffix or f.endswith(suffix)]:  # type: ignore
            fpath = dirpath / f
            yield relpath(fpath, root)


def strip_escseq(text: str) -> str:
    return re.sub('\x1b.*?m', '', text)


def simple_decorator(f):
    """
    A simple decorator that does nothing, for tests to use.
    """
    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        return f(*args, **kwargs)
    return wrapper
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,60p' Makefile; grep -n \"def build\\b\\|_viewcode_modules\\|purge\\|epub\" sphinx/builders/__init__.py | head"
}
```

**tool result**

```
PYTHON ?= python3

.PHONY: all
all: clean-pyc clean-backupfiles style-check type-check test

.PHONY: clean
clean: clean-pyc clean-pycache clean-patchfiles clean-backupfiles clean-generated clean-testfiles clean-buildfiles clean-mypyfiles

.PHONY: clean-pyc
clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +

.PHONY: clean-pycache
clean-pycache:
	find . -name __pycache__ -exec rm -rf {} +

.PHONY: clean-patchfiles
clean-patchfiles:
	find . -name '*.orig' -exec rm -f {} +
	find . -name '*.rej' -exec rm -f {} +

.PHONY: clean-backupfiles
clean-backupfiles:
	find . -name '*~' -exec rm -f {} +
	find . -name '*.bak' -exec rm -f {} +
	find . -name '*.swp' -exec rm -f {} +
	find . -name '*.swo' -exec rm -f {} +

.PHONY: clean-generated
clean-generated:
	find . -name '.DS_Store' -exec rm -f {} +
	rm -rf Sphinx.egg-info/
	rm -rf dist/
	rm -rf doc/_build/
	rm -f sphinx/pycode/*.pickle
	rm -f utils/*3.py*
	rm -f utils/regression_test.js

.PHONY: clean-testfiles
clean-testfiles:
	rm -rf tests/.coverage
	rm -rf tests/build
	rm -rf .tox/
	rm -rf .cache/

.PHONY: clean-buildfiles
clean-buildfiles:
	rm -rf build

.PHONY: clean-mypyfiles
clean-mypyfiles:
	find . -name '.mypy_cache' -exec rm -rf {} +

.PHONY: style-check
style-check:
	@flake8

.PHONY: type-check
type-check:
300:    def build(self, docnames: Iterable[str], summary: str = None, method: str = 'update') -> None:  # NOQA
400:            self.events.emit('env-purge-doc', self.env, docname)
436:            self.events.emit('env-purge-doc', self.env, docname)
443:            self.events.emit('env-purge-doc', self.env, docname)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sphinx/ext/viewcode.py\n@@\n def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], None, None]:\n     env = app.builder.env\n     if not hasattr(env, '_viewcode_modules'):\n         return\n+    if app.builder.name.startswith(\"epub\") and not env.config.viewcode_enable_epub:\n+        return\n     highlighter = app.builder.highlighter  # type: ignore\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sphinx/ext/viewcode.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sphinx/ext/viewcode.py now (297 lines), around the change:
181:def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], None, None]:
182:    env = app.builder.env
183:    if not hasattr(env, '_viewcode_modules'):
184:        return
185:    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
186:        return
187:    highlighter = app.builder.highlighter  # type: ignore
188:    urito = app.builder.get_relative_uri
```

**assistant → tool `bash`**

```json
{
  "command": "cat >> /tmp/patch_test.py <<'EOF'\nEOF\npython - <<'EOF'\nfrom pathlib import Path\np=Path('tests/test_ext_viewcode.py')\ns=p.read_text()\ns += '''\n\n@pytest.mark.sphinx('html', testroot='ext-viewcode')\ndef test_viewcode_epub_builder(app, make_app):\n    app.build()\n\n    # Build epub using the same source and doctree directories as the html build.\n    # The epub builder must not generate the module pages by default, even when\n    # they were generated for the html build.\n    epub_app = make_app('epub', srcdir=app.srcdir)\n    epub_app.build()\n\n    assert not (epub_app.outdir / '_modules').exists()\n'''\np.write_text(s)\nEOF\npython -m pytest tests/test_ext_viewcode.py -q"
}
```

**tool result**

```
Command FAILED (exit status 1): `cat >> /tmp/patch_test.py <<'EOF'
EOF
python - <<'EOF'
from pathlib import Path
p=Path('tests/test_ext_viewcode.py')
s=p.read_text()
s += '''

@pytest.mark.sphinx('html', testroot='ext-viewcode')
def test_viewcode_epub_builder(app, make_app):
    app.build()

    # Build epub using the same source and doctree directories as the html build.
    # The epub builder must not generate the module pages by default, even when
    # they were generated for the html build.
    epub_app = make_app('epub', srcdir=app.srcdir)
    epub_app.build()

    assert not (epub_app.outdir / '_modules').exists()
'''
p.write_text(s)
EOF
python -m pytest tests/test_ext_viewcode.py -q`
Output: F...                                                                     [100%]
=================================== FAILURES ===================================
________________________________ test_viewcode _________________________________

app = <SphinxTestApp buildername='html'>
status = <_io.StringIO object at 0x747c308620d0>
warning = <_io.StringIO object at 0x747c30862160>

    @pytest.mark.sphinx(testroot='ext-viewcode')
    def test_viewcode(app, status, warning):
        app.builder.build_all()
    
        warnings = re.sub(r'\\+', '/', warning.getvalue())
        assert re.findall(
            r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
            r"file .*/spam/__init__.py'",
            warnings
        )
    
        result = (app.outdir / 'index.html').read_text()
        assert result.count('href="_modules/spam/mod1.html#func1"') == 2
        assert result.count('href="_modules/spam/mod2.html#func2"') == 2
        assert result.count('href="_modules/spam/mod1.html#Class1"') == 2
        assert result.count('href="_modules/spam/mod2.html#Class2"') == 2
        assert result.count('@decorator') == 1
    
        # test that the class attribute is correctly documented
        assert result.count('this is Class3') == 2
        assert 'this is the class attribute class_attr' in result
        # the next assert fails, until the autodoc bug gets fixed
        assert result.count('this is the class attribute class_attr') == 2
    
        result = (app.outdir / '_modules/spam/mod1.html').read_text()
        result = re.sub('<span class=".*?">', '<span>', result)  # filter pygments classes
>       assert ('<div class="viewcode-block" id="Class1"><a class="viewcode-back" '
                'href="../../index.html#spam.Class1">[docs]</a>'
                '<span>@decorator</span>\n'
                '<span>class</span> <span>Class1</span>'
                '<span>(</span><span>object</span><span>):</span>\n'
                '    <span>&quot;&quot;&quot;</span>\n'
                '<span>    this is Class1</span>\n'
                '<span>    &quot;&quot;&quot;</span></div>\n') in result
E       assert '<div class="viewcode-block" id="Class1"><a class="viewcode-back" href="../../index.html#spam.Class1">[docs]</a><span>...an>\n    <span>&quot;&quot;&quot;</span>\n<span>    this is Class1</span>\n<span>    &quot;&quot;&quot;</span></div>\n' in '\n<!DOCTYPE html>\n\n<html>\n  <head>\n    <meta charset="utf-8" />\n    <meta name="viewport" content="width=device-..."https://github.com/bitprophet/alabaster">Alabaster 0.7.11</a>\n      \n    </div>\n\n    \n\n    \n  </body>\n</html>'

tests/test_ext_viewcode.py:42: AssertionError
--------------------------- Captured stdout teardown ---------------------------
# testroot: root
# builder: html
# srcdir: /tmp/pytest-of-root/pytest-0/ext-viewcode
# outdir: /tmp/pytest-of-root/pytest-0/ext-viewcode/_build/html
# status: 
[01mRunning Sphinx v3.5.0+/10011eea7[39;49;00m
[01mbuilding [html]: [39;49;00mall source files
[01mupdating environment: [39;49;00m[new config] 2 added, 0 changed, 0 removed
[01mreading sources... [39;49;00m[ 50%] [35mindex[39;49;00m                                                [01mreading sources... [39;49;00m[100%] [35mobjects[39;49;00m                                              
[01mlooking for now-outdated files... [39;49;00mnone found
[01mpickling environment... [39;49;00mdone
[01mchecking consistency... [39;49;00mdone
[01mpreparing documents... [39;49;00mdone
[01mwriting output... [39;49;00m[ 50%] [32mindex[39;49;00m                                                 [01mwriting output... [39;49;00m[100%] [32mobjects[39;49;00m                                               
[01mgenerating indices... [39;49;00mgenindex py-modindex done
[01mhighlighting module code... [39;49;00m[ 50%] [94mspam.mod1[39;49;00m                                   [01mhighlighting module code... [39;49;00m[100%] [94mspam.mod2[39;49;00m                                   
[01mwriting additional pages... [39;49;00msearch done
[01mcopying static files... [39;49;00mdone
[01mcopying extra files... [39;49;00mdone
[01mdumping search index in English (code: en)... [39;49;00mdone
[01mdumping object inventory... [39;49;00mdone

# warning: 
[91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/index.rst:23: WARNING: Object named 'func1' not found in include file '/tmp/pytest-of-root/pytest-0/ext-viewcode/spam/__init__.py'[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/spam/mod1.py:docstring of spam.mod1.Class3:1: WARNING: duplicate object description of spam.mod3.Class3, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/spam/mod1.py:docstring of spam.mod3.Class3.class_attr:1: WARNING: duplicate object description of spam.mod3.Class3.class_attr, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:84: WARNING: Error in declarator
If declarator-id with parameters (e.g., 'void f(int arg)'):
  Invalid C declaration: Expected identifier in nested name. [error at 18]
    Sphinx_DoSomething()
    ------------------^
If parenthesis in noptr-declarator (e.g., 'void (*f(int arg))(double)'):
  Error in declarator or parameters
  Invalid C declaration: Expected identifier in nested name. [error at 19]
    Sphinx_DoSomething()
    -------------------^
[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:86: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 19]
  SphinxStruct.member
  -------------------^[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:92: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 13]
  sphinx_global
  -------------^[39;49;00m
[31m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:155: WARNING: Unknown directive type "userdesc".

.. userdesc:: myobj:parameter

   Description of userdesc.[39;49;00m
[31m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:160: WARNING: Unknown interpreted text role "userdescrole".[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:166: WARNING: Too many template argument lists compared to parameter lists. Argument lists: 1, Parameter lists: 0, Extra empty parameters lists prepended: 1. Declaration:
	n::Array<T, d>[39;49;00m
[91m/tmp/pytest-of-root/pytest-0/ext-viewcode/objects.rst:117: WARNING: Unparseable C cross-reference: 'SphinxType *'
Invalid C declaration: Expected end of definition. [error at 11]
  SphinxType *
  -----------^[39;49;00m

=============================== warnings summary ===============================
sphinx/util/docutils.py:45
  /testbed/sphinx/util/docutils.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

sphinx/directives/patches.py:14
  /testbed/sphinx/directives/patches.py:14: DeprecationWarning: The `docutils.parsers.rst.directive.html` module will be removed in Docutils 2.0. Since Docutils 0.18, the "Meta" node is defined in `docutils.parsers.rst.directives.misc`.
    from docutils.parsers.rst.directives import html, images, tables

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:210: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse():  # type: Node

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.translatable):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:110: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for ref in self.document.traverse(nodes.substitution_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:131: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:150: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.block_quote):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:175: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.Element):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:222: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:189: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:279: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.doctest_block):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:116: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:135: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/latex/transforms.py:36: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:291: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/util/compat.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/index.py:51: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/math.py:84: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    self.data['has_equations'][docname] = any(document.traverse(math_node))

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:127: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(addnodes.download_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/title.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/ext/viewcode.py:91: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:301: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.system_message):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:390: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.manpage):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:488: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for inline in self.document.traverse(matcher):  # type: nodes.inline

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/python.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in result.traverse(nodes.Text):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:422: DeprecationWarning: The frontend.OptionParser class will be replaced by a subclass of argparse.ArgumentParser in Docutils 0.21 or later.
    self.docsettings = OptionParser(

tests/test_ext_viewcode.py: 360 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/optparse.py:1000: DeprecationWarning: The frontend.Option class will be removed in Docutils 0.21 or later.
    option = self.option_class(*args, **kwargs)

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/c.py:3494: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/cpp.py:7070: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:69: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.pending_xref):

tests/test_ext_viewcode.py: 47 warnings
  /testbed/sphinx/util/nodes.py:598: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.only):

tests/test_ext_viewcode.py: 24 warnings
  /testbed/sphinx/transforms/post_transforms/images.py:33: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.image):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:216: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.desc_sig_element):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:48: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.substitution_definition):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/transforms.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.literal

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:606: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.title):

tests/test_ext_viewcode.py: 36 warnings
  /testbed/sphinx/builders/latex/transforms.py:608: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for i, index in enumerate(node.traverse(addnodes.index)):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:43: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.highlightlang):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for lbnode in self.document.traverse(nodes.literal_block):  # type: nodes.literal_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:99: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for dbnode in self.document.traverse(nodes.doctest_block):  # type: nodes.doctest_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/environment/__init__.py:541: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:203: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for subtocnode in toc.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:261: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for refnode in newnode.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/__init__.py:181: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:844: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/adapters/toctree.py:312: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in toc.traverse(nodes.reference):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:114: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.
    _gaq.push(['_setAllowLinker', true]);

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:70: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:99: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:328: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:215: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:238: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:33: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:224: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:386: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:401: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:350: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for img in node.traverse(nodes.image):

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:352: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for raw in node.traverse(nodes.raw):

tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
  /testbed/sphinx/ext/linkcode.py:42: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:275: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for reference in tree.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for target in tree.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:290: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for desc_signature in tree.traverse(addnodes.desc_signature):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:340: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in tree.traverse(nodes.reference):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED tests/test_ext_viewcode.py::test_viewcode - assert '<div class="viewco...
1 failed, 3 passed, 1056 warnings in 2.81s

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "tail -30 tests/test_ext_viewcode.py && python -m pytest tests/test_ext_viewcode.py::test_viewcode_epub_builder -q 2>&1 | tail -5"
}
```

**tool result**

```

    warnings = re.sub(r'\\+', '/', warning.getvalue())
    assert re.findall(
        r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
        r"file .*/not_a_package/__init__.py'",
        warnings
    )

    result = (app.outdir / 'index.html').read_text()
    assert result.count('href="_modules/not_a_package.html#func1"') == 1
    assert result.count('href="_modules/not_a_package.html#not_a_package.submodule.func1"') == 1
    assert result.count('href="_modules/not_a_package/submodule.html#Class1"') == 1
    assert result.count('href="_modules/not_a_package/submodule.html#Class3"') == 1
    assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class1"') == 1

    assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class3.class_attr"') == 1
    assert result.count('This is the class attribute class_attr') == 1


@pytest.mark.sphinx('html', testroot='ext-viewcode')
def test_viewcode_epub_builder(app, make_app):
    app.build()

    # Build epub using the same source and doctree directories as the html build.
    # The epub builder must not generate the module pages by default, even when
    # they were generated for the html build.
    epub_app = make_app('epub', srcdir=app.srcdir)
    epub_app.build()

    assert not (epub_app.outdir / '_modules').exists()
  /testbed/sphinx/builders/_epub_base.py:340: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in tree.traverse(nodes.reference):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
1 passed, 434 warnings in 1.44s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_ext_viewcode.py::test_linkcode tests/test_ext_viewcode.py::test_local_source_files tests/test_ext_viewcode.py::test_viewcode_epub_builder -q 2>&1 | tail -3; git diff --stat; git diff sphinx/ext/viewcode.py"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
3 passed, 823 warnings in 4.13s
 sphinx/ext/viewcode.py     |  2 ++
 tests/test_ext_viewcode.py | 13 +++++++++++++
 2 files changed, 15 insertions(+)
diff --git a/sphinx/ext/viewcode.py b/sphinx/ext/viewcode.py
index a7d52a91c..060604e25 100755
--- a/sphinx/ext/viewcode.py
+++ b/sphinx/ext/viewcode.py
@@ -182,6 +182,8 @@ def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], Non
     env = app.builder.env
     if not hasattr(env, '_viewcode_modules'):
         return
+    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
+        return
     highlighter = app.builder.highlighter  # type: ignore
     urito = app.builder.get_relative_uri
```

**assistant**

````
Implemented the fix.

### Change
In `sphinx/ext/viewcode.py`, `collect_pages()` now skips module-page generation for EPUB builders unless `viewcode_enable_epub=True`:

```python
def collect_pages(app: Sphinx) -> ...:
    env = app.builder.env
    if not hasattr(env, '_viewcode_modules'):
        return
    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
        return
```

Previously only `doctree_read()` honored `viewcode_enable_epub`. On `make html epub`, the shared environment already contained `_viewcode_modules` from the HTML build, so `collect_pages()` generated `_modules/*` pages for EPUB even though the config default is `False`.

### Test
Added `test_viewcode_epub_builder` to `tests/test_ext_viewcode.py`, which builds HTML (populating `_modules`), then builds EPUB from the same source/doctree and asserts no `_modules` directory is produced.

### Verification
- New EPUB regression test passes.
- `test_linkcode` and `test_local_source_files` pass.
- The pre-existing `test_viewcode` HTML-highlighting assertion still fails due to environment/Pygments output differences; it is unrelated to this change.
- No commit/checkout/reset/stash performed.
````

## Run folder `team-solve-2026-11-06T133747`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
10011eea7452d83281547d452d6d4edbcae12dcc
```

### `baseline-check.log`

```
check: python -m pytest tests/test_ext_viewcode.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-8.3.3, pluggy-1.5.0
libraries: Sphinx-3.5.0+/10011eea7, docutils-0.21.2
base tempdir: /tmp/pytest-of-root/pytest-1
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree
configfile: setup.cfg
plugins: cov-5.0.0
collected 3 items

tests/test_ext_viewcode.py F..                                           [100%]

=================================== FAILURES ===================================
________________________________ test_viewcode _________________________________

app = <SphinxTestApp buildername='html'>
status = <_io.StringIO object at 0x7e5551338700>
warning = <_io.StringIO object at 0x7e5551338f70>

    @pytest.mark.sphinx(testroot='ext-viewcode')
    def test_viewcode(app, status, warning):
        app.builder.build_all()
    
        warnings = re.sub(r'\\+', '/', warning.getvalue())
        assert re.findall(
            r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
            r"file .*/spam/__init__.py'",
            warnings
        )
    
        result = (app.outdir / 'index.html').read_text()
        assert result.count('href="_modules/spam/mod1.html#func1"') == 2
        assert result.count('href="_modules/spam/mod2.html#func2"') == 2
        assert result.count('href="_modules/spam/mod1.html#Class1"') == 2
        assert result.count('href="_modules/spam/mod2.html#Class2"') == 2
        assert result.count('@decorator') == 1
    
        # test that the class attribute is correctly documented
        assert result.count('this is Class3') == 2
        assert 'this is the class attribute class_attr' in result
        # the next assert fails, until the autodoc bug gets fixed
        assert result.count('this is the class attribute class_attr') == 2
    
        result = (app.outdir / '_modules/spam/mod1.html').read_text()
        result = re.sub('<span class=".*?">', '<span>', result)  # filter pygments classes
>       assert ('<div class="viewcode-block" id="Class1"><a class="viewcode-back" '
                'href="../../index.html#spam.Class1">[docs]</a>'
                '<span>@decorator</span>\n'
                '<span>class</span> <span>Class1</span>'
                '<span>(</span><span>object</span><span>):</span>\n'
                '    <span>&quot;&quot;&quot;</span>\n'
                '<span>    this is Class1</span>\n'
                '<span>    &quot;&quot;&quot;</span></div>\n') in result
E       assert '<div class="viewcode-block" id="Class1"><a class="viewcode-back" href="../../index.html#spam.Class1">[docs]</a><span>...an>\n    <span>&quot;&quot;&quot;</span>\n<span>    this is Class1</span>\n<span>    &quot;&quot;&quot;</span></div>\n' in '\n<!DOCTYPE html>\n\n<html>\n  <head>\n    <meta charset="utf-8" />\n    <meta name="viewport" content="width=device-..."https://github.com/bitprophet/alabaster">Alabaster 0.7.11</a>\n      \n    </div>\n\n    \n\n    \n  </body>\n</html>'

tests/test_ext_viewcode.py:42: AssertionError
--------------------------- Captured stdout teardown ---------------------------
# testroot: root
# builder: html
# srcdir: /tmp/pytest-of-root/pytest-1/ext-viewcode
# outdir: /tmp/pytest-of-root/pytest-1/ext-viewcode/_build/html
# status: 
[01mRunning Sphinx v3.5.0+/10011eea7[39;49;00m
[01mbuilding [html]: [39;49;00mall source files
[01mupdating environment: [39;49;00m[new config] 2 added, 0 changed, 0 removed
[01mreading sources... [39;49;00m[ 50%] [35mindex[39;49;00m                                                [01mreading sources... [39;49;00m[100%] [35mobjects[39;49;00m                                              
[01mlooking for now-outdated files... [39;49;00mnone found
[01mpickling environment... [39;49;00mdone
[01mchecking consistency... [39;49;00mdone
[01mpreparing documents... [39;49;00mdone
[01mwriting output... [39;49;00m[ 50%] [32mindex[39;49;00m                                                 [01mwriting output... [39;49;00m[100%] [32mobjects[39;49;00m                                               
[01mgenerating indices... [39;49;00mgenindex py-modindex done
[01mhighlighting module code... [39;49;00m[ 50%] [94mspam.mod1[39;49;00m                                   [01mhighlighting module code... [39;49;00m[100%] [94mspam.mod2[39;49;00m                                   
[01mwriting additional pages... [39;49;00msearch done
[01mcopying static files... [39;49;00mdone
[01mcopying extra files... [39;49;00mdone
[01mdumping search index in English (code: en)... [39;49;00mdone
[01mdumping object inventory... [39;49;00mdone

# warning: 
[91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/index.rst:23: WARNING: Object named 'func1' not found in include file '/tmp/pytest-of-root/pytest-1/ext-viewcode/spam/__init__.py'[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/spam/mod1.py:docstring of spam.mod1.Class3:1: WARNING: duplicate object description of spam.mod3.Class3, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/spam/mod1.py:docstring of spam.mod3.Class3.class_attr:1: WARNING: duplicate object description of spam.mod3.Class3.class_attr, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:84: WARNING: Error in declarator
If declarator-id with parameters (e.g., 'void f(int arg)'):
  Invalid C declaration: Expected identifier in nested name. [error at 18]
    Sphinx_DoSomething()
    ------------------^
If parenthesis in noptr-declarator (e.g., 'void (*f(int arg))(double)'):
  Error in declarator or parameters
  Invalid C declaration: Expected identifier in nested name. [error at 19]
    Sphinx_DoSomething()
    -------------------^
[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:86: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 19]
  SphinxStruct.member
  -------------------^[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:92: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 13]
  sphinx_global
  -------------^[39;49;00m
[31m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:155: WARNING: Unknown directive type "userdesc".

.. userdesc:: myobj:parameter

   Description of userdesc.[39;49;00m
[31m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:160: WARNING: Unknown interpreted text role "userdescrole".[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:166: WARNING: Too many template argument lists compared to parameter lists. Argument lists: 1, Parameter lists: 0, Extra empty parameters lists prepended: 1. Declaration:
	n::Array<T, d>[39;49;00m
[91m/tmp/pytest-of-root/pytest-1/ext-viewcode/objects.rst:117: WARNING: Unparseable C cross-reference: 'SphinxType *'
Invalid C declaration: Expected end of definition. [error at 11]
  SphinxType *
  -----------^[39;49;00m

=============================== warnings summary ===============================
sphinx/util/docutils.py:45
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/util/docutils.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../../../../../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

sphinx/directives/patches.py:14
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/directives/patches.py:14: DeprecationWarning: The `docutils.parsers.rst.directive.html` module will be removed in Docutils 2.0. Since Docutils 0.18, the "Meta" node is defined in `docutils.parsers.rst.directives.misc`.
    from docutils.parsers.rst.directives import html, images, tables

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:210: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse():  # type: Node

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/i18n.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.translatable):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:110: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for ref in self.document.traverse(nodes.substitution_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:131: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:150: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.block_quote):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:175: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.Element):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:222: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:189: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:279: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.doctest_block):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/citation.py:116: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/citation.py:135: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/latex/transforms.py:36: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:291: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/util/compat.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/index.py:51: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/math.py:84: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    self.data['has_equations'][docname] = any(document.traverse(math_node))

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/collectors/asset.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/collectors/asset.py:127: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(addnodes.download_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/collectors/title.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/ext/viewcode.py:91: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:301: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.system_message):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/__init__.py:390: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.manpage):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/i18n.py:488: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for inline in self.document.traverse(matcher):  # type: nodes.inline

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/python.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in result.traverse(nodes.Text):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/html/__init__.py:422: DeprecationWarning: The frontend.OptionParser class will be replaced by a subclass of argparse.ArgumentParser in Docutils 0.21 or later.
    self.docsettings = OptionParser(

tests/test_ext_viewcode.py: 216 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/optparse.py:1000: DeprecationWarning: The frontend.Option class will be removed in Docutils 0.21 or later.
    option = self.option_class(*args, **kwargs)

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/c.py:3494: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/domains/cpp.py:7070: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/post_transforms/__init__.py:69: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.pending_xref):

tests/test_ext_viewcode.py: 25 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/util/nodes.py:598: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.only):

tests/test_ext_viewcode.py: 10 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/post_transforms/images.py:33: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/post_transforms/__init__.py:216: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.desc_sig_element):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/latex/transforms.py:48: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.substitution_definition):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/html/transforms.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.literal

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/latex/transforms.py:606: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.title):

tests/test_ext_viewcode.py: 17 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/latex/transforms.py:608: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for i, index in enumerate(node.traverse(addnodes.index)):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/post_transforms/code.py:43: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.highlightlang):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/post_transforms/code.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for lbnode in self.document.traverse(nodes.literal_block):  # type: nodes.literal_block

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/transforms/post_transforms/code.py:99: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for dbnode in self.document.traverse(nodes.doctest_block):  # type: nodes.doctest_block

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/__init__.py:541: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 15 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/adapters/toctree.py:203: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for subtocnode in toc.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 15 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/adapters/toctree.py:261: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for refnode in newnode.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/__init__.py:181: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/builders/html/__init__.py:844: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/adapters/toctree.py:312: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in toc.traverse(nodes.reference):

tests/test_ext_viewcode.py: 20 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:114: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.
    _gaq.push(['_setAllowLinker', true]);

tests/test_ext_viewcode.py: 20 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:70: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 20 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:99: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 20 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/environment/adapters/toctree.py:328: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 20 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:215: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 20 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:238: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  <template>:33: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  <template>:224: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  <template>:386: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
  <template>:401: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 10 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/util/nodes.py:350: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for img in node.traverse(nodes.image):

tests/test_ext_viewcode.py: 10 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/util/nodes.py:352: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for raw in node.traverse(nodes.raw):

tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
  /testbed/.memdoor/runs/team-solve-2026-11-06T133747/baseline-tree/sphinx/ext/linkcode.py:42: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED tests/test_ext_viewcode.py::test_viewcode - assert '<div class="viewco...
================== 1 failed, 2 passed, 647 warnings in 3.60s ===================
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sphinx/ext/viewcode.py b/sphinx/ext/viewcode.py
index a7d52a91c..060604e25 100755
--- a/sphinx/ext/viewcode.py
+++ b/sphinx/ext/viewcode.py
@@ -182,6 +182,8 @@ def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], Non
     env = app.builder.env
     if not hasattr(env, '_viewcode_modules'):
         return
+    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
+        return
     highlighter = app.builder.highlighter  # type: ignore
     urito = app.builder.get_relative_uri
 
diff --git a/tests/test_ext_viewcode.py b/tests/test_ext_viewcode.py
index 79864095b..fa97b0e79 100755
--- a/tests/test_ext_viewcode.py
+++ b/tests/test_ext_viewcode.py
@@ -102,3 +102,16 @@ def test_local_source_files(app, status, warning):
 
     assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class3.class_attr"') == 1
     assert result.count('This is the class attribute class_attr') == 1
+
+
+@pytest.mark.sphinx('html', testroot='ext-viewcode')
+def test_viewcode_epub_builder(app, make_app):
+    app.build()
+
+    # Build epub using the same source and doctree directories as the html build.
+    # The epub builder must not generate the module pages by default, even when
+    # they were generated for the html build.
+    epub_app = make_app('epub', srcdir=app.srcdir)
+    epub_app.build()
+
+    assert not (epub_app.outdir / '_modules').exists()
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

viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`
**Describe the bug**
viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`

**To Reproduce**
```
$ make html epub
```

**Expected behavior**
module pages should not be created for epub by default.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions:  sphinx.ext.viewcode
- Extra tools: No

**Additional context**
No

## Deliverable

changes to this tree

## Check

`python -m pytest tests/test_ext_viewcode.py`

## Scope

`sphinx/ext/viewcode.py`
`tests/`

## Done when

Building `make html epub` with `viewcode_enable_epub=False` creates no viewcode module pages in the epub output.
The epub skip still applies when the `html` build runs first and the `epub` build reuses the environment.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest tests/test_ext_viewcode.py`

## Scope
`sphinx/ext/viewcode.py`
`tests/`

## Done when
Building `make html epub` with `viewcode_enable_epub=False` creates no viewcode module pages in the epub output.
The epub skip still applies when the `html` build runs first and the `epub` build reuses the environment.

## Approach
Trace `sphinx/ext/viewcode.py`: `collect_pages` handles the `html-collect-pages` event and yields one module page per entry in `env._viewcode_modules`. Because the `html` build can populate that environment before the `epub` build reuses it, any skip must happen at page-collection time, not only during `doctree-read`.

Preferred approach: in `collect_pages`, return early or continue past each module when the active builder is epub and `viewcode_enable_epub` is false. Add a regression test under `tests/` that builds `html` then `epub` with the default false config and asserts no `_modules/` pages are emitted; also confirm the true setting still emits them if the existing test fixture supports it.

Candidate alternatives if the first fails:
1. Clear or bypass `env._viewcode_modules` for epub builds before page collection, but ensure this does not corrupt the shared environment for later builders.
2. Filter viewcode pages in the EPUB builder’s additional-page generation; this is broader and couples the builder to an extension, so use only if `collect_pages` cannot distinguish the builder reliably.
3. Check `app.builder.format == 'epub'` instead of `app.builder.name == 'epub'` if builder naming differs in the failing path.


# sphinx/ext/viewcode.py

```
"""
    sphinx.ext.viewcode
    ~~~~~~~~~~~~~~~~~~~

    Add links to module code in Python object descriptions.

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import posixpath
import traceback
from os import path
from typing import Any, Dict, Generator, Iterable, Optional, Set, Tuple, cast

from docutils import nodes
from docutils.nodes import Element, Node

import sphinx
from sphinx import addnodes
from sphinx.application import Sphinx
from sphinx.builders.html import StandaloneHTMLBuilder
from sphinx.environment import BuildEnvironment
from sphinx.locale import _, __
from sphinx.pycode import ModuleAnalyzer
from sphinx.util import get_full_modname, logging, status_iterator
from sphinx.util.nodes import make_refnode

logger = logging.getLogger(__name__)


OUTPUT_DIRNAME = '_modules'


def _get_full_modname(app: Sphinx, modname: str, attribute: str) -> Optional[str]:
    try:
        return get_full_modname(modname, attribute)
    except AttributeError:
        # sphinx.ext.viewcode can't follow class instance attribute
        # then AttributeError logging output only verbose mode.
        logger.verbose('Didn\'t find %s in %s', attribute, modname)
        return None
    except Exception as e:
        # sphinx.ext.viewcode follow python domain directives.
        # because of that, if there are no real modules exists that specified
        # by py:function or other directives, viewcode emits a lot of warnings.
        # It should be displayed only verbose mode.
        logger.verbose(traceback.format_exc().rstrip())
        logger.verbose('viewcode can\'t import %s, failed with error "%s"', modname, e)
        return None


def doctree_read(app: Sphinx, doctree: Node) -> None:
    env = app.builder.env
    if not hasattr(env, '_viewcode_modules'):
        env._viewcode_modules = {}  # type: ignore
    if app.builder.name == "singlehtml":
        return
    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
        return

    def has_tag(modname: str, fullname: str, docname: str, refname: str) -> bool:
        entry = env._viewcode_modules.get(modname, None)  # type: ignore
        if entry is False:
            return False

        code_tags = app.emit_firstresult('viewcode-find-source', modname)
        if code_tags is None:
            try:
                analyzer = ModuleAnalyzer.for_module(modname)
                analyzer.find_tags()
            except Exception:
                env._viewcode_modules[modname] = False  # type: ignore
                return False

            code = analyzer.code
            tags = analyzer.tags
        else:
            code, tags = code_tags

        if entry is None or entry[0] != code:
            entry = code, tags, {}, refname
            env._viewcode_modules[modname] = entry  # type: ignore
        _, tags, used, _ = entry
        if fullname in tags:
            used[fullname] = docname
            return True

        return False

    for objnode in doctree.traverse(addnodes.desc):
        if objnode.get('domain') != 'py':
            continue
        names = set()  # type: Set[str]
        for signode in objnode:
            if not isinstance(signode, addnodes.desc_signature):
                continue
            modname = signode.get('module')
            fullname = signode.get('fullname')
            refname = modname
            if env.config.viewcode_follow_imported_members:
                new_modname = app.emit_firstresult(
                    'viewcode-follow-imported', modname, fullname,
                )
                if not new_modname:
                    new_modname = _get_full_modname(app, modname, fullname)
                modname = new_modname
            if not modname:
                continue
            fullname = signode.get('fullname')
            if not has_tag(modname, fullname, env.docname, refname):
                continue
            if fullname in names:
                # only one link per name, please
                continue
            names.add(fullname)
            pagename = posixpath.join(OUTPUT_DIRNAME, modname.replace('.', '/'))
            inline = nodes.inline('', _('[source]'), classes=['viewcode-link'])
            onlynode = addnodes.only(expr='html')
            onlynode += addnodes.pending_xref('', inline, reftype='viewcode', refdomain='std',
                                              refexplicit=False, reftarget=pagename,
                                              refid=fullname, refdoc=env.docname)
            signode += onlynode


def env_merge_info(app: Sphinx, env: BuildEnvironment, docnames: Iterable[str],
                   other: BuildEnvironment) -> None:
    if not hasattr(other, '_viewcode_modules'):
        return
    # create a _viewcode_modules dict on the main environment
    if not hasattr(env, '_viewcode_modules'):
        env._viewcode_modules = {}  # type: ignore
    # now merge in the information from the subprocess
    env._viewcode_modules.update(other._viewcode_modules)  # type: ignore


def missing_reference(app: Sphinx, env: BuildEnvironment, node: Element, contnode: Node
                      ) -> Optional[Node]:
    # resolve our "viewcode" reference nodes -- they need special treatment
    if node['reftype'] == 'viewcode':
        return make_refnode(app.builder, node['refdoc'], node['reftarget'],
                            node['refid'], contnode)

    return None


def get_module_filename(app: Sphinx, modname: str) -> Optional[str]:
    """Get module filename for *modname*."""
    source_info = app.emit_firstresult('viewcode-find-source', modname)
    if source_info:
        return None
    else:
        try:
            filename, source = ModuleAnalyzer.get_module_source(modname)
            return filename
        except Exception:
            return None


def should_generate_module_page(app: Sphinx, modname: str) -> bool:
    """Check generation of module page is needed."""
    module_filename = get_module_filename(app, modname)
    if module_filename is None:
        # Always (re-)generate module page when module filename is not found.
        return True

    builder = cast(StandaloneHTMLBuilder, app.builder)
    basename = modname.replace('.', '/') + builder.out_suffix
    page_filename = path.join(app.outdir, '_modules/', basename)

    try:
        if path.getmtime(module_filename) <= path.getmtime(page_filename):
            # generation is not needed if the HTML page is newer than module file.
            return False
    except IOError:
        pass

    return True


def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], None, None]:
    env = app.builder.env
    if not hasattr(env, '_viewcode_modules'):
        return
    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
        return
    highlighter = app.builder.highlighter  # type: ignore
    urito = app.builder.get_relative_uri

    modnames = set(env._viewcode_modules)  # type: ignore

    for modname, entry in status_iterator(
            sorted(env._viewcode_modules.items()),  # type: ignore
            __('highlighting module code... '), "blue",
            len(env._viewcode_modules),  # type: ignore
            app.verbosity, lambda x: x[0]):
        if not entry:
            continue
        if not should_generate_module_page(app, modname):
            continue

        code, tags, used, refname = entry
        # construct a page name for the highlighted source
        pagename = posixpath.join(OUTPUT_DIRNAME, modname.replace('.', '/'))
        # highlight the source using the builder's highlighter
        if env.config.highlight_language in ('python3', 'default', 'none'):
            lexer = env.config.highlight_language
        else:
            lexer = 'python'
        highlighted = highlighter.highlight_block(code, lexer, linenos=False)
        # split the code into lines
        lines = highlighted.splitlines()
        # split off wrap markup from the first line of the actual code
        before, after = lines[0].split('<pre>')
        lines[0:1] = [before + '<pre>', after]
        # nothing to do for the last line; it always starts with </pre> anyway
        # now that we have code lines (starting at index 1), insert anchors for
        # the collected tags (HACK: this only works if the tag boundaries are
        # properly nested!)
        maxindex = len(lines) - 1
        for name, docname in used.items():
            type, start, end = tags[name]
            backlink = urito(pagename, docname) + '#' + refname + '.' + name
            lines[start] = (
                '<div class="viewcode-block" id="%s"><a class="viewcode-back" '
                'href="%s">%s</a>' % (name, backlink, _('[docs]')) +
                lines[start])
            lines[min(end, maxindex)] += '</div>'
        # try to find parents (for submodules)
        parents = []
        parent = modname
        while '.' in parent:
            parent = parent.rsplit('.', 1)[0]
            if parent in modnames:
                parents.append({
                    'link': urito(pagename,
                                  posixpath.join(OUTPUT_DIRNAME, parent.replace('.', '/'))),
                    'title': parent})
        parents.append({'link': urito(pagename, posixpath.join(OUTPUT_DIRNAME, 'index')),
                        'title': _('Module code')})
        parents.reverse()
        # putting it all together
        context = {
            'parents': parents,
            'title': modname,
            'body': (_('<h1>Source code for %s</h1>') % modname +
                     '\n'.join(lines)),
        }
        yield (pagename, context, 'page.html')

    if not modnames:
        return

    html = ['\n']
    # the stack logic is needed for using nested lists for submodules
    stack = ['']
    for modname in sorted(modnames):
        if modname.startswith(stack[-1]):
            stack.append(modname + '.')
            html.append('<ul>')
        else:
            stack.pop()
            while not modname.startswith(stack[-1]):
                stack.pop()
                html.append('</ul>')
            stack.append(modname + '.')
        html.append('<li><a href="%s">%s</a></li>\n' % (
            urito(posixpath.join(OUTPUT_DIRNAME, 'index'),
                  posixpath.join(OUTPUT_DIRNAME, modname.replace('.', '/'))),
            modname))
    html.append('</ul>' * (len(stack) - 1))
    context = {
        'title': _('Overview: module code'),
        'body': (_('<h1>All modules for which code is available</h1>') +
                 ''.join(html)),
    }

    yield (posixpath.join(OUTPUT_DIRNAME, 'index'), context, 'page.html')


def setup(app: Sphinx) -> Dict[str, Any]:
    app.add_config_value('viewcode_import', None, False)
    app.add_config_value('viewcode_enable_epub', False, False)
    app.add_config_value('viewcode_follow_imported_members', True, False)
    app.connect('doctree-read', doctree_read)
    app.connect('env-merge-info', env_merge_info)
    app.connect('html-collect-pages', collect_pages)
    app.connect('missing-reference', missing_reference)
    # app.add_config_value('viewcode_include_modules', [], 'env')
    # app.add_config_value('viewcode_exclude_modules', [], 'env')
    app.add_event('viewcode-find-source')
    app.add_event('viewcode-follow-imported')
    return {
        'version': sphinx.__display_version__,
        'env_version': 1,
        'parallel_read_safe': True
    }

```


# tests (the files in it)

tests/__init__.py
tests/certs/cert.pem
tests/conftest.py
tests/ext_napoleon_pep526_data_google.py
tests/ext_napoleon_pep526_data_numpy.py
tests/js/doctools.js
tests/roots/test-add_enumerable_node/conf.py
tests/roots/test-add_enumerable_node/enumerable_node.py
tests/roots/test-add_enumerable_node/index.rst
tests/roots/test-add_enumerable_node/rimg.png
tests/roots/test-add_source_parser-conflicts-with-users-setting/conf.py
tests/roots/test-add_source_parser-conflicts-with-users-setting/source_parser.py
tests/roots/test-add_source_parser/conf.py
tests/roots/test-add_source_parser/source_parser.py
tests/roots/test-api-set-translator/conf.py
tests/roots/test-api-set-translator/index.rst
tests/roots/test-api-set-translator/nonext/conf.py
tests/roots/test-api-set-translator/translator.py
tests/roots/test-apidoc-pep420/a/b/c/__init__.py
tests/roots/test-apidoc-pep420/a/b/c/d.py
tests/roots/test-apidoc-pep420/a/b/e/__init__.py
tests/roots/test-apidoc-pep420/a/b/e/f.py
tests/roots/test-apidoc-pep420/a/b/x/y.py
tests/roots/test-apidoc-subpackage-in-toc/parent/__init__.py
tests/roots/test-apidoc-subpackage-in-toc/parent/child/__init__.py
tests/roots/test-apidoc-subpackage-in-toc/parent/child/foo.py
tests/roots/test-apidoc-toc/mypackage/__init__.py
tests/roots/test-apidoc-toc/mypackage/main.py
tests/roots/test-apidoc-toc/mypackage/no_init/foo.py
tests/roots/test-apidoc-toc/mypackage/resource/__init__.py
tests/roots/test-apidoc-toc/mypackage/resource/resource.txt
tests/roots/test-apidoc-toc/mypackage/something/__init__.py
tests/roots/test-apidoc-trailing-underscore/package_/__init__.py
tests/roots/test-apidoc-trailing-underscore/package_/module_.py
tests/roots/test-autosummary/conf.py
tests/roots/test-autosummary/dummy_module.py
tests/roots/test-autosummary/index.rst
tests/roots/test-autosummary/sphinx.rst
tests/roots/test-autosummary/underscore_module_.py
tests/roots/test-basic/conf.py
tests/roots/test-basic/index.rst
tests/roots/test-build-html-translator/conf.py
tests/roots/test-build-html-translator/index.rst
tests/roots/test-build-text/conf.py
tests/roots/test-build-text/doc1.txt
tests/roots/test-build-text/doc2.txt
tests/roots/test-build-text/index.txt
tests/roots/test-build-text/lineblock.txt
tests/roots/test-build-text/listitems.txt
tests/roots/test-build-text/maxwidth.txt
tests/roots/test-build-text/nonascii_maxwidth.txt
tests/roots/test-build-text/nonascii_table.txt
tests/roots/test-build-text/nonascii_title.txt
tests/roots/test-build-text/table.txt
tests/roots/test-build-text/table_colspan.txt
tests/roots/test-build-text/table_colspan_and_rowspan.txt
tests/roots/test-build-text/table_colspan_left.txt
tests/roots/test-build-text/table_rowspan.txt
tests/roots/test-builder-dirhtml/bar.rst
tests/roots/test-builder-dirhtml/conf.py
tests/roots/test-builder-dirhtml/foo/foo_1.rst
tests/roots/test-builder-dirhtml/foo/foo_2.rst
tests/roots/test-builder-dirhtml/foo/index.rst
tests/roots/test-builder-dirhtml/index.rst
tests/roots/test-builder-gettext-dont-rebuild-mo/bom.rst
tests/roots/test-builder-gettext-dont-rebuild-mo/conf.py
tests/roots/test-builder-gettext-dont-rebuild-mo/index.rst
tests/roots/test-builder-gettext-dont-rebuild-mo/xx/LC_MESSAGES/bom.po
tests/roots/test-changes/base.rst
tests/roots/test-changes/c-api.rst
tests/roots/test-changes/conf.py
tests/roots/test-changes/contents.rst
tests/roots/test-changes/library/utils.rst
tests/roots/test-circular/conf.py
tests/roots/test-circular/index.rst
tests/roots/test-circular/sub.rst
tests/roots/test-config/conf.py
tests/roots/test-correct-year/conf.py
tests/roots/test-correct-year/index.rst
tests/roots/test-default_role/conf.py
tests/roots/test-default_role/foo.rst
tests/roots/test-default_role/index.rst
tests/roots/test-directive-code/caption.rst
tests/roots/test-directive-code/classes.rst
tests/roots/test-directive-code/conf.py
tests/roots/test-directive-code/emphasize.rst
tests/roots/test-directive-code/empty.inc
tests/roots/test-directive-code/error.inc
tests/roots/test-directive-code/force.rst
tests/roots/test-directive-code/highlight.rst
tests/roots/test-directive-code/index.rst
tests/roots/test-directive-code/linenos.rst
tests/roots/test-directive-code/linenothreshold.rst
tests/roots/test-directive-code/literal-diff.inc
tests/roots/test-directive-code/literal-short.inc
tests/roots/test-directive-code/literal.inc
tests/roots/test-directive-code/namedblocks.rst
tests/roots/test-directive-code/py-decorators.inc
tests/roots/test-directive-code/py-decorators.rst
tests/roots/test-directive-code/python.rst
tests/roots/test-directive-code/target.py
tests/roots/test-directive-only/conf.py
tests/roots/test-directive-only/index.rst
tests/roots/test-directive-only/only.rst
tests/roots/test-directives-raw/conf.py
tests/roots/test-directives-raw/index.rst
tests/roots/test-docutilsconf/conf.py
tests/roots/test-docutilsconf/docutils.conf
tests/roots/test-docutilsconf/index.rst
tests/roots/test-domain-c-intersphinx/conf.py
tests/roots/test-domain-c-intersphinx/index.rst
tests/roots/test-domain-c/anon-dup-decl.rst
tests/roots/test-domain-c/conf.py
tests/roots/test-domain-c/function_param_target.rst
tests/roots/test-domain-c/index.rst
tests/roots/test-domain-c/namespace.rst
tests/roots/test-domain-c/semicolon.rst
tests/roots/test-domain-cpp-intersphinx/conf.py
tests/roots/test-domain-cpp-intersphinx/index.rst
tests/roots/test-domain-cpp/anon-dup-decl.rst
tests/roots/test-domain-cpp/any-role.rst
tests/roots/test-domain-cpp/backslash.rst
tests/roots/test-domain-cpp/conf.py
tests/roots/test-domain-cpp/index.rst
tests/roots/test-domain-cpp/lookup-key-overload.rst
tests/roots/test-domain-cpp/multi-decl-lookup.rst
tests/roots/test-domain-cpp/roles-targets-ok.rst
tests/roots/test-domain-cpp/roles-targets-warn.rst
tests/roots/test-domain-cpp/roles.rst
tests/roots/test-domain-cpp/roles2.rst
tests/roots/test-domain-cpp/semicolon.rst
tests/roots/test-domain-cpp/warn-template-param-qualified-name.rst
tests/roots/test-domain-cpp/xref_consistency.rst
tests/roots/test-domain-js/conf.py
tests/roots/test-domain-js/index.rst
tests/roots/test-domain-js/module.rst
tests/roots/test-domain-js/roles.rst
tests/roots/test-domain-py-xref-warning/conf.py
tests/roots/test-domain-py-xref-warning/index.rst
tests/roots/test-domain-py/abbr.rst
tests/roots/test-domain-py/conf.py
tests/roots/test-domain-py/index.rst
tests/roots/test-domain-py/module.rst
tests/roots/test-domain-py/module_option.rst
tests/roots/test-domain-py/roles.rst
tests/roots/test-double-inheriting-theme/base_themes_dir/base_theme1/theme.conf
tests/roots/test-double-inheriting-theme/base_themes_dir/base_theme2/theme.conf
tests/roots/test-double-inheriting-theme/conf.py
tests/roots/test-double-inheriting-theme/index.rst
tests/roots/test-epub-anchor-id/conf.py
tests/roots/test-epub-anchor-id/index.rst
tests/roots/test-ext-autodoc/autodoc_dummy_bar.py
tests/roots/test-ext-autodoc/autodoc_dummy_module.py
tests/roots/test-ext-autodoc/bug2437/__init__.py
tests/roots/test-ext-autodoc/bug2437/autodoc_dummy_foo.py
tests/roots/test-ext-autodoc/conf.py
tests/roots/test-ext-autodoc/index.rst
tests/roots/test-ext-autodoc/target/TYPE_CHECKING.py
tests/roots/test-ext-autodoc/target/__init__.py
tests/roots/test-ext-autodoc/target/abstractmethods.py
tests/roots/test-ext-autodoc/target/annotated.py
tests/roots/test-ext-autodoc/target/annotations.py
tests/roots/test-ext-autodoc/target/autoclass_content.py
tests/roots/test-ext-autodoc/target/bound_method.py
tests/roots/test-ext-autodoc/target/cached_property.py
tests/roots/test-ext-autodoc/target/callable.py
tests/roots/test-ext-autodoc/target/classes.py
tests/roots/test-ext-autodoc/target/coroutine.py
tests/roots/test-ext-autodoc/target/cython.pyx
tests/roots/test-ext-autodoc/target/decorator.py
tests/roots/test-ext-autodoc/target/descriptor.py
tests/roots/test-ext-autodoc/target/docstring_signature.py
tests/roots/test-ext-autodoc/target/empty_all.py
tests/roots/test-ext-autodoc/target/enums.py
tests/roots/test-ext-autodoc/target/final.py
tests/roots/test-ext-autodoc/target/functions.py
tests/roots/test-ext-autodoc/target/generic_class.py
tests/roots/test-ext-autodoc/target/genericalias.py
tests/roots/test-ext-autodoc/target/hide_value.py
tests/roots/test-ext-autodoc/target/imported_members.py
tests/roots/test-ext-autodoc/target/inheritance.py
tests/roots/test-ext-autodoc/target/instance_variable.py
tests/roots/test-ext-autodoc/target/methods.py
tests/roots/test-ext-autodoc/target/name_conflict/__init__.py
tests/roots/test-ext-autodoc/target/name_conflict/foo.py
tests/roots/test-ext-autodoc/target/name_mangling.py
tests/roots/test-ext-autodoc/target/need_mocks.py
tests/roots/test-ext-autodoc/target/overload.py
tests/roots/test-ext-autodoc/target/overload2.py
tests/roots/test-ext-autodoc/target/partialfunction.py
tests/roots/test-ext-autodoc/target/partialmethod.py
tests/roots/test-ext-autodoc/target/pep570.py
tests/roots/test-ext-autodoc/target/private.py
tests/roots/test-ext-autodoc/target/process_docstring.py
tests/roots/test-ext-autodoc/target/singledispatch.py
tests/roots/test-ext-autodoc/target/singledispatchmethod.py
tests/roots/test-ext-autodoc/target/slots.py
tests/roots/test-ext-autodoc/target/sort_by_all.py
tests/roots/test-ext-autodoc/target/typed_vars.py
tests/roots/test-ext-autodoc/target/typehints.py
tests/roots/test-ext-autodoc/target/typevar.py
tests/roots/test-ext-autodoc/target/wrappedfunction.py
tests/roots/test-ext-autosectionlabel-prefix-document/conf.py
tests/roots/test-ext-autosectionlabel-prefix-document/index.rst
tests/roots/test-ext-autosectionlabel/conf.py
tests/roots/test-ext-autosectionlabel/index.rst
tests/roots/test-ext-autosummary-filename-map/autosummary_dummy_module.py
tests/roots/test-ext-autosummary-filename-map/conf.py
tests/roots/test-ext-autosummary-filename-map/index.rst
tests/roots/test-ext-autosummary-imported_members/autosummary_dummy_package/__init__.py
tests/roots/test-ext-autosummary-imported_members/autosummary_dummy_package/autosummary_dummy_module.py
tests/roots/test-ext-autosummary-imported_members/conf.py
tests/roots/test-ext-autosummary-imported_members/index.rst
tests/roots/test-ext-autosummary-mock_imports/conf.py
tests/roots/test-ext-autosummary-mock_imports/foo.py
tests/roots/test-ext-autosummary-mock_imports/index.rst
tests/roots/test-ext-autosummary-recursive/conf.py
tests/roots/test-ext-autosummary-recursive/index.rst
tests/roots/test-ext-autosummary-recursive/package/__init__.py
tests/roots/test-ext-autosummary-recursive/package/module.py
tests/roots/test-ext-autosummary-recursive/package/module_importfail.py
tests/roots/test-ext-autosummary-recursive/package/package/__init__.py
tests/roots/test-ext-autosummary-recursive/package/package/module.py
tests/roots/test-ext-autosummary-recursive/package2/__init__.py
tests/roots/test-ext-autosummary-recursive/package2/module.py
tests/roots/test-ext-autosummary-skip-member/conf.py
tests/roots/test-ext-autosummary-skip-member/index.rst
tests/roots/test-ext-autosummary-skip-member/target.py
tests/roots/test-ext-autosummary-template/_templates/empty.rst
tests/roots/test-ext-autosummary-template/conf.py
tests/roots/test-ext-autosummary-template/index.rst
tests/roots/test-ext-autosummary-template/target.py
tests/roots/test-ext-autosummary/autosummary_dummy_module.py
tests/roots/test-ext-autosummary/autosummary_importfail.py
tests/roots/test-ext-autosummary/conf.py
tests/roots/test-ext-autosummary/index.rst
tests/roots/test-ext-coverage/conf.py
tests/roots/test-ext-coverage/coverage_ignored.py
tests/roots/test-ext-coverage/coverage_not_ignored.py
tests/roots/test-ext-coverage/index.rst
tests/roots/test-ext-doctest-skipif/conf.py
tests/roots/test-ext-doctest-skipif/skipif.txt
tests/roots/test-ext-doctest-with-autodoc/conf.py
tests/roots/test-ext-doctest-with-autodoc/dir/__init__.py
tests/roots/test-ext-doctest-with-autodoc/dir/bar.py
tests/roots/test-ext-doctest-with-autodoc/dir/inner.rst
tests/roots/test-ext-doctest-with-autodoc/foo.py
tests/roots/test-ext-doctest-with-autodoc/index.rst
tests/roots/test-ext-doctest/conf.py
tests/roots/test-ext-doctest/doctest.txt
tests/roots/test-ext-githubpages/conf.py
tests/roots/test-ext-githubpages/index.rst
tests/roots/test-ext-graphviz/conf.py
tests/roots/test-ext-graphviz/graph.dot
tests/roots/test-ext-graphviz/graph.xx.dot
tests/roots/test-ext-graphviz/index.rst
tests/roots/test-ext-ifconfig/conf.py
tests/roots/test-ext-ifconfig/index.rst
tests/roots/test-ext-imgconverter/conf.py
tests/roots/test-ext-imgconverter/index.rst
tests/roots/test-ext-imgconverter/svgimg.svg
tests/roots/test-ext-inheritance_diagram/conf.py
tests/roots/test-ext-inheritance_diagram/example/__init__.py
tests/roots/test-ext-inheritance_diagram/example/sphinx.py
tests/roots/test-ext-inheritance_diagram/index.rst
tests/roots/test-ext-inheritance_diagram/test.py
tests/roots/test-ext-intersphinx-cppdomain/conf.py
tests/roots/test-ext-intersphinx-cppdomain/index.rst
tests/roots/test-ext-math-compat/conf.py
tests/roots/test-ext-math-compat/index.rst
tests/roots/test-ext-math-simple/conf.py
tests/roots/test-ext-math-simple/index.rst
tests/roots/test-ext-math/conf.py
tests/roots/test-ext-math/index.rst
tests/roots/test-ext-math/math.rst
tests/roots/test-ext-math/nomath.rst
tests/roots/test-ext-math/page.rst
tests/roots/test-ext-todo/bar.rst
tests/roots/test-ext-todo/conf.py
tests/roots/test-ext-todo/foo.rst
tests/roots/test-ext-todo/index.rst
tests/roots/test-ext-viewcode-find/conf.py
tests/roots/test-ext-viewcode-find/index.rst
tests/roots/test-ext-viewcode-find/not_a_package/__init__.py
tests/roots/test-ext-viewcode-find/not_a_package/submodule.py
tests/roots/test-ext-viewcode/conf.py
tests/roots/test-ext-viewcode/index.rst
tests/roots/test-ext-viewcode/objects.rst
tests/roots/test-ext-viewcode/spam/__init__.py
tests/roots/test-ext-viewcode/spam/mod1.py
tests/roots/test-ext-viewcode/spam/mod2.py
tests/roots/test-ext-viewcode/spam/mod3.py
tests/roots/test-extensions/conf.py
tests/roots/test-extensions/read_parallel.py
tests/roots/test-extensions/read_serial.py
tests/roots/test-extensions/write_parallel.py
tests/roots/test-extensions/write_serial.py
tests/roots/test-footnotes/bar.rst
tests/roots/test-footnotes/baz.rst
tests/roots/test-footnotes/conf.py


# The last commit

```
10011eea7 SWE-bench



 .circleci/config.yml                                    |   0
 .codecov.yml                                            |   0
 .github/ISSUE_TEMPLATE/bug_report.md                    |   0
 .github/ISSUE_TEMPLATE/config.yml                       |   0
 .github/ISSUE_TEMPLATE/feature_request.md               |   0
 .github/PULL_REQUEST_TEMPLATE.md                        |   0
 .github/workflows/builddoc.yml                          |   0
 .github/workflows/lint.yml                              |   0
 .github/workflows/main.yml                              |   0
 .github/workflows/nodejs.yml                            |   0
 .gitignore                                              |   0
 .readthedocs.yml                                        |   0
 AUTHORS                                                 |   0
 CHANGES                                                 |   0
 CHANGES.old                                             |   0
 CODE_OF_CONDUCT                                         |   0
 CONTRIBUTING.rst                                        |   0
 EXAMPLES                                                |   0
 LICENSE                                                 |   0
 MANIFEST.in                                             |   0
 Makefile                                                |   0
 README.rst                                              |   0
 babel.cfg                                               |   0
 bindep.txt                                              |   0
 doc/Makefile                                            |   0
 doc/_static/Makefile                                    |   0
 doc/_static/bookcover.png                               | Bin
 doc/_static/conf.py.txt                                 |   0
 doc/_static/favicon.svg                                 |   0
 doc/_static/more.png                                    | Bin
 doc/_static/pocoo.png                                   | Bin
 doc/_static/sphinx.png                                  | Bin
 doc/_static/themes/agogo.png                            | Bin
 doc/_static/themes/alabaster.png                        | Bin
 doc/_static/themes/bizstyle.png                         | Bin
 doc/_static/themes/classic.png                          | Bin
 doc/_static/themes/fullsize/agogo.png                   | Bin
 doc/_static/themes/fullsize/alabaster.png               | Bin
 doc/_static/themes/fullsize/bizstyle.png                | Bin
 doc/_static/themes/fullsize/classic.png                 | Bin
 doc/_static/themes/fullsize/haiku.png                   | Bin
 doc/_static/themes/fullsize/nature.png                  | Bin
 doc/_static/themes/fullsize/pyramid.png                 | Bin
 doc/_static/themes/fullsize/scrolls.png                 | Bin
 doc/_static/themes/fullsize/sphinx_rtd_theme.png        | Bin
 doc/_static/themes/fullsize/sphinxdoc.png               | Bin
 doc/_static/themes/fullsize/traditional.png             | Bin
 doc/_static/themes/haiku.png                            | Bin
 doc/_static/themes/nature.png                           | Bin
 doc/_static/themes/pyramid.png                          | Bin
 doc/_static/themes/scrolls.png                          | Bin
 doc/_static/themes/sphinx_rtd_theme.png                 | Bin
 doc/_static/themes/sphinxdoc.png                        | Bin
 doc/_static/themes/traditional.png                      | Bin
 doc/_static/translation.png                             | Bin
 doc/_static/translation.puml                            |   0
```

```diff
diff --git a/.circleci/config.yml b/.circleci/config.yml
old mode 100644
new mode 100755
diff --git a/.codecov.yml b/.codecov.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/bug_report.md b/.github/ISSUE_TEMPLATE/bug_report.md
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/config.yml b/.github/ISSUE_TEMPLATE/config.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/feature_request.md b/.github/ISSUE_TEMPLATE/feature_request.md
old mode 100644
new mode 100755
diff --git a/.github/PULL_REQUEST_TEMPLATE.md b/.github/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/workflows/builddoc.yml b/.github/workflows/builddoc.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/lint.yml b/.github/workflows/lint.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/main.yml b/.github/workflows/main.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/nodejs.yml b/.github/workflows/nodejs.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.readthedocs.yml b/.readthedocs.yml
old mode 100644
new mode 100755
diff --git a/AUTHORS b/AUTHORS
old mode 100644
new mode 100755
diff --git a/CHANGES b/CHANGES
old mode 100644
new mode 100755
diff --git a/CHANGES.old b/CHANGES.old
old mode 100644
new mode 100755
diff --git a/CODE_OF_CONDUCT b/CODE_OF_CONDUCT
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.rst b/CONTRIBUTING.rst
old mode 100644
new mode 100755
diff --git a/EXAMPLES b/EXAMPLES
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/Makefile b/Makefile
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/babel.cfg b/babel.cfg
old mode 100644
new mode 100755
diff --git a/bindep.txt b/bindep.txt
old mode 100644
new mode 100755
diff --git a/doc/Makefile b/doc/Makefile
old mode 100644
new mode 100755
diff --git a/doc/_static/Makefile b/doc/_static/Makefile
old mode 100644
new mode 100755
diff --git a/doc/_static/bookcover.png b/doc/_static/bookcover.png
old mode 100644
new mode 100755
diff --git a/doc/_static/conf.py.txt b/doc/_static/conf.py.txt
old mode 100644
new mode 100755
diff --git a/doc/_static/favicon.svg b/doc/_static/favicon.svg
old mode 100644
new mode 100755
diff --git a/doc/_static/more.png b/doc/_static/more.png
old mode 100644
new mode 100755
diff --git a/doc/_static/pocoo.png b/doc/_static/pocoo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/sphinx.png b/doc/_static/sphinx.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/agogo.png b/doc/_static/themes/agogo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/alabaster.png b/doc/_static/themes/alabaster.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/bizstyle.png b/doc/_static/themes/bizstyle.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/classic.png b/doc/_static/themes/classic.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/agogo.png b/doc/_static/themes/fullsize/agogo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/alabaster.png b/doc/_static/themes/fullsize/alabaster.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/bizstyle.png b/doc/_static/themes/fullsize/bizstyle.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/classic.png b/doc/_static/themes/fullsize/classic.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/haiku.png b/doc/_static/themes/fullsize/haiku.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/nature.png b/doc/_static/themes/fullsize/nature.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/pyramid.png b/doc/_static/themes/fullsize/pyramid.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/scrolls.png b/doc/_static/themes/fullsize/scrolls.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/sphinx_rtd_theme.png b/doc/_static/themes/fullsize/sphinx_rtd_theme.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/sphinxdoc.png b/doc/_static/themes/fullsize/sphinxdoc.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/traditional.png b/doc/_static/themes/fullsize/traditional.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/haiku.png b/doc/_static/themes/haiku.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/nature.png b/doc/_static/themes/nature.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/pyramid.png b/doc/_static/themes/pyramid.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/scrolls.png b/doc/_static/themes/scrolls.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/sphinx_rtd_theme.png b/doc/_static/themes/sphinx_rtd_theme.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/sphinxdoc.png b/doc/_static/themes/sphinxdoc.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/traditional.png b/doc/_static/themes/traditional.png
old mode 100644
new mode 100755
diff --git a/doc/_static/translation.png b/doc/_static/translation.png
old mode 100644
new mode 100755
diff --git a/doc/_static/translation.puml b/doc/_static/translation.puml
old mode 100644
new mode 100755
diff --git a/doc/_static/translation.svg b/doc/_static/translation.svg
old mode 100644
new mode 100755
diff --git a/doc/_templates/index.html b/doc/_templates/index.html
old mode 100644
new mode 100755
diff --git a/doc/_templates/indexsidebar.html b/doc/_templates/indexsidebar.html
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/layout.html b/doc/_themes/sphinx13/layout.html
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/bodybg.png b/doc/_themes/sphinx13/static/bodybg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/footerbg.png b/doc/_themes/sphinx13/static/footerbg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/headerbg.png b/doc/_themes/sphinx13/static/headerbg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/listitem.png b/doc/_themes/sphinx13/static/listitem.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/relbg.png b/doc/_themes/sphinx13/static/relbg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/sphinx13.css b/doc/_themes/sphinx13/static/sphinx13.css
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/sphinxheader.png b/doc/_themes/sphinx13/static/sphinxheader.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/theme.conf b/doc/_themes/sphinx13/theme.conf
old mode 100644
new mode 100755
diff --git a/doc/changes.rst b/doc/changes.rst
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/contents.rst b/doc/contents.rst
old mode 100644
new mode 100755
diff --git a/doc/develop.rst b/doc/develop.rst
old mode 100644
new mode 100755
diff --git a/doc/development/builders.rst b/doc/development/builders.rst
old mode 100644
new mode 100755
diff --git a/doc/development/index.rst b/doc/development/index.rst
old mode 100644
new mode 100755
diff --git a/doc/development/overview.rst b/doc/development/overview.rst
old mode 100644
new mode 100755
diff --git a/doc/development/theming.rst b/doc/development/theming.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/README.rst b/doc/development/tutorials/examples/README.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/helloworld.py b/doc/development/tutorials/examples/helloworld.py
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/recipe.py b/doc/development/tutorials/examples/recipe.py
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/todo.py b/doc/development/tutorials/examples/todo.py
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/helloworld.rst b/doc/development/tutorials/helloworld.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/index.rst b/doc/development/tutorials/index.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/recipe.rst b/doc/development/tutorials/recipe.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/todo.rst b/doc/development/tutorials/todo.rst
old mode 100644
new mode 100755
diff --git a/doc/examples.rst b/doc/examples.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/appapi.rst b/doc/extdev/appapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/builderapi.rst b/doc/extdev/builderapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/collectorapi.rst b/doc/extdev/collectorapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/deprecated.rst b/doc/extdev/deprecated.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/domainapi.rst b/doc/extdev/domainapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/envapi.rst b/doc/extdev/envapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/i18n.rst b/doc/extdev/i18n.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/index.rst b/doc/extdev/index.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/logging.rst b/doc/extdev/logging.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/markupapi.rst b/doc/extdev/markupapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/nodes.rst b/doc/extdev/nodes.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/parserapi.rst b/doc/extdev/parserapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/projectapi.rst b/doc/extdev/projectapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/utils.rst b/doc/extdev/utils.rst
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/glossary.rst b/doc/glossary.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/authors.rst b/doc/internals/authors.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/code-of-conduct.rst b/doc/internals/code-of-conduct.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/contributing.rst b/doc/internals/contributing.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/index.rst b/doc/internals/index.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/organization.rst b/doc/internals/organization.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/release-process.rst b/doc/internals/release-process.rst
old mode 100644
new mode 100755
diff --git a/doc/latex.rst b/doc/latex.rst
old mode 100644
new mode 100755
diff --git a/doc/make.bat b/doc/make.bat
old mode 100644
new mode 100755
diff --git a/doc/man/index.rst b/doc/man/index.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-apidoc.rst b/doc/man/sphinx-apidoc.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-autogen.rst b/doc/man/sphinx-autogen.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-build.rst b/doc/man/sphinx-build.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-quickstart.rst b/doc/man/sphinx-quickstart.rst
old mode 100644
new mode 100755
diff --git a/doc/templating.rst b/doc/templating.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/intl.rst b/doc/usage/advanced/intl.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/setuptools.rst b/doc/usage/advanced/setuptools.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/api.rst b/doc/usage/advanced/websupport/api.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/index.rst b/doc/usage/advanced/websupport/index.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/quickstart.rst b/doc/usage/advanced/websupport/quickstart.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/searchadapters.rst b/doc/usage/advanced/websupport/searchadapters.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/storagebackends.rst b/doc/usage/advanced/websupport/storagebackends.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/builders/index.rst b/doc/usage/builders/index.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/configuration.rst b/doc/usage/configuration.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/autodoc.rst b/doc/usage/extensions/autodoc.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/autosectionlabel.rst b/doc/usage/extensions/autosectionlabel.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/autosummary.rst b/doc/usage/extensions/autosummary.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/coverage.rst b/doc/usage/extensions/coverage.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/doctest.rst b/doc/usage/extensions/doctest.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/duration.rst b/doc/usage/extensions/duration.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_google.py b/doc/usage/extensions/example_google.py
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_google.rst b/doc/usage/extensions/example_google.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_numpy.py b/doc/usage/extensions/example_numpy.py
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_numpy.rst b/doc/usage/extensions/example_numpy.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/extlinks.rst b/doc/usage/extensions/extlinks.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/githubpages.rst b/doc/usage/extensions/githubpages.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/graphviz.rst b/doc/usage/extensions/graphviz.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/ifconfig.rst b/doc/usage/extensions/ifconfig.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/imgconverter.rst b/doc/usage/extensions/imgconverter.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/index.rst b/doc/usage/extensions/index.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/inheritance.rst b/doc/usage/extensions/inheritance.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/intersphinx.rst b/doc/usage/extensions/intersphinx.rst
old mode 100644
new mode 100755
diff --git a/doc
```
````

### `direct-check.log`

```
check: python -m pytest tests/test_ext_viewcode.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-8.3.3, pluggy-1.5.0
libraries: Sphinx-3.5.0+/10011eea7, docutils-0.21.2
base tempdir: /tmp/pytest-of-root/pytest-4
rootdir: /testbed
configfile: setup.cfg
plugins: cov-5.0.0
collected 4 items

tests/test_ext_viewcode.py F...                                          [100%]

=================================== FAILURES ===================================
________________________________ test_viewcode _________________________________

app = <SphinxTestApp buildername='html'>
status = <_io.StringIO object at 0x7d0ec13b3ee0>
warning = <_io.StringIO object at 0x7d0ec13b3f70>

    @pytest.mark.sphinx(testroot='ext-viewcode')
    def test_viewcode(app, status, warning):
        app.builder.build_all()
    
        warnings = re.sub(r'\\+', '/', warning.getvalue())
        assert re.findall(
            r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
            r"file .*/spam/__init__.py'",
            warnings
        )
    
        result = (app.outdir / 'index.html').read_text()
        assert result.count('href="_modules/spam/mod1.html#func1"') == 2
        assert result.count('href="_modules/spam/mod2.html#func2"') == 2
        assert result.count('href="_modules/spam/mod1.html#Class1"') == 2
        assert result.count('href="_modules/spam/mod2.html#Class2"') == 2
        assert result.count('@decorator') == 1
    
        # test that the class attribute is correctly documented
        assert result.count('this is Class3') == 2
        assert 'this is the class attribute class_attr' in result
        # the next assert fails, until the autodoc bug gets fixed
        assert result.count('this is the class attribute class_attr') == 2
    
        result = (app.outdir / '_modules/spam/mod1.html').read_text()
        result = re.sub('<span class=".*?">', '<span>', result)  # filter pygments classes
>       assert ('<div class="viewcode-block" id="Class1"><a class="viewcode-back" '
                'href="../../index.html#spam.Class1">[docs]</a>'
                '<span>@decorator</span>\n'
                '<span>class</span> <span>Class1</span>'
                '<span>(</span><span>object</span><span>):</span>\n'
                '    <span>&quot;&quot;&quot;</span>\n'
                '<span>    this is Class1</span>\n'
                '<span>    &quot;&quot;&quot;</span></div>\n') in result
E       assert '<div class="viewcode-block" id="Class1"><a class="viewcode-back" href="../../index.html#spam.Class1">[docs]</a><span>...an>\n    <span>&quot;&quot;&quot;</span>\n<span>    this is Class1</span>\n<span>    &quot;&quot;&quot;</span></div>\n' in '\n<!DOCTYPE html>\n\n<html>\n  <head>\n    <meta charset="utf-8" />\n    <meta name="viewport" content="width=device-..."https://github.com/bitprophet/alabaster">Alabaster 0.7.11</a>\n      \n    </div>\n\n    \n\n    \n  </body>\n</html>'

tests/test_ext_viewcode.py:42: AssertionError
--------------------------- Captured stdout teardown ---------------------------
# testroot: root
# builder: html
# srcdir: /tmp/pytest-of-root/pytest-4/ext-viewcode
# outdir: /tmp/pytest-of-root/pytest-4/ext-viewcode/_build/html
# status: 
[01mRunning Sphinx v3.5.0+/10011eea7[39;49;00m
[01mbuilding [html]: [39;49;00mall source files
[01mupdating environment: [39;49;00m[new config] 2 added, 0 changed, 0 removed
[01mreading sources... [39;49;00m[ 50%] [35mindex[39;49;00m                                                [01mreading sources... [39;49;00m[100%] [35mobjects[39;49;00m                                              
[01mlooking for now-outdated files... [39;49;00mnone found
[01mpickling environment... [39;49;00mdone
[01mchecking consistency... [39;49;00mdone
[01mpreparing documents... [39;49;00mdone
[01mwriting output... [39;49;00m[ 50%] [32mindex[39;49;00m                                                 [01mwriting output... [39;49;00m[100%] [32mobjects[39;49;00m                                               
[01mgenerating indices... [39;49;00mgenindex py-modindex done
[01mhighlighting module code... [39;49;00m[ 50%] [94mspam.mod1[39;49;00m                                   [01mhighlighting module code... [39;49;00m[100%] [94mspam.mod2[39;49;00m                                   
[01mwriting additional pages... [39;49;00msearch done
[01mcopying static files... [39;49;00mdone
[01mcopying extra files... [39;49;00mdone
[01mdumping search index in English (code: en)... [39;49;00mdone
[01mdumping object inventory... [39;49;00mdone

# warning: 
[91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/index.rst:23: WARNING: Object named 'func1' not found in include file '/tmp/pytest-of-root/pytest-4/ext-viewcode/spam/__init__.py'[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/spam/mod1.py:docstring of spam.mod1.Class3:1: WARNING: duplicate object description of spam.mod3.Class3, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/spam/mod1.py:docstring of spam.mod3.Class3.class_attr:1: WARNING: duplicate object description of spam.mod3.Class3.class_attr, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:84: WARNING: Error in declarator
If declarator-id with parameters (e.g., 'void f(int arg)'):
  Invalid C declaration: Expected identifier in nested name. [error at 18]
    Sphinx_DoSomething()
    ------------------^
If parenthesis in noptr-declarator (e.g., 'void (*f(int arg))(double)'):
  Error in declarator or parameters
  Invalid C declaration: Expected identifier in nested name. [error at 19]
    Sphinx_DoSomething()
    -------------------^
[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:86: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 19]
  SphinxStruct.member
  -------------------^[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:92: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 13]
  sphinx_global
  -------------^[39;49;00m
[31m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:155: WARNING: Unknown directive type "userdesc".

.. userdesc:: myobj:parameter

   Description of userdesc.[39;49;00m
[31m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:160: WARNING: Unknown interpreted text role "userdescrole".[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:166: WARNING: Too many template argument lists compared to parameter lists. Argument lists: 1, Parameter lists: 0, Extra empty parameters lists prepended: 1. Declaration:
	n::Array<T, d>[39;49;00m
[91m/tmp/pytest-of-root/pytest-4/ext-viewcode/objects.rst:117: WARNING: Unparseable C cross-reference: 'SphinxType *'
Invalid C declaration: Expected end of definition. [error at 11]
  SphinxType *
  -----------^[39;49;00m

=============================== warnings summary ===============================
sphinx/util/docutils.py:45
  /testbed/sphinx/util/docutils.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

sphinx/directives/patches.py:14
  /testbed/sphinx/directives/patches.py:14: DeprecationWarning: The `docutils.parsers.rst.directive.html` module will be removed in Docutils 2.0. Since Docutils 0.18, the "Meta" node is defined in `docutils.parsers.rst.directives.misc`.
    from docutils.parsers.rst.directives import html, images, tables

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:210: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse():  # type: Node

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.translatable):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:110: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for ref in self.document.traverse(nodes.substitution_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:131: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:150: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.block_quote):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:175: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.Element):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:222: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:189: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:279: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.doctest_block):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:116: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:135: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/latex/transforms.py:36: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:291: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/util/compat.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/index.py:51: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/math.py:84: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    self.data['has_equations'][docname] = any(document.traverse(math_node))

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:127: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(addnodes.download_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/title.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/ext/viewcode.py:91: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:301: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.system_message):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:390: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.manpage):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:488: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for inline in self.document.traverse(matcher):  # type: nodes.inline

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/python.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in result.traverse(nodes.Text):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:422: DeprecationWarning: The frontend.OptionParser class will be replaced by a subclass of argparse.ArgumentParser in Docutils 0.21 or later.
    self.docsettings = OptionParser(

tests/test_ext_viewcode.py: 360 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/optparse.py:1000: DeprecationWarning: The frontend.Option class will be removed in Docutils 0.21 or later.
    option = self.option_class(*args, **kwargs)

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/c.py:3494: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/cpp.py:7070: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:69: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.pending_xref):

tests/test_ext_viewcode.py: 47 warnings
  /testbed/sphinx/util/nodes.py:598: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.only):

tests/test_ext_viewcode.py: 24 warnings
  /testbed/sphinx/transforms/post_transforms/images.py:33: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.image):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:216: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.desc_sig_element):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:48: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.substitution_definition):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/transforms.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.literal

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:606: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.title):

tests/test_ext_viewcode.py: 36 warnings
  /testbed/sphinx/builders/latex/transforms.py:608: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for i, index in enumerate(node.traverse(addnodes.index)):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:43: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.highlightlang):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for lbnode in self.document.traverse(nodes.literal_block):  # type: nodes.literal_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:99: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for dbnode in self.document.traverse(nodes.doctest_block):  # type: nodes.doctest_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/environment/__init__.py:541: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:203: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for subtocnode in toc.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:261: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for refnode in newnode.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/__init__.py:181: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:844: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/adapters/toctree.py:312: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in toc.traverse(nodes.reference):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:114: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.
    _gaq.push(['_setAllowLinker', true]);

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:70: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:99: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:328: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:215: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:238: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:33: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:224: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:386: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:401: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:350: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for img in node.traverse(nodes.image):

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:352: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for raw in node.traverse(nodes.raw):

tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
  /testbed/sphinx/ext/linkcode.py:42: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:275: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for reference in tree.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for target in tree.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:290: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for desc_signature in tree.traverse(addnodes.desc_signature):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:340: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in tree.traverse(nodes.reference):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED tests/test_ext_viewcode.py::test_viewcode - assert '<div class="viewco...
================== 1 failed, 3 passed, 1056 warnings in 4.66s ==================

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: sphinx/ext/viewcode.py tests
changed: sphinx/ext/viewcode.py +2 -0
changed: tests/test_ext_viewcode.py +13 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sphinx/ext/viewcode.py b/sphinx/ext/viewcode.py
index a7d52a91c..060604e25 100755
--- a/sphinx/ext/viewcode.py
+++ b/sphinx/ext/viewcode.py
@@ -182,6 +182,8 @@ def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], Non
     env = app.builder.env
     if not hasattr(env, '_viewcode_modules'):
         return
+    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
+        return
     highlighter = app.builder.highlighter  # type: ignore
     urito = app.builder.get_relative_uri
 
diff --git a/tests/test_ext_viewcode.py b/tests/test_ext_viewcode.py
index 79864095b..fa97b0e79 100755
--- a/tests/test_ext_viewcode.py
+++ b/tests/test_ext_viewcode.py
@@ -102,3 +102,16 @@ def test_local_source_files(app, status, warning):
 
     assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class3.class_attr"') == 1
     assert result.count('This is the class attribute class_attr') == 1
+
+
+@pytest.mark.sphinx('html', testroot='ext-viewcode')
+def test_viewcode_epub_builder(app, make_app):
+    app.build()
+
+    # Build epub using the same source and doctree directories as the html build.
+    # The epub builder must not generate the module pages by default, even when
+    # they were generated for the html build.
+    epub_app = make_app('epub', srcdir=app.srcdir)
+    epub_app.build()
+
+    assert not (epub_app.outdir / '_modules').exists()
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
check: python -m pytest tests/test_ext_viewcode.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-8.3.3, pluggy-1.5.0
libraries: Sphinx-3.5.0+/10011eea7, docutils-0.21.2
base tempdir: /tmp/pytest-of-root/pytest-7
rootdir: /testbed
configfile: setup.cfg
plugins: cov-5.0.0
collected 4 items

tests/test_ext_viewcode.py F...                                          [100%]

=================================== FAILURES ===================================
________________________________ test_viewcode _________________________________

app = <SphinxTestApp buildername='html'>
status = <_io.StringIO object at 0x7117aecf4ee0>
warning = <_io.StringIO object at 0x7117aecf4f70>

    @pytest.mark.sphinx(testroot='ext-viewcode')
    def test_viewcode(app, status, warning):
        app.builder.build_all()
    
        warnings = re.sub(r'\\+', '/', warning.getvalue())
        assert re.findall(
            r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
            r"file .*/spam/__init__.py'",
            warnings
        )
    
        result = (app.outdir / 'index.html').read_text()
        assert result.count('href="_modules/spam/mod1.html#func1"') == 2
        assert result.count('href="_modules/spam/mod2.html#func2"') == 2
        assert result.count('href="_modules/spam/mod1.html#Class1"') == 2
        assert result.count('href="_modules/spam/mod2.html#Class2"') == 2
        assert result.count('@decorator') == 1
    
        # test that the class attribute is correctly documented
        assert result.count('this is Class3') == 2
        assert 'this is the class attribute class_attr' in result
        # the next assert fails, until the autodoc bug gets fixed
        assert result.count('this is the class attribute class_attr') == 2
    
        result = (app.outdir / '_modules/spam/mod1.html').read_text()
        result = re.sub('<span class=".*?">', '<span>', result)  # filter pygments classes
>       assert ('<div class="viewcode-block" id="Class1"><a class="viewcode-back" '
                'href="../../index.html#spam.Class1">[docs]</a>'
                '<span>@decorator</span>\n'
                '<span>class</span> <span>Class1</span>'
                '<span>(</span><span>object</span><span>):</span>\n'
                '    <span>&quot;&quot;&quot;</span>\n'
                '<span>    this is Class1</span>\n'
                '<span>    &quot;&quot;&quot;</span></div>\n') in result
E       assert '<div class="viewcode-block" id="Class1"><a class="viewcode-back" href="../../index.html#spam.Class1">[docs]</a><span>...an>\n    <span>&quot;&quot;&quot;</span>\n<span>    this is Class1</span>\n<span>    &quot;&quot;&quot;</span></div>\n' in '\n<!DOCTYPE html>\n\n<html>\n  <head>\n    <meta charset="utf-8" />\n    <meta name="viewport" content="width=device-..."https://github.com/bitprophet/alabaster">Alabaster 0.7.11</a>\n      \n    </div>\n\n    \n\n    \n  </body>\n</html>'

tests/test_ext_viewcode.py:42: AssertionError
--------------------------- Captured stdout teardown ---------------------------
# testroot: root
# builder: html
# srcdir: /tmp/pytest-of-root/pytest-7/ext-viewcode
# outdir: /tmp/pytest-of-root/pytest-7/ext-viewcode/_build/html
# status: 
[01mRunning Sphinx v3.5.0+/10011eea7[39;49;00m
[01mbuilding [html]: [39;49;00mall source files
[01mupdating environment: [39;49;00m[new config] 2 added, 0 changed, 0 removed
[01mreading sources... [39;49;00m[ 50%] [35mindex[39;49;00m                                                [01mreading sources... [39;49;00m[100%] [35mobjects[39;49;00m                                              
[01mlooking for now-outdated files... [39;49;00mnone found
[01mpickling environment... [39;49;00mdone
[01mchecking consistency... [39;49;00mdone
[01mpreparing documents... [39;49;00mdone
[01mwriting output... [39;49;00m[ 50%] [32mindex[39;49;00m                                                 [01mwriting output... [39;49;00m[100%] [32mobjects[39;49;00m                                               
[01mgenerating indices... [39;49;00mgenindex py-modindex done
[01mhighlighting module code... [39;49;00m[ 50%] [94mspam.mod1[39;49;00m                                   [01mhighlighting module code... [39;49;00m[100%] [94mspam.mod2[39;49;00m                                   
[01mwriting additional pages... [39;49;00msearch done
[01mcopying static files... [39;49;00mdone
[01mcopying extra files... [39;49;00mdone
[01mdumping search index in English (code: en)... [39;49;00mdone
[01mdumping object inventory... [39;49;00mdone

# warning: 
[91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/index.rst:23: WARNING: Object named 'func1' not found in include file '/tmp/pytest-of-root/pytest-7/ext-viewcode/spam/__init__.py'[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/spam/mod1.py:docstring of spam.mod1.Class3:1: WARNING: duplicate object description of spam.mod3.Class3, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/spam/mod1.py:docstring of spam.mod3.Class3.class_attr:1: WARNING: duplicate object description of spam.mod3.Class3.class_attr, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:84: WARNING: Error in declarator
If declarator-id with parameters (e.g., 'void f(int arg)'):
  Invalid C declaration: Expected identifier in nested name. [error at 18]
    Sphinx_DoSomething()
    ------------------^
If parenthesis in noptr-declarator (e.g., 'void (*f(int arg))(double)'):
  Error in declarator or parameters
  Invalid C declaration: Expected identifier in nested name. [error at 19]
    Sphinx_DoSomething()
    -------------------^
[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:86: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 19]
  SphinxStruct.member
  -------------------^[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:92: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 13]
  sphinx_global
  -------------^[39;49;00m
[31m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:155: WARNING: Unknown directive type "userdesc".

.. userdesc:: myobj:parameter

   Description of userdesc.[39;49;00m
[31m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:160: WARNING: Unknown interpreted text role "userdescrole".[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:166: WARNING: Too many template argument lists compared to parameter lists. Argument lists: 1, Parameter lists: 0, Extra empty parameters lists prepended: 1. Declaration:
	n::Array<T, d>[39;49;00m
[91m/tmp/pytest-of-root/pytest-7/ext-viewcode/objects.rst:117: WARNING: Unparseable C cross-reference: 'SphinxType *'
Invalid C declaration: Expected end of definition. [error at 11]
  SphinxType *
  -----------^[39;49;00m

=============================== warnings summary ===============================
sphinx/util/docutils.py:45
  /testbed/sphinx/util/docutils.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

sphinx/directives/patches.py:14
  /testbed/sphinx/directives/patches.py:14: DeprecationWarning: The `docutils.parsers.rst.directive.html` module will be removed in Docutils 2.0. Since Docutils 0.18, the "Meta" node is defined in `docutils.parsers.rst.directives.misc`.
    from docutils.parsers.rst.directives import html, images, tables

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:210: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse():  # type: Node

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.translatable):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:110: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for ref in self.document.traverse(nodes.substitution_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:131: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:150: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.block_quote):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:175: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.Element):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:222: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:189: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:279: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.doctest_block):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:116: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:135: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/latex/transforms.py:36: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:291: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/util/compat.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/index.py:51: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/math.py:84: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    self.data['has_equations'][docname] = any(document.traverse(math_node))

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:127: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(addnodes.download_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/title.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/ext/viewcode.py:91: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:301: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.system_message):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:390: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.manpage):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:488: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for inline in self.document.traverse(matcher):  # type: nodes.inline

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/python.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in result.traverse(nodes.Text):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:422: DeprecationWarning: The frontend.OptionParser class will be replaced by a subclass of argparse.ArgumentParser in Docutils 0.21 or later.
    self.docsettings = OptionParser(

tests/test_ext_viewcode.py: 360 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/optparse.py:1000: DeprecationWarning: The frontend.Option class will be removed in Docutils 0.21 or later.
    option = self.option_class(*args, **kwargs)

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/c.py:3494: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/cpp.py:7070: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:69: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.pending_xref):

tests/test_ext_viewcode.py: 47 warnings
  /testbed/sphinx/util/nodes.py:598: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.only):

tests/test_ext_viewcode.py: 24 warnings
  /testbed/sphinx/transforms/post_transforms/images.py:33: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.image):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:216: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.desc_sig_element):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:48: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.substitution_definition):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/transforms.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.literal

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:606: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.title):

tests/test_ext_viewcode.py: 36 warnings
  /testbed/sphinx/builders/latex/transforms.py:608: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for i, index in enumerate(node.traverse(addnodes.index)):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:43: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.highlightlang):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for lbnode in self.document.traverse(nodes.literal_block):  # type: nodes.literal_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:99: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for dbnode in self.document.traverse(nodes.doctest_block):  # type: nodes.doctest_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/environment/__init__.py:541: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:203: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for subtocnode in toc.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:261: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for refnode in newnode.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/__init__.py:181: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:844: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/adapters/toctree.py:312: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in toc.traverse(nodes.reference):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:114: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.
    _gaq.push(['_setAllowLinker', true]);

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:70: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:99: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:328: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:215: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:238: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:33: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:224: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:386: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:401: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:350: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for img in node.traverse(nodes.image):

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:352: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for raw in node.traverse(nodes.raw):

tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
  /testbed/sphinx/ext/linkcode.py:42: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:275: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for reference in tree.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for target in tree.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:290: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for desc_signature in tree.traverse(addnodes.desc_signature):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:340: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in tree.traverse(nodes.reference):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED tests/test_ext_viewcode.py::test_viewcode - assert '<div class="viewco...
================== 1 failed, 3 passed, 1056 warnings in 6.35s ==================

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: sphinx/ext/viewcode.py tests
changed: sphinx/ext/viewcode.py +2 -0
changed: tests/test_ext_viewcode.py +13 -0
```

### `final-status.txt`

```
0
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
# Notes, run 2026-11-06T133747

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`
**Describe the bug**
viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`

**To Reproduce**
```
$ make html epub
```

**Expected behavior**
module pages should not be created for epub by default.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions:  sphinx.ext.viewcode
- Extra tools: No

**Additional context**
No


# The files of the project

```
.circleci/config.yml
.codecov.yml
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/feature_request.md
.github/PULL_REQUEST_TEMPLATE.md
.github/workflows/builddoc.yml
.github/workflows/lint.yml
.github/workflows/main.yml
.github/workflows/nodejs.yml
.gitignore
.readthedocs.yml
AUTHORS
CHANGES
CHANGES.old
CODE_OF_CONDUCT
CONTRIBUTING.rst
EXAMPLES
LICENSE
MANIFEST.in
Makefile
README.rst
babel.cfg
bindep.txt
doc/Makefile
doc/_static/Makefile
doc/_static/bookcover.png
doc/_static/conf.py.txt
doc/_static/favicon.svg
doc/_static/more.png
doc/_static/pocoo.png
doc/_static/sphinx.png
doc/_static/themes/agogo.png
doc/_static/themes/alabaster.png
doc/_static/themes/bizstyle.png
doc/_static/themes/classic.png
doc/_static/themes/fullsize/agogo.png
doc/_static/themes/fullsize/alabaster.png
doc/_static/themes/fullsize/bizstyle.png
doc/_static/themes/fullsize/classic.png
doc/_static/themes/fullsize/haiku.png
doc/_static/themes/fullsize/nature.png
doc/_static/themes/fullsize/pyramid.png
doc/_static/themes/fullsize/scrolls.png
doc/_static/themes/fullsize/sphinx_rtd_theme.png
doc/_static/themes/fullsize/sphinxdoc.png
doc/_static/themes/fullsize/traditional.png
doc/_static/themes/haiku.png
doc/_static/themes/nature.png
doc/_static/themes/pyramid.png
doc/_static/themes/scrolls.png
doc/_static/themes/sphinx_rtd_theme.png
doc/_static/themes/sphinxdoc.png
doc/_static/themes/traditional.png
doc/_static/translation.png
doc/_static/translation.puml
doc/_static/translation.svg
doc/_templates/index.html
doc/_templates/indexsidebar.html
doc/_themes/sphinx13/layout.html
doc/_themes/sphinx13/static/bodybg.png
doc/_themes/sphinx13/static/footerbg.png
doc/_themes/sphinx13/static/headerbg.png
doc/_themes/sphinx13/static/listitem.png
doc/_themes/sphinx13/static/relbg.png
doc/_themes/sphinx13/static/sphinx13.css
doc/_themes/sphinx13/static/sphinxheader.png
doc/_themes/sphinx13/theme.conf
doc/changes.rst
doc/conf.py
doc/contents.rst
doc/develop.rst
doc/development/builders.rst
doc/development/index.rst
doc/development/overview.rst
doc/development/theming.rst
doc/development/tutorials/examples/README.rst
doc/development/tutorials/examples/helloworld.py
doc/development/tutorials/examples/recipe.py
doc/development/tutorials/examples/todo.py
doc/development/tutorials/helloworld.rst
doc/development/tutorials/index.rst
doc/development/tutorials/recipe.rst
doc/development/tutorials/todo.rst
doc/examples.rst
doc/extdev/appapi.rst
doc/extdev/builderapi.rst
doc/extdev/collectorapi.rst
doc/extdev/deprecated.rst
doc/extdev/domainapi.rst
doc/extdev/envapi.rst
doc/extdev/i18n.rst
doc/extdev/index.rst
doc/extdev/logging.rst
doc/extdev/markupapi.rst
doc/extdev/nodes.rst
doc/extdev/parserapi.rst
doc/extdev/projectapi.rst
doc/extdev/utils.rst
doc/faq.rst
doc/glossary.rst
doc/internals/authors.rst
doc/internals/code-of-conduct.rst
doc/internals/contributing.rst
doc/internals/index.rst
doc/internals/organization.rst
doc/internals/release-process.rst
doc/latex.rst
doc/make.bat
doc/man/index.rst
doc/man/sphinx-apidoc.rst
doc/man/sphinx-autogen.rst
doc/man/sphinx-build.rst
doc/man/sphinx-quickstart.rst
doc/templating.rst
doc/usage/advanced/intl.rst
doc/usage/advanced/setuptools.rst
doc/usage/advanced/websupport/api.rst
doc/usage/advanced/websupport/index.rst
doc/usage/advanced/websupport/quickstart.rst
doc/usage/advanced/websupport/searchadapters.rst
doc/usage/advanced/websupport/storagebackends.rst
doc/usage/builders/index.rst
doc/usage/configuration.rst
doc/usage/extensions/autodoc.rst
doc/usage/extensions/autosectionlabel.rst
doc/usage/extensions/autosummary.rst
doc/usage/extensions/coverage.rst
doc/usage/extensions/doctest.rst
doc/usage/extensions/duration.rst
doc/usage/extensions/example_google.py
doc/usage/extensions/example_google.rst
doc/usage/extensions/example_numpy.py
doc/usage/extensions/example_numpy.rst
doc/usage/extensions/extlinks.rst
doc/usage/extensions/githubpages.rst
doc/usage/extensions/graphviz.rst
doc/usage/extensions/ifconfig.rst
doc/usage/extensions/imgconverter.rst
doc/usage/extensions/index.rst
doc/usage/extensions/inheritance.rst
doc/usage/extensions/intersphinx.rst
doc/usage/extensions/linkcode.rst
doc/usage/extensions/math.rst
doc/usage/extensions/napoleon.rst
doc/usage/extensions/todo.rst
doc/usage/extensions/viewcode.rst
doc/usage/index.rst
doc/usage/installation.rst
doc/usage/markdown.rst
doc/usage/quickstart.rst
doc/usage/restructuredtext/basics.rst
doc/usage/restructuredtext/directives.rst
doc/usage/restructuredtext/domains.rst
doc/usage/restructuredtext/field-lists.rst
doc/usage/restructuredtext/index.rst
doc/usage/restructuredtext/roles.rst
doc/usage/theming.rst
karma.conf.js
package-lock.json
package.json
setup.cfg
setup.py
sphinx/__init__.py
sphinx/__main__.py
sphinx/addnodes.py
sphinx/application.py
sphinx/builders/__init__.py
sphinx/builders/_epub_base.py
sphinx/builders/applehelp.py
sphinx/builders/changes.py
sphinx/builders/devhelp.py
sphinx/builders/dirhtml.py
sphinx/builders/dummy.py
sphinx/builders/epub3.py
sphinx/builders/gettext.py
sphinx/builders/html/__init__.py
sphinx/builders/html/transforms.py
sphinx/builders/htmlhelp.py
sphinx/builders/latex/__init__.py
sphinx/builders/latex/constants.py
sphinx/builders/latex/nodes.py
sphinx/builders/latex/theming.py
sphinx/builders/latex/transforms.py
sphinx/builders/latex/util.py
sphinx/builders/linkcheck.py
sphinx/builders/manpage.py
sphinx/builders/qthelp.py
sphinx/builders/singlehtml.py
sphinx/builders/texinfo.py
sphinx/builders/text.py
sphinx/builders/xml.py
sphinx/cmd/__init__.py
sphinx/cmd/build.py
sphinx/cmd/make_mode.py
sphinx/cmd/quickstart.py
sphinx/config.py
sphinx/deprecation.py
sphinx/directives/__init__.py
sphinx/directives/code.py
sphinx/directives/other.py
sphinx/directives/patches.py
sphinx/domains/__init__.py
sphinx/domains/c.py
sphinx/domains/changeset.py
sphinx/domains/citation.py
sphinx/domains/cpp.py
sphinx/domains/index.py
sphinx/domains/javascript.py
sphinx/domains/math.py
sphinx/domains/python.py
sphinx/domains/rst.py
sphinx/domains/std.py
sphinx/environment/__init__.py
sphinx/environment/adapters/__init__.py
sphinx/environment/adapters/asset.py
sphinx/environment/adapters/indexentries.py
sphinx/environment/adapters/toctree.py
sphinx/environment/collectors/__init__.py
sphinx/environment/collectors/asset.py
sphinx/environment/collectors/dependencies.py
sphinx/environment/collectors/indexentries.py
sphinx/environment/collectors/metadata.py
sphinx/environment/collectors/title.py
sphinx/environment/collectors/toctree.py
sphinx/errors.py
sphinx/events.py
sphinx/ext/__init__.py
sphinx/ext/apidoc.py
sphinx/ext/autodoc/__init__.py
sphinx/ext/autodoc/deprecated.py
sphinx/ext/autodoc/directive.py
sphinx/ext/autodoc/importer.py
sphinx/ext/autodoc/mock.py
sphinx/ext/autodoc/type_comment.py
sphinx/ext/autodoc/typehints.py
sphinx/ext/autosectionlabel.py
sphinx/ext/autosummary/__init__.py
sphinx/ext/autosummary/generate.py
sphinx/ext/autosummary/templates/autosummary/base.rst
sphinx/ext/autosummary/templates/autosummary/class.rst
sphinx/ext/autosummary/templates/autosummary/module.rst
sphinx/ext/coverage.py
sphinx/ext/doctest.py
sphinx/ext/duration.py
sphinx/ext/extlinks.py
sphinx/ext/githubpages.py
sphinx/ext/graphviz.py
sphinx/ext/ifconfig.py
sphinx/ext/imgconverter.py
sphinx/ext/imgmath.py
sphinx/ext/inheritance_diagram.py
sphinx/ext/intersphinx.py
sphinx/ext/jsmath.py
sphinx/ext/linkcode.py
sphinx/ext/mathjax.py
sphinx/ext/napoleon/__init__.py
sphinx/ext/napoleon/docstring.py
sphinx/ext/napoleon/iterators.py
sphinx/ext/todo.py
sphinx/ext/viewcode.py
sphinx/extension.py
sphinx/highlighting.py
sphinx/io.py
sphinx/jinja2glue.py
sphinx/locale/.tx/config
sphinx/locale/__init__.py
sphinx/locale/ar/LC_MESSAGES/sphinx.js
sphinx/locale/ar/LC_MESSAGES/sphinx.mo
sphinx/locale/ar/LC_MESSAGES/sphinx.po
sphinx/locale/bg/LC_MESSAGES/sphinx.js
sphinx/locale/bg/LC_MESSAGES/sphinx.mo
sphinx/locale/bg/LC_MESSAGES/sphinx.po
sphinx/locale/bn/LC_MESSAGES/sphinx.js
sphinx/locale/bn/LC_MESSAGES/sphinx.mo
sphinx/locale/bn/LC_MESSAGES/sphinx.po
sphinx/locale/ca/LC_MESSAGES/sphinx.js
sphinx/locale/ca/LC_MESSAGES/sphinx.mo
sphinx/locale/ca/LC_MESSAGES/sphinx.po
sphinx/locale/cak/LC_MESSAGES/sphinx.js
sphinx/locale/cak/LC_MESSAGES/sphinx.mo
sphinx/locale/cak/LC_MESSAGES/sphinx.po
sphinx/locale/cs/LC_MESSAGES/sphinx.js
sphinx/locale/cs/LC_MESSAGES/sphinx.mo
sphinx/locale/cs/LC_MESSAGES/sphinx.po
sphinx/locale/cy/LC_MESSAGES/sphinx.js
sphinx/locale/cy/LC_MESSAGES/sphinx.mo
sphinx/locale/cy/LC_MESSAGES/sphinx.po
sphinx/locale/da/LC_MESSAGES/sphinx.js
sphinx/locale/da/LC_MESSAGES/sphinx.mo
sphinx/locale/da/LC_MESSAGES/sphinx.po
sphinx/locale/de/LC_MESSAGES/sphinx.js
sphinx/locale/de/LC_MESSAGES/sphinx.mo
sphinx/locale/de/LC_MESSAGES/sphinx.po
sphinx/locale/el/LC_MESSAGES/sphinx.js
sphinx/locale/el/LC_MESSAGES/sphinx.mo
sphinx/locale/el/LC_MESSAGES/sphinx.po
sphinx/locale/eo/LC_MESSAGES/sphinx.js
sphinx/locale/eo/LC_MESSAGES/sphinx.mo
sphinx/locale/eo/LC_MESSAGES/sphinx.po
sphinx/locale/es/LC_MESSAGES/sphinx.js
sphinx/locale/es/LC_MESSAGES/sphinx.mo
sphinx/locale/es/LC_MESSAGES/sphinx.po
sphinx/locale/et/LC_MESSAGES/sphinx.js
sphinx/locale/et/LC_MESSAGES/sphinx.mo
sphinx/locale/et/LC_MESSAGES/sphinx.po
sphinx/locale/eu/LC_MESSAGES/sphinx.js
sphinx/locale/eu/LC_MESSAGES/sphinx.mo
sphinx/locale/eu/LC_MESSAGES/sphinx.po
sphinx/locale/fa/LC_MESSAGES/sphinx.js
sphinx/locale/fa/LC_MESSAGES/sphinx.mo
sphinx/locale/fa/LC_MESSAGES/sphinx.po
sphinx/locale/fi/LC_MESSAGES/sphinx.js
sphinx/locale/fi/LC_MESSAGES/sphinx.mo
sphinx/locale/fi/LC_MESSAGES/sphinx.po
sphinx/locale/fr/LC_MESSAGES/sphinx.js
sphinx/locale/fr/LC_MESSAGES/sphinx.mo
sphinx/locale/fr/LC_MESSAGES/sphinx.po
sphinx/locale/he/LC_MESSAGES/sphinx.js
sphinx/locale/he/LC_MESSAGES/sphinx.mo
sphinx/locale/he/LC_MESSAGES/sphinx.po
sphinx/locale/hi/LC_MESSAGES/sphinx.js
sphinx/locale/hi/LC_MESSAGES/sphinx.mo
sphinx/locale/hi/LC_MESSAGES/sphinx.po
sphinx/locale/hi_IN/LC_MESSAGES/sphinx.js
sphinx/locale/hi_IN/LC_MESSAGES/sphinx.mo
sphinx/locale/hi_IN/LC_MESSAGES/sphinx.po
sphinx/locale/hr/LC_MESSAGES/sphinx.js
sphinx/locale/hr/LC_MESSAGES/sphinx.mo
sphinx/locale/hr/LC_MESSAGES/sphinx.po
sphinx/locale/hu/LC_MESSAGES/sphinx.js
sphinx/locale/hu/LC_MESSAGES/sphinx.mo
sphinx/locale/hu/LC_MESSAGES/sphinx.po
sphinx/locale/id/LC_MESSAGES/sphinx.js
sphinx/locale/id/LC_MESSAGES/sphinx.mo
sphinx/locale/id/LC_MESSAGES/sphinx.po
sphinx/locale/it/LC_MESSAGES/sphinx.js
sphinx/locale/it/LC_MESSAGES/sphinx.mo
sphinx/locale/it/LC_MESSAGES/sphinx.po
sphinx/locale/ja/LC_MESSAGES/sphinx.js
sphinx/locale/ja/LC_MESSAGES/sphinx.mo
sphinx/locale/ja/LC_MESSAGES/sphinx.po
sphinx/locale/ko/LC_MESSAGES/sphinx.js
sphinx/locale/ko/LC_MESSAGES/sphinx.mo
sphinx/locale/ko/LC_MESSAGES/sphinx.po
sphinx/locale/lt/LC_MESSAGES/sphinx.js
sphinx/locale/lt/LC_MESSAGES/sphinx.mo
sphinx/locale/lt/LC_MESSAGES/sphinx.po
sphinx/locale/lv/LC_MESSAGES/sphinx.js
sphinx/locale/lv/LC_MESSAGES/sphinx.mo
sphinx/locale/lv/LC_MESSAGES/sphinx.po
sphinx/locale/mk/LC_MESSAGES/sphinx.js
sphinx/locale/mk/LC_MESSAGES/sphinx.mo
sphinx/locale/mk/LC_MESSAGES/sphinx.po
sphinx/locale/nb_NO/LC_MESSAGES/sphinx.js
sphinx/locale/nb_NO/LC_MESSAGES/sphinx.mo
sphinx/locale/nb_NO/LC_MESSAGES/sphinx.po
sphinx/locale/ne/LC_MESSAGES/sphinx.js
sphinx/locale/ne/LC_MESSAGES/sphinx.mo
sphinx/locale/ne/LC_MESSAGES/sphinx.po
sphinx/locale/nl/LC_MESSAGES/sphinx.js
sphinx/locale/nl/LC_MESSAGES/sphinx.mo
sphinx/locale/nl/LC_MESSAGES/sphinx.po
sphinx/locale/pl/LC_MESSAGES/sphinx.js
sphinx/locale/pl/LC_MESSAGES/sphinx.mo
sphinx/locale/pl/LC_MESSAGES/sphinx.po
sphinx/locale/pt/LC_MESSAGES/sphinx.js
sphinx/locale/pt/LC_MESSAGES/sphinx.mo
sphinx/locale/pt/LC_MESSAGES/sphinx.po
sphinx/locale/pt_BR/LC_MESSAGES/sphinx.js
sphinx/locale/pt_BR/LC_MESSAGES/sphinx.mo
sphinx/locale/pt_BR/LC_MESSAGES/sphinx.po
sphinx/locale/pt_PT/LC_MESSAGES/sphinx.js
sphinx/locale/pt_PT/LC_MESSAGES/sphinx.mo
sphinx/locale/pt_PT/LC_MESSAGES/sphinx.po
sphinx/locale/ro/LC_MESSAGES/sphinx.js
sphinx/locale/ro/LC_MESSAGES/sphinx.mo
sphinx/locale/ro/LC_MESSAGES/sphinx.po
sphinx/locale/ru/LC_MESSAGES/sphinx.js
sphinx/locale/ru/LC_MESSAGES/sphinx.mo
sphinx/locale/ru/LC_MESSAGES/sphinx.po
sphinx/locale/si/LC_MESSAGES/sphinx.js
sphinx/locale/si/LC_MESSAGES/sphinx.mo
sphinx/locale/si/LC_MESSAGES/sphinx.po
sphinx/locale/sk/LC_MESSAGES/sphinx.js
sphinx/locale/sk/LC_MESSAGES/sphinx.mo
sphinx/locale/sk/LC_MESSAGES/sphinx.po
sphinx/locale/sl/LC_MESSAGES/sphinx.js
sphinx/locale/sl/LC_MESSAGES/sphinx.mo
sphinx/locale/sl/LC_MESSAGES/sphinx.po
sphinx/locale/sphinx.pot
sphinx/locale/sq/LC_MESSAGES/sphinx.js
sphinx/locale/sq/LC_MESSAGES/sphinx.mo
sphinx/locale/sq/LC_MESSAGES/sphinx.po
sphinx/locale/sr/LC_MESSAGES/sphinx.js
sphinx/locale/sr/LC_MESSAGES/sphinx.mo
sphinx/locale/sr/LC_MESSAGES/sphinx.po
sphinx/locale/sr@latin/LC_MESSAGES/sphinx.js
sphinx/locale/sr@latin/LC_MESSAGES/sphinx.mo
sphinx/locale/sr@latin/LC_MESSAGES/sphinx.po
sphinx/locale/sr_RS/LC_MESSAGES/sphinx.js
sphinx/locale/sr_RS/LC_MESSAGES/sphinx.mo
sphinx/locale/sr_RS/LC_MESSAGES/sphinx.po
sphinx/locale/sv/LC_MESSAGES/sphinx.js
sphinx/locale/sv/LC_MESSAGES/sphinx.mo
sphinx/locale/sv/LC_MESSAGES/sphinx.po
sphinx/locale/ta/LC_MESSAGES/sphinx.js
sphinx/locale/ta/LC_MESSAGES/sphinx.mo
sphinx/locale/ta/LC_MESSAGES/sphinx.po
sphinx/locale/te/LC_MESSAGES/sphinx.js
sphinx/locale/te/LC_MESSAGES/sphinx.mo
sphinx/locale/te/LC_MESSAGES/sphinx.po
sphinx/locale/tr/LC_MESSAGES/sphinx.js
sphinx/locale/tr/LC_MESSAGES/sphinx.mo
sphinx/locale/tr/LC_MESSAGES/sphinx.po
sphinx/locale/uk_UA/LC_MESSAGES/sphinx.js
sphinx/locale/uk_UA/LC_MESSAGES/sphinx.mo
sphinx/locale/uk_UA/LC_MESSAGES/sphinx.po
sphinx/locale/ur/LC_MESSAGES/sphinx.js
sphinx/locale/ur/LC_MESSAGES/sphinx.mo
sphinx/locale/ur/LC_MESSAGES/sphinx.po
sphinx/locale/vi/LC_MESSAGES/sphinx.js
sphinx/locale/vi/LC_MESSAGES/sphinx.mo
sphinx/locale/vi/LC_MESSAGES/sphinx.po
sphinx/locale/zh_CN/LC_MESSAGES/sphinx.js
sphinx/locale/zh_CN/LC_MESSAGES/sphinx.mo
sphinx/locale/zh_CN/LC_MESSAGES/sphinx.po
sphinx/locale/zh_TW/LC_MESSAGES/sphinx.js
sphinx/locale/zh_TW/LC_MESSAGES/sphinx.mo
sphinx/locale/zh_TW/LC_MESSAGES/sphinx.po
sphinx/parsers.py
sphinx/project.py
sphinx/py.typed
sphinx/pycode/__init__.py
sphinx/pycode/ast.py
sphinx/pycode/parser.py
sphinx/pygments_styles.py
sphinx/registry.py
sphinx/roles.py
sphinx/search/__init__.py
sphinx/search/da.py
sphinx/search/de.py
sphinx/search/en.py
sphinx/search/es.py
sphinx/search/fi.py
sphinx/search/fr.py
sphinx/search/hu.py
sphinx/search/it.py
sphinx/search/ja.py
sphinx/search/jssplitter.py
sphinx/search/nl.py
sphinx/search/no.py
sphinx/search/non-minified-js/danish-stemmer.js
sphinx/search/non-minified-js/dutch-stemmer.js
sphinx/search/non-minified-js/finnish-stemmer.js
sphinx/search/non-minified-js/french-stemmer.js
sphinx/search/non-minified-js/german-stemmer.js
sphinx/search/non-minified-js/hungarian-stemmer.js
sphinx/search/non-minified-js/italian-stemmer.js
sphinx/search/non-minified-js/norwegian-stemmer.js
sphinx/search/non-minified-js/porter-stemmer.js
sphinx/search/non-minified-js/portuguese-stemmer.js
sphinx/search/non-minified-js/romanian-stemmer.js
sphinx/search/non-minified-js/russian-stemmer.js
sphinx/search/non-minified-js/spanish-stemmer.js
sphinx/search/non-minified-js/swedish-stemmer.js
sphinx/search/non-minified-js/turkish-stemmer.js
sphinx/search/pt.py
sphinx/search/ro.py
sphinx/search/ru.py
sphinx/search/sv.py
sphinx/search/tr.py
sphinx/search/zh.py
sphinx/setup_command.py
sphinx/templates/apidoc/module.rst_t
sphinx/templates/apidoc/package.rst_t
sphinx/templates/apidoc/toc.rst_t
sphinx/templates/epub3/container.xml
sphinx/templates/epub3/content.opf_t
sphinx/templates/epub3/mimetype
sphinx/templates/epub3/nav.xhtml_t
sphinx/templates/epub3/toc.ncx_t
sphinx/templates/gettext/message.pot_t
sphinx/templates/graphviz/graphviz.css
sphinx/templates/htmlhelp/project.hhc
sphinx/templates/htmlhelp/project.hhp
sphinx/templates/htmlhelp/project.stp
sphinx/templates/imgmath/preview.tex_t
sphinx/templates/imgmath/template.tex_t
sphinx/templates/latex/latex.tex_t
sphinx/templates/latex/longtable.tex_t
sphinx/templates/latex/sphinxmessages.sty_t
sphinx/templates/latex/tabular.tex_t
sphinx/templates/latex/tabulary.tex_t
sphinx/templates/quickstart/Makefile.new_t
sphinx/templates/quickstart/Makefile_t
sphinx/templates/quickstart/conf.py_t
sphinx/templates/quickstart/make.bat.new_t
sphinx/templates/quickstart/make.bat_t
sphinx/templates/quickstart/master_doc.rst_t
sphinx/templates/texinfo/Makefile
sphinx/testing/__init__.py
sphinx/testing/comparer.py
sphinx/testing/fixtures.py
sphinx/testing/path.py
sphinx/testing/restructuredtext.py
sphinx/testing/util.py
sphinx/texinputs/LICRcyr2utf8.xdy
sphinx/texinputs/LICRlatin2utf8.xdy
sphinx/texinputs/LatinRules.xdy
sphinx/texinputs/Makefile_t
sphinx/texinputs/footnotehyper-sphinx.sty
sphinx/texinputs/latexmkjarc_t
sphinx/texinputs/latexmkrc_t
sphinx/texinputs/make.bat_t
sphinx/texinputs/python.ist
sphinx/texinputs/sphinx.sty
sphinx/texinputs/sphinx.xdy
sphinx/texinputs/sphinxcyrillic.sty
sphinx/texinputs/sphinxhowto.cls
sphinx/texinputs/sphinxmanual.cls
sphinx/texinputs/sphinxmulticell.sty
sphinx/texinputs_win/Makefile_t
sphinx/themes/agogo/layout.html
sphinx/themes/agogo/static/agogo.css_t
sphinx/themes/agogo/static/bgfooter.png
sphinx/themes/agogo/static/bgtop.png
sphinx/themes/agogo/theme.conf
sphinx/themes/basic/changes/frameset.html
sphinx/themes/basic/changes/rstsource.html
sphinx/themes/basic/changes/versionchanges.html
sphinx/themes/basic/defindex.html
sphinx/themes/basic/domainindex.html
sphinx/themes/basic/genindex-single.html
sphinx/themes/basic/genindex-split.html
sphinx/themes/basic/genindex.html
sphinx/themes/basic/globaltoc.html
sphinx/themes/basic/layout.html
sphinx/themes/basic/localtoc.html
sphinx/themes/basic/opensearch.xml
sphinx/themes/basic/page.html
sphinx/themes/basic/relations.html
sphinx/themes/basic/search.html
sphinx/themes/basic/searchbox.html
sphinx/themes/basic/sourcelink.html
sphinx/themes/basic/static/basic.css_t
sphinx/themes/basic/static/doctools.js
sphinx/themes/basic/static/documentation_options.js_t
sphinx/themes/basic/static/file.png
sphinx/themes/basic/static/jquery-3.5.1.js
sphinx/themes/basic/static/jquery.js
sphinx/themes/basic/static/language_data.js_t
sphinx/themes/basic/static/minus.png
sphinx/themes/basic/static/plus.png
sphinx/themes/basic/static/searchtools.js
sphinx/themes/basic/static/underscore-1.3.1.js
sphinx/themes/basic/static/underscore.js
sphinx/themes/basic/theme.conf
sphinx/themes/bizstyle/layout.html
sphinx/themes/bizstyle/static/background_b01.png
sphinx/themes/bizstyle/static/bizstyle.css_t
sphinx/themes/bizstyle/static/bizstyle.js_t
sphinx/themes/bizstyle/static/css3-mediaqueries.js
sphinx/themes/bizstyle/static/css3-mediaqueries_src.js
sphinx/themes/bizstyle/theme.conf
sphinx/themes/classic/layout.html
sphinx/themes/classic/static/classic.css_t
sphinx/themes/classic/static/sidebar.js_t
sphinx/themes/classic/theme.conf
sphinx/themes/default/static/default.css
sphinx/themes/default/theme.conf
sphinx/themes/epub/epub-cover.html
sphinx/themes/epub/layout.html
sphinx/themes/epub/static/epub.css_t
sphinx/themes/epub/theme.conf
sphinx/themes/haiku/layout.html
sphinx/themes/haiku/static/alert_info_32.png
sphinx/themes/haiku/static/alert_warning_32.png
sphinx/themes/haiku/static/bg-page.png
sphinx/themes/haiku/static/bullet_orange.png
sphinx/themes/haiku/static/haiku.css_t
sphinx/themes/haiku/theme.conf
sphinx/themes/nature/static/nature.css_t
sphinx/themes/nature/theme.conf
sphinx/themes/nonav/layout.html
sphinx/themes/nonav/static/nonav.css
sphinx/themes/nonav/theme.conf
sphinx/themes/pyramid/layout.html
sphinx/themes/pyramid/static/dialog-note.png
sphinx/themes/pyramid/static/dialog-seealso.png
sphinx/themes/pyramid/static/dialog-todo.png
sphinx/themes/pyramid/static/dialog-topic.png
sphinx/themes/pyramid/static/dialog-warning.png
sphinx/themes/pyramid/static/epub.css
sphinx/themes/pyramid/static/footerbg.png
sphinx/themes/pyramid/static/headerbg.png
sphinx/themes/pyramid/static/ie6.css
sphinx/themes/pyramid/static/middlebg.png
sphinx/themes/pyramid/static/pyramid.css_t
sphinx/themes/pyramid/static/transparent.gif
```


# The last commit

```
10011eea7 SWE-bench



 .circleci/config.yml                                    |   0
 .codecov.yml                                            |   0
 .github/ISSUE_TEMPLATE/bug_report.md                    |   0
 .github/ISSUE_TEMPLATE/config.yml                       |   0
 .github/ISSUE_TEMPLATE/feature_request.md               |   0
 .github/PULL_REQUEST_TEMPLATE.md                        |   0
 .github/workflows/builddoc.yml                          |   0
 .github/workflows/lint.yml                              |   0
 .github/workflows/main.yml                              |   0
 .github/workflows/nodejs.yml                            |   0
 .gitignore                                              |   0
 .readthedocs.yml                                        |   0
 AUTHORS                                                 |   0
 CHANGES                                                 |   0
 CHANGES.old                                             |   0
 CODE_OF_CONDUCT                                         |   0
 CONTRIBUTING.rst                                        |   0
 EXAMPLES                                                |   0
 LICENSE                                                 |   0
 MANIFEST.in                                             |   0
 Makefile                                                |   0
 README.rst                                              |   0
 babel.cfg                                               |   0
 bindep.txt                                              |   0
 doc/Makefile                                            |   0
 doc/_static/Makefile                                    |   0
 doc/_static/bookcover.png                               | Bin
 doc/_static/conf.py.txt                                 |   0
 doc/_static/favicon.svg                                 |   0
 doc/_static/more.png                                    | Bin
 doc/_static/pocoo.png                                   | Bin
 doc/_static/sphinx.png                                  | Bin
 doc/_static/themes/agogo.png                            | Bin
 doc/_static/themes/alabaster.png                        | Bin
 doc/_static/themes/bizstyle.png                         | Bin
 doc/_static/themes/classic.png                          | Bin
 doc/_static/themes/fullsize/agogo.png                   | Bin
 doc/_static/themes/fullsize/alabaster.png               | Bin
 doc/_static/themes/fullsize/bizstyle.png                | Bin
 doc/_static/themes/fullsize/classic.png                 | Bin
 doc/_static/themes/fullsize/haiku.png                   | Bin
 doc/_static/themes/fullsize/nature.png                  | Bin
 doc/_static/themes/fullsize/pyramid.png                 | Bin
 doc/_static/themes/fullsize/scrolls.png                 | Bin
 doc/_static/themes/fullsize/sphinx_rtd_theme.png        | Bin
 doc/_static/themes/fullsize/sphinxdoc.png               | Bin
 doc/_static/themes/fullsize/traditional.png             | Bin
 doc/_static/themes/haiku.png                            | Bin
 doc/_static/themes/nature.png                           | Bin
 doc/_static/themes/pyramid.png                          | Bin
 doc/_static/themes/scrolls.png                          | Bin
 doc/_static/themes/sphinx_rtd_theme.png                 | Bin
 doc/_static/themes/sphinxdoc.png                        | Bin
 doc/_static/themes/traditional.png                      | Bin
 doc/_static/translation.png                             | Bin
 doc/_static/translation.puml                            |   0
```

```diff
diff --git a/.circleci/config.yml b/.circleci/config.yml
old mode 100644
new mode 100755
diff --git a/.codecov.yml b/.codecov.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/bug_report.md b/.github/ISSUE_TEMPLATE/bug_report.md
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/config.yml b/.github/ISSUE_TEMPLATE/config.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/feature_request.md b/.github/ISSUE_TEMPLATE/feature_request.md
old mode 100644
new mode 100755
diff --git a/.github/PULL_REQUEST_TEMPLATE.md b/.github/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/workflows/builddoc.yml b/.github/workflows/builddoc.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/lint.yml b/.github/workflows/lint.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/main.yml b/.github/workflows/main.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/nodejs.yml b/.github/workflows/nodejs.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.readthedocs.yml b/.readthedocs.yml
old mode 100644
new mode 100755
diff --git a/AUTHORS b/AUTHORS
old mode 100644
new mode 100755
diff --git a/CHANGES b/CHANGES
old mode 100644
new mode 100755
diff --git a/CHANGES.old b/CHANGES.old
old mode 100644
new mode 100755
diff --git a/CODE_OF_CONDUCT b/CODE_OF_CONDUCT
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.rst b/CONTRIBUTING.rst
old mode 100644
new mode 100755
diff --git a/EXAMPLES b/EXAMPLES
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/Makefile b/Makefile
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/babel.cfg b/babel.cfg
old mode 100644
new mode 100755
diff --git a/bindep.txt b/bindep.txt
old mode 100644
new mode 100755
diff --git a/doc/Makefile b/doc/Makefile
old mode 100644
new mode 100755
diff --git a/doc/_static/Makefile b/doc/_static/Makefile
old mode 100644
new mode 100755
diff --git a/doc/_static/bookcover.png b/doc/_static/bookcover.png
old mode 100644
new mode 100755
diff --git a/doc/_static/conf.py.txt b/doc/_static/conf.py.txt
old mode 100644
new mode 100755
diff --git a/doc/_static/favicon.svg b/doc/_static/favicon.svg
old mode 100644
new mode 100755
diff --git a/doc/_static/more.png b/doc/_static/more.png
old mode 100644
new mode 100755
diff --git a/doc/_static/pocoo.png b/doc/_static/pocoo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/sphinx.png b/doc/_static/sphinx.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/agogo.png b/doc/_static/themes/agogo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/alabaster.png b/doc/_static/themes/alabaster.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/bizstyle.png b/doc/_static/themes/bizstyle.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/classic.png b/doc/_static/themes/classic.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/agogo.png b/doc/_static/themes/fullsize/agogo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/alabaster.png b/doc/_static/themes/fullsize/alabaster.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/bizstyle.png b/doc/_static/themes/fullsize/bizstyle.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/classic.png b/doc/_static/themes/fullsize/classic.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/haiku.png b/doc/_static/themes/fullsize/haiku.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/nature.png b/doc/_static/themes/fullsize/nature.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/pyramid.png b/doc/_static/themes/fullsize/pyramid.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/scrolls.png b/doc/_static/themes/fullsize/scrolls.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/sphinx_rtd_theme.png b/doc/_static/themes/fullsize/sphinx_rtd_theme.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/sphinxdoc.png b/doc/_static/themes/fullsize/sphinxdoc.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/fullsize/traditional.png b/doc/_static/themes/fullsize/traditional.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/haiku.png b/doc/_static/themes/haiku.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/nature.png b/doc/_static/themes/nature.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/pyramid.png b/doc/_static/themes/pyramid.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/scrolls.png b/doc/_static/themes/scrolls.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/sphinx_rtd_theme.png b/doc/_static/themes/sphinx_rtd_theme.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/sphinxdoc.png b/doc/_static/themes/sphinxdoc.png
old mode 100644
new mode 100755
diff --git a/doc/_static/themes/traditional.png b/doc/_static/themes/traditional.png
old mode 100644
new mode 100755
diff --git a/doc/_static/translation.png b/doc/_static/translation.png
old mode 100644
new mode 100755
diff --git a/doc/_static/translation.puml b/doc/_static/translation.puml
old mode 100644
new mode 100755
diff --git a/doc/_static/translation.svg b/doc/_static/translation.svg
old mode 100644
new mode 100755
diff --git a/doc/_templates/index.html b/doc/_templates/index.html
old mode 100644
new mode 100755
diff --git a/doc/_templates/indexsidebar.html b/doc/_templates/indexsidebar.html
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/layout.html b/doc/_themes/sphinx13/layout.html
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/bodybg.png b/doc/_themes/sphinx13/static/bodybg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/footerbg.png b/doc/_themes/sphinx13/static/footerbg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/headerbg.png b/doc/_themes/sphinx13/static/headerbg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/listitem.png b/doc/_themes/sphinx13/static/listitem.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/relbg.png b/doc/_themes/sphinx13/static/relbg.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/sphinx13.css b/doc/_themes/sphinx13/static/sphinx13.css
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/static/sphinxheader.png b/doc/_themes/sphinx13/static/sphinxheader.png
old mode 100644
new mode 100755
diff --git a/doc/_themes/sphinx13/theme.conf b/doc/_themes/sphinx13/theme.conf
old mode 100644
new mode 100755
diff --git a/doc/changes.rst b/doc/changes.rst
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/contents.rst b/doc/contents.rst
old mode 100644
new mode 100755
diff --git a/doc/develop.rst b/doc/develop.rst
old mode 100644
new mode 100755
diff --git a/doc/development/builders.rst b/doc/development/builders.rst
old mode 100644
new mode 100755
diff --git a/doc/development/index.rst b/doc/development/index.rst
old mode 100644
new mode 100755
diff --git a/doc/development/overview.rst b/doc/development/overview.rst
old mode 100644
new mode 100755
diff --git a/doc/development/theming.rst b/doc/development/theming.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/README.rst b/doc/development/tutorials/examples/README.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/helloworld.py b/doc/development/tutorials/examples/helloworld.py
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/recipe.py b/doc/development/tutorials/examples/recipe.py
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/examples/todo.py b/doc/development/tutorials/examples/todo.py
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/helloworld.rst b/doc/development/tutorials/helloworld.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/index.rst b/doc/development/tutorials/index.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/recipe.rst b/doc/development/tutorials/recipe.rst
old mode 100644
new mode 100755
diff --git a/doc/development/tutorials/todo.rst b/doc/development/tutorials/todo.rst
old mode 100644
new mode 100755
diff --git a/doc/examples.rst b/doc/examples.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/appapi.rst b/doc/extdev/appapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/builderapi.rst b/doc/extdev/builderapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/collectorapi.rst b/doc/extdev/collectorapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/deprecated.rst b/doc/extdev/deprecated.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/domainapi.rst b/doc/extdev/domainapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/envapi.rst b/doc/extdev/envapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/i18n.rst b/doc/extdev/i18n.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/index.rst b/doc/extdev/index.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/logging.rst b/doc/extdev/logging.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/markupapi.rst b/doc/extdev/markupapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/nodes.rst b/doc/extdev/nodes.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/parserapi.rst b/doc/extdev/parserapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/projectapi.rst b/doc/extdev/projectapi.rst
old mode 100644
new mode 100755
diff --git a/doc/extdev/utils.rst b/doc/extdev/utils.rst
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/glossary.rst b/doc/glossary.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/authors.rst b/doc/internals/authors.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/code-of-conduct.rst b/doc/internals/code-of-conduct.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/contributing.rst b/doc/internals/contributing.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/index.rst b/doc/internals/index.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/organization.rst b/doc/internals/organization.rst
old mode 100644
new mode 100755
diff --git a/doc/internals/release-process.rst b/doc/internals/release-process.rst
old mode 100644
new mode 100755
diff --git a/doc/latex.rst b/doc/latex.rst
old mode 100644
new mode 100755
diff --git a/doc/make.bat b/doc/make.bat
old mode 100644
new mode 100755
diff --git a/doc/man/index.rst b/doc/man/index.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-apidoc.rst b/doc/man/sphinx-apidoc.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-autogen.rst b/doc/man/sphinx-autogen.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-build.rst b/doc/man/sphinx-build.rst
old mode 100644
new mode 100755
diff --git a/doc/man/sphinx-quickstart.rst b/doc/man/sphinx-quickstart.rst
old mode 100644
new mode 100755
diff --git a/doc/templating.rst b/doc/templating.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/intl.rst b/doc/usage/advanced/intl.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/setuptools.rst b/doc/usage/advanced/setuptools.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/api.rst b/doc/usage/advanced/websupport/api.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/index.rst b/doc/usage/advanced/websupport/index.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/quickstart.rst b/doc/usage/advanced/websupport/quickstart.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/searchadapters.rst b/doc/usage/advanced/websupport/searchadapters.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/advanced/websupport/storagebackends.rst b/doc/usage/advanced/websupport/storagebackends.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/builders/index.rst b/doc/usage/builders/index.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/configuration.rst b/doc/usage/configuration.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/autodoc.rst b/doc/usage/extensions/autodoc.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/autosectionlabel.rst b/doc/usage/extensions/autosectionlabel.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/autosummary.rst b/doc/usage/extensions/autosummary.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/coverage.rst b/doc/usage/extensions/coverage.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/doctest.rst b/doc/usage/extensions/doctest.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/duration.rst b/doc/usage/extensions/duration.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_google.py b/doc/usage/extensions/example_google.py
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_google.rst b/doc/usage/extensions/example_google.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_numpy.py b/doc/usage/extensions/example_numpy.py
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/example_numpy.rst b/doc/usage/extensions/example_numpy.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/extlinks.rst b/doc/usage/extensions/extlinks.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/githubpages.rst b/doc/usage/extensions/githubpages.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/graphviz.rst b/doc/usage/extensions/graphviz.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/ifconfig.rst b/doc/usage/extensions/ifconfig.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/imgconverter.rst b/doc/usage/extensions/imgconverter.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/index.rst b/doc/usage/extensions/index.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/inheritance.rst b/doc/usage/extensions/inheritance.rst
old mode 100644
new mode 100755
diff --git a/doc/usage/extensions/intersphinx.rst b/doc/usage/extensions/intersphinx.rst
old mode 100644
new mode 100755
diff --git a/doc
```


# Makefile (the start)

```
PYTHON ?= python3

.PHONY: all
all: clean-pyc clean-backupfiles style-check type-check test

.PHONY: clean
clean: clean-pyc clean-pycache clean-patchfiles clean-backupfiles clean-generated clean-testfiles clean-buildfiles clean-mypyfiles

.PHONY: clean-pyc
clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +

.PHONY: clean-pycache
clean-pycache:
	find . -name __pycache__ -exec rm -rf {} +

.PHONY: clean-patchfiles
clean-patchfiles:
	find . -name '*.orig' -exec rm -f {} +
	find . -name '*.rej' -exec rm -f {} +

.PHONY: clean-backupfiles
clean-backupfiles:
	find . -name '*~' -exec rm -f {} +
	find . -name '*.bak' -exec rm -f {} +
	find . -name '*.swp' -exec rm -f {} +
	find . -name '*.swo' -exec rm -f {} +

.PHONY: clean-generated
clean-generated:
	find . -name '.DS_Store' -exec rm -f {} +
	rm -rf Sphinx.egg-info/
	rm -rf dist/
	rm -rf doc/_build/
	rm -f sphinx/pycode/*.pickle
	rm -f utils/*3.py*
	rm -f utils/regression_test.js

.PHONY: clean-testfiles
clean-testfiles:
	rm -rf tests/.coverage
	rm -rf tests/build
	rm -rf .tox/
	rm -rf .cache/

.PHONY: clean-buildfiles
clean-buildfiles:
	rm -rf build

.PHONY: clean-mypyfiles
clean-mypyfiles:
	find . -name '.mypy_cache' -exec rm -rf {} +

.PHONY: style-check
style-check:
	@flake8

.PHONY: type-check
type-check:
	mypy sphinx

.PHONY: doclinter
doclinter:
	python utils/doclinter.py CHANGES *.rst doc/

.PHONY: test
test:
	@$(PYTHON) -X dev -m pytest -v $(TEST)

.PHONY: covertest
covertest:
	@$(PYTHON) -X dev -m pytest -v --cov=sphinx --junitxml=.junit.xml $(TEST)

.PHONY: build
build:
	@$(PYTHON) setup.py build

.PHONY: docs
docs:
ifndef target
	$(info You need to provide a target variable, e.g. `make docs target=html`.)
endif
	$(MAKE) -C doc $(target)

```


# package.json (the start)

```
{
  "name": "sphinx",
  "scripts": {
    "test": "./node_modules/.bin/karma start --browsers Firefox --single-run"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/sphinx-doc/sphinx.git"
  },
  "bugs": {
    "url": "https://github.com/sphinx-doc/sphinx/issues"
  },
  "devDependencies": {
    "jasmine-core": "^3.4.0",
    "karma": "^4.0.0",
    "karma-chrome-launcher": "^3.0.0",
    "karma-firefox-launcher": "^1.1.0",
    "karma-jasmine": "^2.0.0"
  }
}

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest tests/test_ext_viewcode.py`

## Scope
`sphinx/ext/viewcode.py`
`tests/`

## Done when
Building `make html epub` with `viewcode_enable_epub=False` creates no viewcode module pages in the epub output.
The epub skip still applies when the `html` build runs first and the `epub` build reuses the environment.

## Approach
Trace `sphinx/ext/viewcode.py`: `collect_pages` handles the `html-collect-pages` event and yields one module page per entry in `env._viewcode_modules`. Because the `html` build can populate that environment before the `epub` build reuses it, any skip must happen at page-collection time, not only during `doctree-read`.

Preferred approach: in `collect_pages`, return early or continue past each module when the active builder is epub and `viewcode_enable_epub` is false. Add a regression test under `tests/` that builds `html` then `epub` with the default false config and asserts no `_modules/` pages are emitted; also confirm the true setting still emits them if the existing test fixture supports it.

Candidate alternatives if the first fails:
1. Clear or bypass `env._viewcode_modules` for epub builds before page collection, but ensure this does not corrupt the shared environment for later builders.
2. Filter viewcode pages in the EPUB builder’s additional-page generation; this is broader and couples the builder to an extension, so use only if `collect_pages` cannot distinguish the builder reliably.
3. Check `app.builder.format == 'epub'` instead of `app.builder.name == 'epub'` if builder naming differs in the failing path.
```

### `prompt.md`

````
viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`
**Describe the bug**
viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`

**To Reproduce**
```
$ make html epub
```

**Expected behavior**
module pages should not be created for epub by default.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions:  sphinx.ext.viewcode
- Extra tools: No

**Additional context**
No
````

### `review.md`

```
verdict: PASS

findings:
- The change adds the required epub guard in `sphinx/ext/viewcode.py::collect_pages`, skipping module page generation when the builder is epub and `viewcode_enable_epub` is false.
- The guard is evaluated on each `collect_pages` call using the active builder, so it also applies when the epub build reuses an environment populated by a prior html build.
- The new test covers the html-then-epub reuse scenario and passes in the check output.
- The only failing test, `test_viewcode`, fails on the baseline tree as well due to an unrelated HTML rendering assertion; the change does not add a failing test.
- Changed files are within the stated scope.
```

### `scope.txt`

```
scope: sphinx/ext/viewcode.py tests
changed: sphinx/ext/viewcode.py +2 -0
changed: tests/test_ext_viewcode.py +13 -0
```

### `task.md`

````
# Task

## Prompt

viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`
**Describe the bug**
viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`

**To Reproduce**
```
$ make html epub
```

**Expected behavior**
module pages should not be created for epub by default.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions:  sphinx.ext.viewcode
- Extra tools: No

**Additional context**
No

## Deliverable

changes to this tree

## Check

`python -m pytest tests/test_ext_viewcode.py`

## Scope

`sphinx/ext/viewcode.py`
`tests/`

## Done when

Building `make html epub` with `viewcode_enable_epub=False` creates no viewcode module pages in the epub output.
The epub skip still applies when the `html` build runs first and the `epub` build reuses the environment.
````

### `test-output.log`

```
check: python -m pytest tests/test_ext_viewcode.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-8.3.3, pluggy-1.5.0
libraries: Sphinx-3.5.0+/10011eea7, docutils-0.21.2
base tempdir: /tmp/pytest-of-root/pytest-5
rootdir: /testbed
configfile: setup.cfg
plugins: cov-5.0.0
collected 4 items

tests/test_ext_viewcode.py F...                                          [100%]

=================================== FAILURES ===================================
________________________________ test_viewcode _________________________________

app = <SphinxTestApp buildername='html'>
status = <_io.StringIO object at 0x73f92f633ee0>
warning = <_io.StringIO object at 0x73f92f633f70>

    @pytest.mark.sphinx(testroot='ext-viewcode')
    def test_viewcode(app, status, warning):
        app.builder.build_all()
    
        warnings = re.sub(r'\\+', '/', warning.getvalue())
        assert re.findall(
            r"index.rst:\d+: WARNING: Object named 'func1' not found in include " +
            r"file .*/spam/__init__.py'",
            warnings
        )
    
        result = (app.outdir / 'index.html').read_text()
        assert result.count('href="_modules/spam/mod1.html#func1"') == 2
        assert result.count('href="_modules/spam/mod2.html#func2"') == 2
        assert result.count('href="_modules/spam/mod1.html#Class1"') == 2
        assert result.count('href="_modules/spam/mod2.html#Class2"') == 2
        assert result.count('@decorator') == 1
    
        # test that the class attribute is correctly documented
        assert result.count('this is Class3') == 2
        assert 'this is the class attribute class_attr' in result
        # the next assert fails, until the autodoc bug gets fixed
        assert result.count('this is the class attribute class_attr') == 2
    
        result = (app.outdir / '_modules/spam/mod1.html').read_text()
        result = re.sub('<span class=".*?">', '<span>', result)  # filter pygments classes
>       assert ('<div class="viewcode-block" id="Class1"><a class="viewcode-back" '
                'href="../../index.html#spam.Class1">[docs]</a>'
                '<span>@decorator</span>\n'
                '<span>class</span> <span>Class1</span>'
                '<span>(</span><span>object</span><span>):</span>\n'
                '    <span>&quot;&quot;&quot;</span>\n'
                '<span>    this is Class1</span>\n'
                '<span>    &quot;&quot;&quot;</span></div>\n') in result
E       assert '<div class="viewcode-block" id="Class1"><a class="viewcode-back" href="../../index.html#spam.Class1">[docs]</a><span>...an>\n    <span>&quot;&quot;&quot;</span>\n<span>    this is Class1</span>\n<span>    &quot;&quot;&quot;</span></div>\n' in '\n<!DOCTYPE html>\n\n<html>\n  <head>\n    <meta charset="utf-8" />\n    <meta name="viewport" content="width=device-..."https://github.com/bitprophet/alabaster">Alabaster 0.7.11</a>\n      \n    </div>\n\n    \n\n    \n  </body>\n</html>'

tests/test_ext_viewcode.py:42: AssertionError
--------------------------- Captured stdout teardown ---------------------------
# testroot: root
# builder: html
# srcdir: /tmp/pytest-of-root/pytest-5/ext-viewcode
# outdir: /tmp/pytest-of-root/pytest-5/ext-viewcode/_build/html
# status: 
[01mRunning Sphinx v3.5.0+/10011eea7[39;49;00m
[01mbuilding [html]: [39;49;00mall source files
[01mupdating environment: [39;49;00m[new config] 2 added, 0 changed, 0 removed
[01mreading sources... [39;49;00m[ 50%] [35mindex[39;49;00m                                                [01mreading sources... [39;49;00m[100%] [35mobjects[39;49;00m                                              
[01mlooking for now-outdated files... [39;49;00mnone found
[01mpickling environment... [39;49;00mdone
[01mchecking consistency... [39;49;00mdone
[01mpreparing documents... [39;49;00mdone
[01mwriting output... [39;49;00m[ 50%] [32mindex[39;49;00m                                                 [01mwriting output... [39;49;00m[100%] [32mobjects[39;49;00m                                               
[01mgenerating indices... [39;49;00mgenindex py-modindex done
[01mhighlighting module code... [39;49;00m[ 50%] [94mspam.mod1[39;49;00m                                   [01mhighlighting module code... [39;49;00m[100%] [94mspam.mod2[39;49;00m                                   
[01mwriting additional pages... [39;49;00msearch done
[01mcopying static files... [39;49;00mdone
[01mcopying extra files... [39;49;00mdone
[01mdumping search index in English (code: en)... [39;49;00mdone
[01mdumping object inventory... [39;49;00mdone

# warning: 
[91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/index.rst:23: WARNING: Object named 'func1' not found in include file '/tmp/pytest-of-root/pytest-5/ext-viewcode/spam/__init__.py'[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/spam/mod1.py:docstring of spam.mod1.Class3:1: WARNING: duplicate object description of spam.mod3.Class3, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/spam/mod1.py:docstring of spam.mod3.Class3.class_attr:1: WARNING: duplicate object description of spam.mod3.Class3.class_attr, other instance in index, use :noindex: for one of them[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:84: WARNING: Error in declarator
If declarator-id with parameters (e.g., 'void f(int arg)'):
  Invalid C declaration: Expected identifier in nested name. [error at 18]
    Sphinx_DoSomething()
    ------------------^
If parenthesis in noptr-declarator (e.g., 'void (*f(int arg))(double)'):
  Error in declarator or parameters
  Invalid C declaration: Expected identifier in nested name. [error at 19]
    Sphinx_DoSomething()
    -------------------^
[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:86: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 19]
  SphinxStruct.member
  -------------------^[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:92: WARNING: Error in declarator or parameters
Invalid C declaration: Expected identifier in nested name. [error at 13]
  sphinx_global
  -------------^[39;49;00m
[31m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:155: WARNING: Unknown directive type "userdesc".

.. userdesc:: myobj:parameter

   Description of userdesc.[39;49;00m
[31m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:160: WARNING: Unknown interpreted text role "userdescrole".[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:166: WARNING: Too many template argument lists compared to parameter lists. Argument lists: 1, Parameter lists: 0, Extra empty parameters lists prepended: 1. Declaration:
	n::Array<T, d>[39;49;00m
[91m/tmp/pytest-of-root/pytest-5/ext-viewcode/objects.rst:117: WARNING: Unparseable C cross-reference: 'SphinxType *'
Invalid C declaration: Expected end of definition. [error at 11]
  SphinxType *
  -----------^[39;49;00m

=============================== warnings summary ===============================
sphinx/util/docutils.py:45
  /testbed/sphinx/util/docutils.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

sphinx/directives/patches.py:14
  /testbed/sphinx/directives/patches.py:14: DeprecationWarning: The `docutils.parsers.rst.directive.html` module will be removed in Docutils 2.0. Since Docutils 0.18, the "Meta" node is defined in `docutils.parsers.rst.directives.misc`.
    from docutils.parsers.rst.directives import html, images, tables

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:210: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse():  # type: Node

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.translatable):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:110: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for ref in self.document.traverse(nodes.substitution_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:131: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:150: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.block_quote):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:175: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.Element):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:222: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:189: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:279: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.doctest_block):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:116: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/citation.py:135: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.citation_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/latex/transforms.py:36: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:291: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: Element

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/util/compat.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/index.py:51: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.index):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/math.py:84: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    self.data['has_equations'][docname] = any(document.traverse(math_node))

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/asset.py:127: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(addnodes.download_reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/collectors/title.py:46: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.section):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/ext/viewcode.py:91: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:301: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.system_message):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/__init__.py:390: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.manpage):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/transforms/i18n.py:488: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for inline in self.document.traverse(matcher):  # type: nodes.inline

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/domains/python.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in result.traverse(nodes.Text):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:422: DeprecationWarning: The frontend.OptionParser class will be replaced by a subclass of argparse.ArgumentParser in Docutils 0.21 or later.
    self.docsettings = OptionParser(

tests/test_ext_viewcode.py: 360 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/optparse.py:1000: DeprecationWarning: The frontend.Option class will be removed in Docutils 0.21 or later.
    option = self.option_class(*args, **kwargs)

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/c.py:3494: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/domains/cpp.py:7070: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(AliasNode):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:69: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.pending_xref):

tests/test_ext_viewcode.py: 47 warnings
  /testbed/sphinx/util/nodes.py:598: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in document.traverse(addnodes.only):

tests/test_ext_viewcode.py: 24 warnings
  /testbed/sphinx/transforms/post_transforms/images.py:33: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.image):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/__init__.py:216: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.desc_sig_element):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:48: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.substitution_definition):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/transforms.py:44: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(matcher):  # type: nodes.literal

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/builders/latex/transforms.py:606: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(nodes.title):

tests/test_ext_viewcode.py: 36 warnings
  /testbed/sphinx/builders/latex/transforms.py:608: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for i, index in enumerate(node.traverse(addnodes.index)):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:43: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in self.document.traverse(addnodes.highlightlang):

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:95: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for lbnode in self.document.traverse(nodes.literal_block):  # type: nodes.literal_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/transforms/post_transforms/code.py:99: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for dbnode in self.document.traverse(nodes.doctest_block):  # type: nodes.doctest_block

tests/test_ext_viewcode.py: 12 warnings
  /testbed/sphinx/environment/__init__.py:541: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:203: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for subtocnode in toc.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:261: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for refnode in newnode.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/__init__.py:181: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/html/__init__.py:844: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in doctree.traverse(nodes.image):

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/environment/adapters/toctree.py:312: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in toc.traverse(nodes.reference):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:114: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.
    _gaq.push(['_setAllowLinker', true]);

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:70: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/about.html:99: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /testbed/sphinx/environment/adapters/toctree.py:328: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for toctreenode in doctree.traverse(addnodes.toctree):

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:215: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 26 warnings
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/alabaster/layout.html:238: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:33: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:224: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:386: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py::test_viewcode
tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_local_source_files
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  <template>:401: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:350: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for img in node.traverse(nodes.image):

tests/test_ext_viewcode.py: 14 warnings
  /testbed/sphinx/util/nodes.py:352: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for raw in node.traverse(nodes.raw):

tests/test_ext_viewcode.py::test_linkcode
tests/test_ext_viewcode.py::test_linkcode
  /testbed/sphinx/ext/linkcode.py:42: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for objnode in doctree.traverse(addnodes.desc):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:275: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for reference in tree.traverse(nodes.reference):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:283: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for target in tree.traverse(nodes.target):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:290: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for desc_signature in tree.traverse(addnodes.desc_signature):

tests/test_ext_viewcode.py::test_viewcode_epub_builder
tests/test_ext_viewcode.py::test_viewcode_epub_builder
  /testbed/sphinx/builders/_epub_base.py:340: PendingDeprecationWarning: nodes.Node.traverse() is obsoleted by Node.findall().
    for node in tree.traverse(nodes.reference):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED tests/test_ext_viewcode.py::test_viewcode - assert '<div class="viewco...
================== 1 failed, 3 passed, 1056 warnings in 9.37s ==================

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: sphinx/ext/viewcode.py tests
changed: sphinx/ext/viewcode.py +2 -0
changed: tests/test_ext_viewcode.py +13 -0
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
