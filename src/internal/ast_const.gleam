import glance.{type Module as AST, Constant, Definition, Module as AST, Public}
import gleam/list
import gleam/string
import internal/ast.{FileAst, ModuleName, PublicConst}

pub fn public_const(file_ast) {
  let FileAst(ast) = file_ast
  let AST(_, _, _, constants, ..) = ast
  use constant <- list.flat_map(constants)
  let Definition(_, Constant(const_name, is_public, ..)) = constant
  case is_public {
    Public -> [PublicConst(const_name)]
    _ -> []
  }
}

pub fn is_pub_const_used(files_ast, pub_const_name, module_full_name) {
  ast.is_pub_member_used(
    files_ast,
    pub_const_name,
    module_full_name,
    check_const_usage,
  )
}

fn check_const_usage(statements, pub_const_name, module_name) {
  let assert PublicConst(pub_const_name) = pub_const_name
  let ModuleName(module_name) = module_name
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
