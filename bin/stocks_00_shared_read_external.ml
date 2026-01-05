open Core
open Par_samples

(* File "bin/stocks_00_shared_read_external.ml", line 10, characters 19-38: *)
(* 10 |       (fun _par -> is_five_digit_stock stock) *)
(*                        ^^^^^^^^^^^^^^^^^^^ *)
(* Error: The value is_five_digit_stock is nonportable *)
(*       because it closes over the value Stock.price (at File "bin/stocks_00_shared_read_external.ml", line 6, characters 41-52) *)
(*       which is nonportable. *)
(*       However, the highlighted value is_five_digit_stock is expected to be portable *)
(*       because it is used inside a function which is expected to be portable. *)

let calc_weird_stock_tuple_par (par : Parallel.t) stock =
  let is_penny_stock stock = Float.(Stock.price stock < 1.0) in
  let is_five_digit_stock stock = Float.(Stock.price stock >= 10000.0) in
  let #(is_penny, is_five_digit) =
    Parallel.fork_join2 par
      (fun _par -> is_penny_stock stock)
      (fun _par -> is_five_digit_stock stock)
  in
  (is_penny, is_five_digit)
;;

let stock1 = Stock.create ~price:0.07

let run par = calc_weird_stock_tuple_par par stock1

let () =
  let (is_penny, is_five_digit) = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %b %b\n" is_penny is_five_digit
