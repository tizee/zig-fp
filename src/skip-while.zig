const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

/// The SkipWhile iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedSkipWhileContext(comptime Context: type, comptime FilterFn: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        filterFn: FilterFn,
        fused: bool = false,
        context: Context,

        pub fn init(context: InnerContextType, filterFn: FilterFn) Self {
            return Self{
                .filterFn = filterFn,
                .context = context,
                .fused = false,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            _ = self;
            return .{};
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.filterFn(value)) {
                        return null;
                    } else {
                        count += 1;
                    }
                    i += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekBackwardFn(i)) |value| {
                    if (self.filterFn(value)) {
                        return null;
                    } else {
                        count += 1;
                    }
                    i += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekBackwardFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.fused) {
                return self.context.nextFn();
            }
            while (self.context.nextFn()) |value| {
                if (self.filterFn(value)) {
                    continue;
                } else {
                    self.fused = true;
                    return value;
                }
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.fused) {
                return self.context.nextBackFn();
            }
            while (self.context.nextBackFn()) |value| {
                if (self.filterFn(value)) {
                    continue;
                } else {
                    self.fused = true;
                    return value;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.fused) {
                return self.context.skipFn();
            }
            while (self.context.skipFn()) |value| {
                if (self.filterFn(value)) {
                    continue;
                } else {
                    self.fused = true;
                    return true;
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.fused) {
                return self.context.skipBackFn();
            }
            while (self.context.skipBackFn()) |value| {
                if (self.filterFn(value)) {
                    continue;
                } else {
                    self.fused = true;
                    return true;
                }
            }
            return false;
        }

        pub fn reverseFn(self: *Self) void {
            self.fused = false;
            self.context.reverseFn();
        }
    };
}

pub fn SkipWhileContext(comptime Context: type, comptime FilterFn: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        filterFn: FilterFn,
        fused: bool = false,
        context: Context,

        pub fn init(context: InnerContextType, filterFn: FilterFn) Self {
            return Self{
                .filterFn = filterFn,
                .context = context,
                .fused = false,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            _ = self;
            return .{};
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.filterFn(value)) {
                        return null;
                    } else {
                        count += 1;
                    }
                    i += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.fused) {
                return self.context.nextFn();
            }
            while (self.context.nextFn()) |value| {
                if (self.filterFn(value)) {
                    continue;
                } else {
                    self.fused = true;
                    return value;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.fused) {
                return self.context.skipFn();
            }
            while (self.context.skipFn()) |value| {
                if (self.filterFn(value)) {
                    continue;
                } else {
                    self.fused = true;
                    return true;
                }
            }
            return false;
        }
    };
}

/// A SkipWhile Iterator constructor
/// It's actually a wrapper over an iterator
pub fn SkipWhileIterator(comptime Context: type, comptime FilterFn: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const SkipWhileContextType = DoubleEndedSkipWhileContext(Context, FilterFn);
        return IIterator(SkipWhileContextType);
    } else {
        const SkipWhileContextType = SkipWhileContext(Context, FilterFn);
        return IIterator(SkipWhileContextType);
    }
}

pub fn skipWhile(s: anytype, func: anytype) SkipWhileIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s))), @TypeOf(func)) {
    return SliceIter.slice(s).skip_while(func);
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const slice = @import("slice.zig").slice;

test "test SkipWhile method" {
    const ints: []const u32 = &[_]u32{ 2, 4, 6, 8, 1, 3, 5, 7 };
    const truths: []const u32 = &[_]u32{ 1, 3, 5, 7 };

    const S = struct {
        pub fn is_even(cur: u32) bool {
            return cur % 2 == 0;
        }
    }.is_even;
    var skip_while_iter = skipWhile(ints, S);
    try IterAssert.testIterator(skip_while_iter, truths, 4, .{});
}

test "test SkipWhile method with std" {
    var str: []const u8 = "1234abcd";
    var truths: []const u8 = "abcd";

    var skip_while_iter = skipWhile(str, std.ascii.isDigit);

    try IterAssert.testIterator(skip_while_iter, truths, 4, .{});
}
