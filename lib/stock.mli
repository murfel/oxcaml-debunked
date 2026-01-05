@@ portable

type t

val create : price:float -> t @ portable
val price : t @ contended -> float

(* val create : price:float -> t @ portable @@ portable *)
(* val price : t @ contended -> float @@ portable *)
