const std = @import("std");
const smp = std.heap.smp_allocator;

const engine = @import("engine").engine;
const renderer = @import("renderer").render;

pub fn main() !void {
    try engine.init(smp);
    defer engine.deinit();

    try renderer.render(engine.update);
}
