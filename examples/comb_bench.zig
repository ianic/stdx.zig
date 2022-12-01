const std = @import("std");
const stdx = @import("stdx");
const comb = stdx.comb;

const K = 12;
const N = 32;
const expectedCnt = comb.binomial(N, K);

pub fn main() !void {
    std.debug.print("{d}/{d}\n", .{ N, K });
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        try stdx.bench("\tCoolLexBitStr", 1, coolLexBitStr);
        try stdx.bench("\tCoolLex", 1, coolLex);
        //try stdx.bench("\tCoLexIndices", 1, coolLexIndices);

        try stdx.bench("\tLex", 1, lex);
        try stdx.bench("\tCoLex", 1, colex);
        try stdx.bench("\tRevDoor", 1, revdoor);
        //try stdx.bench("\tLam", 1, lam);
        try stdx.bench("\tLam callback", 1, lamCallback);
        std.debug.print("\n", .{});
    }
}

pub fn lam() !void {
    var a: [K + 1]u8 = undefined;
    var t: [K + 1]u8 = undefined;

    var l = comb.Lam.init(&a, &t, N, K);
    l.run();
    try std.testing.expectEqual(expectedCnt, l.cnt);
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
    try comb.lamStatic(N, K, CallbackWrapper.callback, &wrapper);
    try std.testing.expectEqual(expectedCnt, wrapper.cnt);
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

pub fn coolLexIndices() !void {
    const bitArrayToIndices = @import("../src/comb/cool_lex.zig").bitArrayToIndices;

    var a: [N]u1 = undefined;
    var ix: [K]u8 = undefined;

    var cl = comb.CoolLex.init(&a, K);
    // visit a
    bitArrayToIndices(&a, &ix);
    var cnt: usize = 1;
    while (cl.next()) {
        // visit a
        bitArrayToIndices(&a, &ix);
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
    try std.testing.expectEqual(ix[0], 0); // use ix to prevent optimize out
}

pub fn revdoor() !void {
    var a: [K]u8 = undefined;
    var l = comb.RevDoor.init(&a, N);
    // visit a
    var cnt: usize = 1;
    while (l.next()) {
        // visit a
        cnt += 1;
    }
    try std.testing.expectEqual(expectedCnt, cnt);
}
