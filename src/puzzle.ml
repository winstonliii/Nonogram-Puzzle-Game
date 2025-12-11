open Core

type cell_state =
  | Empty
  | Filled
  | Unknown

type clue = RLE of int list [@@unboxed]

module Position = Position

type position = Position.t

type t = {
  size : int;
  grid : cell_state Grid.t;
  row_clues : clue array;
  col_clues : clue array;
}

let size p = p.size

let get p pos = Grid.get p.grid pos

let set p pos state =
  let grid = Grid.set p.grid pos state in
  { p with grid }

let rows p r = Grid.rows p.grid r

let cols p c = Grid.cols p.grid c

let fold_rows p ~init ~f = Grid.fold_rows p.grid ~init ~f

let fold_cols p ~init ~f = Grid.fold_cols p.grid ~init ~f

let row_clue p r = p.row_clues.(r)
let col_clue p c = p.col_clues.(c)

let create ~size ~row_clues ~col_clues =
  let grid =
    Grid.create ~size ~init:(fun _ -> Unknown)
  in
  { size; grid; row_clues; col_clues }
