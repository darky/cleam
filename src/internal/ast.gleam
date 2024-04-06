import gleam/list
import internal/fs.{FileContent, FilesDir}
import glance.{type Module as AST}
import gleam/option.{None, Some}

pub type FileAst {
  FileAst(AST)
}

pub type AnotherFilesAst {
  AnotherFilesAst(List(FileAst))
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
