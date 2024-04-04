import fswalk
import gleam/iterator
import gleam/string
import simplifile
import gleam/list
import glance.{
  Block, Call, Definition, Expression, Field, FieldAccess, Fn, Function, Import,
  Module, Public, UnqualifiedImport, Variable,
}

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
  let assert Module(_, _, _, _, _, _, fns) = module
  use fun_def <- list.flat_map(fns)
  let assert Definition(_, Function(name, public, _, _, _, _)) = fun_def
  case public {
    Public if name != "main" -> [name]
    _ -> []
  }
}

pub fn pub_fn_used(ast, fun_name, module_name) {
  let assert Ok(file_name) =
    string.split(module_name, "/")
    |> list.last
  let is_used_somewhere = {
    use module <- list.flat_map(ast)
    let assert Module(imports, _, _, _, _, _, fns) = module
    let is_imported =
      list.map(imports, fn(imp) {
        case imp {
          Definition(_, Import(import_name, _, _, aliases))
            if import_name == module_name
          -> #(
            True,
            list.any(aliases, fn(al) {
              let assert UnqualifiedImport(f_name, _) = al
              f_name == fun_name
            }),
          )
          _ -> #(False, False)
        }
      })
      |> list.find(fn(is_imp) { is_imp.0 })
    case is_imported {
      Ok(#(True, True)) -> [True]
      Ok(#(True, False)) -> {
        use fun_def <- list.flat_map(fns)
        let assert Definition(_, Function(_, _, _, _, statements, _)) = fun_def
        check_fun_name_usage(statements, fun_name, file_name)
      }
      _ -> []
    }
  }
  is_used_somewhere
  |> list.any(fn(is) { is })
}

fn check_fun_name_usage(statements, fun_name, file_name) {
  use statement <- list.flat_map(statements)
  check_fun_name_usage_in_statement(statement, fun_name, file_name)
}

fn check_fun_name_usage_in_statement(statement, fun_name, file_name) {
  case statement {
    Expression(Call(FieldAccess(Variable(var_name), field_name), _))
      if field_name == fun_name && var_name == file_name
    -> [True]
    Expression(Call(_, params)) -> {
      use param <- list.flat_map(params)
      case param {
        Field(_, Fn(_, _, statements)) -> {
          check_fun_name_usage(statements, fun_name, file_name)
        }
        _ -> [False]
      }
    }
    Expression(Block(statements)) -> {
      check_fun_name_usage(statements, fun_name, file_name)
    }
    _ -> [False]
  }
}
