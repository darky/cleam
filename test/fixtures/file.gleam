import fixtures/dependency.{
  dep_fun, dep_fun_inside_block, dep_fun_inside_clojure, dep_fun_inside_use,
  dep_fun_nested_inside_block,
}
import gleam/list

pub fn main() {
  dep_fun()

  {
    dep_fun_inside_block()
    { dep_fun_nested_inside_block() }
  }

  list.map([1, 2, 3], fn(_) { dep_fun_inside_clojure() })

  use _ <- list.map([1, 2, 3])
  dep_fun_inside_use()
}
