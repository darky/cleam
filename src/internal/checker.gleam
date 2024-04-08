import gleam/list
import internal/ast_fun
import internal/ast_const
import internal/fs

pub fn not_used_functions(dir, ast_info) {
  use #(file_path, file_ast, another_files_ast) <- list.flat_map(ast_info)
  let public_funs = ast_fun.public_funs(file_ast)
  use public_fun <- list.flat_map(public_funs)
  let is_public_fun_used =
    ast_fun.is_pub_fun_used(
      another_files_ast,
      public_fun,
      fs.file_path_to_module_full_name(dir, file_path),
    )
  case is_public_fun_used {
    Ok(Nil) -> []
    Error(Nil) -> [#(public_fun, file_path)]
  }
}

pub fn not_used_const(dir, ast_info) {
  use #(file_path, file_ast, another_files_ast) <- list.flat_map(ast_info)
  let public_const = ast_const.public_const(file_ast)
  use public_const <- list.flat_map(public_const)
  let is_public_const_used =
    ast_const.is_pub_const_used(
      another_files_ast,
      public_const,
      fs.file_path_to_module_full_name(dir, file_path),
    )
  case is_public_const_used {
    Ok(Nil) -> []
    Error(Nil) -> [#(public_const, file_path)]
  }
}
