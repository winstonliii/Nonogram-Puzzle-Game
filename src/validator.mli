type error =
  | RowError of int * string
  | ColError of int * string

type validation_result =
  | Valid
  | Incomplete
  | Invalid of error list 

(* [validate puzzle] checks if the puzzle is completely and correctly solved.
    
    Validation rules:
    1. All cells must be Filled or Empty (no Unknown cells)
    2. Each row must match its clue sequence exactly
    3. Each column must match its clue sequence exactly
    4. Groups of filled cells must be separated by at least one empty cell
    
*)