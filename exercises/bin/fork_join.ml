(* A custom [my_fork_join2] that hands each branch its own argument. The arguments are
   captured into closures.

   Exercise: Indicate the mode/modes at which the arguments are passed into
   [my_fork_join2], and compile to see if your modes are compatible with the examples 1
   and 2 below. Hint: you need to annotate each of the arguments (a : int ref) (b : int
   ref) with `@ mode/modes` annotations. Hint: think of the requirements for the unary
   functions passed into the real fork_join2, and work out the requirements for the custom
   fork_join2 backwards from there.
*)
let my_fork_join2 (par : Parallel.t) f g (a @ shareable shared) (b @ shareable shared) =
  Parallel.fork_join2 par (fun _par -> f a) (fun _par -> g b)
;;

(* First example usage. *)
let example1 (par : Parallel.t) =
  let a = ref 1 in
  let b = ref 10 in
  let #(a', b') =
    my_fork_join2 par (fun a -> a.contents + 1) (fun b -> b.contents + 1) a b
  in
  Printf.printf "a: %d, b: %d\n" a' b'
;;

(* Second example usage. *)
let example2 (par : Parallel.t) =
  let incr r = r := !r + 42 in
  let decr r = r := !r - 10 in
  let #(a', b') =
    my_fork_join2
      par
      (fun a ->
        let r = ref 0 in
        a r;
        !r)
      (fun b ->
        let r = ref 0 in
        b r;
        !r)
      incr
      decr
  in
  Printf.printf "a: %d, b: %d\n" a' b'
;;

let () = Parallel_scheduler.with_parallel example1
(* Uncomment to see if your modes pass this one, too. *)
(* let () = Parallel_scheduler.with_parallel example2 *)
