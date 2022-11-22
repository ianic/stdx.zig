pub const thread = @import("thread.zig");

test {
    // Run tests in imported files in `zig build test`
    _ = @import("thread.zig");
}
