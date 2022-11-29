pub const thread = @import("thread.zig");
pub const comb = @import("comb.zig");

test {
    // Run tests in imported files in `zig build test`
    _ = @import("thread.zig");
    _ = @import("comb.zig");
}
