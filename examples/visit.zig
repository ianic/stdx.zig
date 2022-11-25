const std = @import("std");
const assert = std.debug.assert;

// Produces (n,k)-combinations in cool-lex order.
// Implements the cool-lex algorithm to generate (n,k)-combinations.
// References:
//   https://www.sciencedirect.com/science/article/pii/S0012365X07009570#aep-figure-id48
//   https://news.ycombinator.com/item?id=33716358
//   https://gist.github.com/m1el/6016b53ff20ae08712436a4b073820f2#file-bit_permutations-rs-L13
const CoolLex = struct {
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
    pub fn next(self: *Self) ?usize {
        const ret = self.current;
        if (ret & self.limit_mask == 0) {
            self.findNext();
            return ret;
        }
        return null;
    }

    fn findNext(self: *Self) void {
        const lowest_zero = self.current & (self.current + 1);
        const suffix_mask = lowest_zero ^ (lowest_zero -% 1);
        const suffix = suffix_mask & self.current;
        const next_bit_mask = suffix_mask +% 1;
        const next_bit_m1 = (next_bit_mask & self.current) -| 1;
        self.current = self.current + suffix - next_bit_m1;
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
    // used for visualization
    if (true) return error.SkipZigTest;

    std.debug.print("\n", .{});

    var cl = CoolLex.init(3, 5);
    while (cl.next()) |c| {
        std.debug.print("{b:0>5}\n", .{c});
    }
}

fn coolLex(r: u6, n: u6) void {
    const zeros = n - r;
    const ones = r;
    const limit_mask = @as(usize, 1) << (zeros + ones);

    var current = (@as(usize, 1) << ones) - 1;
    while (limit_mask & current == 0) {
        std.debug.print("{b:0>5}\n", .{current});
        const lowest_zero = current & (current + 1);
        const suffix_mask = lowest_zero ^ (lowest_zero -% 1);
        const suffix = suffix_mask & current;
        const next_bit_mask = suffix_mask +% 1;
        const next_bit_m1 = (next_bit_mask & current) -| 1;
        current = current + suffix - next_bit_m1;
    }
    std.debug.print("current at end {b} {d} {b}", .{ current, current, limit_mask });
}

// test {
//     coolLex(3, 5);
// }
