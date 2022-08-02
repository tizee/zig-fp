const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zig-fp", "src/fp.zig");
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTest("src/test_all.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const target = b.standardTargetOptions(.{});
    const bench_range = b.step("bench-range", "Bench range iterator");
    const bench_range_exe = b.addExecutable("bench-range", "bench/range_bench.zig");
    bench_range_exe.addPackagePath("../src/range.zig", "src/range.zig");

    bench_range_exe.setTarget(target);
    bench_range_exe.setBuildMode(mode);
    bench_range_exe.setOutputDir("bench");
    bench_range_exe.single_threaded = true;
    bench_range_exe.install();
    const run_cmd = bench_range_exe.run();
    bench_range.dependOn(&run_cmd.step);
}
