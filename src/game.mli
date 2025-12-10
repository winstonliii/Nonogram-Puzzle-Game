(* Type representing game state *)
type t

(* Type of user actions. *)
type action =
  | UpdateCell of { pos : Puzzle.position ; new_state : Puzzle.cell_state }
  | RestartPuzzle
  | Quit

type win = {
  time : Mtime.span;
  num_hints : int;
  score : int;
}

(* Errors that game-related operations may report. *)
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

val create : Puzzle.t -> t
val puzzle : t -> Puzzle.t
val status : t -> status
val process_action : t -> action -> action_result