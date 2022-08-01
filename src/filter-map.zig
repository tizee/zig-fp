const IIterator = @import("iterator/iterator.zig").IIterator;
const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;
const SliceIter = @import("slice.zig");
const FilterIterator = @import("filter.zig");
const IterAssert = @import("utils.zig");

pub fn DoubleEndedFilterMapContext(comptime Context: type, comptime Out: type, comptime transformFn: fn (Context.ItemType) ?Out) type {
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
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (transformFn(value)) |_| {
                        count += 1;
                    }
                } else {
                    break;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekBackwardFn(i)) |value| {
                    if (transformFn(value)) |_| {
                        i += 1;
                    }
                } else {
                    break;
                }
            }
            return self.context.peekBackwardFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            while (self.context.nextFn()) |value| {
                if (transformFn(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            while (self.context.nextBackFn()) |value| {
                if (transformFn(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.nextFn()) |value| {
                if (transformFn(value)) |_| {
                    return true;
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            while (self.context.nextBackFn()) |value| {
                if (transformFn(value)) |_| {
                    return true;
                }
            }
            return false;
        }
    };
}

pub fn FilterMapContext(comptime Context: type, comptime Out: type, comptime transformFn: fn (Context.ItemType) ?Out) type {
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

        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (transformFn(value)) |_| {
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
                if (transformFn(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.nextFn()) |value| {
                if (transformFn(value)) |_| {
                    return true;
                }
            }
            return false;
        }
    };
}

/// A FilterMap Iterator struct
/// It's actually a wrapper over an iterator
pub fn FilterMapIterator(comptime Context: type, comptime Out: type, comptime transformFn: fn (Context.ItemType) ?Out) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const FilterMapContextType = DoubleEndedFilterMapContext(Context, Out, transformFn);
        return IDoubleEndedIterator(FilterMapContextType);
    } else {
        const FilterMapContextType = FilterMapContext(Context, Out, transformFn);
        return IIterator(FilterMapContextType);
    }
}

pub fn filterMap(comptime T: type, comptime Out: type, s: []const T, comptime transformFn: fn (T) ?Out) FilterMapIterator(SliceIter.SliceContext(T), Out, transformFn) {
    return SliceIter.slice(T, s).filter_map(Out, transformFn);
}
