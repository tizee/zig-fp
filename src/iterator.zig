const debug = @import("std").debug;

pub const MapIterator = @import("map.zig").MapIterator;
pub const RangeIterator = @import("range.zig").RangeIterator;
pub const ReverseIterator = @import("reverse.zig").ReverseIterator;
pub const SliceIterator = @import("slice.zig").SliceIterator;

/// Generic Iterator Interface
pub fn IIterator(
    comptime T: type,
    comptime Context: type,
) type {
    return struct {
        const Self = @This();
        pub const IterContext = Context;
        pub const ItemType = T;

        context: Context,

        pub fn initWithContext(context: Context) Self {
            return Self{ .context = context };
        }

        /// Look at the next item without advancing
        pub fn peek(self: *Self) ?T {
            return self.context.peekAheadFn(0);
        }

        /// Look at the nth item without advancing
        pub fn peekAhead(self: *Self, comptime n: usize) ?T {
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
        pub fn next(self: *Self) ?T {
            return self.context.nextFn();
        }

        /// Advances the iterator, return false if failed
        pub fn skip(self: *Self) bool {
            return self.context.skipFn();
        }

        /// transform ItemType to NewType and return a new Iterator
        pub fn map(self: *Self, comptime NewType: type, comptime f: fn (T) NewType) MapIterator(Self, NewType, f) {
            return MapIterator(Self, NewType, f).init(self);
        }

        /// Consumes the iterator and apply the f for each item
        pub fn for_each(self: *Self, f: fn (item: T) void) void {
            while (self.next()) |value| {
                f(value);
            }
        }
    };
}
