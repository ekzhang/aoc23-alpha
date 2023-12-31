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
8. `H` is for **Haskell** — [GHC 9.8.1](https://www.haskell.org/ghc/)
9. `I` is for **Io** — _dynamic prototypes in the same realm as Smalltalk and Self_
10. `J` is for **Java bytecode** — _write once, run anywhere_
11. `K` is for **Koka** — _functional language with effects_
12. `L` is for **Lean** — _interactive theorem prover_
13. `M` is for **Mojo** — _Python with systems and metaprogramming features_
14. `N` is for **Nim** — _compiled, garbage-collected systems programming_
15. `O` is for **OCaml** — [OCaml 5.1.0](https://ocaml.org/releases/5.1.0)
16. `P` is for **Pony** — _capabilities-secure, high-performance actors_
17. `Q` is for **Qi** — _lightweight, fast interpreted language written in Chinese_
18. `R` is for **Raku** — _formerly known as Perl 6_
19. `S` is for **Swift** — [Swift 5.8.1](https://www.swift.org/blog/swift-5.8-released/)
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

## Runtime Environment

This is my runtime environment for each language on macOS Ventura v13.2.1, M1 / ARM64 processor, with Rosetta 2 and Xcode CLT. I only used languages that I could install on my own machine; these instructions aren't guaranteed to work on other operating systems or processor architectures.

- **Day 1:** Apple clang version 14.0.3, target arm64-apple-darwin22.3.0
- **Day 2:** [CBQN 0.4.0](https://github.com/dzaima/CBQN), vendored as submodule and built with Make
- **Day 3:** [Carp 0.5.5](https://github.com/carp-lang/Carp), binary installation in script
- **Day 4:** [Dafny 4.3.0](https://github.com/dafny-lang/dafny) via VSCode extension, with dotnet-sdk 8.0.100 installed via Homebrew Cask
- **Day 5:** Erlang/OTP 26.0.2, installed from Homebrew
- **Day 6:** [Flix 0.42.0](https://github.com/flix/flix/releases/tag/v0.42.0), included in script, with Java runtime OpenJDK 21.0.1 from Homebrew
- **Day 7:** [Gleam 0.32.4](https://gleam.run/), installed from Homebrew, with Erlang/OTP 26.0.2
- **Day 8:** GHC 9.8.1, Cabal 3.10.2.0, installed via GHCup 0.1.20.0; with LLVM 12.0.1
- **Day 9:** Io Programming Language, v. 20151111 installed via Homebrew for x86-64
- **Day 10:** Jasmin v2.4, from Homebrew, with OpenJDK 21
- **Day 11:** [Koka 2.4.2](https://koka-lang.github.io/koka/doc/book.html), installed from the script on the website
- **Day 12:** Lean 4.3.0, installed with the [elan](https://github.com/leanprover/elan) version manager, via Homebrew
- **Day 13:** Mojo 0.6.0 (d55c0025), via proprietary installer
- **Day 14:** Nim 2.0.0, from Homebrew
- **Day 15:** OCaml 4.12.0, installed via opam 2.1.0, from Homebrew
- **Day 16:** ponyc-release-0.55.1-arm64-darwin, from ponyup nightly-20230822, with manually patched symlinks for libressl `libcrypto.50.dylib -> libcrypto.52.dylib` and `libssl.53.dylib -> libssl.55.dylib`
- **Day 17:** [Qi 21b3195](https://github.com/AnonymousAAArdvark/qi/tree/21b3195bb315b4cec0568f2814cc32d940b03657), vendored as submodule and built with Make
- **Day 18:** Rakudo 2023.11 from Homebrew, implementing Raku 6.d
- **Day 19:** Apple Swift 5.8.1, targeting arm64-apple-macosx13.0
- **Day 20:** Tcl 8.6.13 from Homebrew
- **Day 21:** TBD
- **Day 22:** TBD
- **Day 23:** Rust 1.72.1, with Wasmtime 16.0.0
- **Day 24:** Yuescript 0.21.3, vendored as submodule and built with Make, and Lua 5.4.6
- **Day 25:** Zig 0.11.0, from release binary (zigup)

Note that while exact version numbers are provided above, the code will likely work with newer versions of these languages as well. Also, assume a global dependency on Python 3.11+, Node v20, and NPM v9.
