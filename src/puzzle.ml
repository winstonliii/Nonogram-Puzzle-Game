open Core

type cell_state =
  | Empty
  | Filled
  | Unknown

type position = { x : int; y : int }

type clue = RLE of int list [@@unboxed]

type t = {
  size : int;
  grid : (position, cell_state) Map.Poly.t;
  row_clues : clue array;
  col_clues : clue array;
}

let size p = p.size

let get p pos =
  Map.Poly.find p.grid pos
  |> Option.value ~default:Unknown

let set p pos state =
  let grid =
    match state with
    | Unknown -> Map.Poly.remove p.grid pos
    | _ -> Map.Poly.set p.grid ~key:pos ~data:state
  in
  { p with grid }

let rows p r =
  List.init p.size ~f:(fun x ->
      get p { x; y = r })

let cols p c =
  List.init p.size ~f:(fun y ->
      get p { x = c; y })

let row_clue p r = p.row_clues.(r)
let col_clue p c = p.col_clues.(c)

let create ~size ~row_clues ~col_clues =
  let grid = Map.Poly.empty in
  { size; grid; row_clues; col_clues }
