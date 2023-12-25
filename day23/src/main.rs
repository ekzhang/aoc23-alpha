// Ahh, writing a solution in Rust feels so good. Nice to be using a language
// that I'm very comfortable with again.
//
// I thought compiling to WASI would be more difficult, but actually I didn't
// have to make any code changes. It's just a cross-platform, portable binary
// that runs in a sandbox. Nice!
//
// Long recursion depths can cause stack overflow. You _could_ just fix it by
// setting `ulimit -s` very high, as in competitive programming, but I decided
// to challenge myself with a non-recursive solution instead. We can do this by
// explicitly pushing the "backtrack" operation onto the stack.
//
// By the way, Part 2 is a pretty CPU-intensive bitmask DP. It takes about 1.3
// seconds to run this solution, even with a somewhat optimized bitmask DP.
// Native code (not WASM) only takes 1.0 seconds for the same.

use std::io;

use fnv::{FnvHashMap, FnvHashSet};

type Pos = (i32, i32);

enum Op {
    Move(Pos),
    Backtrack,
}

fn longest_path(tile: impl Fn(Pos) -> u8, src: Pos, dst: Pos) -> u32 {
    let mut ret = 0;
    let mut stack = vec![Op::Move(src)];
    let mut path = Vec::new();
    let mut path_set = FnvHashSet::default();

    while let Some(op) = stack.pop() {
        match op {
            Op::Move(pos) => {
                if pos == dst {
                    ret = ret.max(path.len() as u32);
                } else {
                    let moves = match tile(pos) {
                        b'#' => continue,
                        b'.' => vec![(1, 0), (-1, 0), (0, 1), (0, -1)],
                        b'>' => vec![(0, 1)],
                        b'v' => vec![(1, 0)],
                        b'<' => vec![(0, -1)],
                        b'^' => vec![(-1, 0)],
                        t => panic!("invalid tile {t}"),
                    };

                    path.push(pos);
                    path_set.insert(pos);
                    stack.push(Op::Backtrack);
                    for (di, dj) in moves {
                        let n = (pos.0 + di, pos.1 + dj);
                        if !path_set.contains(&n) {
                            stack.push(Op::Move(n));
                        }
                    }
                }
            }
            Op::Backtrack => {
                let pos = path.pop().expect("failed backtrack");
                path_set.remove(&pos);
            }
        }
    }

    ret
}

/// Return an adjacency list of the graph formed by contracting all paths in the
/// grid, indexed by the index in the `vertices` vector.
fn contracted_neighbors(tile: impl Fn(Pos) -> u8, vertices: &[Pos]) -> Vec<Vec<(u32, u32)>> {
    let mut adj = Vec::new();
    for start in vertices {
        let mut search = vec![(*start, *start, 0)];
        let mut current_adj = Vec::new();
        while let Some((pos, last, dist)) = search.pop() {
            if let Some(j) = vertices.iter().position(|&v| v == pos) {
                if pos != *start {
                    current_adj.push((j as u32, dist));
                    continue;
                }
            }
            for (di, dj) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                let n = (pos.0 + di, pos.1 + dj);
                if n != last && tile(n) != b'#' {
                    search.push((n, pos, dist + 1));
                }
            }
        }
        adj.push(current_adj);
    }
    adj
}

/// Computes the longest path in a graph with memoized recursive bitmasks.
fn graph_longest_path(
    adj: &[Vec<(u32, u32)>],
    dst: u32,
    n: u32,
    visited: u64,
    memo: &mut FnvHashMap<(u32, u64), Option<u32>>,
) -> Option<u32> {
    if n == dst {
        return Some(0);
    }
    if let Some(&dist) = memo.get(&(n, visited)) {
        return dist;
    }
    let mut dist = None;
    for &(j, d) in &adj[n as usize] {
        if visited & (1 << j) == 0 {
            if let Some(len) = graph_longest_path(adj, dst, j, visited | (1 << j), memo) {
                dist = Some(dist.unwrap_or(0).max(d + len));
            }
        }
    }
    memo.insert((n, visited), dist);
    dist
}

fn main() {
    let mut grid = Vec::new();
    for line in io::stdin().lines() {
        grid.push(line.unwrap().as_bytes().to_vec());
    }

    let tile = |(i, j)| {
        if i < 0 || i >= grid.len() as i32 || j < 0 || j >= grid[0].len() as i32 {
            b'#'
        } else {
            grid[i as usize][j as usize]
        }
    };

    let src = (0, 1);
    let dst = ((grid.len() - 1) as i32, (grid[0].len() - 2) as i32);

    // Part 1
    println!("{}", longest_path(tile, src, dst,));

    // Part 2
    let mut vertices = vec![src, dst];
    for i in 0..(grid.len() as i32) {
        for j in 0..(grid.len() as i32) {
            if tile((i, j)) == b'#' {
                continue;
            }
            let mut num_adj = 0;
            for (di, dj) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                if tile((i + di, j + dj)) != b'#' {
                    num_adj += 1;
                }
            }
            if num_adj > 2 {
                vertices.push((i, j));
            }
        }
    }
    let adj = contracted_neighbors(tile, &vertices);
    println!(
        "{}",
        graph_longest_path(&adj, 1, 0, 1, &mut FnvHashMap::default()).unwrap()
    );
}
