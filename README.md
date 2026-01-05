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
