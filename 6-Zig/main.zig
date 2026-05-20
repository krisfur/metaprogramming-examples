// Zig's `comptime` collapses the line between "compile-time" and
// "runtime": any normal Zig code can run during compilation if its
// inputs are known then. `@typeInfo` returns a `Type` value the
// compiler hands you, and `inline for` peels the loop at compile time
// so each field access is monomorphized.
//
// This is one generic `toJson` proc; the body specializes per T.
// Add a field to `User`, recompile — no codegen tool, no derive macro.

const std = @import("std");

const User = struct {
    id: u32,
    name: []const u8,
    email: []const u8,
    active: bool,
};

fn toJson(writer: anytype, value: anytype) !void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .@"struct" => |s| {
            try writer.writeByte('{');
            inline for (s.fields, 0..) |field, i| {
                if (i != 0) try writer.writeByte(',');
                try writer.print("\"{s}\":", .{field.name});
                try toJson(writer, @field(value, field.name));
            }
            try writer.writeByte('}');
        },
        .bool => try writer.writeAll(if (value) "true" else "false"),
        .int, .comptime_int => try writer.print("{d}", .{value}),
        .pointer => |p| {
            if (p.size == .slice and p.child == u8) {
                try writer.print("\"{s}\"", .{value});
            } else @compileError("unsupported pointer: " ++ @typeName(T));
        },
        else => @compileError("unsupported type: " ++ @typeName(T)),
    }
}

pub fn main() !void {
    var aw: std.Io.Writer.Allocating = .init(std.heap.smp_allocator);
    defer aw.deinit();

    const u = User{ .id = 42, .name = "alice", .email = "a@x.com", .active = true };
    try toJson(&aw.writer, u);
    std.debug.print("{s}\n", .{aw.written()});
}
