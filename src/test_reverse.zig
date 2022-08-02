const std = @import("std");
const testing = std.testing;
const SliceIterator = @import("slice.zig").SliceIterator;
const slice = @import("slice.zig").slice;
const reverse = @import("reverse.zig").reverse;
const ReverseIterator = @import("reverse.zig").ReverseIterator;
const debug = std.debug;

test "Test Reversed for Int" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4 };

    var iter = slice(ints);

    var reversed_iter = iter.reverse();

    var i: usize = ints.len;
    while (reversed_iter.next()) |value| {
        i -= 1;
        debug.print("{} {}\n", .{ ints[i], value });
        try testing.expectEqual(ints[i], value);
    }
}

test "Test Reversed for string" {
    const Point = struct {
        x: i32,
        y: i32,
    };

    const points: []const Point = &[_]Point{
        .{
            .x = 1,
            .y = 1,
        },
        .{
            .x = 2,
            .y = 2,
        },
        .{
            .x = 3,
            .y = 3,
        },
        .{
            .x = 4,
            .y = 4,
        },
    };
    var iter = slice(points);

    var reversed_iter = iter.reverse();

    var i: usize = points.len;
    while (reversed_iter.next()) |value| {
        i -= 1;
        debug.print("{}\n", .{value});
        try testing.expectEqual(points[i], value);
    }
}

test "test reverse" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4 };

    var reversed_iter = reverse(ints);

    var i: usize = ints.len;
    while (reversed_iter.next()) |value| {
        i -= 1;
        debug.print("{} {}\n", .{ ints[i], value });
        try testing.expectEqual(ints[i], value);
    }
    try testing.expectEqual(@as(usize, 0), i);
    try testing.expectEqual(@as(?u32, null), reversed_iter.next());
}

test "test reverse reverse" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4 };

    var reversed_iter = reverse(ints)
        .reverse()
        .reverse()
        .reverse();

    var i: usize = 0;
    while (reversed_iter.next()) |value| : (i += 1) {
        debug.print("{} {}\n", .{ ints[i], value });
        try testing.expectEqual(ints[i], value);
    }
    try testing.expectEqual(@as(usize, 4), i);
    try testing.expectEqual(@as(?u32, null), reversed_iter.next());
}
