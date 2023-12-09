// And… yet another BEAM VM language. It's my season of Erlang!
//
// First impressions: Gleam appears to be a statically typed functional
// programming language that compiles to Erlang (and JS?). It comes with the
// classic cocktail of functional programming features, plus immutable data
// types and an actor model for concurrency.
//
// It's initially unclear to me how different Gleam is from Elixir, since both
// have immutable variables, rely on the Erlang runtime, and have modern syntax.
// I guess Gleam has static typing and appears a bit more Rusty.
//
// Let's start writing code! It looks like a simple language.
//
// The book and examples have no loops though. I guess I could write everything
// recursively? It's not as natural as in Erlang or Haskell though, where
// function declarations come with pattern matching included.
//
// Nevermind: Didn't need to do any recursion at all! The functional programming
// library functions feel ergonomic, like OCaml / F#, but more effortless.

import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order.{type Order, Eq}
import gleam/result
import gleam/string
import simplifile.{read}

fn display(obj: a) {
  io.println(string.inspect(obj))
}

// Given in the problem statemenet.
fn rank(c: UtfCodepoint, part2: Bool) -> Int {
  // There's no literal syntax for chars, so I guess I'll convert the codepoint
  // back to a string and match on that?
  let s = string.from_utf_codepoints([c])
  case s {
    "2" -> 2
    "3" -> 3
    "4" -> 4
    "5" -> 5
    "6" -> 6
    "7" -> 7
    "8" -> 8
    "9" -> 9
    "T" -> 10
    "J" ->
      case part2 {
        True -> 1
        False -> 11
      }
    "Q" -> 12
    "K" -> 13
    "A" -> 14
  }
}

// Returns the partition of a string, like "KKAKA" -> [3, 2].
fn get_partition(hand: String) -> List(Int) {
  string.to_utf_codepoints(hand)
  |> list.fold(
    dict.new(),
    fn(m, c) { dict.update(m, c, fn(x) { option.unwrap(x, 0) + 1 }) },
  )
  |> dict.values
  |> list.sort(by: order.reverse(int.compare))
}

// Compute the highest-rank partition including J "wildcards".
fn get_partition_wildcard(hand: String) -> List(Int) {
  let counts =
    string.to_utf_codepoints(hand)
    |> list.fold(
      dict.new(),
      fn(m, c) { dict.update(m, c, fn(x) { option.unwrap(x, 0) + 1 }) },
    )

  // This seems awkward, but there's no other way to create `UtfCodepoint` types.
  let assert [joker] = string.to_utf_codepoints("J")
  let wildcards = result.unwrap(dict.get(counts, joker), 0)

  case
    dict.delete(counts, joker)
    |> dict.values
    |> list.sort(by: order.reverse(int.compare))
  {
    [f, ..rest] -> [f + wildcards, ..rest]
    [] -> [wildcards]
  }
}

// Compare two lists of ints in lexicographic order.
fn lexicographic(a: List(Int), b: List(Int)) -> Order {
  list.zip(a, b)
  |> list.fold_until(
    None,
    fn(_, x) {
      case int.compare(x.0, x.1) {
        Eq -> list.Continue(None)
        c -> list.Stop(Some(c))
      }
    },
  )
  |> option.lazy_unwrap(fn() { int.compare(list.length(a), list.length(b)) })
}

fn compare_part1(h1: #(String, Int), h2: #(String, Int)) -> Order {
  let p1 = get_partition(h1.0)
  let p2 = get_partition(h2.0)
  case lexicographic(p1, p2) {
    Eq ->
      lexicographic(
        string.to_utf_codepoints(h1.0)
        |> list.map(rank(_, False)),
        string.to_utf_codepoints(h2.0)
        |> list.map(rank(_, False)),
      )
    c -> c
  }
}

fn compare_part2(h1: #(String, Int), h2: #(String, Int)) -> Order {
  let p1 = get_partition_wildcard(h1.0)
  let p2 = get_partition_wildcard(h2.0)
  case lexicographic(p1, p2) {
    Eq ->
      lexicographic(
        string.to_utf_codepoints(h1.0)
        |> list.map(rank(_, True)),
        string.to_utf_codepoints(h2.0)
        |> list.map(rank(_, True)),
      )
    c -> c
  }
}

fn score(hands: List(#(String, Int))) -> Int {
  hands
  |> list.index_map(with: fn(i, x) { { i + 1 } * x.1 })
  |> int.sum
}

pub fn main() {
  let assert Ok(file) = read(from: "input.txt")

  let hands =
    file
    |> string.trim_right
    |> string.split(on: "\n")
    |> list.map(with: fn(s) {
      let assert [hand, score] = string.split(s, on: " ")
      let assert Ok(score) = int.parse(score)
      #(hand, score)
    })

  // Part 1
  list.sort(hands, by: compare_part1)
  |> score
  |> display

  // Part 2
  list.sort(hands, by: compare_part2)
  |> score
  |> display
}
