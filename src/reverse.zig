const IDoubleEndedIterator = @import("iterator/double_ended_iterator.zig").IDoubleEndedIterator;

const debug = @import("std").debug;

// ReverseIterator's context should be a wrapper over its inner context
pub fn ReverseContext(comptime Context: type) type {
    comptime {
        const has_nextBackwardFn = @hasDecl(Context, "nextBackFn");
        const has_skipBackFn = @hasDecl(Context, "skipBackFn");
        const has_peekBackwardFn = @hasDecl(Context, "peekBackwardFn");
        if (!has_peekBackwardFn or !has_skipBackFn or !has_nextBackwardFn) {
            @compileError("Context is invalid for ReverseIterator");
        }
    }

    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context,

        pub fn init(context: Context) Self {
            return Self{
                .context = context,
            };
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            return self.context.peekAheadFn(n);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            return self.context.peekBackwardFn(n);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            return self.context.nextBackFn();
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            return self.context.nextFn();
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }

        pub fn skipBackFn(self: *Self) bool {
            return self.context.skipBackFn();
        }

        pub fn reverseFn(self: *Self) bool {
            return self.context.reverseFn();
        }
    };
}

// An Reverse Iterator for a slice
// Iter should be a double-ended iterator
pub fn ReverseIterator(comptime Context: type) type {
    const ReverseContextType = ReverseContext(Context);
    return IDoubleEndedIterator(ReverseContextType);
}
