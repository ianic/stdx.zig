pub const Mpsc = @import("thread/channel.zig").Mpsc;
pub const WaitGroup = @import("thread/WaitGroup.zig");

test {
    _ = @import("thread/channel.zig").Mpsc;
    _ = @import("thread/WaitGroup.zig");
}
