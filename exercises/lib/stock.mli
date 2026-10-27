(* The record holds only a string and a float, so it crosses portability. *)
type t : value mod portable

val create : ticker:string -> price:float -> t @@ portable

(* [ticker] is immutable, so it can be read from a [contended] stock. *)
val ticker : t @ contended -> string @@ portable

(* [price] is mutable, so reading or writing it requires an [uncontended] stock. *)
val price : t @ shared -> float @@ portable
val set_price : t -> float -> unit @@ portable
