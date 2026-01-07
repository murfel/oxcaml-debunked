(*  Does not compile. *)

(* 22 |   let r1, r2 = Parallel_utils.run_one_test ~f:run in *)
(*                                                   ^^^ *)
(* Error: This value is nonportable *)
(*       because it closes over the value run_par (at File "bin/nonportable.ml", line 19, characters 14-21) *)
(*       which is nonportable *)
(*       because it closes over the value f (at File "bin/nonportable.ml", line 15, characters 55-56) *)
(*       which is nonportable *)
(*       because it contains a usage (of the value x at File "bin/nonportable.ml", line 10, characters 4-5) *)
(*       which is expected to be uncontended. *)
(*       However, the highlighted expression is expected to be portable. *)

(*  If we mark f as @ portable, the compiler will treat x as contended,
  but the increment requires uncontended mode, so the compiler will again produce an error. *)

(* 7 |     x := !x + 1; *)
(*        ^ *)
(* Error: This value is contended but is expected to be uncontended. *)

let x = ref 0

let f () =
  x := !x + 1;
  !x
;;

let run_par (par : Parallel.t) =
  let #(r1, r2) = Parallel.fork_join2 par (fun _par -> f) (fun _par -> 42) in
  r1, r2
;;

let run par = run_par par

let () =
  let r1, r2 = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d %d\n" r1 r2
;;
