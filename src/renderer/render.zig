const std = @import("std");
const allocator = std.heap.page_allocator;

const raylib = @import("raylib");
const render_texture_2d = raylib.RenderTexture2D;
const Rectangle = raylib.Rectangle;
const screen_options = @import("settings").screen_options;

pub fn render(updateFunction: fn () void) !void {
    raylib.initWindow(screen_options.screen_width, screen_options.screen_height, "");
    raylib.initWindow(screen_options.screen_width, screen_options.screen_height, "");
    defer raylib.closeWindow();

    raylib.setTargetFPS(screen_options.target_fps);

    const target: render_texture_2d = try raylib.loadRenderTexture(raylib.getScreenWidth(), raylib.getScreenHeight());
    const rec: Rectangle = .{
        .x = 0,
        .y = 0,
        .width = @floatFromInt(target.texture.width),
        .height = @floatFromInt(-target.texture.height),
    };

    while (!raylib.windowShouldClose()) {
        raylib.beginTextureMode(target);
        updateFunction();
        raylib.endTextureMode();

        raylib.beginDrawing();
        defer raylib.endDrawing();

        try redrawWindowTitle();

        raylib.clearBackground(.dark_gray);

        raylib.drawTextureRec(target.texture, rec, raylib.Vector2.init(0, 0), raylib.Color.white);
    }
}

fn redrawWindowTitle() !void {
    const current_FPS: i32 = raylib.getFPS();
    const fps_string: []const u8 = try std.fmt.allocPrint(allocator, "{d}", .{current_FPS});
    defer allocator.free(fps_string);

    const window_title: [:0]const u8 = try std.mem.concatWithSentinel(allocator, u8, &[_][]const u8{ screen_options.window_title_prefix, fps_string, screen_options.window_title_sufix }, 0);
    defer allocator.free(window_title);

    raylib.setWindowTitle(window_title);
}
