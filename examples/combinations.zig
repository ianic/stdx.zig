const std = @import("std");

// const testdata = [_]struct {
//     r: u6,
//     stake: f64,
//     winning: f64,
//     prices: []const f64,
// }{.{
//     .r = 9,
//     .stake = 9.5000,
//     .winning = 874.0096,
//     .prices = &[_]f64{ 1.35, 1.30, 2.10, 1.75, 1.75, 1.55, 1.70, 1.70, 1.75, 1.35, 2.05 },
// }};

const max_len = 20;
const test_data = @import("combinations_test_data.zig").data;

test "show testdata" {
    if (true) return error.SkipZigTest;

    var no: usize = 0;
    while (no < 1) : (no += 1) {
        for (test_data) |d| {

            //std.debug.print("{d}\n", .{d.prices});

            const r: u6 = d.r;
            const n: u6 = @intCast(u6, d.prices.len);

            var i: u64 = (@intCast(u64, 1) << r) - 1;
            var j = i << (n - r);

            var c: f64 = 0;
            var s: f64 = 0;

            while (i <= j) : (i += 1) {
                if (@popCount(i) == r) {
                    var b: u6 = 0;

                    var m1: f64 = 1;

                    while (b <= n) : (b += 1) {
                        if ((i & (@intCast(u64, 1) << b) != 0)) { // if b bit set in i
                            //a[b] = d.prices[b];
                            m1 *= d.prices[b];
                        } // else {
                        //     a[b] = 1;
                        // }
                    }

                    //const v: @Vector(max_len, f64) = a;
                    //const m = @reduce(.Mul, v);
                    s += m1;

                    //std.debug.print("a {d}", .{a});
                    //std.debug.print("i: {b}, popCount: {d}\n", .{ i, @popCount(i) });
                    c += 1;
                }
            }

            const w = s * d.stake / c;
            //std.debug.print("combinations: {d}, sum: {d}\n", .{ c, s / c * d.stake });
            try std.testing.expect(@fabs(w - d.winning) < 0.1);
            //std.debug.print("i: {b}, popCount: {d}\n", .{ i, @popCount(i) });
            //std.debug.print("j: {b}, popCount: {d}\n", .{ j, @popCount(j) });
        }
    }
}
