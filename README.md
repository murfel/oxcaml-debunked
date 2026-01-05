## References

- https://oxcaml.org/documentation/tutorials/01-intro-to-parallelism-part-1 (better redability on [github](https://github.com/oxcaml/oxcaml/blob/main/jane/doc/extensions/_01-tutorials/01-intro-to-parallelism-part-1.md)) ([commit](https://github.com/oxcaml/oxcaml/blob/6aabd693a02d4c4bfbca826b9b1705a0ac6d3e3c/jane/doc/extensions/_01-tutorials/01-intro-to-parallelism-part-1.md)) (add4, average, Thing examples are from here)
- https://gavinleroy.com/oxcaml-tutorial-icfp25/#68 + quiz https://gavinleroy.com/oxcaml-icfp-activity/ + activities 1-4 (atomics + capsules, not portability/contention in particular) https://github.com/oxcaml/tutorial-icfp25/tree/main/handson_activity
- https://youtu.be/kuoT6CrSY70?si=S1aEHfuNffIs_6Je&t=233
- https://dl.acm.org/doi/epdf/10.1145/3704859

> ... **Base functions are annotated with modes, but the OCaml stdlib is not**. The answer right now is to **always use Base with OxCaml**.
https://anil.recoil.org/notes/icfp25-oxcaml 
>
>[**Is Base fully annotated, though?**]

## Run
Run with
```
dune exec bin/add4.exe
dune exec bin/average.exe
```

Also

```
dune utop
open Par_samples;;
let x = Thing.create ~price:3.0 ~mood:Happy;;
x;;
Thing.price x;;
```


To get the compiler tree dump like `stocks_01_shared_read_compiler_tree_dump.txt`, modify `bin/dune`:
```dune
 (names stocks_01_shared_read)  ;; only leave the module you want
 (flags (:standard -principal -dtypedtree))
```
Run `dune build --verbose`
