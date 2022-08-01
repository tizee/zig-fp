const std = @import("std");
const testing = std.testing;
const SliceIterator = @import("slice.zig").SliceIterator;
const ReverseIterator = @import("reverse.zig").ReverseIterator;
const debug = std.debug;

test "Test Reversed for Int" {
    const SliceInt = SliceIterator(u32);
    const str = &[_]u32{ 1, 2, 3, 4 };

    var context = SliceInt.IterContext.init(str);
    var iter = SliceInt.initWithContext(context);
    var reversed_iter = iter.reverse();
    debug.print("{} {}\n", .{ context.len, context.current });

    var i: usize = str.len;
    while (reversed_iter.next()) |value| {
        debug.print("context {} {}\n", .{ context.len, context.current });
        i -= 1;
        debug.print("{} {}\n", .{ str[i], value });
        try testing.expectEqual(str[i], value);
    }
}

test "Test Reversed for string" {
    const Point = struct {
        x: i32,
        y: i32,
    };
    const SlicePoint = SliceIterator(Point);

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
    var context = SlicePoint.IterContext.init(slice);
    var iter = SlicePoint.initWithContext(context);

    var reversed_iter = iter.reverse();

    var i: usize = slice.len;
    while (reversed_iter.next()) |value| {
        i -= 1;
        debug.print("{}\n", .{value});
        try testing.expectEqual(slice[i], value);
    }
}
