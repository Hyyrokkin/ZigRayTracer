const std = @import("std");
const math = std.math;

const renderInfos = @import("renderer").render_infos;
const Color = renderInfos.Color;

const types = @import("types.zig");
const Sceen = types.Scene;
const Camera = types.Camera;
const Sphere = types.Sphere;
const Light = types.Light;
const AmbientLight = types.AmbientLight;
const PointLight = types.PointLight;
const DirectionalLight = types.DirectionalLight;
const Vector3 = types.Vector3;

var test_sceene: Sceen = .{};
var test_camera: Camera = .{};

var active_sceene: Sceen = undefined;
var active_camera: Camera = undefined;

pub fn init(initial_scene: Sceen, initial_camera: Camera) void {
    active_sceene = initial_scene;
    active_camera = initial_camera;
}

pub fn deinit() void {
    active_sceene.deinit();
}

pub fn switchScene(new_scene: Sceen) void {
    active_sceene.deinit();
    active_sceene = new_scene;
}

pub fn switchCamera(new_camera: Camera) void {
    active_camera = new_camera;
}

pub fn update() void {
    var x: i32 = @divTrunc(-renderInfos.getWidthI32(), 2);
    while (x < @divTrunc(renderInfos.getWidthI32(), 2)) : (x += 1) {
        var y: i32 = @divTrunc(-renderInfos.getHeightI32(), 2);
        while (y < @divTrunc(renderInfos.getHeightI32(), 2)) : (y += 1) {
            const dirrection: Vector3 = canvasToViewPort(@floatFromInt(x), @floatFromInt(y));
            const color: Color = TraceRay(active_camera.position, dirrection, active_camera.near_plane, active_camera.far_plane);

            renderInfos.putPixel(x, y, color);
        }
    }
}

fn canvasToViewPort(x: f32, y: f32) Vector3 {
    return Vector3.init(
        x * active_camera.aspect_ratio / renderInfos.getWidthF32(),
        y * 1 / renderInfos.getHeightF32(),
        active_camera.near_plane,
    );
}

fn TraceRay(origin: Vector3, dirrection: Vector3, near_plane: f32, far_plane: f32) Color {
    const res = ClosestIntersection(origin, dirrection, near_plane, far_plane);

    if (res.closest_sphere) |sphere| {
        const hit_point = origin.add(dirrection.scale(res.closest_point));
        const hit_normal = hit_point.subtract(sphere.center).normalize();
        const light_intensity = ComputeLighting(hit_point, hit_normal, dirrection.normalize().scale(-1), sphere.specular);

        return ComputeColorByIntensity(sphere.color, light_intensity);
    }

    return Color.ray_white;
}

fn ClosestIntersection(origin: Vector3, dirrection: Vector3, near_plane: f32, far_plane: f32) struct { closest_sphere: ?Sphere, closest_point: f32 } {
    var closest_point: f32 = std.math.inf(f32);
    var closest_sphere: ?Sphere = null;
    for (active_sceene.spheres.items) |sphere_to_test| {
        const hit_points = IntersectRaySphere(origin, dirrection, sphere_to_test);
        if (near_plane < hit_points.t1 and hit_points.t1 < far_plane and hit_points.t1 < closest_point) {
            closest_point = hit_points.t1;
            closest_sphere = sphere_to_test;
        }
        if (near_plane < hit_points.t2 and hit_points.t2 < far_plane and hit_points.t2 < closest_point) {
            closest_point = hit_points.t2;
            closest_sphere = sphere_to_test;
        }
    }

    return .{
        .closest_sphere = closest_sphere,
        .closest_point = closest_point,
    };
}

fn IntersectRaySphere(origin: Vector3, dirrection: Vector3, sphere: Sphere) struct { t1: f32, t2: f32 } {
    const r: f32 = sphere.radius;
    const sphere_to_origin: Vector3 = origin.subtract(sphere.center);

    const a: f32 = dirrection.dotProduct(dirrection);
    const b: f32 = 2 * sphere_to_origin.dotProduct(dirrection);
    const c: f32 = sphere_to_origin.dotProduct(sphere_to_origin) - r * r;

    const discriminant = b * b - 4 * a * c;
    if (discriminant < 0) {
        return .{
            .t1 = std.math.inf(f32),
            .t2 = std.math.inf(f32),
        };
    }

    return .{
        .t1 = (-b + std.math.sqrt(discriminant)) / (2 * a),
        .t2 = (-b - std.math.sqrt(discriminant)) / (2 * a),
    };
}

fn ComputeLighting(point: Vector3, normal: Vector3, view_vector: Vector3, specular: f32) Vector3 {
    var intensity: Vector3 = Vector3.zero();
    for (active_sceene.lights.items) |light_to_test| {
        switch (light_to_test) {
            .AmbientLight => |al| {
                intensity = intensity.add(al.inensity);
            },
            else => {
                const light_dir: Vector3 = switch (light_to_test) {
                    .PointLight => |pl| pl.position.subtract(point),
                    .DirectionalLight => |dl| dl.direction.normalize(),
                    else => unreachable,
                };

                const light_distance: f32 = switch (light_to_test) {
                    .PointLight => 1,
                    .DirectionalLight => math.inf(f32),
                    else => unreachable,
                };

                const shadow_res = ClosestIntersection(point, light_dir, 0.01, light_distance);
                if (shadow_res.closest_sphere) |sphere| {
                    _ = sphere;
                    continue;
                }

                const light_intensity: Vector3 = switch (light_to_test) {
                    .PointLight => |pl| pl.intensity,
                    .DirectionalLight => |dl| dl.intensity,
                    else => unreachable,
                };

                intensity = intensity.add(ComputeDiffuseLighting(normal, light_dir.normalize(), light_intensity));
                intensity = intensity.add(ComputeSpecularLighting(normal, light_dir.normalize(), light_intensity, view_vector, specular));
            },
        }
    }

    return intensity;
}

fn ComputeDiffuseLighting(normal: Vector3, light_dirrection: Vector3, light_intensity: Vector3) Vector3 {
    const view_intesity: f32 = normal.dotProduct(light_dirrection);
    if (view_intesity > 0) {
        return light_intensity.scale(view_intesity);
    }
    return Vector3.zero();
}

fn ComputeSpecularLighting(normal: Vector3, light_dirrection: Vector3, light_intensity: Vector3, view_vector: Vector3, specular: f32) Vector3 {
    if (specular <= -1) {
        return Vector3.zero();
    }

    const ideal_reflection: Vector3 = normal.scale(2 * normal.dotProduct(light_dirrection)).subtract(light_dirrection).normalize();
    const ideal_reflection_difference: f32 = ideal_reflection.dotProduct(view_vector);
    if (ideal_reflection_difference > 0) {
        return light_intensity.scale(math.pow(f32, ideal_reflection_difference, specular));
    }

    return Vector3.zero();
}

fn ComputeColorByIntensity(color: Color, intensity: Vector3) Color {
    const new_r: u8 = @as(u8, @intFromFloat(@min(255.0, @max(0.0, @as(f32, @floatFromInt(color.r)) * intensity.x))));
    const new_g: u8 = @as(u8, @intFromFloat(@min(255.0, @max(0.0, @as(f32, @floatFromInt(color.g)) * intensity.y))));
    const new_b: u8 = @as(u8, @intFromFloat(@min(255.0, @max(0.0, @as(f32, @floatFromInt(color.b)) * intensity.z))));

    return Color.init(new_r, new_g, new_b, color.a);
}
