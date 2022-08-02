const math = @import("std").math;
const IIterator = @import("core/iterator.zig").IIterator;
const SliceIter = @import("slice.zig");
const SizeHint = @import("core/size-hint.zig").SizeHint;

const GetPtrChildType = @import("utils.zig").GetPtrChildType;
const IterAssert = @import("utils.zig");

/// The Step iterator is designed to be lazily evaluated
/// as the the map iterator
/// It's just a wrapper over underlying iterator
pub fn DoubleEndedStepContext(comptime Context: type) type {
    comptime {
        IterAssert.assertDoubleEndedIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context = undefined,
        start: bool = false,
        step: usize = 1,

        pub fn init(context: InnerContextType, init_state: usize) Self {
            if (init_state == 0) {
                @panic("StepIterator should use a positive and non-zero step");
            }
            return Self{
                .context = context,
                .step = init_state,
                .start = false,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                if (self.context.sizeHintFn().len()) |value| {
                    const steps = math.divCeil(usize, value, self.step) catch 0;
                    return SizeHint{
                        .low = steps,
                        .high = steps,
                    };
                }
                return .{};
            } else {
                return .{};
            }
        }

        /// Look at the nth item without advancing
        /// index = n * step
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            return self.context.peekAheadFn(n * self.step);
        }

        pub fn peekBackwardFn(self: *Self, n: usize) ?ItemType {
            return self.context.peekBackwardFn(n * self.step);
        }

        /// set a counter for the step
        /// always start from the first item
        pub fn nextFn(self: *Self) ?ItemType {
            if (!self.start) {
                self.start = true;
                return self.context.nextFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipFn()) {
                    return null;
                }
            }
            return self.context.nextFn();
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (!self.start) {
                self.start = true;
                return self.context.nextBackFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipBackFn()) {
                    return null;
                }
            }
            return self.context.nextBackFn();
        }

        pub fn skipFn(self: *Self) bool {
            if (!self.start) {
                self.start = true;
                return self.context.skipFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipFn()) {
                    return null;
                }
            }
            return self.context.skipFn();
        }

        pub fn skipBackFn(self: *Self) bool {
            if (!self.start) {
                self.start = true;
                return self.context.skipBackFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipBackFn()) {
                    return null;
                }
            }
            return self.context.skipBackFn();
        }

        pub fn reverseFn(self: *Self) void {
            self.context.reverseFn();
        }
    };
}

pub fn StepContext(comptime Context: type) type {
    comptime {
        IterAssert.assertIteratorContext(Context);
    }
    return struct {
        const Self = @This();
        pub const InnerContextType = Context;
        pub const ItemType = Context.ItemType;

        context: Context = undefined,
        start: bool = false,
        step: usize = 1,

        pub fn init(context: InnerContextType, init_state: usize) Self {
            if (init_state == 0) {
                @panic("StepIterator should use a positive and non-zero step");
            }
            return Self{
                .context = context,
                .step = init_state,
                .start = false,
            };
        }
        /// return 0 if the context does not support
        /// size_hint
        pub fn sizeHintFn(self: *Self) SizeHint {
            if (@hasDecl(InnerContextType, "sizeHintFn")) {
                if (self.context.sizeHintFn().len()) |value| {
                    const steps = math.divCeil(usize, value, self.step);
                    return .{
                        .low = steps,
                        .high = steps,
                    };
                }
            } else {
                return {};
            }
        }

        /// Look at the nth item without advancing
        /// index = n * step
        pub fn peekAheadFn(self: *Self, n: usize) ?ItemType {
            return self.context.peekAheadFn(n * self.step);
        }

        /// set a counter for the step
        /// always start from the first item
        pub fn nextFn(self: *Self) ?ItemType {
            if (!self.start) {
                self.start = true;
                return self.context.nextFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipFn()) {
                    return null;
                }
            }
            return self.context.nextFn();
        }

        pub fn nextBackFn(self: *Self) ?ItemType {
            if (!self.start) {
                self.start = true;
                return self.context.nextBackFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipBackFn()) {
                    return null;
                }
            }
            return self.context.nextBackFn();
        }

        pub fn skipFn(self: *Self) bool {
            if (!self.start) {
                self.start = true;
                return self.context.skipFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipFn()) {
                    return null;
                }
            }
            return self.context.skipFn();
        }

        pub fn skipBackFn(self: *Self) bool {
            if (!self.start) {
                self.start = true;
                return self.context.skipBackFn();
            }
            var i: usize = 0;
            while (i < self.step - 1) : (i += 1) {
                if (!self.context.skipBackFn()) {
                    return null;
                }
            }
            return self.context.skipBackFn();
        }
    };
}

/// A Step Iterator constructor
/// It's actually a wrapper over an iterator
pub fn StepIterator(comptime Context: type) type {
    if (IterAssert.isDoubleEndedIteratorContext(Context)) {
        const StepContextType = DoubleEndedStepContext(Context);
        return IIterator(StepContextType);
    } else {
        const StepContextType = StepContext(Context);
        return IIterator(StepContextType);
    }
}

pub fn step(s: anytype, state: usize) StepIterator(SliceIter.SliceContext(GetPtrChildType(@TypeOf(s)))) {
    return SliceIter.slice(s).step(state);
}

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const slice = @import("slice.zig").slice;

test "test step method" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const truth: []const u32 = &[_]u32{ 1, 3, 5, 7 };

    var step_iter = step(ints, 2);
    try IterAssert.testIterator(step_iter, truth, 4, .{
        .low = 4,
        .high = 4,
    });
}

test "test slice step" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const truth: []const u32 = &[_]u32{ 1, 3, 5, 7 };

    var step_iter = SliceIter.slice(ints).step(2);

    try IterAssert.testIterator(step_iter, truth, 4, .{
        .low = 4,
        .high = 4,
    });
}
