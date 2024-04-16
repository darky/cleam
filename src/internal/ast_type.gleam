import glance.{
  type Module as AST, CustomType, Definition, Module as AST, Public, TypeAlias,
  Variant,
}
import gleam/list
import gleam/string
import internal/ast.{FileAst, ModuleName, PublicType}

pub fn public_type(file_ast) {
  let assert FileAst(ast) = file_ast
  let assert AST(_, types, type_aliases, ..) = ast
  {
    use pub_type <- list.flat_map(types)
    let assert Definition(_, CustomType(pub_type, is_public, _, _, sub_types)) =
      pub_type
    case is_public {
      Public -> {
        case list.length(sub_types) > 0 {
          True -> {
            use sub_type <- list.map(sub_types)
            let assert Variant(type_name, _) = sub_type
            PublicType(type_name)
          }
          False -> [PublicType(pub_type)]
        }
      }
      _ -> []
    }
  }
  |> list.append({
    use pub_type <- list.flat_map(type_aliases)
    let assert Definition(_, TypeAlias(pub_type, is_public, ..)) = pub_type
    case is_public {
      Public -> [PublicType(pub_type)]
      _ -> []
    }
  })
}

pub fn is_pub_type_used(files_ast, pub_type_name, module_full_name) {
  ast.is_pub_member_used(
    files_ast,
    pub_type_name,
    module_full_name,
    check_type_usage,
  )
}

fn check_type_usage(statements, pub_type_name, module_name) {
  let assert PublicType(pub_type_name) = pub_type_name
  let assert ModuleName(module_name) = module_name
  use statement <- list.find_map(statements)
  let serialized_statement =
    statement
    |> string.inspect
  case
    serialized_statement
    |> string.contains(
      "FieldAccess(Variable(\""
      <> module_name
      <> "\"), \""
      <> pub_type_name
      <> "\")",
    )
    || serialized_statement
    |> string.contains(
      "Some(NamedType(\""
      <> pub_type_name
      <> "\", Some(\""
      <> module_name
      <> "\")",
    )
  {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}
