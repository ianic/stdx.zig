const std = @import("std");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// The sequence is such that the sets are ordered lexicographically
pub fn Lex(comptime max_k: u8) type {
    return struct {
        k: u8,
        n: u8,
        x: [max_k]u8 = undefined, // internal buffer

        const Self = @This();

        pub fn init(n: u8, k: u8) Self {
            assert(n >= k and k <= max_k and k > 1);
            var s = Self{
                .n = n,
                .k = k,
            };
            s.x[k - 1] = 0; // signal that first is not called
            return s;
        }

        // Initialize x with first combination.
        fn first(s: *Self) void {
            var i: u8 = 0;
            while (i < s.k) : (i += 1) {
                s.x[i] = i;
            }
        }

        pub fn isLast(s: *Self) bool {
            return s.x[0] == s.n - s.k;
        }

        pub fn current(s: *Self) []u8 {
            return s.x[0..s.k];
        }

        // Iterates over all combinations.
        // Returns next combination or null when no more combinations.
        // Example:
        //   while (lex.next()) |comb| {
        //      // use comb
        //   }
        pub fn next(s: *Self) ?[]u8 {
            return if (s.hasNext()) s.current() else null;
        }

        // For usage in while without capture.
        // Example:
        //   while (lex.hasNext()) {
        //      const comb = lex.current();
        //      // use comb
        //   }
        fn hasNext(s: *Self) bool {
            // first call
            if (s.x[s.k - 1] == 0) {
                s.first();
                return true;
            }

            // current combination is the last
            if (s.isLast()) return false;

            s.calcNext();
            return true;
        }

        fn calcNext(s: *Self) void {
            var j = s.k - 1;
            // easy case:  highest element != highest possible value:
            if (s.x[j] < (s.n - 1)) {
                s.x[j] += 1;
                return;
            }

            // find highest falling edge:
            while (1 == (s.x[j] - s.x[j - 1])) {
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
}

test "3/5 Lex" {
    var l = Lex(3).init(5, 3);

    var j: u8 = 0;
    // visit all combinations
    while (l.next()) |comb| {
        try expectEqualSlices(u8, &lex_test_data_5_3[j], comb);
        j += 1;
    }
    try expectEqual(lex_test_data_5_3.len, j); // we visited all of them
    try expectEqual(l.next(), null); // all other calls to next returns null
}

test "3/5  ensure working k>2" {
    if (true) return error.SkipZigTest;

    const n = 5;
    var k: u8 = 2;
    const T = Lex(n);
    std.debug.print("\n", .{});
    while (k <= n) : (k += 1) {
        std.debug.print("{d} / {d}\n", .{ k, n });
        var l = T.init(n, k);
        while (l.next()) |comb| {
            std.debug.print("\t{d}\n", .{comb});
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
