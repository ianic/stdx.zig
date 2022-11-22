const std = @import("std");
const stdx = @import("stdx");

const Mpsc = stdx.thread.Mpsc;
const Thread = std.Thread;
const WaitGroup = stdx.thread.WaitGroup;

const EventTag = enum {
    foo,
    bar,
    signal,
};

const Event = union(EventTag) {
    foo: usize,
    bar: usize,
    signal: usize,
};

const ch = struct {
    var channel = Mpsc(Event, 16){};
    var wg: WaitGroup = .{};

    pub fn recv() ?Event {
        return channel.recv();
    }

    pub fn sendFoo(i: usize) !void {
        try channel.send(.{ .foo = i });
    }
    pub fn sendBar(i: usize) !void {
        try channel.send(.{ .bar = i });
    }
    pub fn sendSignal(i: usize) !void {
        try channel.send(.{ .signal = i });
    }

    pub fn done() void {
        if (wg.doneIsAllDone()) {
            channel.close();
        }
    }
    pub fn close() void {
        channel.close();
    }
};

pub fn main() !void {
    try setSignalHandler();

    ch.wg.add(2); // channel will be closed after 2 dones
    var trd_foo = try Thread.spawn(.{}, runCounter, .{ .{ .send = ch.sendFoo, .done = ch.done }, 300, 10 });
    var trd_bar = try Thread.spawn(.{}, runCounter, .{ .{ .send = ch.sendBar, .done = ch.done }, 600, 10 });

    while (ch.recv()) |event| { // loop unitl channel is closed
        switch (event) {
            .foo => |i| std.debug.print("foo {d}\n", .{i}),
            .bar => |i| std.debug.print("bar {d}\n", .{i}),
            .signal => |i| {
                std.debug.print("signal {d}\n", .{i});
                // can send signal with
                // kill -s USR1 $(pgrep thread_mpsc)
                if (i == std.os.SIG.INT or i == std.os.SIG.TERM) {
                    ch.close();
                }
            },
        }
    }

    Thread.join(trd_foo);
    Thread.join(trd_bar);
}

fn runCounter(c: anytype, sleep: usize, cnt: usize) void {
    defer c.done(); // call done on exit
    var i: usize = 0;
    while (i < cnt) : (i += 1) {
        c.send(i) catch |err| { // try send, exit if channel is closed
            if (err == error.Closed) {
                break;
            }
            unreachable;
        };
        std.time.sleep(sleep * std.time.ns_per_ms);
    }
}

// trap signals
fn setSignalHandler() !void {
    var act = std.os.Sigaction{
        .handler = .{ .handler = sigHandler },
        .mask = std.os.empty_sigset,
        .flags = 0,
    };
    try std.os.sigaction(std.os.SIG.INT, &act, null);
    try std.os.sigaction(std.os.SIG.TERM, &act, null);
    try std.os.sigaction(std.os.SIG.USR1, &act, null);
    try std.os.sigaction(std.os.SIG.USR2, &act, null);
}

fn sigHandler(sig: c_int) callconv(.C) void {
    ch.sendSignal(@intCast(usize, sig)) catch {};
}
