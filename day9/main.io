// The best way I can describe Io is as "metaprogramming paradise."
//
// I started using Io, and in the first minute, I had accidentally modified the
// global List prototype and was frantically figuring out how to fix it via
// introspection. And I was getting errors like "Object does not *respond* to …"
// when I had misspelt a variable. :')
//
// Don't even mention the fact that every object takes literals as messages, but
// it just shadows the object! WTF, that's so cool. And scary. But cool!
//
// Still going a bit over my head at the moment, but it'll come with time.
//
// What a crazy flexible syntax; almost every program is syntactically valid.
// And it's not as annoying to use as Lisp. Could probably jam on some cute DSL
// ideas here. It's still really easy & fun to write code! Feels a bit like BQN
// in way it composes, but with friendlier syntax.
//
// I found myself using the REPL a lot to see what methods were available, given
// the lack of documentation. But it's super concise.

extrapolate := method(
  nums := call target
  if(nums unique size == 1, return nums first)
  nums2 := List clone
  for(i, 0, nums size - 2,
    nums2 append(nums at(i + 1) - nums at(i))
  )
  nums last + nums2 extrapolate
)

lines := List clone

loop(
  line := File standardInput readLine
  if(line not, break)
  nums := line split map(asNumber)
  lines append(nums)
)

lines map(extrapolate) sum println
lines map(reverse) map(extrapolate) sum println

// Io's version of "return 0;" is just "0". I love it.
0
