const IIterator = @import("iterator/iterator.zig").IIterator;
const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;
const debug = @import("std").debug;

const IterAssert = @import("utils.zig");

/// The filter iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedFilterContext(comptime Context: type, comptime filterFn: fn (?Context.ItemType) bool) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (filterFn(value)) {
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
                    if (filterFn(value)) {
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
                    if (filterFn(value)) {
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
                    if (filterFn(value)) {
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
                if (filterFn(value)) {
                    return true;
                } else {
                    self.context.skipFn();
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            while (self.context.peekBackwardFn(0)) |value| {
                if (filterFn(value)) {
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

pub fn FilterContext(comptime Context: type, comptime filterFn: fn (?Context.ItemType) bool) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var count: usize = 0;
            var i: usize = 0;
            while (count < n) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (filterFn(value)) {
                        count += 1;
                    }
                    i += 1;
                } else {
                    break;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            while (self.context.nextFn()) |value| {
                if (filterFn(value)) {
                    return value;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.peekAheadFn(0)) |value| {
                if (filterFn(value)) {
                    return true;
                } else {
                    self.context.skipFn();
                }
            }
            return false;
        }
    };
}

/// A Filter Iterator constructor
/// It's actually a wrapper over an iterator
pub fn FilterIterator(comptime Context: type, comptime filterFn: fn (?Context.ItemType) bool) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const FilterContextType = DoubleEndedFilterContext(Context, filterFn);
        return IDoubleEndedIterator(FilterContextType);
    } else {
        const FilterContextType = FilterContext(Context, filterFn);
        return IIterator(FilterContextType);
    }
}
