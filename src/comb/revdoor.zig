const std = @import("std");
const assert = std.debug.assert;

pub const RevDoor = struct {
    n: u8,
    k: u8,
    j: u8,
    a: []u8,

    const Self = @This();

    pub fn init(a: []u8, n: u6) Self {
        const k: u8 = @intCast(u8, a.len);
        assert(n >= k);

        var c = Self{
            .n = n,
            .k = k,
            .a = a,
            .j = 0,
        };
        c.first();
        return c;
    }

    pub fn first(c: *Self) void {
        var i: u8 = 0;
        while (i < c.k) : (i += 1) c.a[i] = i;
    }

    pub fn next(c: *Self) bool {
        c.j = 1;

        // easy case?
        if (c.k & 1 == 1) { // odd k (try to increase)
            var x = c.a[0] + 1;
            if (x < c.a[1]) {
                c.a[0] = x;
                return true;
            }
        } else { // even k (try to decrease)
            var x = c.a[0];
            if (x != 0) {
                c.a[0] = x - 1;
                return true;
            }
            if (c.increase()) |r| return r;
        }

        while (true) {
            if (c.decrease()) |r| return r;
            if (c.j == c.k) return false;
            if (c.increase()) |r| return r;
            if (c.j == c.k) return false;
        }
    }

    fn decrease(c: *Self) ?bool {
        if (c.a[c.j] > c.j) {
            c.a[c.j] = c.a[c.j - 1];
            c.a[c.j - 1] = c.j - 1;
            return true;
        }
        c.j += 1;
        return null;
    }

    fn increase(c: *Self) ?bool {
        var x = c.a[c.j] + 1;
        var y: u8 = if (c.j == c.k - 1) c.n else c.a[c.j + 1]; // instead of sentinel at c.a[c.k] = n
        if (x < y) {
            c.a[c.j - 1] = x - 1;
            c.a[c.j] = x;
            return true;
        }
        c.j += 1;
        return null;
    }
};

const test_data_5_3 = [10][3]u8{
    [_]u8{ 0, 1, 2 },
    [_]u8{ 0, 2, 3 },
    [_]u8{ 1, 2, 3 },
    [_]u8{ 0, 1, 3 },
    [_]u8{ 0, 3, 4 },
    [_]u8{ 1, 3, 4 },
    [_]u8{ 2, 3, 4 },
    [_]u8{ 0, 2, 4 },
    [_]u8{ 1, 2, 4 },
    [_]u8{ 0, 1, 4 },
};

test "3/5" {
    var a: [3]u8 = undefined;
    var l = RevDoor.init(&a, 5);

    try std.testing.expectEqualSlices(u8, &test_data_5_3[0], &a); // visit first combination
    var j: u8 = 1;
    while (l.next()) : (j += 1) {
        try std.testing.expectEqualSlices(u8, &test_data_5_3[j], &a); // all other
    }
    try std.testing.expectEqual(l.next(), false);
}
