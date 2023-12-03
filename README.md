# aoc23-alpha

_Advent of Code 2023 solved with 25 languages, in alphabetical order._

Languages are how we express and develop computational ideas; a dialogue between the programmer & designer. I know most of the popular ones, so I picked some cool specimens that I'm curious about.

I did a similar thing once before [in 2021](https://github.com/ekzhang/aoc21-alpha), but that challenge had relatively tamer languages. This year will be a little more “out there.”

## Schedule

As usual, the hardest problems are at the end, so it's a balance between coolness and the practicality of me actually being able to solve the challenges.

1. `A` is for **ARM64 Assembly** — [ARMv8.5-A](https://en.wikipedia.org/wiki/AArch64#ARMv8.5-A)
2. `B` is for **BQN** — _finally, an APL for your flying saucer_
3. `C` is for **Carp** — _a statically typed lisp, without GC, for real-time applications_
4. `D` is for **Dafny** — _a verification-ready programming language_
5. `E` is for **Erlang** — _practical functional programming for a parallel world_
6. `F` is for **Flix** — _polymorphic effect system and first-class Datalog constraints_
7. `G` is for **Gleam** — _a friendly language for building type-safe systems that scale_
8. `H` is for **Hylo** — _mutable value semantics and generic programming_
9. `I` is for **Io** — _dynamic prototypes in the same realm as Smalltalk and Self_
10. `J` is for **Java bytecode** — [JASM assembler](https://github.com/roscopeco/jasm)
11. `K` is for **Koka** — _functional language with effects_
12. `L` is for **Lean** — _interactive theorem prover_
13. `M` is for **Mojo** — _Python with systems and metaprogramming features_
14. `N` is for **Nim** — _compiled, garbage-collected systems programming_
15. `O` is for **OCaml** — [OCaml 5.1.0](https://ocaml.org/releases/5.1.0)
16. `P` is for **Pony** — _capabilities-secure, high-performance actors_
17. `Q` is for **Quadro** — [Rust-CUDA](https://github.com/Rust-GPU/Rust-CUDA) (yes, this is a stretch)
18. `R` is for **Raku** — _formerly known as Perl 6_
19. `S` is for **Swift** — [Swift 5.9](https://www.swift.org/blog/swift-5.9-released/)
20. `T` is for **Tcl** — _a very simple programming language_
21. `U` is for **Unison** — _purely functional language for distributed systems_
22. `V` is for **Vale** — _single ownership with constraint references for memory safety_
23. `W` is for **WebAssembly** — [Wasmtime v15](https://wasmtime.dev/) with Rust
24. `Y` is for **Yuescript** — _a Moonscript dialect that compiles to Lua_
25. `Z` is for **Zig** — _general-purpose systems, without garbage collection_

We're skipping X because the only reasonable language I could find was x86-64 assembly, and I'm definitely not solving day 23 in assembly!

## Development

First, create a `.env` file containing your session token from the Advent of Code website, so that the input data can be downloaded. For example:

```
SESSION=30b5d4e5790f02d4c32c71f59f10d5f2f6adfcf5b4c064c64a689ab02b4beb3e84bf74857e40cc9fe31088972fedeb64
```

Then, if you have [Python 3](https://python.org/) and [Just](https://github.com/casey/just) installed, as well as the language runtime for a given day's solution, you can load the input data and run the solution with:

```
just run <day1|day2|...>
```

Each day's solutions are located in their respective folder `dayN`. The source code reads from standard input, and it is executed using the script `run.sh`.

## Complete Run

If you have all of the required packages for the 25 languages installed, you can run all of the solutions sequentially with the command:

```
just run-all
```

This takes about a minute on my computer, since it needs to compile code in addition to running it.

## Runtime Environment

This is my runtime environment for each language on macOS Ventura v13.2.1, M1 / ARM64 processor, with Rosetta 2 and Xcode CLT. I only used languages that I could install on my own machine; these instructions aren't guaranteed to work on other operating systems or processor architectures.

- **Day 1:** Apple clang version 14.0.3, target arm64-apple-darwin22.3.0.
- **Day 2:** [CBQN v0.4.0](https://github.com/dzaima/CBQN), vendored as submodule and built with Make.
- **Day 3:** [Carp v0.5.5](https://github.com/carp-lang/Carp), binary installation in script.

Note that while exact version numbers are provided above, the code will likely work with newer versions of these languages as well. Also, assume a global dependency on Python 3.11+, Node v20, and NPM v9.
