open Core
open Puzzle

type solve_result =
  | Solved of t (*found exactly one full solution*)
  | NoSolution 
  | MultipleSolutions of t list (*solver found at least 2 distinct solutions*)

type line = Line of cell_state list [@@unboxed]


let compatible_line (known : cell_state list) (candidate : cell_state list) : bool =
  List.zip_exn known candidate
  |> List.for_all ~f:(fun (k, c) ->
         match k with
         | Unknown -> true
         | Filled -> phys_equal c Filled
         | Empty -> phys_equal c Empty)

let build_candidate (len : int) (segments : (int * int) list)
  : cell_state list =
  List.init len ~f:(fun j ->
    if List.exists segments ~f:(fun (s, e) -> j >= s && j <= e)
    then Filled
    else Empty)

let all_placements (RLE runs : clue) (known : cell_state list)
  : cell_state list list =
  let len = List.length known in
  match runs with
  | [] ->
      let candidate = List.init len ~f:(fun _ -> Empty) in
      if compatible_line known candidate then [ candidate ] else []
  | _ ->
      let rec min_len = function
        | [] -> 0
        | [ x ] -> x
        | x :: xs -> x + 1 + min_len xs
      in
      let rec place runs i segments =
        match runs with
        | [] ->
            let candidate = build_candidate len segments in
            if compatible_line known candidate then [ candidate ] else []
        | run_len :: rest ->
            let remaining_min = min_len rest in
            let max_start = len - remaining_min - run_len in
            let rec try_start s =
              if s > max_start then []
              else
                let segments' = (s, s + run_len - 1) :: segments in
                let here = place rest (s + run_len + 1) segments' in
                let more = try_start (s + 1) in
                here @ more
            in
            try_start i
      in
      place runs 0 []


let intersect_placements (placements : cell_state list list)
  : cell_state list =
  match placements with
  | [] -> []
  | first :: rest ->
      List.fold rest ~init:first ~f:(fun acc p ->
        List.map2_exn acc p ~f:(fun a b ->
          if phys_equal a b then a else Unknown))


let solve_line clue (Line cells as line) : line =
  let placements = all_placements clue cells in
  match placements with
  | [] -> line
  | [ single ] -> Line single
  | many -> Line (intersect_placements many)

let propagate_once (p : t)
  : [ `Ok of t * bool | `Contradiction ] =
  let row_result =
    fold_rows p
      ~init:(`Ok (p, false))
      ~f:(fun acc r row_cells ->
        match acc with
        | `Contradiction -> `Contradiction
        | `Ok (p_acc, changed_acc) ->
            let clue = row_clue p_acc r in
            let placements = all_placements clue row_cells in
            if List.is_empty placements then
              `Contradiction
            else
              let Line new_row = solve_line clue (Line row_cells) in
              let p', changed_row =
                List.foldi new_row ~init:(p_acc, false)
                  ~f:(fun x (p_grid, chg) new_c ->
                    let pos = Position.{ x; y = r } in
                    let old_c = get p_grid pos in
                    if phys_equal old_c new_c then
                      (p_grid, chg)
                    else
                      (set p_grid pos new_c, true))
              in
              `Ok (p', changed_acc || changed_row))
  in
  match row_result with
  | `Contradiction -> `Contradiction
  | `Ok (p_after_rows, changed_rows) ->
      let col_result =
        fold_cols p_after_rows
          ~init:(`Ok (p_after_rows, changed_rows))
          ~f:(fun acc c col_cells ->
            match acc with
            | `Contradiction -> `Contradiction
            | `Ok (p_acc, changed_acc) ->
                let clue = col_clue p_acc c in
                let placements = all_placements clue col_cells in
                if List.is_empty placements then
                  `Contradiction
                else
                  let Line new_col = solve_line clue (Line col_cells) in
                  let p', changed_col =
                    List.foldi new_col ~init:(p_acc, false)
                      ~f:(fun y (p_grid, chg) new_c ->
                        let pos = Position.{ x = c; y } in
                        let old_c = get p_grid pos in
                        if phys_equal old_c new_c then
                          (p_grid, chg)
                        else
                          (set p_grid pos new_c, true))
                  in
                  `Ok (p', changed_acc || changed_col))
      in
      col_result

let rec propagate (p : t) : [ `Ok of t | `Contradiction ] =
  match propagate_once p with
  | `Contradiction -> `Contradiction
  | `Ok (p', changed) ->
      if changed then propagate p' else `Ok p'


let has_unknown (p : t) : bool =
  fold_rows p ~init:false
    ~f:(fun acc _ row_cells ->
      acc
      || List.exists row_cells ~f:(fun c -> phys_equal c Unknown))

let choose_unknown (p : t) : position option =
  let n = size p in
  let rec find_row y =
    if y = n then None
    else
      let row = rows p y in
      match List.findi row ~f:(fun _ c -> phys_equal c Unknown) with
      | Some (x, _) -> Some Position.{ x; y }
      | None -> find_row (y + 1)
  in
  find_row 0


let solve (p0 : t) : solve_result =
  let max_solutions = 2 in
  let rec search (p : t) (solutions : t list) : t list =
    if List.length solutions >= max_solutions then
      solutions
    else
      match propagate p with
      | `Contradiction -> solutions
      | `Ok p' ->
          if not (has_unknown p') then
            p' :: solutions
          else
            match choose_unknown p' with
            | None ->
                solutions
            | Some pos ->
                let solutions_after_filled =
                  search (set p' pos Filled) solutions
                in
                if List.length solutions_after_filled >= max_solutions then
                  solutions_after_filled
                else
                  search (set p' pos Empty) solutions_after_filled
  in
  let solutions = search p0 [] in
  match solutions with
  | [] -> NoSolution
  | [ s ] -> Solved s
  | s1 :: s2 :: _ -> MultipleSolutions [ s1; s2 ]
