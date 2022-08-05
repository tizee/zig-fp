const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

/// The TakeWhile iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedTakeWhileContext(comptime Context: type, comptime FilterFn: type) type {
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
                        count += 1;
                    } else {
                        return null;
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
                        count += 1;
                    } else {
                        return null;
                    }
                    i += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekBackwardFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                if (self.filterFn(value)) {
                    return value;
                } else {
                    self.fused = true;
                }
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.context.nextBackFn()) |value| {
                if (self.filterFn(value)) {
                    return value;
                } else {
                    self.fused = true;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.context.skipFn()) |value| {
                if (self.filterFn(value)) {
                    return true;
                } else {
                    self.fused = true;
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.context.skipBackFn()) |value| {
                if (self.filterFn(value)) {
                    return true;
                } else {
                    self.fused = true;
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

pub fn TakeWhileContext(comptime Context: type, comptime FilterFn: type) type {
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
            return {};
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.filterFn(value)) {
                        count += 1;
                    } else {
                        return null;
                    }
                    i += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                if (self.filterFn(value)) {
                    return value;
                } else {
                    self.fused = true;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.context.skipFn()) |value| {
                if (self.filterFn(value)) {
                    return true;
                } else {
                    self.fused = true;
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

/// A TakeWhile Iterator constructor
/// It's actually a wrapper over an iterator
pub fn TakeWhileIterator(comptime Context: type, comptime FilterFn: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const TakeWhileContextType = DoubleEndedTakeWhileContext(Context, FilterFn);
        return IIterator(TakeWhileContextType);
    } else {
        const TakeWhileContextType = TakeWhileContext(Context, FilterFn);
        return IIterator(TakeWhileContextType);
    }
}

pub fn takeWhile(s: anytype, func: anytype) TakeWhileIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s))), @TypeOf(func)) {
    return SliceIter.slice(s).take_while(func);
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const slice = @import("slice.zig").slice;

test "test takeWhile method" {
    const ints: []const u32 = &[_]u32{ 2, 4, 6, 8, 9 };
    const truths: []const u32 = &[_]u32{ 2, 4, 6, 8 };

    const S = struct {
        pub fn is_even(cur: u32) bool {
            return cur % 2 == 0;
        }
    }.is_even;
    var take_while_iter = takeWhile(ints, S);
    try IterAssert.testIterator(take_while_iter, truths, 4, .{});
}

test "test takeWhile method with std" {
    var str: []const u8 = "1234abcd";
    var truths: []const u8 = "1234";

    var take_while_iter = takeWhile(str, std.ascii.isDigit);

    try IterAssert.testIterator(take_while_iter, truths, 4, .{});
}
