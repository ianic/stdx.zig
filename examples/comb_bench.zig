const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;

const K = 20;
const N = 32;
const expectedCnt = comb.binomial(N, K);

pub fn main() !void {
    std.debug.print("{d}/{d}\n", .{ N, K });
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        try stdx.bench("\tCoolLexBinaryString", 1, coolLexBinaryString);
        try stdx.bench("\tCoolLex", 1, coolLex);
        try stdx.bench("\tLex", 1, lex);
        try stdx.bench("\tCoLex", 1, colex);
        std.debug.print("\n", .{});
    }
}

pub fn lex() !void {
    var a: [K]u8 = undefined;
    var l = comb.Lex.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn colex() !void {
    var a: [K]u8 = undefined;
    var l = comb.CoLex.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn coolLexBinaryString() !void {
    var cnt: usize = 0;
    var cl = comb.CoolLexBinaryString.init(N, K);
    while (cl.next()) |a| {
        _ = a; // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}

pub fn coolLex() !void {
    var a: [N]u1 = undefined;
    var cl = comb.CoolLex.init(&a, K);
    // visit a
    var cnt: usize = 1;
    while (cl.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}
