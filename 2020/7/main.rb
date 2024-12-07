def parse_rules(raw_input)
  lines = Utils.as_lines(raw_input)

  lines.to_h do |line|
    m = line.match(/^(\w+ \w+) bags? contain (.+?)\.$/)
    bag = m[1]
    children =
      if m[2] == "no other bags"
        {}
      else
        m[2]
          .split(", ")
          .to_h do |c|
            n = c.match(/(\d+) (\w+ \w+) bags?/)
            count = n[1].to_i
            child_bag = n[2]
            [child_bag, count]
          end
      end

    [bag, children]
  end
end

def level_1(raw_input)
  rules = parse_rules(raw_input)

  counts = {}

  occurences =
    Proc.new do |bag|
      next counts[bag] if counts.key?(bag)

      count =
        rules[bag].any? do |child_bag, _count|
          child_bag == "shiny gold" ? true : occurences.call(child_bag)
        end

      counts[bag] = count
    end

  answer = rules.count { |bag, _rule| occurences.call(bag) }

  answer
end

def level_2(raw_input)
  rules = parse_rules(raw_input)

  counts = {}

  occurences =
    Proc.new do |bag|
      next counts[bag] if counts.key?(bag)

      count =
        rules[bag].sum do |child_bag, amount|
          amount * occurences.call(child_bag)
        end

      counts[bag] = count + 1
    end

  answer = occurences.call("shiny gold") - 1

  answer
end
