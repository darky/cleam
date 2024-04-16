import glance.{type Module as AST, Definition, Function, Module as AST, Public}
import gleam/list
import gleam/string
import internal/ast.{FileAst, ModuleName, PublicFun}

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
  ast.is_pub_member_used(
    files_ast,
    pub_fun_name,
    module_full_name,
    check_fun_usage,
  )
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
