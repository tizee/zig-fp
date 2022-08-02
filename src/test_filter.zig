const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const DoubleEndedFilterContext = @import("filter.zig").DoubleEndedFilterContext;
const filter = @import("filter.zig").filter;
const slice = @import("slice.zig").slice;

test "test filter with map" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    var iter = slice(ints);

    const S = struct {
        pub fn is_even(cur: u32) bool {
            return cur % 2 == 0;
        }
    }.is_even;
    var filter_iter = iter.filter(S);

    const Fn = struct {
        pub fn toChar(old: u32) bool {
            if (@mod(old, 2) == 0) {
                return true;
            } else {
                return false;
            }
        }
    }.toChar;

    var map_iter = filter_iter.map(Fn);

    while (map_iter.next()) |value| {
        debug.print("map_iter result {}\n", .{value});
    }
}

test "test filter method" {
    const ints: []const u32 = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };

    const S = struct {
        pub fn is_even(cur: u32) bool {
            return cur % 2 == 0;
        }
    }.is_even;
    var filter_iter = filter(ints, S);

    const Fn = struct {
        pub fn toChar(old: u32) bool {
            if (@mod(old, 2) == 0) {
                return true;
            } else {
                return false;
            }
        }
    }.toChar;

    var map_iter = filter_iter.map(Fn);

    while (map_iter.next()) |value| {
        debug.print("map_iter result {}\n", .{value});
    }
}
