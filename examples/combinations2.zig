const std = @import("std");

const max_len = 20;
const test_data = @import("combinations_test_data.zig").data;

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

// Sum of products of all combinations.
// Combinations of n items taken r at the time.
pub fn sumOfProducts(items: []const f64, r: usize) f64 {
    //const n = items.len;
    //handle simple r==1 and r==n cases
    //not necessary tiny optimization
    // if (r == 1) {
    //     return sumAll(items);
    // } else if (r == n) {
    //     return mulAll(items);
    // }
    //all other cases
    //return sumOfProductsRec(items, r - 1, n, 1);
    return SOP(items, r);
}

fn sumAll(items: []const f64) f64 {
    var s: f64 = items[0];
    var i: usize = 1;
    while (i < items.len) : (i += 1) {
        s += items[i];
    }
    return s;
}

fn mulAll(items: []const f64) f64 {
    var s = items[0];
    var i: usize = 1;
    while (i < items.len) : (i += 1) {
        s *= items[i];
    }
    return s;
}

fn sumOfProductsRec(items: []const f64, start_pos: usize, end_pos: usize, prod: f64) f64 {
    var s: f64 = 0;
    var i = start_pos;
    while (i < end_pos) : (i += 1) {
        const new_prod = prod * items[i];
        s += if (start_pos == 0) new_prod else sumOfProductsRec(items, start_pos - 1, i, new_prod);
    }
    return s;
}

test "2/4" {
    const items = [_]f64{ 1, 2, 3, 4 };
    const sp = sumOfProducts(&items, 2);
    try std.testing.expectEqual(sp, 35);

    try std.testing.expectEqual(sumOfProd(&items, 2), 35);
}

test "3/5" {
    const items = [_]f64{ 1, 2, 3, 4, 5 };
    const sp = sumOfProducts(&items, 3);
    try std.testing.expectEqual(sp, 225);

    try std.testing.expectEqual(sumOfProd(&items, 3), 225);
}
const SOP = @import("sum_of_products.zig").SumOfProductsGen(f64).sum;

fn sumOfProd(items: []const f64, r: usize) f64 {
    //return SumOfProductsGen(f64).sum(items, r);
    return SOP(items, r);
}
fn SumOfProductsGen(comptime T: type) type {
    return struct {
        pub fn sum(items: []const T, r: usize) T {
            const n: usize = items.len;
            var s: T = 0;

            switch (r) {
                2 => {
                    var l1: usize = r - 1;
                    while (l1 < n) : (l1 += 1) {
                        var p1: T = items[l1];

                        var l2: usize = r - 2;
                        while (l2 < l1) : (l2 += 1) {
                            var p2 = p1 * items[l2];
                            s += p2;
                        }
                    }
                },
                3 => {
                    var l1: usize = r - 1;
                    while (l1 < n) : (l1 += 1) {
                        var p1: T = items[l1];

                        var l2: usize = r - 2;
                        while (l2 < l1) : (l2 += 1) {
                            var p2 = p1 * items[l2];

                            var l3: usize = r - 3;
                            while (l3 < l2) : (l3 += 1) {
                                var p3 = p2 * items[l3];
                                s += p3;
                            }
                        }
                    }
                },
                else => unreachable,
            }

            return s;
        }
    };
}

test "first data row" {
    const d = test_data[0];
    const p = sumOfProducts(d.prices, d.r);
    const w = p * d.stake / 55;
    try std.testing.expect(@fabs(w - d.winning) < 0.0001);
}

test "all data rows" {
    for (test_data) |d, i| {
        const p = sumOfProducts(d.prices, d.r);
        const w = p * d.stake / @intToFloat(f64, binomial(d.r, d.prices.len));

        const expect = @fabs(w - d.winning) < 0.1;
        if (!expect) {
            std.debug.print("case {d} failed, w: {d} {d}\n", .{ i, w, d.winning });
        }
        try std.testing.expect(expect);
    }
}

const PASCAL_TRIANGLE = calcPascalTriangle();
const MAX_N = 64;
const PT_SIZE = (MAX_N * (MAX_N + 1)) / 2;

fn calcPascalTriangle() [PT_SIZE]usize {
    @setEvalBranchQuota(10_000);
    var k = [_]usize{1} ** PT_SIZE;

    var n: usize = 0;
    var i: usize = 0;
    while (n <= MAX_N) : (n += 1) {
        var r: usize = 0;
        while (r < n) : ({
            r += 1;
            i += 1;
        }) {
            if (r == 0) {
                k[i] = n;
                continue;
            }
            if (r == n - 1) {
                k[i] = 1;
                continue;
            }
            k[i] = k[i - n] + k[i - n + 1];
        }
    }
    return k;
}

fn position(r: usize, n: usize) usize {
    std.debug.assert(r <= n);
    std.debug.assert(n <= MAX_N);
    std.debug.assert(n > 0);
    std.debug.assert(r > 0);

    switch (n) {
        1 => return 0,
        2 => return r,
        3 => return r + 2,
        4 => return r + 5,
        5 => return r + 9,
        6 => return r + 14,
        7 => return r + 20,
        8 => return r + 27,
        9 => return r + 35,
        10 => return r + 44,
        else => return ((n * (n - 1)) / 2) + r - 1,
    }
}

test "print pascal triangle" {
    if (true) return error.SkipZigTest;

    std.debug.print("\n", .{});
    for (PASCAL_TRIANGLE) |i| {
        std.debug.print("{d} ", .{i});
        if (i == 1)
            std.debug.print("\n", .{});
    }
    std.debug.print("max: {d}\n", .{binomial(MAX_N / 2, MAX_N)});
}

const expectEqual = std.testing.expectEqual;

test "binomial" {
    try expectEqual(binomial(1, 1), 1);
    try expectEqual(binomial(1, 2), 2);
    try expectEqual(binomial(2, 2), 1);
    try expectEqual(binomial(1, 3), 3);
    try expectEqual(binomial(2, 3), 3);
    try expectEqual(binomial(3, 3), 1);

    try expectEqual(binomial(1, 7), 7);
    try expectEqual(binomial(2, 7), 21);
    try expectEqual(binomial(3, 7), 35);
    try expectEqual(binomial(4, 7), 35);

    try expectEqual(binomial(8, 19), 75582);
    try expectEqual(binomial(9, 19), 92378);
    try expectEqual(binomial(12, 19), 50388);
    try expectEqual(binomial(13, 19), 27132);

    try expectEqual(binomial(16, 33), 1166803110);
    try expectEqual(binomial(32, 64), 1832624140942590534);
}

pub fn binomial(r: usize, n: usize) usize {
    return PASCAL_TRIANGLE[position(r, n)];
    // alternative implementation:
    // return binomialCalc(r, n);
}

// from fxtbook 6.1.
pub fn binomialCalc(r: usize, n: usize) usize {
    var k = r;

    if (k > n) return 0;
    if ((k == 0) or (k == n)) return 1;
    if (k > n / 2) {
        k = n - k;
    } // use symmetry

    var b: usize = n - k + 1;
    var f: usize = b;
    var j: usize = 2;
    while (j <= k) : (j += 1) {
        f += 1;
        b *= f;
        b /= j;
    }
    return b;
}

// for readme:
// fxtbook: https://www.jjj.de/fxt/#fxtbook
