const math = @import("std").math;
const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

/// The Take iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedTakeContext(comptime Context: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context = undefined,
        total: usize = 1,
        number: usize = 1,

        pub fn init(context: InnerContextType, init_state: usize) Self {
            if (init_state == 0) {
                @panic("TakeIterator should use a positive and non-zero number");
            }
            return Self{
                .context = context,
                .number = init_state,
                .total = init_state,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                if (self.context.sizeHintFn().len()) |value| {
                    var num = blk: {
                        if (value > self.number) {
                            break :blk self.number;
                        } else {
                            break :blk value;
                        }
                    };
                    return SizeHint{
                        .low = num,
                        .high = num,
                    };
                }
                return .{};
            } else {
                return .{};
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.number == 0) {
                return null;
            }
            if (self.number < n) {
                return null;
            }
            return self.context.peekAheadFn(n);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) ?ItemType {
            if (self.number == 0) {
                return null;
            }
            if (self.number < n) {
                return null;
            }
            return self.context.peekBackwardFn(n);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.number > 0) {
                self.number -= 1;
                return self.context.nextFn();
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.number > 0) {
                self.number -= 1;
                return self.context.nextBackFn();
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.number > 0) {
                self.number -= 1;
                return self.context.skipFn();
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.number > 0) {
                self.number -= 1;
                return self.context.skipBackFn();
            }
            return false;
        }

        // reset number to initial state
        pub fn reverseFn(self: *Self) void {
            self.number = self.total;
            self.context.reverseFn();
        }
    };
}

pub fn TakeContext(comptime Context: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context = undefined,
        total: usize = 1,
        number: usize = 1,

        pub fn init(context: InnerContextType, init_state: usize) Self {
            if (init_state == 0) {
                @panic("TakeIterator should use a positive and non-zero number");
            }
            return Self{
                .context = context,
                .number = init_state,
                .total = init_state,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                if (self.context.sizeHintFn().len()) |value| {
                    var num = blk: {
                        if (value > self.number) {
                            break :blk self.number;
                        } else {
                            break :blk value;
                        }
                    };
                    return SizeHint{
                        .low = num,
                        .high = num,
                    };
                }
                return .{};
            } else {
                return .{};
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.number == 0) {
                return null;
            }
            if (self.number < n) {
                return null;
            }
            return self.context.peekAheadFn(n);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.number > 0) {
                self.number -= 1;
                return self.context.nextFn();
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.number > 0) {
                self.number -= 1;
                return self.context.skipFn();
            }
            return false;
        }
    };
}

/// A Take Iterator constructor
/// It's actually a wrapper over an iterator
pub fn TakeIterator(comptime Context: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const TakeContextType = DoubleEndedTakeContext(Context);
        return IIterator(TakeContextType);
    } else {
        const TakeContextType = TakeContext(Context);
        return IIterator(TakeContextType);
    }
}

pub fn take(s: anytype, state: usize) TakeIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s)))) {
    return SliceIter.slice(s).take(state);
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const slice = @import("slice.zig").slice;

test "test take method" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const truth: []const u32 = &[_]u32{ 1, 2, 3, 4 };

    var take_iter = take(ints, 4);
    try IterAssert.testIterator(take_iter, truth, 4, .{
        .low = 4,
        .high = 4,
    });
}

test "test slice Take" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const truth: []const u32 = &[_]u32{ 1, 2, 3, 4 };

    var take_iter = SliceIter.slice(ints).take(4);

    try IterAssert.testIterator(take_iter, truth, 4, .{
        .low = 4,
        .high = 4,
    });
}
