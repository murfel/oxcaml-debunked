let run_one_test ~(f : Parallel.t @ local -> 'a) : 'a =
  Parallel_scheduler.with_parallel f
;;
