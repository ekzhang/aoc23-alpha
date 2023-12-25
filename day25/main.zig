// Zig is a nice systems programming language. Its safety and error handling
// make C less stressful.
//
// But to start out a project, you need to know how to customize a memory
// allocator and manage all of your memory manually. Those low-level details
// make a quick problem like this a bit verbose. Half of the code is just
// reading input!
//
// (If you're writing a database or high-performance system, you'd need to
// customize those things anyway, and the additional control is worth it.)
//
// I solved this with the Ford-Fulkerson algorithm, in linear time.

const std = @import("std");

const NodePair = std.meta.Tuple(&.{ u32, u32 });

/// Augment a flow by 1 unit using Ford-Fulkerson.
fn augment(
    adj: *const std.ArrayList(std.ArrayList(u32)),
    visited: []bool,
    flow: *std.AutoHashMap(NodePair, void),
    src: u32,
    dst: u32,
) !bool {
    if (src == dst) {
        return true;
    }

    visited[src] = true;
    for (adj.items[src].items) |u| {
        if (!visited[u] and flow.get(.{ src, u }) == null) {
            if (try augment(adj, visited, flow, u, dst)) {
                if (flow.get(.{ u, src }) != null) {
                    _ = flow.remove(.{ u, src });
                } else {
                    try flow.put(.{ src, u }, {});
                }
                return true;
            }
        }
    }

    return false;
}

pub fn main() !void {
    var input: [512]u8 = undefined;

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const alloc = gpa.allocator();
    const alloc = std.heap.c_allocator;

    var node_id = std.StringHashMap(u32).init(alloc);
    var adj = std.ArrayList(std.ArrayList(u32)).init(alloc);
    defer {
        for (adj.items) |a| {
            a.deinit();
        }
        adj.deinit();

        var it = node_id.iterator();
        while (it.next()) |entry| {
            alloc.free(entry.key_ptr.*);
        }
        node_id.deinit();
    }

    while (true) {
        const slice = stdin.readUntilDelimiter(&input, '\n') catch break;
        // try stdout.print("input: {s}\n", .{slice});

        var it = std.mem.split(u8, slice, ": ");
        const v = try (it.next() orelse error.InvalidInput);
        const us = try (it.next() orelse error.InvalidInput);

        const vi = node_id.get(v) orelse blk: {
            const x = @as(u32, node_id.count());
            try node_id.put(try alloc.dupe(u8, v), x);
            try adj.append(std.ArrayList(u32).init(alloc));
            break :blk x;
        };

        it = std.mem.split(u8, us, " ");
        while (it.next()) |u| {
            // try stdout.print("{s}: {s}\n", .{ v, u });
            const ui = node_id.get(u) orelse blk: {
                const x = @as(u32, node_id.count());
                try node_id.put(try alloc.dupe(u8, u), x);
                try adj.append(std.ArrayList(u32).init(alloc));
                break :blk x;
            };
            // try stdout.print("{}: {}\n", .{ vi, ui });
            try adj.items[vi].append(ui);
            try adj.items[ui].append(vi);
        }
    }

    const n = @as(u32, @truncate(adj.items.len));
    var j: u32 = 1;
    while (j < n) : (j += 1) {
        var flow = std.AutoHashMap(NodePair, void).init(alloc);
        defer flow.deinit();

        var visited = std.ArrayList(bool).init(alloc);
        defer visited.deinit();
        try visited.resize(n);

        // try stdout.print("augmenting: {}\n", .{j});
        var totalFlow: u32 = 0;
        while (true) : (totalFlow += 1) {
            for (adj.items, 0..) |_, i| {
                visited.items[i] = false;
            }
            if (!(try augment(&adj, visited.items, &flow, 0, j))) {
                break;
            }
        }

        if (totalFlow == 3) {
            var size: u32 = 0;
            for (visited.items) |b| {
                size += if (b) 1 else 0;
            }
            try stdout.print("{}\n", .{size * (n - size)});
            break;
        }
    }
}
