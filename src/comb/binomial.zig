const std = @import("std");

const PASCAL_TRIANGLE = calcPascalTriangle();
const MAX_N = 67; // for n = 68 we got u64 overflow for some values in triangle
const PT_SIZE = (MAX_N * (MAX_N + 1)) / 2;

fn calcPascalTriangle() [PT_SIZE]usize {
    @setEvalBranchQuota(10_000);
    var b = [_]usize{1} ** PT_SIZE;

    var n: usize = 0;
    var i: usize = 0;
    while (n <= MAX_N) : (n += 1) {
        var k: usize = 0;
        while (k < n) : ({
            k += 1;
            i += 1;
        }) {
            if (k == 0) {
                b[i] = n;
                continue;
            }
            if (k == n - 1) {
                b[i] = 1;
                continue;
            }
            b[i] = b[i - n] + b[i - n + 1];
        }
    }
    return b;
}

// find position in pascal triangle array
fn position(n: usize, k: usize) usize {
    std.debug.assert(k <= n);
    std.debug.assert(n <= MAX_N);
    std.debug.assert(n > 0);
    std.debug.assert(k > 0);

    switch (n) {
        1 => return 0,
        2 => return k,
        3 => return k + 2,
        4 => return k + 5,
        5 => return k + 9,
        6 => return k + 14,
        7 => return k + 20,
        8 => return k + 27,
        9 => return k + 35,
        10 => return k + 44,
        else => return ((n * (n - 1)) / 2) + k - 1,
    }
}

test "show pascal triangle" {
    if (true) return error.SkipZigTest;

    std.debug.print("\nk =>", .{});
    var j: usize = 1;
    while (j <= 20) : (j += 1) {
        std.debug.print("{d:>6} ", .{j});
    }

    var n: usize = 1;
    std.debug.print("\nn= 1", .{});
    for (PASCAL_TRIANGLE) |i| {
        std.debug.print("{d:>6} ", .{i});
        if (i == 1) {
            n += 1;
            std.debug.print("\nn={d:>2}", .{n});
            if (n >= 21) {
                break;
            }
        }
    }
    //std.debug.print("max: {d}\n", .{binomial(MAX_N, MAX_N / 2)});
}

const expectEqual = std.testing.expectEqual;

test "binomial" {
    try expectEqual(binomial(1, 1), 1);
    try expectEqual(binomial(2, 1), 2);
    try expectEqual(binomial(2, 2), 1);
    try expectEqual(binomial(3, 1), 3);
    try expectEqual(binomial(3, 2), 3);
    try expectEqual(binomial(3, 3), 1);
    try expectEqual(binomial(4, 2), 6);

    try expectEqual(binomial(7, 1), 7);
    try expectEqual(binomial(7, 2), 21);
    try expectEqual(binomial(7, 3), 35);
    try expectEqual(binomial(7, 4), 35);

    try expectEqual(binomial(19, 8), 75582);
    try expectEqual(binomial(19, 9), 92378);
    try expectEqual(binomial(19, 12), 50388);
    try expectEqual(binomial(19, 13), 27132);

    try expectEqual(binomial(33, 16), 1166803110);
    try expectEqual(binomial(64, 32), 1832624140942590534);
    try expectEqual(binomial(65, 2), 2080);

    // those goes to binomialCalc implementation
    try expectEqual(binomial(68, 2), 2278);
    try expectEqual(binomial(256, 2), 32640);
}

pub fn binomial(n: usize, k: usize) usize {
    if (n <= MAX_N)
        return PASCAL_TRIANGLE[position(n, k)];
    // alternative implementation:
    return binomialCalc(n, k);
}

// from fxtbook 6.1. (https://www.jjj.de/fxt/#fxtbook)
pub fn binomialCalc(n: usize, k_: usize) usize {
    var k = k_;

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
