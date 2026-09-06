# Contention and portability

{pause}

OCaml 5 introduced multidomain computing

{pause}

Domain = thread

{pause}

Multithreading is hard

{pause}

**Data races**

Recipe
- **Two domains**
- access **mutable data**
- **without synchronization**
- and one of these accesses is a **write**

{pause}

OxCaml **contention** and **portability** mode axes 
prevent data races in **compile time**, part of type checking.

{pause}

**Building blocks** of multidomain computing in OxCaml:

- Mode axes: **contention**, **portability**
- Synchronization primitives: **atomics**, **capsules**
- Domain management framework (fork-join pool)

---

{pause up}
### Modes

{pause}

- A type decides what a value is
- A mode decides how you can use a value of a type

{pause}

```ocaml
val foo : int * int ref @ mode -> unit
```

{pause}

```ocaml
let foo (p @ mode) = ...
```

{pause}

```ocaml
let p = (5, ref 42)
foo p
```

---

{pause up}

### Anatomy of a value

A value contains **data** and **functions**

{pause}

```ocaml
let p = (ref 42, (fun x -> x + 1))
```

{pause}

Where a data race occurs

{pause}

* mutable non-protected data

{pause}

* functions capturing _mutable non-protected data_

{pause}

* functions capturing _function capturing mutable non-protected data_

* etc.

---

{pause up}

### Contention mode axis

Relates to **data**, decides if you can read and write

{pause}

#### Data has immutable and mutable parts

{pause}

### Crosses contention
Immutable data

{pause}

#### Mutable data has synchronized or not synchronized parts

{pause}

### `@ contended` $\implies$ safe to access from multiple domains
Full access to **synchronized mutable data** (atomic, mutex)

