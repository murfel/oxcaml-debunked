open! Core
open Await

(* One mutex for a fresh capsule [Lock.k]. The key type is existential, so we use
   [Create ()] to get it at the module level. *)
module Lock = Capsule.Sync.Mutex.Create ()

(* Two separate counters, both living in the capsule [Lock.k] and so both protected by
   [Lock.mutex]. *)
let hits : (int ref, Lock.k) Capsule.Data.t = Capsule.Data.create (fun () -> ref 0)
let misses : (int ref, Lock.k) Capsule.Data.t = Capsule.Data.create (fun () -> ref 0)

let iterations = 1_000_000

(* Increment one counter, taking the shared lock on every iteration. *)
let bump counter =
  let sync = Sync.blocking in
  for _ = 1 to iterations do
    Capsule.Sync.Mutex.with_lock sync Lock.mutex ~f:(fun _sync access ->
      incr (Capsule.Data.unwrap ~access counter))
  done
;;

let run (par : Parallel.t) =
  let #((), ()) =
    Parallel.fork_join2 par (fun _par -> bump hits) (fun _par -> bump misses)
  in
  let h, m =
    Capsule.Sync.Mutex.with_lock Sync.blocking Lock.mutex ~f:(fun _sync access ->
      !(Capsule.Data.unwrap ~access hits), !(Capsule.Data.unwrap ~access misses))
  in
  printf "hits: %d, misses: %d\n" h m
;;

let () = Parallel_scheduler.with_parallel run
