const std = @import("std");
const allocator = std.heap.page_allocator;

const raylib = @import("raylib");
const render_texture_2d = raylib.RenderTexture2D;
const Rectangle = raylib.Rectangle;
const screen_options = @import("settings").screen_options;

pub fn render(updateFunction: fn () void) !void {
    raylib.initWindow(screen_options.screen_width, screen_options.screen_height, screen_options.window_title);
    defer raylib.closeWindow();

    raylib.setTargetFPS(screen_options.target_fps);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.dark_gray);

        updateFunction();
        try drawFPS();
    }
}

fn drawFPS() !void {
    const current_FPS: i32 = raylib.getFPS();
    const fps_string: []const u8 = try std.fmt.allocPrint(allocator, "{d}", .{current_FPS});
    defer allocator.free(fps_string);

    const fps_with: [:0]const u8 = try std.mem.concatWithSentinel(allocator, u8, &[_][]const u8{fps_string}, 0);
    defer allocator.free(fps_with);

    raylib.drawText(fps_with, 10, 10, 10, raylib.Color.black);
}
