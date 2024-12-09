const std = @import("std");

const debug = std.debug.print;

const CellValue = enum { Empty, Visited, Obstacle, OutOfBounds };

const Point = struct {
    x: i16,
    y: i16,

    pub fn eql(self: *const Point, other: *const Point) bool {
        return self.x == other.x and self.y == other.y;
    }
};

const Direction = enum(u8) { Right = 0, Up = 1, Left = 2, Down = 3 };

const Grid = struct {
    elements: []CellValue,
    width: u16,
    height: u16,

    guard_pos: Point,
    guard_dir: Direction,

    pub fn get_cell(self: *const Grid, pos: Point) CellValue {
        if (!(pos.x < self.width and pos.y < self.height and pos.x >= 0 and pos.y >= 0)) {
            return CellValue.OutOfBounds;
        }
        return self.elements[@as(u16, @intCast(pos.y)) * self.width + @as(u16, @intCast(pos.x))];
    }
    pub fn set_cell(self: *Grid, pos: Point, value: CellValue) !void {
        if (!(pos.x < self.width and pos.y < self.height and pos.x >= 0 and pos.y >= 0)) {
            return error.OutOfBounds;
        }
        self.elements[@as(u16, @intCast(pos.y)) * self.width + @as(u16, @intCast(pos.x))] = value;
    }
    // pub fn is_in_bounds(self: *const Grid, pos: Point) bool {
    //     return pos.x < self.width and pos.y < self.height and pos.x >= 0 and pos.y >= 0;
    // }

    pub fn clone(self: *const Grid) !Grid {
        var allocator = std.heap.page_allocator;
        return Grid{
            .elements = allocator.dupe(CellValue, self.elements) catch return error.OutOfMemory,
            .width = self.width,
            .height = self.height,
            .guard_pos = self.guard_pos,
            .guard_dir = self.guard_dir,
        };
    }
};

fn get_next_pos(pos: Point, dir: Direction) Point {
    return switch (dir) {
        .Right => Point{ .x = pos.x + 1, .y = pos.y },
        .Up => Point{ .x = pos.x, .y = pos.y - 1 },
        .Left => Point{ .x = pos.x - 1, .y = pos.y },
        .Down => Point{ .x = pos.x, .y = pos.y + 1 },
    };
}
fn clockwise_dir(dir: Direction) Direction {
    return switch (dir) {
        .Right => .Down,
        .Up => .Right,
        .Left => .Up,
        .Down => .Left,
    };
}

fn parse_input(raw_input: *const []const u8) !Grid {
    var lines_iter = std.mem.split(u8, raw_input.*, "\n");
    const first_line = lines_iter.next().?;
    const width = first_line.len;
    const height = raw_input.len / (width + 1); // +1 for the newline

    const size = width * height;
    debug("width: {d}, height: {d}, size: {d}\n", .{ width, height, size });

    var guard_pos: Point = undefined;

    var allocator = std.heap.page_allocator;
    var elements = try allocator.alloc(CellValue, size);
    // defer allocator.free(elements);

    lines_iter.reset();
    var y: usize = 0;
    while (lines_iter.next()) |line| {
        for (line, 0..) |char, x| {
            elements[y * width + x] = switch (char) {
                '.' => CellValue.Empty,
                '^' => CellValue.Visited,
                '#' => CellValue.Obstacle,
                else => return error.InvalidInput,
            };

            if (char == '^') {
                guard_pos = Point{ .x = @intCast(x), .y = @intCast(y) };
            }
        }
        y += 1;
    }

    return Grid{
        .elements = elements,
        .width = @intCast(width),
        .height = @intCast(height),
        .guard_pos = guard_pos,
        .guard_dir = Direction.Up,
    };
}

