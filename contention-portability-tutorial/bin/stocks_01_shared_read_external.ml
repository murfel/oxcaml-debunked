open Core
open Par_samples

(*  Does not compile. *)

(*  Extracted Stock into a separate module lib/stock.mli and lib/stock.ml. *)

(*  The compiler can now only see the Stock's signature in stock.mli,
      and cannot see the implementation in stock.ml.
      The implementation contained crucial information for mode inference,
      so now we need to add explicit mode annotations to convince the compiler
      that there's no possibility for a data race. *)

let calc_stock_properties (par : Parallel.t) stock =
  let is_penny_stock stock = Float.(Stock.price stock < 1.0) in
  let is_five_digit_stock stock = Float.(Stock.price stock >= 10000.0) in
  let #(is_penny, is_five_digit) =
    Parallel.fork_join2
      par
      (fun _par -> is_penny_stock stock)
      (fun _par -> is_five_digit_stock stock)
  in
  is_penny, is_five_digit
;;

let stock = Stock.create ~price:0.07
let run par = calc_stock_properties par stock

let () =
  let is_penny, is_five_digit = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %b %b\n" is_penny is_five_digit
;;
(* result: true false *)

(* File "bin/stocks_01_shared_read_external.ml", line 21, characters 19-38: *)
(* 21 |       (fun _par -> is_five_digit_stock stock) *)
(*                        ^^^^^^^^^^^^^^^^^^^ *)
(* Error: The value is_five_digit_stock is nonportable *)
(*       because it closes over the value Stock.price (at File "bin/stocks_01_shared_read_external.ml", line 16, characters 41-52) *)
(*       which is nonportable. *)
(*       However, the highlighted value is_five_digit_stock is expected to be portable *)
(*       because it is used inside a function which is expected to be portable. *)

(*  Fix: annotate Stock.price in lib/stock.mli as `@@ portable` *)

(* File "bin/stocks_01_shared_read_external.ml", line 21, characters 39-44: *)
(* 21 |       (fun _par -> is_five_digit_stock stock) *)
(*                                            ^^^^^ *)
(* Error: This value is contended but is expected to be uncontended. *)

(*  Fix: annotate t passed into the price getter as `t @ contended` *)

(* File "bin/stocks_01_shared_read_external.ml", line 27, characters 45-50: *)
(* 27 | let run par = calc_stock_properties par stock *)
(*                                                  ^^^^^ *)
(* Error: This value is nonportable but is expected to be portable. *)

(*  Fix: annotate t returned from create as `t @ portable` *)

(*  Now it compiles. *)
