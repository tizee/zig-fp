const IIterator = @import("iterator.zig").IIterator;
const std = @import("std");
const debug = std.debug;
const assert = @import("std").debug.assert;

/// A Map Iterator struct
pub fn MapIterator(comptime Iter: type, comptime Out: type, comptime transformFn: fn (Iter.ItemType) Out) type {
    return struct {
        const Self = @This();
        pub const IterContext = Iter.IterContext;
        pub const ItemType = Out;

        inner: *Iter,

        pub fn peekAhead(self: *Self, n: usize) ?Out {
            if (self.inner.peekAhead(n)) |item| {
                return transformFn(item);
            }
            return null;
        }

        pub fn peek(self: *Self) ?Out {
            if (self.inner.peek()) |item| {
                return transformFn(item);
            }
            return null;
        }

        pub fn next(self: *Self) ?Out {
            if (self.inner.next()) |item| {
                return transformFn(item);
            }
            return null;
        }

        pub fn skip(self: *Self) bool {
            return self.inner_iterator.skip();
        }

        /// Consumes the iterator and apply the f for each item
        pub fn for_each(self: *Self, f: fn (item: Out) void) void {
            while (self.next()) |value| {
                f(value);
            }
        }

        /// transform ItemType to NewType and return a new Iterator
        pub fn map(self: *Self, comptime NewType: type, comptime f: fn (Out) NewType) MapIterator(Self, NewType, f) {
            return MapIterator(Self, NewType, f).init(self);
        }

        pub fn init(input_iterator: *Iter) Self {
            return Self{ .inner = input_iterator };
        }
    };
}
