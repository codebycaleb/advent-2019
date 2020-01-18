defmodule Utils do
  def to_ints(string), do: string |> to_strings |> Enum.map(&to_int/1)

  def to_int([single_string]), do: to_int(single_string)

  def to_int(string) do
    string
    |> Integer.parse()
    |> elem(0)
  end

  def to_strings([single_string]), do: to_strings(single_string)
  def to_strings(list_of_strings) when is_list(list_of_strings), do: list_of_strings

  def to_strings(single_string) when is_binary(single_string),
    do: single_string |> String.trim() |> String.split(",")

  def output_to_string(map) when is_map(map) do
    [min_x, max_x, min_y, max_y] =
      map
      |> Map.keys()
      |> Enum.reduce([0, 0, 0, 0], fn {x, y}, [min_x, max_x, min_y, max_y] ->
        min_x = min(min_x, x)
        max_x = max(max_x, x)
        min_y = min(min_y, y)
        max_y = max(max_y, y)
        [min_x, max_x, min_y, max_y]
      end)

    min_y..max_y
    |> Enum.map(fn y ->
      min_x..max_x
      |> Enum.map(fn x -> Map.get(map, {x, y}, 0) end)
    end)
    |> output_to_string
  end

  def output_to_string(list) do
    list
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.chunk_by(&(&1 == [0, 0, 0, 0, 0, 0]))
    |> Enum.reject(&Enum.any?(&1, fn x -> x == [0, 0, 0, 0, 0, 0] end))
    |> Enum.map(fn letter ->
      case letter do
        [
          [1, 1, 1, 1, 1, 1],
          [1, 0, 1, 0, 0, 1],
          [1, 0, 1, 0, 0, 1],
          [0, 1, 0, 1, 1, 0]
        ] ->
          ?B

        [
          [0, 1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 1],
          [0, 1, 0, 0, 1, 0]
        ] ->
          ?C

        [
          [1, 1, 1, 1, 1, 1],
          [1, 0, 1, 0, 0, 0],
          [1, 0, 1, 0, 0, 0],
          [1, 0, 0, 0, 0, 0]
        ] ->
          ?F

        [
          [1, 1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0, 0],
          [0, 0, 1, 0, 0, 0],
          [1, 1, 1, 1, 1, 1]
        ] ->
          ?H

        [
          [0, 0, 0, 0, 1, 0],
          [0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 1],
          [1, 1, 1, 1, 1, 0]
        ] ->
          ?J

        [
          [1, 1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0, 0],
          [0, 1, 0, 1, 1, 0],
          [1, 0, 0, 0, 0, 1]
        ] ->
          ?K

        [
          [1, 1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 1]
        ] ->
          ?L

        [
          [1, 1, 1, 1, 1, 1],
          [1, 0, 0, 1, 0, 0],
          [1, 0, 0, 1, 1, 0],
          [0, 1, 1, 0, 0, 1]
        ] ->
          ?R

        [
          [1, 1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 1],
          [1, 1, 1, 1, 1, 0]
        ] ->
          ?U

        [
          [1, 1, 0, 0, 0, 0],
          [0, 0, 1, 0, 0, 0],
          [0, 0, 0, 1, 1, 1],
          [0, 0, 1, 0, 0, 0],
          [1, 1, 0, 0, 0, 0]
        ] ->
          ?Y

        _ ->
          letter
      end
    end)
    |> to_string
  end
end
