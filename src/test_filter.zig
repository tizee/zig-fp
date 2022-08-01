const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const DoubleEndedFilterContext = @import("filter.zig").DoubleEndedFilterContext;
const filter = @import("filter.zig").filter;
const slice = @import("slice.zig").slice;

test "test filter with map" {
    const ints = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    var iter = slice(u32, ints);

    const S = struct {
        pub fn is_even(cur: ?u32) bool {
            if (cur) |value| {
                return value % 2 == 0;
            }
            return false;
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

    var map_iter = filter_iter.map(bool, Fn);

    while (map_iter.next()) |value| {
        debug.print("map_iter result {}\n", .{value});
    }
}

test "test filter method" {
    const ints = &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };

    const S = struct {
        pub fn is_even(cur: ?u32) bool {
            if (cur) |value| {
                return value % 2 == 0;
            }
            return false;
        }
    }.is_even;
    var filter_iter = filter(u32, ints, S);

    const Fn = struct {
        pub fn toChar(old: u32) bool {
            if (@mod(old, 2) == 0) {
                return true;
            } else {
                return false;
            }
        }
    }.toChar;

    var map_iter = filter_iter.map(bool, Fn);

    while (map_iter.next()) |value| {
        debug.print("map_iter result {}\n", .{value});
    }
}
