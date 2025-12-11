module Position = Position

type 'a t

val size : 'a t -> int

val create : size:int -> init:(Position.t -> 'a) -> 'a t

val get : 'a t -> Position.t -> 'a

val set : 'a t -> Position.t -> 'a -> 'a t

val rows : 'a t -> int -> 'a list

val cols : 'a t -> int -> 'a list

val fold_rows :
  'a t ->
  init:'b ->
  f:('b -> int -> 'a list -> 'b) ->
  'b

val fold_cols :
  'a t ->
  init:'b ->
  f:('b -> int -> 'a list -> 'b) ->
  'b