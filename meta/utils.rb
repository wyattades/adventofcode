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

module Utils
  class << self
    def get_input(year: Year, day: Day)
      dir = "#{year}/#{day}"
      FileUtils.mkdir_p(dir)

      return File.read("#{dir}/input.txt") if File.exist?("#{dir}/input.txt")

      raw_input = AdventRequest.get("/#{year}/day/#{day}/input").body

      File.write("#{year}/#{day}/input.txt", raw_input)

      raw_input
    end

    def submit_answer(answer, level: Level, year: Year, day: Day)
      puts "Submitting answer for year=#{year} day=#{day} level=#{level}: #{answer}"

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

        Utils.setup_files(year: year, day: day)

        return true
      elsif html.include?("You don't seem to be solving the right level")
        puts "Already submitted this level."
      else
        puts "Unrecognized response! See below.\n"
        puts html
      end

      false
    end

    def get_input_lines(remove_blank: true, **kwargs)
      lines = get_input(**kwargs).split("\n")
      lines.pop if remove_blank && lines.last.blank?
      lines
    end

    def get_input_numbers(**kwargs)
      get_input_lines(**kwargs).map(&:to_i)
    end
    def get_input_number_lists(**kwargs)
      get_input_lines(**kwargs).map { |line| line.split(/\s+/).map(&:to_i) }
    end

    def setup_files(year: Year, day: Day)
      dir = "#{year}/#{day}"
      FileUtils.mkdir_p(dir)

      unless File.exist?("#{dir}/prompt.txt") &&
               File.read("#{dir}/prompt.txt")&.include?("--- Part Two ---")
        res = AdventRequest.get("/#{year}/day/#{day}")

        return false unless res.status == 200

        html = res.body

        document = Nokogiri::HTML.parse(html)

        text =
          document.css("main article.day-desc > *").map(&:text).join("\n\n")

        File.write("#{dir}/prompt.txt", text)
        File.write("#{dir}/prompt.html", html)

        get_input(year: year, day: day)

        unless File.exist?("#{dir}/main.rb")
          FileUtils.cp("meta/template_main.rb", "#{dir}/main.rb")
        end
      end

      true
    end
  end
end
