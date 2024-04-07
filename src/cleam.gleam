import internal/checker
import internal/fs.{FilePath, FilesDir}
import internal/ast_fun.{PublicFun}
import gleam/list
import gleam/io
import gleam/option.{Some}

pub fn main() {
  let not_used_fun =
    checker.not_used_functions(FilesDir("src"), Some(FilesDir("test")))
  list.each(not_used_fun, fn(not_used_fun) {
    let #(PublicFun(public_fun), FilePath(file_path)) = not_used_fun
    io.println_error(
      "Function not used: " <> public_fun <> "; File path: " <> file_path,
    )
  })
  case list.length(not_used_fun) > 0 {
    True -> halt(1)
    False -> halt(0)
  }
}

@target(erlang)
@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil
