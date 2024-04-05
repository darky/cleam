import gleeunit
import gleeunit/should
import gleam/list
import gleam/string
import internal/fs.{FileContent, FilePath, FilesDir, ModuleFullName}
import internal/ast_fun.{PublicFun}

pub fn main() {
  gleeunit.main()
}

const file_paths = [
  FilePath("test/fixtures/dependency.gleam"),
  FilePath("test/fixtures/file.gleam"),
]

pub fn files_list_test() {
  fs.files_paths(FilesDir("test/fixtures"))
  |> list.sort(fn(path1, path2) {
    let assert FilePath(path1) = path1
    let assert FilePath(path2) = path2
    string.compare(path1, path2)
  })
  |> should.equal(file_paths)
}

pub fn files_content_test() {
  fs.files_contents(file_paths)
  |> list.map(fn(content) {
    let assert FileContent(content) = content
    string.starts_with(content, "import")
  })
  |> should.equal([True, True])
}

pub fn file_path_to_module_name_test() {
  fs.file_path_to_module_name(
    FilesDir("test"),
    FilePath("test/fixtures/dependency.gleam"),
  )
  |> should.equal(ModuleFullName("fixtures/dependency"))
}

pub fn public_functions_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.public_funs
  |> should.equal([
    PublicFun("fun_orphan"),
    PublicFun("dep_fun_imported_as_alias"),
    PublicFun("dep_fun_inside_clojure"),
    PublicFun("dep_fun_inside_use"),
    PublicFun("dep_fun_nested_inside_block"),
    PublicFun("dep_fun_inside_block"),
    PublicFun("dep_fun"),
  ])
}

pub fn public_function_used_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_not_used_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("fun_orphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(False)
}

pub fn public_function_used_inside_block_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_block"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_inside_nested_block_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_nested_inside_block"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_inside_use_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_use"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_inside_clojure_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_clojure"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_imported_as_alias_test() {
  fs.files_contents(file_paths)
  |> ast_fun.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_imported_as_alias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}
