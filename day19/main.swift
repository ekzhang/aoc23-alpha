// Haven't written Swift before, but it felt nice. A statically-typed language
// with modern features and clean syntax. CoW value semantics are cool.
//
// Everything was effortless except dealing with strings and nil-handling.

import Foundation

// Declare a mutable map from string -> Array[(Rule?, String)]
struct Rule {
  let feature: Character // 'x', 'm', 'a', 's'
  let lt: Bool
  let value: Int
}

func parseBranch<T>(s: T) -> (Rule?, String) where T: StringProtocol {
  if s.contains(":") {
    let parts = s.split(separator: ":")
    let condition = parts[0]
    let result = parts[1]
    var rule: Rule
    if condition.contains("<") {
      let parts = condition.split(separator: "<")
      let value = Int(String(parts[1]))!
      rule = Rule(feature: parts[0].first!, lt: true, value: value)
    } else {
      let parts = condition.split(separator: ">")
      let value = Int(String(parts[1]))!
      rule = Rule(feature: parts[0].first!, lt: false, value: value)
    }
    return (rule, String(result))
  } else {
    return (nil, String(s))
  }
}

var rules = [String: [(Rule?, String)]]()

while let line = readLine() {
  if line.isEmpty {
    break
  }
  // Split a line into a name and contents
  let parts = line.split(separator: "{")
  let name = parts[0]
  rules[String(name)] = parts[1].dropLast().split(separator: ",").map {
    parseBranch(s: String($0))
  }
}

// Part 1
func simulate(_ item: [Character: Int]) -> Bool {
  var label = "in"
  while true {
    guard let clauses = rules[label] else {
      return label == "A"
    }
    for clause in clauses {
      if let c = clause.0 {
        let val = item[c.feature]!
        if (c.lt && val < c.value) || (!c.lt && val > c.value) {
          label = clause.1
          break
        }
      } else {
        label = clause.1
        break
      }
    }
  }
}

var totalRating = 0
while let line = readLine() {
  let vals = line.dropFirst().dropLast().split(separator: ",")
  var item = [Character: Int]()
  for val in vals {
    item[val.first!] = Int(String(val[val.index(val.startIndex, offsetBy: 2)...]))!
  }
  if simulate(item) {
    totalRating += item.values.reduce(0, +)
  }
}

print(totalRating)

// Part 2
func totalCombos(label: String, idx: Int, bounds: [Character: (Int, Int)]) -> Int64 {
  guard let clauses = rules[label] else {
    if label == "A" {
      return bounds.values.reduce(1) { $0 * Int64($1.1 - $1.0 + 1) }
    } else {
      return 0
    }
  }

  let (rule, result) = clauses[idx]
  if let rule = rule {
    let (lo, hi) = bounds[rule.feature]!
    var ans = Int64(0)
    if rule.lt {
      // x < rule.value
      if lo < rule.value {
        var newBounds = bounds
        newBounds[rule.feature] = (lo, rule.value - 1)
        ans += totalCombos(label: result, idx: 0, bounds: newBounds)
      }
      if hi >= rule.value {
        var newBounds = bounds
        newBounds[rule.feature] = (rule.value, hi)
        ans += totalCombos(label: label, idx: idx + 1, bounds: newBounds)
      }
    } else {
      // x > rule.value
      if hi > rule.value {
        var newBounds = bounds
        newBounds[rule.feature] = (rule.value + 1, hi)
        ans += totalCombos(label: result, idx: 0, bounds: newBounds)
      }
      if lo <= rule.value {
        var newBounds = bounds
        newBounds[rule.feature] = (lo, rule.value)
        ans += totalCombos(label: label, idx: idx + 1, bounds: newBounds)
      }
    }
    return ans
  } else {
    return totalCombos(label: result, idx: 0, bounds: bounds)
  }
}

print(totalCombos(
  label: "in",
  idx: 0,
  bounds: ["x": (1, 4000), "m": (1, 4000), "a": (1, 4000), "s": (1, 4000)]
))
