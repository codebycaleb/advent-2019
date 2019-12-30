require Utils
require Program

defmodule D13 do
  @moduledoc """
  --- Day 13: Care Package ---
  As you ponder the solitude of space and the ever-increasing three-hour roundtrip for messages between you and Earth, you notice that the Space Mail Indicator Light is blinking. To help keep you sane, the Elves have sent you a care package.

  It's a new game for the ship's arcade cabinet! Unfortunately, the arcade is all the way on the other end of the ship. Surely, it won't be hard to build your own - the care package even comes with schematics.

  The arcade cabinet runs Intcode software like the game the Elves sent (your puzzle input). It has a primitive screen capable of drawing square tiles on a grid. The software draws tiles to the screen with output instructions: every three output instructions specify the x position (distance from the left), y position (distance from the top), and tile id. The tile id is interpreted as follows:

  0 is an empty tile. No game object appears in this tile.
  1 is a wall tile. Walls are indestructible barriers.
  2 is a block tile. Blocks can be broken by the ball.
  3 is a horizontal paddle tile. The paddle is indestructible.
  4 is a ball tile. The ball moves diagonally and bounces off objects.

  Start the game. How many block tiles are on the screen when the game exits?

  --- Part Two ---
  The game didn't run because you didn't put in any quarters. Unfortunately, you did not bring any quarters. Memory address 0 represents the number of quarters that have been inserted; set it to 2 to play for free.

  The arcade cabinet has a joystick that can move left and right. The software reads the position of the joystick with input instructions:

  If the joystick is in the neutral position, provide 0.
  If the joystick is tilted to the left, provide -1.
  If the joystick is tilted to the right, provide 1.
  The arcade cabinet also has a segment display capable of showing a single number that represents the player's current score. When three output instructions specify X=-1, Y=0, the third output instruction is not a tile; the value instead specifies the new score to show in the segment display. For example, a sequence of output values like -1,0,12345 would show 12345 as the player's current score.

  Beat the game by breaking all the blocks. What is your score after the last block is broken?
  """

  @behaviour Day

  def print_game_board(output) do
    output
    |> Enum.chunk_every(3)
    |> Enum.reduce(%{}, fn [type, y, x], map -> Map.put(map, {x, y}, type) end)
    |> Enum.group_by(fn {{_x, y}, _v} -> y end, fn {{x, _y}, v} -> {x, v} end)
    |> Enum.sort()
    |> Enum.map(fn {_y, list} ->
      list
      |> Enum.sort()
      |> Enum.map(fn {_x, v} ->
        case v do
          0 -> "⬛"
          1 -> "🟫"
          2 -> "⬜"
          3 -> "🟩"
          4 -> "🔵"
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def solve(input) do
    input = input |> Utils.to_ints()

    program = Program.new(input)
    %Program{output: board} = Program.run(program)

    part_1 =
      board
      |> Enum.chunk_every(3)
      |> Enum.map(fn [x, _, _] -> x end)
      |> Enum.count(fn x -> x == 2 end)

    # set paddle to full width
    part_2_entry =
      input
      |> Enum.chunk_every(40, 1)
      |> Enum.find_index(fn
        [1 | rest] -> Enum.sort(rest) == List.duplicate(0, 37) ++ [1, 3] and List.last(rest) == 1
        _ -> false
      end)

    part_2_hack = [1] ++ List.duplicate(3, 38) ++ [1]
    part_2_hacked = Program.hack(program, part_2_entry, part_2_hack)

    # add quarters
    part_2_hacked = Program.hack(part_2_hacked, 0, [2])

    # set input
    part_2_hacked = %{part_2_hacked | input: List.duplicate(0, 100_000)}

    %Program{output: [part_2 | _]} = Program.run(part_2_hacked)

    {
      part_1,
      part_2
    }
  end
end
