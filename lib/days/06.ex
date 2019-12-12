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
    [top_down, bottom_up] =
      input
      |> Enum.map(&String.split(&1, ")"))
      |> Enum.reduce([%{}, %{}], fn [parent, child], [top_down, bottom_up] ->
        children = Map.get(top_down, parent, [])
        top_down = Map.put(top_down, parent, [child | children])
        bottom_up = Map.put(bottom_up, child, parent)
        [top_down, bottom_up]
      end)

    levels =
      Stream.unfold([top_down, ["COM"]], fn
        [map, _] when map == %{} ->
          nil

        [map, nodes] ->
          children = Enum.flat_map(nodes, &Map.get(map, &1, []))
          map = Map.drop(map, nodes)
          {children, [map, children]}
      end)
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {group, distance}, acc ->
        Enum.reduce(group, acc, fn node, acc ->
          Map.put(acc, node, distance)
        end)
      end)

    you = Map.get(levels, "YOU")
    santa = Map.get(levels, "SAN")

    gcd_node =
      Stream.unfold([bottom_up, ["YOU", "SAN"]], fn
        [bottom_up, [node_1, node_2]] ->
          {parent_1, bottom_up} = Map.pop(bottom_up, node_1)
          {parent_2, bottom_up} = Map.pop(bottom_up, node_2)

          cond do
            parent_1 == nil -> {node_1, node_1}
            parent_2 == nil -> {node_2, node_2}
            parent_1 == "COM" -> {0, [bottom_up, [node_1, parent_2]]}
            parent_2 == "COM" -> {0, [bottom_up, [parent_1, node_2]]}
            true -> {0, [bottom_up, [parent_1, parent_2]]}
          end

        _ ->
          nil
      end)
      |> Enum.to_list()
      |> List.last()

    gcd = Map.get(levels, gcd_node)

    part_1 =
      levels
      |> Map.values()
      |> Enum.sum()

    part_2 = you + santa - 2 * gcd - 2

    {
      part_1,
      part_2
    }
  end
end