pub fn level_1(raw_input: *const []const u8) !u32 {
    var grid = try parse_input(raw_input);

    debug("grid: {d}x{d}\n", .{ grid.width, grid.height });
    debug("guard: {}\n", .{grid.guard_pos});

    var guard_pos = grid.guard_pos;
    var guard_dir = grid.guard_dir;

    var visited_count: u32 = 1;
    var move_count: u32 = 0;
    while (true) {
        const next_pos = get_next_pos(guard_pos, guard_dir);

        const cell_value = grid.get_cell(next_pos);
        if (cell_value == CellValue.OutOfBounds) {
            break;
        }

        if (cell_value == CellValue.Obstacle) {
            guard_dir = clockwise_dir(guard_dir);
        } else {
            guard_pos = next_pos;

            move_count += 1;
            if (move_count > 1000000) {
                return error.Timeout;
            }

            if (cell_value != CellValue.Visited) {
                try grid.set_cell(next_pos, CellValue.Visited);
                visited_count += 1;
            }
        }
    }

    debug("visited_count: {d}\n", .{visited_count});

    return visited_count;
}

fn print_grid(grid: *const Grid, guard_pos: Point, guard_dir: Direction) void {
    // clear the screen: \x1B[2J\x1B[H
    debug("\x1b[2J\x1b[H", .{});

    const console_height = 95;

    for (0..@min(grid.height, console_height)) |y| {
        debug("> ", .{});
        for (0..grid.width) |x| {
            const cell = grid.get_cell(Point{ .x = @intCast(x), .y = @intCast(y) });
            var char: u8 = switch (cell) {
                CellValue.Empty => '.',
                CellValue.Visited => '.',
                CellValue.Obstacle => '#',
                else => unreachable,
            };

            if (grid.guard_pos.x == x and grid.guard_pos.y == y) {
                char = 'O';
            }

            if (guard_pos.x == x and guard_pos.y == y) {
                char = switch (guard_dir) {
                    Direction.Right => '>',
                    Direction.Up => '^',
                    Direction.Left => '<',
                    Direction.Down => 'v',
                };
            }

            if (grid.guard_pos.x == guard_pos.x and grid.guard_pos.y == guard_pos.y) {
                std.time.sleep(5000 * std.time.ns_per_ms);
            }

            debug("{c}", .{char});
        }
        debug("\n", .{});
    }

    // sleep for 4ms
    // std.time.sleep(6 * std.time.ns_per_ms);
}

pub fn level_2(raw_input: *const []const u8) !u32 {
    const init_grid = try parse_input(raw_input);

    debug("grid: {d}x{d}\n", .{ init_grid.width, init_grid.height });
    debug("guard: {}\n", .{init_grid.guard_pos});

    var answer: u32 = 0;

    // for each element in the grid:
    for (0..init_grid.width) |x| {
        for (0..init_grid.height) |y| {
            const modified_pos = Point{ .x = @intCast(x), .y = @intCast(y) };

            debug("modified_pos={}\n", .{modified_pos});

            if (modified_pos.eql(&init_grid.guard_pos)) {
                continue;
            }

            var grid = try init_grid.clone();

            try grid.set_cell(modified_pos, CellValue.Obstacle);

            // print_grid(&grid);

            var guard_pos = grid.guard_pos;
            var guard_dir = grid.guard_dir;

            var move_count: u32 = 0;
            while (true) {
                const next_pos = get_next_pos(guard_pos, guard_dir);

                const cell_value = grid.get_cell(next_pos);
                if (cell_value == CellValue.OutOfBounds) {
                    break;
                }

                if (cell_value == CellValue.Obstacle) {
                    guard_dir = clockwise_dir(guard_dir);
                } else {
                    guard_pos = next_pos;

                    move_count += 1;
                    if (move_count > 10000000) {
                        // this works and gives the correct answer!
                        // TODO: why doesn't the guard_pos.eql() check work?
                        answer += 1;
                        break;
                        // return error.Timeout;
                    }
                }

                // an example of a cel that times-out
                // if (modified_pos.x == 3 and modified_pos.y == 52) {
                //     debug("guard_pos={}, guard_dir={}, move_count={d}\n", .{ guard_pos, guard_dir, move_count });
                //     print_grid(&grid, guard_pos, guard_dir);
                // }

                if (guard_dir == grid.guard_dir and guard_pos.eql(&grid.guard_pos)) {
                    debug("answer={d}\n", .{answer});
                    answer += 1;
                    break;
                }
            }
        }
    }

    return answer;
}
