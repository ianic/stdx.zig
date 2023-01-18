const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

fn readArg(comptime T: anytype, pos: usize, default: T) T {
    const argv = std.os.argv;
    if (pos >= argv.len) return default;
    const arg = argv[pos];
    return std.fmt.parseUnsigned(T, arg[0..std.mem.len(arg)], 10) catch default;
}

pub fn main() !void {
    const alg = readArg(usize, 1, 0);
    const n = readArg(u6, 2, 20);
    const k_min = readArg(u6, 3, 1);
    const k_max = readArg(u6, 4, n);
    const runs = readArg(usize, 5, 50);

    std.debug.print("alg: {d}, n: {d}, k_min: {d}, k_max: {d}, runs: {d}\n", .{ alg, n, k_min, k_max, runs });
    assert(k_min <= k_max and k_min > 0 and k_max <= n);

    var r: u8 = 0;
    while (r < runs) : (r += 1) {
        var k: u6 = k_min;
        while (k <= k_max) : (k += 1) {
            switch (alg) {
                // lexicographical order
                0 => try lex(n, k),

                // co-lexicographical order
                1 => try fxtCoLex(n, k),
                2 => try knuthCoLex(n, k),
                3 => try knuthCoLexIter(n, k),

                // returns bits array
                4 => try coolLex(n, k),
                5 => try coolLexIter(n, k), // alternative interface

                // revolving door
                6 => try revdoor(n, k),

                // callback interface
                7 => try lam(n, k),
                else => unreachable,
            }
        }
    }
}

const MAX_N = 64;
var buf: [MAX_N]u8 = undefined;
var buf_u1: [MAX_N]u1 = undefined;
var prevent_optimization: []u8 = undefined;
var prevent_optimization_u1: []u1 = undefined;

pub fn lex(n: u6, k: u6) !void {
    var l = comb.Lex.init(n, k, &buf);
    var cnt: usize = 0;
    var hasMore = true;
    while (hasMore) : (hasMore = l.more()) {
        cnt += 1;
        prevent_optimization = l.current();
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, k), prevent_optimization.len);
}

pub fn fxtCoLex(n: u6, k: u6) !void {
    var l = comb.FxtCoLex.init(n, k, &buf);
    var cnt: usize = 0;
    var hasMore = true;
    while (hasMore) : (hasMore = l.more()) {
        cnt += 1;
        prevent_optimization = l.current();
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, k), prevent_optimization.len);
}

pub fn knuthCoLex(n: u6, k: u6) !void {
    var l = comb.KnuthCoLex.init(n, k, &buf);
    var cnt: usize = 0;
    var hasMore = true;
    while (hasMore) : (hasMore = l.more()) {
        cnt += 1;
        prevent_optimization = l.current();
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, k), prevent_optimization.len);
}

pub fn knuthCoLexIter(n: u6, k: u6) !void {
    var alg = comb.KnuthCoLex.init(n, k, &buf);
    var cnt: usize = 0;
    var iter = alg.iter();
    while (iter.next()) |current| {
        prevent_optimization = current;
        cnt += 1;
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, k), prevent_optimization.len);
}

fn lam(n: u6, k: u6) !void {
    const CallbackWrapper = struct {
        cnt: usize = 0,
        const Self = @This();
        pub fn callback(self: *Self, a: []u8) !void {
            prevent_optimization = a;
            self.cnt += 1;
        }
    };
    var wrapper: CallbackWrapper = .{};
    try comb.lam(n, k, CallbackWrapper.callback, &wrapper);
    try expectEqual(comb.binomial(n, k), wrapper.cnt);
    try expectEqual(@as(usize, k), prevent_optimization.len);
}

pub fn coolLex(n: u6, k: u6) !void {
    var alg = comb.CoolLex.init(n, k, &buf_u1);

    var cnt: usize = 0;
    var hasMore = true;
    while (hasMore) : (hasMore = alg.more()) {
        prevent_optimization_u1 = alg.current();
        cnt += 1;
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, n), prevent_optimization_u1.len);
}

pub fn coolLexIter(n: u6, k: u6) !void {
    var alg = comb.CoolLex.init(n, k, &buf_u1);

    var cnt: usize = 0;
    var iter = alg.iter();
    while (iter.next()) |current| {
        prevent_optimization_u1 = current;
        cnt += 1;
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, n), prevent_optimization_u1.len);
}

pub fn revdoor(n: u6, k: u6) !void {
    var l = comb.RevDoor.init(n, k, &buf);

    var cnt: usize = 0;
    var hasMore = true;
    while (hasMore) : (hasMore = l.more()) {
        prevent_optimization = l.current();
        cnt += 1;
    }
    try expectEqual(comb.binomial(n, k), cnt);
    try expectEqual(@as(usize, k), prevent_optimization.len);
}
