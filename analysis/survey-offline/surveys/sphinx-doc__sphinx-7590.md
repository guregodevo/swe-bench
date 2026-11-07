# Survey: C++ user-defined literals are not parsed

The issue reports that `cpp:var`/`cpp:member` (and any C++ expression) rejects a
user-defined literal such as `6.62607015e-34q_J` with "Expected end of
definition". The root cause is that the literal parser consumes the numeric
part but not the UDL suffix, so the expression parser returns successfully with
the suffix left over and the final end-of-definition check fails.

## Public APIs named or shown by the issue

- `sphinx/domains/cpp.py:CPPDomain.directives` — registers `cpp:var` and `cpp:member` (both `CPPMemberObject`), the directive used in the issue's example.
- `sphinx/domains/cpp.py:CPPObject.parse_definition` — dispatches a `cpp:var`/`cpp:member` signature to `DefinitionParser.parse_declaration`.
- `sphinx/domains/cpp.py:CPPObject.handle_signature` — parses the signature and calls `parser.assert_end()`, which emits the "Expected end of definition" warning shown in the issue.
- `sphinx/domains/cpp.py:DefinitionParser.parse_declaration` — for `objectType == 'member'` calls `_parse_type_with_init`, the entry point for the issue's declaration.
- `sphinx/domains/cpp.py:DefinitionParser._parse_type_with_init` — parses the type and then the `= ...` initializer of the variable.
- `sphinx/domains/cpp.py:DefinitionParser._parse_initializer` — parses `= assignment-expression` for a member/var and returns an initializer that stops before the UDL suffix.
- `sphinx/domains/cpp.py:DefinitionParser._parse_expression_fallback` — only falls back when the expression parser raises; here the parser succeeds early, so the leftover `q_J` is never consumed.
- `sphinx/domains/cpp.py:DefinitionParser._parse_expression` — parses the comma-expression and returns the number literal as a complete expression, leaving the suffix.
- `sphinx/domains/cpp.py:DefinitionParser._parse_assignment_expression` — accepts the bare number literal as a complete assignment-expression, so no error is raised at this level.
- `sphinx/domains/cpp.py:DefinitionParser._parse_logical_or_expression` — binary-operator chain that stops at `q_J` because it is not an operator.
- `sphinx/domains/cpp.py:DefinitionParser._parse_cast_expression` — passes through to the unary/postfix/primary chain for the literal.
- `sphinx/domains/cpp.py:DefinitionParser._parse_unary_expression` — passes through to the postfix expression for the literal.
- `sphinx/domains/cpp.py:DefinitionParser._parse_postfix_expression` — parses the primary expression and finds no postfix operators after the number.
- `sphinx/domains/cpp.py:DefinitionParser._parse_primary_expression` — calls `_parse_literal` and returns its result as a complete primary expression.
- `sphinx/domains/cpp.py:DefinitionParser._parse_literal` — the actual defect: matches the numeric literal, consumes only `uUlLfF` suffixes, and has a `# TODO: user-defined lit` instead of consuming the UDL suffix.
- `sphinx/domains/cpp.py:DefinitionParser._parse_string` — string-literal scanner that likewise stops at the closing quote and never consumes a UDL suffix.
- `sphinx/domains/cpp.py:CPPExprRole.run` — the `cpp:expr`/`cpp:texpr` role parses expressions through the same `parse_expression` path, so `:cpp:expr:`6.6q_J`` fails the same way.
- `sphinx/domains/cpp.py:DefinitionParser.parse_expression` — public expression entry point used by `CPPExprRole`; it calls `_parse_expression` and then `assert_end`, hitting the same leftover suffix.

## Other places that parse literals the same way

