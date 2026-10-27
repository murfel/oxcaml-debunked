open! Core
open Await

let () =
  let (P key) = Capsule.Prim.create () in
  let data = Capsule.Data.create (fun () -> ref 42) in
  let run par =
    let #(left, right) =
      Parallel.fork_join2
        par
        (fun _ ->
          let #(value, _key) =
            Capsule.Prim.Key.with_password key ~f:(fun password ->
              Capsule.Prim.access ~password ~f:(fun access ->
                !(Capsule.Data.unwrap ~access data)))
          in
          value)
        (fun _ -> 2)
    in
    left + right
  in
  let result = Parallel_scheduler.with_parallel run in
  Printf.printf "result: %d\n" result
;;