No access to any other mutable data parts of the value (temporary hidden, compiler won't allow access)

[//]: # (### `@ shared` $\implies$ safe to READ from multiple domains)
[//]: # (Full **read** access to mutable data protected by a synchronization primitive)
[//]: # (allowing to read &#40;reader-writer lock&#41; &#40;2&#41;)
[//]: # ()
[//]: # (Includes &#40;1&#41;)

{pause}

### `@ uncontended` $\implies$ safe to access from a single domain
Full access to **any mutable data**
 
Includes **synchronized mutable data** (atomic, mutex)

[//]: # (**Rule**: at most one domain can consired a value as `@ uncontended`)

{pause}

**NB**: both modes allow read access for immutable data

{pause up}
```ocaml
val foo : int * int ref @ mode -> ...
let foo (p @ mode) = ...
```

{pause}

{#contention-examples}
### A contended pair

```ocaml
let p = (5, ref 42)
let foo (p @ contended) = ...
foo p
```

{pause}

- **read** `fst p` ✅
- **write** `fst p` -
- **read** `snd p` ❌
- **write** `snd p` ❌

{pause}

Any domain can access `p`, but it can only invoke `fst p`

{pause up=contention-examples}

{#contended-pair-atomic}
### A contended pair with an atomic

```ocaml
let p = (5, ref (Atomic.make 42))
let foo (p @ contended) = ...
foo p
```

{pause}

- **read** `fst p` ✅
- **write** `fst p` -
- **read** `snd p` ✅
- **write** `snd p` ✅

{pause}

Any domain can access `p` fully

{pause up=contended-pair-atomic}
### An uncontended pair

```ocaml
let p @ uncontended = (5, ref 42)
let foo (p @ uncontended) = ...
foo p
```

{pause}

| | domain 1 | domain 2 |
|---|:---:|:---:|
| **read**  | ✅ | ❌ |
| **write** | ✅ | ❌ |

---

{pause up}
## Typechecker

```ocaml
let foo (p @ uncontended) = ...
foo p
```

Checks
- the argument can be passed in the required mode
- the function does not violate access restrictions for the mode

---

{pause up}
## Modes are deep

{pause}

A value is `@ mode` $\implies$ all its fields are `@ mode`, recursively

{pause}

```ocaml
val foo : int ref * int ref @ contended -> unit
(* => both int ref are contended *)
```

{pause}

To contruct a value `@ mode`, all its parts must be `@ mode` (or compatible with `@ mode`)

{pause}

```ocaml
val modify : int ref * int ref @ uncontended -> unit

let bar (r1 @ uncontended) (r2 @ contended) = 
    modify (r1, r2) (* ❌ *)
```

---

{pause up}
## Submodding

{pause}

$\le$ means "can be used in place of"

`@ uncontended` $\le$ `@ contended`

{pause}

`@ uncontended` can be passed into a function expecting `@ contended`

```ocaml
let foo (p @ contended) = ...

let bar (p @ uncontended) = foo p (* ✅ *)
```

{pause}

Why?

A function taking a `@ contended` parameter is more restricted

A function taking a `@ contended` parameter is restricted access to everything but synchronized mutable data

A function taking a `@ uncontended` parameter is not restricted: it can access all its parameter's parts, including synchronized mutable data

[//]: # (Reminder: immutable data can be read in any mode because it crosses contention)

[//]: # (Using a value in a certain restrictive mode is like taking a restrictive view on the value: all the parts are still there, but you can only use some of them)

---
{pause up}
# Portability mode axis

Applies to **functions**, and **values containing functions**

{pause}

## How functions can cause a data race?

A function can **capture** and modify mutable data

{pause}

A function can capture _a reference to another function_ which captures and modifies mutable data

{pause}

{#portable}
## `@ portable` $\implies$ safe to invoke from multiple domains

- captures no data
- captures immutable data
- captures mutable data but never accesses it
- captures mutable data protected by a read-write synchronization primitive 

{pause}

And all functions it captures are also safe to invoke from multiple domains

{pause}

A **function** is `@ portable` if all its **captured** values are `@ contended` or `@ portable`

{pause}

A **value** is `@ portable` if all its components which are function are `@ portable`

{pause}

```ocaml
let incr (x @ uncontended) = x := !x + 1 (* @ portable function *)
let incr_list = [incr; incr; incr]  (* @ portable value *)
```

{pause up=portable}

## `@ nonportable` $\implies$ can only invoke from one domain

{pause}

A function is `@ nonportable` if it captures an `@ uncontended` or `@ nonportable` value

{pause}

```ocaml
let x = ref 0
let incr2 () = x := !x + 1  (* @ nonportable function *)
let incr2_list = [incr2; incr2; incr2]  (* @ nonportable value *)
```

{pause}

**Captured** values, not parameters, make a function `@ nonportable`

---

{pause up}
## Submodding

{pause}

`@ portable` $\le$ `@ nonportable`

{pause}

Recall
- A function is `@ portable` if all its captured values are `@ contended` and `@ portable`
- A function is `@ nonportable` if it captures some `@ uncontended` or `@ nonportable`

{pause}

A `@ portable` function can be used in place of `@ nonportable`,

{pause}

since parts of a value accessible in the `@ contended` mode is a subset of parts of a value accesssible in the `@ uncontended` mode

{pause}

```ocaml
let triple = (5, ref 42, (Atomic.make 100))
(* in @ contended you can access 5 and Atomic 100 *)
(* in @ uncontended you can access everything *)
```

{pause}

A `@ portable` function can at most modify the synchronized mutable data that it captures

A `@ nonportable` function can modify any data it captures

Hence, any `@ portable` function is `@ nonportable`

{pause}

This was explained from the "what a function can do" perspective

{pause up}
#### "How a function can be used" perspective

`@ portable` $\le$ `@ nonportable`

A `@ portable` function can be used in place of `@ nonportable`

{pause}

`@ portable` is allowing to run a function on multiple domains.
 
{pause}

If a function can run on multiple domains (and not cause a data race), it can also run on a single domain (and not cause a data race).

{pause}

`@ nonportable` guarantees that a function will only be inkoved on one domain

{pause}

```ocaml
val create : (unit -> 'a) @ nonportable -> 'a list
let create (f @ nonportable) = [f (); f (); f ()]

let counter = ref 0 in
let next_nonportable () = incr counter; !counter in
create next_nonportable (* => [1; 2; 3] *)

let counter = Atomic.make 0 in
let next_portable () = Atomic.fetch_and_add counter 1 + 1 in
create next_portable (* => [1; 2; 3] *)
```


---

{pause up}
## Spawning a domain

{pause}

- To spawn a domain, you specify a function

{pause}

- This function must be `@ portable`

```ocaml
val spawn : (unit -> 'a) @ portable -> 'a t
```

{pause}

- So all values it captures must be `@ contended` and `@ portable`

{pause}

- Inside, it may invoke `@ nonportable` functions capturing its own local variables

{pause}

- It may spawn new domains, but with `@ portable` functions only

{pause}

```ocaml
let p = (5, ref 42)
let d = Domain.spawn (fun () -> 
  (* the function to run in parallel *)
  ...
  fst p  (* p is captured as contended *)
  ...
  let x = ref 0 in
  ...
  let incr () = x := !x + 1 in (* nonportable *)
  ...
  incr ()
  ...
)
let result = Domain.join d
```

[//]: # (- A typical value flow: a value is created and used as `@ uncontended`, then passed to multiple functions as `@ contended`, and these functions can be invoked on multiple domains. After these domains join, the value can be used as `@ uncontended` again.)

[//]: # (---)

[//]: # ({pause up})

[//]: # (## Backward compatibility)

[//]: # (- OxCaml went from no domains to multidomains with contention and portability &#40;lucky!&#41;)

[//]: # (- Backward compatible with OCaml without domains)

[//]: # (- Default modes: everything is `@ uncontended` and `@ nonportable`)

[//]: # (- Need a new version of the standard library)

[//]: # ()
[//]: # (```ocaml)

[//]: # (stdlib example)

[//]: # (```)

---

{pause up}
## Summary

{pause}

Compile time

{pause}

(The compiler will infer many annotations itself)

{pause}

A value contains parts which are **data** and which are **functions**

{pause}

**Data**: `@ uncontended` $\le$ `@ contended` (contention axis)

{pause}

**Functions**: `@ portable` $\le$ `@ nonportable` (portability axis)

{pause}

Submodding: $\le$ means "can be used in place of"

{pause}

Deepness

{pause}

## Next
- ✅ contention and portability
- ✅ atomics
- **capsules** (mutex, read-write lock, `@ shared` mode on the contention axis)
- **fork-join framework** for spawning domains