open Core
open Par_samples

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
