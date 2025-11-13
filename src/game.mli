(* Type representing game state *)
type t

(* Type of user actions. *)
type action =
  | FillCell of Puzzle.position
  | MarkEmpty of Puzzle.position
  | ClearCell of Puzzle.position
  | GetHint
  | AutoSolve
  | CheckSolution
  | RestartPuzzle
  | Quit

(* Result of processing an action. *)
type action_result =
  | Success of string
  | Error of string
  | GameWon of float
  | HintProvided of Puzzle.position * Puzzle.cell_state

(* Game status. *)
type status =
  | InProgress 
  | Won 
  | Checking
