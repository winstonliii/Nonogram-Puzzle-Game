open Core

type cell_state =
  | Empty
  | Filled
  | Unknown

type position = { x : int; y : int }

type clue = RLE of int list [@@unboxed]

(* Readded to use Map.Make instead of Poly *)
module Position = struct
  type t = position

  let compare a b =
    match Int.compare a.y b.y with
    | 0 -> Int.compare a.x b.x
    | n -> n
end

module PosMap = Stdlib.Map.Make (Position)

type t = {
  size : int;
  grid : cell_state PosMap.t;
  row_clues : clue array;
  col_clues : clue array;
}

let size p = p.size

let get p pos =
  match PosMap.find_opt pos p.grid with
  | Some state -> state
  | None -> Unknown

let set p pos state =
  let grid =
    match state with
    | Unknown -> PosMap.remove pos p.grid
    | _ -> PosMap.add pos state p.grid
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
  let grid = PosMap.empty in
  { size; grid; row_clues; col_clues }
