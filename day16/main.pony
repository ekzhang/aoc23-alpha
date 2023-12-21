// Pony is a capabilities-secure language with concurrent actors.
//
// It's really interesting! The different capabilities for mutability and
// aliasing kind of take Rust's borrowing model to an even stricter regime, but
// it also simplifies concurrency by having a garbage collector.
//
// I could see this being a useful model for secure network services. Would take
// some time to get used to the type system though. There's other quirks, like
// the HashSet.add() function actually cloning the entire data structure, and
// `iso`/`box` capabilities being incompatible.
//
// (The Pony documentation is really well-written, though!)

use "collections"
use "files"
use "itertools"

primitive Up is (Equatable[Direction] & Hashable)
  fun string(): String => "Up"
  fun hash(): USize => 1
primitive Down is (Equatable[Direction] & Hashable)
  fun string(): String => "Down"
  fun hash(): USize => 2
primitive Left is (Equatable[Direction] & Hashable)
  fun string(): String => "Left"
  fun hash(): USize => 3
primitive Right is (Equatable[Direction] & Hashable)
  fun string(): String => "Right"
  fun hash(): USize => 4

type Direction is (Up | Down | Left | Right)

primitive Dir
  fun move(i: I32, j: I32, dir: Direction): (I32, I32) =>
    """
    Move one square forward from a direction.
    """
    match dir
    | Up => (i - 1, j)
    | Down => (i + 1, j)
    | Left => (i, j - 1)
    | Right => (i, j + 1)
    end

  fun bounce(loc: U8, dir: Direction): Array[Direction] val =>
    """
    Bounce a current direction from the character at a location.
    """
    match loc
    | '\\' => match dir
      | Up => [Left]
      | Down => [Right]
      | Left => [Up]
      | Right => [Down]
      end
    | '/' => match dir
      | Up => [Right]
      | Down => [Left]
      | Left => [Down]
      | Right => [Up]
      end
    | '|' => match dir
      | Up | Down => [dir]
      | Left | Right => [Up; Down]
    end
    | '-' => match dir
      | Up | Down => [Left; Right]
      | Left | Right => [dir]
    end
    else
      [dir]
    end

class Laser is (Equatable[Laser] & Hashable)
  """
  An entry in the visited set of the grid. This is just needed to implement Hashable.
  """

  let i: I32
  let j: I32
  let dir: Direction

  new val create(i': I32, j': I32, dir': Direction) =>
    i = i'
    j = j'
    dir = dir'

  fun eq(that: Laser box): Bool =>
    """
    I spent a long time trying to figure out why my HashMap wasn't working, and
    it's because the default implementation of Equatable is reference equality.

    Definitely my fault, but still weird for a language that emphasizes absolute
    correctness without bugs.
    """
    (i == that.i) and (j == that.j) and (dir == that.dir)

  fun hash(): USize =>
    """
    Hash the entry. I'm not sure if there's a better way to do this.
    """
    (((i.hash() * 1000000007) + j.hash()) * 1000000007) + dir.hash()

  fun string(): String =>
    """
    Print the entry.
    """
    i.string() + ", " + j.string() + ", " + dir.string()


primitive Solver
  fun bfs(lines: Array[String] val, start: Laser val): Set[Laser val] ref =>
    """
    Find all visitable squares in the grid.
    """

    var visited = Set[Laser val]()
    let queue = List[Laser val].from([start])

    while true do
      let n = try queue.shift()? else break end
      let loc = try lines(n.i.usize())?(n.j.usize())? else continue end

      if not visited.contains(n) then
        visited.set(n)
        let dirs = Dir.bounce(loc, n.dir)

        for dir' in dirs.values() do
          (let i', let j') = Dir.move(n.i, n.j, dir')
          queue.push(Laser(i', j', dir'))
        end
      end
    end

    visited

  fun energized(lines: Array[String] val, start: Laser val): USize =>
    let visited = bfs(lines, start)
    Iter[Laser val](visited.values())
      .map[Laser val]({(n) => Laser(n.i, n.j, Left) })
      .unique[HashEq[Laser]]()
      .count()


actor Worker
  new create(parent: Main, lines: Array[String] val, start: Laser val) =>
    let result = Solver.energized(lines, start)
    parent.done_part2(result)


actor Main
  let env: Env
  var expected: USize = 0
  var results: Array[USize] = Array[USize]()

  new create(env': Env) =>
    env = env'

    let path = FilePath(FileAuth(env.root), "input.txt")
    let lines: Array[String] val = recover match OpenFile(path)
      | let file: File =>
        Iter[String](file.lines()).collect(Array[String]())
      else
        env.err.print("Error opening file 'input.txt'")
        return
      end
    end

    let n = lines.size()
    let m = try lines(0)?.size() else 0 end
    expected = 2 * (n + m)

    // Part 1
    env.out.print(Solver.energized(lines, Laser(0, 0, Right)).string())

    // Part 2
    var xs = Array[USize]()
    for i in Range(0, n) do
      Worker(this, lines, Laser(i.i32(), 0, Right))
      Worker(this, lines, Laser(i.i32(), m.i32() - 1, Left))
    end
    for j in Range(0, m) do
      Worker(this, lines, Laser(0, j.i32(), Down))
      Worker(this, lines, Laser(n.i32() - 1, j.i32(), Up))
    end

  be done_part2(x: USize) =>
    results.push(x)
    if results.size() == expected then
      let max = Iter[USize](results.values()).fold[USize](0, {(a, b) => if (a > b) then a else b end })
      env.out.print(max.string())
    end
