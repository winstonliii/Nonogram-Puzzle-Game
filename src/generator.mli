(* Type representing puzzle gen params *)
type generation_params = {
  rows : int;
  cols : int;
}

(* Result of puzzle generation. *)
type generation_result =
  | Success of Puzzle.t * Puzzle.t
  | Failure of string