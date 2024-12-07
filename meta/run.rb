#!/usr/bin/env ruby

require_relative "utils"

Year = ARGV[0].to_i
Day = ARGV[1].to_i
Level = ARGV[2].to_i

current_year = Time.now.year

if (2015..current_year).exclude?(Year) || (1..25).exclude?(Day) ||
     (1..).exclude?(Level)
  warn "Usage: meta/run.rb <year> <day> <level>"
  exit 1
end

require_relative "../#{Year}/#{Day}/main.rb"

method = Object.method(:"level_#{Level}")
answer =
  if method.arity.zero?
    method.call
  else
    method.call(Utils.get_input(year: Year, day: Day))
  end
Utils.submit_answer(answer) unless answer.nil?
