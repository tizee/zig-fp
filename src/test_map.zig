const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const MapIterator = @import("map.zig").MapIterator;
const SliceIterator = @import("slice.zig").SliceIterator;

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
    var slice_iter = StrIter.initWithContext(context);

    const Map = MapIterator(StrIter, bool, transform);
    var map_iter = Map.init(&slice_iter);

    const truth = [_]bool{ false, false, true, true };
    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
}

test "test map" {
    const StrIter = SliceIterator(u8);
    const str = "0011";
    var context = StrIter.IterContext.init(str);
    var slice_iter = StrIter.initWithContext(context);

    var map_iter = slice_iter.map(bool, transform).map(u8, transform2);

    const truth = "0011";
    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
}
