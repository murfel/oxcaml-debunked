type t =
  { ticker : string
  ; mutable price : float
  }

let create ~ticker ~price = { ticker; price }
let ticker { ticker; _ } = ticker
let price { price; _ } = price
let set_price t price = t.price <- price
