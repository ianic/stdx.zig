const std = @import("std");
const assert = std.debug.assert;

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// in co-lexicographic order
pub const CoLex = struct {
    n: usize,
    k: usize,
    a: []usize, // working array
    current: ?[]usize,
    is_first: bool = true,

    const Self = @This();
    pub fn init(a: []usize, n: u6) Self {
        var c = Self{
            .n = n,
            .k = a.len,
            .a = a,
            .current = null,
        };
        assert(c.n >= c.k);
        c.first();
        return c;
    }

    fn first(c: *Self) void {
        var i: usize = 0;
        while (i < c.k) : (i += 1) {
            c.a[i] = i;
        }
        c.current = c.a;
        c.is_first = true;
    }

    pub fn next(c: *Self) ?[]usize {
        if (c.is_first) { // current combination is the first
            c.is_first = false;
        } else {
            _ = c.hasNext();
        }
        return c.current;
    }

    pub fn findNext(c: *Self) void {
        _ = c.hasNext();
    }

    // find next combination
    pub fn hasNext(c: *Self) bool {
        if (c.a[0] == c.n - c.k) { // current combination is the last
            c.current = null;
            return false;
        }
        var j: usize = 0;
        // until lowest rising edge:  attach block at low end
        while (j + 1 < c.k and 1 == (c.a[j + 1] - c.a[j])) : (j += 1) {
            c.a[j] = j;
        }
        c.a[j] += 1; // move edge element up
        return true;
    }

    pub fn get(c: *Self) ?[]usize {
        return c.current;
    }
};

const test_data_5_3 = [10][3]usize{
    [_]usize{ 0, 1, 2 },
    [_]usize{ 0, 1, 3 },
    [_]usize{ 0, 2, 3 },
    [_]usize{ 1, 2, 3 },
    [_]usize{ 0, 1, 4 },
    [_]usize{ 0, 2, 4 },
    [_]usize{ 1, 2, 4 },
    [_]usize{ 0, 3, 4 },
    [_]usize{ 1, 3, 4 },
    [_]usize{ 2, 3, 4 },
};

test "5/3 iter api" {
    var buf: [3]usize = undefined;
    var l = CoLex.init(&buf, 5);

    var j: usize = 0;
    while (l.next()) |c| : (j += 1) {
        try std.testing.expectEqualSlices(usize, &test_data_5_3[j], c);
        //std.debug.print("{d}\n", .{c});
    }
    try std.testing.expectEqual(l.next(), null);
}

test "5/3 get/findNext api" {
    var buf: [3]usize = undefined;
    var l = CoLex.init(&buf, 5);

    var j: usize = 0;
    while (l.get()) |c| : ({
        l.findNext();
        j += 1;
    }) {
        try std.testing.expectEqualSlices(usize, &test_data_5_3[j], c);
        //std.debug.print("{d}\n", .{c});
    }

    try std.testing.expectEqual(l.get(), null);
}

test "5/3 hasNext api" {
    var buf: [3]usize = undefined;
    var l = CoLex.init(&buf, 5);

    // visit first combination
    try std.testing.expectEqualSlices(usize, &test_data_5_3[0], &buf);

    var j: usize = 1;
    while (l.hasNext()) : (j += 1) {
        // call hasNext and then visit another
        try std.testing.expectEqualSlices(usize, &test_data_5_3[j], &buf);
    }

    try std.testing.expectEqual(l.get(), null);
}
