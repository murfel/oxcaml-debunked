open! Core
open Await

(* Each balance lives in its own capsule, protected by its own mutex. *)
type account = int ref Capsule.Sync.With_mutex.t

module Name = struct
  type t = string

  let equal = String.equal
  let hash = String.hash
end

(* A concurrent hashtable from user name to account. *)
type t = (string, account) Portable_lockfree_htbl.t

let create () : t = Portable_lockfree_htbl.create (module Name)

let open_account (t : t) name ~(balance : int) =
  let account = Capsule.Sync.With_mutex.create (fun () -> ref balance) in
  match Portable_lockfree_htbl.add t ~key:name ~data:account with
  | Null -> Ok ()
  | This _ -> Error ()
;;

let balance (sync : Sync.t @ local) (t : t) name =
  match Portable_lockfree_htbl.find t name with
  | Null -> Error ()
  | This account ->
    Ok (Capsule.Sync.With_mutex.with_lock sync account ~f:(fun _sync balance -> !balance))
;;

let transfer (sync : Sync.t @ local) (t : t) ~from ~to_ ~amount =
  match Portable_lockfree_htbl.find t from, Portable_lockfree_htbl.find t to_ with
  | Null, _ | _, Null -> Error ()
  | This from_account, This to_account ->
    if amount <= 0 || String.equal from to_
    then Error ()
    else (
      let from_first = String.( < ) from to_ in
      let first, second =
        if from_first then from_account, to_account else to_account, from_account
      in
      Capsule.Sync.With_mutex.with_scoped sync first ~f:(fun sync first ->
        Capsule.Sync.With_mutex.with_scoped sync second ~f:(fun _sync second ->
          let #(from_balance, to_balance) =
            if from_first then #(first, second) else #(second, first)
          in
          if Capsule.Scoped.get from_balance ~f:(fun balance -> !balance) < amount
          then Error ()
          else (
            Capsule.Scoped.iter from_balance ~f:(fun balance ->
              balance := !balance - amount);
            Capsule.Scoped.iter to_balance ~f:(fun balance ->
              balance := !balance + amount);
            Ok ()))
        [@nontail])
      [@nontail])
;;

let print_balance (sync : Sync.t @ local) (t : t) name =
  match balance sync t name with
  | Ok balance -> printf "  %s: %d\n" name balance
  | Error () -> printf "  %s: no such user\n" name
;;

let result_to_string result = if Result.is_ok result then "ok" else "error"

(* Usage example: opens two accounts, makes a few transfers and prints the results. *)
let () =
  let sync = Sync.blocking in
  let bank = create () in
  let _ = open_account bank "alice" ~balance:100 in
  let _ = open_account bank "bob" ~balance:50 in
  let try_transfer ~from ~to_ ~amount =
    let result = transfer sync bank ~from ~to_ ~amount in
    printf "transfer %s -> %s %d: %s\n" from to_ amount (result_to_string result)
  in
  print_endline "initial balances:";
  print_balance sync bank "alice";
  print_balance sync bank "bob";
  try_transfer ~from:"alice" ~to_:"bob" ~amount:30;
  try_transfer ~from:"bob" ~to_:"alice" ~amount:500;
  try_transfer ~from:"alice" ~to_:"carol" ~amount:10;
  print_endline "final balances:";
  print_balance sync bank "alice";
  print_balance sync bank "bob"
;;
