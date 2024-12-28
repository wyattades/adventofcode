require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "faraday", "~> 1"
  gem "faraday_middleware", "~> 1"
  gem "pry"
  gem "nokogiri"
  gem "activesupport"
  gem "ostruct"
end
require "active_support"
require "active_support/core_ext"
require "fileutils"
require_relative "langs"

unless File.exist?("session.txt")
  puts "No session ID found! Please create a file named session.txt with your Advent of Code session ID."
  exit 1
end

session_id = File.read("session.txt").strip

AdventRequest =
  Faraday.new(
    url: "https://adventofcode.com",
    headers: {
      Accept:
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "Content-Type": "application/x-www-form-urlencoded",
      Cookie: "session=#{session_id}",
    },
  )

module AdventIo
  extend self

  # ROOT_DIR = File.expand_path("..")

  def src_file(year:, day:)
    files_in_dir = Dir.glob("#{year}/#{day}/*.*")
    files_in_dir.reject! do |f|
      f.end_with?(".txt", ".html", ".json", ".toml", ".lock") ||
        f.start_with?("_")
    end
    return nil, nil if files_in_dir.empty?

    if files_in_dir.size != 1
      raise "Expected exactly one source file in #{year}/#{day}, got: #{files_in_dir.join(", ")}"
    end

    src_file = files_in_dir.sole
    src_file = File.expand_path(src_file)

    file_ext = File.extname(src_file).downcase.delete_prefix(".")
    lang = Langs::EXTENSIONS.fetch(file_ext.to_sym)

    [src_file, lang]
  end

  def get_input(year:, day:)
    dir = "#{year}/#{day}"
    FileUtils.mkdir_p(dir)

    return File.read("#{dir}/input.txt") if File.exist?("#{dir}/input.txt")

    raw_input = AdventRequest.get("/#{year}/day/#{day}/input").body

    File.write("#{year}/#{day}/input.txt", raw_input)

    raw_input
  end

  def submit_answer(
    answer,
    level:,
    year:,
    day:,
    program_duration_ms: nil,
    inner_duration_ms: nil
  )
    puts "Submitting answer for year=#{year} day=#{day} level=#{level}: #{answer.inspect}"

    raise "No answer to submit!" if answer.nil?
    raise "Answer is not a number!" unless answer.is_a?(Numeric)

    File.write(
      "#{year}/#{day}/results-#{level}.json",
      JSON.pretty_generate(
        {
          program_duration_ms: program_duration_ms.round(3),
          inner_duration_ms: inner_duration_ms.round(3),
        },
      ) + "\n",
    )

    # already submitted
    if File.exist?("#{year}/#{day}/answer-#{level}.txt")
      prev_answer = JSON.parse(File.read("#{year}/#{day}/answer-#{level}.txt"))

      if prev_answer == answer
        puts "Already submitted this level!"
      else
        puts "Already submitted this level, but the correct answer is: #{prev_answer}"
      end

      return false
    end

    res =
      AdventRequest.post("/#{year}/day/#{day}/answer") do |req|
        req.body = { level: level, answer: answer }.to_param
      end

    html = res.body || ""
    if html.include?("That's not the right answer")
      if html.include?("your answer is too high.")
        puts "Wrong answer! (too high)"
      elsif html.include?("your answer is too low.")
        puts "Wrong answer! (too low)"
      else
        puts "Wrong answer!"
      end
    elsif html.include?("You gave an answer too recently")
      match = html.match(/You have (?:(\d+)m )?(\d+)s left to wait/)
      m = match&.[](1)&.to_i
      s = match&.[](2)&.to_i
      wait_seconds = m && s ? m * 60 + s : s
      puts "Cooldown in progress (#{wait_seconds || "???"}s remaining)"
    elsif html.include?("That's the right answer!")
      puts "\n\n***    Correct!    ***\n\n"

      File.write("#{year}/#{day}/answer-#{level}.txt", answer.to_s)

      setup_files(year: year, day: day)

      return true
    elsif html.include?("You don't seem to be solving the right level")
      puts "Already submitted this level."
    else
      puts "Unrecognized response! See below.\n"
      puts html
    end

    false
  end

  def setup_files(year:, day:, lang: nil)
    dir = "#{year}/#{day}"
    FileUtils.mkdir_p(dir)

    unless File.exist?("#{dir}/prompt.txt") &&
             File.read("#{dir}/prompt.txt")&.include?("--- Part Two ---")
      res = AdventRequest.get("/#{year}/day/#{day}")

      return false unless res.status == 200

      html = res.body

      document = Nokogiri::HTML.parse(html)

      text = document.css("main article.day-desc > *").map(&:text).join("\n\n")

      File.write("#{dir}/prompt.txt", text)
      File.write("#{dir}/prompt.html", html)

      get_input(year: year, day: day)

      src_file, _existing_lang = src_file(year: year, day: day)
      if src_file.nil?
        if lang.nil?
          rng = Random.new(year * 1000 + day)
          lang = Langs::LANGS.keys.sample(random: rng)
          lang_ext = Array(Langs::LANGS.fetch(lang)).first
        elsif Langs::LANGS.key?(lang)
          lang_ext = Array(Langs::LANGS.fetch(lang)).first
        elsif Langs::EXTENSIONS.key?(lang)
          lang_ext = lang
          lang = Langs::EXTENSIONS.fetch(lang)
        else
          raise "Invalid language specified: #{lang.inspect}"
        end

        puts "Setting up: #{year}/#{day}/main.#{lang_ext} (#{lang})"

        FileUtils.cp("templates/main.#{lang_ext}", "#{dir}/main.#{lang_ext}")
      end
    end

    true
  end

  def parse_cli(argv = ARGV)
    opts = {}
    args = []

    argv.each do |arg|
      if (m = arg.match(/^--(\w+)=(.*)$/))
        opts[m[1].to_sym] = m[2]
      elsif arg.start_with?("-")
        raise "Unknown option: #{arg}"
      else
        args << arg
      end
    end

    [args, opts]
  end
end
