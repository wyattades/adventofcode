def level_1
  lines = Utils.get_input_lines

  answer =
    lines.count do |line|
      m = line.match(/^(\d+)-(\d+)\s+(\w):\s+(\w+)$/)
      min = m[1].to_i
      max = m[2].to_i
      char = m[3]
      password = m[4]

      chars = password.split("")

      count = chars.count { |b| b == char }

      puts [min, max, char, password, count].to_s

      count >= min && count <= max
    end

  Utils.submit_answer(answer)
end

def level_2
  lines = Utils.get_input_lines

  answer =
    lines.count do |line|
      m = line.match(/^(\d+)-(\d+)\s+(\w):\s+(\w+)$/)
      min = m[1].to_i - 1
      max = m[2].to_i - 1
      char = m[3]
      password = m[4]

      chars = password.split("")

      count =
        chars.each_with_index.count do |c, i|
          (min == i && c == char) || (max === i && c == char)
        end

      puts [min, max, char, password, count].to_s

      count == 1
    end

  Utils.submit_answer(answer)
end
