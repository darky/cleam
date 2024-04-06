import fixtures/dependency.{dep_fun_imported_as_alias}
import gleam/list
import gleam/function
import fixtures/dependency as dep

pub fn main() {
  dependency.dep_fun()

  {
    dependency.dep_fun_inside_block()
    { dependency.dep_fun_nested_inside_block() }
  }

  let ident = function.identity(dependency.dep_fun_called_as_argument())

  list.map([1, 2, 3], fn(_) { dependency.dep_fun_inside_clojure() })

  use _ <- list.map([1, 2, 3])
  dependency.dep_fun_inside_use()

  dep_fun_imported_as_alias()

  dep.dep_fun_module_as_alias()

  let resp = dependency.dep_fun_assigned()
  #(resp, ident)
}
