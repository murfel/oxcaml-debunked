(*  Compiles. *)

(*  Parallel_scheduler.with_parallel does not require the root computation `run` to be
  portable, and the first branch of Biased.fork_join2 may be nonportable,
  so f can modify the global x there. *)

(*  Moving f () to the second branch does not compile, since that branch must be portable: *)

(* 23 |   let _ = Parallel.Biased.fork_join2 par (fun _par -> 42) (fun _par -> f ()) in *)
(*                                                                         ^ *)
(* Error: The value "f" is "nonportable" *)
(*       but is expected to be "portable" *)
(*         because it is used inside the function at file "bin/ref_global_good.ml", line 23, characters 58-76 *)
(*         which is expected to be "portable". *)

(*  If we mark f as @ portable, the compiler will treat x as contended,
  but the increment requires uncontended mode, so the compiler will again produce an error. *)

let x = ref 0
let f () = x := !x + 1

let run (par : Parallel.t) =
  let _ = Parallel.Biased.fork_join2 par (fun _par -> f ()) (fun _par -> 42) in
  !x
;;

let () =
  let res = Parallel_scheduler.with_parallel run in
  Printf.printf "result: %d\n" res
;;
