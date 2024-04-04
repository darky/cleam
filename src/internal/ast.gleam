import gleam/string
import gleam/list
import glance.{
  type Module as AST, Block, Call, Definition, Expression, Field, FieldAccess,
  Fn, Function, Import, Module as AST, Public, UnqualifiedImport, Variable,
}
import internal/fs.{FileContent, ModuleName}

const main_fun_name = "main"

pub type FileAst {
  FileAst(AST)
}

pub type PublicFun {
  PublicFun(String)
}

pub fn files_ast(files_contents) {
  use content <- list.map(files_contents)
  let assert FileContent(content) = content
  let assert Ok(ast) = glance.module(content)
  FileAst(ast)
}

pub fn public_funs(files_ast) {
  use file_ast <- list.flat_map(files_ast)
  let assert FileAst(ast) = file_ast
  let assert AST(_, _, _, _, _, _, funs) = ast
  use fun_def <- list.flat_map(funs)
  let assert Definition(_, Function(fun_name, is_public, _, _, _, _)) = fun_def
  case is_public {
    Public if fun_name != main_fun_name -> [PublicFun(fun_name)]
    _ -> []
  }
}

pub fn is_pub_fun_used(ast, fun_name, module_name) {
  let assert ModuleName(module_name) = module_name
  let assert Ok(file_name) =
    string.split(module_name, "/")
    |> list.last
  let is_used_somewhere = {
    use module <- list.flat_map(ast)
    let assert FileAst(module) = module
    let assert AST(imports, _, _, _, _, _, fns) = module
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
