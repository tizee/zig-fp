const IIterator = @import("iterator/iterator.zig").IIterator;
const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;
const IterAssert = @import("utils.zig");

pub fn DoubleEndedMapContext(comptime Context: type, comptime Out: type, comptime transformFn: fn (Context.ItemType) Out) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Out;

        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.context.peekAheadFn(n)) |value| {
                return transformFn(value);
            }
            return null;
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            if (self.context.peekBackwardFn(n)) |value| {
                return transformFn(value);
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                return transformFn(value);
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.context.nextBackFn()) |value| {
                return transformFn(value);
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

pub fn MapContext(comptime Context: type, comptime Out: type, comptime transformFn: fn (Context.ItemType) Out) type {
    comptime {
        IterAssert.isIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Out;

        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.context.peekAheadFn(n)) |value| {
                return transformFn(value);
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                return transformFn(value);
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }
    };
}

/// A Map Iterator struct
/// It's actually a wrapper over an iterator
pub fn MapIterator(comptime Context: type, comptime Out: type, comptime transformFn: fn (Context.ItemType) Out) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const MapContextType = DoubleEndedMapContext(Context, Out, transformFn);
        return IDoubleEndedIterator(MapContextType);
    } else {
        const MapContextType = MapContext(Context, Out, transformFn);
        return IIterator(MapContextType);
    }
}
