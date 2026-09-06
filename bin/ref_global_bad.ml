(*  Does not compile. *)

(* 30 |   let res = Parallel_utils.run_one_test ~f:run in *)
(*                                                ^^^ *)
(* Error: This value is nonportable *)
(*       because it closes over the value f (at File "bin/ref_global_bad.ml", line 25, characters 47-48) *)
(*       which is nonportable *)
(*       because it contains a usage (of the value x at File "bin/ref_global_bad.ml", line 22, characters 11-12) *)
(*       which is expected to be uncontended. *)
(*       However, the highlighted expression is expected to be portable. *)

(*  If we mark f as @ portable, the compiler will treat x as contended,
  but the increment requires uncontended mode, so the compiler will again produce an error. *)

(* 20 | let (f @ portable) () = x := !x + 1 *)
(*                             ^ *)
(* Error: This value is contended but is expected to be uncontended. *)

let x = ref 0
let f () = x := !x + 1

let run (par : Parallel.t) =
  let _ = Parallel.fork_join2 par (fun _par -> f ()) (fun _par -> 42) in
  !x
;;

let () =
  let res = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d\n" res
;;
