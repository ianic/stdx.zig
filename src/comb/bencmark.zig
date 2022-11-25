const std = @import("std");

const max_len = 20;
const test_data = @import("test_data.zig").data;
const binomial = @import("binomial.zig").binomial;

pub fn main() !void {
    const start = std.time.nanoTimestamp();
    const runs: usize = 2246;
    var rns = runs;
    var sum: f64 = 0;
    while (rns > 0) : (rns -= 1) {
        for (test_data) |d| {
            const p = sumOfProducts(d.prices, d.r);
            const w = p * d.stake / @intToFloat(f64, binomial(d.r, d.prices.len));
            try std.testing.expect(@fabs(w - d.winning) < 0.1);
            sum += w;
        }
    }
    const duration = std.time.nanoTimestamp() - start;
    const nsop = @intCast(u64, duration) / @intCast(u64, runs);
    std.debug.print("duration: {d} {d} ns/op\n", .{ duration, nsop });
    std.debug.print("sum: {d}\n", .{sum});
}

pub fn sumOfProducts(items: []const f64, r: usize) f64 {
    return SOP(items, r);
}

const SOP = @import("sum_of_products.zig").SumOfProductsGen(f64).sum;
