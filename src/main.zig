const std = @import("std");
const fs = std.fs;

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_syswm.h");
    @cInclude("SDL2/SDL_version.h");
});

const bgfx = @import("bgfx.zig");

const WNDW_WIDTH = 800;
const WNDW_HEIGHT = 600;

const shapes = enum {
    triangle,
    square,
};

// Change to draw another shape
const shape_to_draw = shapes.triangle;

const PosColorVertex = struct {
    position: [3]f32,
    color: u32,
};

var triangle_vertices = [3]PosColorVertex{
    PosColorVertex{ .position = .{ -0.5, -0.5, 0 }, .color = 0x339933FF },
    PosColorVertex{ .position = .{ 0.5, -0.5, 0 }, .color = 0x993333FF },
    PosColorVertex{ .position = .{ 0.0, 0.5, 0 }, .color = 0x333399FF },
};

const triangle_indices = [3]u16{
    0,
    1,
    2,
};

const square_vertices = [4]PosColorVertex{
    PosColorVertex{ .position = .{ -0.5, -0.5, 0 }, .color = 0x339933FF },
    PosColorVertex{ .position = .{ 0.5, -0.5, 0 }, .color = 0x333399FF },
    PosColorVertex{ .position = .{ -0.5, 0.5, 0 }, .color = 0x993333FF },
    PosColorVertex{ .position = .{ 0.5, 0.5, 0 }, .color = 0x993333FF },
};

const square_indices = [6]u16{
    0, 1, 2,
    3, 2, 1,
};

