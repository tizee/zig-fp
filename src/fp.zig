pub const IIterator = @import("core/iterator.zig").IIterator;

pub const MapIterator = @import("map.zig").MapIterator;
pub const map = @import("map.zig").map;

pub const SliceIterator = @import("slice.zig").SliceIterator;
pub const slice = @import("slice.zig").slice;

pub const RangeIterator = @import("range.zig").RangeIterator;
pub const range = @import("range.zig").slice;

pub const ReverseIterator = @import("reverse.zig").ReverseIterator;
pub const reverse = @import("reverse.zig").reverse;

pub const FilterIterator = @import("filter.zig").FilterIterator;
pub const filter = @import("filter.zig").filter;

pub const EnumerateIterator = @import("enumerate.zig").EnumerateIterator;
pub const enumerate = @import("enumerate.zig").enumerate;
