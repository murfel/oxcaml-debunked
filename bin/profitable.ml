open Core

(* Given a list of daily closing prices for a security and a threshold price, *)
(* count the number of days when the closing price > threshold. *)

(* Sequential version *)

let prices = [3.5; 2.1; 3.3; 5.7; 1.8]
let threshold = 2.0

let count_profitable_days prices threshold =
  List.count prices ~f:(fun price -> Float.(price > threshold))

let () =
  let result = count_profitable_days prices threshold in
  Printf.printf "result (sequential): %d\n" result (* result: 4 *)

(* Speed up the computation by parallelizing by data: *)
(* split the list in two, and count each part on its own domain (thread). *)

(* Incorrect parallel version (data race on `counter`) (does not compile) *)

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
(*      (fun _par -> count_profitable_days right) *)
(*  in *)
(*  !count *)
(* ;; *)

(* Correct parallel version *)

let count_profitable_days_par (par : Parallel.t) prices threshold =
  let (left, right) = List.split_n prices (List.length prices / 2) in
  let #(left_count, right_count) =
    Parallel.fork_join2 par
      (fun _par -> count_profitable_days left threshold)
      (fun _par -> count_profitable_days right threshold)
  in
  left_count + right_count
;;

let run par = count_profitable_days_par par prices threshold

let () =
  let result = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result (parallel): %d\n" result
