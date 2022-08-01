const std = @import("std");
const testing = std.testing;

pub fn isIteratorContext(comptime Context: type) bool {
    const has_nextFn = @hasDecl(Context, "nextFn");
    const has_peekAheadFn = @hasDecl(Context, "peekAheadFn");
    const has_skipFn = @hasDecl(Context, "skipFn");
    return has_nextFn and has_peekAheadFn and has_skipFn;
}

pub fn assertIteratorContext(comptime Context: type) void {
    if (!isIteratorContext(Context)) {
        @compileError("Context is not a IteratorContext");
    }
}

pub fn isDoubleEndedIteratorContext(comptime Context: type) bool {
    assertIteratorContext(Context);
    const has_nextBackwardFn = @hasDecl(Context, "nextBackFn");
    const has_skipBackFn = @hasDecl(Context, "skipBackFn");
    const has_peekBackwardFn = @hasDecl(Context, "peekBackwardFn");
    return has_nextBackwardFn and has_skipBackFn and has_peekBackwardFn;
}

pub fn assertDoubleEndedIteratorContext(comptime Context: type) void {
    if (!isDoubleEndedIteratorContext(Context)) {
        @compileError("Context is not a DoubleEndedMapContext");
    }
}

pub fn testIterator(it: anytype, expected: anytype) !void {
    for (expected) |item| {
        try testing.expectEqual(item, it.next().?);
    }
    try testing.expect(it.next() == null);
}
