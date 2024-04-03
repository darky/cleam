import gleeunit
import gleeunit/should
import cleam
import gleam/list
import gleam/string

pub fn main() {
  gleeunit.main()
}

const file_paths = ["src/cleam.gleam", "src/internal/internal.gleam"]

pub fn files_list_test() {
  cleam.files_list("src")
  |> should.equal(file_paths)
}

pub fn files_content_test() {
  cleam.files_content(file_paths)
  |> list.map(fn(content) { string.starts_with(content, "import") })
  |> should.equal([True, True])
}

pub fn public_functions_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fns
  |> should.equal(["pub_fns", "files_ast", "files_content", "files_list"])
}
