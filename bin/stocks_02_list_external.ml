open Core
open Par_samples

(*  Cannot use List.count because it accepts the list as uncontended (default mode), *)
(*  since f is allowed to mutate list items. *)

(*  However, it worked before when Stock implementation was in the same file,
  because the compiler was able to infer that TODO *)

(*  Thus we use a custom annotated count. *)

let rec count (lst @ contended) ~f =
  match lst with
    | [] -> 0
    | x :: xs ->
      let acc = count_if xs ~f in
        if f x then 1 + acc else acc
;;

(*  Does not compile. *)
(*  Replace both List.count entries with count to make it compile. *)
(* 27 |       (fun _par -> count_five_digit_stocks stocks) *)
(*                                                 ^^^^^^ *)
(* Error: This value is contended but is expected to be uncontended. *)

let count_weird_stocks_par (par : Parallel.t) stocks =
  let is_penny_stock stock = Float.(Stock.price stock < 1.0) in
  let count_penny_stocks lst = List.count lst ~f:is_penny_stock in
  let is_five_digit_stock stock = Float.(Stock.price stock >= 10000.0) in
  let count_five_digit_stocks lst = List.count lst ~f:is_five_digit_stock in
  let #(penny, five_digit) =
    Parallel.fork_join2 par
      (fun _par -> count_penny_stocks stocks)
      (fun _par -> count_five_digit_stocks stocks)
  in
  (penny, five_digit)
;;

let stocks = [(Stock.create ~price:0.07);
              (Stock.create ~price:50000.0);
              (Stock.create ~price:3.3);
              (Stock.create ~price:0.5);
              (Stock.create ~price:2.0);
              ]

let run par = count_weird_stocks_par par stocks

let () =
  let (penny, five_digit) = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d %d\n" penny five_digit (* result: 2 1 *)
