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
    limit_mask: usize,
    current: usize,

    const one = @as(usize, 1);
    const Self = @This();

    // Init for r of n combinations;
    // r items from the set of size n
    pub fn init(r: u6, n: u6) Self {
        assert(n > 0 and r > 0 and n >= r);
        return .{
            .limit_mask = one << n,
            .current = (one << r) - 1,
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

test "CoolLex" {
    var cl = CoolLex.init(3, 5);
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

test "CoolLex show" {
    if (SKIP_SHOW_TESTS) return error.SkipZigTest;

    std.debug.print("\n", .{});
    var cl = CoolLex.init(3, 5);
    while (cl.next()) |c| {
        std.debug.print("{b:0>5}\n", .{c});
    }
}

pub const CoolLexSlice = struct {
    b: []usize,
    x: usize,
    y: usize,
    n: usize,

    const Self = @This();

    // Provide slice of n elements.
    // To get all combinations r of n elements.
    pub fn init(r: u6, b: []usize) Self {
        const n = b.len;
        assert(n > 0 and r > 0 and n >= r);

        var i: usize = 0;
        while (i < r) : (i += 1) {
            b[i] = 1;
        }
        while (i < n) : (i += 1) {
            b[i] = 0;
        }

        return .{
            .b = b,
            .x = 0, // using 0 to signal first iterations, should be init to r-1 after first visit, it is never zero again
            .y = r - 1,
            .n = n,
        };
    }

    pub fn next(c: *Self) ?[]usize {
        if (c.x == 0) { // first iteration
            c.x = c.y; // init x
            return c.b;
        }
        if (c.x < c.n - 1) { // all other iterations
            c.findNext();
            return c.b;
        }
        return null;
    }

    fn findNext(c: *Self) void {
        c.b[c.x] = 0;
        c.b[c.y] = 1;
        c.x += 1;
        c.y += 1;
        if (c.b[c.x] == 0) {
            c.b[c.x] = 1;
            c.b[0] = 0;
            if (c.y > 1) c.x = 1;
            c.y = 0;
        }
    }
};

test "CoolLexSlice show" {
    if (SKIP_SHOW_TESTS) return error.SkipZigTest;

    std.debug.print("\n", .{});
    var b = [_]usize{0} ** 5;
    var cl = CoolLexSlice.init(3, &b);
    while (cl.next()) |c| {
        std.debug.print("{d}\n", .{c});
    }
}

test "CoolLexSlice" {
    var b = [_]usize{0} ** 5;
    var cl = CoolLexSlice.init(3, &b);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 1, 1, 0, 0 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 0, 1, 1, 1, 0 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 0, 1, 1, 0 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 1, 0, 1, 0 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 0, 1, 1, 0, 1 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 0, 1, 0, 1 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 0, 1, 0, 1, 1 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 0, 0, 1, 1, 1 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 0, 0, 1, 1 }, cl.next().?);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 1, 0, 0, 1 }, cl.next().?);
    try std.testing.expectEqual(cl.next(), null);
    try std.testing.expectEqual(cl.next(), null);
}

const SKIP_SHOW_TESTS = true;
