const std = @import("std");
const assert = std.debug.assert;

// Minimal-change order for combinations with k>=2 elements.
// Good performance for small k.
// Code taken from fxtbook, chapter 6.4, demo/combination-lam-demo.cc

const MAX_N = 64;

pub fn lamStatic(n: u8, k: u8, comptime f: anytype, ctx: anytype) !void {
    assert(n < MAX_N);
    var a: [MAX_N]u8 = undefined;
    var t: [MAX_N]u8 = undefined;

    try lamProvided(&a, &t, n, k, f, ctx);
}

pub fn lamProvided(a: []u8, t: []u8, n: u8, k: u8, comptime f: anytype, ctx: anytype) !void {
    assert(k >= 2 and k <= n and a.len >= k + 1 and t.len >= k + 1);

    var top: u8 = 0;

    // init first
    if (k % 2 == 0) {
        a[k + 1] = n + 1;
        a[k] = k;
        if (k < n) top = k;
    } else {
        a[k] = n;
        if (k < n) top = k - 1;
    }

    a[1] = 1;
    t[k] = 0;
    var i: u8 = 2;
    while (i < k) : (i += 1) {
        a[i] = i;
        t[i] = i + 1;
    }

    const args = .{ ctx, a[1 .. k + 1] };
    try @call(.auto, f, args);

    // all other
    while (top != 0) {
        if (top == 2) { // (* special handling for a[2] and a[1] *)
            top = t[2];
            t[2] = 3;
            while (true) {
                a[1] = a[2];
                a[2] = a[2] + 1;
                try @call(.auto, f, args);
                while (true) {
                    a[1] = a[1] - 1;
                    try @call(.auto, f, args);
                    if (a[1] == 1) break;
                }
                if (a[2] == a[3] - 1) break;
            }
        } else {
            if (top % 2 == 0) {
                a[top - 1] = a[top];
                a[top] = a[top] + 1;
                if (a[top] == a[top + 1] - 1) {
                    t[top - 1] = t[top];
                    t[top] = top + 1;
                }
                top = top - 2;
            } else {
                a[top] = a[top] - 1;
                if (a[top] > top) {
                    top = top - 1;
                    a[top] = top;
                } else {
                    a[top - 1] = top - 1;
                    i = top;
                    top = t[top];
                    t[i] = i + 1;
                }
            }
            try @call(.auto, f, args);
        }
    }
}

const test_data_5_3 = [10][3]u8{
    [_]u8{ 1, 2, 5 },
    [_]u8{ 2, 3, 5 },
    [_]u8{ 1, 3, 5 },
    [_]u8{ 3, 4, 5 },
    [_]u8{ 2, 4, 5 },
    [_]u8{ 1, 4, 5 },
    [_]u8{ 1, 2, 4 },
    [_]u8{ 2, 3, 4 },
    [_]u8{ 1, 3, 4 },
    [_]u8{ 1, 2, 3 },
};

const CallbackWrapper = struct {
    no: usize = 0,
    const Self = @This();

    pub fn callback(self: *Self, a: []u8) !void {
        try std.testing.expectEqualSlices(u8, &test_data_5_3[self.no], a);
        self.no += 1;
        //std.debug.print("{d}\n", .{a});
    }
};

const PrintCallback = struct {
    no: usize = 0,
    const Self = @This();

    pub fn callback(self: *Self, a: []u8) !void {
        _ = a;
        self.no += 1;
        //std.debug.print("{d}\n", .{a});
    }
};

test "3/5" {
    const n: u8 = 5;
    const k: u8 = 3;

    var wrapper: CallbackWrapper = .{};

    //std.debug.print("\n", .{});
    try lamStatic(n, k, CallbackWrapper.callback, &wrapper);
    try std.testing.expectEqual(wrapper.no, 10);
}

test "2/5" {
    const n: u8 = 5;
    const k: u8 = 2;

    var wrapper: PrintCallback = .{};

    try lamStatic(n, k, PrintCallback.callback, &wrapper);
    try std.testing.expectEqual(wrapper.no, 10);
}
