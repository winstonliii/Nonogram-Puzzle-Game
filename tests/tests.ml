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

  let test_check_solution_incomplete _ =
    let g = make_game () in
    match Game.process_action g Game.CheckSolution with
    | Game.Error Game.IncompletePuzzle -> ()
    | _ ->
        assert_failure "expected IncompletePuzzle error"
  ;;

  let series =
    "Game tests" >::: 
    [ "initial status" >:: test_initial_status
    ; "fill cell changes board" >:: test_fill_cell_updates_puzzle
    ; "check solution incomplete" >:: test_check_solution_incomplete
    ]
end

let suite =
  "All tests" >::: [
    Puzzle_tests.series;
    Game_tests.series;
  ]

let () =
  run_test_tt_main suite