require Utils

defmodule D1 do
  @moduledoc """
  --- Day 1: The Tyranny of the Rocket Equation ---
  Santa has become stranded at the edge of the Solar System while delivering presents to other planets! To accurately calculate his position in space, safely align his warp drive, and return to Earth in time to save Christmas, he needs you to bring him measurements from fifty stars.

  Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

  The Elves quickly load you into a spacecraft and prepare to launch.

  At the first Go / No Go poll, every Elf is Go until the Fuel Counter-Upper. They haven't determined the amount of fuel required yet.

  Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.

  The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually calculate the fuel needed for the mass of each module (your puzzle input), then add together all the fuel values.

  What is the sum of the fuel requirements for all of the modules on your spacecraft?

  --- Part Two ---
  During the second Go / No Go poll, the Elf in charge of the Rocket Equation Double-Checker stops the launch sequence. Apparently, you forgot to include additional fuel for the fuel you just added.

  Fuel itself requires fuel just like a module - take its mass, divide by three, round down, and subtract 2. However, that fuel also requires fuel, and that fuel requires fuel, and so on. Any mass that would require negative fuel should instead be treated as if it requires zero fuel; the remaining mass, if any, is instead handled by wishing really hard, which has no mass and is outside the scope of this calculation.

  So, for each module mass, calculate its fuel and add it to the total. Then, treat the fuel amount you just calculated as the input mass and repeat the process, continuing until a fuel requirement is zero or negative.

  What is the sum of the fuel requirements for all of the modules on your spacecraft when also taking into account the mass of the added fuel? (Calculate the fuel requirements for each module separately, then add them all up at the end.)
  """

  # 9 / 3 - 2 = 1; 8 / 3 - 2 = 0

  @behaviour Day

  defp calculate_fuel(sum, mass) when mass < 9, do: sum

  defp calculate_fuel(sum, mass) do
    # perform mass -> fuel conversion
    fuel = div(mass, 3) - 2
    # and convert again to account for newly required fuel
    calculate_fuel(sum + fuel, fuel)
  end

  def solve(input) do
    part_1_mapped =
      input
      |> Utils.to_ints
      |> Enum.map(fn mass -> div(mass, 3) - 2 end)

    part_1 = Enum.sum(part_1_mapped)

    part_2 =
      part_1_mapped
      |> Enum.map(&calculate_fuel(&1, &1))
      |> Enum.sum()

    {
      part_1,
      part_2
    }
  end
end
