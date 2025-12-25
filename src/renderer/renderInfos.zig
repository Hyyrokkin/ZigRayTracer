const options = @import("settings").render_options;
const raylib = @import("raylib");
pub const Color = raylib.Color;
pub const Vector3 = raylib.Vector3;

pub fn putPixel(x: i32, y: i32, color: Color) void {
    const corrected_x = @divTrunc(options.screen_width, 2) + x;
    const corrected_y = options.screen_height - (@divTrunc(options.screen_height, 2) + y);
    raylib.drawPixel(corrected_x, corrected_y, color);
}

pub fn getWidthI32() i32 {
    return options.screen_width;
}

pub fn getWidthF32() f32 {
    return @as(f32, @floatFromInt(options.screen_width));
}

pub fn getHeightI32() i32 {
    return options.screen_height;
}

pub fn getHeightF32() f32 {
    return @as(f32, @floatFromInt(options.screen_height));
}

pub fn drawDebug(x: i32, y: i32) void {
    const corrected_x = @divTrunc(options.screen_width, 2) + x;
    const corrected_y = options.screen_height - (@divTrunc(options.screen_height, 2) + y);
    raylib.drawCircle(corrected_x, corrected_y, 10, Color.white);
}
