def level_1
  numbers = Utils.get_input_numbers

  numbers.each_with_index do |n, i|
    numbers.each_with_index do |m, j|
      if i != j
        if n + m == Year
          Utils.submit_answer(n * m)
          return
        end
      end
    end
  end

  raise "Failed to calculate answer!"
end

def level_2
  numbers = Utils.get_input_numbers

  numbers.each_with_index do |n, i|
    numbers.each_with_index do |m, j|
      numbers.each_with_index do |l, k|
        if i != j && j != k && i != k
          if n + m + l == Year
            Utils.submit_answer(n * m * l)
            return
          end
        end
      end
    end
  end

  raise "Failed to calculate answer!"
end
