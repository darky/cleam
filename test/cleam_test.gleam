import gleeunit
import gleeunit/should
import cleam
import gleam/list
import gleam/string

pub fn main() {
  gleeunit.main()
}

const file_paths = ["src/cleam.gleam", "src/internal/internal.gleam"]

pub fn files_list_test() {
  cleam.files_list("src")
  |> should.equal(file_paths)
}

pub fn files_content_test() {
  cleam.files_content(file_paths)
  |> list.map(fn(content_result) {
    let assert Ok(content) = content_result
    string.starts_with(content, "import")
  })
  |> should.equal([True, True])
}
