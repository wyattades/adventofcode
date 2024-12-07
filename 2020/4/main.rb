Fields = {
  "byr" => 1920..2002,
  "iyr" => 2010..2020,
  "eyr" => 2020..2030,
  "hgt" =>
    Proc.new do |v|
      m = v&.match(/^(\d+)(cm|in)$/)
      if !m
        false
      elsif m[2] == "cm"
        (150..193).include? m[1].to_i
      else
        (59..76).include? m[1].to_i
      end
    end,
  "hcl" => /^#[0-9a-f]{6}$/,
  "ecl" => /^(amb|blu|brn|gry|grn|hzl|oth)$/,
  "pid" => /^[0-9]{9}$/,
  "cid" => nil,
}

def level_1(raw_input)
  lines = Utils.as_lines(raw_input)

  passports = []
  last_p = nil

  lines.each do |line|
    if line.blank?
      passports << last_p
      last_p = nil
    else
      line
        .split(/\s+/)
        .select(&:present?)
        .each do |ar|
          key, val = ar.split(":")
          (last_p ||= {})[key] = val
        end
    end
  end
  passports << last_p if last_p

  answer =
    passports.count do |passport|
      Fields.all? { |k, v| v == nil || passport[k].present? }
    end

  answer
end

def level_2(raw_input)
  lines = Utils.as_lines(raw_input)

  passports = []
  last_p = nil

  lines.each do |line|
    if line.blank?
      passports << last_p
      last_p = nil
    else
      line
        .split(/\s+/)
        .select(&:present?)
        .each do |ar|
          key, val = ar.split(":")
          (last_p ||= {})[key] = val
        end
    end
  end
  passports << last_p if last_p

  answer =
    passports.count do |passport|
      good =
        Fields.all? do |k, t|
          v = passport[k]
          puts [k, v, t].to_s
          if t == nil
            true
          elsif t.is_a?(Regexp)
            v&.match(t).present?
          elsif t.is_a?(Range)
            v.present? && t.include?(v.to_i)
          elsif t.is_a? Proc
            t.call(v)
          else
            puts "BAD:", [k, v, t].to_s
            false
          end
        end

      puts passport
      puts good
      puts "\n"
      good
    end

  answer
end
