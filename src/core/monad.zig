const std = @import("std");

pub fn Monad(comptime T: type, comptime F: anytype) type {
    if (comptime std.meta.trait.hasFunctions(F(T), .{ "Monad_pure", "Monad_bind" })) {
        return F(T);
    } else {
        @compileError("given type is not monad instance");
    }
}

pub fn MonadicOption(comptime T: type) type {
    return struct {
        const Self = @This();
        some: bool,
        value: T,
        pub fn Monad_pure(t: T) Self {
            return Self{ .some = true, .value = t };
        }
        pub fn Monad_bind(self: Self, f: anytype) Self {
            if (self.some) {
                return f.invoke(.{self.value});
            } else {
                return self;
            }
        }
    };
}

// thanks MasterQ32/closure.zig
pub fn Closure(comptime function: anytype) type {
    const F = @TypeOf(function);
    const A0 = @typeInfo(F).Fn.args[0].arg_type.?;

    return struct {
        const Self = @This();

        pub const is_mutable = (@typeInfo(A0) == .Pointer);
        pub const State = if (is_mutable)
            std.meta.Child(A0)
        else
            A0;
        pub const Result = (@typeInfo(F).Fn.return_type.?);

        state: State,

        pub fn init(state: State) Self {
            return Self{ .state = state };
        }

        pub fn invoke(self: if (is_mutable) *Self else Self, args: anytype) Result {
            return @call(.{}, function, .{if (is_mutable) &self.state else self.state} ++ args);
        }
    };
}

const testing = std.testing;

test "simple monad" {
    const AddM = struct {
        pub fn add_m(comptime T: type, comptime F: anytype, a1: Monad(T, F), a2: Monad(T, F)) Monad(T, F) {
            const closure1 = Closure(struct {
                fn f(state: struct { a2: Monad(T, F) }, a: T) Monad(T, F) {
                    const closure2 = Closure(struct {
                        fn g(state1: struct { a: T }, b: T) Monad(T, F) {
                            return Monad(T, F).Monad_pure(state1.a + b);
                        }
                    }.g).init(
                        .{ .a = a },
                    );
                    return Monad(T, F).Monad_bind(state.a2, closure2);
                }
            }.f).init(
                .{ .a2 = a2 },
            );
            return Monad(T, F).Monad_bind(a1, closure1);
        }
    }.add_m;
    const res = AddM(i32, MonadicOption, MonadicOption(i32).Monad_pure(1), MonadicOption(i32).Monad_pure(2));
    try testing.expectEqual(@as(i32, 3), res.value);
}
