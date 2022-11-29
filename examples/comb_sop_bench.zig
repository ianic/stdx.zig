const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;

const test_data = @import("../src/comb/test_data.zig").data;

pub fn main() !void {
    const runs = 2246;
    std.debug.print("sum of products\n", .{});
    try stdx.bench("recursive", runs, sumOfProductsRecursive);
    try stdx.bench("iterative", runs, sumOfProductsIterative);
}

pub fn sumOfProductsIterative() !void {
    for (test_data) |d| {
        const p = comb.SumOfProducts(f64).iterative(d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, comb.binomial(d.prices.len, d.k));
        try std.testing.expect(@fabs(w - d.winning) < 0.1);
    }
}

pub fn sumOfProductsRecursive() !void {
    for (test_data) |d| {
        const p = comb.SumOfProducts(f64).recursive(d.prices, d.k);
        const w = p * d.stake / @intToFloat(f64, comb.binomial(d.prices.len, d.k));
        try std.testing.expect(@fabs(w - d.winning) < 0.1);
    }
}
