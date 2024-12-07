def level_1(raw_input)
  answer =
    raw_input
      .split("\n\n")
      .select(&:present?)
      .sum { |g| g.split("").select { |c| /^\w$/.match(c) }.uniq.length }

  answer
end

def level_2(raw_input)
  answer =
    raw_input
      .split("\n\n")
      .select(&:present?)
      .sum do |g|
        users = g.split("\n").map { |u| u.split("") }
        answers = users.flatten.uniq

        answers.count { |c| users.all? { |u| u.include?(c) } }
      end

  answer
end
