(* Exercise: implement the [applier] function which accepts a pair of a (ref int,
   function) and applies the function to the ref int. Add a small usage example for a (ref
   0, incrementer) function. The incrementer function must increment its argument.

   At which mode should your function accept the pair? Annotate the arguments and the
   [applier] function parameters with the strictest modes possible.
*)

let () =
  let r @ uncontended = ref 0 in
  let (incrementer @ contended) r = r := !r + 1 in
  let applier (p @ uncontended) = (snd p) (fst p) in
  applier (r, incrementer);
  Printf.printf "%d\n" !r
;;
