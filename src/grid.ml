open Core

module Position = Position
module PosMap = Map.Make (Position)

type 'a t = {
  size : int;
  data : 'a PosMap.t;
}

let size g = g.size