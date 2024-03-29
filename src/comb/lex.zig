const std = @import("std");
const iterator = @import("iterator.zig");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// The sequence is such that the sets are ordered lexicographically
pub const Lex = struct {
    k: u8,
    n: u8,
    x: []u8,

    const Self = @This();

    pub fn init(n: u8, k: u8, buf: []u8) Self {
        assert(k > 0 and n >= k and buf.len >= k);

        var s = Self{
            .n = n,
            .k = k,
            .x = buf[0..k],
        };
        s.first();
        return s;
    }

    // Initialize x with first combination.
    pub fn first(s: *Self) void {
        var i: u8 = 0;
        while (i < s.k) : (i += 1)
            s.x[i] = i;
    }

    pub fn current(s: *Self) []u8 {
        return s.x[0..s.k];
    }

    // For iterating over all combinations.
    // It is initialized with first combination after init.
    // Use it in loop with check at end.
    // Example:
    //   var hasMore = true;
    //   while (hasMore) : (alg.more()) {
    //      // use alg.current();
    //   }
    pub fn more(s: *Self) bool {
        if (s.isLast())
            return false;
        s.move();
        return true;
    }

    fn isLast(s: *Self) bool {
        return s.x[0] == s.n - s.k;
    }

    fn move(s: *Self) void {
        var j = s.k - 1;
        // easy case:  highest element != highest possible value:
        if (s.x[j] < (s.n - 1)) {
            s.x[j] += 1;
            return;
        }

        // find highest falling edge:
        while (s.x[j - 1] + 1 == s.x[j]) {
            j -= 1;
        }

        // move lowest element of highest block up:
        s.x[j - 1] += 1;
        var z = s.x[j - 1];
        // ... and attach rest of block:
        while (j < s.k) : (j += 1) {
            z += 1;
            s.x[j] = z;
        }
    }

    const Iterator = iterator.Iterator(Lex, []u8);

    pub fn iter(s: *Self) Iterator {
        return Iterator{ .alg = s, .is_first = s.x[s.k - 1] == s.k - 1 };
    }
};

const binomial = @import("binomial.zig").binomial;

test "3/5 Lex" {
    var buf: [3]u8 = undefined;
    var alg = Lex.init(5, 3, &buf);

    var i: u8 = 15;
    var hasMore = true;
    while (hasMore) : (hasMore = alg.more()) {
        const expected = test_data_5[i][0..3];
        try expectEqualSlices(u8, expected, alg.current());
        i += 1;
    }
    try expectEqual(binomial(5, 3), i - 15); // we visited all of them
    try expectEqual(false, alg.more()); // all other calls to next returns null
}

test "*/5 Lex" {
    var buf: [test_data_n]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = Lex.init(test_data_n, k, &buf);
        var hasMore = true;

        while (hasMore) : ({
            hasMore = alg.more();
            i += 1;
        }) {
            const expected = test_data_5[i][0..k];
            try expectEqualSlices(u8, expected, alg.current());
        }
    }
    try expectEqual(i, 31); // we visited all of them
}

test "*/5 Lex iterator interface" {
    var buf: [test_data_n + 3]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = Lex.init(test_data_n, k, &buf);
        var iter = alg.iter();

        while (iter.next()) |current| {
            const expected = test_data_5[i][0..k];
            try expectEqualSlices(u8, expected, current);
            i += 1;
        }
    }
    try expectEqual(i, 31); // we visited all of them
}

const test_data_n = 5;
// 0xff are unused, just tu have arrays of same len
const test_data_5 = [_][5]u8{
    [_]u8{ 0, 0xff, 0xff, 0xff, 0xff },
    [_]u8{ 1, 0xff, 0xff, 0xff, 0xff },
    [_]u8{ 2, 0xff, 0xff, 0xff, 0xff },
    [_]u8{ 3, 0xff, 0xff, 0xff, 0xff },
    [_]u8{ 4, 0xff, 0xff, 0xff, 0xff },

    [_]u8{ 0, 1, 0xff, 0xff, 0xff },
    [_]u8{ 0, 2, 0xff, 0xff, 0xff },
    [_]u8{ 0, 3, 0xff, 0xff, 0xff },
    [_]u8{ 0, 4, 0xff, 0xff, 0xff },
    [_]u8{ 1, 2, 0xff, 0xff, 0xff },
    [_]u8{ 1, 3, 0xff, 0xff, 0xff },
    [_]u8{ 1, 4, 0xff, 0xff, 0xff },
    [_]u8{ 2, 3, 0xff, 0xff, 0xff },
    [_]u8{ 2, 4, 0xff, 0xff, 0xff },
    [_]u8{ 3, 4, 0xff, 0xff, 0xff },

    [_]u8{ 0, 1, 2, 0xff, 0xff },
    [_]u8{ 0, 1, 3, 0xff, 0xff },
    [_]u8{ 0, 1, 4, 0xff, 0xff },
    [_]u8{ 0, 2, 3, 0xff, 0xff },
    [_]u8{ 0, 2, 4, 0xff, 0xff },
    [_]u8{ 0, 3, 4, 0xff, 0xff },
    [_]u8{ 1, 2, 3, 0xff, 0xff },
    [_]u8{ 1, 2, 4, 0xff, 0xff },
    [_]u8{ 1, 3, 4, 0xff, 0xff },
    [_]u8{ 2, 3, 4, 0xff, 0xff },

    [_]u8{ 0, 1, 2, 3, 0xff },
    [_]u8{ 0, 1, 2, 4, 0xff },
    [_]u8{ 0, 1, 3, 4, 0xff },
    [_]u8{ 0, 2, 3, 4, 0xff },
    [_]u8{ 1, 2, 3, 4, 0xff },

    [_]u8{ 0, 1, 2, 3, 4 },
};
