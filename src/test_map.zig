const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const MapIterator = @import("map.zig").MapIterator;
const map = @import("map.zig").map;

const SliceIterator = @import("slice.zig").SliceIterator;
const slice = @import("slice.zig").slice;

fn transform(value: u8) bool {
    if (value == '1') return true;
    return false;
}

fn transform2(value: bool) u8 {
    if (value) return '1';
    return '0';
}

test "test MapIterator" {
    const StrIter = SliceIterator(u8);
    const str = "0011";
    var context = StrIter.IterContext.init(str);

    const Map = MapIterator(StrIter.IterContext, bool, transform);
    var map_context = Map.IterContext.init(context);
    var map_iter = Map.initWithContext(map_context);

    const truth = [_]bool{ false, false, true, true };
    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
}

test "test slice map" {
    const str = "0011";
    var slice_iter = slice(u8, str);

    var map_iter = slice_iter
        .map(bool, transform)
        .map(u8, transform2);

    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(str[i], value);
        i += 1;
    }
}

test "test map method" {
    const str = "0011";

    var map_iter = map(u8, bool, str, transform)
        .map(u8, transform2);

    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(str[i], value);
        i += 1;
    }
}
