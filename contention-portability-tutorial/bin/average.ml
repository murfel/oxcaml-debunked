open Par_samples

module Tree = struct
  type 'a t =
    | Leaf of 'a
    | Node of 'a t * 'a t
end

let _average (tree : float Tree.t) =
  let rec total tree : total:float * count:int =
    match tree with
    | Tree.Leaf x -> ~total:x, ~count:1
    | Tree.Node (l, r) ->
      let ~total:total_l, ~count:count_l = total l in
      let ~total:total_r, ~count:count_r = total r in
      ~total:(total_l +. total_r), ~count:(count_l + count_r)
  in
  let ~total, ~count = total tree in
  total /. (count |> Float.of_int)
;;

let _test_tree = Tree.Node (Leaf 3.0, Leaf 4.0)

let average_par (par : Parallel.t) tree =
  let rec (total @ portable) par tree : total:float * count:int =
    match tree with
    (*| Tree.Leaf x -> ~total:x, ~count:1*)
    | Tree.Leaf x -> ~total:(Thing.price x), ~count:1
    | Tree.Node (l, r) ->
      let #((~total:total_l, ~count:count_l), (~total:total_r, ~count:count_r)) =
        Parallel.fork_join2 par (fun par -> total par l) (fun par -> total par r)
      in
      ~total:(total_l +. total_r), ~count:(count_l + count_r)
  in
  let ~total, ~count = total par tree in
  total /. (count |> Float.of_int)
;;

let test_tree_thing =
  Tree.Node
    (Leaf (Thing.create ~price:3.0 ~mood:Happy), Leaf (Thing.create ~price:4.0 ~mood:Sad))
;;

let average_par_tree par = average_par par test_tree_thing

let () =
  let result = Parallel_utils.run_one_test ~f:average_par_tree in
  Printf.printf "result: %f\n" result
;;
