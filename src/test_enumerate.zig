const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const DoubleEndedEnumerateContext = @import("enumerate.zig").DoubleEndedEnumerateContext;
const EnumerateContext = @import("enumerate.zig").EnumerateContext;
const enumerate = @import("enumerate.zig").enumerate;
const slice = @import("slice.zig").slice;

test "test enumerate" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6 };
    var iter = enumerate(ints);

    var i: usize = 0;
    while (iter.next()) |value| : (i += 1) {
        try testing.expectEqual(i, value.index);
        try testing.expectEqual(i + 1, value.value);
    }
}
