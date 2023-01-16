const std = @import("std");
const assert = std.debug.assert;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// The sequence is such that the sets are ordered lexicographically
pub const Lex = struct {
    n: u8,
    k: u8,
    a: []u8,

    const Self = @This();
    pub fn init(a: []u8, n: u6) Self {
        const k: u8 = @intCast(u8, a.len);
        assert(n >= k);

        var c = Self{
            .n = n,
            .k = k,
            .a = a,
        };
        c.first();
        return c;
    }

    pub fn first(c: *Self) void {
        var i: u8 = 0;
        while (i < c.k) : (i += 1) {
            c.a[i] = i;
        }
    }

    pub fn next(c: *Self) bool {
        if (c.a[0] == c.n - c.k) { // current combination is the last
            return false;
        }

        var j = c.k - 1;
        // easy case:  highest element != highest possible value:
        if (c.a[j] < (c.n - 1)) {
            c.a[j] += 1;
            return true;
        }

        // find highest falling edge:
        while (1 == (c.a[j] - c.a[j - 1])) {
            j -= 1;
        }

        // move lowest element of highest block up:
        c.a[j - 1] += 1;
        var z = c.a[j - 1];
        // ... and attach rest of block:
        while (j < c.k) : (j += 1) {
            z += 1;
            c.a[j] = z;
        }

        return true;
    }
};

const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

const test_data_5_3 = [10][3]u8{
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

test "3/5" {
    var buf: [3]u8 = undefined;
    var l = Lex.init(&buf, 5);

    // visit first combination
    try expectEqualSlices(u8, &test_data_5_3[0], &buf);

    var j: u8 = 1;
    while (l.next()) : (j += 1) {
        // call next and then visit another combination
        try expectEqualSlices(u8, &test_data_5_3[j], &buf);
    }
    // next returns false
    try expectEqual(l.next(), false);

    // rewind to the start
    l.first();
    try expectEqualSlices(u8, &test_data_5_3[0], &buf);
}

pub fn LexT(comptime max_k: u8) type {
    return struct {
        k: u8,
        n: u8,
        buf: [max_k]u8 = undefined, // internal buffer
        x: []u8 = undefined, // holds current combination

        const Self = @This();

        pub fn init(n: u8, k: u8) Self {
            assert(n >= k and k <= max_k);
            var s = Self{
                .n = n,
                .k = k,
            };
            s.reset();
            return s;
        }

        // Reset x to zero len so we can detect first call to next.
        inline fn reset(s: *Self) void {
            s.x = s.buf[0..0];
        }

        // Initialize x with first combination.
        fn first(s: *Self) void {
            s.x = s.buf[0..s.k];
            var i: u8 = 0;
            while (i < s.k) : (i += 1) {
                s.x[i] = i;
            }
        }

        inline fn isLast(s: *Self) bool {
            return s.x[0] == s.n - s.k;
        }

        pub inline fn current(s: *Self) []u8 {
            return s.x;
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
        pub fn hasNext(s: *Self) bool {
            // first call
            if (s.x.len == 0) {
                s.first();
                return true;
            }

            // current combination is the last
            if (s.isLast()) {
                return false;
            }

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

test "3/5 for LexT" {
    var l = LexT(3).init(5, 3);

    var j: u8 = 0;
    // visit all combinations
    while (l.next()) |comb| {
        try expectEqualSlices(u8, &test_data_5_3[j], comb);
        j += 1;
    }
    try expectEqual(test_data_5_3.len, j); // we visited all of them
    try expectEqual(l.next(), null); // all other calls to next returns null
}
