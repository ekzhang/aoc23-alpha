import std/[algorithm, sequtils, strutils, sugar, tables]

proc tilt(s: string): string =
  ## Tilt a string, moving all rocks forward in index.
  ## e.g. tilt("O..O.#.") == "...OOX."
  var res = newString(s.len)
  var rocks = 0
  for i in 0 .. s.len:
    if i < s.len:
      res[i] = if s[i] == '#': '#' else: '.'
    if i == s.len or (s[i] == '#' and rocks > 0):
      var j = i
      while rocks > 0:
        j -= 1
        res[j] = 'O'
        rocks -= 1
    elif s[i] == 'O':
      rocks += 1
  res

proc tiltBack(s: string): string =
  var res = s
  res.reverse()
  res = tilt(res)
  res.reverse()
  res

proc totalLoad(grid: seq[string]): int =
  var load = 0
  for i in 0 ..< grid.len:
    for j in 0 ..< grid[i].len:
      if grid[i][j] == 'O':
        load += grid.len - i
  load

proc flip(grid: seq[string]): seq[string] =
  var cols = newSeq[string]()
  for i in 0 ..< grid[0].len:
    let col = collect(newSeqOfCap(grid.len)):
      for line in grid:
        line[i]
    cols.add(col.join "")
  cols


when isMainModule:
  var grid = newSeq[string]()

  while true:
    try:
      let line = stdin.readLine
      grid.add(line)
    except EOFError:
      break

  # Part 1
  echo grid.flip.map(tiltBack).flip.totalLoad

  # Part 2
  var memory = initTable[string, int]()
  var cycles = 1000000000
  while cycles > 0:
    memory[grid.join "|"] = cycles
    let gridN = grid.flip.map(tiltBack).flip;
    let gridW = gridN.map(tiltBack);
    let gridS = gridW.flip.map(tilt).flip;
    let gridE = gridS.map(tilt);
    cycles -= 1
    grid = gridE
    if memory.hasKey(grid.join "|"):
      let cycle = memory[grid.join "|"]
      cycles = cycles mod (cycle - cycles)
  echo grid.totalLoad
