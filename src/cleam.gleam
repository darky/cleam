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
  list.each(not_used_fun, fn(not_used_fun) {
    let assert #(PublicFun(public_fun), FilePath(file_path)) = not_used_fun
    io.println_error(
      "Function not used: " <> public_fun <> "; File path: " <> file_path,
    )
  })
  let not_used_const = checker.not_used_const(FilesDir("src"), ast_info)
  list.each(not_used_const, fn(not_used_const) {
    let assert #(PublicConst(pub_const), FilePath(file_path)) = not_used_const
    io.println_error(
      "Const not used: " <> pub_const <> "; File path: " <> file_path,
    )
  })
  let not_used_types = checker.not_used_types(FilesDir("src"), ast_info)
  list.each(not_used_types, fn(not_used_type) {
    let assert #(PublicType(pub_type), FilePath(file_path)) = not_used_type
    io.println_error(
      "Type not used: " <> pub_type <> "; File path: " <> file_path,
    )
  })
  case
    list.length(not_used_fun) > 0
    || list.length(not_used_const) > 0
    || list.length(not_used_types) > 0
  {
    True -> halt(1)
    False -> halt(0)
  }
}

@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil
