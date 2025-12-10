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

(* Game status. *)
type status =
  | InProgress 
  | Won 
  | Checking

type t = {
  puzzle : Puzzle.t;
  initial_puzzle : Puzzle.t;
  status : status;
  (*hints_used : int;
  start_time : Mtime.t;*)
}

(* Result of processing an action. *)
type action_result =
| Success of t
| Error of error
| GameWon of win
| HintProvided of Puzzle.position * Puzzle.cell_state * t

let create (p : Puzzle.t) : t =
  {
    puzzle = p;
    initial_puzzle = p;
    status = InProgress;
    (* hints_used = 0;
    start_time = Mtime_clock.now (); *)
  }


let puzzle (a : t) = a.puzzle
let status (a : t) = a.status

let process_action (g : t) (a : action) : action_result =
  match a with
  | UpdateCell { pos; new_state } ->
    let puzzle' = Puzzle.set g.puzzle pos new_state in
    Success { g with puzzle = puzzle' }

  | RestartPuzzle ->
    let g2 =
      {
        g with
        puzzle = g.initial_puzzle;
        status = InProgress;
        (*hints_used = 0;
        start_time = Mtime_clock.now (); *)(* Some versions online make u keep the same start time if u start over, doing this might not make sense in the context of hints counting for score *)
      }
    in
    Success g2

  | Quit -> Success g
;;