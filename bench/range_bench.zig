const std = @import("std");
const debug = std.debug;
const RangeContext = @import("../src/range.zig").RangeContext;
const range = @import("../src/range.zig").range;
const Range64 = RangeContext(u64);

const MAX: u64 = 5_000_000;

fn whileLoop(times: u64) void {
    var i: u64 = 0;
    while (i < times) : (i += 1) {
        asm volatile ("" ::: "memory");
    }
}

fn rangeLoop(times: u64) void {
    var iter = range(u64, 0, times, 1);

    while (iter.next()) |_| {
        asm volatile ("" ::: "memory");
    }
}

fn rangeContextLoop(times: u64) void {
    var iter = Range64.init(0, times, 1);

    while (iter.nextFn()) |_| {
        asm volatile ("" ::: "memory");
    }
}

fn bench() void {
    var i: u64 = 40;
    while (i < MAX) : (i *= 10) {
        var start = std.time.nanoTimestamp();
        whileLoop(i);
        var end = std.time.nanoTimestamp();
        const whileTime = end - start;

        start = std.time.nanoTimestamp();
        rangeLoop(i);
        end = std.time.nanoTimestamp();
        const contextTime = end - start;

        start = std.time.nanoTimestamp();
        rangeLoop(i);
        end = std.time.nanoTimestamp();
        const rangeTime = end - start;

        debug.print(
            \\
            \\
            \\  times: {}
            \\  while  :       {}ns  base
            \\  context:       {}ns ~{} times
            \\  range  :       {}ns ~{} times
            \\
            \\
        , .{
            i,
            whileTime,
            contextTime,
            @intToFloat(f64, contextTime + 1) / @intToFloat(f64, whileTime + 1),
            rangeTime,
            @intToFloat(f64, rangeTime + 1) / @intToFloat(f64, whileTime + 1),
        });
    }
}

pub fn main() anyerror!void {
    bench();
}
