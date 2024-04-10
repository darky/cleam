import gleam/list
import gleam/string
import glance.{
  type Module as AST, CustomType, Definition, Function, Module as AST, Public,
  Variant,
}
import internal/ast.{
  AnotherFilesAst, FileAst, ImportedAsAlias, ModuleImported, ModuleName,
  PublicType,
}

pub fn public_type(file_ast) {
  let assert FileAst(ast) = file_ast
  let assert AST(_, types, ..) = ast
  use pub_type <- list.flat_map(types)
  let assert Definition(_, CustomType(_, is_public, _, _, sub_types)) = pub_type
  case is_public {
    Public -> {
      use sub_type <- list.map(sub_types)
      let assert Variant(type_name, _) = sub_type
      PublicType(type_name)
    }
    _ -> []
  }
}

pub fn is_pub_type_used(files_ast, pub_type_name, module_full_name) {
  let assert AnotherFilesAst(files_ast) = files_ast
  use file_ast <- list.find_map(files_ast)
  let assert FileAst(ast) = file_ast
  let assert AST(imports, _, _, _, fns) = ast
  let imported_info_list =
    ast.imported_info(imports, module_full_name, pub_type_name)
  use imported_info <- list.find_map(imported_info_list)
  case imported_info {
    ImportedAsAlias -> Ok(Nil)
    ModuleImported(module_name) -> {
      use fun_def <- list.find_map(fns)
      let assert Definition(_, Function(_, _, _, _, statements, _)) = fun_def
      check_type_usage(statements, pub_type_name, module_name)
    }
  }
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
