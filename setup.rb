require_relative "utils"

Year = ARGV[0].to_i

raise "Usage: ruby setup.rb <year>" if (2015..2021).exclude?(Year)

(1..25).each { |day| break unless Utils.setup_files(year: Year, day: day) }
