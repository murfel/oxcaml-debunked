let counter = ref 0
let incr_counter () = counter := !counter + 1

(* Exercise: decide which lines will compile. Uncomment to check yourself. *)

(* Part 1: the same mutable data, captured vs passed as a parameter. *)

(* let (p1 @ portable) () = counter := !counter + 1 *)
(* let (p2 @ portable) r = r := !r + 1 *)

(* Part 2: the same nonportable function, captured vs passed as a parameter. *)

(* let (p3 @ portable) () = incr_counter () *)
(* let (p4 @ portable) (f @ nonportable) = f () *)

(* Part 3: a parameter of the outer function, used by an inner function. *)

(* let (p5 @ portable) r = let g () = r := !r + 1 in g () *)
(* let (p6 @ portable) r = let (g @ portable) () = r := !r + 1 in g () *)
(* let (p7 @ portable) r = let (g @ portable) r = r := !r + 1 in g r *)

let () =
(*   p2 counter; *)
  Printf.printf "%d\n" !counter
;;
