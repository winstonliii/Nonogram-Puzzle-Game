open OUnit2
open Nonogram

(* Puzzle Tests *)
module Puzzle_tests = struct
  let make_puzzle () =
    let size = 2 in
    let row_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    let col_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    Puzzle.create ~size ~row_clues ~col_clues
  ;;

  let test_size _ =
    let p = make_puzzle () in
    assert_equal 2 (Puzzle.size p)
  ;;

  let test_get_unknown_initially _ =
    let p = make_puzzle () in
    assert_equal Puzzle.Unknown (Puzzle.get p { x = 0; y = 0 })
  ;;

  let test_set_and_get _ =
    let p = make_puzzle () in
    let p2 = Puzzle.set p { x = 1; y = 1 } Puzzle.Filled in
    assert_equal Puzzle.Filled (Puzzle.get p2 { x = 1; y = 1 })
  ;;

  let test_rows _ =
    let p = make_puzzle () in
    let p1 = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    let row = Puzzle.rows p1 0 in
    assert_equal [Puzzle.Filled; Puzzle.Unknown] row
  ;;

  let test_cols _ =
    let p = make_puzzle () in
    let p1 = Puzzle.set p { x = 0; y = 1 } Puzzle.Empty in
    let col = Puzzle.cols p1 0 in
    assert_equal [Puzzle.Unknown; Puzzle.Empty] col
  ;;

  let series =
    "Puzzle tests" >::: 
    [ "size" >:: test_size
    ; "initially unknown" >:: test_get_unknown_initially
    ; "set and get" >:: test_set_and_get
    ; "rows simple" >:: test_rows
    ; "cols simple" >:: test_cols
    ]
end


(* Game Tests *)
module Game_tests = struct
  let make_game () =
    let size = 2 in
    let row_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    let col_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    let p = Puzzle.create ~size ~row_clues ~col_clues in
    Game.create p
  ;;

  let test_initial_status _ =
    let g = make_game () in
    assert_equal Game.InProgress (Game.status g)
  ;;

  let test_fill_cell_updates_puzzle _ =
    let g = make_game () in
    let pos : Puzzle.position = { x = 0; y = 0 } in
    match Game.process_action g (Game.FillCell pos) with
    | Game.Success g2 ->
        let p2 = Game.puzzle g2 in
        assert_equal Puzzle.Filled (Puzzle.get p2 pos)
    | _ ->
        assert_failure "expected Success from FillCell"
  ;;

  let series =
    "Game tests" >::: 
    [ "initial status" >:: test_initial_status
    ; "fill cell changes board" >:: test_fill_cell_updates_puzzle
    ]
end


(* Generator Tests *)
module Generator_tests = struct
  let test_generate_non_square_failure _ =
    let params = Generator.{ rows = 5; cols = 7 } in
    match Generator.generate params with
    | Generator.Failure _ -> ()
    | Generator.Success _ ->
        assert_failure "Expected non-square dimensions to be rejected"
  ;;

  let test_generate_unsupported_size_failure _ =
    let params = Generator.{ rows = 7; cols = 7 } in
    match Generator.generate params with
    | Generator.Failure _ -> ()
    | Generator.Success _ ->
        assert_failure "Expected unsupported size to be rejected"
  ;;


  let test_generate_supported_size_invariants _ =
    let params = Generator.{ rows = 5; cols = 5 } in
    match Generator.generate params with
    | Generator.Failure _ ->
        ()
    | Generator.Success (solution, puzzle) ->
        let n = Puzzle.size puzzle in
        assert_equal n (Puzzle.size solution);
        for i = 0 to n - 1 do
          assert_equal
            (Puzzle.row_clue solution i)
            (Puzzle.row_clue puzzle i);
          assert_equal
            (Puzzle.col_clue solution i)
            (Puzzle.col_clue puzzle i)
        done;
        (match Validator.validate solution with
         | Validator.Valid -> ()
         | Validator.Incomplete ->
             assert_failure "Generated solution should not be incomplete"
         | Validator.Invalid _ ->
             assert_failure "Generated solution should be valid")
  ;;

  let series =
    "Generator tests" >::: 
    [ "non-square dimensions rejected" >:: test_generate_non_square_failure
    ; "unsupported size rejected" >:: test_generate_unsupported_size_failure
    ; "supported size invariants (if generation succeeds)"
      >:: test_generate_supported_size_invariants
    ]
end


