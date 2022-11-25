const std = @import("std");

const test_data = @import("test_data.zig").data;
const binomial = @import("binomial.zig").binomial;
const iterative = @import("sum_of_products.zig").Iterative(f64).sumOfProducts;
const recursive = @import("sum_of_products.zig").Recursive(f64).sumOfProducts;

// zig run -OReleaseFast bencmark.zig
pub fn main() !void {
    const runs = 2246;
    try bench("iterative", runs, iterative);
    try bench("recursive", runs, recursive);
}

pub fn bench(name: []const u8, runs: usize, comptime handler: fn ([]const f64, usize) f64) !void {
    const start = std.time.nanoTimestamp();

    var rns = runs;
    while (rns > 0) : (rns -= 1) {
        for (test_data) |d| {
            const p = handler(d.prices, d.r);
            const w = p * d.stake / @intToFloat(f64, binomial(d.r, d.prices.len));
            try std.testing.expect(@fabs(w - d.winning) < 0.1);
        }
    }

    const duration = std.time.nanoTimestamp() - start;
    const nsop = @intCast(u64, duration) / @intCast(u64, runs);
    std.debug.print("{s} duration: {d} {d} ns/op\n", .{ name, duration, nsop });
}