- `sphinx/domains/cpp.py:DefinitionParser._parse_initializer_clause` — used for braced/paren initializer lists; delegates to `_parse_assignment_expression` and inherits the same literal limitation.
- `sphinx/domains/cpp.py:DefinitionParser._parse_braced_init_list` — parses `{...}` initializers whose elements go through the same literal parser.
- `sphinx/domains/cpp.py:DefinitionParser._parse_expression_list_or_braced_init_list` — call/initializer argument lists that reuse the same expression parser.
- `sphinx/domains/cpp.py:DefinitionParser._parse_constant_expression` — used for enumerators, template arguments, array bounds and `noexcept`; same literal path, so UDLs fail there too.
- `sphinx/domains/cpp.py:DefinitionParser._parse_template_argument_list` — non-type template arguments are parsed as constant expressions and cannot contain a UDL.
- `sphinx/domains/cpp.py:DefinitionParser._parse_enumerator` — `enumerator = constant-expression` uses the same literal parser.
- `sphinx/domains/cpp.py:DefinitionParser._parse_declarator_name_suffix` — array bounds are parsed as expressions and inherit the same limitation.
- `sphinx/domains/cpp.py:DefinitionParser._parse_trailing_type_spec` — `decltype(<expr>)` parses an expression through the same literal path.
- `sphinx/domains/cpp.py:DefinitionParser._parse_parameters_and_qualifiers` — `noexcept(<expr>)` parses a constant expression through the same literal path.
- `sphinx/domains/cpp.py:DefinitionParser._parse_decl_specs_simple` — handles the `constexpr auto` part of the issue's declaration before the initializer is reached.
- `sphinx/domains/cpp.py:ASTNumberLiteral` — stores only the raw numeric text and has no suffix field, so even a parsed UDL could not be stringified or given an id correctly.
- `sphinx/domains/cpp.py:ASTStringLiteral` — same: stores only the quoted text, with no place for a UDL suffix.
- `sphinx/domains/cpp.py:ASTCharLiteral` — same: stores prefix/data only, with no UDL suffix.
- `sphinx/domains/cpp.py:ASTNumberLiteral.get_id` — builds the symbol id from the raw literal text, which would need to include the UDL suffix.
- `sphinx/domains/cpp.py:ASTDeclaration.get_id` — composes declaration ids from the AST, so a missing UDL suffix would also produce a wrong/ambiguous id.
- `sphinx/domains/cpp.py:DefinitionParser._parse_operator` — the one place that *does* understand UDL syntax (`operator""_udl`), but only for operator declarations, not for literal expressions; the sibling that shows the missing feature.
- `sphinx/domains/cpp.py:ASTOperatorLiteral` — AST node for a UDL *operator declaration*; there is no corresponding AST node for a UDL *literal expression*.
- `sphinx/util/cfamily.py:float_literal_re` — shared numeric regex that matches the value but has no UDL-suffix group.
- `sphinx/util/cfamily.py:integer_literal_re` — shared integer regex, likewise suffix-free.
- `sphinx/util/cfamily.py:hex_literal_re` — shared hex regex, likewise suffix-free.
- `sphinx/util/cfamily.py:octal_literal_re` — shared octal regex, likewise suffix-free.
- `sphinx/util/cfamily.py:binary_literal_re` — shared binary regex, likewise suffix-free.
- `sphinx/util/cfamily.py:char_literal_re` — shared character regex, likewise suffix-free.
- `sphinx/util/cfamily.py:BaseParser.assert_end` — produces the exact "Expected end of definition." message and caret position reported in the issue.
- `sphinx/util/cfamily.py:BaseParser.match` — tokenizer used by `_parse_literal`; it advances only over the matched literal text, leaving the suffix.

## Parallel C domain implementation (same structure, same gap)

- `sphinx/domains/c.py:CDomain.directives` — registers `c:var`/`c:member` (`CMemberObject`), the C analogue of the issue's directive.
- `sphinx/domains/c.py:CObject.handle_signature` — parses the signature and calls `assert_end`, producing the same warning for a trailing literal suffix.
- `sphinx/domains/c.py:DefinitionParser.parse_declaration` — dispatches `member` to `_parse_type_with_init`, mirroring the C++ path.
- `sphinx/domains/c.py:DefinitionParser._parse_type_with_init` — parses type plus initializer for C variables.
- `sphinx/domains/c.py:DefinitionParser._parse_initializer` — parses `= assignment-expression` and stops before any suffix.
- `sphinx/domains/c.py:DefinitionParser._parse_expression_fallback` — same fallback-only-on-exception behaviour, so a partial parse is not retried.
- `sphinx/domains/c.py:DefinitionParser._parse_expression` — returns the bare literal as a complete expression.
- `sphinx/domains/c.py:DefinitionParser._parse_assignment_expression` — accepts the literal and leaves the suffix.
- `sphinx/domains/c.py:DefinitionParser._parse_primary_expression` — calls `_parse_literal` and returns it as a complete primary expression.
- `sphinx/domains/c.py:DefinitionParser._parse_literal` — the C sibling of the defect: matches the literal and returns without any suffix handling.
- `sphinx/domains/c.py:DefinitionParser._parse_string` — C string scanner that stops at the closing quote.
- `sphinx/domains/c.py:DefinitionParser._parse_constant_expression` — same literal path for enumerators and array bounds.
- `sphinx/domains/c.py:DefinitionParser._parse_enumerator` — `enumerator = constant-expression` uses the same literal parser.
- `sphinx/domains/c.py:DefinitionParser._parse_declarator_name_suffix` — array bounds parsed as expressions, same limitation.
- `sphinx/domains/c.py:DefinitionParser.parse_expression` — public expression entry point used by `CExprRole`, same leftover-suffix failure.
- `sphinx/domains/c.py:CExprRole.run` — the `c:expr`/`c:texpr` role, the C analogue of `CPPExprRole`.
- `sphinx/domains/c.py:ASTNumberLiteral` — C literal AST node with no suffix field.
- `sphinx/domains/c.py:ASTStringLiteral` — C string AST node with no suffix field.
- `sphinx/domains/c.py:ASTCharLiteral` — C char AST node with no suffix field.
