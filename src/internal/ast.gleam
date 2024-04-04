import gleam/string
import gleam/list
import glance.{
  type Module, Block, Call, Definition, Expression, Field, FieldAccess, Fn,
  Function, Import, Module, Public, UnqualifiedImport, Variable,
}
import internal/fs.{FileContent}

const main_fun_name = "main"

pub type FileAst {
  FileAst(Module)
}

pub type PublicFun {
  PublicFun(String)
}

pub fn files_ast(files_contents) {
  use content <- list.map(files_contents)
  let assert FileContent(content) = content
  let assert Ok(module) = glance.module(content)
  FileAst(module)
}

pub fn pub_fns(ast) {
  use module <- list.flat_map(ast)
  let assert FileAst(module) = module
  let assert Module(_, _, _, _, _, _, fns) = module
  use fun_def <- list.flat_map(fns)
  let assert Definition(_, Function(name, public, _, _, _, _)) = fun_def
  case public {
    Public if name != main_fun_name -> [PublicFun(name)]
    _ -> []
  }
}

pub fn is_pub_fn_used(ast, fun_name, module_name) {
  let assert Ok(file_name) =
    string.split(module_name, "/")
    |> list.last
  let is_used_somewhere = {
    use module <- list.flat_map(ast)
    let assert FileAst(module) = module
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
              PublicFun(f_name) == fun_name
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
      if PublicFun(field_name) == fun_name && var_name == file_name
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
