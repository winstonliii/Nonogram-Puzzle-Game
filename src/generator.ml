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

(* Generate random solution grid w Random.bool (50% fill prob) for each cell.
   Keep as list-of-lists, then later convert to Puzzle.t *)
let random_solution_grid (size : int) : cell_state list list =
  List.init size ~f:(fun _ ->
      List.init size ~f:(fun _ ->
          if Random.bool () then Filled else Empty))

(* Extract row/col clues from a completed solution grid.
   Reads each row/column as a cell list, then encodes it. *)
let clues_from_grid (grid : cell_state list list) :
    clue array * clue array =
  let size = List.length grid in
  let row_clues =
    grid
    |> List.map ~f:clue_of_cells
    |> Array.of_list
  in
  let col_clues =
    let get_col x =
      let col = List.map grid ~f:(fun row -> List.nth_exn row x) in
      clue_of_cells col
    in
    Array.init size ~f:get_col
  in
  (row_clues, col_clues)

(* Copy solution grid into a Puzzle.t record w/ given clues *)
let puzzle_from_grid (grid : cell_state list list)
    (row_clues : clue array) (col_clues : clue array) : t =
  let size = List.length grid in
  let initial = create ~size ~row_clues ~col_clues in
  List.foldi grid ~init:initial ~f:(fun y acc row ->
      List.foldi row ~init:acc ~f:(fun x acc cell ->
          set acc Position.{ x; y } cell))

(* Verify solver output matches correct solution puzzle *)
let puzzles_match (p1 : t) (p2 : t) : bool =
  let size1 = size p1 in
  let size2 = size p2 in
  if size1 <> size2 then false
  else
    let rec check y x =
      if y = size1 then true
      else if x = size1 then check (y + 1) 0
      else
        let pos = Position.{ x; y } in
        let c1 = get p1 pos in
        let c2 = get p2 pos in
        phys_equal c1 c2 && check y (x + 1)
    in
    check 0 0

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
          let solution_grid = random_solution_grid size in
          let row_clues, col_clues = clues_from_grid solution_grid in
          let puzzle = create ~size ~row_clues ~col_clues in
          match Solver.solve puzzle with
          | Solver.NoSolution
          | PartialSolution _
          | MultipleSolutions _ ->
              attempt (n - 1)
          | Solved solved_puzzle ->
              let solution_puzzle =
                puzzle_from_grid solution_grid row_clues col_clues
              in
              if puzzles_match solved_puzzle solution_puzzle then
                Success (solution_puzzle, puzzle)
              else
                attempt (n - 1)
      in
      attempt max_attempts
    )
