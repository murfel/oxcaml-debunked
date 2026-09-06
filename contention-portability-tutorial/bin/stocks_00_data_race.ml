open Core

(*  Given a list of daily closing prices for a security and a threshold price, *)
(*  count the number of days when the closing price > threshold. *)

(*  Sequential version *)

let prices = [ 3.5; 2.1; 3.3; 5.7; 1.8 ]
let threshold = 2.0

let count_profitable_days prices threshold =
  List.count prices ~f:(fun price -> Float.(price > threshold))
;;

let () =
  let result = count_profitable_days prices threshold in
  Printf.printf "result (sequential): %d\n" result (* result: 4 *)
;;

(*  Speed up the computation by parallelizing by data: *)
(*  split the list in two, and count each part on its own domain (thread). *)

(*  Incorrect parallel version (data race on `counter`) *)

(*  Does not compile. *)

(* 35 |       (fun _par -> count_profitable_days_inner right) *)
(*                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ *)
(* Error: The value count_profitable_days_inner is nonportable *)
(*       because it contains a usage (of the value count at File "bin/stocks_00_data_race.ml", line 29, characters 69-74) *)
(*       which is expected to be uncontended. *)
(*       However, the highlighted value count_profitable_days_inner is expected to be portable *)
(*       because it is used inside a function which is expected to be portable *)

(* let count_profitable_days_par (par : Parallel.t) prices threshold = *)
(*  let count = ref 0 in *)
(*  let left, right = List.split_n prices (List.length prices / 2) in *)
(*  let count_profitable_days_inner lst = *)
(*    List.iter lst ~f:(fun price -> if Float.(price > threshold) then count := !count + 1) *)
(*  in *)
(*  let _ = *)
(*    Parallel.fork_join2 *)
(*      par *)
(*      (fun _par -> count_profitable_days_inner left) *)
(*      (fun _par -> count_profitable_days_inner right) *)
(*  in *)
(*  !count *)
(* ;; *)

(*  Correct parallel version *)

(*  Compiles *)

let count_profitable_days_par (par : Parallel.t) prices threshold =
  let left, right = List.split_n prices (List.length prices / 2) in
  let #(left_count, right_count) =
    Parallel.fork_join2
      par
      (fun _par -> count_profitable_days left threshold)
      (fun _par -> count_profitable_days right threshold)
  in
  left_count + right_count
;;

let run par = count_profitable_days_par par prices threshold

let () =
  let result = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result (parallel): %d\n" result (* result: 4 *)
;;
