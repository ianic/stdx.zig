const std = @import("std");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

pub const RevDoor = struct {
    n: u8,
    k: u8,
    j: u8,
    x: []u8,

    const Self = @This();

    pub fn init(n: u8, k: u8, buf: []u8) Self {
        // Uses 1 sentinel so buf.len needs to be at least k + 1!
        assert(n >= k and k > 0 and buf.len >= k + 1);

        var s = Self{
            .n = n,
            .k = k,
            .x = buf[0 .. k + 1],
            .j = 0,
        };
        s.first();
        return s;
    }

    pub fn first(s: *Self) void {
        var i: u8 = 0;
        while (i < s.k) : (i += 1) s.x[i] = i;
        s.x[s.k] = s.n; // set sentinel
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
        //var y: u8 = if (s.j == s.k - 1) s.n else s.x[s.j + 1]; // instead of sentinel at s.x[s.k] = n
        var y: u8 = s.x[s.j + 1]; // can use sentinel
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
    var buf: [4]u8 = undefined;
    var alg = RevDoor.init(5, 3, &buf);

    var j: u8 = 0;
    var hasMore = true;
    while (hasMore) : ({
        hasMore = alg.more();
        j += 1;
    }) {
        try std.testing.expectEqualSlices(u8, &test_data_5_3[j], alg.current());
    }
    try std.testing.expectEqual(alg.more(), false);
    try expectEqual(j, test_data_5_3.len);
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
    var buf: [3]u8 = undefined;
    var alg = RevDoor.init(5, 2, &buf);

    var j: u8 = 0;
    var hasMore = true;
    while (hasMore) : ({
        hasMore = alg.more();
        j += 1;
    }) {
        try std.testing.expectEqualSlices(u8, &test_data_5_2[j], alg.current());
    }
    try std.testing.expectEqual(alg.more(), false);
    try expectEqual(j, test_data_5_2.len);
}

test "print all x/5" {
    if (true) return error.SkipZigTest;

    var buf: [6]u8 = undefined;
    const n = 5;

    std.debug.print("\n", .{});

    var k: u8 = 1;
    while (k <= n) : (k += 1) {
        std.debug.print("{d} / {d}\n", .{ k, n });
        var alg = RevDoor.init(n, k, &buf);

        var hasMore = true;
        while (hasMore) : (hasMore = alg.more()) {
            std.debug.print("\t{d}\n", .{alg.current()});
        }
    }
}
