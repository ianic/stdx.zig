const std = @import("std");
const iterator = @import("iterator.zig");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// in co-lexicographic order
pub const FxtCoLex = struct {
    n: u8,
    k: u8,
    x: []u8,

    const Self = @This();

    pub fn init(n: u8, k: u8, buf: []u8) Self {
        assert(k > 0 and n >= k and buf.len > k);

        var s = Self{
            .n = n,
            .k = k,
            .x = buf[0 .. k + 1], // uses one sentinel
        };
        s.first();
        return s;
    }

    pub fn first(s: *Self) void {
        var i: u8 = 0;
        while (i < s.k) : (i += 1) {
            s.x[i] = i;
        }
        s.x[s.k] = 0; // set sentinel
    }

    pub fn current(s: *Self) []u8 {
        return s.x[0..s.k];
    }

    pub fn more(s: *Self) bool {
        if (s.isLast())
            return false;
        s.move();
        return true;
    }

    fn isLast(s: *Self) bool {
        return s.x[0] == (s.n - s.k);
    }

    fn move(s: *Self) void {
        var i: u8 = 0;
        // until lowest rising edge:  attach block at low end
        while (s.x[i] + 1 == s.x[i + 1]) : (i += 1) {
            s.x[i] = i;
        }
        s.x[i] += 1; // move edge element up
    }

    const Iterator = iterator.Iterator(FxtCoLex, []u8);

    pub fn iter(s: *Self) Iterator {
        return Iterator{ .alg = s, .is_first = s.x[s.k - 1] == s.k - 1 };
    }
};

test "*/5 FxtCoLex" {
    var buf: [test_data_n + 3]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = FxtCoLex.init(test_data_n, k, &buf);
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

test "*/5 FxtCoLex iterator interface" {
    var buf: [test_data_n + 3]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = FxtCoLex.init(test_data_n, k, &buf);
        var iter = alg.iter();

        while (iter.next()) |current| {
            const expected = test_data_5[i][0..k];
            try expectEqualSlices(u8, expected, current);
            i += 1;
        }
    }
    try expectEqual(i, 31); // we visited all of them
}

pub const KnuthCoLex = struct {
    k: u8,
    n: u8,
    x: []u8,
    j: u8 = 0,

    const Self = @This();

    pub fn init(n: u8, k: u8, buf: []u8) Self {
        assert(n >= k and buf.len > k + 2);
        var s = Self{
            .n = n,
            .k = k,
            .x = buf[0 .. k + 3],
        };
        s.first();
        return s;
    }

    // Initialize x with first combination.
    fn first(s: *Self) void {
        s.x[0] = 0; // not used s.x is zero based

        var j: u8 = 1;
        while (j <= s.k) : (j += 1)
            s.x[j] = j - 1;

        // two sentinels at end
        s.x[s.k + 1] = s.n;
        s.x[s.k + 2] = 0;
        s.j = s.k;

        // algorithm, without this, assumes k < n
        // here we assure isLast to be true for that case so we don't use rest of the algorithm
        if (s.k == s.n) s.j += 1;
    }

    pub fn current(s: *Self) []u8 {
        return s.x[1 .. s.k + 1];
    }

    pub fn more(s: *Self) bool {
        if (s.isLast())
            return false;
        return s.move();
    }

    fn isLast(s: *Self) bool {
        return s.j > s.k;
    }

    fn move(s: *Self) bool {
        if (s.j > 0) {
            // increase
            s.x[s.j] = s.j;
            s.j -= 1;
            return true;
        }
        // easy case?
        if (s.x[1] + 1 < s.x[2]) {
            s.x[1] += 1;
            return true;
        }
        s.j = 2;
        var x: u8 = 0;
        // find j
        while (true) {
            s.x[s.j - 1] = s.j - 2;
            x = s.x[s.j] + 1;
            if (x != s.x[s.j + 1]) break;
            s.j += 1;
        }
        // done?
        if (s.j > s.k) return false;
        // increase
        s.x[s.j] = x;
        s.j -= 1;
        return true;
    }

    const Iterator = iterator.Iterator(KnuthCoLex, []u8);

    pub fn iter(s: *Self) Iterator {
        return Iterator{ .alg = s, .is_first = s.x[s.k] == s.k - 1 };
    }
};

