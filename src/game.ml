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
  solution : Puzzle.t;
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

(* Create with solution *)
let create_with_solution (p : Puzzle.t) (solution : Puzzle.t) : t =
  {
    puzzle = p;
    initial_puzzle = p;
    solution;
    status = InProgress;
    (* hints_used = 0;
       start_time = Mtime_clock.now (); *)
  }

let create (p : Puzzle.t) : t =
  create_with_solution p p

let puzzle (a : t) = a.puzzle
let status (a : t) = a.status

(* Internal helper to check if the game is solved *)
let is_solved (g : t) : bool =
  let n = Puzzle.size g.puzzle in
  let rec loop x y =
    if y >= n then
      true
    else if x >= n then
      loop 0 (y + 1)
    else
      let pos = Position.{ x; y } in
      let a = Puzzle.get g.puzzle pos in
      let b = Puzzle.get g.solution pos in
      if a = b then
        loop (x + 1) y
      else
        false
  in
  loop 0 0

let process_action (g : t) (a : action) : action_result =
  match a with
  | UpdateCell { pos; new_state } ->
      let puzzle' = Puzzle.set g.puzzle pos new_state in
      let g' = { g with puzzle = puzzle' } in
      if is_solved g' then
        let win = {
          time = Mtime.Span.zero;
          num_hints = 0;
          score = 0;
        } in
        GameWon win
      else
        Success g'

  | RestartPuzzle ->
      let g2 =
        {
          g with
          puzzle = g.initial_puzzle;
          status = InProgress;
          (*hints_used = 0;
            start_time = Mtime_clock.now ();*)
        }
      in
      Success g2

  | Quit -> Success g