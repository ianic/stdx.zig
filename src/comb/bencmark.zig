const std = @import("std");

const test_data = @import("test_data.zig").data;
const binomial = @import("binomial.zig").binomial;
const iterative = @import("sum_of_products.zig").Iterative(f64).sumOfProducts;
const recursive = @import("sum_of_products.zig").Recursive(f64).sumOfProducts;

// zig run -OReleaseFast bencmark.zig
pub fn main() !void {
    try bench("CoolLex", 1, coolLex);
    try bench("CoolLexSlice", 1, coolLexSlice);

    // const runs = 2246;
    // try bench("sumOfProducts-recursive", runs, sumOfProductsRecursive);
    // try bench("sumOfProducts-iterative", runs, sumOfProductsIterative);
}

pub fn sumOfProductsIterative() !void {
    for (test_data) |d| {
        const p = iterative(d.prices, d.r);
        const w = p * d.stake / @intToFloat(f64, binomial(d.r, d.prices.len));
        try std.testing.expect(@fabs(w - d.winning) < 0.1);
    }
}

pub fn sumOfProductsRecursive() !void {
    for (test_data) |d| {
        const p = recursive(d.prices, d.r);
        const w = p * d.stake / @intToFloat(f64, binomial(d.r, d.prices.len));
        try std.testing.expect(@fabs(w - d.winning) < 0.1);
    }
}

const CoolLex = @import("coll_lex.zig").CoolLex;
const CoolLexSlice = @import("coll_lex.zig").CoolLexSlice;

pub fn coolLex() !void {
    var cnt: usize = 0;
    var cl = CoolLex.init(20, 32);
    while (cl.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(binomial(20, 32), cnt);
    std.debug.print("ct = {d}\n", .{cnt});
}

pub fn coolLexSlice() !void {
    var cnt: usize = 0;
    var a = [_]usize{0} ** 32;

    var cl = CoolLexSlice.init(20, &a);
    while (cl.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(binomial(20, 32), cnt);
    std.debug.print("ct = {d}\n", .{cnt});
}

pub fn bench(name: []const u8, runs: usize, comptime handler: fn () anyerror!void) !void {
    const start = std.time.nanoTimestamp();

    var rns = runs;
    while (rns > 0) : (rns -= 1) {
        try handler();
    }

    const duration = std.time.nanoTimestamp() - start;
    const nsop = @intCast(u64, duration) / @intCast(u64, runs);
    std.debug.print("{s} duration: {d}ns {d}s {d} ns/op\n", .{
        name,
        duration,
        @intToFloat(f64, duration) / @intToFloat(f64, std.time.ns_per_s),
        nsop,
    });
}
