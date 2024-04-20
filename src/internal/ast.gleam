import glance.{
  type Module as AST, Definition, Discarded, Function, Import, Module as AST,
  Named, UnqualifiedImport,
}
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import internal/fs.{FileContent, FilesDir, ModuleFullName}

pub type FileAst {
  FileAst(AST)
}

pub type AnotherFilesAst {
  AnotherFilesAst(List(FileAst))
}

pub type ModuleName {
  ModuleName(String)
}

type ImportedInfo {
  ModuleImported(ModuleName)
  ImportedAsAlias
}

pub type PublicMember {
  PublicFun(String)
  PublicConst(String)
  PublicType(String)
}

pub fn files_ast(files_contents) {
  use content <- list.map(files_contents)
  let assert FileContent(content) = content
  let assert Ok(ast) = glance.module(content)
  FileAst(ast)
}

pub fn files_paths_with_ast(dir, test_dir) {
  let file_paths = fs.files_paths(dir)
  let flle_contents = fs.files_contents(file_paths)
  let test_file_contents = case test_dir {
    Some(FilesDir(_) as test_dir) -> {
      fs.files_paths(test_dir)
      |> fs.files_contents
    }
    None -> []
  }
  let ast_list =
    flle_contents
    |> list.append(test_file_contents)
    |> files_ast
  let indexes = list.range(0, list.length(ast_list) - 1)
  use index <- list.filter_map(indexes)
  case list.at(file_paths, index) {
    Ok(file_path) -> {
      let assert Ok(file_ast) = list.at(ast_list, index)
      Ok(#(
        file_path,
        file_ast,
        AnotherFilesAst(
          list.filter_map(indexes, fn(idx) {
            case idx == index {
              True -> Error(Nil)
              False -> list.at(ast_list, idx)
            }
          }),
        ),
      ))
    }
    Error(Nil) -> Error(Nil)
  }
}

fn imported_info(imports, module_full_name, exported) {
  list.filter_map(imports, fn(imp) {
    case imp {
      Definition(_, Import(import_name, module_alias, type_aliases, aliases))
        if ModuleFullName(import_name) == module_full_name
      ->
        case
          aliases
          |> list.append(type_aliases)
          |> list.any(fn(alias) {
            let assert UnqualifiedImport(imported, _) = alias
            PublicFun(imported) == exported
            || PublicConst(imported) == exported
            || PublicType(imported) == exported
          })
        {
          True -> Ok(ImportedAsAlias)
          False ->
            case module_alias {
              Some(Named(alias)) -> Ok(ModuleImported(ModuleName(alias)))
              Some(Discarded(_)) -> Error(Nil)
              None ->
                Ok(
                  ModuleImported(module_full_name_to_module_name(
                    module_full_name,
                  )),
                )
            }
        }
      _ -> Error(Nil)
    }
  })
}

pub fn is_pub_member_used(
  files_ast,
  pub_member_name,
  module_full_name,
  check_usage,
) {
  let assert AnotherFilesAst(files_ast) = files_ast
  use file_ast <- list.find_map(files_ast)
  let assert FileAst(ast) = file_ast
  let assert AST(imports, _, _, _, fns) = ast
  let imported_info_list =
    imported_info(imports, module_full_name, pub_member_name)
  use imported_info <- list.find_map(imported_info_list)
  case imported_info {
    ImportedAsAlias -> Ok(Nil)
    ModuleImported(module_name) -> {
      use fun_def <- list.find_map(fns)
      let assert Definition(_, Function(_, _, _, _, statements, _)) = fun_def
      check_usage(statements, pub_member_name, module_name)
    }
  }
}

fn module_full_name_to_module_name(module_full_name) {
  let assert ModuleFullName(module_full_name) = module_full_name
  let assert Ok(module_name) =
    string.split(module_full_name, "/")
    |> list.last
  ModuleName(module_name)
}
