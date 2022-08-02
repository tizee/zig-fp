const math = @import("std").math;
const IIterator = @import("core/iterator.zig").IIterator;
const SizeHint = @import("core/size-hint.zig").SizeHint;

const IterAssert = @import("utils.zig");
/// A half open Range for integer types
pub fn RangeContext(comptime T: type) type {
    comptime {
        IterAssert.assertNum(T);
    }

    return struct {
        const Self = @This();

        pub const ItemType = T;

        direction: bool,
        // current value
        current: ItemType,
        // start value
        start: ItemType,
        // sentinal end value
        end: ItemType,
        // step size
        step: ItemType,

        pub fn sizeHintFn(self: *Self) SizeHint {
            const len = math.sub(ItemType, self.end, self.start) catch 0;
            const steps = math.divCeil(ItemType, len, self.step);

            return SizeHint{
                .low = steps,
                .high = steps,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, comptime n: usize) ?ItemType {
            var current = self.current;
            var i: usize = 0;
            while (i < n) {
                current += self.step;
                i += 1;
            }
            if (current == self.end) return null;
            if (self.step < 0 and current < self.end) {
                return null;
            } else if (self.step > 0 and current > self.end) {
                return null;
            }
            return current;
        }

        pub fn peekBackwardFn(self: *Self, comptime n: usize) ?ItemType {
            var current = self.current;
            var i: usize = 0;
            // TODO should panic for unsigned data
            while (i < n) {
                current -= self.step;
                i += 1;
            }
            if (current == self.end) return null;
            if (self.step < 0 and current > self.end) {
                return null;
            } else if (self.step > 0 and current < self.start) {
                return null;
            }
            return current;
        }

        /// Advances the iterator by step and return the item
        pub fn nextFn(self: *Self) ?ItemType {
            if (self.step < 0 and self.current <= self.end) {
                return null;
            }
            if (self.step > 0 and self.current >= self.end) {
                return null;
            }
            defer self.current += self.step;
            return self.current;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            var current = self.current;
            if (self.step < 0) {
                if (self.current >= self.start) {
                    return null;
                }
            } else {
                if (self.current <= self.start) {
                    return null;
                }
            }
            defer self.current -= self.step;
            return current;
        }

        /// Advances the iterator by step and return the
        /// state whether it succeeds
        pub fn skipFn(self: *Self) bool {
            if (self.current == self.end) return false;
            if (self.step < 0 and self.current < self.end) {
                return false;
            } else if (self.step > 0 and self.current > self.end) {
                return false;
            }

            self.current += self.step;
            return true;
        }

        pub fn skipBackFn(self: *Self) bool {
            if (self.current == self.start) return false;
            if (self.step < 0 and self.current >= self.start) {
                return false;
            } else if (self.step > 0 and self.current <= self.start) {
                return false;
            }

            self.current -= self.step;
            return true;
        }

        /// reverse a range means
        /// This would reset the state of the context
        /// set the current to the end
        pub fn reverseFn(self: *Self) void {
            self.direction = !self.direction;
            if (!self.direction) {
                self.current = self.end;
            } else {
                self.current = self.start;
            }
        }

        pub fn init(start: ItemType, end: ItemType, step: ItemType) Self {
            return Self{ .direction = true, .start = start, .current = start, .end = end, .step = step };
        }
    };
}

pub fn RangeIterator(comptime T: type) type {
    const RangeContextType = RangeContext(T);
    return IIterator(RangeContextType);
}

/// An easy-to-use API
pub fn range(comptime T: type, start: T, end: T, step: T) RangeIterator(T) {
    const RangeType = RangeIterator(T);
    var context = RangeType.IterContext.init(start, end, step);
    return RangeType.initWithContext(context);
}

const std = @import("std");
const testing = std.testing;
const debug = std.debug;

fn testRange(comptime T: type) anyerror!void {
    const Range = RangeIterator(T);
    var iter = range(T, 1, 10, 1);

    var val: T = 1;
    while (iter.next()) |value| {
        try testing.expectEqual(val, value);
        val += 1;
    }
    try testing.expectEqual(@as(?T, null), iter.peek());

    comptime {
        if (T == i32 or T == i8 or T == i16 or T == i64 or T == i128 or T == c_short or T == c_int or T == c_long or T == c_longlong or T == c_longdouble or T == f16 or T == f32 or T == f64 or T == f80 or T == f128) {
            var context1 = Range.IterContext.init(10, 1, -1);
            var iter1 = Range.initWithContext(context1);
            var val1 = 10;
            while (iter1.next()) |value| {
                try testing.expectEqual(val1, value);
                val1 -= 1;
            }
        }
    }

    iter = range(T, 1, 4, 1);
    try testing.expectEqual(@as(?T, 1), iter.next());
    if (iter.skip()) {
        if (iter.next()) |value| {
            try testing.expectEqual(@as(T, 3), value);
        }
        if (iter.next()) |value| {
            try testing.expectEqual(@as(T, 4), value);
        }
        try testing.expectEqual(@as(?T, null), iter.next());
    } else {
        unreachable;
    }
}

test "Test Range for primitives" {
    try testRange(u8);
    try testRange(i8);
    try testRange(u16);
    try testRange(i16);
    try testRange(u32);
    try testRange(i32);
    try testRange(u64);
    try testRange(i64);
    try testRange(u128);
    try testRange(i128);
    try testRange(usize);
    try testRange(isize);
    try testRange(c_ushort);
    try testRange(c_short);
    try testRange(c_ulong);
    try testRange(c_long);
    try testRange(c_ulonglong);
    try testRange(c_longlong);
    try testRange(c_longdouble);
    try testRange(f16);
    try testRange(f32);
    try testRange(f64);
    try testRange(f80);
    try testRange(f128);
}
