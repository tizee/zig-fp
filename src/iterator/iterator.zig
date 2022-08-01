pub const MapIterator = @import("../map.zig").MapIterator;
pub const RangeIterator = @import("../range.zig").RangeIterator;
pub const ReverseIterator = @import("../reverse.zig").ReverseIterator;
pub const slice = @import("../slice.zig").slice;
pub const FilterIterator = @import("../filter.zig").FilterIterator;
pub const FilterMapIterator = @import("../filter-map.zig").FilterMapIterator;
pub const EnumerateIterator = @import("../enumerate.zig").EnumerateIterator;
const IterAssert = @import("../utils.zig");

const debug = @import("std").debug;
const testing = @import("std").testing;

/// a general iterator
pub fn IIterator(
    comptime Context: type,
) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }

    return struct {
        const Self = @This();
        pub const IterContext = Context;
        pub const ItemType = Context.ItemType;

        context: Context,

        pub fn initWithContext(context: IterContext) Self {
            return Self{ .context = context };
        }

        // for wrappers like Map, Reverse
        pub fn initWithInnerContext(context: anytype) Self {
            return Self{ .context = Context{ .context = context } };
        }

        /// Look at the next item without advancing
        pub fn peek(self: *Self) ?ItemType {
            return self.context.peekAheadFn(0);
        }

        /// Look at the nth item without advancing
        pub fn peekAhead(self: *Self, comptime n: usize) ?ItemType {
            return self.context.peekAheadFn(n);
        }

        /// Consumes the iterator and count the length
        pub fn count(self: *Self) usize {
            var len: usize = 0;
            while (self.nextFn()) |_| {
                len += 1;
            }
            return len;
        }

        /// Advances the iterator and return the value
        pub fn next(self: *Self) ?ItemType {
            return self.context.nextFn();
        }

        /// Advances the iterator, return false if failed
        pub fn skip(self: *Self) bool {
            return self.context.skipFn();
        }

        // this iterator should be exhausted after enumerate()
        pub fn enumerate(self: *Self) EnumerateIterator(Self.IterContext) {
            return EnumerateIterator(Self.IterContext).initWithInnerContext(self.context);
        }

        /// transform ItemType to NewType and return a new Iterator
        pub fn map(self: *Self, comptime NewType: type, comptime f: fn (ItemType) NewType) MapIterator(Self.IterContext, NewType, f) {
            // this iterator should be exhausted after reverse()
            return MapIterator(Self.IterContext, NewType, f).initWithInnerContext(self.context);
        }

        // this iterator should be exhausted after filter()
        pub fn filter(self: *Self, comptime f: fn (ItemType) bool) FilterIterator(Self.IterContext, f) {
            return FilterIterator(Self.IterContext, f).initWithInnerContext(self.context);
        }

        // this iterator should be exhausted after filter_map()
        pub fn filter_map(self: *Self, comptime Out: type, comptime f: fn (ItemType) ?Out) FilterMapIterator(Self.IterContext, Out, f) {
            return FilterMapIterator(Self.IterContext, Out, f).initWithInnerContext(self.context);
        }

        /// Consumes the iterator and apply the f for each item
        pub fn for_each(self: *Self, f: fn (item: ItemType) void) void {
            while (self.next()) |value| {
                f(value);
            }
        }

        pub fn reduce(self: *Self, f: fn (accum: ItemType, cur: ItemType) ItemType) ?ItemType {
            var res = self.peek();
            _ = self.next();
            while (self.next()) |value| {
                res = f(res.?, value);
            }
            return res;
        }

        // Consumes the iterator
        pub fn fold(self: *Self, comptime NewType: type, init: NewType, f: fn (accum: NewType, cur: ItemType) NewType) NewType {
            var res = init;
            while (self.next()) |value| {
                res = f(res, value);
            }
            return res;
        }

        // Consumes the iterator
        pub fn find(self: *Self, f: fn (cur: *ItemType) bool) ?ItemType {
            while (self.next()) |value| {
                if (f(&value)) {
                    return value;
                }
            }
            return null;
        }
    };
}
