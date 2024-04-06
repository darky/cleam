import internal/checker
import internal/fs.{FilePath, FilesDir}
import internal/ast_fun.{PublicFun}
import gleam/list
import gleam/io

pub fn main() {
  let not_used_fun = checker.not_used_functions(FilesDir("src"))
  use #(PublicFun(public_fun), FilePath(file_path)) <- list.each(not_used_fun)
  io.println_error(
    "Function not used: " <> public_fun <> "; File path: " <> file_path,
  )
}
