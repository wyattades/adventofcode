def level_1
  lines = Utils.get_input_lines

  cmds =
    lines.map do |line|
      m = line.match(/^(jmp|acc|nop) \+?(\-?\d+)$/)
      [m[1], m[2].to_i]
    end

  hits = Set.new

  acc = 0
  run =
    Proc.new do |i|
      next if i >= cmds.length
      next if hits.include?(i)
      hits.add(i)

      cmd, num = cmds[i]
      if cmd == "acc"
        acc += num
        run.call(i + 1)
      elsif cmd == "jmp"
        run.call(i + num)
      else
        run.call(i + 1)
      end
    end

  run.call(0)

  answer = acc

  Utils.submit_answer(answer)
end

def level_2
  lines = Utils.get_input_lines

  orig_cmds =
    lines.map do |line|
      m = line.match(/^(jmp|acc|nop) \+?(\-?\d+)$/)
      [m[1], m[2].to_i]
    end

  orig_cmds.each_with_index do |(pcmd, pnum), i|
    next if pcmd == "acc"

    cmds = orig_cmds.dup
    cmds[i] = [pcmd == "nop" ? "jmp" : "nop", pnum]

    hits = Set.new

    acc = 0
    run =
      Proc.new do |i|
        if i >= cmds.length
          Utils.submit_answer(acc)
          return
        end

        next if hits.include?(i)
        hits.add(i)

        cmd, num = cmds[i]
        if cmd == "acc"
          acc += num
          run.call(i + 1)
        elsif cmd == "jmp"
          run.call(i + num)
        else
          run.call(i + 1)
        end
      end

    run.call(0)
  end

  raise "Failed to calculate answer!"
end
