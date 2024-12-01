def level_1
  pairs = Utils.get_input_number_lists

  al = []
  bl = []
  pairs.each do |ae, be|
    al << ae
    bl << be
  end

  al.sort!
  bl.sort!

  answer = al.each_with_index.sum { |ae, i| (ae - bl[i]).abs }

  Utils.submit_answer(answer)
end

def level_2
  pairs = Utils.get_input_number_lists

  al = []
  bl = []
  pairs.each do |ae, be|
    al << ae
    bl << be
  end

  bh = bl.tally

  answer = al.sum { |ae| ae * (bh[ae] || 0) }

  Utils.submit_answer(answer)
end
