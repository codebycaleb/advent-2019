defmodule Utils do
  def to_ints(list_of_strings) do
    Enum.map(list_of_strings, fn string ->
      string
      |> Integer.parse()
      |> elem(0)
    end)
  end

  def to_strings([single_string]), do: to_strings(single_string)
  def to_strings(single_string), do: String.split(single_string, ",")
end
