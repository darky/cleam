import gleam/string
import gleam/list
import gleam/result
import glance.{
  type Module as AST, Block, Call, Definition, Expression, Field, FieldAccess,
  Fn, Function, Import, Module as AST, Public, UnqualifiedImport, Variable,
}
import internal/fs.{FileContent, ModuleFullName}

const main_fun_name = "main"

pub type FileAst {
  FileAst(AST)
}

pub type PublicFun {
  PublicFun(String)
}

type ModuleName {
  ModuleName(String)
}

type ImportedInfo {
  ModuleImported
  FunctionImportedAsAlias
  NoImported
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

pub fn is_pub_fun_used(files_ast, pub_fun_name, module_full_name) {
  let module_name = module_full_name_to_module_name(module_full_name)
  let is_used_somewhere = {
    use file_ast <- list.find_map(files_ast)
    let assert FileAst(ast) = file_ast
    let assert AST(imports, _, _, _, _, _, fns) = ast
    let imported_info =
      function_imported_info(imports, module_full_name, pub_fun_name)
    case imported_info {
      FunctionImportedAsAlias -> Ok(Nil)
      ModuleImported -> {
        use fun_def <- list.find_map(fns)
        let assert Definition(_, Function(_, _, _, _, statements, _)) = fun_def
        check_fun_name_usage(statements, pub_fun_name, module_name)
      }
      NoImported -> Error(Nil)
    }
  }
  case is_used_somewhere {
    Ok(Nil) -> True
    Error(Nil) -> False
  }
}

fn check_fun_name_usage(statements, pub_fun_name, module_name) {
  use statement <- list.find_map(statements)
  check_fun_name_usage_in_statement(statement, pub_fun_name, module_name)
}

fn check_fun_name_usage_in_statement(statement, pub_fun_name, module_name) {
  case statement {
    Expression(Call(FieldAccess(Variable(var_name), field_name), _))
      if PublicFun(field_name) == pub_fun_name
      && ModuleName(var_name) == module_name
    -> Ok(Nil)
    Expression(Call(_, params)) -> {
      use param <- list.find_map(params)
      case param {
        Field(_, Fn(_, _, statements)) -> {
          check_fun_name_usage(statements, pub_fun_name, module_name)
        }
        _ -> Error(Nil)
      }
    }
    Expression(Block(statements)) -> {
      check_fun_name_usage(statements, pub_fun_name, module_name)
    }
    _ -> Error(Nil)
  }
}

fn module_full_name_to_module_name(module_full_name) {
  let assert ModuleFullName(module_full_name) = module_full_name
  let assert Ok(module_name) =
    string.split(module_full_name, "/")
    |> list.last
  ModuleName(module_name)
}

fn function_imported_info(imports, module_full_name, pub_fun_name) {
  let imported_info =
    list.find_map(imports, fn(imp) {
      case imp {
        Definition(_, Import(import_name, _, _, aliases))
          if ModuleFullName(import_name) == module_full_name
        ->
          case
            list.any(aliases, fn(alias) {
              let assert UnqualifiedImport(fun_name, _) = alias
              PublicFun(fun_name) == pub_fun_name
            })
          {
            True -> Ok(FunctionImportedAsAlias)
            False -> Ok(ModuleImported)
          }
        _ -> Error(NoImported)
      }
    })
    |> result.or(Ok(NoImported))
  let assert Ok(imported_info) = imported_info
  imported_info
}
