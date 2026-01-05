let run_one_test ~(f : Parallel.t @ local -> 'a) : 'a =
  let module Scheduler = Parallel_scheduler in
  let scheduler = Scheduler.create () in
  let result = Scheduler.parallel scheduler ~f in
  Scheduler.stop scheduler;
  result
;;


let rec count_if (lst @ contended) ~f =
  match lst with
    | [] -> 0
    | x :: xs ->
      let acc = count_if xs ~f in
        if f x then 1 + acc else acc
;;
