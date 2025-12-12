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

  let test_row_and_col_clues _ =
    let p = make_puzzle () in
    assert_equal (Puzzle.RLE [1]) (Puzzle.row_clue p 0);
    assert_equal (Puzzle.RLE [1]) (Puzzle.col_clue p 1)
  ;;

  let test_fold_rows_counts_cells _ =
    let p = make_puzzle () in
    let total_cells =
      Puzzle.fold_rows p ~init:0 ~f:(fun acc _ row ->
        acc + List.length row)
    in
    assert_equal 4 total_cells
  ;;

  let series =
    "Puzzle tests" >::: 
    [ "size" >:: test_size
    ; "initially unknown" >:: test_get_unknown_initially
    ; "set and get" >:: test_set_and_get
    ; "rows simple" >:: test_rows
    ; "cols simple" >:: test_cols
    ; "clues" >:: test_row_and_col_clues
    ; "fold_rows counts cells" >:: test_fold_rows_counts_cells
    ]
end


(* Game Tests *)
module Game_tests = struct
  let make_game () =
    let size = 2 in
    let row_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    let col_clues = [| Puzzle.RLE [1]; Puzzle.RLE [1] |] in
    let p = Puzzle.create ~size ~row_clues ~col_clues in
    let s =
      let p1 = Puzzle.set p { x = 0; y = 0 } Puzzle.Empty in
      let p2 = Puzzle.set p1 { x = 1; y = 0 } Puzzle.Empty in
      let p3 = Puzzle.set p2 { x = 0; y = 1 } Puzzle.Empty in
      let p4 = Puzzle.set p3 { x = 1; y = 1 } Puzzle.Empty in
      p4
    in
    Game.create_with_solution p s
  ;;

  let test_initial_status _ =
    let g = make_game () in
    assert_equal Game.InProgress (Game.status g)
  ;;

  let test_fill_cell_updates_puzzle _ =
    let g = make_game () in
    let pos : Puzzle.position = { x = 0; y = 0 } in
    match Game.process_action g (Game.UpdateCell { pos; new_state = Puzzle.Filled }) with
    | Game.Success g2 ->
        let p2 = Game.puzzle g2 in
        assert_equal Puzzle.Filled (Puzzle.get p2 pos)
    | _ ->
        assert_failure "expected Success from FillCell"
  ;;

  let test_other_actions_update_and_reset _ =
    let g0 = make_game () in
    let pos : Puzzle.position = { x = 1; y = 1 } in
  
    let g1 =
      match Game.process_action g0 (Game.UpdateCell { pos; new_state = Puzzle.Empty }) with
      | Game.Success g' -> g'
      | _ -> assert_failure "mark empty failed"
    in
    assert_equal Puzzle.Empty (Puzzle.get (Game.puzzle g1) pos);
  
    let g2 =
      match Game.process_action g1 (Game.UpdateCell { pos; new_state = Puzzle.Unknown }) with
      | Game.Success g' -> g'
      | _ -> assert_failure "clear failed"
    in
    assert_equal Puzzle.Unknown (Puzzle.get (Game.puzzle g2) pos);  
  
    let g3 =
      match Game.process_action g2 Game.RestartPuzzle with
      | Game.Success g' -> g'
      | _ -> assert_failure "restart failed"
    in
    assert_equal Puzzle.Unknown (Puzzle.get (Game.puzzle g3) pos);
  
    let g4 =
      match Game.process_action g3 Game.Quit with
      | Game.Success g' -> g'
      | _ -> assert_failure "quit failed"
    in
    assert_equal Puzzle.Unknown (Puzzle.get (Game.puzzle g4) pos)
  ;;
  
  let test_check_incomplete_ok _ =
    let size = 2 in
    let row_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let col_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let p = Puzzle.create ~size ~row_clues ~col_clues in
    let s =
      let p1 = Puzzle.set p { x = 0; y = 0 } Puzzle.Empty in
      let p2 = Puzzle.set p1 { x = 1; y = 0 } Puzzle.Empty in
      let p3 = Puzzle.set p2 { x = 0; y = 1 } Puzzle.Empty in
      let p4 = Puzzle.set p3 { x = 1; y = 1 } Puzzle.Empty in
      p4
    in
    let g = Game.create_with_solution p s in
    match Game.check g with
    | Game.Success _ -> ()
    | _ -> assert_failure "expected check to return Success on incomplete but consistent puzzle"
  ;;

  let test_check_reports_win _ =
    let size = 2 in
    let row_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let col_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let p = Puzzle.create ~size ~row_clues ~col_clues in
    let s =
      let p1 = Puzzle.set p { x = 0; y = 0 } Puzzle.Empty in
      let p2 = Puzzle.set p1 { x = 1; y = 0 } Puzzle.Empty in
      let p3 = Puzzle.set p2 { x = 0; y = 1 } Puzzle.Empty in
      let p4 = Puzzle.set p3 { x = 1; y = 1 } Puzzle.Empty in
      p4
    in
    let g = Game.create_with_solution s s in
    match Game.check g with
    | Game.GameWon win ->
        assert_equal 0 win.num_hints
    | _ ->
        assert_failure "expected check to report GameWon when puzzle matches solution"
  ;;

  let test_check_detects_contradiction _ =
    let size = 2 in
    let row_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let col_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let base = Puzzle.create ~size ~row_clues ~col_clues in
    let solution =
      let p1 = Puzzle.set base { x = 0; y = 0 } Puzzle.Filled in
      p1
    in
    let puzzle_wrong =
      let p1 = Puzzle.set base { x = 0; y = 0 } Puzzle.Empty in
      p1
    in
    let g = Game.create_with_solution puzzle_wrong solution in
    match Game.check g with
    | Game.Error (Game.Contradiction _) -> ()
    | _ -> assert_failure "expected check to detect a contradiction"
  ;;

  let test_hint_changes_one_cell_and_increments_counter _ =
    let size = 2 in
    let row_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let col_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let p = Puzzle.create ~size ~row_clues ~col_clues in
    let s =
      let p1 = Puzzle.set p { x = 0; y = 0 } Puzzle.Empty in
      let p2 = Puzzle.set p1 { x = 1; y = 0 } Puzzle.Empty in
      let p3 = Puzzle.set p2 { x = 0; y = 1 } Puzzle.Empty in
      let p4 = Puzzle.set p3 { x = 1; y = 1 } Puzzle.Empty in
      p4
    in
    let g = Game.create_with_solution p s in
    match Game.hint g with
    | Game.HintProvided (_pos, _state, g') ->
        assert_equal 1 (Game.hints_used g');
        let p' = Game.puzzle g' in
        let cells =
          [ Puzzle.get p' { x = 0; y = 0 }
          ; Puzzle.get p' { x = 1; y = 0 }
          ; Puzzle.get p' { x = 0; y = 1 }
          ; Puzzle.get p' { x = 1; y = 1 }
          ]
        in
        let non_unknown =
          List.fold_left
            (fun acc c -> if c = Puzzle.Unknown then acc else acc + 1)
            0
            cells
        in
        assert_equal 1 non_unknown
    | _ ->
        assert_failure "expected HintProvided from hint"
  ;;

  let test_autosolve_sets_puzzle_and_status _ =
    let size = 2 in
    let row_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let col_clues = [| Puzzle.RLE []; Puzzle.RLE [] |] in
    let p = Puzzle.create ~size ~row_clues ~col_clues in
    let s =
      let p1 = Puzzle.set p { x = 0; y = 0 } Puzzle.Empty in
      let p2 = Puzzle.set p1 { x = 1; y = 0 } Puzzle.Empty in
      let p3 = Puzzle.set p2 { x = 0; y = 1 } Puzzle.Empty in
      let p4 = Puzzle.set p3 { x = 1; y = 1 } Puzzle.Empty in
      p4
    in
    let g = Game.create_with_solution p s in
    match Game.autosolve g with
    | Game.Success g' ->
        assert_equal Game.Won (Game.status g');
        let p' = Game.puzzle g' in
        assert_equal Puzzle.Empty (Puzzle.get p' { x = 0; y = 0 });
        assert_equal Puzzle.Empty (Puzzle.get p' { x = 1; y = 0 });
        assert_equal Puzzle.Empty (Puzzle.get p' { x = 0; y = 1 });
        assert_equal Puzzle.Empty (Puzzle.get p' { x = 1; y = 1 })
    | _ ->
        assert_failure "expected autosolve to return Success"
  ;;

  let series =
    "Game tests" >::: 
    [ "initial status" >:: test_initial_status
    ; "fill cell changes board" >:: test_fill_cell_updates_puzzle
    ; "other actions update and reset" >:: test_other_actions_update_and_reset
    ; "check incomplete ok" >:: test_check_incomplete_ok
    ; "check reports win" >:: test_check_reports_win
    ; "check detects contradiction" >:: test_check_detects_contradiction
    ; "hint changes one cell and increments counter" >:: test_hint_changes_one_cell_and_increments_counter
    ; "autosolve sets puzzle and status" >:: test_autosolve_sets_puzzle_and_status
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
    | Validator.Incomplete
    | Validator.Invalid _ -> ()  
    | Validator.Valid ->
        assert_failure "Expected a partially filled puzzle not to be Valid"
  ;;

  let test_validator_row_error _ =
    let p = make_2x2_puzzle () in
    let p = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    let p = Puzzle.set p { x = 1; y = 0 } Puzzle.Filled in
    match Validator.validate p with
    | Validator.Invalid errs ->
        let has_row0 =
          List.exists (function
            | Validator.RowError (0, _) -> true
            | _ -> false) errs
        in
        if not has_row0 then
          assert_failure "Expected at least one RowError on row 0"
    | Validator.Valid | Validator.Incomplete ->
        assert_failure "Expected row violation to be Invalid"
  ;;  

  let test_validator_col_error _ =
    let p = make_2x2_puzzle () in
    let p = Puzzle.set p { x = 0; y = 0 } Puzzle.Filled in
    let p = Puzzle.set p { x = 0; y = 1 } Puzzle.Filled in
    match Validator.validate p with
    | Validator.Invalid errs ->
        let has_col0 =
          List.exists (function
            | Validator.ColError (0, _) -> true
            | _ -> false) errs
        in
        if not has_col0 then
          assert_failure "Expected at least one ColError on column 0"
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


(* Grid Tests *)
module Grid_tests = struct
  let make_grid () =
    Grid.create ~size:2 ~init:(fun _ -> 0)
  ;;

  let test_size _ =
    let g = make_grid () in
    assert_equal 2 (Grid.size g)
  ;;

  let test_get_initial_values _ =
    let g = make_grid () in
    assert_equal 0 (Grid.get g Position.{ x = 0; y = 0 });
    assert_equal 0 (Grid.get g Position.{ x = 1; y = 0 });
    assert_equal 0 (Grid.get g Position.{ x = 0; y = 1 });
    assert_equal 0 (Grid.get g Position.{ x = 1; y = 1 })
  ;;

  let test_set_only_changes_one_cell _ =
    let g = make_grid () in
    let pos = Position.{ x = 1; y = 0 } in
    let g2 = Grid.set g pos 42 in
    assert_equal 42 (Grid.get g2 pos);
    assert_equal 0 (Grid.get g2 Position.{ x = 0; y = 0 })
  ;;

  let test_rows_and_cols_match_layout _ =
    let g = make_grid () in
    let g = Grid.set g Position.{ x = 0; y = 0 } 1 in
    let g = Grid.set g Position.{ x = 1; y = 0 } 2 in
    let g = Grid.set g Position.{ x = 0; y = 1 } 3 in
    let g = Grid.set g Position.{ x = 1; y = 1 } 4 in

    assert_equal [1; 2] (Grid.rows g 0);
    assert_equal [3; 4] (Grid.rows g 1);
    assert_equal [1; 3] (Grid.cols g 0);
    assert_equal [2; 4] (Grid.cols g 1)
  ;;

  let test_fold_rows_and_cols _ =
    let g = make_grid () in
    let g = Grid.set g Position.{ x = 0; y = 0 } 1 in
    let g = Grid.set g Position.{ x = 1; y = 0 } 2 in
    let g = Grid.set g Position.{ x = 0; y = 1 } 3 in
    let g = Grid.set g Position.{ x = 1; y = 1 } 4 in

    let sum_rows =
      Grid.fold_rows g ~init:0 ~f:(fun acc _ row ->
        List.fold_left ( + ) acc row)
    in
    let sum_cols =
      Grid.fold_cols g ~init:0 ~f:(fun acc _ col ->
        List.fold_left ( + ) acc col)
    in

    assert_equal 10 sum_rows;
    assert_equal 10 sum_cols
  ;;

  let series =
    "Grid tests" >::: 
    [ "size" >:: test_size
    ; "initial values" >:: test_get_initial_values
    ; "set only one cell" >:: test_set_only_changes_one_cell
    ; "rows and cols" >:: test_rows_and_cols_match_layout
    ; "fold rows and cols" >:: test_fold_rows_and_cols
    ]
end


(* Position Tests *)
module Position_tests = struct
  let test_equality _ =
    let p1 = Position.{ x = 1; y = 2 } in
    let p2 = Position.{ x = 1; y = 2 } in
    assert_equal p1 p2
  ;;

  let test_compare_order _ =
    let p_left  = Position.{ x = 0; y = 0 } in
    let p_right = Position.{ x = 1; y = 0 } in
    assert_bool "p_left should come before p_right"
      (Position.compare p_left p_right < 0)
  ;;
  let test_sexp_of_t_called _ =
    let p = Position.{ x = 2; y = 3 } in
    let _ = Position.sexp_of_t p in
    ()
  ;;

  let series =
    "Position tests" >::: 
    [ "equality" >:: test_equality
    ; "compare order" >:: test_compare_order
    ; "sexp_of_t called" >:: test_sexp_of_t_called
    ]
end


let suite =
  "All tests" >::: [
    Puzzle_tests.series;
    Game_tests.series;
    Generator_tests.series;
    Validator_tests.series;
    Solver_tests.series;
    Grid_tests.series;
    Position_tests.series;
  ]

let () =
  run_test_tt_main suite
