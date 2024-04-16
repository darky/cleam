import glance.{Definition, Import, Module}
import gleam/list
import gleam/option.{None}
import gleam/string
import gleeunit
import gleeunit/should
import internal/ast.{
  AnotherFilesAst, FileAst, PublicConst, PublicFun, PublicType,
}
import internal/ast_const
import internal/ast_fun
import internal/ast_type
import internal/checker
import internal/fs.{FileContent, FilePath, FilesDir, ModuleFullName}

pub fn main() {
  gleeunit.main()
}

pub fn files_list_test() {
  fs.files_paths(FilesDir("test/fixtures"))
  |> list.sort(fn(fp1, fp2) {
    let assert FilePath(fp1) = fp1
    let assert FilePath(fp2) = fp2
    string.compare(fp1, fp2)
  })
  |> should.equal([
    FilePath("test/fixtures/dependency.gleam"),
    FilePath("test/fixtures/file.gleam"),
  ])
}

pub fn files_content_test() {
  fs.files_contents([
    FilePath("test/fixtures/dependency.gleam"),
    FilePath("test/fixtures/file.gleam"),
  ])
  |> list.sort(fn(c1, c2) {
    let assert FileContent(c1) = c1
    let assert FileContent(c2) = c2
    string.compare(c1, c2)
  })
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
      PublicFun("pub_opaque_type_used_in_aliased_module"),
      PublicFun("pub_opaque_type_used_as_alias"),
      PublicFun("pub_opaque_type"),
      PublicFun("fun_orphan"),
      PublicFun("dep_fun_called_in_pipe"),
      PublicFun("dep_fun_called_as_argument"),
      PublicFun("dep_fun_assigned"),
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
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_not_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("fun_orphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Error(Nil))
}

pub fn public_function_used_inside_block_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_block"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_used_inside_nested_block_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_nested_inside_block"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_used_inside_use_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_use"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_used_inside_clojure_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_inside_clojure"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_imported_as_alias_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_imported_as_alias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_used_in_aliased_module_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_module_as_alias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_used_as_assigned_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_assigned"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_called_as_argument_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_called_as_argument"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_function_called_as_pipe_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_fun.is_pub_fun_used(
    PublicFun("dep_fun_called_in_pipe"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn files_paths_with_ast_test() {
  let resp =
    ast.files_paths_with_ast(FilesDir("test/fixtures"), None)
    |> list.sort(fn(c1, c2) {
      let #(fp1, _, _) = c1
      let #(fp2, _, _) = c2
      let assert FilePath(fp1) = fp1
      let assert FilePath(fp2) = fp2
      string.compare(fp1, fp2)
    })
  let assert Ok(resp0) = list.at(resp, 0)
  let assert Ok(resp1) = list.at(resp, 1)
  resp0.0
  |> should.equal(FilePath("test/fixtures/dependency.gleam"))
  resp1.0
  |> should.equal(FilePath("test/fixtures/file.gleam"))
  case resp0.2 {
    AnotherFilesAst([
      FileAst(Module([Definition(_, Import("gleam/list", ..)), ..], ..)),
    ]) -> True
    _ -> False
  }
  |> should.equal(True)
  case resp1.2 {
    AnotherFilesAst([
      FileAst(Module([Definition(_, Import("gleam/int", ..)), ..], ..)),
    ]) -> True
    _ -> False
  }
  |> should.equal(True)
}

pub fn not_used_functions_test() {
  ast.files_paths_with_ast(FilesDir("test"), None)
  |> checker.not_used_functions(FilesDir("test"), _)
  |> list.filter(fn(not_used) {
    let #(_, FilePath(file_path)) = not_used
    case file_path {
      "test/fixtures/dependency.gleam" -> True
      _ -> False
    }
  })
  |> should.equal([
    #(PublicFun("fun_orphan"), FilePath("test/fixtures/dependency.gleam")),
  ])
}

pub fn not_used_const_test() {
  ast.files_paths_with_ast(FilesDir("test"), None)
  |> checker.not_used_const(FilesDir("test"), _)
  |> list.filter(fn(not_used) {
    let #(_, FilePath(file_path)) = not_used
    case file_path {
      "test/fixtures/dependency.gleam" -> True
      _ -> False
    }
  })
  |> should.equal([
    #(PublicConst("const_orphan"), FilePath("test/fixtures/dependency.gleam")),
  ])
}

pub fn public_const_test() {
  fs.files_contents([FilePath("test/fixtures/dependency.gleam")])
  |> ast.files_ast
  |> list.each(fn(file_ast) {
    file_ast
    |> ast_const.public_const
    |> should.equal([
      PublicConst("const_used_in_aliased_module"),
      PublicConst("const_used_as_alias"),
      PublicConst("const_used"),
      PublicConst("const_orphan"),
    ])
  })
}

pub fn public_const_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_const.is_pub_const_used(
    PublicConst("const_used"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_const_used_as_alias_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_const.is_pub_const_used(
    PublicConst("const_used_as_alias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_const_used_in_aliased_module_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_const.is_pub_const_used(
    PublicConst("const_used_in_aliased_module"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_const_not_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_const.is_pub_const_used(
    PublicConst("const_orphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Error(Nil))
}

pub fn public_types_test() {
  fs.files_contents([FilePath("test/fixtures/dependency.gleam")])
  |> ast.files_ast
  |> list.each(fn(file_ast) {
    file_ast
    |> ast_type.public_type
    |> should.equal([
      PublicType("EmptyTypeOrphan"),
      PublicType("UsedSubType"),
      PublicType("SubTypeOrpan"),
      PublicType("PubOpaqueTypeOrphan"),
      PublicType("PubOpaqueTypeUsedInAliasedModule"),
      PublicType("PubOpaqueTypeUsedAsAlias"),
      PublicType("PubOpaqueTypeUsed"),
      PublicType("PubTypeOrphan"),
      PublicType("PubTypeUsedInAliasedModule"),
      PublicType("PubTypeUsedAsAlias"),
      PublicType("PubTypeUsed"),
      PublicType("UsedAliasTypeInAliasedModule"),
      PublicType("UsedAliasTypeAsAlias"),
      PublicType("AliasTypeOrphan"),
      PublicType("UsedAliasType"),
    ])
  })
}

pub fn public_type_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubTypeUsed"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_type_used_as_alias_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubTypeUsedAsAlias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_type_used_in_aliased_module_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubTypeUsedInAliasedModule"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_type_not_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubTypeOrphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Error(Nil))
}

pub fn public_opaque_type_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubOpaqueTypeUsed"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_opaque_type_used_as_alias_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubOpaqueTypeUsedAsAlias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_opaque_type_used_in_aliased_module_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubOpaqueTypeUsedInAliasedModule"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_opaque_not_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("PubOpaqueTypeOrphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Error(Nil))
}

pub fn public_aliased_type_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("UsedAliasType"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_aliased_type_used_as_alias_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("UsedAliasTypeAsAlias"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_aliased_type_in_aliased_module_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("UsedAliasTypeInAliasedModule"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Ok(Nil))
}

pub fn public_aliased_type_not_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("AliasTypeOrphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Error(Nil))
}

pub fn public_empty_type_not_used_test() {
  fs.files_contents([FilePath("test/fixtures/file.gleam")])
  |> ast.files_ast
  |> AnotherFilesAst
  |> ast_type.is_pub_type_used(
    PublicType("EmptyTypeOrphan"),
    ModuleFullName("fixtures/dependency"),
  )
  |> should.equal(Error(Nil))
}

pub fn not_used_types_test() {
  ast.files_paths_with_ast(FilesDir("test"), None)
  |> checker.not_used_types(FilesDir("test"), _)
  |> list.filter(fn(not_used) {
    let #(_, FilePath(file_path)) = not_used
    case file_path {
      "test/fixtures/dependency.gleam" -> True
      _ -> False
    }
  })
  |> should.equal([
    #(PublicType("EmptyTypeOrphan"), FilePath("test/fixtures/dependency.gleam")),
    #(PublicType("SubTypeOrpan"), FilePath("test/fixtures/dependency.gleam")),
    #(
      PublicType("PubOpaqueTypeOrphan"),
      FilePath("test/fixtures/dependency.gleam"),
    ),
    #(PublicType("PubTypeOrphan"), FilePath("test/fixtures/dependency.gleam")),
    #(PublicType("AliasTypeOrphan"), FilePath("test/fixtures/dependency.gleam")),
  ])
}
