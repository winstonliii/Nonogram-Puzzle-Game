open Core

module Position = Position
module PosMap = Map.Make (Position)

type 'a t = {
  size : int;
  data : 'a PosMap.t;
}

let size g = g.size

let create ~size ~init =
  let positions =
    List.init size ~f:(fun y ->
        List.init size ~f:(fun x -> Position.{ x; y }))
    |> List.concat
  in
  let data =
    List.fold positions ~init:PosMap.empty ~f:(fun m pos ->
        Map.set m ~key:pos ~data:(init pos))
  in
  { size; data }

let get g pos =
  match Map.find g.data pos with
  | Some v -> v
  | None -> invalid_arg "Position not in grid"

let set g pos v =
  { g with data = Map.set g.data ~key:pos ~data:v }

let rows g r =
  List.init g.size ~f:(fun x ->
    get g Position.{ x; y = r })

let cols g c =
  List.init g.size ~f:(fun y ->
      get g Position.{ x = c; y })

let fold_rows g ~init ~f =
  let rec loop r acc =
    if r = g.size then acc
    else
      let row_cells = rows g r in
      let acc' = f acc r row_cells in
      loop (r + 1) acc'
  in
  loop 0 init

let fold_cols g ~init ~f =
  let rec loop c acc =
    if c = g.size then acc
    else
      let col_cells = cols g c in
      let acc' = f acc c col_cells in
      loop (c + 1) acc'
  in
  loop 0 init