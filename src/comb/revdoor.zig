const std = @import("std");
const iterator = @import("iterator.zig");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

// This is zig implementation of fxt/src/comb/combination-revdoor.h from fxtbook.
// fxtbook quotes:
//   // A very efficient (revolving door) algorithm to generate the
//   // sets for the Gray code is given comb in/combination-revdoor.h
//   // Combinations (n choose k) in minimal-change order.
//   // "Revolving door" algorithm following Knuth.
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
            if (s.increase()) return true;
        }

        while (true) {
            // try to decrease
            if (s.j == s.k) return false;
            if (s.decrease()) return true;
            // try to increase
            if (s.j == s.k) return false;
            if (s.increase()) return true;
        }
    }

    fn decrease(s: *Self) bool {
        if (s.x[s.j] > s.j) {
            s.x[s.j] = s.x[s.j - 1];
            s.x[s.j - 1] = s.j - 1;
            return true;
        }
        s.j += 1;
        return false;
    }

    fn increase(s: *Self) bool {
        var x = s.x[s.j] + 1;
        var y: u8 = s.x[s.j + 1]; // can use sentinel
        if (x < y) {
            s.x[s.j - 1] = x - 1;
            s.x[s.j] = x;
            return true;
        }
        s.j += 1;
        return false;
    }

    const Iterator = iterator.Iterator(RevDoor, []u8);

    pub fn iter(s: *Self) Iterator {
        return Iterator{ .alg = s, .is_first = s.x[s.k - 1] == s.k - 1 };
    }
};

test "*/5 RevDoor" {
    var buf: [test_data_n + 1]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = RevDoor.init(test_data_n, k, &buf);
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

test "*/5 RevDoor iterator interface" {
    var buf: [test_data_n + 3]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = RevDoor.init(test_data_n, k, &buf);
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
const test_data_5 = [_][5]u8{
    [_]u8{ 0, 0xff, 0xff, 0xff, 0xff },
	[_]u8{ 1, 0xff, 0xff, 0xff, 0xff },
	[_]u8{ 2, 0xff, 0xff, 0xff, 0xff },
	[_]u8{ 3, 0xff, 0xff, 0xff, 0xff },
	[_]u8{ 4, 0xff, 0xff, 0xff, 0xff },

	[_]u8{ 0, 1, 0xff, 0xff, 0xff },
	[_]u8{ 1, 2, 0xff, 0xff, 0xff },
	[_]u8{ 0, 2, 0xff, 0xff, 0xff },
	[_]u8{ 2, 3, 0xff, 0xff, 0xff },
	[_]u8{ 1, 3, 0xff, 0xff, 0xff },
	[_]u8{ 0, 3, 0xff, 0xff, 0xff },
	[_]u8{ 3, 4, 0xff, 0xff, 0xff },
	[_]u8{ 2, 4, 0xff, 0xff, 0xff },
	[_]u8{ 1, 4, 0xff, 0xff, 0xff },
	[_]u8{ 0, 4, 0xff, 0xff, 0xff },

	[_]u8{ 0, 1, 2, 0xff, 0xff },
	[_]u8{ 0, 2, 3, 0xff, 0xff },
	[_]u8{ 1, 2, 3, 0xff, 0xff },
	[_]u8{ 0, 1, 3, 0xff, 0xff },
	[_]u8{ 0, 3, 4, 0xff, 0xff },
	[_]u8{ 1, 3, 4, 0xff, 0xff },
	[_]u8{ 2, 3, 4, 0xff, 0xff },
	[_]u8{ 0, 2, 4, 0xff, 0xff },
	[_]u8{ 1, 2, 4, 0xff, 0xff },
	[_]u8{ 0, 1, 4, 0xff, 0xff },

	[_]u8{ 0, 1, 2, 3, 0xff },
	[_]u8{ 0, 1, 3, 4, 0xff },
	[_]u8{ 1, 2, 3, 4, 0xff },
	[_]u8{ 0, 2, 3, 4, 0xff },
	[_]u8{ 0, 1, 2, 4, 0xff },

	[_]u8{ 0, 1, 2, 3, 4 },
};

