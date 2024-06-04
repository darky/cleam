import glance.{
  type Module as AST, CustomType, Definition, Function, Module as AST, NamedType,
  Public, TypeAlias, Variant,
}
import gleam/list
import gleam/option.{Some}
import gleam/string
import internal/ast.{FileAst, ModuleName, PublicType}

pub fn public_type(file_ast) {
  let FileAst(ast) = file_ast
  let AST(_, types, type_aliases, _, fns) = ast
  {
    use pub_type <- list.flat_map(types)
    let Definition(_, CustomType(pub_type, is_public, _, _, sub_types)) =
      pub_type
    case is_public {
      Public -> {
        use sub_type <- list.filter_map(case list.length(sub_types) > 0 {
          True -> sub_types
          False -> [Variant(pub_type, [])]
        })
        let Variant(type_name, _) = sub_type
        pub_type_if_not_returned_in_pub_fun(type_name, fns)
      }
      _ -> []
    }
  }
  |> list.append({
    use pub_type <- list.filter_map(type_aliases)
    let Definition(_, TypeAlias(pub_type, is_public, ..)) = pub_type
    case is_public {
      Public -> Ok(PublicType(pub_type))
      _ -> Error(Nil)
    }
  })
}

fn pub_type_if_not_returned_in_pub_fun(type_name, fns) {
  let pub_fun_usage = {
    use fun <- list.find_map(fns)
    case fun {
      Definition(_, Function(_, public, _, Some(NamedType(t_name, ..)), ..))
        if public == Public && t_name == type_name
      -> Ok(Nil)
      _ -> Error(Nil)
    }
  }
  case pub_fun_usage {
    Ok(Nil) -> Error(Nil)
    Error(Nil) -> Ok(PublicType(type_name))
  }
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
  let ModuleName(module_name) = module_name
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
    || serialized_statement
    |> string.contains(
      "PatternConstructor(Some(\""
      <> module_name
      <> "\"), \""
      <> pub_type_name
      <> "\"",
    )
  {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}
