(* Parallel box blur, from
   https://oxcaml.org/documentation/tutorials/intro-to-parallelism-part-2/#image-processing *)

module Par_array = Parallel.Arrays.Array

(* The tutorial's [Capsule] API (keys, passwords, [Data.project]) is [Capsule.Prim] in the
   installed [capsule] library. *)
module Capsule = Capsule.Prim

(* A minimal grayscale image. Pixels are stored in an immutable [iarray] so [get] can read
   them at [shared]; the tutorial's [set] is omitted since the example never mutates an
   image. *)
module Image : sig
  type t : mutable_data

  val of_array : float array -> width:int -> height:int -> t
  val width : t @ contended -> int
  val height : t @ contended -> int
  val get : t @ shared -> x:int -> y:int -> float
end = struct
  type t =
    { width : int
    ; height : int
    ; pixels : float iarray
    }

  let of_array pixels ~width ~height =
    { width; height; pixels = Core.Iarray.of_array pixels }
  ;;

  let width (t @ contended) = t.width
  let height (t @ contended) = t.height
  let get (t @ shared) ~x ~y = Core.Iarray.get t.pixels ((y * t.width) + x)
end

let clamp n ~min ~max = if n < min then min else if n > max then max else n

let blur_at image ~x ~y =
  let width = Image.width image in
  let height = Image.height image in
  let acc = ref 0. in
  let radius = 4 in
  for i = -radius to radius do
    for j = -radius to radius do
      let x = clamp (x + i) ~min:0 ~max:(width - 1) in
      let y = clamp (y + j) ~min:0 ~max:(height - 1) in
      acc := !acc +. Image.get image ~x ~y
    done
  done;
  !acc /. Float.of_int (((2 * radius) + 1) * ((2 * radius) + 1))
;;

(* A boxed pixel. [Par_array.init] can't produce bare floats (it would break the float
   array optimisation), and [Key.access_shared] must return a [unique] value: a freshly
   allocated record is unique, and the [aliased] modality lets the float inside be
   aliased. *)
type pixel = { value : float @@ aliased }

(* Every pixel only reads the source image, so shared access through the key is enough: no
   mutex, and all pixels are computed in parallel. *)
let filter ~key image =
  Parallel_scheduler.with_parallel (fun parallel ->
    let width = Image.width (Capsule.Data.project image) in
    let height = Image.height (Capsule.Data.project image) in
    let pixels = width * height in
    let data =
      Par_array.init parallel pixels ~f:(fun _parallel i ->
        let x = i mod width in
        let y = i / width in
        Capsule.Key.access_shared key ~f:(fun access ->
          let image = Capsule.Data.unwrap_shared image ~access in
          { value = blur_at image ~x ~y }))
    in
    Par_array.to_array data
    |> Array.map (fun { value } -> value)
    |> Image.of_array ~width ~height)
;;

let () =
  let width = 4
  and height = 3 in
  let (P key) = Capsule.create () in
  let image =
    Capsule.Data.create (fun () ->
      Image.of_array (Array.init (width * height) Float.of_int) ~width ~height)
  in
  let blurred = filter ~key image in
  for y = 0 to height - 1 do
    for x = 0 to width - 1 do
      Printf.printf "%5.2f " (Image.get blurred ~x ~y)
    done;
    print_newline ()
  done
;;
