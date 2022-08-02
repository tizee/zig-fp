const IIterator = @import("core/iterator.zig").IIterator;
const SizeHint = @import("core/size-hint.zig").SizeHint;

const SliceIter = @import("slice.zig");
const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

pub fn DoubleEndedEnumerateContext(comptime Context: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = struct { index: usize, value: Context.ItemType };

        index: usize = 0,
        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{ .context = context, .index = @as(usize, 0) };
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
            if (self.context.peekAheadFn(n)) |value| {
                return ItemType{
                    .index = self.index + n,
                    .value = value,
                };
            }
            return null;
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            if (self.context.peekBackwardFn(n)) |value| {
                return ItemType{
                    .index = self.index - n,
                    .value = value,
                };
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                defer self.index += 1;
                return ItemType{
                    .index = self.index,
                    .value = value,
                };
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.context.nextBackFn()) |value| {
                defer self.index += 1;
                return ItemType{
                    .index = self.index,
                    .value = value,
                };
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }

        pub fn skipBackFn(self: *Self) bool {
            return self.context.skipBackFn();
        }
    };
}

pub fn EnumerateContext(comptime Context: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = struct { index: usize, value: Context.ItemType };

        index: usize,
        context: Context,

        pub fn init(context: InnerContextType) Self {
            return Self{ .context = context, .index = @as(usize, 0) };
        }

        /// return 0 if the context does not support
        /// size_hint
        pub fn size_hint(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                return self.context.sizeHintFn();
            } else {
                return .{};
            }
        }

        /// Look at the nth item without advancing
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            if (self.context.peekAheadFn(n)) |value| {
                return ItemType{
                    .index = self.index + n,
                    .value = value,
                };
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                defer self.index += 1;
                return ItemType{
                    .index = self.index,
                    .value = value,
                };
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }
    };
}

/// A Enumerate Iterator struct
/// It's actually a wrapper over an iterator
pub fn EnumerateIterator(comptime Context: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const EnumerateContextType = DoubleEndedEnumerateContext(Context);
        return IIterator(EnumerateContextType);
    } else {
        const EnumerateContextType = EnumerateContext(Context);
        return IIterator(EnumerateContextType);
    }
}

pub fn enumerate(s: anytype) EnumerateIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s)))) {
    return SliceIter.slice(s).enumerate();
}
