const MapIterator = @import("../map.zig").MapIterator;
const RangeIterator = @import("../range.zig").RangeIterator;
const ReverseIterator = @import("../reverse.zig").ReverseIterator;
const slice = @import("../slice.zig").slice;
const FilterIterator = @import("../filter.zig").FilterIterator;
const FilterMapIterator = @import("../filter-map.zig").FilterMapIterator;
const EnumerateIterator = @import("../enumerate.zig").EnumerateIterator;
const IterAssert = @import("../utils.zig");
const SizeHint = @import("size-hint.zig").SizeHint;

const debug = @import("std").debug;
const testing = @import("std").testing;

/// Create a double-ended iterator if its context support
/// related methods like nextBackFn etc. Otherwise, it will
/// create a normal iterator type.
/// This is designed to be a low-level interface. That's to
/// say, you should define your iterator context to use this
/// interface.
///
/// Here are some reasons there are multiple constructors.
///
/// If you're familiar with OOP, this sounds like decorator
/// pattern. We could reuse the same context since most of
/// iterators are functional programming abstractions that
/// manipulate their beneath level of iterator's output.
///
/// 1. Basic iterators
///
/// Basic iterators are iterators over types or numbers,
/// which includes the SliceIterator and RangeIterator.
///
/// 2. Iterator with functions
///
/// When we want to modify the iterator's output on the fly,
/// i.e. with a map iterator, we could use the initWithFunc
/// to pass in the function type.
///
/// MapIterator, FilterIterator, FilterMapIterator are all
/// initialized with this function.
///
/// 3. Iterators without functions
///
/// EnumerateIterator and ReverseIterator are created with
/// initWithInnerContext.
///
/// With these 3 constructors, we could write chained function
/// calls.
///
/// const iter = range(u32,1,100).map(func1) // u32   -> Type1
///                              .map(func2) // Type1 -> Type2
///                              .map(func3) // Type2 -> Type3
///                              .map(func4) // Typee -> Type4
///
/// Note that this behavior relies on the Zig lang compiler.
/// It would also generate many intermediate types.
/// Although the Zig lang uses duck typing, which means
/// we could reuse existing types, the cost should not be
/// underestimated.
///
/// More specifically, above code would generate:
///
/// T1   RangeContext(u32)
/// T2   IIterator(T1)                -> range(u32,1,100)
/// T3   DoubleEndedMapContext(T2)
/// T4   IIterator(T3,@TypeOf(func1)) -> map(func1)
/// T5   DoubleEndedMapContext(T3)
/// T6   IIterator(T5,@TypeOf(func2)) -> map(func2)
/// T7   DoubleEndedMapContext(T5)
/// T8   IIterator(T7,@TypeOf(func3)) -> map(func3)
/// T9   DoubleEndedMapContext(T7)
/// T10  IIterator(T9,@TypeOf(func4)) -> map(func4)
///
///
pub fn IIterator(
    comptime Context: type,
) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        return struct {
            const Self = @This();
            pub const IterContext = Context;
            pub const ItemType = Context.ItemType;

            context: Context,

            /// return 0 if the context does not support
            /// size_hint
            pub fn size_hint(self: *Self) SizeHint {
                if (@hasDecl(IterContext, "sizeHintFn")) {
                    return self.context.sizeHintFn();
                } else {
                    return .{};
                }
            }

            pub fn initWithContext(context: IterContext) Self {
                return Self{ .context = context };
            }

            // for wrappers without Fn like Reverse
            pub fn initWithInnerContext(context: anytype) Self {
                return Self{ .context = Context{ .context = context } };
            }

            // for wrappers with Fn like Map,Filter,FilterMap
            pub fn initWithFunc(context: anytype, f: anytype) Self {
                return Self{ .context = Context{ .context = context, .func = f } };
            }

            /// Look at the next item without advancing
            pub fn peek(self: *Self) ?ItemType {
                return self.context.peekAheadFn(0);
            }

            /// Look at the nth item without advancing
            pub fn peekAhead(self: *Self, comptime n: usize) ?ItemType {
                return self.context.peekAheadFn(n);
            }

            /// Consumes the iterator and count the length
            pub fn count(self: *Self) usize {
                var len: usize = 0;
                while (self.nextFn()) |_| {
                    len += 1;
                }
                return len;
            }

            /// Advances the iterator and return the value
            pub fn next(self: *Self) ?ItemType {
                return self.context.nextFn();
            }

            pub fn nextBack(self: *Self) ?ItemType {
                return self.context.nextBackFn();
            }

            /// Advances the iterator, return false if failed
            pub fn skip(self: *Self) bool {
                return self.context.skipFn();
            }

            /// Advances the iterator backward, return false if failed
            pub fn skipBack(self: *Self) bool {
                return self.context.skipBackFn();
            }

            // this iterator should be exhausted after enumerate()
            pub fn enumerate(self: *Self) EnumerateIterator(Self.IterContext) {
                return EnumerateIterator(Self.IterContext).initWithInnerContext(self.context);
            }

            /// transform ItemType to NewType and return a new Iterator
            pub fn map(self: *Self, f: anytype) MapIterator(Self.IterContext, @TypeOf(f)) {
                // this iterator should be exhausted after reverse()
                return MapIterator(Self.IterContext, @TypeOf(f)).initWithFunc(self.context, f);
            }

            // this iterator should be exhausted after filter()
            pub fn filter(self: *Self, f: anytype) FilterIterator(Self.IterContext, @TypeOf(f)) {
                return FilterIterator(Self.IterContext, @TypeOf(f)).initWithFunc(self.context, f);
            }

            // this iterator should be exhausted after reverse()
            pub fn reverse(self: *Self) ReverseIterator(Self.IterContext) {
                self.context.reverseFn();
                return ReverseIterator(Self.IterContext).initWithInnerContext(self.context);
            }

            // this iterator should be exhausted after filter_map()
            pub fn filter_map(self: *Self, f: anytype) FilterMapIterator(Self.IterContext, @TypeOf(f)) {
                return FilterMapIterator(Self.IterContext, @TypeOf(f)).initWithFunc(self.context, f);
            }

            /// Consumes the iterator and apply the f for each item
            pub fn for_each(self: *Self, f: fn (item: ItemType) void) void {
                while (self.next()) |value| {
                    f(value);
                }
            }

            pub fn reduce(self: *Self, f: fn (accum: ItemType, cur: ItemType) ItemType) ?ItemType {
                var res = self.peek();
                _ = self.next();
                while (self.next()) |value| {
                    res = f(res.?, value);
                }
                return res;
            }

            // Consumes the iterator
            pub fn fold(self: *Self, comptime NewType: type, init: NewType, f: fn (NewType, ItemType) NewType) NewType {
                var res = init;
                while (self.next()) |value| {
                    res = f(res, value);
                }
                return res;
            }

            // Consumes the iterator
            pub fn find(self: *Self, f: fn (*ItemType) bool) ?ItemType {
                while (self.next()) |value| {
                    if (f(&value)) {
                        return value;
                    }
                }
                return null;
            }
        };
    } else {
        return struct {
            const Self = @This();
            pub const IterContext = Context;
            pub const ItemType = Context.ItemType;

            context: Context,

            /// return 0 if the context does not support
            /// size_hint
            pub fn size_hint(self: *Self) SizeHint {
                if (@hasDecl(IterContext, "sizeHintFn")) {
                    return self.context.sizeHintFn();
                } else {
                    return .{};
                }
            }

            pub fn initWithContext(context: IterContext) Self {
                return Self{ .context = context };
            }

            // for wrappers without Fn like Reverse
            pub fn initWithInnerContext(context: anytype) Self {
                return Self{ .context = Context{ .context = context } };
            }

            // for wrappers with Fn like Map,Filter,FilterMap
            pub fn initWithFunc(context: anytype, f: anytype) Self {
                return Self{ .context = Context{ .context = context, .func = f } };
            }

            /// Look at the next item without advancing
            pub fn peek(self: *Self) ?ItemType {
                return self.context.peekAheadFn(0);
            }

            /// Look at the nth item without advancing
            pub fn peekAhead(self: *Self, comptime n: usize) ?ItemType {
                return self.context.peekAheadFn(n);
            }

            /// Consumes the iterator and count the length
            pub fn count(self: *Self) usize {
                var len: usize = 0;
                while (self.nextFn()) |_| {
                    len += 1;
                }
                return len;
            }

            /// Advances the iterator and return the value
            pub fn next(self: *Self) ?ItemType {
                return self.context.nextFn();
            }

            /// Advances the iterator, return false if failed
            pub fn skip(self: *Self) bool {
                return self.context.skipFn();
            }

            // this iterator should be exhausted after enumerate()
            pub fn enumerate(self: *Self) EnumerateIterator(Self.IterContext) {
                return EnumerateIterator(Self.IterContext).initWithInnerContext(self.context);
            }

            /// transform ItemType to NewType and return a new Iterator
            pub fn map(self: *Self, f: anytype) MapIterator(Self.IterContext, @TypeOf(f)) {
                // this iterator should be exhausted after reverse()
                return MapIterator(Self.IterContext, @TypeOf(f)).initWithFunc(self.context, f);
            }

            // this iterator should be exhausted after filter()
            pub fn filter(self: *Self, f: anytype) FilterIterator(Self.IterContext, @TypeOf(f)) {
                return FilterIterator(Self.IterContext, @TypeOf(f)).initWithFunc(self.context, f);
            }

            // this iterator should be exhausted after filter_map()
            pub fn filter_map(self: *Self, f: anytype) FilterMapIterator(Self.IterContext, @TypeOf(f)) {
                return FilterMapIterator(Self.IterContext, @TypeOf(f)).initWithFunc(self.context, f);
            }

            /// Consumes the iterator and apply the f for each item
            pub fn for_each(self: *Self, f: fn (item: ItemType) void) void {
                while (self.next()) |value| {
                    f(value);
                }
            }

            pub fn reduce(self: *Self, f: fn (accum: ItemType, cur: ItemType) ItemType) ?ItemType {
                var res = self.peek();
                _ = self.next();
                while (self.next()) |value| {
                    res = f(res.?, value);
                }
                return res;
            }

            // Consumes the iterator
            pub fn fold(self: *Self, comptime NewType: type, init: NewType, f: fn (NewType, ItemType) NewType) NewType {
                var res = init;
                while (self.next()) |value| {
                    res = f(res, value);
                }
                return res;
            }

            // Consumes the iterator
            pub fn find(self: *Self, f: fn (*ItemType) bool) ?ItemType {
                while (self.next()) |value| {
                    if (f(&value)) {
                        return value;
                    }
                }
                return null;
            }
        };
    }
}

