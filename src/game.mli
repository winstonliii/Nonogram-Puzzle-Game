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

type win = {
  time : Mtime.span;
  hints : int;
  score : int; (* Maybe we can add time to score from using hints *)
}

(* 
InvalidAction for actions that cannot be done (hint with no selection),
IncompletePuzzle respond as incomplete for correct but in progress CheckSolution,
Contradiction responds with the issue for incorrect CheckSolution
*)
type error =
  | InvalidAction of string
  | IncompletePuzzle
  | Contradiction of string

(* Result of processing an action. *)
type action_result =
  | Success of t
  | Error of error
  | GameWon of win
  | HintProvided of Puzzle.position * Puzzle.cell_state * t

(* Game status. *)
type status =
  | InProgress 
  | Won 
  | Checking
