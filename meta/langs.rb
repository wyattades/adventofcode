require "json"
require "open3"

module Langs
  extend self

  LANGS = {
    ruby: :rb,
    python: :py,
    bun: %i[ts js mjs cjs],
    zig: :zig,
    rust: :rs,
    elixir: :ex,
    # golang: :go,
    # dart: :dart,
    # swift: :swift,
    # csharp: :cs,
    # java: :java,
    # kotlin: :kt,
    # c: :c,
    # cpp: :cpp,
  }
  EXTENSIONS =
    LANGS.each_with_object({}) do |(lang, exts), acc|
      Array(exts).each { |ext| acc[ext] = lang }
    end

  def ruby(src_file, raw_input, level:)
    require_relative "../utils/utils.rb"
    require src_file
    answer = nil
    duration_s =
      Benchmark.realtime { answer = Object.send(:"level_#{level}", raw_input) }
    duration_ms = duration_s * 1000.0
    {
      answer:,
      program_duration_ms: duration_ms,
      inner_duration_ms: duration_ms,
    }
  end

  def python(src_file, raw_input, level:)
    python_code = <<~PYTHON
      import json
      import sys
      import time
      sys.path.append(#{File.dirname(src_file).to_json})
      from #{File.basename(src_file, ".py")} import level_#{level} as level_fn

      input_data = sys.argv[1]

      start = time.time()
      answer = None
      try:
        answer = level_fn(input_data)
      finally:
        duration_ms = time.time() - start
        print(json.dumps({"answer": answer, "duration_ms": duration_ms}))
    PYTHON

    run_lang("python3", "-c", python_code, raw_input)
  end

  def bun(src_file, raw_input, level:)
    ts_code = <<~JAVASCRIPT
      import { level_#{level} as level_fn } from "#{src_file}";

      const input = #{raw_input.to_json};

      const start = performance.now();
      let answer: number | null = null;
      try {
        answer = await level_fn(input);
      } finally {
        const duration_ms = performance.now() - start;
        console.log(JSON.stringify({ answer, duration_ms }));
      }
    JAVASCRIPT

    run_lang("bun", "-e", ts_code)
  end

  def zig(src_file, raw_input, level:)
    build_src = <<~ZIG
      const std = @import("std");

      pub fn build(b: *std.Build) void {
        const exe = b.addExecutable(.{
          .name = "temp_run",
          .root_source_file = b.path("_temp_main.zig"),
          .target = b.host,
        });

        b.installArtifact(exe);
      }
    ZIG

    main_src = <<~ZIG
      const std = @import("std");
      const level_fn = @import("#{src_file}").level_#{level};

      pub fn main() anyerror!void {
        var args = try std.process.argsWithAllocator(std.heap.page_allocator);
        defer args.deinit();
        _ = args.next().?; // zig
        const raw_input = args.next().?;

        const start = std.time.Instant.now() catch unreachable;

        const answer = try level_fn(&raw_input);
        
        const end = std.time.Instant.now() catch unreachable;
        const duration_ns = end.since(start); // in nanoseconds
        const duration_ms = @as(f64, @floatFromInt(duration_ns)) / 1_000_000.0;
        const stdout = std.io.getStdOut().writer();
        try std.json.stringify(.{ .answer = answer, .duration_ms = duration_ms }, .{}, stdout);
      }
    ZIG

    dir = File.dirname(src_file)

    temp_build_file = File.join(dir, "build.zig")
    temp_file = File.join(dir, "_temp_main.zig")
    File.write(temp_build_file, build_src)
    File.write(temp_file, main_src)
    begin
      system("zig build", chdir: dir, exception: true)

      exe_file = File.join(dir, "zig-out/bin/temp_run")

      run_lang(exe_file, raw_input)
    ensure
      File.unlink(temp_file)
      File.unlink(temp_build_file)
    end
  end

  def rust(src_file, raw_input, level:)
    main_src = <<~RUST
      use std::env;
      use serde_json::json;

      mod solution {
        include!("#{src_file}");
      }
      use solution::*;

      fn main() {
        let args: Vec<String> = env::args().collect();
        let raw_input = &args[1];
        let start = std::time::Instant::now();

        let answer = level_#{level}(raw_input);

        let duration_ms = start.elapsed().as_secs_f64() * 1000.0;

        println!("{}", json!({"answer": answer, "duration_ms": duration_ms}).to_string());
      }
    RUST

    dir = File.dirname(src_file)
    temp_file = File.join(dir, "_temp_main.rs")

    File.write(temp_file, main_src)
    begin
      system(
        "cargo build --release --target-dir #{dir}/.rust-build",
        chdir: dir,
        exception: true,
      )

      exe_file = File.join(dir, ".rust-build/release/temp_run")

      run_lang(exe_file, raw_input)
    ensure
      File.unlink(temp_file)
    end
  end

  def elixir(src_file, raw_input, level:)
    elixir_code = <<~ELIXIR
      Code.require_file("#{src_file}")
      
      {time, answer} = :timer.tc(fn -> 
        Solution.level_#{level}("#{raw_input}")
      end)

      duration_ms = time / 1000.0

      answer_str = if answer == nil do "null" else answer end

      IO.puts("{\\"answer\\": \#{answer_str}, \\"duration_ms\\": \#{duration_ms}}")
    ELIXIR

    run_lang("elixir", "-e", elixir_code)
  end

  class LangError < StandardError
  end

  # private
  def run_lang(*args)
    answer = nil
    inner_duration_ms = nil
    found_answer = false

    program_duration_s =
      Benchmark.realtime do
        Open3.popen3(*args) do |_stdin, stdout, stderr, wait_thr|
          Thread.new do
            while line = stderr.gets
              $stderr.puts(line)
            end
          rescue => err
            warn "> error reading stderr: #{err}"
          end

          while line = stdout.gets
            if !found_answer && line.start_with?("{") &&
                 line.include?('"answer":')
              parsed = JSON.parse(line.strip)
              answer = parsed.fetch("answer")
              if parsed["duration_ms"].is_a?(Numeric)
                inner_duration_ms = parsed["duration_ms"]
              end
              found_answer = true
            else
              $stdout.puts(line)
            end
          end

          unless wait_thr.value.success?
            raise LangError, "exit status #{wait_thr.value.exitstatus}"
          end
        end
      end

    raise LangError, "no answer found in output" unless found_answer

    {
      answer:,
      program_duration_ms: program_duration_s * 1000.0,
      inner_duration_ms:,
    }
  end
end
