const std = @import("std");

const engine_types = @import("engine").types;
const Scene = engine_types.Scene;
const Camera = engine_types.Camera;
const Sphere = engine_types.Sphere;
const Vector3 = engine_types.Vector3;
const Color = engine_types.Color;
const Light = engine_types.Light;

pub fn getDefaultScene(allocator: std.mem.Allocator) !Scene {
    var default_scene: Scene = .{};

    var sphere_1: Sphere = .{
        .center = Vector3.init(0, -1, 3),
        .color = Color.red,
        .specular = 500,
        .reflective = 0.2,
    };
    var sphere_2: Sphere = .{
        .center = Vector3.init(2, 0, 4),
        .color = Color.blue,
        .specular = 500,
        .reflective = 0.3,
    };
    var sphere_3: Sphere = .{
        .center = Vector3.init(-2, 0, 4),
        .color = Color.green,
        .specular = 10,
        .reflective = 0.4,
    };
    var sphere_4: Sphere = .{
        .radius = 5000,
        .center = Vector3.init(1, -5001, 0),
        .color = Color.yellow,
        .specular = 1000,
        .reflective = 0.05,
    };

    const light_ambient: Light = .{ .AmbientLight = .{
        .inensity = Vector3.init(0.2, 0.2, 0.2),
    } };
    const light_point: Light = .{ .PointLight = .{
        .intensity = Vector3.init(0.6, 0.6, 0.6),
        .position = Vector3.init(2, 1, 0),
    } };
    const light_directional: Light = .{ .DirectionalLight = .{
        .intensity = Vector3.init(0.2, 0.2, 0.2),
        .direction = Vector3.init(1, 4, 4),
    } };

    try default_scene.init(allocator);

    sphere_1.init();
    sphere_2.init();
    sphere_3.init();
    sphere_4.init();

    try default_scene.addSphere(sphere_1);
    try default_scene.addSphere(sphere_2);
    try default_scene.addSphere(sphere_3);
    try default_scene.addSphere(sphere_4);

    try default_scene.addLight(light_ambient);
    try default_scene.addLight(light_point);
    try default_scene.addLight(light_directional);

    return default_scene;
}

pub fn getDefaultCamera(camera_width: f32, camera_height: f32) Camera {
    var deault_camera: Camera = .{};

    deault_camera.init(camera_width, camera_height);

    return deault_camera;
}
