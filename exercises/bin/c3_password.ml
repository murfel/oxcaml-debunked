open! Core
open Await

let main () =
  let (P key) = Capsule.Prim.create () in
  let capsules = List.init 3 ~f:(fun i -> Capsule.Data.create (fun () -> ref i)) in
  (* Exercise: You have a capsule key and a list of capsule data wrapping [int ref]s. Use
     the key to open all capsules and return the list of stored [int]s. Use
     [Capsule.Prim.Key.access] and [Capsule.Data.unwrap]. Do not use the passwords.

     Hints:
     1. Write a recursive function to go through the list. The standard library is not
        rich enough to accept an [@ unique] key as an accumulator to the [List.fold]
        family of functions.
     2. The [~f] argument to the [Capsule.Prim.Key.access] function must return the value
        [@ contended portable unique]. In this exercise, you'll be returning an [int],
        which crosses all these modes, so this is fine. But the compiler checks these
        modes before inferring the full type of the recursive function, so at the time it
        checks the modes, it doesn't yet know it's [int]. You need to specify the type
        directly. The simplest syntax is [~f:(fun access : int -> ...)].
  *)
  let #(all_data1, key) =
    let rec go key capsules =
      match capsules with
      | [] -> #([], key)
      | capsule :: capsules ->
        let #(datum, key) =
          Capsule.Prim.Key.access key ~f:(fun access : int ->
            !(Capsule.Data.unwrap ~access capsule))
        in
        let #(data, key) = go key capsules in
        #(datum :: data, key)
    in
    go key capsules
  in
  (* Exercise: Now, do the same, but use the passwords ([Capsule.Prim.Key.with_password],
     [Capsule.Prim.access], [Capsule.Data.unwrap]).

     Hints:
     1. Passwords are [@ aliased], so it's possible to use [List.map].
     2. The [~f] argument to the [Capsule.Prim.Key.with_password] function must return the
        value [@ unique], so that the tuple the [with_password] function returns can be
        [@ unique], so that the key it contains is still [@ unique]. In this exercise,
        you'll need to return an [int list] from this function, which does not cross
        uniqueness. However, we could return a [@ unique] record with one [@ aliased]
        field. [Core] has wrappers for each modality axis that are exactly this. They are
        meant to be a convenient way to stop mode deepness. For uniqueness, use the
        ['a Modes.Aliased.t] type, with [Modes.Aliased.wrap] and [Modes.Aliased.unwrap]
        helpers.
     3. If you hit an error about tail calls, the reason is that OxCaml by default applies
        a tail call optimisation where it can, which sometimes breaks the locality
        assumptions. You need to disable the tail call optimisation by placing a
        [@nontail] annotation at the end of the tail call.
  *)
  let #(all_data2, key) =
    let #(wrapped, key) =
      Capsule.Prim.Key.with_password key ~f:(fun password ->
        List.map capsules ~f:(fun capsule ->
          Capsule.Prim.access ~password ~f:(fun access ->
            !(Capsule.Data.unwrap ~access capsule)))
        |> Modes.Aliased.wrap)
    in
    #(Modes.Aliased.unwrap wrapped, key)
  in
  let _ = all_data1 in
  let _ = key in
  print_endline "Hello, world!"
;;