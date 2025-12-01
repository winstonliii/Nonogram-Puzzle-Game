
(* Type representing the state of a cell in the grid *)
type cell_state =
  | Empty
  | Filled
  | Unknown

(* Type representing a position on the grid. *)
type position = { x : int; y : int }

(* Type representing a clue sequence for a row or column.
    List of integers indicating consecutive filled cells.
    For example: [2; 1; 3] is the clue sequence for a row or column. *)
type clue = RLE of int list [@@unboxed]

(* Abstract type representing a Nonogram puzzle grid. *)
type t

(* Puzzle fields *)
val size : t -> int

(* Get and set cell state by position*)
val get : t -> position -> cell_state
val set : t -> position -> cell_state -> t

(* Access lines of the puzzle horizontally or vertically*)
val rows : t -> int -> cell_state list
val cols : t -> int -> cell_state list

(* Clues for rows and columns *)
val row_clue : t -> int -> clue
val col_clue : t -> int -> clue

(* Create a puzzle based on size and pre-generated clues *)
val create : size:int -> row_clues:clue array -> col_clues:clue array -> t