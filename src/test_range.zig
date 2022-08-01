const std = @import("std");
const testing = std.testing;
const RangeIterator = @import("Range.zig").RangeIterator;
const range = @import("Range.zig").range;
const debug = std.debug;

fn testRange(comptime T: type) anyerror!void {
    const Range = RangeIterator(T);
    var iter = range(T, 1, 10, 1);

    var val: T = 1;
    while (iter.next()) |value| {
        try testing.expectEqual(val, value);
        val += 1;
    }
    try testing.expectEqual(@as(?T, null), iter.peek());

    comptime {
        if (T == i32 or T == i8 or T == i16 or T == i64 or T == i128 or T == c_short or T == c_int or T == c_long or T == c_longlong or T == c_longdouble or T == f16 or T == f32 or T == f64 or T == f80 or T == f128) {
            var context1 = Range.IterContext.init(10, 1, -1);
            var iter1 = Range.initWithContext(context1);
            var val1 = 10;
            while (iter1.next()) |value| {
                try testing.expectEqual(val1, value);
                val1 -= 1;
            }
        }
    }

    iter = range(T, 1, 4, 1);
    try testing.expectEqual(@as(?T, 1), iter.next());
    if (iter.skip()) {
        if (iter.next()) |value| {
            try testing.expectEqual(@as(T, 3), value);
        }
        if (iter.next()) |value| {
            try testing.expectEqual(@as(T, 4), value);
        }
        try testing.expectEqual(@as(?T, null), iter.next());
    } else {
        unreachable;
    }
}

test "Test Range for primitives" {
    try testRange(u8);
    try testRange(i8);
    try testRange(u16);
    try testRange(i16);
    try testRange(u32);
    try testRange(i32);
    try testRange(u64);
    try testRange(i64);
    try testRange(u128);
    try testRange(i128);
    try testRange(usize);
    try testRange(isize);
    try testRange(c_ushort);
    try testRange(c_short);
    try testRange(c_ulong);
    try testRange(c_long);
    try testRange(c_ulonglong);
    try testRange(c_longlong);
    try testRange(c_longdouble);
    try testRange(f16);
    try testRange(f32);
    try testRange(f64);
    try testRange(f80);
    try testRange(f128);
}
