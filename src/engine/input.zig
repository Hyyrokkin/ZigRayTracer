const std = @import("std");

const input_options = @import("settings").input_options;
const render_infos = @import("renderer").render_infos;

const types = @import("types.zig");
const KeyboardKey = types.KeyboardKey;
const Camera = types.Camera;
const Scene = types.Scene;
const Vector3 = types.Vector3;
const Matrix = types.Marix;

pub fn HandleInput(camera: Camera, scene: Scene) struct { cam: Camera, sce: Scene } {
    var new_pos: Vector3 = Vector3.zero();
    var new_rot: Vector3 = Vector3.zero();

    const elapsed_time = render_infos.GetEplapsedTime();

    if (render_infos.IsKeyDown(KeyboardKey.left)) {
        new_rot = new_rot.add(Vector3.init(0, -input_options.y_axis_rot_speed, 0));
    }
    if (render_infos.IsKeyDown(KeyboardKey.right)) {
        new_rot = new_rot.add(Vector3.init(0, input_options.y_axis_rot_speed, 0));
    }

    if (render_infos.IsKeyDown(KeyboardKey.up)) {
        new_rot = new_rot.add(Vector3.init(input_options.x_axis_rot_speed, 0, 0));
    }
    if (render_infos.IsKeyDown(KeyboardKey.down)) {
        new_rot = new_rot.add(Vector3.init(-input_options.x_axis_rot_speed, 0, 0));
    }

    new_rot = camera.rotation.add(new_rot.scale(elapsed_time));

    if (render_infos.IsKeyDown(KeyboardKey.w)) {
        new_pos = new_pos.add(Vector3.init(0, 0, input_options.z_axis_move_speed));
    }
    if (render_infos.IsKeyDown(KeyboardKey.s)) {
        new_pos = new_pos.add(Vector3.init(0, 0, -input_options.z_axis_move_speed));
    }

    if (render_infos.IsKeyDown(KeyboardKey.a)) {
        new_pos = new_pos.add(Vector3.init(-input_options.x_axis_move_speed, 0, 0));
    }
    if (render_infos.IsKeyDown(KeyboardKey.d)) {
        new_pos = new_pos.add(Vector3.init(input_options.x_axis_move_speed, 0, 0));
    }

    if (render_infos.IsKeyDown(KeyboardKey.space)) {
        new_pos = new_pos.add(Vector3.init(0, input_options.y_axis_move_speed, 0));
    }
    if (render_infos.IsKeyDown(KeyboardKey.left_shift)) {
        new_pos = new_pos.add(Vector3.init(0, -input_options.y_axis_move_speed, 0));
    }

    const rotation_matrix = Matrix.rotateX(camera.rotation.x).multiply(Matrix.rotateY(camera.rotation.y));
    new_pos = camera.position.add(new_pos.scale(elapsed_time).transform(rotation_matrix));

    const new_camera: Camera = .{
        .aspect_ratio = camera.aspect_ratio,
        .far_plane = camera.far_plane,
        .near_plane = camera.near_plane,
        .rotation = new_rot,
        .position = new_pos,
    };

    return .{
        .cam = new_camera,
        .sce = scene,
    };
}
