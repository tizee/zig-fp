const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

/// The filter iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedFilterContext(comptime Context: type, comptime FilterFn: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        func: FilterFn,
        context: Context,

        pub fn init(context: InnerContextType, func: FilterFn) Self {
            return Self{
                .func = func,
                .context = context,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                return self.context.sizeHintFn();
            } else {
                return {};
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.func(value)) {
                        count += 1;
                    }
                    i += 1;
                } else {
                    break;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekBackwardFn(i)) |value| {
                    if (self.func(value)) {
                        count += 1;
                    }
                    i += 1;
                } else {
                    break;
                }
            }
            return self.context.peekBackwardFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            while (true) {
                if (self.context.nextFn()) |value| {
                    if (self.func(value)) {
                        return value;
                    }
                } else {
                    break;
                }
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            var i: usize = 0;
            while (true) {
                if (self.context.nextBackFn()) |value| {
                    if (self.func(value)) {
                        return value;
                    }
                    i += 1;
                } else {
                    break;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.peekAheadFn(0)) |value| {
                if (self.func(value)) {
                    return true;
                } else {
                    self.context.skipFn();
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            while (self.context.peekBackwardFn(0)) |value| {
                if (self.func(value)) {
                    return true;
                } else {
                    self.context.skipBackFn();
                }
            }
            return false;
        }

        pub fn reverseFn(self: *Self) void {
            self.context.reverseFn();
        }
    };
}

pub fn FilterContext(comptime Context: type, comptime FilterFn: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        func: FilterFn = null,
        context: Context,

        pub fn init(context: InnerContextType, func: FilterFn) Self {
            return Self{
                .func = func,
                .context = context,
            };
        }

        /// return 0 if the context does not support
        /// size_hint
        pub fn size_hint(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                return self.context.sizeHintFn();
            } else {
                return 0;
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.func(value)) {
                        count += 1;
                    }
                } else {
                    break;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            while (self.context.nextFn()) |value| {
                if (self.func(value)) {
                    return value;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.nexFn()) |_| {
                return true;
            }
            return false;
        }
    };
}

/// A Filter Iterator constructor
/// It's actually a wrapper over an iterator
pub fn FilterIterator(comptime Context: type, comptime FilterFn: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const FilterContextType = DoubleEndedFilterContext(Context, FilterFn);
        return IIterator(FilterContextType);
    } else {
        const FilterContextType = FilterContext(Context, FilterFn);
        return IIterator(FilterContextType);
    }
}

pub fn filter(s: anytype, func: anytype) FilterIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s))), @TypeOf(func)) {
    return SliceIter.slice(s).filter(func);
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const slice = @import("slice.zig").slice;

test "test filter with map" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    var iter = slice(ints);

    const S = struct {
        pub fn is_even(cur: u32) bool {
            return cur % 2 == 0;
        }
    }.is_even;
    var filter_iter = iter.filter(S);

    const Fn = struct {
        pub fn toChar(old: u32) bool {
            if (@mod(old, 2) == 0) {
                return true;
            } else {
                return false;
            }
        }
    }.toChar;

    var map_iter = filter_iter.map(Fn);

    while (map_iter.next()) |value| {
        debug.print("map_iter result {}\n", .{value});
    }
}

test "test filter method" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };

    const S = struct {
        pub fn is_even(cur: u32) bool {
            return cur % 2 == 0;
        }
    }.is_even;
    var filter_iter = filter(ints, S);

    const Fn = struct {
        pub fn toChar(old: u32) bool {
            if (@mod(old, 2) == 0) {
                return true;
            } else {
                return false;
            }
        }
    }.toChar;

    var map_iter = filter_iter.map(Fn);

    while (map_iter.next()) |value| {
        debug.print("map_iter result {}\n", .{value});
    }
}

test "test filter method with std" {
    var str: []const u8 = "abcd1234";

    var map_iter = filter(str, std.ascii.isDigit);

    var truth: []const u8 = str[4..];
    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
    try testing.expectEqual(@as(usize, 4), i);
}
