const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const IterAssert = @import("utils.zig");
const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const SizeHint = @import("core/size-hint.zig").SizeHint;

pub fn DoubleEndedMapContext(comptime Context: type, comptime TransformFn: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = @typeInfo(TransformFn).Fn.return_type.?;

        context: Context,
        func: TransformFn = undefined,

        pub fn init(context: InnerContextType, f: TransformFn) Self {
            return Self{
                .context = context,
                .func = f,
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
            if (self.context.peekAheadFn(n)) |value| {
                return self.func(value);
            }
            return null;
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            if (self.context.peekBackwardFn(n)) |value| {
                return self.func(value);
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                return self.func(value);
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (self.context.nextBackFn()) |value| {
                return self.func(value);
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

pub fn MapContext(comptime Context: type, comptime TransformFn: type) type {
    comptime {
        IterAssert.isIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = @typeInfo(TransformFn).Fn.return_type.?;

        context: Context,
        func: TransformFn = undefined,

        pub fn init(context: InnerContextType) Self {
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
            if (self.context.peekAheadFn(n)) |value| {
                return self.func(value);
            }
            return null;
        }

        pub fn nextFn(self: *Self) ?ItemType {
            if (self.context.nextFn()) |value| {
                return self.func(value);
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            return self.context.skipFn();
        }
    };
}

/// A Map Iterator struct
/// It's actually a wrapper over an iterator
pub fn MapIterator(comptime Context: type, comptime TransformFn: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const MapContextType = DoubleEndedMapContext(Context, TransformFn);
        return IIterator(MapContextType);
    } else {
        const MapContextType = MapContext(Context, TransformFn);
        return IIterator(MapContextType);
    }
}

pub fn map(s: anytype, transformFn: anytype) MapIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s))), @TypeOf(transformFn)) {
    return SliceIter.slice(s).map(transformFn);
}
