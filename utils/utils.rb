module Utils
  extend self

  def as_lines(raw_input, remove_blank: true)
    lines = raw_input.split("\n")
    lines.pop if remove_blank && lines.last.blank?
    lines
  end
  def as_numbers(raw_input)
    as_lines(raw_input).map(&:to_i)
  end
  def as_number_lists(raw_input)
    as_lines(raw_input).map { |line| line.split(/\s+/).map(&:to_i) }
  end
end
