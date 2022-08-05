const std = @import("std");
const testing = std.testing;

test "test all" {
    testing.refAllDecls(@import("fp.zig"));
    _ = @import("chain.zig");
    _ = @import("core/iterator.zig");
    _ = @import("enumerate.zig");
    _ = @import("filter.zig");
    _ = @import("filter-map.zig");
    _ = @import("map.zig");
    _ = @import("range.zig");
    _ = @import("reverse.zig");
    _ = @import("slice.zig");
    _ = @import("step.zig");
    _ = @import("take.zig");
    _ = @import("take-while.zig");
}
