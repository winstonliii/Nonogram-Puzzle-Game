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

let has_unknown_cells (cells : cell_state list) : bool =
  List.exists cells ~f:(function
    | Unknown -> true
    | _ -> false)

let compare_state (a1, b1) (a2, b2) =
  match Int.compare a1 a2 with
  | 0 -> Int.compare b1 b2
  | c -> c

let next_states_for_symbol (runs : int list) (j, k) (symbol : [ `E | `F ]) : (int * int) list =
  match symbol with
  | `E ->
      if Int.equal k 0 then
        [ (j, 0) ]
      else
        (match List.nth runs j with
         | Some len when Int.equal k len -> [ (j + 1, 0) ]
         | _ -> [])
  | `F ->
      (match List.nth runs j with
       | Some len when k < len -> [ (j, k + 1) ]
       | _ -> [])

let line_satisfiable (cells : cell_state list) (RLE runs : clue) : bool =
  let runs_len = List.length runs in
  let step states cell =
    let symbols =
      match cell with
      | Empty -> [ `E ]
      | Filled -> [ `F ]
      | Unknown -> [ `E; `F ]
    in
    List.concat_map states ~f:(fun st ->
      List.concat_map symbols ~f:(fun sym -> next_states_for_symbol runs st sym))
    |> List.dedup_and_sort ~compare:compare_state
  in
  let accepting (j, k) =
    if Int.equal k 0 then
      Int.equal j runs_len
    else
      match List.nth runs j with
      | Some len -> Int.equal k len && Int.equal j (runs_len - 1)
      | None -> false
  in
  List.fold cells ~init:[ (0, 0) ] ~f:step |> List.exists ~f:accepting

let validate (p : t) : validation_result =
  let check_dim fold_lines clue_at mk_error =
    fold_lines p ~init:(false, []) ~f:(fun (has_unk, errs) i cells ->
      let has_unk' = has_unk || has_unknown_cells cells in
      let expected = clue_at p i in
      let errs' =
        if line_satisfiable cells expected then errs
        else mk_error i :: errs
      in
      (has_unk', errs'))
  in
  let row_has_unknown, row_errors =
    check_dim fold_rows row_clue (fun i -> RowError (i, "Row contradicts its clue"))
  in
  let col_has_unknown, col_errors =
    check_dim fold_cols col_clue (fun i -> ColError (i, "Column contradicts its clue"))
  in
  let has_any_unknown = row_has_unknown || col_has_unknown in
  let all_errors = List.rev_append row_errors col_errors in
  match all_errors, has_any_unknown with
  | [], false -> Valid
  | [], true -> Incomplete
  | errs, _ -> Invalid errs
