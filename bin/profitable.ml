open Core

(* Given a list of prices for a security and a threshold price,
     count the number of days when price > threshold.
     Speed up the computation by splitting the list in two,
     and counting on two domains (threads). *)
(* let count_profitable_days_par (par : Parallel.t) prices threshold = *)
(*  let count = ref 0 in *)
(*  let (left, _right) = List.split_n prices (List.length prices / 2) in *)
(*  let count_profitable_days lst = *)
(*    List.iter lst ~f:(fun price -> *)
(*      if Float.(price > threshold) *)
(*      then count := !count + 1) *)
(*  in *)
(*  let _ = *)
(*    Parallel.fork_join2 par *)
(*      (fun _par -> count_profitable_days left) *)
(* (*      Replace the right part of the array computation with an empty computation. *)
(*        And replace right with _right above. *)
(*        It will compile, because the compiler will infer that count is only modified in one domain. *)
(* *) *)
(* (*      (fun _par -> ()) *) *)
(*      (fun _par -> count_profitable_days right) *)
(*  in *)
(*  !count *)
(* ;; *)

(* let statistics = ref 0 *)


let count_profitable_days_par (par : Parallel.t) prices threshold =
  let (left, right) = List.split_n prices (List.length prices / 2) in
  let is_profitable price = Float.(price > threshold) in
  let count_profitable_days lst = List.count lst ~f:is_profitable in
  let #(left_count, right_count) =
    Parallel.fork_join2 par
      (fun _par -> count_profitable_days left)
      (fun _par -> count_profitable_days right)
  in
  left_count + right_count
;;


let run par = count_profitable_days_par par [3.5; 2.1; 3.3; 5.7; 1.8] 2.0

let () =
  let result = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d\n" result

(* let () = print_endline "Hello, World!" *)
