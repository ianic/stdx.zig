const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;


fn arg2u8(pos: usize) !u6 {
    const arg = std.os.argv[pos];
    if (arg[1] == 0) {
        return try std.fmt.parseUnsigned(u6, arg[0..1], 10);
    }
    if (arg[2] == 0) {
        return try std.fmt.parseUnsigned(u6, arg[0..2], 10);
    }
    return try std.fmt.parseUnsigned(u6, arg[0..3], 10);
}

pub fn main() !void {
    assert(std.os.argv.len > 5);

    const alg = try arg2u8(1);
    const n = try arg2u8(2);
    const k_min = try arg2u8(3);
    const k_max = try arg2u8(4);
    const runs = try arg2u8(5);

    std.debug.print("alg: {d}, n: {d}, k_min: {d}, k_max: {d}, runs: {d}\n", .{ alg, n, k_min, k_max, runs });
    //assert(alg < 5);
    //assert(n > 4);
    assert(k_min <= k_max and k_min >= 2 and k_max <= n);

    var r: u8 = 0;
    while (r < runs) : (r += 1) {
        var k: u6 = k_min;
        while (k <= k_max) : (k += 1) {
            switch (alg) {
                0 => try colex(n, k),
                1 => try lex(n, k),

                3 => try lam(n, k),
                4 => try revdoor(n, k),

                6 => try coolLex(n, k),


                10 => try knuthCoLex(n, k),

                else => unreachable,
            }
        }
    }
}

const MAX_N = 64;
var buf: [MAX_N]u8 = undefined;
var buf_u1: [MAX_N]u1 = undefined;

pub fn lex(n: u6, k: u6) !void {
    var l = comb.Lex(MAX_N).init(n, k);
    var cnt: usize = 0;
    while (l.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(comb.binomial(n, k), cnt);
}


pub fn knuthCoLex(n: u6, k: u6) !void {
    var l = comb.KnuthCoLex(MAX_N).init(n, k);
    var cnt: usize = 0;
    while (l.next()) |_| {
        cnt += 1;
    }
    try std.testing.expectEqual(comb.binomial(n, k), cnt);
}

fn lam(n: u6, k: u6) !void {
    const CallbackWrapper = struct {
        cnt: usize = 0,
        const Self = @This();
        pub fn callback(self: *Self, a: []u8) !void {
            _ = a;
            //std.debug.print("{d}\n", .{a});
            self.cnt += 1;
        }
    };
    var wrapper: CallbackWrapper = .{};
    try comb.lam(n, k, CallbackWrapper.callback, &wrapper);
    try std.testing.expectEqual(comb.binomial(n, k), wrapper.cnt);
}

pub fn colex(n: u6, k: u6) !void {
    var l = comb.CoLex(MAX_N).init(n, k);
    var cnt: usize = 0;
    while (l.next()) |_|  {
        cnt += 1;
    }
    try std.testing.expectEqual(comb.binomial(n, k), cnt);
}

pub fn coolLex(n: u6, k: u6) !void {
    var a = buf_u1[0..n];
    var cl = comb.CoolLex.init(a, k);
    // visit a
    var cnt: usize = 1;
    while (cl.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(comb.binomial(n, k), cnt);
}


var unomptimized: []u8 = undefined;

pub fn revdoor(n: u6, k: u6) !void {
    var l = comb.RevDoor.init(n, k, &buf);

    var cnt: usize = 0;
    var hasMore = true;
    while (hasMore): (hasMore = l.more()) {
        unomptimized = l.current();
        cnt += 1;
    }
    try std.testing.expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, k), unomptimized.len);
}
