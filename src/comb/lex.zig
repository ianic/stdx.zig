const std = @import("std");

// fxtbook chapter 6.2.1
// Returns set: list of elements indexes.
// The sequence is such that the sets are ordered lexicographically
pub const Lex = struct {
    n: usize,
    k: usize,
    current: []usize,
    no: usize,

    const Self = @This();
    pub fn init(buf: []usize, n: u6) Self {
        var c = Self{
            .n = n,
            .k = buf.len,
            .current = buf,
            .no = 0,
        };
        c.first();
        return c;
    }

    fn first(c: *Self) void {
        var i: usize = 0;
        while (i < c.k) : (i += 1) {
            c.current[i] = i;
        }
    }

    pub fn next(c: *Self) ?[]usize {
        if (c.no == 0 or c.hasNext()) { // current combination is the first
            c.no += 1;
            return c.current;
        }
        return null;
    }

    pub fn hasNext(c: *Self) bool {
        if (c.current[0] == c.n - c.k) { // current combination is the last
            return false;
        }
        var j = c.k - 1;
        // easy case:  highest element != highest possible value:
        if (c.current[j] < (c.n - 1)) {
            c.current[j] += 1;
            return true;
        }

        // find highest falling edge:
        while (1 == (c.current[j] - c.current[j - 1])) {
            j -= 1;
        }

        // move lowest element of highest block up:
        c.current[j - 1] += 1;
        var z = c.current[j - 1];

        // ... and attach rest of block:
        while (j < c.k) : (j += 1) {
            z += 1;
            c.current[j] = z;
        }

        return true;
    }
};

test "3/5" {
    var buf = [_]usize{0} ** 3;
    var l = Lex.init(&buf, 5);

    // while (l.next()) |c| {
    //     std.debug.print("{d} {d}\n", .{ c, l.no });
    // }
    // std.debug.print("{d}\n", .{l.no});

    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 0, 1, 2 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 0, 1, 3 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 0, 1, 4 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 0, 2, 3 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 0, 2, 4 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 0, 3, 4 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 1, 2, 3 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 1, 2, 4 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 1, 3, 4 });
    try std.testing.expectEqualSlices(usize, l.next().?, &[_]usize{ 2, 3, 4 });
    try std.testing.expectEqual(l.next(), null);
}
