module Stock = struct
  type t =
    { price : float
    ; trading_speed : float ref
    }

  let create ~price ~trading_speed = { price; trading_speed = ref trading_speed }
  let price { price; _ } = price
  let _trading_speed t = !(t.trading_speed)
  let set_trading_speed t v = t.trading_speed := v
end

(* let is_penny_stock stock = Float.(Stock.price stock < 1.0) *)
(* let is_five_digit_stock stock = Float.(Stock.price stock >= 10000.0) *)

let calc_price_properties stock = Stock.price stock < 1.0

let adjust_trading_speed stock =
  if Stock.price stock > 100000.0
  then Stock.set_trading_speed stock 0.0
  else Stock.set_trading_speed stock 1.0
;;

(* Writer domain W *)
(* adjust_trading_speed stock *)

(* Reader domain R1 *)
(* calc_price_properties1 stock *)

(* Reader domain R2 *)
(* calc_price_properties2 stock *)

let run (par : Parallel.t) =
  let stock = Stock.create ~price:17.29 ~trading_speed:0.10 in
  let #((), _, _) =
    Parallel.fork_join3
      par
      (fun _par -> adjust_trading_speed stock)
      (fun _par -> calc_price_properties stock)
      (fun _par -> calc_price_properties stock)
  in
  ()
;;

let () =
  let () = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: it compiles and runs!\n" (* result: it compiles and runs!*)
;;
