#!/usr/bin/env ruby

require_relative "advent_io"

def as_int(s)
  s.to_i.to_s == s ? s.to_i : nil
end

def parse_args
  args, opts = AdventIo.parse_cli

  year = as_int(args[0])
  day = as_int(args[1]) # optional
  lang = opts[:lang]&.to_sym # optional

  current_year = Time.now.year
  raise "Invalid year: #{year.inspect}" if (2015..current_year).exclude?(year)
  raise "Invalid day: #{day.inspect}" if !day.nil? && (1..25).exclude?(day)

  { year:, day:, lang: }
rescue => err
  warn "Usage: meta/setup.rb <year> [<day>] [--lang=<lang>]"
  warn "  Error: #{err.message}"
  exit(1)
end

year, day, lang = parse_args.values_at(:year, :day, :lang)

if day
  AdventIo.setup_files(year:, day:, lang:)
else
  (1..25).each do |day|
    did_setup = AdventIo.setup_files(year:, day:, lang:)
    break unless did_setup
  end
end
