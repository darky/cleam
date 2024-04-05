import gleam/list
import internal/fs.{FileContent}
import glance.{type Module as AST}

pub type FileAst {
  FileAst(AST)
}

pub fn files_ast(files_contents) {
  use content <- list.map(files_contents)
  let assert FileContent(content) = content
  let assert Ok(ast) = glance.module(content)
  FileAst(ast)
}
