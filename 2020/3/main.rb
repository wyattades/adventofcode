def tree_count(lines, dx, dy)
  x = 0
  y = 0

  count = 0
  while y < lines.length
    line = lines[y]
    char = line.chars[x % line.length]

    # puts [x, y, char].to_s

    count += 1 if char == "#"

    x += dx
    y += dy
  end

  count
end

def level_1
  lines = Utils.get_input_lines

  answer = tree_count(lines, 3, 1)

  Utils.submit_answer(answer)
end

def level_2
  lines = Utils.get_input_lines

  answer = 1

  [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]].each do |dx, dy|
    answer *= tree_count(lines, dx, dy)
  end

  Utils.submit_answer(answer)
end
