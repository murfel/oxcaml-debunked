open! Core
open Await

module Either_capsule = struct
  type ('a, 'k1, 'k2) t =
    | Capsule_1 of ('a, 'k1) Capsule.Data.t
    | Capsule_2 of ('a, 'k2) Capsule.Data.t
end

let open_capsule
  (type a : value mod aliased contended many portable)
  ~key
  ~(data : (a ref, _) Capsule.Data.t)
  =
  Capsule_prim.Key.with_password key ~f:(fun password ->
    Capsule_prim.access ~password ~f:(fun access -> !(Capsule.Data.unwrap ~access data)))
;;

let main () =
  let (P key1) = Capsule.Prim.create () in
  let (P key2) = Capsule.Prim.create () in
  let make_data () = Capsule.Data.create (fun () -> ref 0) in
  let capsules =
    [ Either_capsule.Capsule_1 (make_data ())
    ; Either_capsule.Capsule_2 (make_data ())
    ; Either_capsule.Capsule_1 (make_data ())
    ]
  in
  let #(all_data, key1, key2) =
    let rec go capsules key1 key2 =
      match capsules with
      | [] -> #([], key1, key2)
      | Either_capsule.Capsule_1 data1 :: capsules ->
        let #(data1, key1) = open_capsule ~key:key1 ~data:data1 in
        let #(data, key1, key2) = go capsules key1 key2 in
        #(data1 :: data, key1, key2)
      | Either_capsule.Capsule_2 data2 :: capsules ->
        let #(data2, key2) = open_capsule ~key:key2 ~data:data2 in
        let #(data, key1, key2) = go capsules key1 key2 in
        #(data2 :: data, key1, key2)
    in
    go capsules key1 key2
  in
  (* let #(one, key1) = *)
  (* Capsule_prim.Key.with_password key1 ~f:(fun password -> *)
  (* Capsule_prim.access ~password ~f:(fun access -> *)
  (* !(Capsule.Data.unwrap ~access data2) *)
  (* ) *)
  (* ) *)
  (* in *)
  let _ = all_data in
  let _ = key1 in
  let _ = key2 in
  print_endline "Done"
;;
