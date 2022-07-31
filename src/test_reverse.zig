const std = @import("std");
const testing = std.testing;
const ReverseIterator = @import("reverse.zig").ReverseIterator;
const debug = std.debug;

test "Test Reversed for string" {
    const Iterator = ReverseIterator(u8);
    const str = "abcdefgh";
    var context = Iterator.IterContext.init(str);
    var iter = Iterator.initWithContext(context);

    var i: usize = str.len;
    while (iter.next()) |value| {
        i -= 1;
        try testing.expectEqual(str[i], value);
    }

    context = context.reset();
    iter = Iterator.initWithContext(context);
    if (iter.skip()) {
        i = str.len - 1;
        while (iter.next()) |value| {
            i -= 1;
            try testing.expectEqual(str[i], value);
        }
    } else {
        unreachable;
    }
}

test "Test Reversed for string" {
    const Point = struct {
        x: i32,
        y: i32,
    };
    const Iterator = ReverseIterator(Point);

    const slice = &[_]Point{
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
    var context = Iterator.IterContext.init(slice);
    var iter = Iterator.initWithContext(context);

    var i: usize = slice.len;
    while (iter.next()) |value| {
        i -= 1;
        debug.print("{}\n", .{value});
        try testing.expectEqual(slice[i], value);
    }

    context = context.reset();
    iter = Iterator.initWithContext(context);
    if (iter.skip()) {
        i = slice.len - 1;
        while (iter.next()) |value| {
            i -= 1;
            debug.print("{}\n", .{value});
            try testing.expectEqual(slice[i], value);
        }
    } else {
        unreachable;
    }
}
