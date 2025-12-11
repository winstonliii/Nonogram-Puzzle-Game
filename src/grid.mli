module Position = Position

type 'a t

val size : 'a t -> int

val create : size:int -> init:(Position.t -> 'a) -> 'a t