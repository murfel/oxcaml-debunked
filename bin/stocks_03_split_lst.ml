open Core

module Stock = struct
  type t =
    { price : float
    }

  let create ~price = { price }
  let price { price; _ } = price
end

let count_penny_stocks_par (par : Parallel.t) prices threshold =
  let (left, right) = List.split_n prices (List.length prices / 2) in
  let is_penny_stock stock = Float.(Stock.price stock > threshold) in
  let count_penny_stocks lst = List.count lst ~f:is_penny_stock in
  let #(left_count, right_count) =
    Parallel.fork_join2 par
      (fun _par -> count_penny_stocks left)
      (fun _par -> count_penny_stocks right)
  in
  left_count + right_count
;;

let stocks = [(Stock.create ~price:0.07);
              (Stock.create ~price:5.0);
              (Stock.create ~price:3.3);
              (Stock.create ~price:0.5);
              (Stock.create ~price:2.0);
              ]

let run par = count_penny_stocks_par par stocks 1.0

let () =
  let result = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d\n" result
