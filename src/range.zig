const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;

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
    return IDoubleEndedIterator(RangeContextType);
}

/// An easy-to-use API
pub fn range(comptime T: type, start: T, end: T, step: T) RangeIterator(T) {
    const RangeType = RangeIterator(T);
    var context = RangeType.IterContext.init(start, end, step);
    return RangeType.initWithContext(context);
}
