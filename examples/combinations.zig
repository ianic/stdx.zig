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

test {
    var s: u32 = 0;

    std.debug.print("\n", .{});
    for (pt) |i| {
        std.debug.print("{d} ", .{i});
        if (i == 1)
            std.debug.print("\n", .{});
        s += i;
    }
    std.debug.print("sum: {d}\n", .{s});
}

const pt = pascalTriangle();
const ps = positions();

fn pascalTriangle() [210]u18 {
    var k = [_]u18{1} ** 210;

    var n: u8 = 0;
    var i: u18 = 0;
    while (n <= 20) : (n += 1) {
        var r: u8 = 0;
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

fn positions() [210]u21 {
    var k = [_]u21{0} ** 210;

    var i: u18 = 1;
    while (i < k.len) : (i += 1) {
        k[i] = k[i - 1] + pt[i - 1];
    }

    return k;
}

test "positions" {
    std.debug.print("\n", .{});
    for (ps) |i, j| {
        std.debug.print("{d} ", .{i});
        if (pt[j] == 1)
            std.debug.print("\n", .{});
    }
}

fn kk() void {
    var p: [210]u21 = ps;
    var k = [_]u20{1} ** 2097130;

    var j: u20 = 1;
    while (j <= (2 << 20)) : (j += 1) {
        const pc = @popCount(j);

        var n: u8 = 0;
        var i: u18 = 0;
        while (n <= 20) : (n += 1) {
            var r: u8 = 0;
            while (r < n) : ({
                r += 1;
                i += 1;
            }) {
                if (r == pc) {
                    k[p[i]] = j;
                    p[i] += 1;
                }
            }
        }
    }
    for (k) |v| {
        std.debug.print("{d} ", .{v});
    }
}

const a_indexes = calcIndexes();
const a_indexes_positions = calcIndexesPositions();

const m20 = 1048575;

fn calcIndexesPositions() [20]u20 {
    var p = [_]u20{0} ** 20;

    var j: u8 = 190;
    var i: u8 = 1;
    while (j < 209) : ({
        j += 1;
        i += 1;
    }) {
        p[i] = p[i - 1] + pt[j];
    }
    return p;
}

fn calcIndexes() [m20]u21 {
    @setEvalBranchQuota(m20 * 2);

    var k = [_]u21{0} ** m20;
    //var p: [20]u20 = a_indexes_positions;

    var p = [_]u20{0} ** 20;
    var j: u8 = 190;
    var i: u8 = 1;
    while (j < 209) : ({
        j += 1;
        i += 1;
    }) {
        p[i] = p[i - 1] + pt[j];
    }

    //std.debug.print("{d}\n", .{p});

    var l: u21 = 1;
    while (l <= m20) : (l += 1) {
        const pc = @popCount(l) - 1;
        k[p[pc]] = l;
        p[pc] += 1;
    }

    // var m: u20 = 210;
    // while (m < 1350) : (m += 1) {
    //     const v = k[m];
    //     std.debug.print("{b:0>20}\n", .{v});
    //     if (m == 19) {
    //         break;
    //     }
    // }
    return k;
}

test "kk" {
    if (true) return error.SkipZigTest;
    var k = [_]u21{0} ** m20;
    var p = [_]u20{0} ** 20;

    var j: u8 = 190;
    var i: u8 = 1;
    while (j < 209) : ({
        j += 1;
        i += 1;
    }) {
        p[i] = p[i - 1] + pt[j];
    }

    std.debug.print("{d}\n", .{p});

    var l: u21 = 1;
    while (l <= m20) : (l += 1) {
        const pc = @popCount(l) - 1;
        k[p[pc]] = l;
        p[pc] += 1;
    }

    var m: u20 = 210;
    while (m < 1350) : (m += 1) {
        const v = k[m];
        std.debug.print("{b:0>20}\n", .{v});
        if (m == 19) {
            break;
        }
    }
}

fn count(r: u8, n: u8) u20 {
    return pt[position(r, n)];
}

fn position(r: u8, n: u8) u8 {
    std.debug.assert(r <= n);
    std.debug.assert(n <= 20);
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
        else => return @intCast(u8, ((@intCast(u16, n) * (@intCast(u16, n) - 1)) / 2) + r - 1),
    }
}

fn indexes(r: u8, n: u8) []const u21 {
    const pos = a_indexes_positions[r - 1];
    const no = count(r, n);
    return a_indexes[pos .. pos + no];
}

const expectEqual = std.testing.expectEqual;

test "count" {
    try expectEqual(count(1, 1), 1);
    try expectEqual(count(1, 2), 2);
    try expectEqual(count(2, 2), 1);
    try expectEqual(count(1, 3), 3);
    try expectEqual(count(2, 3), 3);
    try expectEqual(count(3, 3), 1);

    try expectEqual(count(1, 7), 7);
    try expectEqual(count(2, 7), 21);
    try expectEqual(count(3, 7), 35);
    try expectEqual(count(4, 7), 35);

    try expectEqual(count(8, 19), 75582);
    try expectEqual(count(9, 19), 92378);
    try expectEqual(count(12, 19), 50388);
    try expectEqual(count(13, 19), 27132);
}

test "indexes" {
    const is = indexes(3, 5);
    std.debug.print("{b} ", .{is});
}
