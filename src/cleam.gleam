import fswalk
import gleam/iterator
import gleam/string
import simplifile
import gleam/list
import glance

pub fn files_list(path) {
  fswalk.builder()
  |> fswalk.with_path(path)
  |> fswalk.walk()
  |> iterator.filter(fn(entry_result) {
    case entry_result {
      Ok(fswalk.Entry(path, fswalk.Stat(is_dir))) ->
        is_dir == False && string.ends_with(path, ".gleam")
      _ -> False
    }
  })
  |> iterator.map(fn(entry_result) {
    let assert Ok(fswalk.Entry(path, _)) = entry_result
    path
  })
  |> iterator.to_list()
}

pub fn files_content(files_paths) {
  use path <- list.map(files_paths)
  let assert Ok(content) = simplifile.read(path)
  content
}

pub fn files_ast(files_contents) {
  use content <- list.map(files_contents)
  let assert Ok(module) = glance.module(content)
  module
}

pub fn pub_fns(ast) {
  use module <- list.flat_map(ast)
  let assert glance.Module(_, _, _, _, _, _, fns) = module
  use fun_def <- list.flat_map(fns)
  let assert glance.Definition(_, glance.Function(name, public, _, _, _, _)) =
    fun_def
  case public {
    glance.Public if name != "main" -> [name]
    _ -> []
  }
}
