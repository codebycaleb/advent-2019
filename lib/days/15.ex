require Utils
require Program

defmodule D15 do
  @moduledoc """
  --- Day 15: Oxygen System ---
  Out here in deep space, many things can go wrong. Fortunately, many of those things have indicator lights. Unfortunately, one of those lights is lit: the oxygen system for part of the ship has failed!

  According to the readouts, the oxygen system must have failed days ago after a rupture in oxygen tank two; that section of the ship was automatically sealed once oxygen levels went dangerously low. A single remotely-operated repair droid is your only option for fixing the oxygen system.

  The Elves' care package included an Intcode program (your puzzle input) that you can use to remotely control the repair droid. By running that program, you can direct the repair droid to the oxygen system and fix the problem.

  The remote control program executes the following steps in a loop forever:

  Accept a movement command via an input instruction.
  Send the movement command to the repair droid.
  Wait for the repair droid to finish the movement operation.
  Report on the status of the repair droid via an output instruction.
  Only four movement commands are understood: north (1), south (2), west (3), and east (4). Any other command is invalid. The movements differ in direction, but not in distance: in a long enough east-west hallway, a series of commands like 4,4,4,4,3,3,3,3 would leave the repair droid back where it started.

  The repair droid can reply with any of the following status codes:

  0: The repair droid hit a wall. Its position has not changed.
  1: The repair droid has moved one step in the requested direction.
  2: The repair droid has moved one step in the requested direction; its new position is the location of the oxygen system.
  You don't know anything about the area around the repair droid, but you can figure it out by watching the status codes.

  What is the fewest number of movement commands required to move the repair droid from its starting position to the location of the oxygen system?

  --- Part Two ---
  You quickly repair the oxygen system; oxygen gradually fills the area.

  Oxygen starts in the location containing the repaired oxygen system. It takes one minute for oxygen to spread to all open locations that are adjacent to a location that already contains oxygen. Diagonal locations are not adjacent.

  Use the repair droid to get a complete map of the area. How many minutes will it take to fill with oxygen?
  """

  @behaviour Day

  # def print(map) do
  #   # first row
  #   (["⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛"] ++
  #      (map
  #       |> Enum.map(fn {k, [_up, down, left, _right]} -> {k, [down, left]} end)
  #       |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end)
  #       |> Enum.chunk_every(20)
  #       |> Enum.map(fn row ->
  #         # end of the row
  #         lefts =
  #           Enum.map(row, fn {_k, [_down, left]} ->
  #             case left do
  #               true -> "⬜⬜"
  #               false -> "⬛⬜"
  #             end
  #           end) ++
  #             ["⬛"]
  #
  #         # end of the row
  #         downs =
  #           Enum.map(row, fn {_k, [down, _left]} ->
  #             case down do
  #               true -> "⬛⬜"
  #               false -> "⬛⬛"
  #             end
  #           end) ++
  #             ["⬛"]
  #
  #         [lefts, downs] |> Enum.map(&Enum.join/1) |> Enum.join("\n")
  #       end)))
  #   |> Enum.join("\n")
  #   |> IO.puts()
  # end
  #
  # def map(data) do
  #   up_down =
  #     data
  #     |> Enum.chunk_every(39)
  #     |> Enum.map(fn line ->
  #       ([999] ++ line)
  #       |> Enum.drop_every(2)
  #     end)
  #     |> Enum.zip()
  #     |> Enum.map(fn column ->
  #       column = Tuple.to_list(column)
  #
  #       ([999] ++ column)
  #       |> Enum.chunk_every(2, 1, :discard)
  #       |> Enum.map(fn [a, b] -> [a < 58, b < 58] end)
  #     end)
  #
  #   left_right =
  #     data
  #     |> Enum.chunk_every(39)
  #     |> Enum.map(fn row ->
  #       row = Enum.drop_every(row, 2)
  #
  #       ([999] ++ row ++ [999])
  #       |> Enum.chunk_every(2, 1, :discard)
  #       |> Enum.map(fn [a, b] -> [a < 58, b < 58] end)
  #     end)
  #
  #   for i <- 0..19, j <- 0..19, into: %{} do
  #     [up, down] = up_down |> Enum.at(i) |> Enum.at(j)
  #     [left, right] = left_right |> Enum.at(j) |> Enum.at(i)
  #     {{i, j}, [up, down, left, right]}
  #   end
  # end

  def edges(data, delimiter) do
    up_down =
      data
      |> Enum.chunk_every(39)
      |> Enum.map(fn line ->
        ([999] ++ line)
        |> Enum.drop_every(2)
      end)
      |> Enum.zip()
      |> Enum.map(fn column ->
        column = Tuple.to_list(column)

        ([999] ++ column)
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> [a < delimiter, b < delimiter] end)
      end)

    left_right =
      data
      |> Enum.chunk_every(39)
      |> Enum.map(fn row ->
        row = Enum.drop_every(row, 2)

        ([999] ++ row ++ [999])
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> [a < delimiter, b < delimiter] end)
      end)

    for i <- 0..19, j <- 0..19 do
      [up, down] = up_down |> Enum.at(i) |> Enum.at(j)
      [left, right] = left_right |> Enum.at(j) |> Enum.at(i)

      [
        up and {{i, j}, {i, j - 1}},
        down and {{i, j}, {i, j + 1}},
        left and {{i, j}, {i - 1, j}},
        right and {{i, j}, {i + 1, j}}
      ]
    end
    |> List.flatten()
    |> Enum.filter(& &1)
  end

  def part_1(graph, start, goal) do
    path =
      graph
      |> Graph.dijkstra(start, goal)
      |> length

    # subtract initial point from path for move set; then double because the map is twice the size of the steps needed
    (path - 1) * 2
  end

  def part_2(graph, current, minutes, frontier, seen) do
    neighbors =
      graph
      |> Graph.neighbors(current)
      |> Enum.reject(fn x -> MapSet.member?(seen, x) end)

    seen = Enum.reduce(neighbors, seen, fn x, seen -> MapSet.put(seen, x) end)
    frontier = Enum.reduce(neighbors, frontier, fn x, q -> :queue.in({x, minutes + 2}, q) end)

    case :queue.out(frontier) do
      {{:value, {next, minutes}}, frontier} -> part_2(graph, next, minutes, frontier, seen)
      {:empty, _} -> minutes
    end
  end

  def part_2(graph, start), do: part_2(graph, start, 0, :queue.new(), MapSet.new([start]))

  def solve(input) do
    input = Utils.to_ints(input)

    data_start =
      (input
       |> Enum.chunk_every(3, 1)
       |> Enum.find_index(fn
         [1105, 1, 0] -> true
         [1106, 0, 0] -> true
         _ -> false
       end)) + 3

    # the last command before jumping back to the beginning is to output the movement value
    movement_index = Enum.at(input, data_start - 4)

    # the movement index is first referred to after a section that checks the current x, y; if they match the goal x, y, then the movement value is set to 2
    tmp = Enum.find_index(input, fn x -> x == movement_index end)

    # the section that checks the current x, y against the goal is ~17 ints long and is consists of checking a pointer to a set number (pointers > 1000 and the opcode will be 108 or 1008), jump-if-trues (opcode 1006), and then finally setting the M value (either adding 0 and 2 or multiplying 1 and 2)
    [goal_x, goal_y] =
      input
      |> Enum.slice((tmp - 17)..tmp)
      |> Enum.filter(fn x -> x < 100 end)
      |> Enum.drop(-2)

    # my map space is half the size of the actual maze
    goal = {div(goal_x, 2), div(goal_y, 2)}

    # there's only one check-less-than, and it's checking for our delimiter (mine is 58)
    delimiter_index = Enum.find_index(input, fn x -> x == 1007 end) + 2
    delimiter = Enum.at(input, delimiter_index)

    data = Enum.slice(input, data_start, 20 * 39)
    graph = Graph.add_edges(Graph.new(), edges(data, delimiter))

    part_1 = part_1(graph, {10, 10}, goal)
    part_2 = part_2(graph, goal)

    {
      part_1,
      part_2
    }
  end
end
