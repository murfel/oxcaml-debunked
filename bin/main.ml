open Core

(* let () = print_endline "Hello, World!" *)
let x1 @ contended = 42
let x2 @ uncontended = 42
let lst1 @ contended = [ 1; 2; 3 ]
let lst2 @ uncontended = [ 1; 2; 3 ]
let r1 @ contended = ref 0
let r2 @ uncontended = ref 0
let ref_lst1 @ contended = [ ref 0; ref 0; ref 0 ]
let ref_lst2 @ uncontended = [ ref 0; ref 0; ref 0 ]
let f1 (lst @ contended) = List.length lst
let f2 (lst @ uncontended) = List.length lst
let get_plus_one1 (x @ contended) = x + 1
let get_plus_one2 (x @ uncontended) = x + 1
let get_plus_one_ref1 (r @ contended) = !r + 1
let get_plus_one_ref2 (r @ uncontended) = !r + 1

let () =
  let result = f1 lst1 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = f1 lst2 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = f1 ref_lst1 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = f1 ref_lst2 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = get_plus_one1 x1 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = get_plus_one1 x2 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = get_plus_one_ref1 r1 in
  Printf.printf "result: %d\n" result
;;

let () =
  let result = get_plus_one_ref1 r2 in
  Printf.printf "result: %d\n" result
;;
