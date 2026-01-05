module Mood = struct
  type t =
    | Happy
    | Neutral
    | Sad
end

type t =
  { price : float
  ; mutable mood : Mood.t
  }

let create ~price ~mood = { price; mood }
let price { price; _ } = price
let mood { mood; _ } = mood
let cheer_up t = t.mood <- Happy
