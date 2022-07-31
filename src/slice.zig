const IIterator = @import("iterator.zig").IIterator;

/// A thin wrapper over a slice
pub fn SliceContext(comptime T: type) type {
    return struct {
        const Self = @This();

        const ItemType = T;

        current: ?usize,
        len: usize,
        data: []const T,

        /// Advances the iterator by n*step and return the item
        pub fn peekAheadFn(self: *Self, n: usize) ?T {
            if (self.current) |idx| {
                const current = idx + n;
                if (idx < self.len) {
                    return self.data[current];
                }
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.current) |idx| {
                if (idx >= self.len - 1) {
                    // reach last
                    self.current = null;
                } else {
                    self.current = idx + 1;
                }
                return self.data[idx];
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            if (self.current) |idx| {
                if (idx >= self.len - 1) {
                    // reach last
                    self.current = null;
                } else {
                    self.current = idx + 1;
                }
                return true;
            }
            return false;
        }

        pub fn init(data: []const T) Self {
            return Self{ .len = data.len, .current = 0, .data = data };
        }
    };
}

pub fn SliceIterator(comptime T: type) type {
    const Context = SliceContext(T);
    return IIterator(T, Context);
}
