require Utils
require Program

defmodule D11 do
  @moduledoc """
  --- Day 11: Space Police ---
  On the way to Jupiter, you're pulled over by the Space Police.

  "Attention, unmarked spacecraft! You are in violation of Space Law! All spacecraft must have a clearly visible registration identifier! You have 24 hours to comply or be sent to Space Jail!"

  Not wanting to be sent to Space Jail, you radio back to the Elves on Earth for help. Although it takes almost three hours for their reply signal to reach you, they send instructions for how to power up the emergency hull painting robot and even provide a small Intcode program (your puzzle input) that will cause it to paint your ship appropriately.

  There's just one problem: you don't have an emergency hull painting robot.

  You'll need to build a new emergency hull painting robot. The robot needs to be able to move around on the grid of square panels on the side of your ship, detect the color of its current panel, and paint its current panel black or white. (All of the panels are currently black.)

  The Intcode program will serve as the brain of the robot. The program uses input instructions to access the robot's camera: provide 0 if the robot is over a black panel or 1 if the robot is over a white panel. Then, the program will output two values:

  First, it will output a value indicating the color to paint the panel the robot is over: 0 means to paint the panel black, and 1 means to paint the panel white.
  Second, it will output a value indicating the direction the robot should turn: 0 means it should turn left 90 degrees, and 1 means it should turn right 90 degrees.
  After the robot turns, it should always move forward exactly one panel. The robot starts facing up.

  The robot will continue running for a while like this and halt when it is finished drawing. Do not restart the Intcode computer inside the robot during this process.

  Before you deploy the robot, you should probably have an estimate of the area it will cover: specifically, you need to know the number of panels it paints at least once, regardless of color. In the example above, the robot painted 6 panels at least once. (It painted its starting panel twice, but that panel is still only counted once; it also never painted the panel it ended on.)

  Build a new emergency hull painting robot and run the Intcode program on it. How many panels does it paint at least once?

  --- Part Two ---
  You're not sure what it's trying to paint, but it's definitely not a registration identifier. The Space Police are getting impatient.

  Checking your external ship cameras again, you notice a white panel marked "emergency hull painting robot starting panel". The rest of the panels are still black, but it looks like the robot was expecting to start on a white panel, not a black one.

  Based on the Space Law Space Brochure that the Space Police attached to one of your windows, a valid registration identifier is always eight capital letters. After starting the robot on a single white panel instead, what registration identifier does it paint on your hull?
  """

  @behaviour Day

  def run_program(_program, :halt, map, _location, _direction), do: map

  def run_program(program, :block, map, {x, y}, direction) do
    %Program{output: [turn | [color | _output]]} = program
    # paint
    map = Map.put(map, {x, y}, color)
    # 0 = up, 1 = right, 2 = down, 3 = left
    direction = rem(direction + turn * 2 + 3, 4)

    location =
      case direction do
        0 -> {x, y - 1}
        1 -> {x + 1, y}
        2 -> {x, y + 1}
        3 -> {x - 1, y}
      end

    current = Map.get(map, location, 0)
    {status, program} = Program.run_blocking(%{program | input: [current]})

    run_program(program, status, map, location, direction)
  end

  def run_program(program, initial_input) do
    program = %{program | input: [initial_input]}
    {:block, program} = Program.run_blocking(program)
    run_program(program, :block, %{}, {0, 0}, 0)
  end

  def solve(input) do
    input = input |> Utils.to_ints()

    program = Program.new(input)

    [a, b, c, d, e, f, g, h, i, j] =
      input
      |> Enum.with_index()
      |> Enum.filter(fn {v, _i} -> v == 108 or v == 1008 end)
      |> Enum.map(fn {_v, i} -> i end)
      |> Enum.sort()
      |> Enum.drop(-1)
      |> Enum.map(fn i -> Enum.slice(input, i + 1, 2) end)
      |> Enum.map(fn [a, b] -> if a == 8, do: b, else: a end)

    part_1_hack =
      "3,8,1005,8,325,1106,0,11,0,0,0,104,1,104,0,3,8,102,-1,8,10,1001,10,1,10,4,10,108,#{a},8,10,4,10,101,0,8,28,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,#{
        b
      },10,4,10,101,0,8,51,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,#{c},8,10,4,10,101,0,8,72,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,#{
        d
      },10,4,10,1002,8,1,95,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,#{e},10,4,10,101,0,8,117,3,8,1002,8,-1,10,101,1,10,10,4,10,108,#{
        f
      },8,10,4,10,1001,8,0,138,3,8,102,-1,8,10,1001,10,1,10,4,10,108,#{g},8,10,4,10,1001,8,0,160,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,#{
        h
      },10,4,10,102,1,8,183,3,8,102,-1,8,10,101,1,10,10,4,10,108,#{i},8,10,4,10,102,1,8,204,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,#{
        j
      },10,4,10,102,1,8,227,1006,0,74,2,1003,2,10,1,107,1,10,101,1,9,9,1007,9,1042,10,1005,10,15,99"
      |> Utils.to_ints()

    part_1_hacked = Program.hack(program, 0, part_1_hack)

    part_1 =
      part_1_hacked
      |> run_program(0)
      |> map_size

    part_2 =
      program
      |> run_program(1)
      |> Utils.output_to_string()

    {
      part_1,
      part_2
    }
  end
end
