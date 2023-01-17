const std = @import("std");

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
        assert(n >= k and k > 0 and buf.len >= k);

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
};

test "3/5 Lex" {
    var buf: [3]u8 = undefined;
    var alg = Lex.init(5, 3, &buf);

    var j: u8 = 0;
    var hasMore = true;
    while (hasMore) : (hasMore = alg.more()) {
        try expectEqualSlices(u8, &lex_test_data_5_3[j], alg.current());
        j += 1;
    }
    try expectEqual(lex_test_data_5_3.len, j); // we visited all of them
    try expectEqual(false, alg.more()); // all other calls to next returns null
}

test "3/5  ensure working k>2" {
    //    if (true) return error.SkipZigTest;

    var buf: [5]u8 = undefined;
    const n = 5;
    var k: u8 = 1;

    std.debug.print("\n", .{});
    while (k <= n) : (k += 1) {
        std.debug.print("{d} / {d}\n", .{ k, n });
        var alg = Lex.init(n, k, &buf);
        var hasMore = true;
        while (hasMore) : (hasMore = alg.more()) {
            std.debug.print("\t{d}\n", .{alg.current()});
        }
    }
}

const lex_test_data_5_3 = [10][3]u8{
    [_]u8{ 0, 1, 2 },
    [_]u8{ 0, 1, 3 },
    [_]u8{ 0, 1, 4 },
    [_]u8{ 0, 2, 3 },
    [_]u8{ 0, 2, 4 },
    [_]u8{ 0, 3, 4 },
    [_]u8{ 1, 2, 3 },
    [_]u8{ 1, 2, 4 },
    [_]u8{ 1, 3, 4 },
    [_]u8{ 2, 3, 4 },
};
