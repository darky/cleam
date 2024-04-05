import gleam/int

pub fn dep_fun() {
  int.to_string(123)
}

pub fn dep_fun_inside_block() {
  int.to_string(123)
}

pub fn dep_fun_nested_inside_block() {
  int.to_string(123)
}

pub fn dep_fun_inside_use() {
  int.to_string(123)
}

pub fn dep_fun_inside_clojure() {
  int.to_string(123)
}

pub fn dep_fun_imported_as_alias() {
  int.to_string(123)
}

pub fn dep_fun_module_as_alias() {
  int.to_string(123)
}

pub fn fun_orphan() {
  123
}
