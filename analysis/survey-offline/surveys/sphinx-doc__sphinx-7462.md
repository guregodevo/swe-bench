# Survey: `IndexError: pop from empty list` for empty tuple annotation

The issue's traceback points at `sphinx/domains/python.py:unparse`; the root cause is that the `ast.Tuple` branch appends a `', '` separator after every element and then unconditionally calls `result.pop()`, so an empty tuple (`Tuple[()]`, whose slice is an `ast.Tuple` with no `elts`) pops from an empty list. The same "append separator then pop" pattern exists in the `ast.List` branch and in the sibling AST unparsers below.

## Paths named by the issue (traceback first)

- `sphinx/domains/python.py:unparse` — the nested AST-to-docutils-node converter inside `_parse_annotation`; its `ast.Tuple` branch (line 116) builds `result`, appends `', '` per element, then calls `result.pop()` (line 121), which raises `IndexError` when the tuple has no elements, exactly the reported traceback.
- `sphinx/domains/python.py:_parse_annotation` — parses a type-annotation string with `ast_parse` and calls `unparse(tree)`; this is the public entry point that turns `Tuple[()]` into nodes and therefore the function that surfaces the crash.
- `sphinx/domains/python.py:_parse_arglist` — calls `_parse_annotation(param.annotation)` for each parameter annotation (line 163), so an empty-tuple annotation on a parameter reaches the same `unparse` crash.
- `sphinx/domains/python.py:PyObject.handle_signature` — parses the directive signature, calls `_parse_arglist(arglist)` (line 410) and `_parse_annotation(retann)` for the return annotation (line 425), so `def foo() -> Tuple[()]` documented via `py:function`/autodoc hits the crash here.

## Siblings doing the same thing the same way

- `sphinx/domains/python.py:unparse` (`ast.List` branch, line 98) — identical "append `', '` after each element then `result.pop()`" logic (line 103), so an empty list annotation (`Callable[[], int]`-style empty parameter list) fails the same way.
- `sphinx/pycode/ast.py:unparse` (`ast.Tuple` branch, line 116) — the string-producing AST unparser joins elements with `", ".join(...)`, which is safe for empty tuples but is the parallel implementation used for the same annotation text elsewhere; its `ast.List` branch (line 100) is the analogous list formatter.
- `sphinx/pycode/ast.py:unparse_arguments` — companion unparser for `ast.arguments` that formats parameter/annotation text and is the sibling used when annotations are rendered from source rather than from docutils nodes.
- `sphinx/util/typing.py:stringify` — stringifies a runtime annotation object; dispatches to the py37/py36 implementations and is the other main path that renders `Tuple[()]` for autodoc.
- `sphinx/util/typing.py:_stringify_py37` — formats `__args__` with `', '.join(...)` guarded by `if getattr(annotation, '__args__', None):`, so an empty tuple's empty `__args__` is falsy and it falls through to just `Tuple` (a related but non-crashing rendering of the same empty-tuple case).
- `sphinx/util/typing.py:_stringify_py36` — the older parallel implementation of the same annotation stringification, with its own `TupleMeta`/`__args__` handling for the same empty-tuple input.
- `sphinx/util/inspect.py:stringify_signature` — builds a signature string and calls `stringify_annotation` on parameter and return annotations (lines 475, 495), the sibling formatter used by autodoc for the same `-> Tuple[()]` return annotation.
- `sphinx/util/inspect.py:Signature.format_args` — deprecated older interface that formats arguments/return annotation via `stringify_annotation` (lines 646-676), a parallel implementation of `stringify_signature`.
- `sphinx/util/inspect.py:Signature.format_annotation` / `format_annotation_new` / `format_annotation_old` — three parallel wrappers all delegating to `stringify_annotation`, the older/newer annotation-formatting interfaces for the same output.
- `sphinx/util/inspect.py:signature_from_str` — parses a signature string with `ast.parse` and `ast_unparse` for each annotation, the string-to-signature sibling of `_parse_arglist`.
- `sphinx/ext/autodoc/__init__.py:FunctionDocumenter.format_args` — calls `stringify_signature(sig, ...)` (line 1035) to render the function signature, the autodoc path that produces the `-> Tuple[()]` text for the issue's `foo`.
- `sphinx/ext/autodoc/__init__.py:ClassDocumenter.format_args` — calls `stringify_signature` for `__init__` (line 1194), the class-level parallel of the function path.
- `sphinx/ext/autodoc/__init__.py:MethodDocumenter.format_args` — calls `stringify_signature` (line 1450), the method-level parallel of the function path.
- `sphinx/ext/autodoc/__init__.py:DataDocumenter.add_directive_header` — calls `stringify_typehint` (line 1339) to render a data annotation, another consumer of the same stringifier.
- `sphinx/ext/autodoc/__init__.py:AttributeDocumenter.add_directive_header` — calls `stringify_typehint` (line 1591), the attribute-level parallel of the data path.
- `sphinx/ext/autodoc/type_comment.py:signature_from_ast` — builds a `Signature` from AST/type comments using `ast_unparse` for annotations, the type-comment sibling of the annotation-parsing paths.
- `sphinx/ext/autodoc/type_comment.py:update_annotations_using_type_comments` — rewrites `__annotations__` using `ast_unparse` (line 127), feeding the same annotation strings into the autodoc signature formatters.
- `sphinx/pycode/parser.py:add_variable_annotation` — stores `unparse(annotation)` (line 270) for variable annotations, the source-analyzer sibling that renders the same annotation text.
