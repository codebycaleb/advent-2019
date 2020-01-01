require Utils
require Program

defmodule D14 do
  @moduledoc """
  --- Day 14: Space Stoichiometry ---
  As you approach the rings of Saturn, your ship's low fuel indicator turns on. There isn't any fuel here, but the rings have plenty of raw material. Perhaps your ship's Inter-Stellar Refinery Union brand nanofactory can turn these raw materials into fuel.

  You ask the nanofactory to produce a list of the reactions it can perform that are relevant to this process (your puzzle input). Every reaction turns some quantities of specific input chemicals into some quantity of an output chemical. Almost every chemical is produced by exactly one reaction; the only exception, ORE, is the raw material input to the entire process and is not produced by a reaction.

  You just need to know how much ORE you'll need to collect before you can produce one unit of FUEL.

  Each reaction gives specific quantities for its inputs and output; reactions cannot be partially run, so only whole integer multiples of these quantities can be used. (It's okay to have leftover chemicals when you're done, though.) For example, the reaction 1 A, 2 B, 3 C => 2 D means that exactly 2 units of chemical D can be produced by consuming exactly 1 A, 2 B and 3 C. You can run the full reaction as many times as necessary; for example, you could produce 10 D by consuming 5 A, 10 B, and 15 C.

  Given the list of reactions in your puzzle input, what is the minimum amount of ORE required to produce exactly 1 FUEL?
  """

  @behaviour Day

  def produce(_map, store, 0, _type), do: store

  def produce(_map, store, quantity, "ORE") do
    store
    |> Map.update("TOTAL ORE", quantity, &(&1 + quantity))
    |> Map.update("ORE", quantity, &(&1 + quantity))
  end

  def produce(map, store, quantity, type) do
    {count, requirements} = Map.get(map, type)
    producing = ceil(quantity / count)
    # produce and consume
    store =
      Enum.reduce(requirements, store, fn {r_count, r_type}, store ->
        available = Map.get(store, r_type, 0)
        needed = max(0, r_count * producing - available)
        store = produce(map, store, needed, r_type)
        Map.update!(store, r_type, &(&1 - r_count * producing))
      end)

    Map.update(store, type, count * producing, &(&1 + count * producing))
  end

  def calculate_ore(map, quantity, type),
    do: produce(map, %{}, quantity, type) |> Map.get("TOTAL ORE")

  def parse(input) do
    input
    |> Enum.reduce(%{}, fn line, acc ->
      [requirements_string, element_string] = String.split(line, " => ")
      [element_quantity_string, element_name] = String.split(element_string, " ")
      {element_quantity, ""} = Integer.parse(element_quantity_string)

      requirements =
        requirements_string
        |> String.split(", ")
        |> Enum.map(fn element_string ->
          [element_quantity_string, element_name] = String.split(element_string, " ")
          {element_quantity, ""} = Integer.parse(element_quantity_string)
          {element_quantity, element_name}
        end)

      Map.put(acc, element_name, {element_quantity, requirements})
    end)
  end

  def part_2(_map, min, max) when min == max - 1, do: min

  def part_2(map, min, max) do
    avg = div(min + max, 2)
    store = produce(map, %{}, avg, "FUEL")
    ore_used = store["TOTAL ORE"]
    if ore_used < 1_000_000_000_000, do: part_2(map, avg, max), else: part_2(map, min, avg)
  end

  def solve(input) do
    map = parse(input)

    part_1 = calculate_ore(map, 1, "FUEL")
    part_2 = part_2(map, div(1_000_000_000_000, part_1), div(2_000_000_000_000, part_1))

    {
      part_1,
      part_2
    }
  end
end
