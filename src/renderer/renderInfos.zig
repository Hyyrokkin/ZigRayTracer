const raylib = @import("raylib");
pub const Color = raylib.Color;
pub const Vector3 = raylib.Vector3;
pub const Matrix = raylib.Matrix;
pub const KeyboardKey = raylib.KeyboardKey;
const render_options = @import("settings").render_options;
const screen_options = @import("settings").screen_options;

pub fn PutPixel(x: i32, y: i32, color: Color) void {
    const corrected_x = @divTrunc(screen_options.screen_width, 2) + x;
    const corrected_y = screen_options.screen_height - (@divTrunc(screen_options.screen_height, 2) + y);
    raylib.drawPixel(corrected_x, corrected_y, color);
}

pub fn GetWidthI32() i32 {
    return screen_options.screen_width;
}

pub fn GetWidthF32() f32 {
    return @as(f32, @floatFromInt(screen_options.screen_width));
}

pub fn GetHeightI32() i32 {
    return screen_options.screen_height;
}

pub fn DetHeightF32() f32 {
    return @as(f32, @floatFromInt(screen_options.screen_height));
}

pub fn DrawDebug(x: i32, y: i32) void {
    const corrected_x = @divTrunc(screen_options.screen_width, 2) + x;
    const corrected_y = screen_options.screen_height - (@divTrunc(screen_options.screen_height, 2) + y);
    raylib.drawCircle(corrected_x, corrected_y, 10, Color.white);
}

pub fn GetRecursionDepth() u32 {
    return render_options.recursion_deph;
}

pub fn GetEpsilon() f32 {
    return render_options.epsilon;
}

pub fn IsKeyDown(key: KeyboardKey) bool {
    return raylib.isKeyDown(key);
}

pub fn GetEplapsedTime() f32 {
    return raylib.getFrameTime();
}
