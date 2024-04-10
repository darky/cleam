import gleam/list
import gleam/string
import glance.{
  type Module as AST, Constant, Definition, Function, Module as AST, Public,
}
import internal/ast.{
  AnotherFilesAst, FileAst, ImportedAsAlias, ModuleImported, ModuleName,
  PublicConst,
}

pub fn public_const(file_ast) {
  let assert FileAst(ast) = file_ast
  let assert AST(_, _, _, constants, ..) = ast
  use constant <- list.flat_map(constants)
  let assert Definition(_, Constant(const_name, is_public, ..)) = constant
  case is_public {
    Public -> [PublicConst(const_name)]
    _ -> []
  }
}

pub fn is_pub_const_used(files_ast, pub_const_name, module_full_name) {
  let assert AnotherFilesAst(files_ast) = files_ast
  use file_ast <- list.find_map(files_ast)
  let assert FileAst(ast) = file_ast
  let assert AST(imports, _, _, _, fns) = ast
  let imported_info_list =
    ast.imported_info(imports, module_full_name, pub_const_name)
  use imported_info <- list.find_map(imported_info_list)
  case imported_info {
    ImportedAsAlias -> Ok(Nil)
    ModuleImported(module_name) -> {
      use fun_def <- list.find_map(fns)
      let assert Definition(_, Function(_, _, _, _, statements, _)) = fun_def
      check_const_usage(statements, pub_const_name, module_name)
    }
  }
}

fn check_const_usage(statements, pub_const_name, module_name) {
  let assert PublicConst(pub_const_name) = pub_const_name
  let assert ModuleName(module_name) = module_name
  use statement <- list.find_map(statements)
  case
    statement
    |> string.inspect
    |> string.contains(
      "FieldAccess(Variable(\""
      <> module_name
      <> "\"), \""
      <> pub_const_name
      <> "\")",
    )
  {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}
