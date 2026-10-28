module Stock = struct
  type t =
    { ticker : string
    ; mutable price : float
    }

  let create ~ticker ~price = { ticker; price }
  let print_ticker { ticker; _ } = Printf.printf "%s\n" ticker
  let print_price { price; _ } = Printf.printf "%.2f\n" price
  let set_price t price = t.price <- price
end

(* Exercise: decide which lines will compile. Uncomment to check yourself. *)

(* let f1 (stock @ contended) = Stock.print_ticker stock *)
(* let f2 (stock @ uncontended) = Stock.print_ticker stock *)

(* let f3 (stock @ contended) = Stock.print_price stock *)
(* let f4 (stock @ uncontended) = Stock.print_price stock *)

(* let f5 (stock @ contended) = Stock.set_price stock 101.5 *)
(* let f6 (stock @ uncontended) = Stock.set_price stock 101.5 *)

let () =
  let _stock = Stock.create ~ticker:"AAPL" ~price:100.0 in
  (* f1 stock *)
  ()
;;

(* Continue the exercise with f7 and f8 *)

module AtomicStock = struct
  type t =
    { ticker : string
    ; mutable price : float [@atomic]
    }

  let create ~ticker ~price = { ticker; price }
  let print_ticker { ticker; _ } = Printf.printf "%s\n" ticker
  let print_price t = Printf.printf "%.2f\n" t.price (* sad note: cannot pattern-match on atomic *)
  let set_price t price = t.price <- price
end

(* let f7 (stock @ contended) = AtomicStock.set_price stock 101.5 *)
(* let f8 (stock @ uncontended) = AtomicStock.set_price stock 101.5 *)

let () =
  let _stock = AtomicStock.create ~ticker:"AAPL" ~price:100.0 in
  (* f7 stock *)
  ()
;;
