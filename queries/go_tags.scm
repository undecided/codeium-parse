;; 0.
;; Use regex matching to work around a bug.
;; https://github.com/tree-sitter/tree-sitter/issues/1461 potentially.
(
  (comment)* @doc
  .
  (type_declaration
    (type_spec
      name: (type_identifier) @name
      type: (struct_type
        (field_declaration_list) @body))) @definition.class
  (#match? @definition.class "^type [^\\(]")
  (#select-adjacent! @doc @definition.class)
)
;; 1. Same as 0 but for interfaces.
(
  (comment)* @doc
  .
  (type_declaration
    (type_spec
      name: (type_identifier) @name
      type: (interface_type))) @definition.interface
  (#match? @definition.interface "^type [^\\(]")
  (#select-adjacent! @doc @definition.interface)
)

;; 2. Pattern 0 from tags.scm.
(
  (comment)* @doc
  .
  (function_declaration
    name: (identifier) @name
    parameters: (parameter_list) @codeium.parameters
    body: (_)? @body) @definition.function
  (#select-adjacent! @doc @definition.function)
)

;; 3. Pattern 1 from tags.scm.
(
  (comment)* @doc
  .
  (method_declaration
    receiver: (parameter_list
      (parameter_declaration
        type: (_) @_))
    name: (field_identifier) @name
    parameters: (parameter_list) @codeium.parameters
    body: (_)? @body) @definition.method
  (#select-adjacent! @doc @definition.method)
  (#set! codeium.lineage @_)
  (#set! codeium.lineage_type class)
)

;; 4. Pattern 2 from tags.scm.
(call_expression
  function: [
    (identifier) @name
    (selector_expression field: (field_identifier) @name)
  ]
  arguments: (argument_list) @codeium.parameters) @reference.call

;; 5.
(composite_literal
  type: (type_identifier) @name) @reference.class

;; 6. Pattern 3 from tags.scm.
;; Restricted to just type aliases.
(type_spec
  name: (type_identifier) @name
  type: (type_identifier)) @definition.type

(source_file
  (package_clause
    (package_identifier) @name) @definition.package) @codeium.lineage_node

(
  (comment)* @doc
  .
  (method_spec
    name: (field_identifier) @name
    parameters: (parameter_list) @codeium.parameters) @definition.method
)
