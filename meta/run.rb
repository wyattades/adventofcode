#!/usr/bin/env ruby

require_relative "advent_io"
require_relative "langs"

def as_int(s)
  s.to_i.to_s == s ? s.to_i : nil
end
def parse_args
  args, _opts = AdventIo.parse_cli

  year = as_int(args[0])
  day = as_int(args[1])
  level = as_int(args[2])

  current_year = Time.now.year
  raise "Invalid year: #{year.inspect}" if (2015..current_year).exclude?(year)
  raise "Invalid day: #{day.inspect}" if (1..25).exclude?(day)
  raise "Invalid level: #{level.inspect}" if (1..2).exclude?(level)

  { year:, day:, level: }
rescue => e
  warn "Usage: meta/run.rb <year> <day> <level>"
  warn "  Error: #{e.message}"
  exit 1
end

year, day, level = parse_args.values_at(:year, :day, :level)

src_file, lang = AdventIo.src_file(year:, day:)

begin
  raw_input = AdventIo.get_input(year:, day:)
  result = Langs.send(lang, src_file, raw_input, level:)
  AdventIo.submit_answer(
    result.dig(:answer),
    year:,
    day:,
    level:,
    program_duration_ms: result.dig(:program_duration_ms),
    inner_duration_ms: result.dig(:inner_duration_ms),
  )
rescue Langs::LangError => err
  warn("> #{lang} error: #{err.message}")
  exit 1
end
