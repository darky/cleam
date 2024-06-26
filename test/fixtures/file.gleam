import fixtures/dependency.{
  type PubOpaqueTypeUsedAsAlias, type UsedAliasTypeAsAlias, PubTypeUsedAsAlias,
  const_used_as_alias, dep_fun_imported_as_alias,
}
import fixtures/dependency as dep
import gleam/function
import gleam/list

pub fn main() {
  case dep.put_type_used_in_pattern_matching_aliased_module() {
    dep.PubTypeUsedInPatternMatchingInAliasedModule -> ""
  }

  case dependency.put_type_used_in_pattern_matching() {
    dependency.PubTypeUsedInPatternMatching -> ""
  }

  let pub_alias_type: dependency.UsedAliasType = 123
  pub_alias_type

  let pub_alias_type: UsedAliasTypeAsAlias = 123
  pub_alias_type

  let pub_alias_type: dep.UsedAliasTypeInAliasedModule = 123
  pub_alias_type

  dependency.UsedSubType

  let pub_opaq_type: dependency.PubOpaqueTypeUsed =
    dependency.pub_opaque_type(0)
  pub_opaq_type

  let pub_opaq_type_as_alias: PubOpaqueTypeUsedAsAlias =
    dep.pub_opaque_type_used_as_alias(0)
  pub_opaq_type_as_alias

  let pub_opaq_type_in_aliased_module: dep.PubOpaqueTypeUsedInAliasedModule =
    dep.pub_opaque_type_used_in_aliased_module(0)
  pub_opaq_type_in_aliased_module

  dependency.PubTypeUsed("name")

  PubTypeUsedAsAlias("name")

  dep.PubTypeUsedInAliasedModule("name")

  dependency.const_used

  const_used_as_alias

  dep.const_used_in_aliased_module

  dependency.dep_fun()

  {
    dependency.dep_fun_inside_block()
    { dependency.dep_fun_nested_inside_block() }
  }

  1
  |> dependency.dep_fun_called_in_pipe

  let ident = function.identity(dependency.dep_fun_called_as_argument())

  list.map([1, 2, 3], fn(_) { dependency.dep_fun_inside_clojure() })

  use _ <- list.map([1, 2, 3])
  dependency.dep_fun_inside_use()

  dep_fun_imported_as_alias()

  dep.dep_fun_module_as_alias()

  let resp = dependency.dep_fun_assigned()
  #(resp, ident)
}
