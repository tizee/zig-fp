const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const DoubleEndedFilterContext = @import("filter.zig").DoubleEndedFilterContext;
const SliceIterator = @import("slice.zig").SliceIterator;

test "test filter with map" {
    const SliceInt = SliceIterator(u32);

    const slice = [_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    var context = SliceInt.IterContext.init(&slice);
    var iter = SliceInt.initWithContext(context);

    const S = struct {
        pub fn large(cur: ?u32) bool {
            if (cur) |value| {
                if (value > 2) {
                    return true;
                }
            }
            return false;
        }
    }.large;
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
