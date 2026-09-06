open Core

let x_cont @ contended = 42
let c_uncont @ uncontended = 42
let lst_cont @ contended = [ 1; 2; 3 ]
let lst_uncont @ uncontended = [ 1; 2; 3 ]
let _r_cont @ contended = ref 0 (*  Useless. Cannot read or write. *)
let r_uncont @ uncontended = ref 0
let ref_lst_cont @ contended = [ ref 0; ref 0; ref 0 ]
let ref_lst_uncont @ uncontended = [ ref 0; ref 0; ref 0 ]
let len_cont (lst @ contended) = List.length lst
let _len_uncont (lst @ uncontended) = List.length lst
let get_plus_one_cont (x @ contended) = x + 1
let _get_plus_one_uncont (x @ uncontended) = x + 1

(*  Incorrect: r must be uncontended for a read access, since it's mutable. *)
(* let get_plus_one_ref_cont (r @ contended) = !r + 1 *)
let get_plus_one_ref_uncont (r @ uncontended) = !r + 1

let () =
  let result = len_cont lst_cont in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = len_cont lst_uncont in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = len_cont ref_lst_cont in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = len_cont ref_lst_uncont in
  Printf.printf "result: %d\n" result
;;

(*  ref_lst_cont - Error: This value is contended but is expected to be uncontended. *)
(* let () = *)
(*  let result = len_uncont ref_lst_cont in *)
(*  Printf.printf "result: %d\n" result *)
(* ;; *)

let () =
  let result = get_plus_one_cont x_cont in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = get_plus_one_cont c_uncont in
  Printf.printf "result: %d\n" result
;;

(*  r_cont - Error: This value is contended but is expected to be uncontended.*)
(* let () = *)
(*  let result = get_plus_one_ref_uncont r_cont in *)
(*  Printf.printf "result: %d\n" result *)
(* ;; *)

let () =
  let result = get_plus_one_ref_uncont r_uncont in
  Printf.printf "result: %d\n" result
;;
