test "test all" {
    _ = @import("test_range.zig");
    _ = @import("test_reverse.zig");
    _ = @import("test_slice.zig");
    _ = @import("test_map.zig");
    _ = @import("test_filter.zig");
    _ = @import("test_filter_map.zig");
    _ = @import("test_enumerate.zig");
    _ = @import("iterator/double_ended_iterator.zig");
}
