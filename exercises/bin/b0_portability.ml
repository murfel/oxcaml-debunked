let counter = ref 0
let greeting = "hello"
let incr_counter () = counter := !counter + 1
let atomic_counter = Atomic.make 0

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

(* Part 1: portable functions using top-level values. *)

(* let (p1 @ portable) () = print_endline "hi" *)
(* let (p2 @ portable) () = print_endline greeting *)

(* let (p3 @ portable) () = Printf.printf "%d\n" !counter *)
(* let (p4 @ portable) () = counter := 42 *)

(* let (p5 @ portable) () = incr_counter () *)
(* let (p6 @ portable) () = Atomic.incr atomic_counter *)

(* let (p7 @ portable) () = let r = ref 0 in r := !r + 1; !r *)

(* Part 2: portable closures capturing local values. *)

(* let p8 () = let x = 5 in let (h @ portable) () = x + 1 in h () *)

(* let p9 () = let r = ref 5 in let (h @ portable) () = !r + 1 in h () *)

(* Part 3: portable closures capturing a stock. *)

(* let p10 (stock : Stock.t) = let (h @ portable) () = Stock.print_ticker stock in h () *)

(* let p11 (stock : Stock.t) = let (h @ portable) () = Stock.print_price stock in h () *)

(* let p12 (stock : Stock.t) = let (h @ portable) () = Stock.set_price stock 101.5 in h () *)

(* Part 4: portable closures capturing functions. *)

(* let p13 (f @ nonportable) = let (h @ portable) () = f () in h () *)

(* let p14 (f @ portable) = let (h @ portable) () = f () in h () *)

(* let p15 (f @ portable) = let (h @ nonportable) () = f () in h () *)

let () =
  let _stock = Stock.create ~ticker:"AAPL" ~price:100.0 in
  (* p1 () *)
  ()
;;
