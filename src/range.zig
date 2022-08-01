const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;

/// A half open Range for integer types
pub fn RangeContext(comptime T: type) type {
    comptime {
        if (!(T == i8 or T == u8 or T == i16 or T == u16 or T == i32 or T == u32 or T == i64 or T == u64 or T == i128 or T == u128 or T == i128 or T == isize or T == usize or T == c_short or T == c_ushort or T == c_int or T == c_uint or T == c_long or T == c_ulong or T == c_longlong or T == c_ulonglong or T == c_longdouble or T == f16 or T == f32 or T == f64 or T == f80 or T == f128)) {
            @compileError("Range should use an integer type");
        }
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
            var current = self.current;
            if (self.step < 0) {
                if (self.current <= self.end) {
                    return null;
                }
            } else {
                if (self.current >= self.end) {
                    return null;
                }
            }
            self.current += self.step;
            return current;
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
            self.current -= self.step;
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

        pub fn init(start: ItemType, end: ItemType, comptime step: ItemType) Self {
            comptime {
                if (step == 0) {
                    @compileError("Range step cannot be zero");
                }
            }

            return Self{ .direction = true, .start = start, .current = start, .end = end, .step = step };
        }
    };
}

pub fn RangeIterator(comptime T: type) type {
    const RangeContextType = RangeContext(T);
    return IDoubleEndedIterator(RangeContextType);
}
