open Core

(*  Calculate properties of a stock (is a penny stock, is a five-digit stock) given its price. *)

(*  Motivation: you need to know the properties of a stock before you can safely work with it. *)
(*  Calculating properties is independent of each other and also takes a long time, *)
(*  so you parallelize the computation by instructions (same data, different instructions). *)

(*  Compiles. *)

module Stock = struct
  type t = { price : float }

  let create ~price = { price }
  let price { price } = price
end

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

let stock1 = Stock.create ~price:0.07
let run par = calc_stock_properties par stock1

let () =
  let is_penny, is_five_digit = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %b %b\n" is_penny is_five_digit (* result: true false *)
;;
