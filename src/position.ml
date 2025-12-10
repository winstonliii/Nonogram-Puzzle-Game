open Core

type t = { x : int; y : int } [@@deriving compare, sexp]