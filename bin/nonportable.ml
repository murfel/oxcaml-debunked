let x = ref 0

let run_par (par : Parallel.t) =
  let (f @ portable) () = x := !x + 1; !x in
  let g () = 42 in
  let #(r1, r2) =
    Parallel.fork_join2 par
      (fun _par -> f)
      (fun _par -> g)
  in
  (r1, r2)

let run par = run_par par

let () =
  let (r1, r2) = Parallel_utils.run_one_test ~f:run in
  Printf.printf "result: %d %d\n" r1 r2
