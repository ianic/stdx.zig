const std = @import("std");
const assert = std.debug.assert;

test "3/5 L" {
    const t = 3;
    const n = 5;
    var c: [t + 2]u8 = undefined;

    // initialize
    var j: u8 = 0;
    while (j < t) : (j += 1) {
        c[j] = j;
    }
    c[j] = n;
    c[j + 1] = 0;

    while (true) {
        // visit
        std.debug.print("{d}\n", .{c[0..t].*});
        // find j
        j = 0;
        while (c[j + 1] == c[j] + 1) {
            c[j] = j;
            j += 1;
        }
        // done?
        if (j == t) break;
        // increase cj
        c[j] += 1;
    }
}

test "3/5 T" {
    const t = 3;
    const n = 5;
    var c: [t + 3]u8 = undefined;

    // initialize
    var j: u8 = 1;
    while (j <= t) : (j += 1) {
        c[j] = j - 1;
    }
    c[t + 1] = n;
    c[t + 2] = 0;
    j = t;
    var x: u8 = 0;

    while (true) {
        // visit
        std.debug.print("{d}\n", .{c[1 .. t + 1].*});

        if (j > 0) {
            //std.debug.print("j = {d}\n", .{j});
            x = j;
            // increase
            c[j] = x;
            j -= 1;
            continue;
        }
        // easy case?
        if (c[1] + 1 < c[2]) {
            c[1] += 1;
            continue; // goto visit
        }
        j = 2;
        // find j
        while (true) {
            c[j - 1] = j - 2;
            x = c[j] + 1;
            if (x != c[j + 1]) break;
            j += 1;
        }
        // done?
        if (j > t) break;
        // increase
        c[j] = x;
        j -= 1;
    }
}
