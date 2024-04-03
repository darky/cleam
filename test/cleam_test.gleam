import gleeunit
import gleeunit/should
import cleam
import gleam/list
import gleam/string

pub fn main() {
  gleeunit.main()
}

const file_paths = [
  "test/fixtures/dependency.gleam", "test/fixtures/file.gleam",
]

pub fn files_list_test() {
  cleam.files_list("test/fixtures")
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
  |> should.equal([
    "fun_orphan", "dep_fun_inside_clojure", "dep_fun_inside_use",
    "dep_fun_nested_inside_block", "dep_fun_inside_block", "dep_fun",
  ])
}

pub fn public_function_used_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fn_used("dep_fun", _)
  |> should.equal(True)
}

pub fn public_function_not_used_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fn_used("fun_orphan", _)
  |> should.equal(False)
}

pub fn public_function_used_inside_block_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fn_used("dep_fun_inside_block", _)
  |> should.equal(True)
}

pub fn public_function_used_inside_nested_block_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fn_used("dep_fun_nested_inside_block", _)
  |> should.equal(True)
}

pub fn public_function_used_inside_use_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fn_used("dep_fun_inside_use", _)
  |> should.equal(True)
}

pub fn public_function_used_inside_clojure_test() {
  cleam.files_content(file_paths)
  |> cleam.files_ast
  |> cleam.pub_fn_used("dep_fun_inside_clojure", _)
  |> should.equal(True)
}
