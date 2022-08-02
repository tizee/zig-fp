const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

const debug = @import("std").debug;

// ReverseIterator's context should be a wrapper over its inner context
pub fn ReverseContext(comptime Context: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
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

        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                return self.context.sizeHintFn();
            } else {
                return .{};
            }
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

        pub fn reverseFn(self: *Self) void {
            self.context.reverseFn();
        }
    };
}

// An Reverse Iterator for a slice
// Iter should be a double-ended iterator
pub fn ReverseIterator(comptime Context: type) type {
    const ReverseContextType = ReverseContext(Context);
    return IIterator(ReverseContextType);
}

pub fn reverse(s: anytype) ReverseIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s)))) {
    return SliceIter.slice(s).reverse();
}
