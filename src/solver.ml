open Core
open Puzzle

type solve_result =
  | Solved of t
  | NoSolution
  | PartialSolution of t
  | MultipleSolutions of t list

type line = Line of cell_state list [@@unboxed]


let compatible_line (known : cell_state list) (candidate : cell_state list) : bool =
  List.zip_exn known candidate
  |> List.for_all ~f:(fun (k, c) ->
         match k with
         | Unknown -> true
         | Filled -> phys_equal c Filled
         | Empty -> phys_equal c Empty)


let all_placements (RLE runs : clue) (known : cell_state list) :
    cell_state list list =
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
      let rec place runs i acc =
        match runs with
        | [] ->
            let line = Array.create ~len Empty in
            List.iter acc ~f:(fun (s, e) ->
                for j = s to e do
                  line.(j) <- Filled
                done);
            let candidate = Array.to_list line in
            if compatible_line known candidate then [ candidate ] else []
        | run_len :: rest ->
            let remaining_min = min_len rest in
            let max_start = len - remaining_min - run_len in
            let rec try_start s =
              if s > max_start then []
              else
                let acc' = (s, s + run_len - 1) :: acc in
                let here = place rest (s + run_len + 1) acc' in
                let more = try_start (s + 1) in
                here @ more
            in
            try_start i
      in
      place runs 0 []

let intersect_placements (placements : cell_state list list) : cell_state list =
  match placements with
  | [] -> []
  | first :: rest ->
      let arr = Array.of_list first in
      List.iter rest ~f:(fun p ->
          List.iteri p ~f:(fun i c ->
              if not (phys_equal arr.(i) c) then arr.(i) <- Unknown));
      Array.to_list arr

let solve_line clue (Line cells as line) : line =
  let placements = all_placements clue cells in
  match placements with
  | [] ->
      line
  | [ single ] ->
      Line single
  | many ->
      Line (intersect_placements many)

let propagate (p0 : t) :
    [ `Ok of t | `Contradiction ] =
  let n = size p0 in
  let rec step p =
    let changed = ref false in
    let ok = ref true in
    let p_ref = ref p in

    for r = 0 to n - 1 do
      if !ok then (
        let row_cells = rows !p_ref r in
        let clue = row_clue !p_ref r in
        let placements = all_placements clue row_cells in
        if List.is_empty placements then ok := false
        else
          let Line new_row = solve_line clue (Line row_cells) in
          for x = 0 to n - 1 do
            let pos = Position.{ x; y = r } in
            let old_c = get !p_ref pos in
            let new_c = List.nth_exn new_row x in
            if not (phys_equal old_c new_c) then (
              p_ref := set !p_ref pos new_c;
              changed := true)
          done)
    done;

    if !ok then
      for c = 0 to n - 1 do
        if !ok then (
          let col_cells = cols !p_ref c in
          let clue = col_clue !p_ref c in
          let placements = all_placements clue col_cells in
          if List.is_empty placements then ok := false
          else
            let Line new_col = solve_line clue (Line col_cells) in
            for y = 0 to n - 1 do
              let pos = Position.{ x = c; y } in
              let old_c = get !p_ref pos in
              let new_c = List.nth_exn new_col y in
              if not (phys_equal old_c new_c) then (
                p_ref := set !p_ref pos new_c;
                changed := true)
            done)
      done;

    if not !ok then `Contradiction
    else if !changed then step !p_ref
    else `Ok !p_ref
  in
  step p0

let has_unknown (p : t) : bool =
  let n = size p in
  let found = ref false in
  for y = 0 to n - 1 do
    if not !found then (
      let row = rows p y in
      if List.exists row ~f:(fun c -> phys_equal c Unknown) then
        found := true)
  done;
  !found

let choose_unknown (p : t) : position option =
  let n = size p in
  let result = ref None in
  for y = 0 to n - 1 do
    for x = 0 to n - 1 do
      match !result with
      | Some _ -> ()
      | None ->
          let pos = Position.{ x; y } in
          if phys_equal (get p pos) Unknown then
            result := Some pos
    done
  done;
  !result

let solve (p0 : t) : solve_result =
  let solutions = ref [] in
  let max_solutions = 2 in
  let rec search p =
    if List.length !solutions >= max_solutions then ()
    else
      match propagate p with
      | `Contradiction -> ()
      | `Ok p' ->
          if not (has_unknown p') then
            solutions := p' :: !solutions
          else
            match choose_unknown p' with
            | None -> ()
            | Some pos ->
                let p_filled = set p' pos Filled in
                search p_filled;
                if List.length !solutions < max_solutions then (
                  let p_empty = set p' pos Empty in
                  search p_empty)
  in
  search p0;
  match !solutions with
  | [] -> NoSolution
  | [ s ] -> Solved s
  | s1 :: s2 :: _ -> MultipleSolutions [ s1; s2 ]
