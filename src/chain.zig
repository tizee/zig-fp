const std = @import("std");
const IIterator = @import("core/iterator.zig").IIterator;
const SizeHint = @import("core/size-hint.zig").SizeHint;

const SliceIter = @import("slice.zig");
const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

pub fn DoubleEndedChainContext(comptime ContextA: type, comptime ContextB: type) type {
    comptime {
        if (@TypeOf(ContextA.ItemType) != @TypeOf(ContextB.ItemType)) {
            @compileError("Chained Iterators should have the same item type");
        }
        IterAssert.assertDoubleEndedIteratorContext(ContextA);
        IterAssert.assertDoubleEndedIteratorContext(ContextB);
    }
    return struct {
        const Self = @This();
        pub const ItemType = ContextA.ItemType;

        index: usize = 0,
        contextA: ContextA = undefined,
        contextB: ContextB = undefined,

        pub fn init(a: ContextA, b: ContextB) Self {
            return Self{ .contextA = a, .contextB = b };
        }

        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            return SizeHint.join(self.contextA.sizeHintFn(), self.contextB.sizeHintFn());
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.contextA.peekAheadFn(n)) |value| {
                return value;
            } else {
                if (self.contextA.sizeHintFn().len()) |len| {
                    return self.contextB.peekAheadFn(n - len);
                } else {
                    var i: usize = 0;
                    while (self.contextA.peekAheadFn(i + 1)) |_| : (i += 1) {}
                    return self.contextB.peekAheadFn(n - i);
                }
            }
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            if (self.contextA.peekBackwardFn(n)) |value| {
                return value;
            } else {
                if (self.contextA.sizeHintFn().len()) |len| {
                    return self.contextB.peekBackwardFn(n - len);
                } else {
                    var i: usize = 0;
                    while (self.contextA.peekBackwardFn(i + 1)) |_| : (i += 1) {}
                    return self.contextB.peekBackwardFn(n - i);
                }
            }
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.contextA.nextFn()) |value| {
                return value;
            }
            return self.contextB.nextFn();
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.contextA.nextBackFn()) |value| {
                return value;
            }
            return self.contextB.nextBackFn();
        }

        pub fn skipFn(self: *Self) bool {
            if (self.contextA.skipFn()) {
                return true;
            }
            return self.contextB.skipFn();
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.contextA.skipBackFn()) {
                return true;
            }
            return self.contextB.skipBackFn();
        }
    };
}

pub fn ChainContext(comptime ContextA: type, comptime ContextB: type) type {
    comptime {
        if (@TypeOf(ContextA.ItemType) != @TypeOf(ContextB.ItemType)) {
            @compileError("Chained Iterators should have the same item type");
        }
        IterAssert.assertIteratorContext(ContextA);
        IterAssert.assertIteratorContext(ContextB);
    }
    return struct {
        const Self = @This();
        pub const ItemType = ContextA.ItemType;

        index: usize = 0,
        contextA: ContextA = undefined,
        contextB: ContextB = undefined,

        pub fn init(a: ContextA, b: ContextB) Self {
            return Self{ .contextA = a, .contextB = b };
        }

        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            return SizeHint.join(self.contextA.sizeHintFn(), self.contextB.sizeHintFn());
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.contextA.peekAheadFn(n)) |value| {
                return value;
            } else {
                if (self.contextA.sizeHintFn().len()) |len| {
                    return self.contextB.peekAheadFn(n - len);
                } else {
                    var i: usize = 0;
                    while (self.contextA.peekAheadFn(i + 1)) |_| : (i += 1) {}
                    return self.contextB.peekAheadFn(n - i);
                }
            }
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.contextA.nextFn()) |value| {
                return value;
            }
            return self.contextB.nextFn();
        }

        pub fn skipFn(self: *Self) bool {
            if (self.contextA.skipFn()) {
                return true;
            }
            return self.contextB.skipFn();
        }
    };
}

/// A Chain Iterator struct
/// It's actually a wrapper over an iterator
pub fn ChainIterator(comptime ContextA: type, comptime ContextB: type) type {
    comptime {
        if (IterAssert.isDoubleEndedIteratorContext(ContextA) and IterAssert.isDoubleEndedIteratorContext(ContextB)) {
            const ChainContextType = DoubleEndedChainContext(ContextA, ContextB);
            return IIterator(ChainContextType);
        } else {
            const ChainContextType = ChainContext(ContextA, ContextB);
            return IIterator(ChainContextType);
        }
    }
}

pub fn chain(a: anytype, b: anytype) ChainIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(a))), SliceIter.SliceContext(GetPtrChildType(@TypeOf(b)))) {
    return SliceIter.slice(a).chain(SliceIter.slice(b));
}

const testing = std.testing;

test "test ChainIterator" {
    const hello: []const u8 = "hello,";
    const world: []const u8 = "world";
    var a = SliceIter.slice(hello);
    var b = SliceIter.slice(world);

    const truth: []const u8 = "hello,world";

    const Chain = ChainIterator(@TypeOf(a).IterContext, @TypeOf(b).IterContext);
    var chainIter = Chain.initWithTwoContext(a.context, b.context);

    try IterAssert.testIterator(chainIter, truth, truth.len, SizeHint{
        .low = 11,
        .high = 11,
    });
}

test "test chain" {
    const hello: []const u8 = "hello,";
    const world: []const u8 = "world";

    const truth: []const u8 = "hello,world";

    var chainIter = chain(hello, world);

    try IterAssert.testIterator(chainIter, truth, truth.len, SizeHint{
        .low = 11,
        .high = 11,
    });
}
