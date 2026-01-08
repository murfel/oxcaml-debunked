(*  Does not compile. *)

(* 7 | let f () = x := !x + 1 *)
(*               ^ *)
(* Error: Unbound value x *)

let f () = x := !x + 1

let run (par : Parallel.t) =
  let x = ref 0 in
  let _ = Parallel.fork_join2 par (fun _par -> f ()) (fun _par -> 42) in
  !x
;;

let () =
  let result = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d\n" result
;;
