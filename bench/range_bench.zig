const std = @import("std");
const range = @import("../src/range.zig").range;

const TIMES: i64 = 500_000;

fn whileLoop() void {
    var i: i64 = TIMES;
    while (i > 0) : (i -= 1) {
        asm volatile ("" ::: "memory");
    }
}

fn rangeLoop() void {
    var iter = range(i64, TIMES, 0, -1);

    while (iter.next()) |_| {
        asm volatile ("" ::: "memory");
    }
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    const start = std.time.nanoTimestamp();
    whileLoop();
    const end = std.time.nanoTimestamp();
    try stdout.print("while-loop: {}ns\n", .{(end - start)});

    const iter_start = std.time.nanoTimestamp();
    rangeLoop();
    const iter_end = std.time.nanoTimestamp();
    try stdout.print("range-loop: {}ns\n", .{(iter_end - iter_start)});
}
