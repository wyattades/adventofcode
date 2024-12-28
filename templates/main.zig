const std = @import("std");

const VAL_TYPE = u32;

const ParsedInput = struct {
    lists: std.ArrayList(std.ArrayList(VAL_TYPE)),
};

fn parse_input(raw_input: *const []const u8) !ParsedInput {
    var lists = std.ArrayList(std.ArrayList(VAL_TYPE)).init(std.heap.page_allocator);

    return ParsedInput{ .lists = lists };
}

pub fn level_1(raw_input: *const []const u8) !i32 {
    const parsed_input = try parse_input(raw_input);

    var answer: i32 = 0;

    std.debug.print("answer: {d}\n", .{answer});

    return error.NotImplemented;
}

pub fn level_2(raw_input: *const []const u8) !i32 {
    const parsed_input = try parse_input(raw_input);

    var answer: i32 = 0;

    std.debug.print("answer: {d}\n", .{answer});

    return error.NotImplemented;
}
