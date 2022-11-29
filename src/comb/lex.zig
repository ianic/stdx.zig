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
    try std.testing.expectEqualSlices(u8, &test_data_5_3[0], &buf);

    var j: u8 = 1;
    while (l.next()) : (j += 1) {
        // call next and then visit another combination
        try std.testing.expectEqualSlices(u8, &test_data_5_3[j], &buf);
    }
    // next returns false
    try std.testing.expectEqual(l.next(), false);

    // rewind to the start
    l.first();
    try std.testing.expectEqualSlices(u8, &test_data_5_3[0], &buf);
}
