import fswalk.{Entry, Stat}
import gleam/iterator
import gleam/string
import simplifile
import gleam/list

pub fn files_list(path) {
  fswalk.builder()
  |> fswalk.with_path(path)
  |> fswalk.walk()
  |> iterator.filter(fn(entry_result) {
    case entry_result {
      Ok(Entry(path, Stat(is_dir))) ->
        is_dir == False && string.ends_with(path, ".gleam")
      _ -> False
    }
  })
  |> iterator.map(fn(entry_result) {
    let assert Ok(Entry(path, _)) = entry_result
    path
  })
  |> iterator.to_list()
}

pub fn files_content(files_paths) {
  use path <- list.map(files_paths)
  let assert Ok(content) = simplifile.read(path)
  content
}
