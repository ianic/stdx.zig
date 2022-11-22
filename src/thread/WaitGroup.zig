const std = @import("std");
const Thread = std.Thread;

cnt: isize = 0,
mut: Thread.Mutex = .{},
cond: Thread.Condition = .{},

const Self = @This();

pub fn init() Self {
    return .{};
}

pub fn add(self: *Self, delta: isize) void {
    self.mut.lock();
    defer self.mut.unlock();
    self._add(delta);
}

// private, must be used while mut is locked
fn _add(self: *Self, delta: isize) void {
    self.cnt += delta;
    if (self.cnt < 0) {
        unreachable;
    }
    if (self.cnt == 0)
        self.cond.signal();
}

// done marks one as done
pub fn done(self: *Self) void {
    self.add(-1);
}

// doneIsAllDone marks one as done and returns true if all is done
pub fn doneIsAllDone(self: *Self) bool {
    self.mut.lock();
    defer self.mut.unlock();
    self._add(-1);
    return self.cnt == 0;
}

// wait blocks until counter is zero
pub fn wait(self: *Self) void {
    self.mut.lock();
    defer self.mut.unlock();
    while (self.cnt > 0)
        self.cond.wait(&self.mut);
}
