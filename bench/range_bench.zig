const std = @import("std");
const debug = std.debug;
const RangeContext = @import("../src/range.zig").RangeContext;
const range = @import("../src/range.zig").range;
const Range64 = RangeContext(u64);

const TIMES: u64 = 1_000_000;

fn whileLoop() void {
    var i: u64 = 0;
    while (i < TIMES) : (i += 1) {
        asm volatile ("" ::: "memory");
    }
}

fn rangeLoop() void {
    var iter = range(u64, 0, TIMES, 1);

    while (iter.next()) |_| {
        asm volatile ("" ::: "memory");
    }
}

fn rangeContextLoop() void {
    var iter = Range64.init(0, TIMES, 1);

    while (iter.nextFn()) |_| {
        asm volatile ("" ::: "memory");
    }
}

pub fn main() anyerror!void {
    var start = std.time.nanoTimestamp();
    whileLoop();
    var end = std.time.nanoTimestamp();
    const whileTime = end - start;

    start = std.time.nanoTimestamp();
    rangeLoop();
    end = std.time.nanoTimestamp();
    const contextTime = end - start;

    start = std.time.nanoTimestamp();
    rangeLoop();
    end = std.time.nanoTimestamp();
    const rangeTime = end - start;

    debug.print(
        \\  while  :       {}ns  base
        \\  context:       {}ns {} times
        \\  range  :       {}ns {} times
    , .{
        whileTime,
        contextTime,
        @divFloor(contextTime, whileTime),
        rangeTime,
        @divFloor(rangeTime, whileTime),
    });
}
