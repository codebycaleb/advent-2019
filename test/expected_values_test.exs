defmodule ExpectedValuesTest do
  use ExUnit.Case

  test "programs meet expected output" do
    Enum.each(Expected.values(), fn {name, expected_values} ->
      {n, _} = Integer.parse(name)

      Enum.each(expected_values, fn {raw_input, {output_1, output_2}} ->
        input =
          raw_input
          |> String.trim()
          |> String.split("\n")

        module = String.to_existing_atom("Elixir.D#{n}")

        try do
          {part_1, part_2} = module.solve(input)
          if output_2 == 0 do # allows for 0-definitions for part 2 while developing part 1
            assert part_1 == output_1
          else
            assert {part_1, part_2} == {output_1, output_2}
          end
        rescue
          e ->
            IO.puts(:stderr, "error in day: #{n}; input: #{Enum.at(input, 0)}")
            raise e
        end
      end)
    end)
  end
end
