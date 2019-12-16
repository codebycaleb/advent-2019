require Utils
require Program

defmodule D7 do
  @moduledoc """
  --- Day 7: Amplification Circuit ---
  Based on the navigational maps, you're going to need to send more power to your ship's thrusters to reach Santa in time. To do this, you'll need to configure a series of amplifiers already installed on the ship.

  There are five amplifiers connected in series; each one receives an input signal and produces an output signal. They are connected such that the first amplifier's output leads to the second amplifier's input, the second amplifier's output leads to the third amplifier's input, and so on. The first amplifier's input value is 0, and the last amplifier's output leads to your ship's thrusters.

  --  O-------O  O-------O  O-------O  O-------O  O-------O
  0 ->| Amp A |->| Amp B |->| Amp C |->| Amp D |->| Amp E |-> (to thrusters)
  --  O-------O  O-------O  O-------O  O-------O  O-------O
  The Elves have sent you some Amplifier Controller Software (your puzzle input), a program that should run on your existing Intcode computer. Each amplifier will need to run a copy of the program.

  When a copy of the program starts running on an amplifier, it will first use an input instruction to ask the amplifier for its current phase setting (an integer from 0 to 4). Each phase setting is used exactly once, but the Elves can't remember which amplifier needs which phase setting.

  The program will then call another input instruction to get the amplifier's input signal, compute the correct output signal, and supply it back to the amplifier with an output instruction. (If the amplifier has not yet received an input signal, it waits until one arrives.)

  Your job is to find the largest output signal that can be sent to the thrusters by trying every possible combination of phase settings on the amplifiers. Make sure that memory is not shared or reused between copies of the program.

  Try every combination of phase settings on the amplifiers. What is the highest signal that can be sent to the thrusters?

  --- Part Two ---
  It's no good - in this configuration, the amplifiers can't generate a large enough output signal to produce the thrust you'll need. The Elves quickly talk you through rewiring the amplifiers into a feedback loop:

  --    O-------O  O-------O  O-------O  O-------O  O-------O
  0 -+->| Amp A |->| Amp B |->| Amp C |->| Amp D |->| Amp E |-.
  -- |  O-------O  O-------O  O-------O  O-------O  O-------O |
  -- |                                                        |
  -- '--------------------------------------------------------+
                                                      |
                                                      v
                                               (to thrusters)

  Most of the amplifiers are connected as they were before; amplifier A's output is connected to amplifier B's input, and so on. However, the output from amplifier E is now connected into amplifier A's input. This creates the feedback loop: the signal will be sent through the amplifiers many times.

  In feedback loop mode, the amplifiers need totally different phase settings: integers from 5 to 9, again each used exactly once. These settings will cause the Amplifier Controller Software to repeatedly take input and produce output many times before halting. Provide each amplifier its phase setting at its first input instruction; all further input/output instructions are for signals.

  Don't restart the Amplifier Controller Software on any amplifier during this process. Each one should continue receiving and sending signals until it halts.

  All signals sent or received in this process will be between pairs of amplifiers except the very first signal and the very last signal. To start the process, a 0 signal is sent to amplifier A's input exactly once.

  Eventually, the software on the amplifiers will halt after they have processed the final loop. When this happens, the last output signal from amplifier E is sent to the thrusters. Your job is to find the largest output signal that can be sent to the thrusters using the new phase settings and feedback loop arrangement.

  Try every combination of the new phase settings on the amplifier feedback loop. What is the highest signal that can be sent to the thrusters?
  """

  @behaviour Day

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def part_2_mapping(programs) do
    programs =
      Enum.scan(
        programs,
        fn {:halt, program}, {_, %Program{output: [previous_output | _]}} ->
          program = %{program | input: [previous_output]}
          Program.run_blocking(program)
        end
      )

    {final_status, final_program} = List.last(programs)
    programs = List.replace_at(programs, 0, {final_status, final_program})

    case final_status do
      :halt -> part_2_mapping(programs)
      :ok -> hd(final_program.output)
    end
  end

  def solve(input) do
    input = input |> Utils.to_strings() |> Utils.to_ints()

    program = Program.new(input)

    part_1 =
      0..4
      |> Enum.to_list()
      |> permutations
      |> Enum.map(fn phase_settings ->
        Enum.reduce(
          phase_settings,
          0,
          fn phase, previous_output ->
            %Program{output: [result]} =
              Program.evaluate(%{program | input: [phase, previous_output]})

            result
          end
        )
      end)
      |> Enum.max()

    part_2 =
      5..9
      |> Enum.to_list()
      |> permutations
      |> Enum.map(fn phase_settings ->
        [a | rest] =
          Enum.map(
            phase_settings,
            fn phase ->
              %{program | input: [phase]}
            end
          )

        programs = Enum.map([a | rest], fn program -> Program.run_blocking(program) end)

        programs = [{:halt, %Program{output: [0]}} | programs]
        part_2_mapping(programs)
      end)
      |> Enum.max()

    {
      part_1,
      part_2
    }
  end
end
