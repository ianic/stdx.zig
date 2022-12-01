const std = @import("std");
const assert = std.debug.assert;

pub const Callback = fn (a: []const u8) void;

pub fn lam(a: []u8, t: []u8, n: u8, k: u8, cb: *const Callback) void {
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

    cb(a[1..]);

    // all other
    while (top != 0) {
        if (top == 2) { // (* special handling for a[2] and a[1] *)
            top = t[2];
            t[2] = 3;
            while (true) {
                a[1] = a[2];
                a[2] = a[2] + 1;
                cb(a[1..]);
                while (true) {
                    a[1] = a[1] - 1;
                    cb(a[1..]);
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
            cb(a[1..]);
        }
    }
}

pub const Lam = struct {
    top: u8 = 0,
    n: u8,
    k: u8,
    a: []u8,
    t: []u8,
    cnt: usize = 0,

    const Self = @This();
    pub fn init(a: []u8, t: []u8, n: u8, k: u8) Self {
        var c = Self{
            .a = a,
            .t = t,
            .k = k,
            .n = n,
        };
        c.first();
        return c;
    }

    pub fn first(c: *Self) void {
        if (c.k % 2 == 0) {
            c.a[c.k + 1] = c.n + 1;
            c.a[c.k] = c.k;
            if (c.k < c.n) c.top = c.k;
        } else {
            c.a[c.k] = c.n;
            if (c.k < c.n) c.top = c.k - 1;
        }

        c.a[1] = 1;
        c.t[c.k] = 0;
        var i: u8 = 2;
        while (i < c.k) : (i += 1) {
            c.a[i] = i;
            c.t[i] = i + 1;
        }
    }

    fn process(c: *Self) void {
        c.cnt += 1;
        std.debug.print("{d} {d}\n", .{ c.a[1..], c.t });
    }

    pub fn run(c: *Self) void {
        c.process();

        var i: u8 = c.k;
        while (c.top != 0) {
            if (c.top == 2) { // (* special handling for a[2] and a[1] *)
                c.top = c.t[2];
                c.t[2] = 3;
                while (true) {
                    c.a[1] = c.a[2];
                    c.a[2] = c.a[2] + 1;
                    c.process();
                    while (true) {
                        c.a[1] = c.a[1] - 1;
                        c.process();
                        if (c.a[1] == 1) break;
                    }
                    if (c.a[2] == c.a[3] - 1) break;
                }
            } else {
                if (c.top % 2 == 0) {
                    c.a[c.top - 1] = c.a[c.top];
                    c.a[c.top] = c.a[c.top] + 1;
                    if (c.a[c.top] == c.a[c.top + 1] - 1) {
                        c.t[c.top - 1] = c.t[c.top];
                        c.t[c.top] = c.top + 1;
                    }
                    c.top = c.top - 2;
                } else {
                    c.a[c.top] = c.a[c.top] - 1;
                    if (c.a[c.top] > c.top) {
                        c.top = c.top - 1;
                        c.a[c.top] = c.top;
                    } else {
                        c.a[c.top - 1] = c.top - 1;
                        i = c.top;
                        c.top = c.t[c.top];
                        c.t[i] = i + 1;
                    }
                }
                c.process();
            }
        }
    }
};

test {
    const n: u8 = 5;
    const k: u8 = 3;
    var a: [k + 1]u8 = undefined;
    var t: [k + 1]u8 = undefined;

    std.debug.print("\n", .{});
    var l = Lam.init(&a, &t, n, k);
    l.run();
}

var cnt: usize = 0;

test "callback based" {
    const n: u8 = 5;
    const k: u8 = 3;
    var a: [k + 1]u8 = undefined;
    var t: [k + 1]u8 = undefined;

    std.debug.print("\n", .{});
    lam(&a, &t, n, k, struct {
        fn cb(aa: []const u8) void {
            std.debug.print("{d}\n", .{aa});
            cnt += 1;
        }
    }.cb);
}

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
    assert(k > 2 and k <= n and a.len >= k + 1 and t.len >= k + 1);

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
    try @call(.{}, f, args);

    // all other
    while (top != 0) {
        if (top == 2) { // (* special handling for a[2] and a[1] *)
            top = t[2];
            t[2] = 3;
            while (true) {
                a[1] = a[2];
                a[2] = a[2] + 1;
                try @call(.{}, f, args);
                while (true) {
                    a[1] = a[1] - 1;
                    try @call(.{}, f, args);
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
            try @call(.{}, f, args);
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

test "callback struct based" {
    const n: u8 = 5;
    const k: u8 = 3;

    var wrapper: CallbackWrapper = .{};

    //std.debug.print("\n", .{});
    try lamStatic(n, k, CallbackWrapper.callback, &wrapper);
    try std.testing.expectEqual(wrapper.no, 10);
}
