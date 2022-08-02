const std = @import("std");
const math = std.math;
const IIterator = @import("core/iterator.zig").IIterator;
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const assertSlice = @import("utils.zig").assertSlice;

/// A thin wrapper over a slice
/// It's actually a double-ended iterator context
pub fn SliceContext(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const ItemType = T;
        direction: bool,

        current: usize,
        len: usize,

        data: []const ItemType,

        pub fn sizeHintFn(self: Self) SizeHint {
            if (self.direction) {
                const len = math.sub(usize, self.len, self.current) catch 0;
                return SizeHint{
                    .low = len,
                    .high = len,
                };
            } else {
                return SizeHint{
                    .low = self.current,
                    .high = self.current,
                };
            }
        }

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
    return IIterator(SliceContextType);
}

/// var iter = slice(u8,"abcd");
pub fn slice(s: anytype) SliceIterator(GetPtrChildType(@TypeOf(s))) {
    comptime {
        assertSlice(@TypeOf(s));
    }
    const SliceIteratorType = SliceIterator(GetPtrChildType(@TypeOf(s)));
    var context = SliceIteratorType.IterContext.init(s);
    return SliceIteratorType.initWithContext(context);
}

const testing = std.testing;
const testIterator = @import("utils.zig").testIterator;
const debug = std.debug;

test "test SliceIterator" {
    const StrIter = SliceIterator(u8);
    const str = "abcd";
    var context = StrIter.IterContext.init(str);
    var iter = StrIter.initWithContext(context);

    var i: usize = 0;
    while (iter.next()) |value| {
        try testing.expectEqual(str[i], value);
        i += 1;
        debug.print("{}\n", .{value});
    }
    context = StrIter.IterContext.init(str);
    iter = StrIter.initWithContext(context);

    try testing.expectEqual(@as(?u8, str[0]), iter.peek());
    _ = iter.next();
    _ = iter.next();
    try testing.expectEqual(@as(?u8, str[2]), iter.peek());
}

test "test slice" {
    const str: []const u8 = "abcd";
    var iter = slice(str);

    var i: usize = 0;
    while (iter.next()) |value| {
        try testing.expectEqual(str[i], value);
        i += 1;
        debug.print("{}\n", .{value});
    }
}

test "test slice size_hint" {
    const str: []const u8 = "abcd";
    var iter = slice(str);
    try testIterator(iter, str, 4, SizeHint{
        .low = 4,
        .high = 4,
    });
}

test "test slice ducking types" {
    const StrIter = SliceIterator(u8);
    const str: []const u8 = "abcd";

    var context = StrIter.IterContext.init(str);
    var iter = StrIter.initWithContext(context);

    var iter2 = slice(str);

    try testing.expect(@TypeOf(iter2) == @TypeOf(iter));
}
