open Core

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
  score : int;
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

(* Game status. *)
type status =
  | InProgress 
  | Won 
  | Checking

type t = {
  puzzle : Puzzle.t;
  initial_puzzle : Puzzle.t;
  status : status;
  hints_used : int;
  start_time : Mtime.t;
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
    hints_used = 0;
    start_time = Mtime_clock.now ();
  }


let puzzle (a : t) = a.puzzle
let status (a : t) = a.status

(* Check no unknowns for CheckSolution action *)
let is_complete (p : Puzzle.t) : bool =
  let n = Puzzle.size p in
  let rec loop y x =
    if y = n then
      true
    else if x = n then
      loop (y + 1) 0
    else
      match Puzzle.get p { Puzzle.x = x; y } with
      | Puzzle.Unknown -> false
      | _ -> loop y (x + 1)
  in
  loop 0 0
;;

let process_action (g : t) (a : action) : action_result =
  match a with
  | FillCell pos -> 
    let puzzle' = Puzzle.set g.puzzle pos Puzzle.Filled in
    Success { g with puzzle = puzzle' }

  | MarkEmpty pos ->
    let puzzle' = Puzzle.set g.puzzle pos Puzzle.Empty in
    Success { g with puzzle = puzzle' }

  | ClearCell pos ->
    let puzzle' = Puzzle.set g.puzzle pos Puzzle.Unknown in
    Success { g with puzzle = puzzle' }

  | GetHint ->

  | AutoSolve ->

  | CheckSolution ->

  | RestartPuzzle ->

  | Quit ->

;;