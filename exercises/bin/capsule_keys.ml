open! Core
open Await

let () =
  let (P key1) = Capsule.Prim.create () in
  let (P key2) = Capsule.Prim.create () in
  let data1 = Capsule.Data.create (fun () -> ref 1) in
  let data2 = Capsule.Data.create (fun () -> ref 2) in
  let #(_, _key1') =
    Capsule.Prim.Key.with_password key1 ~f:(fun password ->
        Capsule.Prim.access ~password ~f:(fun access ->
            !(Capsule.Data.unwrap ~access data1)
          )
    )
  in
  let #(_, _key2') =
    Capsule.Prim.Key.with_password key2 ~f:(fun password ->
        Capsule.Prim.access ~password ~f:(fun access ->
            !(Capsule.Data.unwrap ~access data2)
          )
      )
  in
  print_endline "Done"
