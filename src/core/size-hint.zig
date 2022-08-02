/// SizeHint is used for get the length of iterator
pub const SizeHint = struct {
    low: usize = 0,
    high: ?usize = null,

    pub fn len(hint: *@This()) ?usize {
        if (hint.max) |value| {
            return value;
        }
        return null;
    }

    /// create a new SizeHint from two SizeHint
    pub fn join(hint1: SizeHint, hint2: SizeHint) SizeHint {
        if (hint1.high) |h1| {
            if (hint2.high) |h2| {
                return SizeHint{
                    .low = hint1.low + hint2.low,
                    .high = h1 + h2,
                };
            }
        }
        return SizeHint{ .low = hint1.low + hint2.low, .high = null };
    }
};
