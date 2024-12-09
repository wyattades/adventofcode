require "json"
require "open3"

module Langs
  extend self

  LANGS = {
    ruby: :rb,
    python: :py,
    bun: %i[ts js mjs cjs],
    zig: :zig,
    # rs: :rust,
    # go: :golang,
    # dart: :dart,
    # swift: :swift,
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
      sys.path.append(#{File.dirname(src_file).to_json})
      from #{File.basename(src_file, ".py")} import level_#{level} as level_fn

      input_data = sys.argv[1]
      answer = level_fn(input_data)
      print(json.dumps({"answer": answer}))
    PYTHON

    run_lang("python3", "-c", python_code, raw_input)
  end

  def bun(src_file, raw_input, level:)
    ts_code = <<~JAVASCRIPT
      import { level_#{level} as level_fn } from "#{src_file}";

      const start = performance.now();
      try {
        const input = #{raw_input.to_json};
        const result = await level_fn(input);
        console.log(JSON.stringify({ answer: result }));
      } finally {
        const duration = performance.now() - start;
        console.debug(`duration: ${duration.toFixed(2)}ms`);
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

      pub fn main() !void {
        const start = std.time.Instant.now() catch unreachable;
        defer {
          const end = std.time.Instant.now() catch unreachable;
          const duration_ns = end.since(start); // in nanoseconds
          const duration_ms = @as(f64, @floatFromInt(duration_ns)) / 1_000_000.0;  
          std.debug.print("duration: {d:.2}ms\\n", .{duration_ms});
        }

        var args = try std.process.argsWithAllocator(std.heap.page_allocator);
        defer args.deinit();
        _ = args.next().?; // zig
        const raw_input = args.next().?;

        const result = try level_fn(&raw_input);

        const stdout = std.io.getStdOut().writer();
        try std.json.stringify(.{ .answer = result }, .{}, stdout);
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

  class LangError < StandardError
  end

  # private
  def run_lang(*args)
    answer = nil
    found_answer = false

    duration_s =
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
              answer = JSON.parse(line.strip).fetch("answer")
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

    [answer, duration_s * 1000.0]
  end
end
