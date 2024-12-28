const std = @import("std");

const Task = struct {
    description: []const u8,
    completed: bool = false,

    pub fn deinit(self: *Task, allocator: std.mem.Allocator) void {
        allocator.free(self.description);
    }
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

    defer {
        for (tasks.items) |*task| {
            task.deinit(alloc);
        }
        tasks.deinit();
    }

    const tasks_file = "tasks.txt";
    loadTasks(&tasks, alloc, tasks_file) catch |err| {
        std.debug.print("Failed to load tasks: {}\n", .{err});
    };

    if (std.mem.eql(u8, command, "add")) {
        if (args.len < 3) {
            std.debug.print("Usage: taskmanager add <description>\n", .{});
            return;
        }
        const description = try alloc.dupe(u8, args[2]);
        try tasks.append(.{ .description = description });
        std.debug.print("Task added: {s}\n", .{description});
    } else if (std.mem.eql(u8, command, "list")) {
        if (tasks.items.len == 0) {
            std.debug.print("No tasks available.\n", .{});
            return;
        }
        for (tasks.items, 0..) |task, index| {
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
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
        return;
    }

    saveTasks(tasks.items, tasks_file) catch |err| {
        std.debug.print("Failed to save tasks: {}\n", .{err});
    };
}

fn loadTasks(tasks: *std.ArrayList(Task), allocator: std.mem.Allocator, filename: []const u8) !void {
    const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
        if (err == error.FileNotFound) {
            return;
        }
        return err;
    };
    defer file.close();

    const reader = file.reader();
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) continue;
        const completed = line[0] == '1';
        const description = try allocator.dupe(u8, line[2..]);
        try tasks.append(.{
            .description = description,
            .completed = completed,
        });
    }
}

fn saveTasks(tasks_items: []const Task, filename: []const u8) !void {
    const file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    const writer = file.writer();
    for (tasks_items) |task| {
        try writer.print("{d} {s}\n", .{
            @as(u8, if (task.completed) 1 else 0),
            task.description,
        });
    }
}
