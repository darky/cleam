import fswalk
import gleam/iterator
import gleam/string

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
