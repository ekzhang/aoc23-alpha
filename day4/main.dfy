// Dafny has no File IO by default, so we need to define the method externally.
method
  {:extern "AdventOfCode", "GetInput"}
GetInput()
  returns (input: string)


method StringSplit(s: string, c: char) returns (parts: seq<string>) {
  parts := [];
  var part := "";
  for i := 0 to |s|
  {
    if s[i] == c {
      if |part| > 0 {
        parts := parts + [part];
        part := "";
      }
    } else {
      part := part + [s[i]];
    }
  }
  if |part| > 0 {
    parts := parts + [part];
  }
}

method StringToInt(s: string) returns (result: int)
  requires |s| > 0
  requires forall i :: 0 <= i < |s| ==> '0' <= s[i] <= '9'
  ensures result >= 0
{
  result := 0;
  for i := 0 to |s|
    invariant result >= 0
  {
    var ch := s[i];
    result := result * 10 + (ch - '0') as int;
  }
}

method ParseInt(s: string) returns (result: int)
  ensures result >= 0
{
  var found := "";
  var firstNumeral := false;
  for i := 0 to |s|
    invariant forall j :: 0 <= j < |found| ==> '0' <= found[j] <= '9'
  {
    var ch := s[i];
    if '0' <= ch <= '9' {
      found := found + [ch];
      firstNumeral := true;
    } else if firstNumeral {
      break;
    }
  }
  if |found| == 0 {
    print s, '|', found, '|', "warn: no numeral found in ParseInt\n";
    return 0; // Special case of the empty string
  }
  result := StringToInt(found);
}

method ScratchWins(line: string) returns (matches: int)
  ensures matches >= 0
{
  matches := 0;
  var parts := StringSplit(line, ':');
  if |parts| != 2 {
    print "warn: invalid line semicolons in Part1\n";
    return;
  }
  var cardNum := ParseInt(parts[0]);
  parts := StringSplit(parts[1], '|');
  if |parts| != 2 {
    print "warn: missing divider '|' in Part1\n";
    return;
  }
  var owned := StringSplit(parts[0], ' ');
  var winning := StringSplit(parts[1], ' ');

  var winningInts := {};
  for j := 0 to |winning|
    invariant |winningInts| <= j
  {
    var winningCard := ParseInt(winning[j]);
    winningInts := winningInts + {winningCard};
  }
  assert 0 <= |winningInts| <= |winning|;

  for i := 0 to |owned|
    invariant matches >= 0
  {
    var card := ParseInt(owned[i]);
    if card in winningInts {
      matches := matches + 1;
    }
  }
}

method Pow2(n: int) returns (result: int)
  requires n >= 0
  ensures result >= 1
{
  result := 1;
  for i := 0 to n
    invariant result >= 1
  {
    result := result * 2;
  }
}

method Main() {
  var input := GetInput();
  var lines := StringSplit(input, '\n');

  var cardCopies := new int[|lines|];
  for i := 0 to |lines| {
    cardCopies[i] := 1;
  }

  var totalPoints := 0;
  for i := 0 to |lines| {
    var matches := ScratchWins(lines[i]);
    var points := Pow2(matches);
    totalPoints := totalPoints + points;
    for j := i + 1 to i + matches + 1 {
      if j < |lines| {
        cardCopies[j] := cardCopies[j] + cardCopies[i];
      }
    }
  }

  // Part 1
  print totalPoints, "\n";

  // Part 2
  var totalCards := 0;
  for i := 0 to |lines| {
    totalCards := totalCards + cardCopies[i];
  }
  print totalCards, "\n";
}
