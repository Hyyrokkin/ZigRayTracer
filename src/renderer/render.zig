const std = @import("std");

const raylib = @import("raylib");
const render_texture_2d = raylib.RenderTexture2D;
const Rectangle = raylib.Rectangle;
const screen_options = @import("settings").screen_options;

var alloc: std.mem.Allocator = undefined;

pub fn render(allocator: std.mem.Allocator, updateFunction: fn (*[screen_options.screen_height][screen_options.screen_width]raylib.Color) void) !void {
    alloc = allocator;

    raylib.initWindow(screen_options.screen_width, screen_options.screen_height, screen_options.window_title);
    defer raylib.closeWindow();

    raylib.setTargetFPS(screen_options.target_fps);

    var pixels: [screen_options.screen_height][screen_options.screen_width]raylib.Color = undefined;
    for (pixels, 0..) |inner, y| {
        for (inner, 0..) |_, x| {
            pixels[y][x] = raylib.Color.black;
        }
    }

    const screen_image: raylib.Image = .{
        .data = &pixels,
        .width = screen_options.screen_width,
        .height = screen_options.screen_height,
        .format = raylib.PixelFormat.uncompressed_r8g8b8a8,
        .mipmaps = 1,
    };
    const screen_texture = try raylib.loadTextureFromImage(screen_image);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.dark_gray);

        updateFunction(&pixels);
        raylib.updateTexture(screen_texture, &pixels);

        raylib.drawTexture(screen_texture, 0, 0, raylib.Color.ray_white);

        try drawFPS();
    }
}

fn drawFPS() !void {
    const current_FPS: i32 = raylib.getFPS();
    const fps_string: []const u8 = try std.fmt.allocPrint(alloc, "{d}", .{current_FPS});
    defer alloc.free(fps_string);

    const fps_with: [:0]const u8 = try std.mem.concatWithSentinel(alloc, u8, &[_][]const u8{fps_string}, 0);
    defer alloc.free(fps_with);

    raylib.drawText(fps_with, 10, 10, 20, raylib.Color.black);
}