test "3/5 KnuthCoLex" {
    var buf: [6]u8 = undefined;
    var alg = KnuthCoLex.init(5, 3, &buf);

    // raw interface
    var i: u8 = 15;
    var hasMore = true; // after init we have first combination in current
    while (hasMore) : (hasMore = alg.more()) { // loop with check at the end
        try expectEqualSlices(u8, test_data_5[i][0..3], alg.current());
        i += 1;
    }
    try expectEqual(i, 15 + 10); // we visited all of them
    try expectEqual(alg.more(), false); // all other calls to more returns false

    alg.first(); // rewind

    // iterator interface
    var iter = alg.iter();
    i = 15;
    while (iter.next()) |current| {
        try expectEqualSlices(u8, test_data_5[i][0..3], current);
        i += 1;
    }
    try expectEqual(i, 15 + 10);
}

test "*/5 KnuthCoLex" {
    var buf: [test_data_n + 3]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = KnuthCoLex.init(test_data_n, k, &buf);
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

test "*/5 KnuthCoLex iterator interface" {
    var buf: [test_data_n + 3]u8 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = KnuthCoLex.init(test_data_n, k, &buf);
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
    [_]u8{ 0, 2, 0xff, 0xff, 0xff },
    [_]u8{ 1, 2, 0xff, 0xff, 0xff },
    [_]u8{ 0, 3, 0xff, 0xff, 0xff },
    [_]u8{ 1, 3, 0xff, 0xff, 0xff },
    [_]u8{ 2, 3, 0xff, 0xff, 0xff },
    [_]u8{ 0, 4, 0xff, 0xff, 0xff },
    [_]u8{ 1, 4, 0xff, 0xff, 0xff },
    [_]u8{ 2, 4, 0xff, 0xff, 0xff },
    [_]u8{ 3, 4, 0xff, 0xff, 0xff },

    [_]u8{ 0, 1, 2, 0xff, 0xff },
    [_]u8{ 0, 1, 3, 0xff, 0xff },
    [_]u8{ 0, 2, 3, 0xff, 0xff },
    [_]u8{ 1, 2, 3, 0xff, 0xff },
    [_]u8{ 0, 1, 4, 0xff, 0xff },
    [_]u8{ 0, 2, 4, 0xff, 0xff },
    [_]u8{ 1, 2, 4, 0xff, 0xff },
    [_]u8{ 0, 3, 4, 0xff, 0xff },
    [_]u8{ 1, 3, 4, 0xff, 0xff },
    [_]u8{ 2, 3, 4, 0xff, 0xff },

    [_]u8{ 0, 1, 2, 3, 0xff },
    [_]u8{ 0, 1, 2, 4, 0xff },
    [_]u8{ 0, 1, 3, 4, 0xff },
    [_]u8{ 0, 2, 3, 4, 0xff },
    [_]u8{ 1, 2, 3, 4, 0xff },

    [_]u8{ 0, 1, 2, 3, 4 },
};

test "generate testdata" {
    if (true) return error.SkipZigTest;

    var buf: [16]u8 = undefined;
    const n = 5;
    var k: u8 = 1;
    std.debug.print("\n", .{});

    while (k <= n) : (k += 1) {
        var alg = KnuthCoLex.init(n, k, &buf);
        var hasMore = true;
        while (hasMore) : (hasMore = alg.more()) {
            var print_buf = [_]u8{0xff} ** 5;
            std.mem.copy(u8, &print_buf, alg.current());
            std.debug.print("\t[_]u8{d},\n", .{print_buf});
        }
    }
}
