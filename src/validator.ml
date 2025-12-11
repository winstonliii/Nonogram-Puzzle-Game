open Core
open Puzzle

type error =
  | RowError of int * string
  | ColError of int * string

type validation_result =
  | Valid      (* All cells filled AND all clues match *)
  | Incomplete (* Grid has unknown cells but no clue mismatches yet *)
  | Invalid of error list

let clue_of_cells (cells : cell_state list) : clue =
  let rec aux acc current = function
    | [] ->
        let acc =
          match current with
          | 0 -> acc
          | n -> n :: acc
        in
        List.rev acc
    | Filled :: tl ->
        aux acc (current + 1) tl
    | (Empty | Unknown) :: tl ->
        let acc =
          match current with
          | 0 -> acc
          | n -> n :: acc
        in
        aux acc 0 tl
  in
  RLE (aux [] 0 cells)

let clues_equal (RLE a) (RLE b) =
  List.equal Int.equal a b

let has_unknown_cells (cells : cell_state list) : bool =
  List.exists cells ~f:(function
    | Unknown -> true
    | _ -> false)

(* Validate puzzle by deriving clues from current grid state
   and comparing against expected clues.
 *)
let validate (p : t) : validation_result =
  let check_dim fold_lines clue_at mk_error =
    fold_lines p ~init:(false, [])
      ~f:(fun (has_unk, errs) i cells ->
        let has_unk' = has_unk || has_unknown_cells cells in
        let derived = clue_of_cells cells in
        let expected = clue_at p i in
        let errs' =
          if clues_equal derived expected then errs
          else mk_error i :: errs
        in
        (has_unk', errs'))
  in

  let row_has_unknown, row_errors =
    check_dim
      fold_rows
      row_clue
      (fun i -> RowError (i, "Row does not match its clue"))
  in
  let col_has_unknown, col_errors =
    check_dim
      fold_cols
      col_clue
      (fun i -> ColError (i, "Column does not match its clue"))
  in

  let has_any_unknown = row_has_unknown || col_has_unknown in
  let all_errors = List.rev_append row_errors col_errors in

  match all_errors, has_any_unknown with
  | [], false -> Valid
  | [], true -> Incomplete
  | errs, _ -> Invalid errs
