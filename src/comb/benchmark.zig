const std = @import("std");

const comb = @import("../comb.zig");

const test_data = @import("test_data.zig").data;
const binomial = @import("binomial.zig").binomial;
const iterative = @import("sum_of_products.zig").Iterative(f64).sumOfProducts;
const recursive = @import("sum_of_products.zig").Recursive(f64).sumOfProducts;

// zig run -OReleaseFast bencmark.zig
pub fn main() !void {
    var i: usize = 0;
    while (i < 10) : (i += 1) {
        try bench("Lex", 1, lex);
        try bench("CoLex", 1, colex);
    }

    // try bench("CoolLex", 1, coolLex);
    // try bench("CoolLexSlice", 1, coolLexSlice);

    // const runs = 2246;
    // try bench("sumOfProducts-recursive", runs, sumOfProductsRecursive);
    // try bench("sumOfProducts-iterative", runs, sumOfProductsIterative);
}

pub fn sumOfProductsIterative() !void {
    for (test_data) |d| {
        const p = iterative(d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, binomial(d.prices.len, d.k));
        try std.testing.expect(@fabs(w - d.winning) < 0.1);
    }
}

pub fn sumOfProductsRecursive() !void {
    for (test_data) |d| {
        const p = recursive(d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, binomial(d.prices.len, d.k));
        try std.testing.expect(@fabs(w - d.winning) < 0.1);
    }
}

const K = 20;
const N = 32;
const expectedCnt = binomial(N, K);

const CoolLex = @import("cool_lex.zig").CoolLex;
const CoolLexSlice = @import("cool_lex.zig").CoolLexSlice;
const Lex = @import("lex.zig").Lex;
const CoLex = @import("colex.zig").CoLex;

pub fn lex() !void {
    var a: [K]u8 = undefined;
    var l = Lex.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colex() !void {
    var a: [K]u8 = undefined;
    var l = CoLex.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn coolLex() !void {
    var cnt: usize = 0;
    var cl = CoolLex.init(N, K);
    while (cl.next()) |a| {
        _ = a; // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn coolLexSlice() !void {
    var cnt: usize = 0;
    var a = [_]usize{0} ** N;
    var cl = CoolLexSlice.init(&a, K);
    while (cl.next()) |_| {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn bench(name: []const u8, runs: usize, comptime handler: fn () anyerror!void) !void {
    const start = std.time.nanoTimestamp();

    var rns = runs;
    while (rns > 0) : (rns -= 1) {
        try handler();
    }

    const duration = std.time.nanoTimestamp() - start;
    const nsop = @intCast(u64, duration) / @intCast(u64, runs);
    std.debug.print("{s:<25} duration: {d}ns {d:.4}s {d} ns/op\n", .{
        name,
        duration,
        @intToFloat(f64, duration) / @intToFloat(f64, std.time.ns_per_s),
        nsop,
    });
}
