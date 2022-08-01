const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;
const std = @import("std");
const mem = std.mem;
const trait = std.meta.trait;

const debug = @import("std").debug;

/// A thin wrapper over a slice
/// It's actually a double-ended iterator context
pub fn SliceContext(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const ItemType = T;
        direction: bool,

        current: usize,
        len: usize,

        data: []const T,

        /// Advances the iterator by n*step and return the item
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var current = self.current + n;
            if (current < self.len) {
                return self.data[current];
            }
            return null;
        }

        pub fn peekBackwardFn(self: *Self, n: usize) ?ItemType {
            if (self.current > n and (self.current - n) < self.len) {
                return self.data[self.current - n];
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.current == self.len) return null;
            defer self.current += 1;
            return self.data[self.current];
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.current == 0) return null;
            self.current -= 1;
            return self.data[self.current];
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.current == 0) {
                return false;
            } else {
                self.current -= 1;
            }
            return true;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.current >= self.len) {
                // reach last
                return false;
            } else {
                self.current += 1;
            }
            return true;
        }

        /// This would reset the state of the context
        /// If the iterator has been exhausted then it's
        /// a no-op
        pub fn reverseFn(self: *Self) void {
            self.direction = !self.direction;
            if (self.direction) {
                self.current = 0;
            } else {
                self.current = self.len;
            }
        }

        pub fn init(data: anytype) Self {
            return Self{ .direction = true, .len = data.len, .current = @as(usize, 0), .data = data };
        }
    };
}

pub fn SliceIterator(comptime T: type) type {
    const SliceContextType = SliceContext(T);
    return IDoubleEndedIterator(SliceContextType);
}

/// var iter = slice(u8,"abcd");
pub fn slice(comptime T: type, s: anytype) SliceIterator(T) {
    const SliceIteratorType = SliceIterator(T);
    var context = SliceIteratorType.IterContext.init(s);
    return SliceIteratorType.initWithContext(context);
}
