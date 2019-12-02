require Utils

defmodule D2 do
  @moduledoc """
  """

  @behaviour Day

  defp execute(input) do
    Stream.unfold({0, input}, fn {index, acc} ->
      [opcode | params] = Enum.slice(acc, index..(index + 3))

      if opcode == 99 or opcode == nil do
        nil
      else
        [a_index, b_index, output_index] = params
        a = Enum.at(acc, a_index)
        b = Enum.at(acc, b_index)
        index = index + 4

        acc =
          case opcode do
            1 -> List.replace_at(acc, output_index, a + b)
            2 -> List.replace_at(acc, output_index, a * b)
          end

        {acc, {index, acc}}
      end
    end)
    |> Enum.at(-1)
    |> Enum.at(0)
  end

  defp modify(list, value_at_index_1, value_at_index_2) do
    list
    |> List.replace_at(1, value_at_index_1)
    |> List.replace_at(2, value_at_index_2)
  end

  def solve(input) do
    input =
      input
      |> hd
      |> String.split(",")
      |> Utils.to_ints()

    part_1_input = modify(input, 12, 2)

    part_1 = execute(part_1_input)

    part_2_base = input |> modify(0, 0) |> execute
    part_2_dx = (input |> modify(1, 0) |> execute) - part_2_base
    part_2_dy = (input |> modify(0, 1) |> execute) - part_2_base
    part_2_desired_outcome = 19_690_720
    part_2_desired_x = div(part_2_desired_outcome - part_2_base, part_2_dx)

    part_2_desired_y =
      div(part_2_desired_outcome - part_2_base - part_2_desired_x * part_2_dx, part_2_dy)

    part_2 = 100 * part_2_desired_x + part_2_desired_y

    {
      part_1,
      part_2
    }
  end
end
