const std = @import("std");
const assert = std.debug.assert;

pub const RevDoor = struct {
    n: u8,
    k: u8,
    j: u8,
    x: []u8,

    const Self = @This();

    pub fn init(x: []u8, n: u8) Self {
        const k: u8 = @intCast(u8, x.len);
        assert(n >= k and k > 0);

        var s = Self{
            .n = n,
            .k = k,
            .x = x,
            .j = 0,
        };
        s.first();
        return s;
    }

    pub fn first(s: *Self) void {
        var i: u8 = 0;
        while (i < s.k) : (i += 1) s.x[i] = i;
    }

    pub fn current(s: *Self) []u8 {
        return s.x[0..s.k];
    }

    pub fn more(s: *Self) bool {
        s.j = 1;

        // easy case?
        if (s.k & 1 == 1) { // odd k (try to increase)
            var x = s.x[0] + 1;
            if (x < s.x[1]) {
                s.x[0] = x;
                return true;
            }
        } else { // even k (try to decrease)
            var x = s.x[0];
            if (x != 0) {
                s.x[0] = x - 1;
                return true;
            }
            if (s.increase()) |r| return r;
        }

        while (true) {
            if (s.j == s.k) return false;
            if (s.decrease()) |r| return r;
            if (s.j == s.k) return false;
            if (s.increase()) |r| return r;
        }
    }

    fn decrease(s: *Self) ?bool {
        if (s.x[s.j] > s.j) {
            s.x[s.j] = s.x[s.j - 1];
            s.x[s.j - 1] = s.j - 1;
            return true;
        }
        s.j += 1;
        return null;
    }

    fn increase(s: *Self) ?bool {
        var x = s.x[s.j] + 1;
        var y: u8 = if (s.j == s.k - 1) s.n else s.x[s.j + 1]; // instead of sentinel at s.x[s.k] = n
        if (x < y) {
            s.x[s.j - 1] = x - 1;
            s.x[s.j] = x;
            return true;
        }
        s.j += 1;
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
    while (l.more()) : (j += 1) {
        try std.testing.expectEqualSlices(u8, &test_data_5_3[j], &a); // all other
    }
    try std.testing.expectEqual(l.more(), false);
}

const test_data_5_2 = [10][2]u8{
    [_]u8{ 0, 1 },
    [_]u8{ 1, 2 },
    [_]u8{ 0, 2 },
    [_]u8{ 2, 3 },
    [_]u8{ 1, 3 },
    [_]u8{ 0, 3 },
    [_]u8{ 3, 4 },
    [_]u8{ 2, 4 },
    [_]u8{ 1, 4 },
    [_]u8{ 0, 4 },
};

test "2/5" {
    var a: [2]u8 = undefined;
    var l = RevDoor.init(&a, 5);

    try std.testing.expectEqualSlices(u8, &test_data_5_2[0], &a); // visit first combination
    var j: u8 = 1;
    while (l.more()) : (j += 1) {
        try std.testing.expectEqualSlices(u8, &test_data_5_2[j], &a); // all other
    }
    try std.testing.expectEqual(l.more(), false);
}
