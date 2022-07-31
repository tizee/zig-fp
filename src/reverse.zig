const IIterator = @import("iterator.zig").IIterator;

/// An Reverse Iterator for a slice
/// It does not and should not modify the data
pub fn ReverseContext(comptime T: type) type {
    return struct {
        const Self = @This();

        current: ?usize,
        data: []const T,

        /// Look at the nth item without advancing
        pub fn peekAhead(self: *Self, n: usize) ?T {
            if (self.current) |idx| {
                if (idx - n >= 0) {
                    return self.data[idx];
                }
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?T {
            if (self.current) |idx| {
                if (idx <= 0) {
                    // reach last
                    self.current = null;
                } else {
                    self.current = idx - 1;
                }
                return self.data[idx];
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.current) |idx| {
                if (idx <= 0) {
                    // reach last
                    self.current = null;
                } else {
                    self.current = idx - 1;
                }
                return true;
            }
            return false;
        }

        pub fn init(slice: []const T) Self {
            return Self{ .current = slice.len - 1, .data = slice };
        }

        pub fn reset(self: *Self) Self {
            return Self.init(self.data);
        }
    };
}

pub fn ReverseIterator(comptime T: type) type {
    const Context = ReverseContext(T);
    return IIterator(T, Context);
}
