defmodule Utils do
  def to_ints(list_of_strings) do
    Enum.map(list_of_strings, fn string ->
      string
      |> Integer.parse()
      |> elem(0)
    end)
  end
end
