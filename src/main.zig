pub const thread = @import("thread.zig");
pub const comb = @import("comb.zig");

test {
    // Run tests in imported files in `zig build test`
    _ = @import("thread.zig");
    _ = @import("comb.zig");
}

const std = @import("std");

pub fn bench(name: []const u8, runs: usize, handler: *const fn () anyerror!void) !void {
    const start = std.time.nanoTimestamp();
    var rns = runs;
    while (rns > 0) : (rns -= 1) {
        try handler();
    }
    const duration = std.time.nanoTimestamp() - start;

    const nsop = @intCast(u64, duration) / @intCast(u64, runs);
    std.debug.print("{s:<25} duration: {d}ns {d:.4}s {d} ns/op\n", .{
        name,
        duration,
        @intToFloat(f64, duration) / @intToFloat(f64, std.time.ns_per_s),
        nsop,
    });
}
