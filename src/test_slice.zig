const std = @import("std");
const testing = std.testing;
const SliceIterator = @import("slice.zig").SliceIterator;
const debug = std.debug;

test "test SliceIterator" {
    const StrIter = SliceIterator(u8);
    const str = "abcd";
    var context = StrIter.IterContext.init(str);
    var iter = StrIter.initWithContext(context);

    var i: usize = 0;
    while (iter.next()) |value| {
        try testing.expectEqual(str[i], value);
        i += 1;
        debug.print("{}\n", .{value});
    }
    context = StrIter.IterContext.init(str);
    iter = StrIter.initWithContext(context);

    try testing.expectEqual(@as(?u8, str[0]), iter.peek());
    _ = iter.next();
    _ = iter.next();
    try testing.expectEqual(@as(?u8, str[2]), iter.peek());
}
