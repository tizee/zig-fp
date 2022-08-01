const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const FilterMapIterator = @import("filter-map.zig").FilterMapIterator;
const filterMap = @import("filter-map.zig").filterMap;

const SliceIterator = @import("slice.zig").SliceIterator;
const slice = @import("slice.zig").slice;

fn transform(value: u8) ?bool {
    if (value == '1') return true;
    return null;
}

test "test FilterMapIterator" {
    const StrIter = SliceIterator(u8);
    const str = "0011";
    var context = StrIter.IterContext.init(str);

    const Map = FilterMapIterator(StrIter.IterContext, bool, transform);
    var map_context = Map.IterContext.init(context);
    var map_iter = Map.initWithContext(map_context);

    const truth = [_]bool{ true, true };
    var i: usize = 0;
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expectEqual(truth[i], value);
        i += 1;
    }
}

test "test slice filter_map" {
    const str = "0011";
    var slice_iter = slice(u8, str);

    var map_iter = slice_iter.filter_map(bool, transform);

    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expect(value);
    }
}

test "test filterMap method" {
    const str = "0011";

    var map_iter = filterMap(u8, bool, str, transform);
    while (map_iter.next()) |value| {
        debug.print("{}\n", .{value});
        try testing.expect(value);
    }
}
