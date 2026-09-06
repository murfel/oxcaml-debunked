(*  Does not compile. *)

(* 10 |   let _ = Parallel.fork_join2 par (fun _par -> x := !x + 1) (fun _par -> y := !y + 1) in *)
(*                                                                              ^ *)
(* Error: This value is contended but is expected to be uncontended. *)

let run (par : Parallel.t) =
  let x = ref 0 in
  let y = ref 0 in
  let _ = Parallel.fork_join2 par (fun _par -> x := !x + 1) (fun _par -> y := !y + 1) in
  !x + !y
;;

let () =
  let result = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d\n" result
;;
