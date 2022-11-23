const std = @import("std");

const max_len = 20;
const test_data = @import("combinations_test_data.zig").data;

pub fn main() !void {
    const start = std.time.nanoTimestamp();
    const runs: usize = 562;
    var rns = runs;
    var sum: f64 = 0;
    while (rns > 0) : (rns -= 1) {
        for (test_data) |d| {
            const p = sumOfProducts(d.prices, d.r);
            const w = p * d.stake / @intToFloat(f64, count(d.r, @intCast(u8, d.prices.len)));
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
// Combinations of n things taken r at the time.
fn sumOfProducts(items: []const f64, r: usize) f64 {
    const n = items.len;

    // handle simple r==1 and r==n cases
    if (r == 1) {
        return sumAll(items);
    } else if (r == n) {
        return mulAll(items);
    }
    // all other cases
    return sumOfProductsRec(items, r, 0, 0, 1);
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

fn sumOfProductsRec(items: []const f64, r: usize, depth: usize, start_pos: usize, m: f64) f64 {
    const n = items.len;
    var s: f64 = 0;
    var i = start_pos;
    while (i <= n - r + depth) : (i += 1) {
        const new_m = m * items[i];
        s += if (depth == r - 1) new_m else sumOfProductsRec(items, r, depth + 1, i + 1, new_m);
    }
    return s;
}

test "2/4" {
    const items = [_]f64{ 1, 2, 3, 4 };
    const sp = sumOfProducts(&items, 2);
    try std.testing.expectEqual(sp, 35);
}

test "3/5" {
    const items = [_]f64{ 1, 2, 3, 4, 5 };
    const sp = sumOfProducts(&items, 3);
    try std.testing.expectEqual(sp, 225);
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
        const w = p * d.stake / @intToFloat(f64, count(d.r, @intCast(u8, d.prices.len)));

        const expect = @fabs(w - d.winning) < 0.1;
        if (!expect) {
            std.debug.print("case {d} failed, w: {d} {d}\n", .{ i, w, d.winning });
        }
        try std.testing.expect(expect);
    }
}

test "one" {
    const i = 307;

    const d = test_data[i];
    const p = sumOfProducts(d.prices, d.r);
    const w = p * d.stake / @intToFloat(f64, count(d.r, @intCast(u8, d.prices.len)));

    const expect = @fabs(w - d.winning) < 0.1;
    if (!expect) {
        std.debug.print("case {d} failed, w: {d} {d}\n", .{ i, w, d.winning });
    }
    try std.testing.expect(expect);
}

const pt = pascalTriangle();

fn pascalTriangle() [210]u32 {
    var k = [_]u32{1} ** 210;

    var n: u8 = 0;
    var i: u32 = 0;
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

fn count(r: u8, n: u8) u32 {
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
