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
    exe.linkLibC();
    exe.linkLibCpp();
    exe.addIncludePath(b.path("include"));
    exe.linkSystemLibrary("d3d11");
    exe.linkSystemLibrary("d3d12");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("kernel32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("dxguid");
    exe.linkSystemLibrary("shlwapi");
    exe.linkSystemLibrary("ole32");
    exe.linkSystemLibrary("shcore");
    exe.linkSystemLibrary("avrt");
    exe.linkSystemLibrary("ksuser");
    exe.linkSystemLibrary("dbghelp");

    // TODO: Change to dynamically adding path
    exe.addLibraryPath(b.path("lib/win"));
    exe.addObjectFile(b.path("lib/win/SDL2.dll"));
    exe.linkSystemLibrary("bxRelease");
    exe.linkSystemLibrary("bimgRelease");
    exe.linkSystemLibrary("bgfxRelease");

    exe.linkSystemLibrary("mingw32");

    //exe.linkSystemLibrary("bxRelease");
    //exe.linkSystemLibrary("bimgRelease");
    //exe.linkSystemLibrary("bgfxRelease");

    b.installArtifact(exe);
}