test "test filter" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4 };
    var iter = slice(ints);

    const S = struct {
        pub fn large(cur: u32) bool {
            return cur > 2;
        }
    }.large;

    var truth: []const u32 = &[_]u32{ 3, 4 };
    var filter_iter = iter.filter(S);
    var i: usize = 0;
    while (filter_iter.next()) |value| {
        debug.print("filter result {}\n", .{value});
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
}

test "test enumerate" {
    const str: []const u8 = "abcd";
    var iter = slice(str);
    var enum_iter = iter.enumerate();

    var i: usize = 0;
    while (enum_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(value.index, i);
        i += 1;
    }
}

test "test reverse" {
    const str: []const u8 = "abcd";
    var iter = slice(str);
    var reversed_iter = iter.reverse();

    const truth: []const u8 = "dcba";
    var i: usize = 0;
    while (reversed_iter.next()) |value| {
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
}

test "test reduce" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4 };
    var iter = slice(ints);

    const Fn = struct {
        pub fn sum(accum: u32, cur: u32) u32 {
            return accum + cur;
        }
    }.sum;

    var res = iter.reduce(Fn);
    debug.print("{}\n", .{res.?});
    try testing.expectEqual(@as(?u32, 10), res);
}

test "test for each" {
    const str: []const u8 = "abcd";
    var iter = slice(str);

    const Fn = struct {
        pub fn print(cur: u8) void {
            debug.print("{}\n", .{cur});
        }
    }.print;

    iter.for_each(Fn);
}

test "test fold" {
    const str: []const u8 = "abcd";
    var iter = slice(str);

    const Fn = struct {
        pub fn sum(accum: u32, cur: u8) u32 {
            return accum + @as(u32, (cur - 'a'));
        }
    }.sum;

    var res = iter.fold(u32, 0, Fn);
    debug.print("{}\n", .{res});
    try testing.expectEqual(@as(u32, 6), res);
}
