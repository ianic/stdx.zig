const std = @import("std");

const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// in co-lexicographic order
pub fn CoLex(comptime max_k: u8) type {
    return struct {
        n: u8,
        k: u8,
        x: [max_k + 2]u8 = undefined, // internal buffer

        const Self = @This();

        pub fn init(n: u8, k: u8) Self {
            assert(n >= k and k <= max_k);

            var s = Self{
                .n = n,
                .k = k,
            };
            s.first();
            return s;
        }

        fn first(s: *Self) void {
            var i: u8 = 0;
            while (i < s.k) : (i += 1) {
                s.x[i] = i;
            }
            s.x[s.k] = i; // sentinel
            s.x[s.k + 1] = 0; // second sentinel, used only in first iteration of calcNext
        }

        fn current(s: *Self) []u8 {
            return s.x[0..s.k];
        }

        fn isLast(s: *Self) bool {
            return s.x[0] == (s.n - s.k);
        }

        fn tryMove(s: *Self) bool {
            if (s.x[s.k + 1] != 0) return false;
            s.move();
            if (s.isLast()) s.x[s.k + 1] = 1; // use second sentinel to signal isLast for next loop
            return true;
        }

        fn move(s: *Self) void {
            var i: u8 = 0;
            // until lowest rising edge:  attach block at low end
            while (s.x[i] + 1 == s.x[i + 1]) : (i += 1) {
                s.x[i] = i;
            }
            s.x[i] += 1; // move edge element up
            s.x[s.k] = 0; // set sentinel after first iteration
        }

        pub fn next(s: *Self) ?[]u8 {
            return if (s.tryMove()) s.current() else null;
        }
    };
}

test "5/3 CoLex" {
    var l = CoLex(5).init(5, 3);
    var j: u8 = 0;
    while (l.next()) |c| {
        try expectEqualSlices(u8, &colex_test_data_5_3[j], c);
        j += 1;
    }
    try expectEqual(j, colex_test_data_5_3.len);
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
        try expectEqualSlices(u8, &colex_test_data_5_3[j], comb);
        j += 1;
    }
    try expectEqual(colex_test_data_5_3.len, j); // we visited all of them
    try expectEqual(l.next(), null); // all other calls to next returns null
}

test "3/5  ensure working k=n" {
    //if (true) return error.SkipZigTest;

    const n = 5;
    var k: u8 = 1;
    const T = CoLex(n);
    std.debug.print("\n", .{});
    while (k <= n) : (k += 1) {
        std.debug.print("{d} / {d}\n", .{ k, n });
        var l = T.init(n, k);
        while (l.next()) |comb| {
            std.debug.print("\t{d}\n", .{comb});
        }
    }
}

const colex_test_data_5_3 = [10][3]u8{
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
