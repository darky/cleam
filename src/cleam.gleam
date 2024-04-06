// import internal/fs.{FilePath, FilesDir}
// import internal/ast_fun.{PublicFun}
// import internal/ast
// import gleam/list
// import gleam/io

// pub fn main() {
//   core(FilesDir("src"))
// }

// pub fn core(dir) {
//   let file_paths = fs.files_paths(dir)
//   let flle_contents = fs.files_contents(file_paths)
//   let ast_list = ast.files_ast(flle_contents)
//   let indexes =
//     list.length(file_paths)
//     |> list.range(0, _)
//   let not_used_errors =
//     indexes
//     |> list.zip(file_paths, _)
//     |> list.flat_map(fn(item) {
//       let #(file_path, index) = item
//       let module_full_name = fs.file_path_to_module_full_name(dir, file_path)
//       let assert Ok(file_ast) = list.at(ast_list, index)
//       let pub_funs = ast_fun.public_funs(file_ast)
//       let ast_of_other_files =
//         list.filter_map(indexes, fn(idx) {
//           case idx == index {
//             True -> Error(Nil)
//             False -> list.at(ast_list, idx)
//           }
//         })
//       use pub_fun <- list.flat_map(pub_funs)
//       let is_used =
//         ast_fun.is_pub_fun_used(ast_of_other_files, pub_fun, module_full_name)
//       case is_used {
//         True -> []
//         False -> {
//           let assert PublicFun(fun_name) = pub_fun
//           let assert FilePath(file_path) = file_path
//           ["Function not used: " <> fun_name <> ", file path: " <> file_path]
//         }
//       }
//     })
//   case list.length(not_used_errors) > 0 {
//     True -> {
//       list.each(not_used_errors, fn(err) { io.println(err) })
//     }
//     False -> Nil
//   }
// }
