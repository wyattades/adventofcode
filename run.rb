require_relative "utils"

Year = ARGV[0].to_i
Day = ARGV[1].to_i
Level = ARGV[2].to_i

if (2015..2021).exclude?(Year) || (1..25).exclude?(Day) ||
     [1, 2].exclude?(Level)
  raise "Usage: ruby run.rb <year> <day> <level>"
end

require_relative "#{Year}/#{Day}/main.rb"

Object.send("level_#{Level}")
