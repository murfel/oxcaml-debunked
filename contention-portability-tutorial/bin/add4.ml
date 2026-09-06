let add4 (par : Parallel.t) a b c d =
  let #(a_plus_b, c_plus_d) =
    Parallel.fork_join2 par (fun _par -> a + b) (fun _par -> c + d)
  in
  a_plus_b + c_plus_d
;;

let test_add4 par = add4 par 1 10 100 1000

let () =
  let result = Parallel_utils.run_one_test ~f:test_add4 in
  Printf.printf "result: %d\n" result (* result: 1111 *)
;;
