const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.linkLibCpp();
    exe.addIncludePath(b.path("include"));

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

    if (target.result.os.tag == .windows) {
        exe.linkSystemLibrary("d3d11");
        exe.linkSystemLibrary("d3d12");
        exe.addLibraryPath(b.path("lib/win/bgfx/"));
        exe.addLibraryPath(b.path("lib/win/SDL/"));
    } else {
        std.debug.print("\nThis project currently only has libraries for Windows. \nTry compiling the libraries for the platform of your choice and change the build file.\n\n", .{});
        std.process.exit(1);
    }

    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2main");

    exe.linkSystemLibrary("bxRelease");
    exe.linkSystemLibrary("bimgRelease");
    exe.linkSystemLibrary("bgfxRelease");

    //exe.linkSystemLibrary("bxRelease");
    //exe.linkSystemLibrary("bimgRelease");
    //exe.linkSystemLibrary("bgfxRelease");

    b.installArtifact(exe);
}
