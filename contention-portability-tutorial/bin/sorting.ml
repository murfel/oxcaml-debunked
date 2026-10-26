(* Parallel quicksort, from
   https://oxcaml.org/documentation/tutorials/intro-to-parallelism-part-2/#sorting *)

module Par_array = Parallel.Arrays.Array
module Slice = Parallel.Arrays.Array.Slice

(* The tutorial's [Capsule] API (keys, passwords, [Data.iter]) is [Capsule.Prim] in the
   installed [capsule] library; its mutex lives in [Capsule.Blocking_sync]. *)
module Capsule = struct
  include Capsule.Prim
  module Mutex = Capsule.Blocking_sync.Mutex
end

let swap slice ~i ~j =
  let temp = Slice.get slice i in
  Slice.set slice i (Slice.get slice j);
  Slice.set slice j temp
;;

let partition slice =
  let length = Slice.length slice in
  let pivot = Random.int length in
  swap slice ~i:pivot ~j:(length - 1);
  let pivot = Slice.get slice (length - 1) in
  let store = ref 0 in
  for i = 0 to length - 2 do
    if Slice.get slice i <= pivot
    then (
      swap slice ~i ~j:!store;
      incr store)
  done;
  swap slice ~i:!store ~j:(length - 1);
  !store
;;

(* [Slice.fork_join2] splits the local slice at [pivot] and hands each half to a parallel
   subtask, so neither closure has to capture a local value. *)
let rec quicksort parallel slice =
  if Slice.length slice > 1
  then (
    let pivot = partition slice in
    let #((), ()) =
      Slice.fork_join2
        parallel
        ~pivot
        slice
        (fun parallel left -> quicksort parallel left)
        (fun parallel right -> quicksort parallel right)
    in
    ())
;;

(* The array lives in a capsule; the mutex hands out the password needed to reach it
   uncontended. *)
let quicksort ~mutex array =
  Parallel_scheduler.with_parallel (fun parallel ->
    Capsule.Mutex.with_lock mutex ~f:(fun password ->
      Capsule.Data.iter array ~password ~f:(fun array ->
        let array = Par_array.of_array array in
        quicksort parallel (Slice.slice array) [@nontail])
      [@nontail])
    [@nontail])
;;

let () =
  let (P key) = Capsule.create () in
  let array = Capsule.Data.create (fun () -> [| 5; 3; 9; 1; 7; 2; 8; 6; 4; 0 |]) in
  let mutex = Capsule.Mutex.create key in
  quicksort ~mutex array;
  Capsule.Mutex.with_lock mutex ~f:(fun password ->
    Capsule.Data.iter array ~password ~f:(fun array ->
      Array.iter (Printf.printf "%d ") array;
      print_newline () (* 0 1 2 3 4 5 6 7 8 9 *)))
;;
