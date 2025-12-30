const std = @import("std");
const math = std.math;

const renderInfos = @import("renderer").render_infos;
const Color = renderInfos.Color;

const input = @import("input.zig");
const types = @import("types.zig");
const Sceen = types.Scene;
const Camera = types.Camera;
const Sphere = types.Sphere;
const Light = types.Light;
const AmbientLight = types.AmbientLight;
const PointLight = types.PointLight;
const DirectionalLight = types.DirectionalLight;
const Vector3 = types.Vector3;
const Matrix = types.Marix;

const epsilon = renderInfos.getEpsilon();

var active_sceene: Sceen = undefined;
var active_camera: Camera = undefined;

pub fn init(initial_scene: Sceen, initial_camera: Camera) !void {
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
    const updated_info = input.HandleInput(active_camera, active_sceene);
    active_camera = updated_info.cam;
    active_sceene = updated_info.sce;

    const rotation_matrix = Matrix.rotateX(active_camera.rotation.x).multiply(Matrix.rotateY(active_camera.rotation.y));

    var x: i32 = @divTrunc(-renderInfos.getWidthI32(), 2);
    while (x < @divTrunc(renderInfos.getWidthI32(), 2)) : (x += 1) {
        var y: i32 = @divTrunc(-renderInfos.getHeightI32(), 2);
        while (y < @divTrunc(renderInfos.getHeightI32(), 2)) : (y += 1) {
            const dirrection: Vector3 = canvasToViewPort(@floatFromInt(x), @floatFromInt(y)).transform(rotation_matrix);
            const color: Color = traceRay(active_camera.position, dirrection, active_camera.near_plane, active_camera.far_plane, renderInfos.getRecursionDepth());

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

fn traceRay(origin: Vector3, dirrection: Vector3, near_plane: f32, far_plane: f32, recursion_depth: u32) Color {
    const res = closestIntersection(origin, dirrection, near_plane, far_plane);

    if (res.closest_sphere) |sphere| {
        const hit_point = origin.add(dirrection.scale(res.closest_point));
        const hit_normal = hit_point.subtract(sphere.center).normalize();
        const light_intensity = computeLighting(hit_point, hit_normal, dirrection.normalize().scale(-1), sphere.specular);

        const local_color: Color = computeColorByIntensity(sphere.color, light_intensity);
        const local_reflecivity: f32 = sphere.reflective;
        if (recursion_depth <= 0 or local_reflecivity <= 0) {
            return local_color;
        }

        const reflected_ray: Vector3 = dirrection.reflect(hit_normal);
        const reflected_color: Color = traceRay(hit_point, reflected_ray, epsilon, math.inf(f32), recursion_depth - 1);

        const final_color: Color = mixColorsByRatio(local_color, reflected_color, local_reflecivity);
        return final_color;
    }

    return Color.ray_white;
}

fn closestIntersection(origin: Vector3, dirrection: Vector3, near_plane: f32, far_plane: f32) struct { closest_sphere: ?Sphere, closest_point: f32 } {
    var closest_point: f32 = std.math.inf(f32);
    var closest_sphere: ?Sphere = null;
    for (active_sceene.spheres.items) |sphere_to_test| {
        const hit_points = intersectRaySphere(origin, dirrection, sphere_to_test);
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

fn intersectRaySphere(origin: Vector3, dirrection: Vector3, sphere: Sphere) struct { t1: f32, t2: f32 } {
    const r_squared: f32 = sphere.radius_squared;
    const sphere_to_origin: Vector3 = origin.subtract(sphere.center);

    const a: f32 = dirrection.dotProduct(dirrection);
    const b: f32 = 2 * sphere_to_origin.dotProduct(dirrection);
    const c: f32 = sphere_to_origin.dotProduct(sphere_to_origin) - r_squared;

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

fn computeLighting(point: Vector3, normal: Vector3, view_vector: Vector3, specular: f32) Vector3 {
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

                const shadow_res = closestIntersection(point, light_dir, epsilon, light_distance);
                if (shadow_res.closest_sphere) |sphere| {
                    _ = sphere;
                    continue;
                }

                const light_intensity: Vector3 = switch (light_to_test) {
                    .PointLight => |pl| pl.intensity,
                    .DirectionalLight => |dl| dl.intensity,
                    else => unreachable,
                };

                intensity = intensity.add(computeDiffuseLighting(normal, light_dir.normalize(), light_intensity));
                intensity = intensity.add(computeSpecularLighting(normal, light_dir.normalize(), light_intensity, view_vector, specular));
            },
        }
    }

    return intensity;
}

fn computeDiffuseLighting(normal: Vector3, light_dirrection: Vector3, light_intensity: Vector3) Vector3 {
    const view_intesity: f32 = normal.dotProduct(light_dirrection);
    if (view_intesity > 0) {
        return light_intensity.scale(view_intesity);
    }
    return Vector3.zero();
}

fn computeSpecularLighting(normal: Vector3, light_dirrection: Vector3, light_intensity: Vector3, view_vector: Vector3, specular: f32) Vector3 {
    if (specular <= -1) {
        return Vector3.zero();
    }

    const ideal_reflection: Vector3 = light_dirrection.reflect(normal);
    const ideal_reflection_difference: f32 = ideal_reflection.dotProduct(view_vector);
    if (ideal_reflection_difference > 0) {
        return light_intensity.scale(math.pow(f32, ideal_reflection_difference, specular));
    }

    return Vector3.zero();
}

fn computeColorByIntensity(color: Color, intensity: Vector3) Color {
    const new_r: u8 = clampToU8(@as(f32, @floatFromInt(color.r)) * intensity.x);
    const new_g: u8 = clampToU8(@as(f32, @floatFromInt(color.g)) * intensity.y);
    const new_b: u8 = clampToU8(@as(f32, @floatFromInt(color.b)) * intensity.z);

    return Color.init(new_r, new_g, new_b, color.a);
}

fn mixColorsByRatio(color_a: Color, color_b: Color, raio: f32) Color {
    const a_r: f32 = @as(f32, @floatFromInt(color_a.r));
    const a_g: f32 = @as(f32, @floatFromInt(color_a.g));
    const a_b: f32 = @as(f32, @floatFromInt(color_a.b));
    const a_a: f32 = @as(f32, @floatFromInt(color_a.a));

    const b_r: f32 = @as(f32, @floatFromInt(color_b.r));
    const b_g: f32 = @as(f32, @floatFromInt(color_b.g));
    const b_b: f32 = @as(f32, @floatFromInt(color_b.b));
    const b_a: f32 = @as(f32, @floatFromInt(color_b.a));

    const new_r: f32 = a_r * (1 - raio) + b_r * raio;
    const new_g: f32 = a_g * (1 - raio) + b_g * raio;
    const new_b: f32 = a_b * (1 - raio) + b_b * raio;
    const new_a: f32 = a_a * (1 - raio) + b_a * raio;

    return Color.init(clampToU8(new_r), clampToU8(new_g), clampToU8(new_b), clampToU8(new_a));
}

fn clampToU8(in: f32) u8 {
    return @as(u8, @intFromFloat(@min(255.0, @max(0.0, in))));
}
