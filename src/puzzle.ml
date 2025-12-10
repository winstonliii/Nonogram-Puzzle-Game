open Core

type cell_state =
  | Empty
  | Filled
  | Unknown

type clue = RLE of int list [@@unboxed]

module Position = Position
module PosMap = Map.Make (Position)

type position = Position.t

type t = {
  size : int;
  grid : cell_state PosMap.t;
  row_clues : clue array;
  col_clues : clue array;
}

let size p = p.size

let get p pos =
  match Map.find p.grid pos with
  | Some state -> state
  | None -> Unknown

let set p pos state =
  let grid =
    match state with
    | Unknown -> Map.remove p.grid pos
    | _ -> Map.set p.grid ~key:pos ~data:state
  in
  { p with grid }

let rows p r =
  List.init p.size ~f:(fun x ->
      get p Position.{ x; y = r })

let cols p c =
  List.init p.size ~f:(fun y ->
      get p Position.{ x = c; y })

let row_clue p r = p.row_clues.(r)
let col_clue p c = p.col_clues.(c)

let create ~size ~row_clues ~col_clues =
  let grid = PosMap.empty in
  { size; grid; row_clues; col_clues }
