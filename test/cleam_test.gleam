import gleeunit
import gleeunit/should
import gleam/list
import gleam/string
import internal/fs
import internal/ast

pub fn main() {
  gleeunit.main()
}

const file_paths = [
  "test/fixtures/dependency.gleam", "test/fixtures/file.gleam",
]

pub fn files_list_test() {
  fs.files_list("test/fixtures")
  |> list.sort(fn(a, b) { string.compare(a, b) })
  |> should.equal(file_paths)
}

pub fn files_content_test() {
  fs.files_content(file_paths)
  |> list.map(fn(content) { string.starts_with(content, "import") })
  |> should.equal([True, True])
}

pub fn public_functions_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fns
  |> should.equal([
    "fun_orphan", "dep_fun_imported_as_alias", "dep_fun_inside_clojure",
    "dep_fun_inside_use", "dep_fun_nested_inside_block", "dep_fun_inside_block",
    "dep_fun",
  ])
}

pub fn public_function_used_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("dep_fun", "fixtures/dependency")
  |> should.equal(True)
}

pub fn public_function_not_used_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("fun_orphan", "fixtures/dependency")
  |> should.equal(False)
}

pub fn public_function_used_inside_block_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("dep_fun_inside_block", "fixtures/dependency")
  |> should.equal(True)
}

pub fn public_function_used_inside_nested_block_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("dep_fun_nested_inside_block", "fixtures/dependency")
  |> should.equal(True)
}

pub fn public_function_used_inside_use_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("dep_fun_inside_use", "fixtures/dependency")
  |> should.equal(True)
}

pub fn public_function_used_inside_clojure_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("dep_fun_inside_clojure", "fixtures/dependency")
  |> should.equal(True)
}

pub fn public_function_imported_as_alias_test() {
  fs.files_content(file_paths)
  |> ast.files_ast
  |> ast.pub_fn_used("dep_fun_imported_as_alias", "fixtures/dependency")
  |> should.equal(True)
}
