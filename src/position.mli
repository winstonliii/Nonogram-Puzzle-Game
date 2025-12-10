open Core

type t = { x : int; y : int }

val compare : t -> t -> int
val sexp_of_t : t -> Sexp.t
val t_of_sexp : Sexp.t -> t