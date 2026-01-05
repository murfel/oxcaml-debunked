type t

module Mood : sig
  type t =
    | Happy
    | Neutral
    | Sad
end

val create : price:float -> mood:Mood.t -> t @ portable
  @@ portable
val price : t @ contended -> float @@ portable
val mood : t -> Mood.t
val cheer_up : t -> unit
