(* Type representing the state of a cell in the grid *)
type cell_state =
  | Empty
  | Filled
  | Unknown

(* Type representing a position on the grid. *)
type position = int * int

(* Type representing a clue sequence for a row or column.
    List of integers indicating consecutive filled cells.
    For example: [2; 1; 3] is the clue sequence for a row or column. *)
type clue = int list

(* Abstract type representing a Nonogram puzzle grid. *)
type t