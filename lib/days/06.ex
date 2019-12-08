require Utils

defmodule D6 do
  @moduledoc """
  --- Day 6: Universal Orbit Map ---
  You've landed at the Universal Orbit Map facility on Mercury. Because navigation in space often involves transferring between orbits, the orbit maps here are useful for finding efficient routes between, for example, you and Santa. You download a map of the local orbits (your puzzle input).

  Except for the universal Center of Mass (COM), every object in space is in orbit around exactly one other object.

  In this diagram, the object BBB is in orbit around AAA. The path that BBB takes around AAA (drawn with lines) is only partly shown. In the map data, this orbital relationship is written AAA)BBB, which means "BBB is in orbit around AAA".

  Before you use your map data to plot a course, you need to make sure it wasn't corrupted during the download. To verify maps, the Universal Orbit Map facility uses orbit count checksums - the total number of direct orbits (like the one shown above) and indirect orbits.

  Whenever A orbits B and B orbits C, then A indirectly orbits C. This chain can be any number of objects long: if A orbits B, B orbits C, and C orbits D, then A indirectly orbits D.

  What is the total number of direct and indirect orbits in your map data?
  """

  @behaviour Day

  def solve(input) do
    graph =
      input
      |> Enum.map(&String.split(&1, ")"))
      |> Enum.reduce(%{}, fn [main, sat], map ->
        sats = Map.get(map, main, [])
        Map.put(map, main, [sat | sats])
      end)

    part_1 =
      Stream.unfold([graph, ["COM"]], fn
        [map, _] when map == %{} ->
          nil

        [map, mains] ->
          sats = Enum.flat_map(mains, &Map.get(map, &1, []))
          map = Map.drop(map, mains)
          {sats, [map, sats]}
      end)
      |> Enum.map(&Enum.count/1)
      |> Enum.with_index(1)
      |> Enum.map(fn {count, index} -> count * index end)
      |> Enum.sum()

    part_2 = 0

    {
      part_1,
      part_2
    }
  end
end
