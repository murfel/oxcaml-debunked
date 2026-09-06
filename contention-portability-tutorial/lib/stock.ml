type t = { price : float }

let create ~price = { price }
let price { price } = price
