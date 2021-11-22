def level_1
  answer =
    Utils
      .get_input
      .split("\n\n")
      .select(&:present?)
      .sum { |g| g.split("").select { |c| /^\w$/.match(c) }.uniq.length }

  Utils.submit_answer(answer)
end

def level_2
  answer =
    Utils
      .get_input
      .split("\n\n")
      .select(&:present?)
      .sum do |g|
        users = g.split("\n").map { |u| u.split("") }
        answers = users.flatten.uniq

        answers.count { |c| users.all? { |u| u.include?(c) } }
      end

  Utils.submit_answer(answer)
end
