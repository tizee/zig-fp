const std = @import("std");
const testing = std.testing;
const SliceIterator = @import("slice.zig").SliceIterator;
const slice = @import("slice.zig").slice;
const SizeHint = @import("core/size-hint.zig").SizeHint;
const testIterator = @import("utils.zig").testIterator;
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

test "test slice" {
    const str: []const u8 = "abcd";
    var iter = slice(str);

    var i: usize = 0;
    while (iter.next()) |value| {
        try testing.expectEqual(str[i], value);
        i += 1;
        debug.print("{}\n", .{value});
    }
}

test "test slice size_hint" {
    const str: []const u8 = "abcd";
    var iter = slice(str);
    try testIterator(iter, str, 4, SizeHint{
        .low = 4,
        .high = 4,
    });
}

test "test slice ducking types" {
    const StrIter = SliceIterator(u8);
    const str: []const u8 = "abcd";

    var context = StrIter.IterContext.init(str);
    var iter = StrIter.initWithContext(context);

    var iter2 = slice(str);

    try testing.expect(@TypeOf(iter2) == @TypeOf(iter));
}
