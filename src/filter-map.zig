const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IIterator = @import("core/iterator.zig").IIterator;
const IterAssert = @import("utils.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;
const SliceIter = @import("slice.zig");

pub fn DoubleEndedFilterMapContext(comptime Context: type, comptime TransformFn: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = @typeInfo(TransformFn).Fn.return_type.?;

        transformFn: TransformFn,
        context: Context,

        pub fn init(context: InnerContextType, transformFn: TransformFn) Self {
            return Self{
                .transformFn = transformFn,
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
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.transformFn(value)) |_| {
                        count += 1;
                    }
                } else {
                    break;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) bool {
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekBackwardFn(i)) |value| {
                    if (self.transformFn(value)) |_| {
                        i += 1;
                    }
                } else {
                    break;
                }
            }
            return self.context.peekBackwardFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            while (self.context.nextFn()) |value| {
                if (self.transformFn(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            while (self.context.nextBackFn()) |value| {
                if (self.transformFn(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.nextFn()) |value| {
                if (self.transformFn(value)) |_| {
                    return true;
                }
            }
            return false;
        }

        pub fn skipBackFn(self: *Self) bool {
            while (self.context.nextBackFn()) |value| {
                if (self.transformFn(value)) |_| {
                    return true;
                }
            }
            return false;
        }
    };
}

pub fn FilterMapContext(comptime Context: type, comptime TransformFn: type) type {
    comptime {
        IterAssert.isIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = @typeInfo(TransformFn).Fn.return_type.?;

        transformFn: TransformFn = undefined,
        context: Context = undefined,

        pub fn init(context: InnerContextType, transformFn: TransformFn) Self {
            return Self{
                .context = context,
                .transformFn = transformFn,
            };
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

        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            var i: usize = 0;
            var count: usize = 0;
            while (count < n) : (i += 1) {
                if (self.context.peekAheadFn(i)) |value| {
                    if (self.transformFn(value)) |_| {
                        count += 1;
                    }
                } else {
                    break;
                }
            }
            return self.context.peekAheadFn(i);
        }

        pub fn nextFn(self: *Self) ?ItemType {
            while (self.context.nextFn()) |value| {
                if (self.transformFn(value)) |res| {
                    return res;
                }
            }
            return null;
        }

        pub fn skipFn(self: *Self) bool {
            while (self.context.nextFn()) |value| {
                if (self.transformFn(value)) |_| {
                    return true;
                }
            }
            return false;
        }
    };
}

/// A FilterMap Iterator struct
/// It's actually a wrapper over an iterator
pub fn FilterMapIterator(comptime Context: type, comptime TransformFn: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const FilterMapContextType = DoubleEndedFilterMapContext(Context, TransformFn);
        return IIterator(FilterMapContextType);
    } else {
        const FilterMapContextType = FilterMapContext(Context, TransformFn);
        return IIterator(FilterMapContextType);
    }
}

pub fn filterMap(s: anytype, transformFn: anytype) FilterMapIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s))), @TypeOf(transformFn)) {
    return SliceIter.slice(s).filter_map(transformFn);
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;

const SliceIterator = @import("slice.zig").SliceIterator;
const slice = @import("slice.zig").slice;

test "test FilterMapIterator" {
    const transform = struct {
        pub fn transform(value: u8) ?bool {
            if (value == '1') return true;
            return null;
        }
    }.transform;
    const StrIter = SliceIterator(u8);
    const str = "0011";
    var context = StrIter.IterContext.init(str);

    const Map = FilterMapIterator(StrIter.IterContext, @TypeOf(transform));
    var map_context = Map.IterContext.init(context, transform);
    var map_iter = Map.initWithContext(map_context);

    const truth = [_]bool{ true, true };
    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value.?});
        try testing.expectEqual(truth[i], value.?);
        i += 1;
    }
}

test "test slice filter_map" {
    const str: []const u8 = "0011";
    var slice_iter = slice(str);

    const transform = struct {
        pub fn transform(value: u8) ?bool {
            if (value == '1') return true;
            return null;
        }
    }.transform;
    var map_iter = slice_iter.filter_map(transform);

    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value.?});
        try testing.expect(value.?);
    }
}

test "test filterMap method" {
    const str: []const u8 = "0011";

    const transform = struct {
        pub fn transform(value: u8) ?bool {
            if (value == '1') return true;
            return null;
        }
    }.transform;

    var map_iter = filterMap(str, transform);
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value.?});
        try testing.expect(value.?);
    }
}
