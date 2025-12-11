open Core

module Position = Position
module PosMap = Map.Make (Position)

type 'a t = {
  size : int;
  data : 'a PosMap.t;
}

let size g = g.size

let create ~size ~init =
  let positions =
    List.init size ~f:(fun y ->
        List.init size ~f:(fun x -> Position.{ x; y }))
    |> List.concat
  in
  let data =
    List.fold positions ~init:PosMap.empty ~f:(fun m pos ->
        Map.set m ~key:pos ~data:(init pos))
  in
  { size; data }