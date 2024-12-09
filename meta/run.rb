#!/usr/bin/env ruby

require_relative "advent_io"
require_relative "langs"

Year = ARGV[0].to_i
Day = ARGV[1].to_i
Level = ARGV[2].to_i

current_year = Time.now.year

if (2015..current_year).exclude?(Year) || (1..25).exclude?(Day) ||
     (1..).exclude?(Level)
  warn "Usage: meta/run.rb <year> <day> <level>"
  exit 1
end

src_file, lang = AdventIo.src_file(year: Year, day: Day)

begin
  raw_input = AdventIo.get_input(year: Year, day: Day)
  answer, duration_ms = Langs.send(lang, src_file, raw_input, level: Level)
  AdventIo.submit_answer(
    answer,
    year: Year,
    day: Day,
    level: Level,
    duration_ms: duration_ms,
  )
rescue Langs::LangError => err
  warn("> #{lang} error: #{err.message}")
  exit 1
end
