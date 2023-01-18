const std = @import("std");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

// Produces (n,k)-combinations in cool-lex order.
// Implements the cool-lex algorithm to generate (n,k)-combinations.
// References:
//   fxtbook(https://www.jjj.de/fxt/fxtbook.pdf) Chapter 6.3
//   https://www.sciencedirect.com/science/article/pii/S0012365X07009570#aep-figure-id48
//   https://news.ycombinator.com/item?id=33716358
//   https://gist.github.com/m1el/6016b53ff20ae08712436a4b073820f2#file-bit_permutations-rs-L13
//
// Different representations used here:
//   bit string  0b00111                    - number of n bits uN
//   bit array   [5]u1{ 1, 1, 1, 0, 0 },    - array of n u1 elements
//   indices     [3]{0, 1, 2}               - array of k elements
// Bit string is binary number where 1 at some position means that element at that position is selected.
// Bit array is bit string represented as array
// Indices holds indexes of the selected elements.
pub const CoolLex = struct {
    a: []u1, // working array
    x: usize,
    y: usize,
    m: usize,
    n: u8,
    k: u8,

    const Self = @This();

    // Provide slice of n elements.
    // To get all combinations k of n elements.
    pub fn init(n: u8, k: u8, buf: []u1) Self {
        assert(n > 0 and k > 0 and n >= k and buf.len >= n);

        var s = Self{
            .a = buf[0..n],
            .x = k - 1,
            .y = k - 1,
            .n = n,
            .k = k,
            .m = n - 1, // max c.x
        };
        s.first();
        return s;
    }

    pub fn first(s: *Self) void {
        var i: u8 = 0;
        while (i < s.k) : (i += 1) {
            s.a[i] = 1;
        }
        while (i < s.n) : (i += 1) {
            s.a[i] = 0;
        }
        s.x = s.k - 1;
        s.y = s.k - 1;
    }

    pub fn current(s: *Self) []u1 {
        return s.a;
    }

    pub fn more(s: *Self) bool {
        if (s.x == s.m)
            return false;

        s.a[s.x] = 0;
        s.a[s.y] = 1;
        s.x += 1;
        s.y += 1;
        if (s.a[s.x] == 0) {
            s.a[s.x] = 1;
            s.a[0] = 0;
            if (s.y > 1) s.x = 1;
            s.y = 0;
        }
        return true;
    }

    const Iterator = @import("iterator.zig").Iterator(CoolLex, []u1);

    pub fn iter(s: *Self) Iterator {
        return Iterator{ .alg = s, .is_first = s.x == s.y };
    }
};

test "*/5 CoolLex" {
    var buf: [test_data_n]u1 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = CoolLex.init(test_data_n, k, &buf);
        var hasMore = true;
        while (hasMore) : ({
            hasMore = alg.more();
            i += 1;
        }) {
            const expected = &test_data_5[i];
            try expectEqualSlices(u1, expected, alg.current());
        }
    }
    try expectEqual(i, 31); // we visited all of them
}

test "*/5 CoolLex iterator interface" {
    var buf: [test_data_n]u1 = undefined;
    var i: usize = 0;
    var k: u8 = 1;
    while (k <= test_data_n) : (k += 1) {
        var alg = CoolLex.init(test_data_n, k, &buf);
        var iter = alg.iter();

        while (iter.next()) |current| {
            const expected = &test_data_5[i];
            try expectEqualSlices(u1, expected, current);
            i += 1;
        }
    }
    try expectEqual(i, 31); // we visited all of them
}

const test_data_n = 5;
const test_data_5 = [_][5]u1{
    [_]u1{ 1, 0, 0, 0, 0 },
    [_]u1{ 0, 1, 0, 0, 0 },
    [_]u1{ 0, 0, 1, 0, 0 },
    [_]u1{ 0, 0, 0, 1, 0 },
    [_]u1{ 0, 0, 0, 0, 1 },

    [_]u1{ 1, 1, 0, 0, 0 },
    [_]u1{ 0, 1, 1, 0, 0 },
    [_]u1{ 1, 0, 1, 0, 0 },
    [_]u1{ 0, 1, 0, 1, 0 },
    [_]u1{ 0, 0, 1, 1, 0 },
    [_]u1{ 1, 0, 0, 1, 0 },
    [_]u1{ 0, 1, 0, 0, 1 },
    [_]u1{ 0, 0, 1, 0, 1 },
    [_]u1{ 0, 0, 0, 1, 1 },
    [_]u1{ 1, 0, 0, 0, 1 },

    [_]u1{ 1, 1, 1, 0, 0 },
    [_]u1{ 0, 1, 1, 1, 0 },
    [_]u1{ 1, 0, 1, 1, 0 },
    [_]u1{ 1, 1, 0, 1, 0 },
    [_]u1{ 0, 1, 1, 0, 1 },
    [_]u1{ 1, 0, 1, 0, 1 },
    [_]u1{ 0, 1, 0, 1, 1 },
    [_]u1{ 0, 0, 1, 1, 1 },
    [_]u1{ 1, 0, 0, 1, 1 },
    [_]u1{ 1, 1, 0, 0, 1 },

    [_]u1{ 1, 1, 1, 1, 0 },
    [_]u1{ 0, 1, 1, 1, 1 },
    [_]u1{ 1, 0, 1, 1, 1 },
    [_]u1{ 1, 1, 0, 1, 1 },
    [_]u1{ 1, 1, 1, 0, 1 },

    [_]u1{ 1, 1, 1, 1, 1 },
};

