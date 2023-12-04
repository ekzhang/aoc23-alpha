method
  {:extern "AdventOfCode", "GetInput"}
GetInput()
  returns (input: string)

method Abs(x: int) returns (y: int)
  ensures 0 <= y
{
  if x < 0 {
    return -x;
  } else {
    return x;
  }
}

method Main() {
  print "hello, world\n";

  var x := GetInput();
  print x;

  assert 2 == 2;
}
