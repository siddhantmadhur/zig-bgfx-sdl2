const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_syswm.h");
    @cInclude("SDL2/SDL_version.h");
});

const bgfx = @import("bgfx.zig");

const WNDW_WIDTH = 800;
const WNDW_HEIGHT = 600;

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
        0,
    ).?;

    defer sdl.SDL_DestroyWindow(window);

    //var pd = bgfx.PlatformData{};

    var wmi = std.mem.zeroes(sdl.SDL_SysWMinfo);
    wmi.version.major = sdl.SDL_MAJOR_VERSION;
    wmi.version.minor = sdl.SDL_MINOR_VERSION;
    wmi.version.patch = sdl.SDL_PATCHLEVEL;

    const wmi_status = sdl.SDL_GetWindowWMInfo(window, &wmi);
    std.debug.print("WMI Status: {d}\n", .{wmi_status});
    if (wmi_status == sdl.SDL_FALSE) {
        std.debug.panic("Could not set window wm info\n", .{});
    }

    const pd = bgfx.PlatformData{
        .ndt = null,
        .nwh = wmi.info.win.window,
        .context = null,
        .backBuffer = null,
        .backBufferDS = null,
        .type = bgfx.NativeWindowHandleType.Default,
    };

    bgfx.setPlatformData(&pd);

    var renderers: [8]bgfx.RendererType = undefined;
    const size = bgfx.getSupportedRenderers(8, &renderers);

    std.debug.print("Available Renderers:\n", .{});
    for (0..size) |i| {
        std.debug.print("\t{d}: {s}\n", .{ i + 1, bgfx.getRendererName(renderers[i]) });
    }

    var init = std.mem.zeroInit(bgfx.Init, .{});
    init.resolution.format = bgfx.TextureFormat.RGBA8;
    init.resolution.width = WNDW_WIDTH;
    init.resolution.height = WNDW_HEIGHT;
    init.resolution.reset = bgfx.ResetFlags_Vsync;
    init.platformData = pd;
    init.debug = true;
    init.type = bgfx.RendererType.Count;

    const success = bgfx.init(&init);
    defer bgfx.shutdown();

    if (!success) {
        std.debug.panic("Could not start bgfx\n", .{});
    }
    std.debug.print("Using renderer: {s}", .{bgfx.getRendererName(bgfx.getRendererType())});

    bgfx.setDebug(bgfx.DebugFlags_Text);

    bgfx.setViewClear(0, bgfx.ClearFlags_Color | bgfx.ClearFlags_Depth, 0x443355FF, 1.0, 0);
    bgfx.setViewRect(0, 0, 0, WNDW_WIDTH, WNDW_HEIGHT);

    var frame_number: u64 = 0;

    while (true) {
        var _event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&_event) > 0) {}
        bgfx.setViewRect(0, 0, 0, WNDW_WIDTH, WNDW_HEIGHT);
        bgfx.touch(0);
        frame_number = bgfx.frame(true);
    }
}
