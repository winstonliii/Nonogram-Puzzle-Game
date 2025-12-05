open Core
open Puzzle

type error =
  | RowError of int * string
  | ColError of int * string

type validation_result =
  | Valid
  | Incomplete
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

let clues_equal (RLE a) (RLE b) = List.equal Int.equal a b

let validate (p : t) : validation_result =
  let n = size p in
  let has_unknown = ref false in
  let errors = ref [] in

  (* rows *)
  for r = 0 to n - 1 do
    let row_cells = rows p r in
    if List.exists row_cells ~f:(fun c -> phys_equal c Unknown) then
      has_unknown := true;
    let derived = clue_of_cells row_cells in
    let expected = row_clue p r in
    if not (clues_equal derived expected) then
      errors := RowError (r, "Row does not match its clue") :: !errors
  done;

  (* cols *)
  for c = 0 to n - 1 do
    let col_cells = cols p c in
    if List.exists col_cells ~f:(fun c -> phys_equal c Unknown) then
      has_unknown := true;
    let derived = clue_of_cells col_cells in
    let expected = col_clue p c in
    if not (clues_equal derived expected) then
      errors := ColError (c, "Column does not match its clue") :: !errors
  done;

  match !errors, !has_unknown with
  | [], false -> Valid
  | [], true -> Incomplete
  | errs, _ -> Invalid (List.rev errs)
