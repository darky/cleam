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

pub fn dep_fun_assigned() {
  int.to_string(123)
}

pub fn dep_fun_called_as_argument() {
  4
}

pub fn dep_fun_called_in_pipe(n) {
  n + 1
}

pub fn fun_orphan() {
  123
}

pub const const_orphan = "orphan"

pub const const_used = "used"

pub const const_used_as_alias = "used"

pub const const_used_in_aliased_module = "used"

pub type PubTypeUsed {
  PubTypeUsed(name: String)
}

pub type PubTypeUsedAsAlias {
  PubTypeUsedAsAlias(name: String)
}

pub type PubTypeUsedInAliasedModule {
  PubTypeUsedInAliasedModule(name: String)
}

pub type PubTypeOrphan {
  PubTypeOrphan(name: String)
}

pub opaque type PubOpaqueTypeUsed {
  PubOpaqueTypeUsed(n: Int)
}

pub fn pub_opaque_type(n) {
  PubOpaqueTypeUsed(n)
}

pub opaque type PubOpaqueTypeUsedAsAlias {
  PubOpaqueTypeUsedAsAlias(n: Int)
}

pub fn pub_opaque_type_used_as_alias(n) {
  PubOpaqueTypeUsedAsAlias(n)
}

pub opaque type PubOpaqueTypeUsedInAliasedModule {
  PubOpaqueTypeUsedInAliasedModule(n: Int)
}

pub fn pub_opaque_type_used_in_aliased_module(n) {
  PubOpaqueTypeUsedInAliasedModule(n)
}

pub opaque type PubOpaqueTypeOrphan {
  PubOpaqueTypeOrphan(n: Int)
}

pub type UnionType {
  UsedSubType
  SubTypeOrpan
}
