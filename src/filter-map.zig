const IIterator = @import("iterator/iterator.zig").IIterator;
const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;
const SliceIter = @import("slice.zig");
const FilterIterator = @import("filter.zig");
const IterAssert = @import("utils.zig");
const GetPtrChildType = @import("utils.zig").GetPtrChildType;

pub fn DoubleEndedFilterMapContext(comptime Context: type, comptime TransformFn: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = @typeInfo(TransformFn).Fn.return_type.?;

        func: TransformFn,
        context: Context,

        pub fn init(context: InnerContextType, func: TransformFn) Self {
            return Self{
                .func = func,
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.func(value)) |_| {
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
                    if (self.func(value)) |_| {
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
                if (self.func(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            while (self.context.nextBackFn()) |value| {
                if (self.func(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.nextFn()) |value| {
                if (self.func(value)) |_| {
                    return true;
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            while (self.context.nextBackFn()) |value| {
                if (self.func(value)) |_| {
                    return true;
                }
            }
            return false;
        }
    };
}

pub fn FilterMapContext(comptime Context: type, comptime TransformFn: type) type {
    comptime {
        IterAssert.isIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = @typeInfo(TransformFn).Fn.return_type.?;

        func: TransformFn = undefined,
        context: Context = undefined,

        pub fn init(context: InnerContextType, func: TransformFn) Self {
            return Self{
                .context = context,
                .func = func,
            };
        }

        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.func(value)) |_| {
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
                if (self.func(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.nextFn()) |value| {
                if (self.func(value)) |_| {
                    return true;
                }
            }
            return false;
        }
    };
}

/// A FilterMap Iterator struct
/// It's actually a wrapper over an iterator
pub fn FilterMapIterator(comptime Context: type, comptime TransformFn: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const FilterMapContextType = DoubleEndedFilterMapContext(Context, TransformFn);
        return IDoubleEndedIterator(FilterMapContextType);
    } else {
        const FilterMapContextType = FilterMapContext(Context, TransformFn);
        return IIterator(FilterMapContextType);
    }
}

pub fn filterMap(s: anytype, transformFn: anytype) FilterMapIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s))), @TypeOf(transformFn)) {
    return SliceIter.slice(s).filter_map(transformFn);
}
