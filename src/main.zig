const std = @import("std");
const bgfx = @import("bgfx.zig");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_syswm.h");
    @cInclude("SDL2/SDL_version.h");
});

const WNDW_WIDTH = 1280;
const WNDW_HEIGHT = 720;

pub fn main() !void {
    std.debug.print("Hello, World! \n", .{});

    // bgfx.bgfx_init();
    // bgfx.bgfx_reset(800, 600, bgfx.BGFX_RESET_VSYNC);

    // bgfx.bgfx_set_view_clear(0, bgfx.BGFX_CLEAR_COLOR | bgfx.BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0);

    const status = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    if (status != 0) {
        std.debug.print("Status: {d}\n", .{status});
        sdl.SDL_Log("Unable to init SDL: %s\n", sdl.SDL_GetError());
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "My Game",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        WNDW_WIDTH,
        WNDW_HEIGHT,
        sdl.SDL_WINDOW_OPENGL,
    );

    defer sdl.SDL_DestroyWindow(window);

    //var pd = bgfx.PlatformData{};

    var wmi: sdl.SDL_SysWMinfo = undefined;
    wmi.version.major = sdl.SDL_MAJOR_VERSION;
    wmi.version.minor = sdl.SDL_MINOR_VERSION;
    wmi.version.patch = sdl.SDL_PATCHLEVEL;

    if (sdl.SDL_GetWindowWMInfo(window, &wmi) == sdl.SDL_FALSE) {
        std.debug.panic("Could not set window wm info\n", .{});
    }

    var pd = std.mem.zeroes(bgfx.PlatformData);

    pd.ndt = null;
    pd.nwh = wmi.info.win.window;

    pd.context = null;
    pd.backBuffer = null;
    pd.backBufferDS = null;

    bgfx.setPlatformData(&pd);

    var init = std.mem.zeroes(bgfx.Init);
    init.type = bgfx.RendererType.Count;
    init.resolution.width = WNDW_WIDTH;
    init.resolution.height = WNDW_HEIGHT;
    init.resolution.reset = bgfx.ResetFlags_Vsync;
    const success = bgfx.init(&init);
    defer bgfx.shutdown();
    if (!success) {
        std.debug.panic("Could not start bgfx\n", .{});
    }

    bgfx.setViewClear(0, 0x0001 | 0x0002, 0x443355FF, 1.0, 0);
    bgfx.setViewRect(0, 0, 0, WNDW_WIDTH, WNDW_HEIGHT);

    var frame_number: u64 = 0;

    while (true) {
        bgfx.setViewRect(0, 0, 0, WNDW_WIDTH, WNDW_HEIGHT);
        bgfx.touch(0);
        frame_number = bgfx.frame(false);
    }
}
