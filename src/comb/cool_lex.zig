const std = @import("std");
const assert = std.debug.assert;

// Produces (n,k)-combinations in cool-lex order.
// Implements the cool-lex algorithm to generate (n,k)-combinations.
// References:
//   fxtbook(https://www.jjj.de/fxt/fxtbook.pdf) Chapter 6.3
//   https://www.sciencedirect.com/science/article/pii/S0012365X07009570#aep-figure-id48
//   https://news.ycombinator.com/item?id=33716358
//   https://gist.github.com/m1el/6016b53ff20ae08712436a4b073820f2#file-bit_permutations-rs-L13
pub const CoolLex = struct {
    a: []u1, // working array
    x: usize,
    y: usize,
    m: usize,
    n: u8,
    k: u8,

    const Self = @This();

    // Provide slice of n elements.
    // To get all combinations r of n elements.
    pub fn init(a: []u1, k: u8) Self {
        const n = @intCast(u8, a.len);
        assert(n > 0 and k > 0 and n >= k);

        var c = Self{
            .a = a,
            .x = k - 1,
            .y = k - 1,
            .n = n,
            .k = k,
            .m = n - 1, // max c.x
        };
        c.first();
        return c;
    }

    pub fn first(c: *Self) void {
        var i: u8 = 0;
        while (i < c.k) : (i += 1) {
            c.a[i] = 1;
        }
        while (i < c.n) : (i += 1) {
            c.a[i] = 0;
        }
    }

    pub fn next(c: *Self) bool {
        if (c.x == c.m) {
            return false;
        }

        c.a[c.x] = 0;
        c.a[c.y] = 1;
        c.x += 1;
        c.y += 1;
        if (c.a[c.x] == 0) {
            c.a[c.x] = 1;
            c.a[0] = 0;
            if (c.y > 1) c.x = 1;
            c.y = 0;
        }
        return true;
    }
};

test "CoolLex show" {
    if (SKIP_SHOW_TESTS) return error.SkipZigTest;

    std.debug.print("\n", .{});
    var b = [_]u8{0} ** 5;
    var cl = CoolLex.init(&b, 3);
    while (cl.next()) |c| {
        std.debug.print("{d}\n", .{c});
    }
}

const test_data_5_3 = [10][5]u1{
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

test "CoolLex" {
    var a: [5]u1 = undefined;
    var cl = CoolLex.init(&a, 3);

    // visit first combination
    try std.testing.expectEqualSlices(u1, &test_data_5_3[0], &a);

    var j: usize = 1;
    while (cl.next()) : (j += 1) {
        // call next and then visit another combination
        try std.testing.expectEqualSlices(u1, &test_data_5_3[j], &a);
    }
    // next returns false
    try std.testing.expectEqual(cl.next(), false);
    // rewind to the start
    cl.first();
    try std.testing.expectEqualSlices(u1, &test_data_5_3[0], &a);
}

const SKIP_SHOW_TESTS = true;

pub const CoolLexBinaryString = struct {
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

const expectEqual = std.testing.expectEqual;

test "CoolLexBinaryString" {
    var cl = CoolLexBinaryString.init(5, 3);
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

test "CoolLexBinaryString show" {
    if (SKIP_SHOW_TESTS) return error.SkipZigTest;

    std.debug.print("\n", .{});
    var cl = CoolLexBinaryString.init(5, 3);
    while (cl.next()) |c| {
        std.debug.print("{b:0>5}\n", .{c});
    }
}
