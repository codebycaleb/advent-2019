defmodule Day do
  @callback solve(arg :: [binary]) :: {integer | binary, integer | binary}
end

defmodule Advent do
  @moduledoc """
  Documentation for Advent.
  """

  @doc """
  Runs all days, printing the time to run (in microsecodns) and the outputs for
  part 1 and part 2 in a 2-tuple.
  """
  def all do
    # used for padding spaces
    format = fn x, leading -> x |> Integer.to_string() |> String.pad_leading(leading) end
    files = File.ls("lib/days") |> elem(1)

    total =
      files
      |> Enum.sort()
      |> Enum.reduce(0, fn filename, runtime ->
        # pattern match on file name, only reading first two chars
        <<x, y>> <> _rest = filename
        # convert chars to int
        n = (x - ?0) * 10 + (y - ?0)
        # convert to 0-padded string
        nn = to_string([x, y])
        module = String.to_existing_atom("Elixir.D#{n}")
        input = "assets/inputs/#{nn}.txt" |> File.read!() |> String.trim() |> String.split("\n")
        {time, {result_1, result_2}} = :timer.tc(module, :solve, [input])
        IO.puts("Problem #{format.(n, 2)}: #{format.(time, 8)} μs (#{result_1}, #{result_2})")
        runtime + time
      end)

    IO.puts("-------------------")
    IO.puts("Total:  #{format.(total, 12)} μs")
    IO.puts("")
  end
end
