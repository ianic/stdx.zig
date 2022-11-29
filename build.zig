const std = @import("std");
const Pkg = std.build.Pkg;

pub const pkgs = struct {
    pub const stdx = Pkg{
        .name = "stdx",
        .source = .{ .path = "src/main.zig" },
    };
};

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("stdx", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const example_step = b.step("examples", "Build examples");
    inline for (.{
        "thread_mpsc",
        "comb_bench",
        "comb_sop_bench",
    }) |example_name| {
        const example = b.addExecutable(example_name, "examples/" ++ example_name ++ ".zig");
        example.addPackage(pkgs.stdx);
        example.setBuildMode(mode);
        example.setTarget(target);
        example.install();
        example_step.dependOn(&example.step);
    }

    // const bench = b.addExecutable("benchmark", "src/comb/benchmark.zig");
    // bench.addPackage(pkgs.stdx);
    // bench.setBuildMode(mode);
    // bench.setTarget(target);
    // bench.install();
    // example_step.dependOn(&bench.step);
}
