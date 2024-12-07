def binary_partition(chars, high_char)
  rowr = [0, 2**(chars.length) - 1]

  (0..(chars.length - 1)).each do |i|
    mid = (rowr[1] - rowr[0]) / 2.0
    if chars[i] == high_char
      rowr[0] = (rowr[0] + mid).ceil
    else
      rowr[1] = (rowr[0] + mid).floor
    end
    puts [chars[i], mid, rowr.to_s].to_s
  end

  raise "Bad #{rowr}" unless rowr[0] == rowr[1]

  rowr[0]
end

def level_1(raw_input)
  lines = Utils.as_lines(raw_input)

  answer =
    lines
      .map do |line|
        chars = line.split("")

        row = binary_partition(chars[0..6], "B")
        col = binary_partition(chars[7..9], "R")

        puts [line, row, col].to_s
        puts "\n\n"

        row * 8 + col
      end
      .max

  answer
end

def level_2(raw_input)
  lines = Utils.as_lines(raw_input)

  seats = Set.new

  lines.map do |line|
    chars = line.split("")

    row = binary_partition(chars[0..6], "B")
    col = binary_partition(chars[7..9], "R")

    seats.add(row * 8 + col)
  end

  (0..128).each do |row|
    (0..6).each do |col|
      id = row * 8 + col
      if !seats.include?(id) && seats.include?(id - 1) && seats.include?(id + 1)
        answer = id
        return answer
      end
    end
  end

  raise "Failed to calculate answer!"
end
