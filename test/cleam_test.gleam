import gleeunit
import gleeunit/should
import cleam

pub fn main() {
  gleeunit.main()
}

pub fn files_list_test() {
  cleam.files_list("src")
  |> should.equal(["src/cleam.gleam", "src/internal/internal.gleam"])
}
