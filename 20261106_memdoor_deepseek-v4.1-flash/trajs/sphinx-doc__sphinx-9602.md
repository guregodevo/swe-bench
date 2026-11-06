# sphinx-doc__sphinx-9602 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 128s 89 lines cost=0.005759 in=435013 cached=407552 out=8812 calls=25`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

Nitpick flags Literal annotation values as missing py:class
### Describe the bug

When a value is present in a type annotation as `Literal`, sphinx will treat the value as a `py:class`. With nitpick enabled, values like `Literal[True]` end up failing, because `True` is not a class.

This is a problem for builds which want to use `-n -W` to catch doc errors.

### How to Reproduce

Setup a simple function which uses Literal, then attempt to autodoc it. e.g.
```python
import typing
@typing.overload
def foo(x: "typing.Literal[True]") -> int: ...
@typing.overload
def foo(x: "typing.Literal[False]") -> str: ...
def foo(x: bool):
    """a func"""
    return 1 if x else "foo"
```

I've pushed an example [failing project](https://github.com/sirosen/repro/tree/master/sphinxdoc/literal) to [my repro repo](https://github.com/sirosen/repro). Just run `./doc.sh` with `sphinx-build` available to see the failing build.

### Expected behavior

`Literal[True]` (or whatever literal value) should be present in the type annotation but should not trigger the nitpick warning.

### Your project

https://github.com/sirosen/repro/tree/master/sphinxdoc/literal

### Screenshots

_No response_

### OS

Linux

### Python version

3.8, 3.9

### Sphinx version

4.1.2

### Sphinx extensions

autodoc

### Extra tools

_No response_

### Additional context

