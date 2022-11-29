const std = @import("std");
const assert = std.debug.assert;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// in co-lexicographic order
pub const CoLex = struct {
    m: u8, // max index in a = n - k
    a: []u8, // working array

    const Self = @This();
    pub fn init(a: []u8, n: u8) Self {
        const k: u8 = @intCast(u8, a.len);
        assert(n >= k);

        var c = Self{
            .m = n - k,
            .a = a,
        };
        c.first();
        return c;
    }

    pub fn first(c: *Self) void {
        var i: u8 = 0;
        while (i < c.a.len) : (i += 1) {
            c.a[i] = i;
        }
    }

    // find next combination
    pub fn next(c: *Self) bool {
        if (c.a[0] == c.m) { // current combination is the last
            return false;
        }
        var j: u8 = 0;
        // until lowest rising edge:  attach block at low end
        while (j + 1 < c.a.len and 1 == (c.a[j + 1] - c.a[j])) : (j += 1) {
            c.a[j] = j;
        }
        c.a[j] += 1; // move edge element up
        return true;
    }
};

const test_data_5_3 = [10][3]u8{
    [_]u8{ 0, 1, 2 },
    [_]u8{ 0, 1, 3 },
    [_]u8{ 0, 2, 3 },
    [_]u8{ 1, 2, 3 },
    [_]u8{ 0, 1, 4 },
    [_]u8{ 0, 2, 4 },
    [_]u8{ 1, 2, 4 },
    [_]u8{ 0, 3, 4 },
    [_]u8{ 1, 3, 4 },
    [_]u8{ 2, 3, 4 },
};

test "5/3" {
    var buf: [3]u8 = undefined; // buf is of size k = 3
    var l = CoLex.init(&buf, 5); // n = 5

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
