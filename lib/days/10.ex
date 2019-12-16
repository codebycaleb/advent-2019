require Utils

defmodule D10 do
  @moduledoc """
  --- Day 10: Monitoring Station ---
  You fly into the asteroid belt and reach the Ceres monitoring station. The Elves here have an emergency: they're having trouble tracking all of the asteroids and can't be sure they're safe.

  The Elves would like to build a new monitoring station in a nearby area of space; they hand you a map of all of the asteroids in that region (your puzzle input).

  The map indicates whether each position is empty (.) or contains an asteroid (#). The asteroids are much smaller than they appear on the map, and every asteroid is exactly in the center of its marked position. The asteroids can be described with X,Y coordinates where X is the distance from the left edge and Y is the distance from the top edge (so the top-left corner is 0,0 and the position immediately to its right is 1,0).

  Your job is to figure out which asteroid would be the best place to build a new monitoring station. A monitoring station can detect any asteroid to which it has direct line of sight - that is, there cannot be another asteroid exactly between them. This line of sight can be at any angle, not just lines aligned to the grid or diagonally. The best location is the asteroid that can detect the largest number of other asteroids.

  Find the best location for a new monitoring station. How many other asteroids can be detected from that location?

  --- Part Two ---
  Once you give them the coordinates, the Elves quickly deploy an Instant Monitoring Station to the location and discover the worst: there are simply too many asteroids.

  The only solution is complete vaporization by giant laser.

  Fortunately, in addition to an asteroid scanner, the new monitoring station also comes equipped with a giant rotating laser perfect for vaporizing asteroids. The laser starts by pointing up and always rotates clockwise, vaporizing any asteroid it hits.

  If multiple asteroids are exactly in line with the station, the laser only has enough power to vaporize one of them before continuing its rotation. In other words, the same asteroids that can be detected can be vaporized, but if vaporizing one asteroid makes another one detectable, the newly-detected asteroid won't be vaporized until the laser has returned to the same position by rotating a full 360 degrees.

  The Elves are placing bets on which will be the 200th asteroid to be vaporized. Win the bet by determining which asteroid that will be; what do you get if you multiply its X coordinate by 100 and then add its Y coordinate? (For example, 8,2 becomes 802.)
  """

  @behaviour Day

  def distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def to_angle({x, y}) do
    rads = :math.atan2(y, x)
    angle = rads * 180 / :math.pi() + 90
    if x < 0 and y < 0, do: angle + 360, else: angle
  end

  def mx({x1, y1}, {x2, y2}) do
    {dx, dy} = {x2 - x1, y2 - y1}
    gcd = Integer.gcd(dx, dy)
    {div(dx, gcd), div(dy, gcd)}
  end

  def count_visible(asteroids, point) do
    asteroids
    |> Enum.reject(&(&1 == point))
    |> Enum.map(fn point_2 -> mx(point, point_2) end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def solve(input) do
    asteroids =
      input
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, y}, acc ->
        line
        |> to_charlist
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, x}, acc -> if c == ?#, do: [{x, y} | acc], else: acc end)
      end)

    best = Enum.max_by(asteroids, fn point -> count_visible(asteroids, point) end)

    part_1 = count_visible(asteroids, best)

    {part_2_x, part_2_y} =
      asteroids
      |> Enum.reject(&(&1 == best))
      |> Enum.sort_by(fn point -> distance(best, point) end)
      |> Enum.group_by(fn point -> to_angle(mx(best, point)) end)
      |> Enum.flat_map(fn {angle, list} ->
        list
        |> Enum.with_index()
        |> Enum.map(fn {point, index} -> {index * 360 + angle, point} end)
      end)
      |> Enum.sort()
      |> Enum.at(199)
      |> elem(1)

    part_2 = 100 * part_2_x + part_2_y

    {
      part_1,
      part_2
    }
  end
end
