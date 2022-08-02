const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const SizeHint = @import("core/size-hint.zig").SizeHint;

pub fn isSlice(comptime Ptr: type) bool {
    const info = @typeInfo(Ptr);
    return info == .Pointer and info.Pointer.size == .Slice;
}

pub fn assertSlice(comptime Ptr: type) void {
    if (!isSlice(Ptr)) {
        @compileError("require a Slice type");
    }
}

pub fn GetPtrChildType(comptime Ptr: type) type {
    const info = @typeInfo(Ptr);
    if (info == .Array) {
        return info.Array.child;
    } else if (info == .Pointer and info.Pointer.size == .Slice) {
        return info.Pointer.child;
    }
    return Ptr;
}

pub fn isFloat(comptime T: type) bool {
    return @typeInfo(T) == .Float;
}

pub fn isInteger(comptime T: type) bool {
    return @typeInfo(T) == .Int;
}

pub fn assertNum(comptime T: type) void {
    if (!isInteger(T) and !isFloat(T)) {
        @compileError("require a Number type");
    }
}

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

pub fn testIterator(it: anytype, expected: anytype, len: usize, hint: SizeHint) !void {
    var iter_ = it;
    try testing.expectEqual(hint, iter_.size_hint());

    var i: usize = 0;
    for (expected) |item| {
        try testing.expectEqual(item, iter_.next().?);
        i += 1;
    }
    try testing.expect(iter_.next() == null);
    try testing.expectEqual(len, i);
}
