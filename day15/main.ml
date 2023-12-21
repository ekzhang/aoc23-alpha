(*
OCaml is exactly how I remember it. I tried to use more of the `|>` operator
this time! Not a bad solution, though still a little verbose.

In my freshman year of college, the first CS class I took was compilers, taught
in OCaml. I remember thinking it was really tricky. But compared to the other
languages in this challenge, OCaml feels quite tame and practical. :')
*)

let hash (s : string) : int =
  let rec aux i acc =
    if i = String.length s then acc
    else
      let c = Char.code s.[i] in
      aux (i + 1) ((acc + c) * 17 mod 256)
  in
  aux 0 0

module IntMap = Map.Make (struct
  type t = int

  let compare = compare
end)

type state = (string * int) list IntMap.t

let update_lenses (s : state) (token : string) : state =
  if token.[String.length token - 1] == '-' then
    (* Remove label from its bucket. *)
    let label = String.sub token 0 (String.length token - 1) in
    IntMap.update (hash label)
      (fun x ->
        match x with
        | None -> None
        | Some lenses -> Some (List.filter (fun (l, _) -> l <> label) lenses))
      s
  else
    (* Add a new lens to the bucket, or replace an existing one. *)
    let label = String.sub token 0 (String.length token - 2) in
    let strength =
      int_of_string (String.sub token (String.length token - 1) 1)
    in
    let rec assoc_replace_or_add (l, x) lenses =
      match lenses with
      | [] -> [ (l, x) ]
      | (l', x') :: lenses ->
          if l = l' then (l, x) :: lenses
          else (l', x') :: assoc_replace_or_add (l, x) lenses
    in
    IntMap.update (hash label)
      (fun x ->
        match x with
        | None -> Some [ (label, strength) ]
        | Some lenses -> Some (assoc_replace_or_add (label, strength) lenses))
      s

let tokens = read_line () |> String.split_on_char ',';;

(* Part 1 *)
List.map hash tokens |> List.fold_left ( + ) 0 |> string_of_int |> print_endline;

(* Part 2 *)
let s = List.fold_left update_lenses IntMap.empty tokens in
IntMap.fold
  (fun bucket lenses acc ->
    lenses
    |> List.mapi (fun i (_, x) -> (i + 1) * x)
    |> List.fold_left ( + ) 0
    |> ( * ) (bucket + 1)
    |> ( + ) acc)
  s 0
|> string_of_int |> print_endline
