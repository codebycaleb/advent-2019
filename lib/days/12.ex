defmodule D12 do
  @moduledoc """
  --- Day 12: The N-Body Problem ---
  The space near Jupiter is not a very safe place; you need to be careful of a big distracting red spot, extreme radiation, and a whole lot of moons swirling around. You decide to start by tracking the four largest moons: Io, Europa, Ganymede, and Callisto.

  After a brief scan, you calculate the position of each moon (your puzzle input). You just need to simulate their motion so you can avoid them.

  Each moon has a 3-dimensional position (x, y, and z) and a 3-dimensional velocity. The position of each moon is given in your scan; the x, y, and z velocity of each moon starts at 0.

  Simulate the motion of the moons in time steps. Within each time step, first update the velocity of every moon by applying gravity. Then, once all moons' velocities have been updated, update the position of every moon by applying velocity. Time progresses by one step once all of the positions are updated.

  To apply gravity, consider every pair of moons. On each axis (x, y, and z), the velocity of each moon changes by exactly +1 or -1 to pull the moons together. For example, if Ganymede has an x position of 3, and Callisto has a x position of 5, then Ganymede's x velocity changes by +1 (because 5 > 3) and Callisto's x velocity changes by -1 (because 3 < 5). However, if the positions on a given axis are the same, the velocity on that axis does not change for that pair of moons.

  Once all gravity has been applied, apply velocity: simply add the velocity of each moon to its own position. For example, if Europa has a position of x=1, y=2, z=3 and a velocity of x=-2, y=0,z=3, then its new position would be x=-1, y=2, z=6. This process does not modify the velocity of any moon.

  Then, it might help to calculate the total energy in the system. The total energy for a single moon is its potential energy multiplied by its kinetic energy. A moon's potential energy is the sum of the absolute values of its x, y, and z position coordinates. A moon's kinetic energy is the sum of the absolute values of its velocity coordinates. Below, each line shows the calculations for a moon's potential energy (pot), kinetic energy (kin), and total energy:

  What is the total energy in the system after simulating the moons given in your scan for 1000 steps?

  --- Part Two ---
  All this drifting around in space makes you wonder about the nature of the universe. Does history really repeat itself? You're curious whether the moons will ever return to a previous state.

  Determine the number of steps that must occur before all of the moons' positions and velocities exactly match a previous point in time.

  Of course, the universe might last for a very long time before repeating. Here's a copy of the second example from above:

  This set of initial positions takes 4686774924 steps before it repeats a previous state! Clearly, you might need to find a more efficient way to simulate the universe.

  How many steps does it take to reach the first state that exactly matches a previous state?
  """

  @behaviour Day

  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(list) do
    Enum.reduce(list, fn x, acc ->
      div(x * acc, gcd(x, acc))
    end)
  end

  def parse(input) do
    Enum.map(input, fn line ->
      [_ | xyz] = Regex.run(~r/<x=([-\d]+), y=([-\d]+), z=([-\d]+)>/, line)

      [
        # position
        Enum.map(xyz, fn x -> x |> Integer.parse() |> elem(0) end),
        # velocity
        [0, 0, 0]
      ]
    end)
  end

  def add_vectors([a, b, c], [x, y, z]), do: [a + x, b + y, c + z]

  def calc_gravity([[ax, ay, az], _], [[bx, by, bz], _]) do
    [
      if(ax > bx, do: -1, else: if(ax < bx, do: 1, else: 0)),
      if(ay > by, do: -1, else: if(ay < by, do: 1, else: 0)),
      if(az > bz, do: -1, else: if(az < bz, do: 1, else: 0))
    ]
  end

  def apply_gravity(state) do
    Enum.map(state, fn [position, velocity] = object ->
      [
        position,
        Enum.map(state, &calc_gravity(object, &1))
        |> Enum.reduce(&add_vectors/2)
        |> add_vectors(velocity)
      ]
    end)
  end

  def apply_velocity(state) do
    Enum.map(state, fn [position, velocity] ->
      [add_vectors(position, velocity), velocity]
    end)
  end

  def calc_score(state) do
    state
    |> Enum.map(fn [position, velocity] ->
      potential =
        position
        |> Enum.map(&abs/1)
        |> Enum.sum()

      kinetic =
        velocity
        |> Enum.map(&abs/1)
        |> Enum.sum()

      potential * kinetic
    end)
    |> Enum.sum()
  end

  def step(state) do
    state
    |> apply_gravity()
    |> apply_velocity()
  end

  def solve(input) do
    state = parse(input)

    part_1 = 1..1000 |> Enum.reduce(state, fn _, state -> step(state) end) |> calc_score

    part_2 =
      1..1_000_000
      |> Enum.reduce_while([state, 0, 0, 0], fn
        steps, [state, x, y, z] when x == 0 or y == 0 or z == 0 ->
          state = step(state)

          case [state, x, y, z] do
            [[[_, [0 | _]], [_, [0 | _]], [_, [0 | _]], [_, [0 | _]]], 0, _, _] ->
              {:cont, [state, steps, y, z]}

            [[[_, [_, 0, _]], [_, [_, 0, _]], [_, [_, 0, _]], [_, [_, 0, _]]], _, 0, _] ->
              {:cont, [state, x, steps, z]}

            [[[_, [_, _, 0]], [_, [_, _, 0]], [_, [_, _, 0]], [_, [_, _, 0]]], _, _, 0] ->
              {:cont, [state, x, y, steps]}

            _ ->
              {:cont, [state, x, y, z]}
          end

        _steps, [_state, x, y, z] ->
          {:halt, lcm([x, y, z]) * 2}
      end)

    {
      part_1,
      part_2
    }
  end
end
