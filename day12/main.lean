-- I'm going to be honest, Lean isn't the best language for this unless you for
-- whatever reason wanted to formalize a proof of the DP?
--
-- But as the saying goes: "If it has a display, it can run Doom."
--
-- Let's do this. References:
--   * https://lean-lang.org/functional_programming_in_lean
--   * https://github.com/leanprover/lean4/blob/v4.3.0/src/Init/System/IO.lean
--
-- It's actually okay for scripting! Quite friendly and sensible. There's just
-- not a lot of places to get documentation. It seems targeted at mathematicians
-- who want to do some programming.
--
-- Definitely more palatable with Haskell background.

partial def getLines (stream : IO.FS.Stream) : IO (Array String) :=
  let rec read (lines : Array String) := do
    let line <- stream.getLine
    if line.length == 0 then
      pure lines
    else if line.back == '\n' then
      read <| lines.push (line.dropRight 1)
    else
      pure <| lines.push line
  read #[]

def parseLine (line : String) : (Prod String (List Nat)) :=
  let (arr, strnums) := match line.split (· == ' ') with
  | [a, b] => (a, b.split (· == ','))
  | _ => panic! "bad input"
  let nums := match strnums.mapM String.toNat? with
  | some ns => ns
  | none => panic! "bad input nums"
  (arr, nums)

def arrangements (s : String) (nums : List Nat) : Nat :=
  let n := s.length
  let k := nums.length
  let chars := s.toList

  -- Answer is dp[n + 1][k]. I don't know enough about theorem-proving to fix
  -- the "failed to prove index is valid" error well, so I'll just add runtime
  -- checks for this issue.
  let ans := Id.run do
    let mut dp := #[#[1] ++ Array.mkArray k 0]
    for i in [1:n+2] do
      let mut cur := #[]
      for j in [0:k+1] do
        let mut x := 0
        if i == n + 1 || chars[i - 1]! != '#' then
          x := dp[i - 1]![j]!
          if j > 0 then
            let d := nums[j - 1]!
            let substr := (s.drop (i - d - 1)).take d
            if i >= d + 1 && substr.all (λ c => c == '#' || c == '?') then
              x := x + dp[i - d - 1]![j - 1]!
        cur := cur.push x
      dp := dp.push cur
    dp[n + 1]![k]!

  ans

def part1 (line : String) : Nat :=
  let (s, nums) := parseLine line
  arrangements s nums

def part2 (line : String) : Nat :=
  let (s, nums) := parseLine line
  let s := String.join [s, "?", s, "?", s, "?", s, "?", s]
  let nums := nums ++ nums ++ nums ++ nums ++ nums
  arrangements s nums

def main : IO Unit := do
  let stdin <- IO.getStdin
  let lines <- getLines stdin
  IO.println <| ((lines.map part1).foldl Nat.add 0)
  IO.println <| ((lines.map part2).foldl Nat.add 0)
