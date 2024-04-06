import internal/ast
import gleam/list
import internal/ast_fun
import internal/fs

pub fn not_used_functions(dir, test_dir) {
  let fp_with_ast = ast.files_paths_with_ast(dir, test_dir)
  use #(file_path, file_ast, another_files_ast) <- list.flat_map(fp_with_ast)
  let public_funs = ast_fun.public_funs(file_ast)
  use public_fun <- list.flat_map(public_funs)
  let is_public_fun_used =
    ast_fun.is_pub_fun_used(
      another_files_ast,
      public_fun,
      fs.file_path_to_module_full_name(dir, file_path),
    )
  case is_public_fun_used {
    True -> []
    False -> [#(public_fun, file_path)]
  }
}
