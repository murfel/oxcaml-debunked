open! Core
open Await

let open_capsule
  (type a : value mod aliased contended many portable)
  ~key
  ~(data : (a ref, _) Capsule.Data.t)
  =
  Capsule_prim.Key.with_password key ~f:(fun password ->
    Capsule_prim.access ~password ~f:(fun access -> !(Capsule.Data.unwrap ~access data)))
;;

let main () =
  let (P key) = Capsule.Prim.create () in
  let make_data (i : int) = Capsule.Data.create (fun () -> ref i) in
  let capsules = [ make_data 1; make_data 2; make_data 3 ] in
  let #(all_data, key) =
    let rec go capsules key =
      match capsules with
      | [] -> #([], key)
      | data :: capsules ->
        let #(value, key) = open_capsule ~key ~data in
        let #(values, key) = go capsules key in
        #(value :: values, key)
    in
    go capsules key
  in
  let _ = key in
  print_endline (String.concat ~sep:" " (List.map all_data ~f:Int.to_string));
  print_endline "Done"
;;

let () = main ()
