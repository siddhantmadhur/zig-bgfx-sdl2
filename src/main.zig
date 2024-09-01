const std = @import("std");
const sdl = @cImport(
    @cInclude("SDL2/SDL.h"),
);

pub fn main() !void {
    std.debug.print("Hello, World! \n", .{});

    const status = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    if (status != 0) {
        sdl.SDL_Log("Unable to init SDL: %s\n", sdl.SDL_GetError());
    }
    std.debug.print("Status: {d}", .{status});
    defer sdl.SDL_Quit();

    const screen = sdl.SDL_CreateWindow(
        "My Game",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        400,
        140,
        sdl.SDL_WINDOW_OPENGL,
    );

    defer sdl.SDL_DestroyWindow(screen);

    while (true) {}
}
