open Core
open Par_samples

let count_weird_stocks_par (par : Parallel.t) stocks =
  let is_penny_stock stock = Float.(Stock.price stock < 1.0) in
  let count_penny_stocks lst = Parallel_utils.count_if lst ~f:is_penny_stock in
  let is_five_digit_stock stock = Float.(Stock.price stock >= 10000.0) in
  let count_five_digit_stocks lst = Parallel_utils.count_if lst ~f:is_five_digit_stock in
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
  Printf.printf "result: %d %d\n" penny five_digit
