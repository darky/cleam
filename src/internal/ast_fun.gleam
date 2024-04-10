import gleam/string
import gleam/list
import glance.{type Module as AST, Definition, Function, Module as AST, Public}
import internal/ast.{
  AnotherFilesAst, FileAst, ImportedAsAlias, ModuleImported, ModuleName,
  PublicFun,
}

const main_fun_name = "main"

pub fn public_funs(file_ast) {
  let assert FileAst(ast) = file_ast
  let assert AST(_, _, _, _, funs) = ast
  use fun_def <- list.flat_map(funs)
  let assert Definition(_, Function(fun_name, is_public, ..)) = fun_def
  case is_public {
    Public if fun_name != main_fun_name -> [PublicFun(fun_name)]
    _ -> []
  }
}

pub fn is_pub_fun_used(files_ast, pub_fun_name, module_full_name) {
  let assert AnotherFilesAst(files_ast) = files_ast
  use file_ast <- list.find_map(files_ast)
  let assert FileAst(ast) = file_ast
  let assert AST(imports, _, _, _, fns) = ast
  let imported_info_list =
    ast.imported_info(imports, module_full_name, pub_fun_name)
  use imported_info <- list.find_map(imported_info_list)
  case imported_info {
    ImportedAsAlias -> Ok(Nil)
    ModuleImported(module_name) -> {
      use fun_def <- list.find_map(fns)
      let assert Definition(_, Function(_, _, _, _, statements, _)) = fun_def
      check_fun_usage(statements, pub_fun_name, module_name)
    }
  }
}

fn check_fun_usage(statements, pub_fun_name, module_name) {
  let assert PublicFun(pub_fun_name) = pub_fun_name
  let assert ModuleName(module_name) = module_name
  use statement <- list.find_map(statements)
  case
    statement
    |> string.inspect
    |> string.contains(
      "FieldAccess(Variable(\""
      <> module_name
      <> "\"), \""
      <> pub_fun_name
      <> "\")",
    )
  {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}
