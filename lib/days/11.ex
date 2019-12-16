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

  def run_program(program, initial_input) do
    program = %{program | input: [initial_input]}

    Stream.unfold({%{}, {{0, 0}, 0}, Program.run_blocking(program)}, fn
      {_map, _info, {:ok, _program}} ->
        nil

      {map, {{x, y} = location, direction},
       {:halt, %Program{output: [turn | [color | _output]]} = program}} ->
        # paint
        map = Map.put(map, location, color)
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
        program = %{program | input: [current]}
        {map, {map, {location, direction}, Program.run_blocking(program)}}
    end)
    |> Enum.at(-1)
  end

  def solve(input) do
    input = input |> Utils.to_strings() |> Utils.to_ints()

    program = Program.new(input)

    part_1 =
      program
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
