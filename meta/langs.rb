require "json"
require "open3"

module Langs
  extend self

  LANGS = {
    ruby: :rb,
    python: :py,
    bun: %i[ts js mjs cjs],
    # rs: :rust,
    # go: :golang,
    # dart: :dart,
    # swift: :swift,
    # zig: :zig,
    # ex: :elixir,
  }
  EXTENSIONS =
    LANGS.each_with_object({}) do |(lang, exts), acc|
      Array(exts).each { |ext| acc[ext] = lang }
    end

  def ruby(src_file, raw_input, level:)
    require_relative "../utils/utils.rb"
    require src_file
    answer = Object.send(:"level_#{level}", raw_input)
    answer
  end

  def python(src_file, raw_input, level:)
    python_code = <<~PYTHON
      import json
      import sys
      from #{File.basename(src_file, ".py")} import level_#{level} as level_fn

      input_data = sys.argv[1]
      result = level_fn(input_data)
      print(json.dumps({"answer": result}))
    PYTHON

    run_lang("python3", "-c", python_code, raw_input)
  end

  def bun(src_file, raw_input, level:)
    ts_code = <<~JAVASCRIPT
      import { level_#{level} as levelFn } from "#{File.basename(src_file)}";

      const result = await levelFn(input);
      console.log(JSON.stringify({ answer: result }));
    JAVASCRIPT

    run_lang("bun", "-c", ts_code, raw_input)
  end

  # private
  def run_lang(*args)
    Open3.popen3(*args) do |_stdin, stdout, stderr, wait_thr|
      Thread.new do
        while line = stderr.gets
          $stderr.puts(line)
        end
      end

      answer = nil
      while line = stdout.gets
        if line.start_with?("{") && line.include?('"answer":')
          answer = JSON.parse(line.strip).fetch("answer")
        else
          $stdout.puts(line)
        end
      end

      raise "Script execution failed" unless wait_thr.value.success?
      raise "No answer found in output" if answer.nil?

      answer
    end
  end
end