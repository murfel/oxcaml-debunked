(* Exercise: create an int ref value, increment it,
   pass it to one of the fork-join branches (how can you use it here?),
   increment it again after the fork-join finishes.

   Can you think of a similar pattern that you know is data-race free,
   but the compiler doesn't let you express it with contention and portability only?
   Hint: you'd be able to express it in plain multicore OCaml,
   without contention/portability restrictions.
   (No mutexes involved.)
   *)

let run (par : Parallel.t) =
  let r = ref 0 in
  r := !r + 1;
  let #(a, b) = Parallel.fork_join2 par (fun _par -> r.contents + 1) (fun _par -> 0) in
  r := !r + 1;
  Printf.printf "r: %d, a: %d, b: %d\n" !r a b
;;

let () = Parallel_scheduler.with_parallel run
