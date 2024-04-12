import internal/checker
import internal/fs.{FilePath, FilesDir}
import internal/ast.{PublicConst, PublicFun, PublicType}
import gleam/list
import gleam/io
import gleam/option.{Some}

pub fn main() {
  let ast_info =
    ast.files_paths_with_ast(FilesDir("src"), Some(FilesDir("test")))

  let not_used_fun = checker.not_used_functions(FilesDir("src"), ast_info)
  print_not_used(not_used_fun)

  let not_used_const = checker.not_used_const(FilesDir("src"), ast_info)
  print_not_used(not_used_const)

  let not_used_types = checker.not_used_types(FilesDir("src"), ast_info)
  print_not_used(not_used_types)

  case
    list.length(not_used_fun) > 0
    || list.length(not_used_const) > 0
    || list.length(not_used_types) > 0
  {
    True -> halt(1)
    False -> halt(0)
  }
}

fn print_not_used(not_used) {
  use not_used <- list.each(not_used)
  let assert #(pub_member, FilePath(file_path)) = not_used
  let #(prefix, name) = case pub_member {
    PublicFun(name) -> #("Function", name)
    PublicConst(name) -> #("Const", name)
    PublicType(name) -> #("Type", name)
  }
  io.println_error(
    prefix <> " not used: " <> name <> "; File path: " <> file_path,
  )
}

@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil
