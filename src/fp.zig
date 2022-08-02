///  Iterators
pub const Chain = @import("chain.zig").ChainIterator;
pub const EnumerateIterator = @import("enumerate.zig").EnumerateIterator;
pub const FilterIterator = @import("filter.zig").FilterIterator;
pub const FilterMapIterator = @import("filter-map.zig").FilterMapIterator;
pub const IIterator = @import("core/iterator.zig").IIterator;
pub const MapIterator = @import("map.zig").MapIterator;
pub const RangeIterator = @import("range.zig").RangeIterator;
pub const ReverseIterator = @import("reverse.zig").ReverseIterator;
pub const SliceIterator = @import("slice.zig").SliceIterator;
pub const StepIterator = @import("step.zig").StepIterator;

pub const chain = @import("chain.zig").chain;
pub const enumerate = @import("enumerate.zig").enumerate;
pub const filter = @import("filter.zig").filter;
pub const filterMap = @import("filter-map.zig").filterMap;
pub const map = @import("map.zig").map;
pub const range = @import("range.zig").range;
pub const reverse = @import("reverse.zig").reverse;
pub const slice = @import("slice.zig").slice;
pub const step = @import("step.zig").step;

/// Monad
pub const Monad = @import("core/monad.zig").Monad;
pub const MonadicOption = @import("core/monad.zig").MonadicOption;
pub const Closure = @import("core/monad.zig").Closure;
