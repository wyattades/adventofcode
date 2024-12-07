#!/usr/bin/env ruby

require_relative "advent_io"

Year = ARGV[0].to_i

if (2015..).exclude?(Year)
  warn "Usage: meta/setup.rb <year>"
  exit 1
end

(1..25).each do |day|
  did_setup = AdventIo.setup_files(year: Year, day: day)
  break unless did_setup
end