pub const CoolLexBitStr = struct {
    limit_mask: usize,
    current: usize,

    const one = @as(usize, 1);
    const Self = @This();

    // Init for r of n combinations;
    // r items from the set of size n
    pub fn init(n: u6, k: u6) Self {
        assert(n > 0 and k > 0 and n >= k);
        return .{
            .limit_mask = one << n,
            .current = (one << k) - 1,
        };
    }

    // Returns combination as binary string.
    // Null when there is no more combinations.
    pub fn next(c: *Self) ?usize {
        if (c.current & c.limit_mask == 0) {
            defer c.findNext();
            return c.current;
        }
        return null;
    }

    fn findNext(c: *Self) void {
        const lowest_zero = c.current & (c.current + 1);
        const suffix_mask = lowest_zero ^ (lowest_zero -% 1);
        const suffix = suffix_mask & c.current;
        const next_bit_mask = suffix_mask +% 1;
        const next_bit_m1 = (next_bit_mask & c.current) -| 1;
        c.current = c.current + suffix - next_bit_m1;
    }
};

test "CoolLexBitStr" {
    var cl = CoolLexBitStr.init(5, 3);
    try expectEqual(cl.next(), 0b00111);
    try expectEqual(cl.next(), 0b01110);
    try expectEqual(cl.next(), 0b01101);
    try expectEqual(cl.next(), 0b01011);
    try expectEqual(cl.next(), 0b10110);
    try expectEqual(cl.next(), 0b10101);
    try expectEqual(cl.next(), 0b11010);
    try expectEqual(cl.next(), 0b11100);
    try expectEqual(cl.next(), 0b11001);
    try expectEqual(cl.next(), 0b10011);
    try expectEqual(cl.next(), null);
    try expectEqual(cl.next(), null);
}

pub fn bitArrayToIndices(ba: []const u1, x: []u8) void {
    var j: usize = 0;
    var i: u8 = 0;
    while (i < ba.len) : (i += 1) {
        if (ba[i] == 1) {
            x[j] = i;
            j += 1;
            if (j == x.len) {
                return;
            }
        }
    }
}

test "bitArrayToIndices" {
    const bit_array = [10][5]u1{
        [_]u1{ 1, 1, 1, 0, 0 },
        [_]u1{ 0, 1, 1, 1, 0 },
        [_]u1{ 1, 0, 1, 1, 0 },
        [_]u1{ 1, 1, 0, 1, 0 },
        [_]u1{ 0, 1, 1, 0, 1 },
        [_]u1{ 1, 0, 1, 0, 1 },
        [_]u1{ 0, 1, 0, 1, 1 },
        [_]u1{ 0, 0, 1, 1, 1 },
        [_]u1{ 1, 0, 0, 1, 1 },
        [_]u1{ 1, 1, 0, 0, 1 },
    };
    const indices = [10][3]u8{
        [_]u8{ 0, 1, 2 },
        [_]u8{ 1, 2, 3 },
        [_]u8{ 0, 2, 3 },
        [_]u8{ 0, 1, 3 },
        [_]u8{ 1, 2, 4 },
        [_]u8{ 0, 2, 4 },
        [_]u8{ 1, 3, 4 },
        [_]u8{ 2, 3, 4 },
        [_]u8{ 0, 3, 4 },
        [_]u8{ 0, 1, 4 },
    };
    var x: [3]u8 = undefined;

    for (bit_array) |ba, i| {
        bitArrayToIndices(&ba, &x);
        try std.testing.expectEqualSlices(u8, &indices[i], &x);
        //std.debug.print("{d}\n", .{ix});
    }
}
