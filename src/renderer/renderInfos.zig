const raylib = @import("raylib");
pub const Color = raylib.Color;
pub const Vector3 = raylib.Vector3;
pub const Matrix = raylib.Matrix;
pub const KeyboardKey = raylib.KeyboardKey;
const render_options = @import("settings").render_options;
const screen_options = @import("settings").screen_options;

pub fn putPixel(x: i32, y: i32, color: Color) void {
    const corrected_x = @divTrunc(screen_options.screen_width, 2) + x;
    const corrected_y = screen_options.screen_height - (@divTrunc(screen_options.screen_height, 2) + y);
    raylib.drawPixel(corrected_x, corrected_y, color);
}

pub fn getWidthI32() i32 {
    return screen_options.screen_width;
}

pub fn getWidthF32() f32 {
    return @as(f32, @floatFromInt(screen_options.screen_width));
}

pub fn getHeightI32() i32 {
    return screen_options.screen_height;
}

pub fn getHeightF32() f32 {
    return @as(f32, @floatFromInt(screen_options.screen_height));
}

pub fn drawDebug(x: i32, y: i32) void {
    const corrected_x = @divTrunc(screen_options.screen_width, 2) + x;
    const corrected_y = screen_options.screen_height - (@divTrunc(screen_options.screen_height, 2) + y);
    raylib.drawCircle(corrected_x, corrected_y, 10, Color.white);
}

pub fn getRecursionDepth() u32 {
    return render_options.recursion_deph;
}

pub fn getEpsilon() f32 {
    return render_options.epsilon;
}

pub fn isKeyDown(key: KeyboardKey) bool {
    return raylib.isKeyDown(key);
}

pub fn getEplapsedTime() f32 {
    return raylib.getFrameTime();
}
