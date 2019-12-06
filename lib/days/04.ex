require Utils

defmodule D4 do
  @moduledoc """
  --- Day 4: Secure Container ---
  You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.

  However, they do remember a few key facts about the password:

  It is a six-digit number.
  The value is within the range given in your puzzle input.
  Two adjacent digits are the same (like 22 in 122345).
  Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).

  How many different passwords within the range given in your puzzle input meet these criteria?

  --- Part Two ---
  An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

  How many different passwords within the range given in your puzzle input meet all of the criteria?
  """

  @behaviour Day

  def ascending?(x) when x < 10, do: true

  def ascending?(x) do
    next = div(x, 10)
    right = rem(x, 10)
    left = rem(next, 10)
    right >= left and ascending?(next)
  end

  def double?(x) when x < 10, do: false

  def double?(x) do
    last_two = rem(x, 100)
    rem(last_two, 11) == 0 or double?(div(x, 10))
  end

  def explicit_double?(0, _, count), do: count == 2

  def explicit_double?(x, current, count) do
    new_current = rem(x, 10)

    cond do
      new_current != current and count == 2 -> true
      new_current == current -> explicit_double?(div(x, 10), current, count + 1)
      true -> explicit_double?(div(x, 10), new_current, 1)
    end
  end

  def explicit_double?(x), do: explicit_double?(div(x, 10), rem(x, 10), 1)

  def solve(input) do
    [minimum, maximum] = input |> Utils.to_strings() |> Utils.to_ints()

    ascending = Enum.filter(minimum..maximum, &ascending?/1)

    part_1 = ascending |> Enum.filter(&double?/1)

    part_2 = part_1 |> Enum.filter(&explicit_double?/1)

    {
      length(part_1),
      length(part_2)
    }
  end
end
