def level_1(raw_input)
  numbers = Utils.as_numbers(raw_input)

  numbers.each_with_index do |n, i|
    numbers.each_with_index do |m, j|
      if i != j
        if n + m == Year
          answer = n * m
          return answer
        end
      end
    end
  end

  raise "Failed to calculate answer!"
end

def level_2(raw_input)
  numbers = Utils.as_numbers(raw_input)

  numbers.each_with_index do |n, i|
    numbers.each_with_index do |m, j|
      numbers.each_with_index do |l, k|
        if i != j && j != k && i != k
          if n + m + l == Year
            answer = n * m * l
            return answer
          end
        end
      end
    end
  end

  raise "Failed to calculate answer!"
end
