(* Result type for solving operations. *)
type solve_result =
  | Solved of Puzzle.t 
  | NoSolution
  | PartialSolution of Puzzle.t

(* The type representing a line (row or column) in the puzzle. *)
type line = Puzzle.cell_state list

(* [solve_line clue line] applies constraint propagation to a single line given its clue.
    This is the deterministic line solver that finds cells that must be filled or empty.
    
    Algorithm:
    1. Generate all valid placements of the clue blocks that fit the line
    2. Filter out placements inconsistent with already-known cells
    3. Find cells that are the same in all valid placements (always filled or always empty)
*)
