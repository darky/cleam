import gleeunit
import gleeunit/should
import gleam/list
import gleam/string
import internal/fs.{FileContent, FilePath, FilesDir, ModuleFullName}
import internal/ast_fun.{PublicFun}
import internal/ast.{FileAst}
import glance.{Definition, Import, Module}

pub fn main() {
  gleeunit.main()
}

const file_paths = [
  FilePath("test/fixtures/dependency.gleam"),
  FilePath("test/fixtures/file.gleam"),
]

pub fn files_list_test() {
  fs.files_paths(FilesDir("test/fixtures"))
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
  fs.file_path_to_module_full_name(
    FilesDir("test"),
    FilePath("test/fixtures/dependency.gleam"),
  )
  |> should.equal(ModuleFullName("fixtures/dependency"))
}

pub fn public_functions_test() {
  fs.files_contents([FilePath("test/fixtures/dependency.gleam")])
  |> ast.files_ast
  |> list.each(fn(file_ast) {
    file_ast
    |> ast_fun.public_funs
    |> should.equal([
      PublicFun("fun_orphan"),
      PublicFun("dep_fun_module_as_alias"),
      PublicFun("dep_fun_imported_as_alias"),
      PublicFun("dep_fun_inside_clojure"),
      PublicFun("dep_fun_inside_use"),
      PublicFun("dep_fun_nested_inside_block"),
      PublicFun("dep_fun_inside_block"),
      PublicFun("dep_fun"),
    ])
  })
}

pub fn public_function_used_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_not_used_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("fun_orphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(False)
}

pub fn public_function_used_inside_block_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_block"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_inside_nested_block_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_nested_inside_block"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_inside_use_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_use"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_inside_clojure_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_clojure"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_imported_as_alias_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_imported_as_alias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn public_function_used_in_aliased_module_test() {
  fs.files_contents(file_paths)
  |> ast.files_ast
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_module_as_alias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(True)
}

pub fn files_paths_with_ast_test() {
  let resp = ast.files_paths_with_ast(FilesDir("test/fixtures"))
  let assert Ok(resp0) = list.at(resp, 0)
  let assert Ok(resp1) = list.at(resp, 1)
  resp0.0
  |> should.equal(FilePath("test/fixtures/dependency.gleam"))
  resp1.0
  |> should.equal(FilePath("test/fixtures/file.gleam"))
  case resp0.1 {
    [
      FileAst(Module(
        [Definition(_, Import("fixtures/dependency", _, _, _)), ..],
        _,
        _,
        _,
        _,
        _,
        _,
      )),
    ] -> True
    _ -> False
  }
  |> should.equal(True)
  case resp1.1 {
    [
      FileAst(Module(
        [Definition(_, Import("gleam/int", _, _, _)), ..],
        _,
        _,
        _,
        _,
        _,
        _,
      )),
    ] -> True
    _ -> False
  }
  |> should.equal(True)
}
