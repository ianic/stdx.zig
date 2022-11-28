const std = @import("std");

const test_data = @import("test_data.zig").data;
const binomial = @import("binomial.zig").binomial;
const iterative = @import("sum_of_products.zig").Iterative(f64).sumOfProducts;
const recursive = @import("sum_of_products.zig").Recursive(f64).sumOfProducts;

// zig run -OReleaseFast bencmark.zig
pub fn main() !void {
    // try bench("Lex", 1, lex);
    // try bench("Lex hasNext api", 1, lexHasNext);

    try bench("CoLex next", 1, colex);
    try bench("CoLex iter", 1, colexIter);
    try bench("CoLex hasNext api", 1, colexHasNext);
    try bench("CoLex Next2 api", 1, colexNext);

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
    var cnt: usize = 0;
    var a = [_]usize{0} ** K;
    var l = Lex.init(&a, N);
    while (l.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn lexHasNext() !void {
    var a: [K]usize = undefined;
    var l = Lex.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.hasNext()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colexNext() !void {
    var a: [K]usize = undefined;
    var l = CoLex.init(&a, N);
    var cnt: usize = 0;
    while (l.comb2()) |c| : (l.next2()) {
        _ = c;
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colex() !void {
    var cnt: usize = 0;
    var a: [K]usize = undefined;

    var l = CoLex.init(&a, N);
    while (l.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colexIter() !void {
    var cnt: usize = 0;
    var a: [K]usize = undefined;
    var l = CoLex.init(&a, N);
    var i = l.iter();
    while (i.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colexHasNext() !void {
    var a = [_]usize{0} ** K;
    var l = CoLex.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.hasNext()) {
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
    std.debug.print("{s:<25} duration: {d}ns {d}s {d} ns/op\n", .{
        name,
        duration,
        @intToFloat(f64, duration) / @intToFloat(f64, std.time.ns_per_s),
        nsop,
    });
}
