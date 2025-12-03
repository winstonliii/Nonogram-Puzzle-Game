type error =
  | RowError of int * string
  | ColError of int * string

type validation_result =
  | Valid
  | Incomplete
  | Invalid of error list 

val validate : Puzzle.t -> validation_result

