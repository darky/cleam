import gleam/int

pub fn dep_fun() {
  int.to_string(123)
}

pub fn fun_orphan() {
  123
}
