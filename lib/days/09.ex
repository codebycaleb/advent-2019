require Utils
require Program

defmodule D9 do
  @moduledoc """
  --- Day 9: Sensor Boost ---
  You've just said goodbye to the rebooted rover and left Mars when you receive a faint distress signal coming from the asteroid belt. It must be the Ceres monitoring station!

  In order to lock on to the signal, you'll need to boost your sensors. The Elves send up the latest BOOST program - Basic Operation Of System Test.

  While BOOST (your puzzle input) is capable of boosting your sensors, for tenuous safety reasons, it refuses to do so until the computer it runs on passes some checks to demonstrate it is a complete Intcode computer.

  Your existing Intcode computer is missing one key feature: it needs support for parameters in relative mode.

  Parameters in mode 2, relative mode, behave very similarly to parameters in position mode: the parameter is interpreted as a position. Like position mode, parameters in relative mode can be read from or written to.

  The important difference is that relative mode parameters don't count from address 0. Instead, they count from a value called the relative base. The relative base starts at 0.

  The address a relative mode parameter refers to is itself plus the current relative base. When the relative base is 0, relative mode parameters and position mode parameters with the same value refer to the same address.

  The relative base is modified with the relative base offset instruction:

  Opcode 9 adjusts the relative base by the value of its only parameter. The relative base increases (or decreases, if the value is negative) by the value of the parameter.

  Your Intcode computer will also need a few other capabilities:

  The computer's available memory should be much larger than the initial program. Memory beyond the initial program starts with the value 0 and can be read or written like any other memory. (It is invalid to try to access memory at a negative address, though.)
  The computer should have support for large numbers. Some instructions near the beginning of the BOOST program will verify this capability.

  The BOOST program will ask for a single input; run it in test mode by providing it the value 1. It will perform a series of checks on each opcode, output any opcodes (and the associated parameter modes) that seem to be functioning incorrectly, and finally output a BOOST keycode.

  Once your Intcode computer is fully functional, the BOOST program should report no malfunctioning opcodes when run in test mode; it should only output a single value, the BOOST keycode. What BOOST keycode does it produce?

  --- Part Two ---
  You now have a complete Intcode computer.

  Finally, you can lock on to the Ceres distress signal! You just need to boost your sensors using the BOOST program.

  The program runs in sensor boost mode by providing the input instruction the value 2. Once run, it will boost the sensors automatically, but it might take a few seconds to complete the operation on slower hardware. In sensor boost mode, the program will output a single value: the coordinates of the distress signal.

  Run the BOOST program in sensor boost mode. What are the coordinates of the distress signal?
  """

  @behaviour Day

  def solve(input) do
    input = input |> Utils.to_ints()

    %Program{output: [part_1]} = Program.run(Program.new(input, 1))

    part_2_entry =
      (input
       |> Enum.with_index()
       |> Enum.filter(fn {v, _i} -> v == 99 end)
       |> Enum.map(fn {_v, i} -> i end)
       |> Enum.at(-2)) + 1

    part_2_static =
      input
      |> Enum.chunk_every(6, 1)
      |> Enum.find(fn
        [_, _, 1, 204, 1, 99] -> true
        _ -> false
      end)
      |> Enum.slice(0..1)
      |> Enum.max()

    part_2_hack =
      "21101,0,2,1,21101,0,3,2,21101,0,5,3,21101,0,1,26,109,1,22201,0,2,3,1206,4,920,21201,3,#{
        part_2_static
      },4,204,4,99"
      |> Utils.to_ints()

    part_2_hacked =
      Program.new(input, 2)
      |> Program.hack(part_2_entry, part_2_hack)

    %Program{output: [part_2]} = Program.run(part_2_hacked)

    {
      part_1,
      part_2
    }
  end
end
