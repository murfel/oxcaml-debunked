open Core
open Par_samples

(*  Move Stock into a separate module. *)

(*  Now it does not compile. *)

(*  The compiler can now only see the Stock's signature in stock.mli,
      and cannot see the implementation in stock.ml.
      The implementation contained crucial information for mode inference,
      so now we need to add explicit mode annotations to convince the compiler
      that there's no possibility for a data race. *)

let calc_weird_stock_tuple_par (par : Parallel.t) stock =
  let is_penny_stock stock = Float.(Stock.price stock < 1.0) in
  let is_five_digit_stock stock = Float.(Stock.price stock >= 10000.0) in
  let #(is_penny, is_five_digit) =
    Parallel.fork_join2 par (fun _par -> is_penny_stock stock) (fun _par -> false)
  in
  is_penny, is_five_digit
;;

let stock = Stock.create ~price:0.07
let run par = calc_weird_stock_tuple_par par stock

let () =
  let is_penny, is_five_digit = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %b %b\n" is_penny is_five_digit
;;
(* result: true false *)

(* File "bin/stocks_01_shared_read_external.ml", line 10, characters 19-38: *)
(* 10 |       (fun _par -> is_five_digit_stock stock) *)
(*                        ^^^^^^^^^^^^^^^^^^^ *)
(* Error: The value is_five_digit_stock is nonportable *)
(*       because it closes over the value Stock.price (at File "bin/stocks_00_shared_read_external.ml", line 6, characters 41-52) *)
(*       which is nonportable. *)
(*       However, the highlighted value is_five_digit_stock is expected to be portable *)
(*       because it is used inside a function which is expected to be portable. *)

(*  Explanation: you can only pass portable function to fork_join2, so the compiler expects is_five_digit_stock to be portable. By default though all functions are nonportable (least amount of guarantees), so the compiler tries to check if it can prove that is_five_digit_stock portable. Portable functions must in turn use portable functions only. is_five_digit_stock uses the Stock.price. However, the compiler doesn't have access to the Stock.price implementation since we moved it to stock.mli, so it can't check if its implementation adheres to portability rules, so it must pessimize and conclude that Stock.price is nonportable. Indeed, Stock.price might be calling some nonportable functions internally or break the portability requirements itself by accessing uncontended data (e.g. writing to a global variable). *)
(*  Fix: annotate Stock.price in lib/stock.mli as `@@ portable` *)

(* File "bin/stocks_01_shared_read_external.ml", line 10, characters 39-44: *)
(* 10 |       (fun _par -> is_five_digit_stock stock) *)
(*                                            ^^^^^ *)
(* Error: This value is contended but is expected to be uncontended. *)

(*  Explanation: *)
(*  Fix: annotate t passed into the price getter as `t @ contended` *)

(* File "bin/stocks_01_shared_read_external.ml", line 17, characters 45-51: *)
(* 17 | let run par = calc_weird_stock_tuple_par par stock1 *)
(*                                                  ^^^^^^ *)
(* Error: This value is nonportable but is expected to be portable. *)

(*  Explanation: *)
(*  Fix: annotate t returned from create as `t @ portable` *)

(*  Now it compiles. *)
