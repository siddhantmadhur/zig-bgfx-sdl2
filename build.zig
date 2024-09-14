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

    const platform = b.addOptions();
    platform.addOption(std.Target.Os.Tag, "os", target.result.os.tag);

    //const platform_module = platform.createModule();
    exe.root_module.addOptions("platform", platform);

    switch (target.result.os.tag) {
        .windows => {
            std.debug.print("Building for Windows...\n", .{});
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
            exe.linkSystemLibrary("d3d11");
            exe.linkSystemLibrary("d3d12");
            exe.addLibraryPath(b.path("lib/win/bgfx/"));
            exe.addLibraryPath(b.path("lib/win/SDL/"));
            exe.linkSystemLibrary("SDL2");
        },
        .macos => {
            std.debug.print("Building for MacOS...\n", .{});
            exe.addLibraryPath(b.path("lib/macos"));
            exe.addSystemFrameworkPath(.{ .cwd_relative = "/Library/Frameworks" });
            exe.addRPath(.{ .cwd_relative = "/Library/Frameworks" });
            exe.linkFramework("SDL2");
            exe.linkSystemLibrary("objc");
            exe.linkFramework("Metal");
            exe.linkFramework("QuartzCore");
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            exe.linkFramework("Carbon");
        },
        else => {
            std.debug.print("\nThis project does not contain static libraries for your operating system.\nManually setup the libraries and link them in the build.zig file and they should work.\n\n", .{});
            std.process.exit(1);
        },
    }

    exe.linkSystemLibrary("bxRelease");
    exe.linkSystemLibrary("bimgRelease");
    exe.linkSystemLibrary("bgfxRelease");

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
