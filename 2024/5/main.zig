const std = @import("std");

// input pages are always in range [10,99]
const PAGE_TYPE = u8;

const OrderRule = struct {
    bigger: PAGE_TYPE,
    smaller: PAGE_TYPE,
};

const PageIdx = struct {
    idx: usize,
    value: PAGE_TYPE,
};

const ParsedInput = struct {
    pages_lists: std.ArrayList(std.ArrayList(PageIdx)),
    order_rules: std.AutoHashMap(OrderRule, void),
};

fn parse_input(raw_input: *const []const u8) !ParsedInput {
    // var order_rules = std.ArrayList(OrderRule).init(std.heap.page_allocator);
    var order_rules = std.AutoHashMap(OrderRule, void).init(std.heap.page_allocator);

    var pages_lists = std.ArrayList(std.ArrayList(PageIdx)).init(std.heap.page_allocator);

    var lines_iter = std.mem.split(u8, raw_input.*, "\n");
    var parsing_rules = true;
    while (lines_iter.next()) |line| {
        if (line.len == 0) {
            parsing_rules = false;
            continue;
        }
        if (parsing_rules) {
            var parts = std.mem.split(u8, line, "|");
            const biggerStr = parts.next().?;
            const smallerStr = parts.next().?;
            const bigger = try std.fmt.parseInt(PAGE_TYPE, biggerStr, 10);
            const smaller = try std.fmt.parseInt(PAGE_TYPE, smallerStr, 10);
            try order_rules.put(
                OrderRule{ .bigger = bigger, .smaller = smaller },
                {},
            );
        } else {
            var pages = std.ArrayList(PageIdx).init(std.heap.page_allocator);
            var page_iter = std.mem.split(u8, line, ",");
            var idx: usize = 0;
            while (page_iter.next()) |pageStr| {
                const page = try std.fmt.parseInt(PAGE_TYPE, pageStr, 10);
                try pages.append(PageIdx{ .idx = idx, .value = page });
                idx += 1;
            }
            try pages_lists.append(pages);
        }
    }

    return ParsedInput{
        //
        .pages_lists = pages_lists,
        .order_rules = order_rules,
    };
}

fn print_pages(label: []const u8, pages: *const std.ArrayList(PageIdx)) void {
    std.debug.print("{s}: ", .{label});
    for (pages.items) |page| {
        std.debug.print("{d},", .{page.value});
    }
    std.debug.print("\n", .{});
}

fn should_be_lessthan(order_rules: *const std.AutoHashMap(OrderRule, void), lhs: PageIdx, rhs: PageIdx) bool {
    if (order_rules.contains(.{ .bigger = lhs.value, .smaller = rhs.value })) {
        return true;
    }
    if (order_rules.contains(.{ .bigger = rhs.value, .smaller = lhs.value })) {
        return false;
    }

    return lhs.idx < rhs.idx;
}

fn is_valid_order(pages: *const std.ArrayList(PageIdx), order_rules: *const std.AutoHashMap(OrderRule, void)) bool {
    const len = pages.items.len;
    for (0..len) |before_idx| {
        for ((before_idx + 1)..len) |after_idx| {
            const before_page = pages.items[before_idx];
            const after_page = pages.items[after_idx];

            // std.debug.print("{d},{d} ({d},{d})\n", .{ before_page.value, after_page.value, before_idx, after_idx });

            // invalid = `after_page|before_page` exists in rules
            if (order_rules.contains(.{ .bigger = after_page.value, .smaller = before_page.value })) {
                return false;
            }
        }
    }
    return true;
}

pub fn level_1(raw_input: *const []const u8) !u32 {
    const parsed_input = try parse_input(raw_input);
    const pages_lists = parsed_input.pages_lists;
    const order_rules = parsed_input.order_rules;

    var answer: u32 = 0;

    for (pages_lists.items) |pages| {
        const is_valid = is_valid_order(&pages, &order_rules);
        if (is_valid) {
            const middle_value = pages.items[pages.items.len / 2].value;
            answer += middle_value;
        }
    }

    // std.debug.print("answer: {d}\n", .{answer});
    return answer;
    // return error.NotImplemented;
}

pub fn level_2(raw_input: *const []const u8) !u32 {
    const parsed_input = try parse_input(raw_input);
    const pages_lists = parsed_input.pages_lists;
    const order_rules = parsed_input.order_rules;

    var answer: u32 = 0;

    for (pages_lists.items) |pages| {
        const is_valid = is_valid_order(&pages, &order_rules);
        if (!is_valid) {
            // print_pages("pages:", &pages);
            // sort the pages based on the rules
            std.mem.sort(PageIdx, pages.items, &order_rules, should_be_lessthan);
            // print_pages("after", &pages);

            const middle_value = pages.items[pages.items.len / 2].value;
            answer += middle_value;
        }
    }

    // std.debug.print("answer: {d}\n", .{answer});
    return answer;
    // return error.NotImplemented;
}
