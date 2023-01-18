// Iterators for algorithms which provide more and current functions.
// T - algorithm type
// RetT - type which is returned from alg.current(); []u8, []u1
pub fn Iterator(comptime T: anytype, comptime RetT: anytype) type {
    return struct {
        alg: *T,
        is_first: bool,

        const Self = @This();

        pub fn next(i: *Self) ?RetT {
            if (i.is_first) {
                i.is_first = false;
                return i.alg.current();
            }
            return if (i.alg.more()) i.alg.current() else null;
        }
    };
}
