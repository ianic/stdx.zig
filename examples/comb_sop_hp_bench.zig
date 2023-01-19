const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;
const expect = std.testing.expect;

const test_data = @import("../src/comb/test_data.zig").data;

fn readArg(comptime T: anytype, pos: usize, default: T) T {
    const argv = std.os.argv;
    if (pos >= argv.len) return default;
    const arg = argv[pos];
    return std.fmt.parseUnsigned(T, arg[0..std.mem.len(arg)], 10) catch default;
}

pub fn main() !void {
    const alg = readArg(usize, 1, 0);
    const runs = readArg(usize, 2, 100);

    var r: usize = 0;
    while (r < runs) : (r += 1) {
        switch (alg) {
            1 => try iterative(),
            2 => try recursive(),
            3 => try naive(),
            else => unreachable,
        }
    }
}

fn iterative() !void {
    for (test_data) |d| {
        const p = comb.sumOfProducts(f64, d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, comb.binomial(d.prices.len, d.k));
        try expect(@fabs(w - d.winning) < 0.1);
    }
}

fn recursive() !void {
    for (test_data) |d| {
        const p = comb.SumOfProducts(f64).recursive(d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, comb.binomial(d.prices.len, d.k));
        try expect(@fabs(w - d.winning) < 0.1);
    }
}

fn naiveCalc(items: []const f64, k: u8) f64 {
    var buf: [21]u8 = undefined;
    var alg = comb.CoLex.init(@intCast(u8, items.len), k, &buf);
    var hasMore = true;

    var sum: f64 = 0;
    while (hasMore) : (hasMore = alg.more()) {
        var prod: f64 = 1;
        for (alg.current()) |idx|
            prod *= items[idx];
        sum += prod;
    }
    return sum;
}

fn naive() !void {
    for (test_data) |d| {
        const p = naiveCalc(d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, comb.binomial(d.prices.len, d.k));
        try expect(@fabs(w - d.winning) < 0.1);
    }
}
