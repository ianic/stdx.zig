const std = @import("std");

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

test "show pascal triangle" {
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
