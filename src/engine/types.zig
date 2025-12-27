const std = @import("std");
const ArrayList = std.ArrayList;

const renderInfos = @import("renderer").render_infos;
pub const Vector3 = renderInfos.Vector3;
pub const Color = renderInfos.Color;

pub const Scene = struct {
    spheres: ArrayList(Sphere) = .empty,
    lights: ArrayList(Light) = .empty,
    allocator: std.mem.Allocator = undefined,

    pub fn init(self: *Scene, alloc: std.mem.Allocator) !void {
        self.allocator = alloc;
    }
    pub fn deinit(self: *Scene) void {
        self.spheres.deinit(self.allocator);
        self.lights.deinit(self.allocator);
    }
    pub fn addSphere(self: *Scene, sphere: Sphere) !void {
        try self.spheres.append(self.allocator, sphere);
    }
    pub fn addLight(self: *Scene, light: Light) !void {
        try self.lights.append(self.allocator, light);
    }
};

pub const Sphere = struct {
    center: Vector3,
    radius: f32 = 1,
    color: Color = Color.white,
    specular: f32 = 0,
};

pub const Camera = struct {
    position: Vector3 = Vector3.init(0, 0, 0),
    direction: Vector3 = Vector3.init(0, 0, 1),
    aspect_ratio: f32 = 1,
    near_plane: f32 = 1,
    far_plane: f32 = std.math.inf(f32),

    pub fn init(self: *Camera, width: f32, height: f32) void {
        self.aspect_ratio = width / height;
    }
};

pub const AmbientLight = struct {
    inensity: Vector3,
};

pub const PointLight = struct {
    intensity: Vector3,
    position: Vector3,
};

pub const DirectionalLight = struct {
    intensity: Vector3,
    direction: Vector3,
};

pub const Light = union(enum) {
    AmbientLight: AmbientLight,
    PointLight: PointLight,
    DirectionalLight: DirectionalLight,
};
