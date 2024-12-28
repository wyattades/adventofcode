defmodule Solution do
  @moduledoc """
  Solution for Advent of Code
  """

  # split into array of integers (each is [0-9])
  def parse_input(raw_input) do
    raw_input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Solves part 1 of the puzzle
  """
  def level_1(raw_input) do
    parsed = parse_input(raw_input)

    # build a new array of integers
    files =
      Enum.flat_map(Enum.with_index(parsed), fn {num, index} ->
        if num > 0 do
          if rem(index, 2) == 0 do
            file_id = trunc(index / 2)
            # segment = an array of file_id of length num
            Enum.map(0..num, fn _ -> file_id end)
          else
            Enum.map(0..num, fn _ -> nil end)
          end
        else
          []
        end
      end)

    # starting from the back, move each integer to the first empty nil
    nil_index = files |> Enum.find_index(&is_nil/1)
    move_index = length(files) - 1
    while(move_index > nil_index) do
      files[move_index] = files[move_index - 1]
      move_index = move_index - 1
    end

    # TODO: Implement solution
    nil
  end

  @doc """
  Solves part 2 of the puzzle
  """
  def level_2(raw_input) do
    parsed = parse_input(raw_input)

    # TODO: Implement solution
    nil
  end
end
