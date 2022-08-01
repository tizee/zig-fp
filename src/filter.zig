const IIterator = @import("iterator/iterator.zig").IIterator;
const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;
const debug = @import("std").debug;

/// The filter iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedFilterContext(comptime Context: type, comptime filterFn: fn (?Context.ItemType) bool) type {
    comptime {
        const has_nextFn = @hasDecl(Context, "nextFn");
        const has_peekAheadFn = @hasDecl(Context, "peekAheadFn");
        const has_skipFn = @hasDecl(Context, "skipFn");
        if (!has_nextFn or !has_peekAheadFn or !has_skipFn) {
            @compileError("Iterator requires a valid context");
        }
        const has_nextBackwardFn = @hasDecl(Context, "nextBackFn");
        const has_skipBackFn = @hasDecl(Context, "skipBackFn");
        const has_peekBackwardFn = @hasDecl(Context, "peekBackwardFn");
        if (!has_peekBackwardFn or !has_skipBackFn or !has_nextBackwardFn) {
            @compileError("Context is invalid for a double-ended iterator");
        }
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
        const has_nextFn = @hasDecl(Context, "nextFn");
        const has_peekAheadFn = @hasDecl(Context, "peekAheadFn");
        const has_skipFn = @hasDecl(Context, "skipFn");
        if (!has_nextFn or !has_peekAheadFn or !has_skipFn) {
            @compileError("FilterContext requires a valid inner context type");
        }
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
    const has_nextBackwardFn = @hasDecl(Context, "nextBackFn");
    const has_skipBackFn = @hasDecl(Context, "skipBackFn");
    const has_peekBackwardFn = @hasDecl(Context, "peekBackwardFn");
    if (has_peekBackwardFn and has_skipBackFn and has_nextBackwardFn) {
        const FilterContextType = DoubleEndedFilterContext(Context, filterFn);
        return IDoubleEndedIterator(FilterContextType);
    } else {
        const FilterContextType = FilterContext(Context, filterFn);
        return IIterator(FilterContextType);
    }
}
