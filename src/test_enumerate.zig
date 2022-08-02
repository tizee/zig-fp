const std = @import("std");
const debug = std.debug;
const testing = std.testing;

const enumerate = @import("enumerate.zig").enumerate;
const slice = @import("slice.zig").slice;
const SizeHint = @import("core/size-hint.zig").SizeHint;

const testIterator = @import("utils.zig").testIterator;

test "test enumerate" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6 };

    var iter = enumerate(ints);
    for (ints) |value| {
        if (iter.next()) |tuple| {
            try testing.expectEqual(@as(usize, value - 1), tuple.index);
            try testing.expectEqual(@as(u32, value), tuple.value);
        }
    }
    try testing.expect(iter.next() == null);
}
