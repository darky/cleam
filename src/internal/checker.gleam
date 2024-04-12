import gleam/list
import internal/ast_fun
import internal/ast_const
import internal/ast_type
import internal/fs

pub fn not_used_functions(dir, ast_info) {
  not_used_base(dir, ast_info, ast_fun.public_funs, ast_fun.is_pub_fun_used)
}

pub fn not_used_const(dir, ast_info) {
  not_used_base(
    dir,
    ast_info,
    ast_const.public_const,
    ast_const.is_pub_const_used,
  )
}

pub fn not_used_types(dir, ast_info) {
  not_used_base(dir, ast_info, ast_type.public_type, ast_type.is_pub_type_used)
}

fn not_used_base(dir, ast_info, get_public_members, is_pub_used) {
  use #(file_path, file_ast, another_files_ast) <- list.flat_map(ast_info)
  let public_members = get_public_members(file_ast)
  use public_member <- list.flat_map(public_members)
  let is_public_used =
    is_pub_used(
      another_files_ast,
      public_member,
      fs.file_path_to_module_full_name(dir, file_path),
    )
  case is_public_used {
    Ok(Nil) -> []
    Error(Nil) -> [#(public_member, file_path)]
  }
}
