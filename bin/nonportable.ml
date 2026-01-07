let x = ref 0

let (f @ portable) = x := !x + 1; !x

let run_par (par : Parallel.t) =
  let #(r1, r2) =
    Parallel.fork_join2 par
      (fun _par -> f)
      (fun _par -> f)
  in
  r1 + r2

let run par = run_par par

let run_one_test ~(f : Parallel.t @ local -> 'a) : 'a =
  let module Scheduler = Parallel_scheduler in
  let scheduler = Scheduler.create () in
  let result = Scheduler.parallel scheduler ~f in
  Scheduler.stop scheduler;
  result

let () =
  let result = run_one_test ~f:run in
  Printf.printf "result: %d\n" result
