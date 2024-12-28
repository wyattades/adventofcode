const std = @import("std");

const VAL_TYPE = u8; // 0-9

const Board = struct {
    grid: std.ArrayList(std.ArrayList(VAL_TYPE)),
    width: usize,
    height: usize,
};

fn parse_input(raw_input: *const []const u8) !Board {
    var grid = std.ArrayList(std.ArrayList(VAL_TYPE)).init(std.heap.page_allocator);

    var lines_iter = std.mem.split(u8, raw_input.*, "\n");
    while (lines_iter.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var list = std.ArrayList(VAL_TYPE).init(std.heap.page_allocator);

        for (line) |c| {
            list.append(c - '0') catch unreachable;
        }

        grid.append(list) catch unreachable;
    }

    const width = grid.items[0].items.len;
    const height = grid.items.len;

    return Board{ .grid = grid, .width = width, .height = height };
}

fn find_paths(board: *const Board, expected_val: VAL_TYPE, x: usize, y: usize, uniq_points: ?*std.AutoHashMap(Point, void)) u32 {
    const actual_val = board.grid.items[y].items[x];
    if (expected_val != actual_val) {
        return 0;
    }

    if (actual_val == 9) {
        if (uniq_points) |p| {
            p.put(Point{ .x = x, .y = y }, {}) catch unreachable;
        }
        return 1;
    }

    // go in all 4 directions (within bounds)
    var sum: u32 = 0;
    if (x > 0) {
        sum += find_paths(board, expected_val + 1, x - 1, y, uniq_points);
    }
    if (x < board.width - 1) {
        sum += find_paths(board, expected_val + 1, x + 1, y, uniq_points);
    }
    if (y > 0) {
        sum += find_paths(board, expected_val + 1, x, y - 1, uniq_points);
    }
    if (y < board.height - 1) {
        sum += find_paths(board, expected_val + 1, x, y + 1, uniq_points);
    }
    return sum;
}

const Point = struct {
    x: usize,
    y: usize,
};

pub fn level_1(raw_input: *const []const u8) !i32 {
    const board = try parse_input(raw_input);

    var answer: i32 = 0;

    for (board.grid.items, 0..) |row, y| {
        for (row.items, 0..) |val, x| {
            if (val == 0) {
                var uniq_points = std.AutoHashMap(Point, void).init(std.heap.page_allocator);
                find_paths(&board, 0, x, y, &uniq_points);
                answer += @intCast(uniq_points.count());
            }
        }
    }

    return answer;
}

pub fn level_2(raw_input: *const []const u8) !i32 {
    const board = try parse_input(raw_input);

    var answer: u32 = 0;

    for (board.grid.items, 0..) |row, y| {
        for (row.items, 0..) |val, x| {
            if (val == 0) {
                answer += find_paths(&board, 0, x, y, null);
            }
        }
    }

    return @intCast(answer);
}