pub fn main() !void {

    // bgfx.bgfx_init();
    // bgfx.bgfx_reset(800, 600, bgfx.BGFX_RESET_VSYNC);

    // bgfx.bgfx_set_view_clear(0, bgfx.BGFX_CLEAR_COLOR | bgfx.BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0);

    const status = sdl.SDL_Init(0);

    if (status != 0) {
        std.debug.print("Status: {d}\n", .{status});
        sdl.SDL_Log("Unable to init SDL: %s\n", sdl.SDL_GetError());
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "BGFX",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        WNDW_WIDTH,
        WNDW_HEIGHT,
        sdl.SDL_WINDOW_RESIZABLE,
    ).?;

    defer sdl.SDL_DestroyWindow(window);

    var wmi = std.mem.zeroes(sdl.SDL_SysWMinfo);
    wmi.version.major = sdl.SDL_MAJOR_VERSION;
    wmi.version.minor = sdl.SDL_MINOR_VERSION;
    wmi.version.patch = sdl.SDL_PATCHLEVEL;

    const wmi_status = sdl.SDL_GetWindowWMInfo(window, &wmi);
    std.debug.print("WMI Status: {d}\n", .{wmi_status});
    if (wmi_status == sdl.SDL_FALSE) {
        std.debug.panic("Could not set window wm info\n", .{});
    }

    var renderers: [8]bgfx.RendererType = undefined;
    const size = bgfx.getSupportedRenderers(8, &renderers);

    std.debug.print("Available Renderers:\n", .{});
    for (0..size) |i| {
        std.debug.print("\t{d}: {s}\n", .{ i + 1, bgfx.getRendererName(renderers[i]) });
    }

    var init = std.mem.zeroInit(bgfx.Init, .{});
    init.resolution.format = bgfx.TextureFormat.RGBA8;
    const platform = @import("platform").os;

    switch (platform) {
        .macos => {
            std.debug.print("Running on OSX...\n", .{});
            init.type = bgfx.RendererType.Count;
            init.vendorId = bgfx.PciIdFlags_None;
            init.platformData.nwh = wmi.info.cocoa.window;
            init.platformData.ndt = null;
        },
        .windows => {
            init.type = bgfx.RendererType.Count;
            init.platformData.nwh = wmi.info.win.window;
            init.platformData.ndt = null;
        },
        else => {
            std.debug.panic("Running on unsupported OS!\n", .{});
        },
    }

    init.resolution.width = WNDW_WIDTH;
    init.resolution.height = WNDW_HEIGHT;
    init.resolution.reset = bgfx.ResetFlags_None;

    _ = bgfx.renderFrame(0);

    const success = bgfx.init(&init);
    defer bgfx.shutdown();

    if (!success) {
        std.debug.panic("Could not start bgfx\n", .{});
    } else {
        std.debug.print("Initialized bgfx...\n", .{});
    }
    std.debug.print("Using renderer: {s}\n", .{bgfx.getRendererName(bgfx.getRendererType())});
    bgfx.setDebug(bgfx.DebugFlags_Text);

    var frame_number: u64 = 0;

    var color_vertex_layout = std.mem.zeroes(bgfx.VertexLayout);

    color_vertex_layout
        .begin(bgfx.getRendererType())
        .add(bgfx.Attrib.Position, 3, bgfx.AttribType.Float, false, false)
        .add(bgfx.Attrib.Color0, 4, bgfx.AttribType.Uint8, true, false)
        .end();

    var vbffr = std.mem.zeroes(bgfx.VertexBufferHandle);
    var indexBffr = std.mem.zeroes(bgfx.IndexBufferHandle);
    var num_vertices: u32 = 3;
    var num_indices: u32 = 3;

    switch (shape_to_draw) {
        .square => {
            num_vertices = 4;
            num_indices = 6;
            vbffr = bgfx.createVertexBuffer(bgfx.makeRef(&square_vertices, @sizeOf([4]PosColorVertex)), &color_vertex_layout, bgfx.BufferFlags_ComputeRead);
            indexBffr = bgfx.createIndexBuffer(bgfx.makeRef(&square_indices, @sizeOf([6]u16)), bgfx.BufferFlags_ComputeRead);
        },
        .triangle => {
            vbffr = bgfx.createVertexBuffer(bgfx.makeRef(&triangle_vertices, @sizeOf([3]PosColorVertex)), &color_vertex_layout, bgfx.BufferFlags_ComputeRead);
            indexBffr = bgfx.createIndexBuffer(bgfx.makeRef(&triangle_indices, @sizeOf([3]u16)), bgfx.BufferFlags_ComputeRead);
        },
    }
    // VS
    const vs_file_content = @embedFile("compiled/vs_basic");
    const vs_mem = bgfx.copy(vs_file_content, @sizeOf(c_char) * 1000);

    // FS

    const fs_file_content = @embedFile("compiled/fs_basic");
    const fs_mem = bgfx.copy(fs_file_content, @sizeOf(c_char) * 1000);

    // read shader
    const vs_tri = bgfx.createShader(vs_mem);
    const fs_tri = bgfx.createShader(fs_mem);

    const m_program = bgfx.createProgram(vs_tri, fs_tri, false);

    bgfx.setViewClear(0, bgfx.ClearFlags_Color | bgfx.ClearFlags_Depth, 0x443355FF, 1.0, 0);
    bgfx.setViewRect(0, 0, 0, WNDW_WIDTH, WNDW_HEIGHT);

    var should_window_close = false;

    while (!should_window_close) {
        var _event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&_event) != 0) {
            if (_event.type == sdl.SDL_QUIT) should_window_close = true;
        }

        bgfx.setViewRect(0, 0, 0, WNDW_WIDTH, WNDW_HEIGHT);
        bgfx.touch(0);

        bgfx.setState(bgfx.StateFlags_Default, bgfx.StateFlags_WriteR | bgfx.StateFlags_WriteG | bgfx.StateFlags_WriteB | bgfx.StateFlags_WriteA);

        bgfx.setVertexBuffer(0, vbffr, 0, num_vertices);
        bgfx.setIndexBuffer(indexBffr, 0, num_indices);

        bgfx.submit(0, m_program, 1, bgfx.DebugFlags_None);

        frame_number = bgfx.frame(false);
    }
}
