const std = @import("std");
const allocator = std.heap.page_allocator;

const raylib = @import("raylib");
const render_options = @import("settings").render_options;

pub fn render(updateFunction: fn () void) !void {
    raylib.initWindow(render_options.screen_width, render_options.screen_height, "");
    defer raylib.closeWindow();

    raylib.setTargetFPS(render_options.target_fps);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        try redrawWindowTitle();

        raylib.clearBackground(.dark_gray);

        updateFunction();
    }
}

fn redrawWindowTitle() !void {
    const current_FPS: i32 = raylib.getFPS();
    const fps_string: []const u8 = try std.fmt.allocPrint(allocator, "{d}", .{current_FPS});
    defer allocator.free(fps_string);

    const window_title: [:0]const u8 = try std.mem.concatWithSentinel(allocator, u8, &[_][]const u8{ render_options.window_title_prefix, fps_string, render_options.window_title_sufix }, 0);
    defer allocator.free(window_title);

    raylib.setWindowTitle(window_title);
}
