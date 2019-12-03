defmodule Vector do
  @type t :: %__MODULE__{
          direction: :up | :right | :down | :left,
          magnitude: integer
        }

  @enforce_keys [:direction]
  defstruct [:direction, magnitude: 0]
end

defmodule D3 do
  @moduledoc """
  --- Day 3: Crossed Wires ---
  The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

  Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

  The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

  What is the Manhattan distance from the central port to the closest intersection?

  --- Part Two ---
  It turns out that this circuit is very timing-sensitive; you actually need to minimize the signal delay.

  To do this, calculate the number of steps each wire takes to reach each intersection; choose the intersection where the sum of both wires' steps is lowest. If a wire visits a position on the grid multiple times, use the steps value from the first time it visits that position when calculating the total value of a specific intersection.

  The number of steps a wire takes is the total number of grid squares the wire has entered to get to that location, including the intersection being considered.

  What is the fewest combined steps the wires must take to reach an intersection?
  """

  @behaviour Day

  defp parse(input) do
    {stack, current} =
      input
      |> to_charlist
      |> Enum.reduce({[], nil}, fn c, {stack, current} ->
        case c do
          ?U -> {stack, %Vector{direction: :up}}
          ?R -> {stack, %Vector{direction: :right}}
          ?D -> {stack, %Vector{direction: :down}}
          ?L -> {stack, %Vector{direction: :left}}
          ?, -> {[current | stack], nil}
          x when x in ?0..?9 -> {stack, Map.update!(current, :magnitude, &(&1 * 10 + x - ?0))}
          _ -> raise ArgumentError, "bad input"
        end
      end)

    # last one doesn't finish getting parsed because the input is trimmed
    stack = [current | stack]
    Enum.reverse(stack)
  end

  defp to_points(instructions) do
    [_final_coordinates, result] =
      Enum.reduce(instructions, [{0, 0}, MapSet.new()], fn %Vector{direction: d, magnitude: m},
                                                           [{x, y}, board] ->
        points =
          case d do
            :up -> for y_prime <- y..(y + m), do: {x, y_prime}
            :down -> for y_prime <- y..(y - m), do: {x, y_prime}
            :right -> for x_prime <- x..(x + m), do: {x_prime, y}
            :left -> for x_prime <- x..(x - m), do: {x_prime, y}
          end

        new_coordinates =
          case d do
            :up -> {x, y + m}
            :down -> {x, y - m}
            :right -> {x + m, y}
            :left -> {x - m, y}
          end

        board = MapSet.union(board, MapSet.new(points))
        [new_coordinates, board]
      end)

    result
  end

  def solve(input) do
    instruction_sets = Enum.map(input, &parse/1)
    [wire_one, wire_two] = Enum.map(instruction_sets, &to_points/1)

    part_1 =
      MapSet.intersection(wire_one, wire_two)
      # don't consider origin point
      |> Enum.reject(fn point -> point == {0, 0} end)
      # manhatten distance
      |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
      # find the smallest one
      |> Enum.min()

    part_2 = 0

    {
      part_1,
      part_2
    }
  end
end
