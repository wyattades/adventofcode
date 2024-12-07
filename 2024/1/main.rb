def level_1(raw_input)
  pairs = Utils.as_number_lists(raw_input)

  al = []
  bl = []
  pairs.each do |ae, be|
    al << ae
    bl << be
  end

  al.sort!
  bl.sort!

  answer = al.each_with_index.sum { |ae, i| (ae - bl[i]).abs }

  answer
end

def level_2(raw_input)
  pairs = Utils.as_number_lists(raw_input)

  al = []
  bl = []
  pairs.each do |ae, be|
    al << ae
    bl << be
  end

  bh = bl.tally

  answer = al.sum { |ae| ae * (bh[ae] || 0) }

  answer
end
