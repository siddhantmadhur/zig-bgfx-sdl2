const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "temp",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.use_lld = true;

    //exe.linkLibC();
    exe.linkLibCpp();
    exe.addIncludePath(b.path("include"));
    exe.linkSystemLibrary("d3d11");
    exe.addObjectFile(b.path("lib/SDL2.dll"));

    exe.addLibraryPath(b.path("lib/"));
    exe.linkSystemLibrary("bxRelease");
    exe.linkSystemLibrary("bimgRelease");
    exe.linkSystemLibrary("bgfxRelease");

    exe.linkSystemLibrary("kernel32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");

    b.installArtifact(exe);
}
