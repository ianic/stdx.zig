const std = @import("std");
const assert = std.debug.assert;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// in co-lexicographic order
pub const CoLex = struct {
    m: u8, // max index in a = n - k
    a: []u8, // working array

    const Self = @This();
    pub fn init(a: []u8, n: u8) Self {
        const k: u8 = @intCast(u8, a.len);
        assert(n >= k);

        var c = Self{
            .m = n - k,
            .a = a,
        };
        c.first();
        return c;
    }

    pub fn first(c: *Self) void {
        var i: u8 = 0;
        while (i < c.a.len) : (i += 1) {
            c.a[i] = i;
        }
    }

    // find next combination
    pub fn next(c: *Self) bool {
        if (c.a[0] == c.m) { // current combination is the last
            return false;
        }
        var j: u8 = 0;
        // until lowest rising edge:  attach block at low end
        while (j + 1 < c.a.len and 1 == (c.a[j + 1] - c.a[j])) : (j += 1) {
            c.a[j] = j;
        }
        c.a[j] += 1; // move edge element up
        return true;
    }
};

const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

const test_data_5_3 = [10][3]u8{
    [_]u8{ 0, 1, 2 },
    [_]u8{ 0, 1, 3 },
    [_]u8{ 0, 2, 3 },
    [_]u8{ 1, 2, 3 },
    [_]u8{ 0, 1, 4 },
    [_]u8{ 0, 2, 4 },
    [_]u8{ 1, 2, 4 },
    [_]u8{ 0, 3, 4 },
    [_]u8{ 1, 3, 4 },
    [_]u8{ 2, 3, 4 },
};

test "5/3" {
    var buf: [3]u8 = undefined; // buf is of size k = 3
    var l = CoLex.init(&buf, 5); // n = 5

    // visit first combination
    try expectEqualSlices(u8, &test_data_5_3[0], &buf);

    var j: u8 = 1;
    while (l.next()) : (j += 1) {
        // call next and then visit another combination
        try expectEqualSlices(u8, &test_data_5_3[j], &buf);
    }
    // next returns false
    try expectEqual(l.next(), false);
    // rewind to the start
    l.first();
    try expectEqualSlices(u8, &test_data_5_3[0], &buf);
}

pub fn KnuthCoLex(comptime max_k: u8) type {
    return struct {
        k: u8,
        n: u8,
        buf: [max_k + 3]u8 = undefined,
        x: []u8 = undefined,
        j: u8 = 0,

        const Self = @This();

        pub fn init(n: u8, k: u8) Self {
            var s = Self{
                .n = n,
                .k = k,
            };
            s.reset();
            return s;
        }

        // Reset x to zero len so we can detect first call to next.
        inline fn reset(s: *Self) void {
            s.x = s.buf[0..0];
        }

        // Initialize x with first combination.
        fn first(s: *Self) void {
            s.x = s.buf[0 .. s.k + 3]; // 3 = zero based + 2 sentinels at end
            s.x[0] = 0; // not used s.x is zero based
            var j: u8 = 1;
            while (j <= s.k) : (j += 1) {
                s.x[j] = j - 1;
            }
            // two sentinels at end
            s.x[s.k + 1] = s.n;
            s.x[s.k + 2] = 0;
            s.j = s.k;

            // algorithm assumes k < n
            // here we assure isLast to be true for that case so we don't use rest of the algorithm
            if (s.k == s.n) s.j += 1;
        }

        inline fn isLast(s: *Self) bool {
            return s.j > s.k;
        }

        pub inline fn current(s: *Self) []u8 {
            // TODO not safe to call before first
            return s.x[1 .. s.k + 1];
        }

        pub fn next(s: *Self) ?[]u8 {
            return if (s.hasNext()) s.current() else null;
        }

        pub fn hasNext(s: *Self) bool {
            // first call
            if (s.x.len == 0) {
                s.first();
                return true;
            }

            // current combination is the last
            if (s.isLast()) {
                return false;
            }

            return s.calcNext();
        }

        fn calcNext(s: *Self) bool {
            if (s.j > 0) {
                // increase
                s.x[s.j] = s.j;
                s.j -= 1;
                return true;
            }
            // easy case?
            if (s.x[1] + 1 < s.x[2]) {
                s.x[1] += 1;
                return true;
            }
            s.j = 2;
            var x: u8 = 0;
            // find j
            while (true) {
                s.x[s.j - 1] = s.j - 2;
                x = s.x[s.j] + 1;
                if (x != s.x[s.j + 1]) break;
                s.j += 1;
            }
            // done?
            if (s.j > s.k) return false;
            // increase
            s.x[s.j] = x;
            s.j -= 1;
            return true;
        }
    };
}

test "3/5 Knuth CoLex" {
    var l = KnuthCoLex(128).init(5, 3);
    var j: u8 = 0;
    // visit all combinations
    while (l.next()) |comb| {
        //std.debug.print("{d}\n", .{comb});
        try expectEqualSlices(u8, &test_data_5_3[j], comb);
        j += 1;
    }
    try expectEqual(test_data_5_3.len, j); // we visited all of them
    try expectEqual(l.next(), null); // all other calls to next returns null
}

test "3/5 Knuth CoLex ensure working k=n" {
    if (true) return error.SkipZigTest;

    const n = 5;
    var k: u8 = 1;
    const KL = KnuthCoLex(n);
    std.debug.print("\n", .{});
    while (k <= n) : (k += 1) {
        std.debug.print("{d} / {d}\n", .{ k, n });
        var l = KL.init(n, k);
        while (l.next()) |comb| {
            std.debug.print("\t{d}\n", .{comb});
        }
    }
}
