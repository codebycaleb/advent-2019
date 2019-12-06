defmodule Direction do
  def vertical?(direction), do: direction == :up or direction == :down
  def horizontal?(direction), do: direction == :right or direction == :left
end

defmodule Vector do
  @type t :: %__MODULE__{
          direction: :up | :right | :down | :left,
          magnitude: integer
        }

  @enforce_keys [:direction]
  defstruct [:direction, magnitude: 0]
end

defmodule Segment do
  @type t :: %__MODULE__{
          direction: :up | :right | :down | :left,
          length: integer,
          start: {integer, integer},
          distance: integer
        }
  @enforce_keys [:direction, :length, :start, :distance]
  defstruct [:direction, :length, :start, :distance]

  def ending(%Segment{direction: d, length: l, start: {x, y}}) do
    case d do
      :up -> {x, y + l}
      :down -> {x, y - l}
      :right -> {x + l, y}
      :left -> {x - l, y}
    end
  end

  def x_range(%Segment{direction: d, length: l, start: {x, _y}}) do
    case d do
      :right -> x..(x + l)
      :left -> x..(x - l)
      _ -> x..x
    end
  end

  def y_range(%Segment{direction: d, length: l, start: {_x, y}}) do
    case d do
      :up -> y..(y + l)
      :down -> y..(y - l)
      _ -> y..y
    end
  end

  def vertical?(%Segment{direction: d}), do: vertical?(d)
  def vertical?(d), do: d == :up or d == :down

  def parallel?(s1, s2), do: vertical?(s1 == vertical?(s2))

  def intersection(segment, other) do
    !parallel?(segment, other) and
      (
        vertical = if vertical?(segment), do: segment, else: other
        horizontal = if vertical?(segment), do: other, else: segment
        %Segment{start: {x1, y1}, distance: p1} = vertical
        %Segment{start: {x2, y2}, distance: p2} = horizontal

        if x1 in x_range(horizontal) and y2 in y_range(vertical) do
          point = {x1, y2}
          distance_vertical = p1 + abs(y1 - y2)
          distance_horizontal = p2 + abs(x1 - x2)
          {point, distance_vertical + distance_horizontal}
        else
          nil
        end
      )
  end
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

  defp to_segments(instructions) do
    [_final_location, lr_segments, ud_segments, _total_distance] =
      Enum.reduce(instructions, [{0, 0}, [], [], 0], fn %Vector{
                                                          direction: direction,
                                                          magnitude: magnitude
                                                        },
                                                        [
                                                          {x, y},
                                                          lr_segments,
                                                          ud_segments,
                                                          distance
                                                        ] ->
        segment = %Segment{
          direction: direction,
          length: magnitude,
          start: {x, y},
          distance: distance
        }

        final_location = Segment.ending(segment)
        final_steps = distance + magnitude

        {lr_segments, ud_segments} =
          case Segment.vertical?(segment) do
            true -> {lr_segments, [segment | ud_segments]}
            false -> {[segment | lr_segments], ud_segments}
          end

        [final_location, lr_segments, ud_segments, final_steps]
      end)

    {lr_segments, ud_segments}
  end

  def solve(input) do
    instruction_sets = Enum.map(input, &parse/1)

    [{lr_segments_1, ud_segments_1}, {lr_segments_2, ud_segments_2}] =
      Enum.map(instruction_sets, &to_segments/1)

    intersections_1 =
      Enum.flat_map(lr_segments_1, fn segment ->
        ud_segments_2
        |> Enum.map(fn other -> Segment.intersection(segment, other) end)
        |> Enum.filter(& &1)
      end)

    intersections_2 =
      Enum.flat_map(lr_segments_2, fn segment ->
        ud_segments_1
        |> Enum.map(fn other -> Segment.intersection(segment, other) end)
        |> Enum.filter(& &1)
      end)

    intersections = intersections_1 ++ intersections_2

    part_1 =
      intersections
      |> Enum.map(fn
        {{0, 0}, _steps} -> 999_999
        {{x, y}, _steps} -> abs(x) + abs(y)
      end)
      |> Enum.min()

    part_2 =
      intersections
      |> Enum.map(fn
        {_, 0} -> 999_999
        {_, steps} -> steps
      end)
      |> Enum.min()

    {
      part_1,
      part_2
    }
  end
end
