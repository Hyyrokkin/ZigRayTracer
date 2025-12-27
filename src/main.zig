const std = @import("std");
const smp = std.heap.smp_allocator;

const engine = @import("engine").engine;
const render_infos = @import("renderer").render_infos;
const renderer = @import("renderer").render;
const scene_manager = @import("scenes").scene_manager;

pub fn main() !void {
    const default_scene = try scene_manager.getDefaultScene(smp);
    const default_camera = scene_manager.getDefaultCamera(render_infos.getWidthF32(), render_infos.getHeightF32());

    try engine.init(default_scene, default_camera, smp);
    defer engine.deinit();

    try renderer.render(engine.update);
}
