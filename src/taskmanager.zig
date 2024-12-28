const std = @import("std");

const Task = struct {
    description: []const u8,
    completed: bool = false,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        std.debug.print("Usage: taskmanager <command> [options]\n", .{});
        return;
    }

    const command = args[1];

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var tasks = std.ArrayList(Task).init(alloc);
    defer tasks.deinit();

    if (std.mem.eql(u8, command, "add")) {
        if (args.len < 3) {
            std.debug.print("Usage: taskmanager add <description>\n", .{});
            return;
        }
        const description = args[2];
        try tasks.append(.{ .description = description });
        std.debug.print("Task added: {s}\n", .{description});
    } else if (std.mem.eql(u8, command, "list")) {
        if (tasks.items.len == 0) {
            std.debug.print("No tasks available.\n", .{});
            return;
        }
        for (tasks.items, 0..) |*task, index| {
            std.debug.print("{d}. {s} - {s}\n", .{
                index + 1,
                task.description,
                if (task.completed) "Completed" else "Incomplete",
            });
        }
    } else if (std.mem.eql(u8, command, "complete")) {
        if (args.len < 3) {
            std.debug.print("Usage: taskmanager complete <task_number>\n", .{});
            return;
        }
        const task_number = try std.fmt.parseInt(usize, args[2], 10);
        if (task_number == 0 or task_number > tasks.items.len) {
            std.debug.print("Invalid task number.\n", .{});
            return;
        }

        tasks.items[task_number - 1].completed = true;
        std.debug.print("Task {d} marked as completed.\n", .{task_number});
    }
}
