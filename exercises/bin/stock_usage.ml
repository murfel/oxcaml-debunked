open Exercises

let describe (par : Parallel.t) stock =
  let #(ticker_length, is_uppercase) =
    Parallel.fork_join2
      par
      (* stock is captured as shared *)
        (fun _ ->
        let ticker = Stock.ticker stock in
        Printf.printf "branch 1: %s %.2f\n%!" ticker (Stock.price stock);
        String.length ticker)
      (fun _ ->
        let ticker = Stock.ticker stock in
        Printf.printf "branch 2: %s %.2f\n%!" ticker (Stock.price stock);
        String.equal ticker (String.uppercase_ascii ticker))
  in
  ticker_length, is_uppercase
;;

let run (par : Parallel.t) =
  (* Create a stock and modify its (mutable) price. *)
  let stock = Stock.create ~ticker:"AAPL" ~price:100.0 in
  Stock.set_price stock 101.5;
  Printf.printf "%s: %.2f\n" (Stock.ticker stock) (Stock.price stock);
  let result = describe par stock in
  (* Both branches have joined, so [stock] is uncontended again and can be modified. *)
  Stock.set_price stock 100.0;
  Printf.printf "%s: %.2f\n" (Stock.ticker stock) (Stock.price stock);
  result
;;

let () =
  let ticker_length, is_uppercase = Parallel_scheduler.with_parallel run in
  Printf.printf "ticker length: %d, uppercase: %b\n" ticker_length is_uppercase
;;
