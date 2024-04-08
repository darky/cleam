import gleam/list
import glance.{type Module as AST, Constant, Definition, Module as AST, Public}
import internal/ast.{FileAst, PublicConst}

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
