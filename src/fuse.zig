const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

/// The Fuse iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedFuseContext(comptime Context: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context,
        fused: bool = false,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
                .fused = false,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (self.fused) {
                return .{};
            }
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                return self.context.sizeHintFn();
            } else {
                return .{};
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.fused) {
                return null;
            }
            var count: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(count)) |_| {
                    count += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekAheadFn(n);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) ?ItemType {
            if (self.fused) {
                return null;
            }
            var count: usize = 0;
            while (count < n) {
                if (self.context.peekBackwardFn(count)) |_| {
                    count += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekBackwardFn(n);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.fused) {
                return null;
            }
            if (self.context.nextFn()) |value| {
                return value;
            }
            self.fused = true;
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.fused) {
                return null;
            }
            if (self.context.nextBackFn()) |value| {
                return value;
            }
            self.fused = true;
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.fused) {
                return false;
            }
            if (self.context.skipFn()) {
                return true;
            }
            self.fused = true;
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.fused) {
                return false;
            }
            if (self.context.skipBackFn()) {
                return true;
            }
            self.fused = true;
            return false;
        }

        pub fn reverseFn(self: *Self) void {
            self.fused = false;
            self.context.reverseFn();
        }
    };
}

pub fn FuseContext(comptime Context: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context,
        fused: bool = false,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
                .fused = false,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (self.fused) {
                return .{};
            }
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                return self.context.sizeHintFn();
            } else {
                return {};
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.fused) {
                return null;
            }
            var count: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(count)) |_| {
                    count += 1;
                } else {
                    return null;
                }
            }
            return self.context.peekAheadFn(n);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.fused) {
                return null;
            }
            if (self.context.nextFn()) |value| {
                return value;
            }
            self.fused = true;
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.fused) {
                return false;
            }
            if (self.context.skipFn()) {
                return true;
            }
            self.fused = true;
            return false;
        }
    };
}

/// A Fuse Iterator constructor
/// It's actually a wrapper over an iterator
pub fn FuseIterator(comptime Context: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const FuseContextType = DoubleEndedFuseContext(Context);
        return IIterator(FuseContextType);
    } else {
        const FuseContextType = FuseContext(Context);
        return IIterator(FuseContextType);
    }
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const slice = @import("slice.zig").slice;

test "test slice fuse" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4 };
    var iter = slice(ints);

    var fuse_iter = iter.fuse();
    try IterAssert.testIterator(fuse_iter, ints, 4, .{
        .low = 4,
        .high = 4,
    });
}
