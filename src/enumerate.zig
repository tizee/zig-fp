const IIterator = @import("iterator/iterator.zig").IIterator;
const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;

const IterAssert = @import("utils.zig");

pub fn DoubleEndedEnumerateContext(comptime Context: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = struct { index: usize, value: Context.ItemType };

        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.context.peekAheadFn(n)) |value| {
                return ItemType{
                    .index = self.context.current + n,
                    .value = value,
                };
            }
            return null;
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            if (self.context.peekBackwardFn(n)) |value| {
                return ItemType{
                    .index = self.context.current - n,
                    .value = value,
                };
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                return ItemType{
                    .index = self.context.current - 1,
                    .value = value,
                };
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.context.nextBackFn()) |value| {
                return ItemType{
                    .index = self.context.current + 1,
                    .value = value,
                };
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }

        pub fn skipBackFn(self: *Self) bool {
            return self.context.skipBackFn();
        }
    };
}

pub fn EnumerateContext(comptime Context: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = struct { index: usize, value: Context.ItemType };

        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.context.peekAheadFn(n)) |value| {
                return ItemType{
                    .index = self.context.current + n,
                    .value = value,
                };
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                return ItemType{
                    .index = self.context.current - 1,
                    .value = value,
                };
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }
    };
}

/// A Enumerate Iterator struct
/// It's actually a wrapper over an iterator
pub fn EnumerateIterator(comptime Context: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const EnumerateContextType = DoubleEndedEnumerateContext(Context);
        return IDoubleEndedIterator(EnumerateContextType);
    } else {
        const EnumerateContextType = EnumerateContext(Context);
        return IIterator(EnumerateContextType);
    }
}
