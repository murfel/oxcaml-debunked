(* Exercise: decide which examples will compile. Uncomment to check yourself. *)

(* Example 1 *)
(* let () = *)
(* let (r @ contended) = ref 0 in *)
(* let incr () = r := !r + 1; !r in *)
(*  Printf.printf "%d\n" (incr ()); *)
(* ;; *)

(* Example 1 *)
(* let () = *)
(* let (r @ uncontended) = ref 0 in *)
(* let incr () = r := !r + 1; !r in *)
(*  Printf.printf "%d\n" (incr ()); *)
(* ;; *)

(* TODO(natasha) atomic example? *)
