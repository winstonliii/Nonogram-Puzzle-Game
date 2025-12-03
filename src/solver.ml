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


(*need to propogate and then solver function*)
