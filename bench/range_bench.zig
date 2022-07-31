const std = @import("std");
const iterator = @import("../src/iterator.zig");

const TIMES: u64 = 500_000;
const RangeIter_u64 = iterator.RangeIterator(u64);

fn whileLoop() void {
    var i: u64 = 0;
    while (i < TIMES) : (i += 1) {
        asm volatile ("" ::: "memory");
    }
}

fn rangeLoop() void {
    var context = RangeIter_u64.IterContext.init(0, TIMES, 1);
    var iter = RangeIter_u64.initWithContext(context);

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
