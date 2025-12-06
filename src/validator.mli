type error =
  | RowError of int * string
  | ColError of int * string

type validation_result =
  | Valid
  | Incomplete
  | Invalid of error list 

val validate : Puzzle.t -> validation_result

val clue_of_cells : Puzzle.cell_state list -> Puzzle.clue