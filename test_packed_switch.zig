const S = packed struct {
    a: u12,
    b: u6,
    c: i14,
};

const Auto = struct {
    a: u16,
    b: u32,
};

// comptime {
//     const auto = Auto{ .a = 0, .b = 1 };
//     switch (auto) {
//         .{ .a = 0, .b = 1 } => @compileLog("here"),
//         else => @compileLog("there"),
//     }
// }

comptime {
    const op = std.builtin.AtomicRmwOp.Sub;
    const res = sw: switch (op) {
        .Sub => continue :sw .Add,
        .Add => true,
        else => false,
    };
    std.debug.assert(res);
}

// const Z = packed struct {
//     a: u9,
//     b: u7,

//     pub fn foo(z: Z) bool {
//         return sw: switch (z) {
//             Z{ .a = 0, .b = 1 } => true,
//             Z{ .a = 1, .b = 0 } => false,
//             else => continue :sw .{ .a = 0, .b = 1 },
//         };
//     }
// };

// comptime {
//     const z = Z{ .a = 0, .b = 1 };
//     @compileLog(z.foo());
// }

fn implicitCaseType(s: S) void {
    switch (s) {
        .{ .a = 0, .b = 1, .c = 2 } => std.debug.print("here\n", .{}),
        else => std.debug.print("there\n", .{}),
    }
}

fn explicitCaseType(s: S) void {
    switch (s) {
        S{ .a = 0, .b = 1, .c = 2 } => std.debug.print("here\n", .{}),
        else => std.debug.print("there\n", .{}),
    }
}

const P = packed struct(u2) {
    a: u1,
    b: u1,
};

fn inlineCases(p: P) void {
    switch (p) {
        inline else => |val| std.debug.print("{any}:{any}\n", .{ val, @TypeOf(val) }),
    }
    switch (p) {
        inline else => |*val| std.debug.print("{any}:{any}\n", .{ val.*, @TypeOf(val) }),
    }
}

fn elseType(p: P) void {
    switch (p) {
        else => |val| std.debug.print("{any}:{any}\n", .{ val, @TypeOf(val) }),
    }
    switch (p) {
        else => |*val| std.debug.print("{any}:{any}\n", .{ val.*, @TypeOf(val) }),
    }
    sw: switch (p) {
        .{ .a = 0, .b = 1 } => continue :sw .{ .a = 1, .b = 0 },
        else => |val| std.debug.print("{any}:{any}\n", .{ val, @TypeOf(val) }),
    }
    sw: switch (p) {
        .{ .a = 0, .b = 1 } => continue :sw .{ .a = 1, .b = 0 },
        else => |*val| std.debug.print("{any}:{any}\n", .{ val.*, @TypeOf(val) }),
    }
}

// comptime {
//     const p = P{ .a = 0, .b = 1 };
//     switch (p) {
//         inline else => |val| @compileLog(@TypeOf(val)),
//     }
//     switch (p) {
//         .{ .a = 1, .b = 1 } => unreachable,
//         inline else => |val| @compileLog(@TypeOf(val)),
//     }
//     sw: switch (p) {
//         .{ .a = 0, .b = 1 } => continue :sw .{ .a = 0, .b = 0 },
//         .{ .a = 1, .b = 1 } => unreachable,
//         inline else => |val| @compileLog(@TypeOf(val)),
//     }
// }

const E = enum(u8) {
    bar = 3,
    _,

    const foo: E = @enumFromInt(0xa);
};

fn declLiteralRepro() void {
    var e: E = .foo;
    _ = &e;
    switch (e) {
        .bar => {},
        .foo => {},
        else => {},
    }
}

const std = @import("std");

test declLiteralRepro {
    declLiteralRepro();
}

test implicitCaseType {
    implicitCaseType(.{ .a = 0, .b = 1, .c = 2 });
    implicitCaseType(.{ .a = 5, .b = 2, .c = 8 });
}

test explicitCaseType {
    explicitCaseType(.{ .a = 0, .b = 1, .c = 2 });
    explicitCaseType(.{ .a = 5, .b = 2, .c = 8 });
}

test inlineCases {
    inlineCases(.{ .a = 0, .b = 1 });
    inlineCases(.{ .a = 1, .b = 0 });
}

test elseType {
    elseType(.{ .a = 0, .b = 1 });
    elseType(.{ .a = 1, .b = 0 });
}
