type cell_state =
  | Empty
  | Filled
  | Unknown

type position = {
  row : int;
  col : int;
}

type clue = RLE of int list

(* I only did a bit tn, can do implementations of the functions later *)