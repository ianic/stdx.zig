const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;

var K: u6 = 20;
var N: u6 = 32;
var expectedCnt: usize = 0;
const MAX_N = 64;
var buf: [MAX_N]u8 = undefined;
var buf_u1: [MAX_N]u1 = undefined;

pub fn main() !void {
    try all(32, 12, 1);
    try all(32, 13, 1);
    try all(32, 14, 1);
    try all(32, 15, 1);
    try all(32, 16, 1);
    try all(32, 17, 1);
    try all(32, 18, 1);
    try all(32, 19, 1);
    try all(32, 20, 1);

    // expectedCnt = comb.binomial(N, K);
    // try stdx.bench("\tLex", 1, lex);
    // try stdx.bench("\tLex", 1, adapt(N, K, lex2));
    // try stdx.bench("\tLex", 1, loop(lex2));

}

fn all(n: u6, k: u6, loops: usize) !void {
    K = k;
    N = n;
    std.debug.print("{d}/{d}\n", .{ N, K });
    expectedCnt = comb.binomial(N, K);
    var i: usize = 0;
    while (i < loops) : (i += 1) {
        //try stdx.bench("\tCoolLexBitStr", 1, coolLexBitStr);
        //try stdx.bench("\tCoLexIndices", 1, coolLexIndices);
        try stdx.bench("\tLex", 1, lex);
        try stdx.bench("\tCoLex", 1, colex);
        try stdx.bench("\tCoolLex", 1, coolLex);
        try stdx.bench("\tRevDoor", 1, revdoor);
        try stdx.bench("\tLam", 1, lamCallback);
        std.debug.print("\n", .{});
    }
}

pub fn adapt(n: u6, k: u6, comptime handler: *const fn (n: u6, k: u6) anyerror!void) *const fn () anyerror!void {
    const s = struct {
        var n_: u6 = 0;
        var k_: u6 = 0;
        fn cb() anyerror!void {
            try handler(n_, k_);
        }
    };
    s.n_ = n;
    s.k_ = k;
    return s.cb;
}

pub fn loop(comptime handler: *const fn (n: u6, k: u6) anyerror!void) *const fn () anyerror!void {
    return struct {
        fn cb() anyerror!void {
            var n: u6 = 32;
            while (n <= 32) : (n += 1) {
                var k: u6 = 3;
                while (k < n) : (k += 1) {
                    N = n;
                    try handler(n, k);
                }
            }
        }
    }.cb;
}

pub fn lex2(n: u6, k: u6) !void {
    var a = buf[0..k];
    var l = comb.Lex.init(a, n);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(comb.binomial(n, k), cnt);
}

fn lamCallback() !void {
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
    try comb.lam(N, K, CallbackWrapper.callback, &wrapper);
    try std.testing.expectEqual(expectedCnt, wrapper.cnt);
}

pub fn lex() !void {
    var a = buf[0..K];
    var l = comb.Lex.init(a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colex() !void {
    var a = buf[0..K];
    var l = comb.CoLex.init(a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn coolLexBitStr() !void {
    var cnt: usize = 0;
    var cl = comb.CoolLexBitStr.init(N, K);
    while (cl.next()) |a| {
        _ = a; // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn coolLex() !void {
    var a = buf_u1[0..N];
    var cl = comb.CoolLex.init(a, K);
    // visit a
    var cnt: usize = 1;
    while (cl.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

// pub fn coolLexIndices() !void {
//     const bitArrayToIndices = @import("../src/comb/cool_lex.zig").bitArrayToIndices;

//     var a: [N]u1 = undefined;
//     var ix: [K]u8 = undefined;

//     var cl = comb.CoolLex.init(&a, K);
//     // visit a
//     bitArrayToIndices(&a, &ix);
//     var cnt: usize = 1;
//     while (cl.next()) {
//         // visit a
//         bitArrayToIndices(&a, &ix);
//         cnt += 1;
//     }
//     try std.testing.expectEqual(expectedCnt, cnt);
//     try std.testing.expectEqual(ix[0], 0); // use ix to prevent optimize out
// }

pub fn revdoor() !void {
    var a = buf[0..K];
    var l = comb.RevDoor.init(a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}
