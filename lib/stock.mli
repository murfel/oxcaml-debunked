type t

val create : price:float -> t
val price : t -> float

(* val create : price:float -> t @ portable @@ portable *)
(* val price : t @ contended -> float @@ portable *)
