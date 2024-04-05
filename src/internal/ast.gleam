import gleam/list
import internal/fs.{FileContent}
import glance.{type Module as AST}

pub type FileAst {
  FileAst(AST)
}

pub fn files_ast(files_contents) {
  use content <- list.map(files_contents)
  let assert FileContent(content) = content
  let assert Ok(ast) = glance.module(content)
  FileAst(ast)
}

pub fn files_paths_with_ast(dir) {
  let file_paths = fs.files_paths(dir)
  let flle_contents = fs.files_contents(file_paths)
  let ast_list = files_ast(flle_contents)
  let indexes = list.range(0, list.length(file_paths) - 1)
  use index <- list.map(indexes)
  let assert Ok(file_path) = list.at(file_paths, index)
  #(
    file_path,
    list.filter_map(indexes, fn(idx) {
      case idx == index {
        True -> Error(Nil)
        False -> list.at(ast_list, idx)
      }
    }),
  )
}
