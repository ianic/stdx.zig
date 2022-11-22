const std = @import("std");

const max_len = 20;
const test_data = @import("combinations_test_data.zig").data;

test "test slips" {
    if (true) return error.SkipZigTest;

    var runs: usize = 1;
    while (runs > 0) : (runs -= 1) {
        for (test_data) |d| {
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
                            m1 *= d.prices[b];
                        }
                    }
                    s += m1;
                    c += 1;
                }
            }

            const w = s * d.stake / c;
            try std.testing.expect(@fabs(w - d.winning) < 0.1);
        }
    }
}
