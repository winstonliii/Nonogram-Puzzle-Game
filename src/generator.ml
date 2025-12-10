open Core
open Puzzle

type generation_params = {
  rows : int;
  cols : int;
}

type generation_result =
  | Success of t * t
  | Failure of string

(* Convert a line of cells (row/col) to a clue using RLE.
   Counts consecutive filled cells, breaking on empty/unknown cell *)
let clue_of_cells (cells : cell_state list) : clue =
  Validator.clue_of_cells cells

(* Generate random solution grid w Random.bool (50% fill prob) for each cell*)
  (* We can update this later for better results with larger nonograms like 10x10, 15x15! *)
let random_solution_matrix (size : int) : cell_state array array =
  let m = Array.make_matrix ~dimx:size ~dimy:size Empty in
  for y = 0 to size - 1 do
    for x = 0 to size - 1 do
      let v = if Random.bool () then Filled else Empty in
      m.(y).(x) <- v
    done
  done;
  m

(* Extract row/col clues from a completed solution matrix.
   Reads each as a cell list, then encodes it *)
let clues_from_matrix (m : cell_state array array) :
  clue array * clue array =
let size = Array.length m in
let row_clues =
  Array.init size ~f:(fun y ->
      let row = Array.to_list m.(y) in
      clue_of_cells row)
in
let col_clues =
  Array.init size ~f:(fun x ->
      let col = List.init size ~f:(fun y -> m.(y).(x)) in
      clue_of_cells col)
in
(row_clues, col_clues)

(* Copy solution matrix into a Puzzle.t record w given clues *)
let puzzle_from_solution (m : cell_state array array)
    (row_clues : clue array) (col_clues : clue array) : t =
  let size = Array.length m in
  let p = create ~size ~row_clues ~col_clues in
  let p_ref = ref p in
  for y = 0 to size - 1 do
    for x = 0 to size - 1 do
      let pos = Position.{ x; y } in
      p_ref := set !p_ref pos m.(y).(x)
    done
  done;
  !p_ref

(* Verify solver output matches correct solution *)
let puzzle_matches_matrix (p : t) (m : cell_state array array) : bool =
  let size_p = size p in
  let size_m = Array.length m in
  if size_p <> size_m then false
  else
    let ok = ref true in
    for y = 0 to size_p - 1 do
      for x = 0 to size_p - 1 do
        let expected = m.(y).(x) in
        let actual = get p Position.{ x; y } in
        if not (phys_equal expected actual) then ok := false
      done
    done;
    !ok

let max_attempts = 100

(* Main Generator: attempts to generate puzzle w unique solution.
  
   Algorithm: Gen random solution -> derive clues -> verify solver
   finds same solution | Retry if unsolvable, incomplete, mult solutions, 
   or solver solution mismatch
  
   Returns tuple of two Puzzle.t records: the solution and blank puzzle w clues *)
let generate (params : generation_params) : generation_result =
  if params.rows <> params.cols then
    Failure "Only square puzzles are supported (rows = cols)."
  else
    let size = params.rows in
    if not (List.mem [ 5; 10; 15 ] size ~equal:Int.equal) then
      Failure "Only 5x5, 10x10, and 15x15 puzzles are supported."
    else (
      Random.self_init ();
      let rec attempt n =
        if n = 0 then
          Failure "Failed to generate a uniquely solvable puzzle."
        else
          let solution_matrix = random_solution_matrix size in
          let row_clues, col_clues = clues_from_matrix solution_matrix in

          let puzzle = create ~size ~row_clues ~col_clues in
          match Solver.solve puzzle with
          | Solver.NoSolution ->
              attempt (n - 1)
          | Solver.PartialSolution _ ->
              attempt (n - 1)
          | Solver.MultipleSolutions _ ->
              attempt (n - 1)
          | Solver.Solved solved_puzzle ->
              if puzzle_matches_matrix solved_puzzle solution_matrix then
                let solution_puzzle =
                  puzzle_from_solution solution_matrix row_clues col_clues
                in
                Success (solution_puzzle, puzzle)
              else
                attempt (n - 1)
      in
      attempt max_attempts
    )