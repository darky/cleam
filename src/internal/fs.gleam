import fswalk.{Entry, Stat}
import gleam/iterator
import gleam/list
import gleam/string
import simplifile

pub type FilePath {
  FilePath(String)
}

pub type FileContent {
  FileContent(String)
}

pub type FilesDir {
  FilesDir(String)
}

pub type ModuleFullName {
  ModuleFullName(String)
}

pub fn files_paths(dir) {
  let assert FilesDir(dir) = dir
  fswalk.builder()
  |> fswalk.with_path(dir)
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
    FilePath(path)
  })
  |> iterator.to_list()
}

pub fn files_contents(files_paths) {
  use path <- list.map(files_paths)
  let assert FilePath(path) = path
  let assert Ok(content) = simplifile.read(path)
  FileContent(content)
}

pub fn file_path_to_module_full_name(files_dir, file_path) {
  let assert FilesDir(files_dir) = files_dir
  let assert FilePath(file_path) = file_path
  file_path
  |> string.replace(files_dir <> "/", "")
  |> string.replace(".gleam", "")
  |> ModuleFullName
}