_No response_

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log --oneline -3"
}
```

**tool result**

```
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
0a08816d9 SWE-bench
6c38f68da Merge pull request #9582 from blueyed/tox-passenv-COLORTERM
80fbbb846 Merge pull request #9591 from tk0miya/9585_type_for_pyproperty
```

**assistant → tool `bash`**

```json
{
  "command": "grep -R \"nitpick\" -n sphinx/domains/python.py | head -50; grep -R \"Literal\" -n sphinx | head -50"
}
```

**tool result**

```
1385:    """Do not emit nitpicky warnings for built-in types."""
sphinx/roles.py:276:class EmphasizedLiteral(SphinxRole):
sphinx/roles.py:354:    'file': EmphasizedLiteral(),
sphinx/roles.py:355:    'samp': EmphasizedLiteral(),
sphinx/transforms/i18n.py:127:            # Avoid "Literal block expected; none found." warnings.
sphinx/transforms/i18n.py:249:            # Avoid "Literal block expected; none found." warnings.
sphinx/directives/code.py:180:class LiteralIncludeReader:
sphinx/directives/code.py:372:class LiteralInclude(SphinxDirective):
sphinx/directives/code.py:422:            reader = LiteralIncludeReader(filename, self.options, self.config)
sphinx/directives/code.py:463:    directives.register_directive('literalinclude', LiteralInclude)
sphinx/util/cfamily.py:209:class UnsupportedMultiCharacterCharLiteral(Exception):
sphinx/util/typing.py:179:        elif cls.__module__ == 'typing' and getattr(origin, '_name', None) == 'Literal':
sphinx/util/typing.py:383:        elif qualname == 'Literal':
sphinx/writers/latex.py:1790:                self.body.append(CR + r'\def\sphinxLiteralBlockLabel{' + labels + '}')
sphinx/writers/texinfo.py:1127:            self.body.append('\n\n@float LiteralBlock\n')
sphinx/builders/latex/transforms.py:551:class LiteralBlockTransform(SphinxPostTransform):
sphinx/builders/latex/transforms.py:621:    app.add_post_transform(LiteralBlockTransform)
sphinx/texinputs/sphinxlatexliterals.sty:9:%   - \sphinxLiteralBlockLabel
sphinx/texinputs/sphinxlatexliterals.sty:236:\newcommand*\sphinxLiteralBlockLabel {}
sphinx/texinputs/sphinxlatexliterals.sty:241:% insert a \label via \sphinxLiteralBlockLabel
sphinx/texinputs/sphinxlatexliterals.sty:244:       {\py@NormalColor\sphinxcaption{\sphinxLiteralBlockLabel #1}}%
sphinx/texinputs/sphinxlatexliterals.sty:497:      \ifx\sphinxLiteralBlockLabel\empty\else
sphinx/texinputs/sphinxlatexliterals.sty:501:          \phantomsection\sphinxLiteralBlockLabel
sphinx/texinputs/sphinxlatexliterals.sty:534:  \global\let\sphinxLiteralBlockLabel\empty
sphinx/domains/c.py:34:                                 UnsupportedMultiCharacterCharLiteral, anon_identifier_re,
sphinx/domains/c.py:279:class ASTLiteral(ASTExpression):
sphinx/domains/c.py:283:class ASTBooleanLiteral(ASTLiteral):
sphinx/domains/c.py:299:class ASTNumberLiteral(ASTLiteral):
sphinx/domains/c.py:312:class ASTCharLiteral(ASTLiteral):
sphinx/domains/c.py:320:            raise UnsupportedMultiCharacterCharLiteral(decoded)
sphinx/domains/c.py:334:class ASTStringLiteral(ASTLiteral):
sphinx/domains/c.py:2191:    def _parse_literal(self) -> ASTLiteral:
sphinx/domains/c.py:2199:            return ASTBooleanLiteral(True)
sphinx/domains/c.py:2201:            return ASTBooleanLiteral(False)
sphinx/domains/c.py:2205:            return ASTNumberLiteral(self.definition[pos:self.pos])
sphinx/domains/c.py:2210:                return ASTNumberLiteral(self.definition[pos:self.pos])
sphinx/domains/c.py:2214:            return ASTStringLiteral(string)
sphinx/domains/c.py:2221:                return ASTCharLiteral(prefix, data)
sphinx/domains/c.py:2224:            except UnsupportedMultiCharacterCharLiteral:
sphinx/domains/cpp.py:34:                                 UnsupportedMultiCharacterCharLiteral, anon_identifier_re,
sphinx/domains/cpp.py:863:class ASTLiteral(ASTExpression):
sphinx/domains/cpp.py:867:class ASTPointerLiteral(ASTLiteral):
sphinx/domains/cpp.py:879:class ASTBooleanLiteral(ASTLiteral):
sphinx/domains/cpp.py:900:class ASTNumberLiteral(ASTLiteral):
sphinx/domains/cpp.py:916:class ASTStringLiteral(ASTLiteral):
sphinx/domains/cpp.py:932:class ASTCharLiteral(ASTLiteral):
sphinx/domains/cpp.py:942:            raise UnsupportedMultiCharacterCharLiteral(decoded)
sphinx/domains/cpp.py:962:class ASTUserDefinedLiteral(ASTLiteral):
sphinx/domains/cpp.py:963:    def __init__(self, literal: ASTLiteral, ident: ASTIdentifier):
sphinx/domains/cpp.py:982:class ASTThisLiteral(ASTExpression):
sphinx/domains/cpp.py:1730:class ASTOperatorLiteral(ASTOperator):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1300,1450p' sphinx/domains/python.py; sed -n '150,210p' sphinx/util/typing.py; sed -n '360,400p' sphinx/util/typing.py"
}
```

**tool result**

```
                matches = canonicals
            else:
                logger.warning(__('more than one target found for cross-reference %r: %s'),
                               target, ', '.join(match[0] for match in matches),
                               type='ref', subtype='python', location=node)
        name, obj = matches[0]

        if obj[2] == 'module':
            return self._make_module_refnode(builder, fromdocname, name, contnode)
        else:
            # determine the content of the reference by conditions
            content = find_pending_xref_condition(node, 'resolved')
            if content:
                children = content.children
            else:
                # if not found, use contnode
                children = [contnode]

            return make_refnode(builder, fromdocname, obj[0], obj[1], children, name)

    def resolve_any_xref(self, env: BuildEnvironment, fromdocname: str, builder: Builder,
                         target: str, node: pending_xref, contnode: Element
                         ) -> List[Tuple[str, Element]]:
        modname = node.get('py:module')
        clsname = node.get('py:class')
        results: List[Tuple[str, Element]] = []

        # always search in "refspecific" mode with the :any: role
        matches = self.find_obj(env, modname, clsname, target, None, 1)
        for name, obj in matches:
            if obj[2] == 'module':
                results.append(('py:mod',
                                self._make_module_refnode(builder, fromdocname,
                                                          name, contnode)))
            else:
                # determine the content of the reference by conditions
                content = find_pending_xref_condition(node, 'resolved')
                if content:
                    children = content.children
                else:
                    # if not found, use contnode
                    children = [contnode]

                results.append(('py:' + self.role_for_objtype(obj[2]),
                                make_refnode(builder, fromdocname, obj[0], obj[1],
                                             children, name)))
        return results

    def _make_module_refnode(self, builder: Builder, fromdocname: str, name: str,
                             contnode: Node) -> Element:
        # get additional info for modules
        module = self.modules[name]
        title = name
        if module.synopsis:
            title += ': ' + module.synopsis
        if module.deprecated:
            title += _(' (deprecated)')
        if module.platform:
            title += ' (' + module.platform + ')'
        return make_refnode(builder, fromdocname, module.docname, module.node_id,
                            contnode, title)

    def get_objects(self) -> Iterator[Tuple[str, str, str, str, str, int]]:
        for modname, mod in self.modules.items():
            yield (modname, modname, 'module', mod.docname, mod.node_id, 0)
        for refname, obj in self.objects.items():
            if obj.objtype != 'module':  # modules are already handled
                if obj.aliased:
                    # aliased names are not full-text searchable.
                    yield (refname, refname, obj.objtype, obj.docname, obj.node_id, -1)
                else:
                    yield (refname, refname, obj.objtype, obj.docname, obj.node_id, 1)

    def get_full_qualified_name(self, node: Element) -> Optional[str]:
        modname = node.get('py:module')
        clsname = node.get('py:class')
        target = node.get('reftarget')
        if target is None:
            return None
        else:
            return '.'.join(filter(None, [modname, clsname, target]))


def builtin_resolver(app: Sphinx, env: BuildEnvironment,
                     node: pending_xref, contnode: Element) -> Element:
    """Do not emit nitpicky warnings for built-in types."""
    def istyping(s: str) -> bool:
        if s.startswith('typing.'):
            s = s.split('.', 1)[1]

        return s in typing.__all__  # type: ignore

    if node.get('refdomain') != 'py':
        return None
    elif node.get('reftype') in ('class', 'obj') and node.get('reftarget') == 'None':
        return contnode
    elif node.get('reftype') in ('class', 'exc'):
        reftarget = node.get('reftarget')
        if inspect.isclass(getattr(builtins, reftarget, None)):
            # built-in class
            return contnode
        elif istyping(reftarget):
            # typing class
            return contnode

    return None


def setup(app: Sphinx) -> Dict[str, Any]:
    app.setup_extension('sphinx.directives')

    app.add_domain(PythonDomain)
    app.add_config_value('python_use_unqualified_type_names', False, 'env')
    app.connect('object-description-transform', filter_meta_fields)
    app.connect('missing-reference', builtin_resolver, priority=900)

    return {
        'version': 'builtin',
        'env_version': 3,
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
        if len(cls.__args__) > 1 and cls.__args__[-1] is NoneType:
            if len(cls.__args__) > 2:
                args = ', '.join(restify(a) for a in cls.__args__[:-1])
                return ':obj:`~typing.Optional`\\ [:obj:`~typing.Union`\\ [%s]]' % args
            else:
                return ':obj:`~typing.Optional`\\ [%s]' % restify(cls.__args__[0])
        else:
            args = ', '.join(restify(a) for a in cls.__args__)
            return ':obj:`~typing.Union`\\ [%s]' % args
    elif inspect.isgenericalias(cls):
        if isinstance(cls.__origin__, typing._SpecialForm):
            text = restify(cls.__origin__)  # type: ignore
        elif getattr(cls, '_name', None):
            if cls.__module__ == 'typing':
                text = ':class:`~%s.%s`' % (cls.__module__, cls._name)
            else:
                text = ':class:`%s.%s`' % (cls.__module__, cls._name)
        else:
            text = restify(cls.__origin__)

        origin = getattr(cls, '__origin__', None)
        if not hasattr(cls, '__args__'):
            pass
        elif all(is_system_TypeVar(a) for a in cls.__args__):
            # Suppress arguments if all system defined TypeVars (ex. Dict[KT, VT])
            pass
        elif cls.__module__ == 'typing' and cls._name == 'Callable':
            args = ', '.join(restify(a) for a in cls.__args__[:-1])
            text += r"\ [[%s], %s]" % (args, restify(cls.__args__[-1]))
        elif cls.__module__ == 'typing' and getattr(origin, '_name', None) == 'Literal':
            text += r"\ [%s]" % ', '.join(repr(a) for a in cls.__args__)
        elif cls.__args__:
            text += r"\ [%s]" % ", ".join(restify(a) for a in cls.__args__)

        return text
    elif isinstance(cls, typing._SpecialForm):
        return ':obj:`~%s.%s`' % (cls.__module__, cls._name)
    elif hasattr(cls, '__qualname__'):
        if cls.__module__ == 'typing':
            return ':class:`~%s.%s`' % (cls.__module__, cls.__qualname__)
        else:
            return ':class:`%s.%s`' % (cls.__module__, cls.__qualname__)
    elif isinstance(cls, ForwardRef):
        return ':class:`%s`' % cls.__forward_arg__
    else:
        # not a class (ex. TypeVar)
        if cls.__module__ == 'typing':
            return ':obj:`~%s.%s`' % (cls.__module__, cls.__name__)
        else:
            return ':obj:`%s.%s`' % (cls.__module__, cls.__name__)


def _restify_py36(cls: Optional[Type]) -> str:
    module = getattr(cls, '__module__', None)
    if module == 'typing':
        if getattr(cls, '_name', None):
            qualname = cls._name
        elif getattr(cls, '__qualname__', None):
            qualname = cls.__qualname__
        elif getattr(cls, '__forward_arg__', None):
            qualname = cls.__forward_arg__
        if not isinstance(annotation.__args__, (list, tuple)):
            # broken __args__ found
            pass
        elif qualname in ('Optional', 'Union'):
            if len(annotation.__args__) > 1 and annotation.__args__[-1] is NoneType:
                if len(annotation.__args__) > 2:
                    args = ', '.join(stringify(a) for a in annotation.__args__[:-1])
                    return 'Optional[Union[%s]]' % args
                else:
                    return 'Optional[%s]' % stringify(annotation.__args__[0])
            else:
                args = ', '.join(stringify(a) for a in annotation.__args__)
                return 'Union[%s]' % args
        elif qualname == 'types.Union':
            if len(annotation.__args__) > 1 and None in annotation.__args__:
                args = ' | '.join(stringify(a) for a in annotation.__args__ if a)
                return 'Optional[%s]' % args
            else:
                return ' | '.join(stringify(a) for a in annotation.__args__)
        elif qualname == 'Callable':
            args = ', '.join(stringify(a) for a in annotation.__args__[:-1])
            returns = stringify(annotation.__args__[-1])
            return '%s[[%s], %s]' % (qualname, args, returns)
        elif qualname == 'Literal':
            args = ', '.join(repr(a) for a in annotation.__args__)
            return '%s[%s]' % (qualname, args)
        elif str(annotation).startswith('typing.Annotated'):  # for py39+
            return stringify(annotation.__args__[0])
        elif all(is_system_TypeVar(a) for a in annotation.__args__):
            # Suppress arguments if all system defined TypeVars (ex. Dict[KT, VT])
            return qualname
        else:
            args = ', '.join(stringify(a) for a in annotation.__args__)
            return '%s[%s]' % (qualname, args)

    return qualname


def _stringify_py36(annotation: Any) -> str:
    """stringify() for py36."""
    module = getattr(annotation, '__module__', None)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"type_to_xref\\|_parse_annotation\\|pending_xref\" sphinx/domains/python.py | head -60; grep -R \"Literal\" -n tests | head -50"
}
```

**tool result**

```
26:from sphinx.addnodes import desc_signature, pending_xref, pending_xref_condition
41:from sphinx.util.nodes import find_pending_xref_condition, make_id, make_refnode
83:def type_to_xref(text: str, env: BuildEnvironment = None) -> addnodes.pending_xref:
101:        contnodes: List[Node] = [pending_xref_condition('', shortname, condition='resolved'),
102:                                 pending_xref_condition('', text, condition='*')]
106:    return pending_xref('', *contnodes,
110:def _parse_annotation(annotation: str, env: BuildEnvironment = None) -> List[Node]:
175:        warnings.warn("The env parameter for _parse_annotation becomes required now.",
183:                result[i] = type_to_xref(str(node), env)
186:        return [type_to_xref(annotation, env)]
215:            children = _parse_annotation(param.annotation, env)
295:        # pending_xref node
311:        elif isinstance(result, pending_xref) and env.config.python_use_unqualified_type_names:
317:            contnodes = [pending_xref_condition('', '', textnode, condition='resolved'),
318:                         pending_xref_condition('', '', *children, condition='*')]
497:            children = _parse_annotation(retann, self.env)
664:            annotations = _parse_annotation(typ, self.env)
825:            annotations = _parse_annotation(typ, self.env)
864:            annotations = _parse_annotation(typ, self.env)
1274:                     type: str, target: str, node: pending_xref, contnode: Element
1311:            content = find_pending_xref_condition(node, 'resolved')
1321:                         target: str, node: pending_xref, contnode: Element
1336:                content = find_pending_xref_condition(node, 'resolved')
1384:                     node: pending_xref, contnode: Element) -> Element:
tests/test_intl.py:213:                             'WARNING: Literal block expected; none found.')
tests/roots/test-directive-code/classes.rst:16:Literal Includes
tests/roots/test-directive-code/literal-diff.inc:1:# Literally included file using Python highlighting
tests/roots/test-directive-code/caption.rst:23:Literal Include
tests/roots/test-directive-code/caption.rst:44:Named Literal Include
tests/roots/test-directive-code/target.py:1:# Literally included file using Python highlighting
tests/roots/test-directive-code/python.rst:2:Literal Includes for python
tests/roots/test-directive-code/emphasize.rst:1:Literal Includes with Highlighted Lines
tests/roots/test-directive-code/literal.inc:1:# Literally included file using Python highlighting
tests/roots/test-directive-code/index.rst:21:Literal Includes
tests/roots/test-directive-code/py-decorators.inc:1:# Literally included file using Python highlighting
tests/roots/test-directive-code/linenothreshold.rst:1:Code Blocks and Literal Includes with Line Numbers via linenothreshold
tests/roots/test-directive-code/linenos.rst:1:Literal Includes with Line Numbers
tests/roots/test-directive-code/namedblocks.rst:22:Named Literal Include
tests/roots/test-root/includes.txt:24:Literalinclude options
tests/roots/test-root/literal_orig.inc:1:# Literally included file using Python highlighting
tests/roots/test-root/literal.inc:1:# Literally included file using Python highlighting
tests/test_roles.py:15:from sphinx.roles import EmphasizedLiteral
tests/test_roles.py:20:    emph_literal_role = EmphasizedLiteral()
tests/test_util_typing.py:138:def test_restify_type_Literal():
tests/test_util_typing.py:139:    from typing import Literal  # type: ignore
tests/test_util_typing.py:140:    assert restify(Literal[1, "2", "\r"]) == ":obj:`~typing.Literal`\\ [1, '2', '\\r']"
tests/test_util_typing.py:269:def test_stringify_type_Literal():
tests/test_util_typing.py:270:    from typing import Literal  # type: ignore
tests/test_util_typing.py:271:    assert stringify(Literal[1, "2", "\r"]) == "Literal[1, '2', '\\r']"
tests/test_build_latex.py:1495:    assert (r'\def\sphinxLiteralBlockLabel{'
tests/test_build_latex.py:1498:    assert (r'\def\sphinxLiteralBlockLabel{'
tests/test_directive_code.py:17:from sphinx.directives.code import LiteralIncludeReader
tests/test_directive_code.py:35:def test_LiteralIncludeReader(literal_inc_path):
tests/test_directive_code.py:37:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:45:def test_LiteralIncludeReader_lineno_start(literal_inc_path):
tests/test_directive_code.py:47:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:55:def test_LiteralIncludeReader_pyobject1(literal_inc_path):
tests/test_directive_code.py:57:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:65:def test_LiteralIncludeReader_pyobject2(literal_inc_path):
tests/test_directive_code.py:67:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:76:def test_LiteralIncludeReader_pyobject3(literal_inc_path):
tests/test_directive_code.py:78:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:85:def test_LiteralIncludeReader_pyobject_and_lines(literal_inc_path):
tests/test_directive_code.py:87:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:94:def test_LiteralIncludeReader_lines1(literal_inc_path):
tests/test_directive_code.py:96:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:98:    assert content == ("# Literally included file using Python highlighting\n"
tests/test_directive_code.py:104:def test_LiteralIncludeReader_lines2(literal_inc_path):
tests/test_directive_code.py:106:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:108:    assert content == ("# Literally included file using Python highlighting\n"
tests/test_directive_code.py:114:def test_LiteralIncludeReader_lines_and_lineno_match1(literal_inc_path):
tests/test_directive_code.py:116:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
tests/test_directive_code.py:125:def test_LiteralIncludeReader_lines_and_lineno_match2(literal_inc_path, app, status, warning):
tests/test_directive_code.py:127:    reader = LiteralIncludeReader(literal_inc_path, options, DUMMY_CONFIG)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '70,200p' sphinx/domains/python.py"
}
```

**tool result**

```
    node_id: str
    objtype: str
    aliased: bool


class ModuleEntry(NamedTuple):
    docname: str
    node_id: str
    synopsis: str
    platform: str
    deprecated: bool


def type_to_xref(text: str, env: BuildEnvironment = None) -> addnodes.pending_xref:
    """Convert a type string to a cross reference node."""
    if text == 'None':
        reftype = 'obj'
    else:
        reftype = 'class'

    if env:
        kwargs = {'py:module': env.ref_context.get('py:module'),
                  'py:class': env.ref_context.get('py:class')}
    else:
        kwargs = {}

    if env.config.python_use_unqualified_type_names:
        # Note: It would be better to use qualname to describe the object to support support
        # nested classes.  But python domain can't access the real python object because this
        # module should work not-dynamically.
        shortname = text.split('.')[-1]
        contnodes: List[Node] = [pending_xref_condition('', shortname, condition='resolved'),
                                 pending_xref_condition('', text, condition='*')]
    else:
        contnodes = [nodes.Text(text)]

    return pending_xref('', *contnodes,
                        refdomain='py', reftype=reftype, reftarget=text, **kwargs)


def _parse_annotation(annotation: str, env: BuildEnvironment = None) -> List[Node]:
    """Parse type annotation."""
    def unparse(node: ast.AST) -> List[Node]:
        if isinstance(node, ast.Attribute):
            return [nodes.Text("%s.%s" % (unparse(node.value)[0], node.attr))]
        elif isinstance(node, ast.BinOp):
            result: List[Node] = unparse(node.left)
            result.extend(unparse(node.op))
            result.extend(unparse(node.right))
            return result
        elif isinstance(node, ast.BitOr):
            return [nodes.Text(' '), addnodes.desc_sig_punctuation('', '|'), nodes.Text(' ')]
        elif isinstance(node, ast.Constant):  # type: ignore
            if node.value is Ellipsis:
                return [addnodes.desc_sig_punctuation('', "...")]
            else:
                return [nodes.Text(node.value)]
        elif isinstance(node, ast.Expr):
            return unparse(node.value)
        elif isinstance(node, ast.Index):
            return unparse(node.value)
        elif isinstance(node, ast.List):
            result = [addnodes.desc_sig_punctuation('', '[')]
            if node.elts:
                # check if there are elements in node.elts to only pop the
                # last element of result if the for-loop was run at least
                # once
                for elem in node.elts:
                    result.extend(unparse(elem))
                    result.append(addnodes.desc_sig_punctuation('', ', '))
                result.pop()
            result.append(addnodes.desc_sig_punctuation('', ']'))
            return result
        elif isinstance(node, ast.Module):
            return sum((unparse(e) for e in node.body), [])
        elif isinstance(node, ast.Name):
            return [nodes.Text(node.id)]
        elif isinstance(node, ast.Subscript):
            result = unparse(node.value)
            result.append(addnodes.desc_sig_punctuation('', '['))
            result.extend(unparse(node.slice))
            result.append(addnodes.desc_sig_punctuation('', ']'))
            return result
        elif isinstance(node, ast.Tuple):
            if node.elts:
                result = []
                for elem in node.elts:
                    result.extend(unparse(elem))
                    result.append(addnodes.desc_sig_punctuation('', ', '))
                result.pop()
            else:
                result = [addnodes.desc_sig_punctuation('', '('),
                          addnodes.desc_sig_punctuation('', ')')]

            return result
        else:
            if sys.version_info < (3, 8):
                if isinstance(node, ast.Ellipsis):
                    return [addnodes.desc_sig_punctuation('', "...")]
                elif isinstance(node, ast.NameConstant):
                    return [nodes.Text(node.value)]

            raise SyntaxError  # unsupported syntax

    if env is None:
        warnings.warn("The env parameter for _parse_annotation becomes required now.",
                      RemovedInSphinx50Warning, stacklevel=2)

    try:
        tree = ast_parse(annotation)
        result = unparse(tree)
        for i, node in enumerate(result):
            if isinstance(node, nodes.Text) and node.strip():
                result[i] = type_to_xref(str(node), env)
        return result
    except SyntaxError:
        return [type_to_xref(annotation, env)]


def _parse_arglist(arglist: str, env: BuildEnvironment = None) -> addnodes.desc_parameterlist:
    """Parse a list of arguments using AST parser"""
    params = addnodes.desc_parameterlist(arglist)
    sig = signature_from_str('(%s)' % arglist)
    last_kind = None
    for param in sig.parameters.values():
        if param.kind != param.POSITIONAL_ONLY and last_kind == param.POSITIONAL_ONLY:
            # PEP-570: Separator for Positional Only Parameter: /
            params += addnodes.desc_parameter('', '', addnodes.desc_sig_operator('', '/'))
        if param.kind == param.KEYWORD_ONLY and last_kind in (param.POSITIONAL_OR_KEYWORD,
                                                              param.POSITIONAL_ONLY,
                                                              None):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -R \"type_to_xref\\|_parse_annotation\\|Literal\\[\" -n tests | head -80; grep -R \"nitpick\" -n tests | head -80"
}
```

**tool result**

```
tests/test_util_typing.py:140:    assert restify(Literal[1, "2", "\r"]) == ":obj:`~typing.Literal`\\ [1, '2', '\\r']"
tests/test_util_typing.py:271:    assert stringify(Literal[1, "2", "\r"]) == "Literal[1, '2', '\\r']"
tests/test_domain_py.py:24:from sphinx.domains.python import (PythonDomain, PythonModuleIndex, _parse_annotation,
tests/test_domain_py.py:278:def test_parse_annotation(app):
tests/test_domain_py.py:279:    doctree = _parse_annotation("int", app.env)
tests/test_domain_py.py:283:    doctree = _parse_annotation("List[int]", app.env)
tests/test_domain_py.py:289:    doctree = _parse_annotation("Tuple[int, int]", app.env)
tests/test_domain_py.py:297:    doctree = _parse_annotation("Tuple[()]", app.env)
tests/test_domain_py.py:304:    doctree = _parse_annotation("Tuple[int, ...]", app.env)
tests/test_domain_py.py:312:    doctree = _parse_annotation("Callable[[int, int], int]", app.env)
tests/test_domain_py.py:324:    doctree = _parse_annotation("Callable[[], int]", app.env)
tests/test_domain_py.py:333:    doctree = _parse_annotation("List[None]", app.env)
tests/test_domain_py.py:340:    doctree = _parse_annotation("None", app.env)
tests/roots/test-transforms-post_transforms-missing-reference/conf.py:1:nitpicky = True
tests/roots/test-ext-autodoc/conf.py:15:nitpicky = True
tests/roots/test-nitpicky-warnings/conf.py:1:nitpicky = True
tests/roots/test-nitpicky-warnings/index.rst:1:test-nitpicky-warnings
tests/test_domain_c.py:640:@pytest.mark.sphinx(testroot='domain-c', confoverrides={'nitpicky': True})
tests/test_domain_c.py:647:@pytest.mark.sphinx(testroot='domain-c', confoverrides={'nitpicky': True})
tests/test_domain_c.py:657:@pytest.mark.sphinx(testroot='domain-c', confoverrides={'nitpicky': True})
tests/test_domain_c.py:666:@pytest.mark.sphinx(confoverrides={'nitpicky': True})
tests/test_domain_c.py:685:@pytest.mark.sphinx(testroot='domain-c', confoverrides={'nitpicky': True})
tests/test_domain_c.py:698:@pytest.mark.sphinx(testroot='domain-c', confoverrides={'nitpicky': True})
tests/test_domain_c.py:705:@pytest.mark.sphinx(testroot='domain-c', confoverrides={'nitpicky': True})
tests/test_domain_c.py:720:@pytest.mark.sphinx(testroot='domain-c-intersphinx', confoverrides={'nitpicky': True})
tests/test_config.py:321:nitpick_warnings = [
tests/test_config.py:329:@pytest.mark.sphinx(testroot='nitpicky-warnings')
tests/test_config.py:330:def test_nitpick_base(app, status, warning):
tests/test_config.py:334:    assert len(warning) == len(nitpick_warnings)
tests/test_config.py:335:    for actual, expected in zip(warning, nitpick_warnings):
tests/test_config.py:339:@pytest.mark.sphinx(testroot='nitpicky-warnings', confoverrides={
tests/test_config.py:340:    'nitpick_ignore': [
tests/test_config.py:347:def test_nitpick_ignore(app, status, warning):
tests/test_config.py:352:@pytest.mark.sphinx(testroot='nitpicky-warnings', confoverrides={
tests/test_config.py:353:    'nitpick_ignore_regex': [
tests/test_config.py:358:def test_nitpick_ignore_regex1(app, status, warning):
tests/test_config.py:363:@pytest.mark.sphinx(testroot='nitpicky-warnings', confoverrides={
tests/test_config.py:364:    'nitpick_ignore_regex': [
tests/test_config.py:369:def test_nitpick_ignore_regex2(app, status, warning):
tests/test_config.py:374:@pytest.mark.sphinx(testroot='nitpicky-warnings', confoverrides={
tests/test_config.py:375:    'nitpick_ignore_regex': [
tests/test_config.py:386:def test_nitpick_ignore_regex_fullmatch(app, status, warning):
tests/test_config.py:390:    assert len(warning) == len(nitpick_warnings)
tests/test_config.py:391:    for actual, expected in zip(warning, nitpick_warnings):
tests/test_transforms_post_transforms.py:16:def test_nitpicky_warning(app, status, warning):
tests/test_domain_cpp.py:1023:@pytest.mark.sphinx(testroot='domain-cpp', confoverrides={'nitpicky': True})
tests/test_domain_cpp.py:1033:@pytest.mark.sphinx(testroot='domain-cpp', confoverrides={'nitpicky': True})
tests/test_domain_cpp.py:1042:@pytest.mark.sphinx(testroot='domain-cpp', confoverrides={'nitpicky': True})
tests/test_domain_cpp.py:1049:@pytest.mark.sphinx(testroot='domain-cpp', confoverrides={'nitpicky': True})
tests/test_domain_cpp.py:1057:                    confoverrides={'nitpicky': True, 'strip_signature_backslash': True})
tests/test_domain_cpp.py:1065:@pytest.mark.sphinx(testroot='domain-cpp', confoverrides={'nitpicky': True})
tests/test_domain_cpp.py:1268:@pytest.mark.sphinx(testroot='domain-cpp', confoverrides={'nitpicky': True})
tests/test_domain_cpp.py:1275:@pytest.mark.sphinx(testroot='domain-cpp-intersphinx', confoverrides={'nitpicky': True})
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '270,350p' tests/test_domain_py.py; sed -n '1,60p' tests/test_domain_py.py"
}
```

**tool result**

```
    assert domain.get_full_qualified_name(node) == 'Class.func'

    # with both py:module and py:class context
    kwargs = {'py:module': 'module1', 'py:class': 'Class'}
    node = nodes.reference(reftarget='func', **kwargs)
    assert domain.get_full_qualified_name(node) == 'module1.Class.func'


def test_parse_annotation(app):
    doctree = _parse_annotation("int", app.env)
    assert_node(doctree, ([pending_xref, "int"],))
    assert_node(doctree[0], pending_xref, refdomain="py", reftype="class", reftarget="int")

    doctree = _parse_annotation("List[int]", app.env)
    assert_node(doctree, ([pending_xref, "List"],
                          [desc_sig_punctuation, "["],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, "]"]))

    doctree = _parse_annotation("Tuple[int, int]", app.env)
    assert_node(doctree, ([pending_xref, "Tuple"],
                          [desc_sig_punctuation, "["],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, ", "],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, "]"]))

    doctree = _parse_annotation("Tuple[()]", app.env)
    assert_node(doctree, ([pending_xref, "Tuple"],
                          [desc_sig_punctuation, "["],
                          [desc_sig_punctuation, "("],
                          [desc_sig_punctuation, ")"],
                          [desc_sig_punctuation, "]"]))

    doctree = _parse_annotation("Tuple[int, ...]", app.env)
    assert_node(doctree, ([pending_xref, "Tuple"],
                          [desc_sig_punctuation, "["],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, ", "],
                          [desc_sig_punctuation, "..."],
                          [desc_sig_punctuation, "]"]))

    doctree = _parse_annotation("Callable[[int, int], int]", app.env)
    assert_node(doctree, ([pending_xref, "Callable"],
                          [desc_sig_punctuation, "["],
                          [desc_sig_punctuation, "["],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, ", "],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, "]"],
                          [desc_sig_punctuation, ", "],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, "]"]))

    doctree = _parse_annotation("Callable[[], int]", app.env)
    assert_node(doctree, ([pending_xref, "Callable"],
                          [desc_sig_punctuation, "["],
                          [desc_sig_punctuation, "["],
                          [desc_sig_punctuation, "]"],
                          [desc_sig_punctuation, ", "],
                          [pending_xref, "int"],
                          [desc_sig_punctuation, "]"]))

    doctree = _parse_annotation("List[None]", app.env)
    assert_node(doctree, ([pending_xref, "List"],
                          [desc_sig_punctuation, "["],
                          [pending_xref, "None"],
                          [desc_sig_punctuation, "]"]))

    # None type makes an object-reference (not a class reference)
    doctree = _parse_annotation("None", app.env)
    assert_node(doctree, ([pending_xref, "None"],))
    assert_node(doctree[0], pending_xref, refdomain="py", reftype="obj", reftarget="None")


def test_pyfunction_signature(app):
    text = ".. py:function:: hello(name: str) -> str"
    doctree = restructuredtext.parse(app, text)
    assert_node(doctree, (addnodes.index,
                          [desc, ([desc_signature, ([desc_name, "hello"],
                                                    desc_parameterlist,
"""
    test_domain_py
    ~~~~~~~~~~~~~~

    Tests the Python Domain

    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
import sys
from unittest.mock import Mock

import pytest
from docutils import nodes

from sphinx import addnodes
from sphinx.addnodes import (desc, desc_addname, desc_annotation, desc_content, desc_name,
                             desc_optional, desc_parameter, desc_parameterlist, desc_returns,
                             desc_sig_name, desc_sig_operator, desc_sig_punctuation,
                             desc_signature, pending_xref)
from sphinx.domains import IndexEntry
from sphinx.domains.python import (PythonDomain, PythonModuleIndex, _parse_annotation,
                                   _pseudo_parse_arglist, py_sig_re)
from sphinx.testing import restructuredtext
from sphinx.testing.util import assert_node


def parse(sig):
    m = py_sig_re.match(sig)
    if m is None:
        raise ValueError
    name_prefix, name, arglist, retann = m.groups()
    signode = addnodes.desc_signature(sig, '')
    _pseudo_parse_arglist(signode, arglist)
    return signode.astext()


def test_function_signatures():
    rv = parse('func(a=1) -> int object')
    assert rv == '(a=1)'

    rv = parse('func(a=1, [b=None])')
    assert rv == '(a=1, [b=None])'

    rv = parse('func(a=1[, b=None])')
    assert rv == '(a=1, [b=None])'

    rv = parse("compile(source : string, filename, symbol='file')")
    assert rv == "(source : string, filename, symbol='file')"

    rv = parse('func(a=[], [b=None])')
    assert rv == '(a=[], [b=None])'

    rv = parse('func(a=[][, b=None])')
    assert rv == '(a=[], [b=None])'


@pytest.mark.sphinx('dummy', testroot='domain-py')
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Literal\\|nitpick\" CHANGES | head -40; git log --all --oneline | head -20"
}
```

**tool result**

```
139:* #9195: autodoc: The arguments of ``typing.Literal`` are wrongly rendered
169:* #9131: Add :confval:`nitpick_ignore_regex` to ignore nitpicky warnings using
1326:* #7428: py domain: a reference to class ``None`` emits a nitpicky warning
1433:* #6895: py domain: Do not emit nitpicky warnings for built-in types
1946:* ``sphinx.directives.LiteralInclude``
2202:* ``sphinx.domains.cpp.UnsupportedMultiCharacterCharLiteral.decoded``
2637:* ``env._nitpick_ignore`` is deprecated
2754:* #5122: setuptools: support nitpicky option
5303:* #1673: Fix crashes with :confval:`nitpick_ignore` and ``:doc:`` references.
5448:* #1345: Fix two bugs with `nitpick_ignore`; now you don't have to
6013:  - #537: Added `nitpick_ignore`.
6144:  targets in nitpicky mode.
6369:  - Added a "nitpicky" mode that emits warnings for all missing
6371:    switch or the :confval:`nitpicky` config value.
0a08816d9 SWE-bench
6c38f68da Merge pull request #9582 from blueyed/tox-passenv-COLORTERM
80fbbb846 Merge pull request #9591 from tk0miya/9585_type_for_pyproperty
3e2419056 Fix #9585: py:property directive does not create a hyperlink for types
e89de152d ci(tox.ini): add COLORTERM to passenv
9ed054279 Merge pull request #9549 from tk0miya/9524_SphinxTestApp_outdir
6fb8d1c80 Merge branch '4.x' into 9524_SphinxTestApp_outdir
a4a0b9783 Merge pull request #9569 from jakelishman/fix-autosummary-sections
baacc26b2 Merge pull request #9565 from JustinTArthur/9564-fix_highlighted_code_role_smartquotes
760820f5e Merge branch '4.x' into fix-autosummary-sections
276f94361 Merge branch '4.x' into 9564-fix_highlighted_code_role_smartquotes
5c3eebccd Merge pull request #9587 from sphinx-doc/bot/pull-translations
a0fbe2f7b Merge branch '4.1.x' into 4.x
a1bb4a81c Fix #9589: autodoc: typing.Annotated has wrongly been rendered
e33134f6b Merge pull request #9590 from tk0miya/9589_Annotated
b82d3ef05 Fix #9589: autodoc: typing.Annotated has wrongly been rendered
d6a340fc1 Update message catalogs
f127a2ff5 Merge pull request #9570 from sphinx-doc/bot/pull-translations
f62a33a8b Update message catalogs
95648432c Merge branch '4.1.x' into 4.x
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"desc_sig\" sphinx/addnodes.py | head -40; grep -R \"desc_sig_literal\\|literal_number\\|literal_string\" -n sphinx tests | head -40"
}
```

**tool result**

```
141:    Contains one or more :py:class:`desc_signature` nodes
154:class desc_signature(_desc_classes_injector, nodes.Part, nodes.Inline, nodes.TextElement):
159:    In that case all child nodes must be :py:class:`desc_signature_line` nodes.
174:class desc_signature_line(nodes.Part, nodes.Inline, nodes.FixedTextElement):
177:    It should only be used as a child of a :py:class:`desc_signature`
209:# nodes to use within a desc_signature or desc_signature_line
280:class desc_sig_element(nodes.inline, _desc_classes_injector):
290:# to not reinvent the wheel, the classes in the following desc_sig classes
293:class desc_sig_space(desc_sig_element):
302:class desc_sig_name(desc_sig_element):
307:class desc_sig_operator(desc_sig_element):
312:class desc_sig_punctuation(desc_sig_element):
317:class desc_sig_keyword(desc_sig_element):
322:class desc_sig_keyword_type(desc_sig_element):
327:class desc_sig_literal_number(desc_sig_element):
332:class desc_sig_literal_string(desc_sig_element):
337:class desc_sig_literal_char(desc_sig_element):
342:SIG_ELEMENTS = [desc_sig_space,
343:                desc_sig_name,
344:                desc_sig_operator,
345:                desc_sig_punctuation,
346:                desc_sig_keyword, desc_sig_keyword_type,
347:                desc_sig_literal_number, desc_sig_literal_string, desc_sig_literal_char]
534:    app.add_node(desc_signature)
535:    app.add_node(desc_signature_line)
sphinx/addnodes.py:327:class desc_sig_literal_number(desc_sig_element):
sphinx/addnodes.py:332:class desc_sig_literal_string(desc_sig_element):
sphinx/addnodes.py:337:class desc_sig_literal_char(desc_sig_element):
sphinx/addnodes.py:347:                desc_sig_literal_number, desc_sig_literal_string, desc_sig_literal_char]
sphinx/domains/c.py:309:        signode += addnodes.desc_sig_literal_number(txt, txt)
sphinx/domains/c.py:331:        signode += addnodes.desc_sig_literal_char(txt, txt)
sphinx/domains/c.py:344:        signode += addnodes.desc_sig_literal_string(txt, txt)
sphinx/domains/cpp.py:913:        signode += addnodes.desc_sig_literal_number(self.data, self.data)
sphinx/domains/cpp.py:929:        signode += addnodes.desc_sig_literal_string(self.data, self.data)
sphinx/domains/cpp.py:959:        signode += addnodes.desc_sig_literal_char(txt, txt)
sphinx/domains/cpp.py:1746:        signode += addnodes.desc_sig_literal_string('""', '""')
sphinx/domains/cpp.py:2159:                signode += addnodes.desc_sig_literal_number('0', '0')
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'PY'\nimport sphinx, inspect\nprint(sphinx.__version__, sphinx.__file__)\nPY\npip show sphinx 2>/dev/null | head"
}
```

**tool result**

```
4.2.0 /testbed/sphinx/__init__.py
Name: Sphinx
Version: 4.2.0.dev20260813
Summary: Python documentation generator
Home-page: https://sphinx-doc.org/
Author: Georg Brandl
Author-email: georg@python.org
License: BSD
Location: /testbed
Editable project location: /testbed
Requires: alabaster, babel, docutils, imagesize, Jinja2, markupsafe, packaging, Pygments, requests, setuptools, snowballstemmer, sphinxcontrib-applehelp, sphinxcontrib-devhelp, sphinxcontrib-htmlhelp, sphinxcontrib-jsmath, sphinxcontrib-qthelp, sphinxcontrib-serializinghtml
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '280,350p' sphinx/addnodes.py; sed -n '120,150p' CHANGES"
}
```

**tool result**

```
class desc_sig_element(nodes.inline, _desc_classes_injector):
    """Common parent class of nodes for inline text of a signature."""
    classes: List[str] = []

    def __init__(self, rawsource: str = '', text: str = '',
                 *children: Element, **attributes: Any) -> None:
        super().__init__(rawsource, text, *children, **attributes)
        self['classes'].extend(self.classes)


# to not reinvent the wheel, the classes in the following desc_sig classes
# are based on those used in Pygments

class desc_sig_space(desc_sig_element):
    """Node for a space in a signature."""
    classes = ["w"]

    def __init__(self, rawsource: str = '', text: str = ' ',
                 *children: Element, **attributes: Any) -> None:
        super().__init__(rawsource, text, *children, **attributes)


class desc_sig_name(desc_sig_element):
    """Node for an identifier in a signature."""
    classes = ["n"]


class desc_sig_operator(desc_sig_element):
    """Node for an operator in a signature."""
    classes = ["o"]


class desc_sig_punctuation(desc_sig_element):
    """Node for punctuation in a signature."""
    classes = ["p"]


class desc_sig_keyword(desc_sig_element):
    """Node for a general keyword in a signature."""
    classes = ["k"]


class desc_sig_keyword_type(desc_sig_element):
    """Node for a keyword which is a built-in type in a signature."""
    classes = ["kt"]


class desc_sig_literal_number(desc_sig_element):
    """Node for a numeric literal in a signature."""
    classes = ["m"]


class desc_sig_literal_string(desc_sig_element):
    """Node for a string literal in a signature."""
    classes = ["s"]


class desc_sig_literal_char(desc_sig_element):
    """Node for a character literal in a signature."""
    classes = ["sc"]


SIG_ELEMENTS = [desc_sig_space,
                desc_sig_name,
                desc_sig_operator,
                desc_sig_punctuation,
                desc_sig_keyword, desc_sig_keyword_type,
                desc_sig_literal_number, desc_sig_literal_string, desc_sig_literal_char]


###############################################################
Deprecated
----------

* The ``app`` argument of ``sphinx.environment.BuildEnvironment`` becomes
  required
* ``sphinx.application.Sphinx.html_theme``
* ``sphinx.ext.autosummary._app``
* ``sphinx.util.docstrings.extract_metadata()``

Features added
--------------

* #8107: autodoc: Add ``class-doc-from`` option to :rst:dir:`autoclass`
  directive to control the content of the specific class like
  :confval:`autoclass_content`
* #8588: autodoc: :confval:`autodoc_type_aliases` now supports dotted name. It
  allows you to define an alias for a class with module name like
  ``foo.bar.BazClass``
* #9175: autodoc: Special member is not documented in the module
* #9195: autodoc: The arguments of ``typing.Literal`` are wrongly rendered
* #9185: autodoc: :confval:`autodoc_typehints` allows ``'both'`` setting to
  allow typehints to be included both in the signature and description
* #4257: autodoc: Add :confval:`autodoc_class_signature` to separate the class
  entry and the definition of ``__init__()`` method
* #8061, #9218: autodoc: Support variable comment for alias classes
* #3014: autodoc: Add :event:`autodoc-process-bases` to modify the base classes
  of the class definitions
* #9272: autodoc: Render enum values for the default argument value better
* #9384: autodoc: ``autodoc_typehints='none'`` now erases typehints for
  variables, attributes and properties
* #3257: autosummary: Support instance attributes for classes
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sphinx/domains/python.py\n@@\n         elif isinstance(node, ast.Constant):  # type: ignore\n             if node.value is Ellipsis:\n                 return [addnodes.desc_sig_punctuation('', \"...\")]\n+            elif isinstance(node.value, bool):\n+                return [addnodes.desc_sig_keyword('', repr(node.value))]\n+            elif isinstance(node.value, int):\n+                return [addnodes.desc_sig_literal_number('', repr(node.value))]\n+            elif isinstance(node.value, str):\n+                return [addnodes.desc_sig_literal_string('', repr(node.value))]\n             else:\n-                return [nodes.Text(node.value)]\n+                # handles None, which is further handled by type_to_xref later\n+                # and fallback for other types that should be converted\n+                return [nodes.Text(repr(node.value))]\n@@\n         elif isinstance(node, ast.Tuple):\n             if node.elts:\n                 result = []\n                 for elem in node.elts:\n                     result.extend(unparse(elem))\n@@\n \n             return result\n+        elif isinstance(node, ast.UnaryOp):\n+            if isinstance(node.op, ast.USub):\n+                return [addnodes.desc_sig_operator('', '-')] + unparse(node.operand)\n+            else:\n+                raise SyntaxError\n         else:\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sphinx/domains/python.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sphinx/domains/python.py now (1429 lines), around the change:
122:        elif isinstance(node, ast.Constant):  # type: ignore
123:            if node.value is Ellipsis:
124:                return [addnodes.desc_sig_punctuation('', "...")]
125:            elif isinstance(node.value, bool):
126:                return [addnodes.desc_sig_keyword('', repr(node.value))]
127:            elif isinstance(node.value, int):
128:                return [addnodes.desc_sig_literal_number('', repr(node.value))]
129:            elif isinstance(node.value, str):
130:                return [addnodes.desc_sig_literal_string('', repr(node.value))]
131:            else:
132:                # handles None, which is further handled by type_to_xref later
133:                # and fallback for other types that should be converted
134:                return [nodes.Text(repr(node.value))]
135:        elif isinstance(node, ast.Expr):
136:            return unparse(node.value)
137:        elif isinstance(node, ast.Index):
…
170:                          addnodes.desc_sig_punctuation('', ')')]
171:
172:            return result
173:            else:
174:            if sys.version_info < (3, 8):
175:                if isinstance(node, ast.Ellipsis):
176:                    return [addnodes.desc_sig_punctuation('', "...")]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '150,195p' sphinx/domains/python.py"
}
```

**tool result**

```
            return result
        elif isinstance(node, ast.Module):
            return sum((unparse(e) for e in node.body), [])
        elif isinstance(node, ast.Name):
            return [nodes.Text(node.id)]
        elif isinstance(node, ast.Subscript):
            result = unparse(node.value)
            result.append(addnodes.desc_sig_punctuation('', '['))
            result.extend(unparse(node.slice))
            result.append(addnodes.desc_sig_punctuation('', ']'))
            return result
        elif isinstance(node, ast.Tuple):
            if node.elts:
                result = []
                for elem in node.elts:
                    result.extend(unparse(elem))
                    result.append(addnodes.desc_sig_punctuation('', ', '))
                result.pop()
            else:
                result = [addnodes.desc_sig_punctuation('', '('),
                          addnodes.desc_sig_punctuation('', ')')]

            return result
            else:
            if sys.version_info < (3, 8):
                if isinstance(node, ast.Ellipsis):
                    return [addnodes.desc_sig_punctuation('', "...")]
                elif isinstance(node, ast.NameConstant):
                    return [nodes.Text(node.value)]

            raise SyntaxError  # unsupported syntax

    if env is None:
        warnings.warn("The env parameter for _parse_annotation becomes required now.",
                      RemovedInSphinx50Warning, stacklevel=2)

    try:
        tree = ast_parse(annotation)
        result = unparse(tree)
        for i, node in enumerate(result):
            if isinstance(node, nodes.Text) and node.strip():
                result[i] = type_to_xref(str(node), env)
        return result
    except SyntaxError:
        return [type_to_xref(annotation, env)]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sphinx/domains/python.py\n@@\n             else:\n                 result = [addnodes.desc_sig_punctuation('', '('),\n                           addnodes.desc_sig_punctuation('', ')')]\n \n             return result\n-            else:\n+        elif isinstance(node, ast.UnaryOp):\n+            if isinstance(node.op, ast.USub):\n+                return [addnodes.desc_sig_operator('', '-')] + unparse(node.operand)\n+            else:\n+                raise SyntaxError\n+        else:\n             if sys.version_info < (3, 8):\n                 if isinstance(node, ast.Ellipsis):\n                     return [addnodes.desc_sig_punctuation('', \"...\")]\n                 elif isinstance(node, ast.NameConstant):\n                     return [nodes.Text(node.value)]\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sphinx/domains/python.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sphinx/domains/python.py now (1434 lines), around the change:
170:                          addnodes.desc_sig_punctuation('', ')')]
171:
172:            return result
173:        elif isinstance(node, ast.UnaryOp):
174:            if isinstance(node.op, ast.USub):
175:                return [addnodes.desc_sig_operator('', '-')] + unparse(node.operand)
176:            else:
177:                raise SyntaxError
178:        else:
179:            if sys.version_info < (3, 8):
180:                if isinstance(node, ast.Ellipsis):
181:                    return [addnodes.desc_sig_punctuation('', "...")]
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_domain_py.py::test_parse_annotation -q 2>&1 | tail -20"
}
```

**tool result**

```
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/highlighting.py:67
  /testbed/sphinx/highlighting.py:67: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if tuple(LooseVersion(pygmentsversion).version) <= (2, 7, 4):

sphinx/registry.py:24
  /testbed/sphinx/registry.py:24: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
1 passed, 7 warnings in 0.82s
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'PY'\nfrom sphinx.domains.python import _parse_annotation\nfrom sphinx.testing.util import SphinxTestApp\nfrom sphinx.testing.path import path\nimport tempfile, os\n# simpler: use app fixture not available; just inspect unparse via ast\nimport ast\nfrom sphinx.domains.python import _parse_annotation\n# env None warns but works? env.config access in type_to_xref only if env\nfor a in ['Literal[True]', 'Literal[False]', 'Literal[1, \"2\", -3]', 'Literal[None]', 'int']:\n    try:\n        r=_parse_annotation(a)\n        print(a, [type(n).__name__+':'+n.astext() for n in r])\n    except Exception as e:\n        print(a, 'ERR', e)\nPY"
}
```

**tool result**

```
<stdin>:11: RemovedInSphinx50Warning: The env parameter for _parse_annotation becomes required now.
Literal[True] ERR 'NoneType' object has no attribute 'config'
Literal[False] ERR 'NoneType' object has no attribute 'config'
Literal[1, "2", -3] ERR 'NoneType' object has no attribute 'config'
Literal[None] ERR 'NoneType' object has no attribute 'config'
int ERR 'NoneType' object has no attribute 'config'
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Bugs fixed\" CHANGES | head -3; sed -n '1,120p' CHANGES"
}
```

**tool result**

```
25:Bugs fixed
66:Bugs fixed
87:Bugs fixed
Release 4.2.0 (in development)
==============================

Dependencies
------------

Incompatible changes
--------------------

Deprecated
----------

Features added
--------------

* #9445: autodoc: Support class properties
* #9479: autodoc: Emit a warning if target is a mocked object
* #9447: html theme: Expose the version of Sphinx in the form of tuple as a
  template variable ``sphinx_version_tuple``
* #9445: py domain: ``:py:property:`` directive supports ``:classmethod:``
  option to describe the class property
* #9524: test: SphinxTestApp can take ``builddir`` as an argument
* #9535: C and C++, support more fundamental types, including GNU extensions.

Bugs fixed
----------

* #9487: autodoc: typehint for cached_property is not shown
* #9509: autodoc: AttributeError is raised on failed resolving typehints
* #9518: autodoc: autodoc_docstring_signature does not effect to ``__init__()``
  and ``__new__()``
* #9522: autodoc: PEP 585 style typehints having arguments (ex. ``list[int]``)
  are not displayed well
* #9481: autosummary: some warnings contain non-existing filenames
* #9568: autosummary: summarise overlined sectioned headings correctly
* #9481: c domain: some warnings contain non-existing filenames
* #9481: cpp domain: some warnings contain non-existing filenames
* #9456: html search: abbreation marks are inserted to the search result if
  failed to fetch the content of the page
* #9267: html theme: CSS and JS files added by theme were loaded twice
* #9585: py domain: ``:type:`` option for :rst:dir:`py:property` directive does
  not create a hyperlink
* #9535 comment: C++, fix parsing of defaulted function parameters that are
  function pointers.
* #9564: smartquotes: don't adjust typography for text with
  language-highlighted ``:code:`` role.

Testing
--------

Release 4.1.3 (in development)
==============================

Dependencies
------------

Incompatible changes
--------------------

Deprecated
----------

Features added
--------------

Bugs fixed
----------

* #9504: autodoc: generate incorrect reference to the parent class if the target
  class inherites the class having ``_name`` attribute
* #9537, #9589: autodoc: Some objects under ``typing`` module are not displayed
  well with the HEAD of 3.10
* #9512: sphinx-build: crashed with the HEAD of Python 3.10

Testing
--------

Release 4.1.2 (released Jul 27, 2021)
=====================================

Incompatible changes
--------------------

* #9435: linkcheck: Disable checking automatically generated anchors on
  github.com (ex. anchors in reST/Markdown documents)

Bugs fixed
----------

* #9489: autodoc: Custom types using ``typing.NewType`` are not displayed well
  with the HEAD of 3.10
* #9490: autodoc: Some objects under ``typing`` module are not displayed well
  with the HEAD of 3.10
* #9436, #9471: autodoc: crashed if ``autodoc_class_signature = "separated"``
* #9456: html search: html_copy_source can't control the search summaries
* #9435: linkcheck: Failed to check anchors in github.com

Release 4.1.1 (released Jul 15, 2021)
=====================================

Dependencies
------------

* #9434: sphinxcontrib-htmlhelp-2.0.0 or above
* #9434: sphinxcontrib-serializinghtml-1.1.5 or above

Bugs fixed
----------

* #9438: html: HTML logo or Favicon specified as file not being found on output

Release 4.1.0 (released Jul 12, 2021)
=====================================

Dependencies
------------

* Support jinja2-3.0

Deprecated
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/test_domain_py.py\n@@\n from sphinx.addnodes import (desc, desc_addname, desc_annotation, desc_content, desc_name,\n                              desc_optional, desc_parameter, desc_parameterlist, desc_returns,\n-                             desc_sig_name, desc_sig_operator, desc_sig_punctuation,\n-                             desc_signature, pending_xref)\n+                             desc_sig_keyword, desc_sig_literal_number,\n+                             desc_sig_literal_string, desc_sig_name, desc_sig_operator,\n+                             desc_sig_punctuation, desc_signature, pending_xref)\n@@\n     # None type makes an object-reference (not a class reference)\n     doctree = _parse_annotation(\"None\", app.env)\n     assert_node(doctree, ([pending_xref, \"None\"],))\n     assert_node(doctree[0], pending_xref, refdomain=\"py\", reftype=\"obj\", reftarget=\"None\")\n \n+    # Literal types\n+    doctree = _parse_annotation(\"Literal[True, False]\", app.env)\n+    assert_node(doctree, ([pending_xref, \"Literal\"],\n+                          [desc_sig_punctuation, \"[\"],\n+                          [desc_sig_keyword, \"True\"],\n+                          [desc_sig_punctuation, \", \"],\n+                          [desc_sig_keyword, \"False\"],\n+                          [desc_sig_punctuation, \"]\"]))\n+\n+    doctree = _parse_annotation(\"Literal[1, -2, 'foo']\", app.env)\n+    assert_node(doctree, ([pending_xref, \"Literal\"],\n+                          [desc_sig_punctuation, \"[\"],\n+                          [desc_sig_literal_number, \"1\"],\n+                          [desc_sig_punctuation, \", \"],\n+                          [desc_sig_operator, \"-\"],\n+                          [desc_sig_literal_number, \"2\"],\n+                          [desc_sig_punctuation, \", \"],\n+                          [desc_sig_literal_string, \"'foo'\"],\n+                          [desc_sig_punctuation, \"]\"]))\n+\n \n def test_pyfunction_signature(app):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/test_domain_py.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/test_domain_py.py now (1219 lines), around the change:
18:from sphinx import addnodes
19:from sphinx.addnodes import (desc, desc_addname, desc_annotation, desc_content, desc_name,
20:                             desc_optional, desc_parameter, desc_parameterlist, desc_returns,
21:                             desc_sig_keyword, desc_sig_literal_number,
22:                             desc_sig_literal_string, desc_sig_name, desc_sig_operator,
23:                             desc_sig_punctuation, desc_signature, pending_xref)
24:from sphinx.domains import IndexEntry
25:from sphinx.domains.python import (PythonDomain, PythonModuleIndex, _parse_annotation,
26:                                   _pseudo_parse_arglist, py_sig_re)
…
341:    doctree = _parse_annotation("None", app.env)
342:    assert_node(doctree, ([pending_xref, "None"],))
343:    assert_node(doctree[0], pending_xref, refdomain="py", reftype="obj", reftarget="None")
344:
345:    # Literal types
346:    doctree = _parse_annotation("Literal[True, False]", app.env)
347:    assert_node(doctree, ([pending_xref, "Literal"],
348:                          [desc_sig_punctuation, "["],
349:                          [desc_sig_keyword, "True"],
350:                          [desc_sig_punctuation, ", "],
351:                          [desc_sig_keyword, "False"],
352:                          [desc_sig_punctuation, "]"]))
353:
354:    doctree = _parse_annotation("Literal[1, -2, 'foo']", app.env)
355:    assert_node(doctree, ([pending_xref, "Literal"],
356:                          [desc_sig_punctuation, "["],
357:                          [desc_sig_literal_number, "1"],
358:                          [desc_sig_punctuation, ", "],
359:                          [desc_sig_operator, "-"],
360:                          [desc_sig_literal_number, "2"],
361:                          [desc_sig_punctuation, ", "],
362:                          [desc_sig_literal_string, "'foo'"],
363:                          [desc_sig_punctuation, "]"]))
364:
365:
366:def test_pyfunction_signature(app):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_domain_py.py::test_parse_annotation -q 2>&1 | tail -30"
}
```

**tool result**

```
.                                                                        [100%]
=============================== warnings summary ===============================
sphinx/util/docutils.py:44
  /testbed/sphinx/util/docutils.py:44: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/highlighting.py:67
  /testbed/sphinx/highlighting.py:67: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if tuple(LooseVersion(pygmentsversion).version) <= (2, 7, 4):

sphinx/registry.py:24
  /testbed/sphinx/registry.py:24: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
1 passed, 7 warnings in 0.65s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_domain_py.py -q 2>&1 | tail -8"
}
```

**tool result**

```
tests/test_domain_py.py::test_resolve_xref_for_properties
tests/test_domain_py.py::test_domain_py_canonical
tests/test_domain_py.py::test_python_python_use_unqualified_type_names
tests/test_domain_py.py::test_python_python_use_unqualified_type_names_disabled
  <template>:401: DeprecationWarning: 'soft_unicode' has been renamed to 'soft_str'. The old name will be removed in MarkupSafe 2.1.

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
45 passed, 192 warnings in 5.14s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: CHANGES\n@@\n * #9585: py domain: ``:type:`` option for :rst:dir:`py:property` directive does\n   not create a hyperlink\n+* #9586: py domain: Literal typehint was converted to a cross reference\n * #9535 comment: C++, fix parsing of defaulted function parameters that are\n   function pointers.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[CHANGES] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

CHANGES now (6506 lines), around the change:
40:* #9267: html theme: CSS and JS files added by theme were loaded twice
41:* #9585: py domain: ``:type:`` option for :rst:dir:`py:property` directive does
42:  not create a hyperlink
43:* #9586: py domain: Literal typehint was converted to a cross reference
44:* #9535 comment: C++, fix parsing of defaulted function parameters that are
45:  function pointers.
46:* #9564: smartquotes: don't adjust typography for text with
```

**assistant → tool `bash`**

```json
{
  "command": "tmp=$(mktemp -d); mkdir -p $tmp/src; cat > $tmp/src/conf.py <<'EOF'\nimport os, sys\nsys.path.insert(0, os.path.abspath('.'))\nextensions = ['sphinx.ext.autodoc']\nnitpicky = True\nEOF\ncat > $tmp/src/mod.py <<'EOF'\nimport typing\n@typing.overload\ndef foo(x: \"typing.Literal[True]\") -> int: ...\n@typing.overload\ndef foo(x: \"typing.Literal[False]\") -> str: ...\ndef foo(x: bool):\n    \"\"\"a func\"\"\"\n    return 1 if x else \"foo\"\nEOF\ncat > $tmp/src/index.rst <<'EOF'\nTest\n====\n\n.. automodule:: mod\n   :members:\nEOF\npython -m sphinx -n -W -b html $tmp/src $tmp/out 2>&1 | tail -20; echo EXIT:${PIPESTATUS[0]}"
}
```

**tool result**

```
building [mo]: targets for 0 po files that are out of date
building [html]: targets for 1 source files that are out of date
updating environment: [new config] 1 added, 0 changed, 0 removed
reading sources... [100%] index

looking for now-outdated files... none found
pickling environment... done
checking consistency... done
preparing documents... done
writing output... [100%] index

generating indices... genindex py-modindex done
writing additional pages... search done
copying static files... done
copying extra files... done
dumping search index in English (code: en)... done
dumping object inventory... done
build succeeded.

The HTML pages are in ../tmp/tmp.2AZxwEgGPT/out.
EXIT:0
```

**assistant → tool `bash`**

```json
{
  "command": "git diff --check && git status --porcelain -- . ':(exclude).memdoor' && python -m pytest tests/test_domain_py.py tests/test_util_typing.py -q 2>&1 | tail -3"
}
```

**tool result**

```
 M CHANGES
 M sphinx/domains/python.py
 M tests/test_domain_py.py

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
68 passed, 2 skipped, 192 warnings in 4.72s
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
Fixed. Literal annotation values are now rendered as literal signature nodes instead of cross-reference targets, so nitpicky mode no longer warns about `True`, `False`, numbers, or strings.

Changes:
- `sphinx/domains/python.py`: `_parse_annotation` now handles booleans, ints, strings, and negative numbers as `desc_sig_keyword` / `desc_sig_literal_number` / `desc_sig_literal_string` / `desc_sig_operator` nodes rather than `pending_xref` nodes.
- `tests/test_domain_py.py`: added coverage for `Literal[True, False]` and `Literal[1, -2, 'foo']`.
- `CHANGES`: added a bug-fix entry.

Verified with the reproduction project using `sphinx-build -n -W` (exit 0), and the Python domain/typing test suites pass (68 passed, 2 skipped).
```

## Run folder `single-2026-11-06T120957`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
Nitpick flags Literal annotation values as missing py:class
### Describe the bug

When a value is present in a type annotation as `Literal`, sphinx will treat the value as a `py:class`. With nitpick enabled, values like `Literal[True]` end up failing, because `True` is not a class.

This is a problem for builds which want to use `-n -W` to catch doc errors.

### How to Reproduce

Setup a simple function which uses Literal, then attempt to autodoc it. e.g.
```python
import typing
@typing.overload
def foo(x: "typing.Literal[True]") -> int: ...
@typing.overload
def foo(x: "typing.Literal[False]") -> str: ...
def foo(x: bool):
    """a func"""
    return 1 if x else "foo"
```

I've pushed an example [failing project](https://github.com/sirosen/repro/tree/master/sphinxdoc/literal) to [my repro repo](https://github.com/sirosen/repro). Just run `./doc.sh` with `sphinx-build` available to see the failing build.

### Expected behavior

`Literal[True]` (or whatever literal value) should be present in the type annotation but should not trigger the nitpick warning.

### Your project

https://github.com/sirosen/repro/tree/master/sphinxdoc/literal

### Screenshots

_No response_

### OS

Linux

### Python version

3.8, 3.9

### Sphinx version

4.1.2

### Sphinx extensions

autodoc

### Extra tools

_No response_

### Additional context

_No response_
````
