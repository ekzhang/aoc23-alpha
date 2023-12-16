# What the heck is Mojo, anyway? Supposedly I can just write ordinary Python
# code here, and it should work, so... let's find out!

from python import Python


fn input(prompt: StringLiteral) -> String:
    # Not off to a great start, how do I get input? Needs some type coercions.
    try:
        let builtins = Python.import_module("builtins")
        let input_function = builtins.input
        let user_input: PythonObject = input_function(String(prompt))
        return str(user_input)
    except:
        return String("")


fn part1(grid: DynamicVector[String]) raises -> Int:
    # This feels quite a bit more verbose than Python for unnecessary reasons.
    for i in range(len(grid) - 1):
        var ok = True
        for k in range(len(grid)):
            if i - k < 0 or i + 1 + k >= len(grid):
                break
            if grid[i - k] != grid[i + 1 + k]:
                ok = False
                break
        if ok:
            return 100 * (i + 1)

    for j in range(len(grid[0]) - 1):
        var ok = True
        for k in range(len(grid[0])):
            if j - k < 0 or j + 1 + k >= len(grid[0]):
                break
            for i in range(len(grid)):
                if grid[i][j - k] != grid[i][j + 1 + k]:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            return j + 1

    raise Error("No mirror image found in part1")


fn part2(grid: DynamicVector[String]) raises -> Int:
    # Hmm, if I were to write this in Python, it could be a lot shorter.
    for i in range(len(grid) - 1):
        var diff = 0
        for k in range(len(grid)):
            if i - k < 0 or i + 1 + k >= len(grid):
                break
            for j in range(len(grid[0])):
                if grid[i - k][j] != grid[i + 1 + k][j]:
                    diff += 1
        if diff == 1:
            return 100 * (i + 1)

    for j in range(len(grid[0]) - 1):
        var diff = 0
        for k in range(len(grid[0])):
            if j - k < 0 or j + 1 + k >= len(grid[0]):
                break
            for i in range(len(grid)):
                if grid[i][j - k] != grid[i][j + 1 + k]:
                    diff += 1
        if diff == 1:
            return j + 1

    raise Error("No mirror image found in part2")


fn main() raises:
    var total_part1 = 0
    var total_part2 = 0

    var grid = DynamicVector[String]()
    while True:
        let line = input("")
        if not line:
            if not len(grid):
                break

            total_part1 += part1(grid)
            total_part2 += part2(grid)

            grid.clear()
            continue
        grid.append(line)

    print(total_part1)
    print(total_part2)
