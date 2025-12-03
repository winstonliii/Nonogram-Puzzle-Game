open Core
open Puzzle

type generation_params = {
  rows : int;
  cols : int;
}

type generation_result =
  | Success of t * t
  | Failure of string

let clue_of_cells (cells : cell_state list) : clue =
  (*  Implement RLE encoding
     - Iterate through cells
     - Count consecutive Filled cells
     - Build list of run lengths
     - Wrap in RLE constructor *)
  RLE []

let random_solution_matrix (size : int) : cell_state array array =
  (* Generate random size x size matrix with random Filled/Empty cells *)
  Array.init size ~f:(fun _ ->
      Array.init size ~f:(fun _ ->
          if Random.bool () then Filled else Empty))

let clues_from_matrix (m : cell_state array array) :
    clue array * clue array =
  (*   Extract clues from solution matrix
     - For each row, convert to list and call clue_of_cells
     - For each col, extract column and call clue_of_cells
     - Return (row_clues, col_clues) *)
  let size = Array.length m in
  (Array.create ~len:size (RLE []), Array.create ~len:size (RLE []))

let puzzle_from_solution (m : cell_state array array)
    (row_clues : clue array) (col_clues : clue array) : t =
  (* Build Puzzle.t by creating puzzle and filling all cells from matrix *)
  let size = Array.length m in
  let puzzle = create ~size ~row_clues ~col_clues in
  Array.foldi m ~init:puzzle ~f:(fun x acc row ->
      Array.foldi row ~init:acc ~f:(fun y p state ->
          set p { x; y } state))

let puzzle_matches_matrix (p : t) (m : cell_state array array) : bool =
  (* Verify puzzle matches solution matrix cell-by-cell *)
  let size = Array.length m in
  let matches =
    Array.for_alli m ~f:(fun x row ->
        Array.for_alli row ~f:(fun y state ->
            let actual = Puzzle.get p { x; y } in
            phys_equal actual state))
  in
  if size <> Puzzle.size p then false else matches

let max_attempts = 100

let generate (params : generation_params) : generation_result =
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
          | Solver.NoSolution -> attempt (n - 1)
          | Solver.PartialSolution _ -> attempt (n - 1)
          | Solver.MultipleSolutions _ -> attempt (n - 1)
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