(* Validator Tests *)
module Validator_tests = struct
  let make_2x2_puzzle () =
    let size = 2 in
    let row_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    let col_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    Puzzle.create ~size ~row_clues ~col_clues
  ;;

  let fill_valid_solution p =
    let p = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    let p = Puzzle.set p { x = 1; y = 0 } Puzzle.Empty in
    let p = Puzzle.set p { x = 0; y = 1 } Puzzle.Empty in
    let p = Puzzle.set p { x = 1; y = 1 } Puzzle.Filled in
    p
  ;;

  let test_validator_valid _ =
    let p = make_2x2_puzzle () |> fill_valid_solution in
    match Validator.validate p with
    | Validator.Valid -> ()
    | _ ->
        assert_failure "Expected a fully correct puzzle to be Valid"
  ;;

  let test_validator_incomplete _ =
    let p = make_2x2_puzzle () in
    let p = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    match Validator.validate p with
    | Validator.Incomplete -> ()
    | _ ->
        assert_failure "Expected partially filled puzzle to be Incomplete"
  ;;

  let test_validator_row_error _ =
    let p = make_2x2_puzzle () in
    let p = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    let p = Puzzle.set p { x = 1; y = 0 } Puzzle.Filled in
    match Validator.validate p with
    | Validator.Invalid [ Validator.RowError (0, _) ] -> ()
    | Validator.Invalid _ ->
        assert_failure "Expected exactly one RowError on row 0"
    | Validator.Valid | Validator.Incomplete ->
        assert_failure "Expected row violation to be Invalid"
  ;;

  let test_validator_col_error _ =
    let p = make_2x2_puzzle () in
    let p = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    let p = Puzzle.set p { x = 0; y = 1 } Puzzle.Filled in
    match Validator.validate p with
    | Validator.Invalid [ Validator.ColError (0, _) ] -> ()
    | Validator.Invalid _ ->
        assert_failure "Expected exactly one ColError on column 0"
    | Validator.Valid | Validator.Incomplete ->
        assert_failure "Expected column violation to be Invalid"
  ;;

  let series =
    "Validator tests" >::: 
    [ "valid puzzle" >:: test_validator_valid
    ; "incomplete puzzle" >:: test_validator_incomplete
    ; "row error" >:: test_validator_row_error
    ; "column error" >:: test_validator_col_error
    ]
end


(* Solver Tests *)
module Solver_tests = struct
  let string_of_cell = function
    | Puzzle.Empty -> "."
    | Puzzle.Filled -> "#"
    | Puzzle.Unknown -> "?"
  ;;

  let string_of_cells cells =
    String.concat "" (List.map string_of_cell cells)
  ;;

  let test_solve_line_full_block _ =
    let line =
      Solver.Line [ Puzzle.Unknown; Puzzle.Unknown; Puzzle.Unknown ]
    in
    let Solver.Line cells = Solver.solve_line (Puzzle.RLE [3]) line in
    assert_equal
      ~printer:string_of_cells
      [ Puzzle.Filled; Puzzle.Filled; Puzzle.Filled ]
      cells
  ;;

  let test_solve_line_center_forced _ =
    let line =
      Solver.Line
        [ Puzzle.Unknown
        ; Puzzle.Unknown
        ; Puzzle.Unknown
        ; Puzzle.Unknown
        ; Puzzle.Unknown
        ]
    in
    let Solver.Line cells = Solver.solve_line (Puzzle.RLE [3]) line in
    assert_equal
      ~printer:string_of_cells
      [ Puzzle.Unknown
      ; Puzzle.Unknown
      ; Puzzle.Filled
      ; Puzzle.Unknown
      ; Puzzle.Unknown
      ]
      cells
  ;;

  let test_solve_line_respects_known_cells _ =
    let line =
      Solver.Line [ Puzzle.Empty; Puzzle.Unknown; Puzzle.Unknown ]
    in
    let Solver.Line cells = Solver.solve_line (Puzzle.RLE [1]) line in
    assert_equal
      ~printer:string_of_cells
      [ Puzzle.Empty; Puzzle.Unknown; Puzzle.Unknown ]
      cells
  ;;

  let make_cross_puzzle () =
    let size = 3 in
    let r1 = Puzzle.RLE [1] in
    let r3 = Puzzle.RLE [3] in
    let row_clues = [| r1; r3; r1 |] in
    let col_clues = [| r1; r3; r1 |] in
    Puzzle.create ~size ~row_clues ~col_clues
  ;;

  let expected_cross =
    [|
      [| Puzzle.Empty; Puzzle.Filled; Puzzle.Empty |];
      [| Puzzle.Filled; Puzzle.Filled; Puzzle.Filled |];
      [| Puzzle.Empty; Puzzle.Filled; Puzzle.Empty |];
    |]
  ;;

  let test_solver_solves_cross _ =
    let puzzle = make_cross_puzzle () in
    match Solver.solve puzzle with
    | Solver.Solved solved ->
        (match Validator.validate solved with
         | Validator.Valid -> ()
         | _ ->
             assert_failure "Solver produced a solution that validator rejects");
        let n = Puzzle.size solved in
        assert_equal 3 n;
        for y = 0 to n - 1 do
          for x = 0 to n - 1 do
            let expected = expected_cross.(y).(x) in
            let actual = Puzzle.get solved { x; y } in
            if expected <> actual then
              assert_failure
                (Printf.sprintf "Unexpected cell at (%d,%d)" x y)
          done
        done
    | Solver.NoSolution ->
        assert_failure "Expected cross puzzle to have a solution"
    | Solver.PartialSolution _ ->
        assert_failure "Expected a full solution, not partial"
    | Solver.MultipleSolutions _ ->
        assert_failure "Expected unique solution, not multiple"
  ;;

  let series =
    "Solver tests" >::: 
    [ "solve_line full block" >:: test_solve_line_full_block
    ; "solve_line center forced" >:: test_solve_line_center_forced
    ; "solve_line respects known cells" >:: test_solve_line_respects_known_cells
    ; "solver solves 3x3 cross puzzle" >:: test_solver_solves_cross
    ]
end


let suite =
  "All tests" >::: [
    Puzzle_tests.series;
    Game_tests.series;
    Generator_tests.series;
    Validator_tests.series;
    Solver_tests.series;
  ]

let () =
  run_test_tt_main suite
