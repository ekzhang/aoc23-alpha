// I know they're very different even in paradigm, but Koka actually reminds me
// a little bit of Nim or Crystal. Compiled, statically-typed, flexible syntax,
// trailing blocks, and a noise-free appearance. I like it.
//
// Koka's focus is on minimalism and generality ("min-gen"). Notably, the
// tutorial just shares neat tidbits of syntax like blocks, effects, and loop
// constructs that are actually ordinary function with lambdas. The "with"
// statement is an especially neat trick that makes CPS palatable.
//
// I don't have many opinions on the algebraic effect system. Not sure exactly
// how the hierarchy works with total / console / div / ndet.
//
// It's unclear to me how _practical_ algebraic effects and termination checking
// are in practice. I would need to use the language more to find out. My
// suspicion is that proving program termination is not too interesting since an
// O(10^100) function is no better than a diverging one.
//
// Although a bit quirky, since it's able to avoid explicit Monads, it might be
// a nice language for exploring foundations. Like Haskell, but easier. I could
// imagine implementing "Build Systems à la Carte" in Koka.
//
// Also curious how effects relate to Context, Hooks, and "Suspend" in React.
//
// I will say that with all of the interesting ideas here, writing actual code
// with all this purity feels awesome. Also, why is the whitespace funny around
// function arguments! `N.repeat` blocks are awesome though. :')

import std/os/readline

fun read-input() : <console,div> list<string>
  // It took me 15 minutes to figure out how to catch an exception for the first
  // time, haha. Tried every combination of handlers.
  match readline.try fn(_) { "" }
    "" -> []
    input -> [input] ++ read-input()

fun transpose( grid : list<list<a>> ) : div list<list<a>>
  val first-col = grid.filter-map(head)
  match first-col
    [] -> []
    _  -> [first-col] ++ transpose(grid.map(tail))

// Returns all rows where all chars are repeated '.' chars.
fun empty-rows( grid : list<list<char>> ) : list<int>
  val indices = grid.map-indexed fn(i, row)
    match row.all(fn(c) { c == '.' })
      True -> Just(i)
      False -> Nothing
  indices.concat-maybe

// Returns all "#" characters in the grid.
fun galaxies( grid : list<list<char>> ) : list<(int,int)>
  val pos = grid.map-indexed fn(i, row)
    row.map-indexed fn(j, c)
      match c
        '#' -> Just((i,j))
        _   -> Nothing
  pos.concat.concat-maybe

fun pairs( xs : list<a> ) : div list<(a,a)>
  match xs.head
    Nothing -> []
    Just(x) -> xs.tail.map(fn(y) { (x,y) }) ++ pairs(xs.tail)

fun is-between( x : int, a : int, b : int ) : div bool
  (x >= a && x <= b) || (x >= b && x <= a)

fun main() : <console,pure> ()
  val grid = read-input().map(list)  // list<list<char>>
  val transposed-grid = grid.transpose()

  // println(grid.show-list(string))
  // val n = grid.length
  // val m = grid[0].unjust.length

  val erows = empty-rows(grid)
  val ecols = empty-rows(transposed-grid)

  val expanded-dists = fn(n)
    grid.galaxies.pairs.map fn(((a1,b1),(a2,b2)))
      val rdist = abs(a2 - a1) + (n - 1) * erows.filter fn(i) { i.is-between(a1, a2) }.length
      val cdist = abs(b2 - b1) + (n - 1) * ecols.filter fn(i) { i.is-between(b1, b2) }.length
      rdist + cdist

  // Part 1
  println(expanded-dists(2).sum)

  // Part 2
  println(expanded-dists(1000000).sum)
