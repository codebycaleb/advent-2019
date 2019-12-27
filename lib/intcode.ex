defmodule Program do
  defstruct [:input, state: %{}, pointer: 0, relative_pointer: 0, output: []]

  def param_value(program, {param, mode}) do
    case mode do
      0 -> Map.get(program.state, param, 0)
      1 -> param
      2 -> Map.get(program.state, program.relative_pointer + param, 0)
    end
  end

  def param_index(program, {param, mode}) do
    case mode do
      0 -> param
      2 -> program.relative_pointer + param
    end
  end

  def add(program, a, b, c) do
    %{
      program
      | state:
          Map.put(
            program.state,
            param_index(program, c),
            param_value(program, a) + param_value(program, b)
          ),
        pointer: program.pointer + 4
    }
  end

  def multiply(program, a, b, c) do
    %{
      program
      | state:
          Map.put(
            program.state,
            param_index(program, c),
            param_value(program, a) * param_value(program, b)
          ),
        pointer: program.pointer + 4
    }
  end

  def save(program, a) do
    %{
      program
      | state:
          Map.put(
            program.state,
            param_index(program, a),
            hd(program.input)
          ),
        input: tl(program.input),
        pointer: program.pointer + 2
    }
  end

  def write(program, a) do
    %{
      program
      | output: [param_value(program, a) | program.output],
        pointer: program.pointer + 2
    }
  end

  def jump_true(program, a, b) do
    case param_value(program, a) do
      0 -> %{program | pointer: program.pointer + 3}
      _ -> %{program | pointer: param_value(program, b)}
    end
  end

  def jump_false(program, a, b) do
    case param_value(program, a) do
      0 -> %{program | pointer: param_value(program, b)}
      _ -> %{program | pointer: program.pointer + 3}
    end
  end

  def less_than(program, a, b, c) do
    case param_value(program, a) < param_value(program, b) do
      true ->
        %{
          program
          | state: Map.put(program.state, param_index(program, c), 1),
            pointer: program.pointer + 4
        }

      false ->
        %{
          program
          | state: Map.put(program.state, param_index(program, c), 0),
            pointer: program.pointer + 4
        }
    end
  end

  def equals(program, a, b, c) do
    case param_value(program, a) == param_value(program, b) do
      true ->
        %{
          program
          | state: Map.put(program.state, param_index(program, c), 1),
            pointer: program.pointer + 4
        }

      false ->
        %{
          program
          | state: Map.put(program.state, param_index(program, c), 0),
            pointer: program.pointer + 4
        }
    end
  end

  def adjust_relative_pointer(program, a) do
    %{
      program
      | relative_pointer: program.relative_pointer + param_value(program, a),
        pointer: program.pointer + 2
    }
  end

  def stop(_program), do: :ok

  @opcodes %{
    1 => &Program.add/4,
    2 => &Program.multiply/4,
    3 => &Program.save/2,
    4 => &Program.write/2,
    5 => &Program.jump_true/3,
    6 => &Program.jump_false/3,
    7 => &Program.less_than/4,
    8 => &Program.equals/4,
    9 => &Program.adjust_relative_pointer/2,
    99 => &Program.stop/1
  }

  def get_arity(opcode), do: :erlang.fun_info(@opcodes[opcode])[:arity] - 1

  def fill_modes(modes, arity) do
    diff = arity - length(modes)

    case diff do
      x when x <= 0 -> modes
      1 -> [0 | modes]
      2 -> [0 | [0 | modes]]
      3 -> [0 | [0 | [0 | modes]]]
      x -> Enum.map(1..x, fn _ -> 0 end) ++ modes
    end
  end

  def parse_modes(opcode, encoded_modes) do
    arity = get_arity(opcode)

    encoded_modes
    |> Integer.digits()
    |> fill_modes(arity)
    |> Enum.reverse()
  end

  def parse_operation(operation) do
    # right-most two digits
    opcode = rem(operation, 100)
    modes = parse_modes(opcode, div(operation, 100))
    {opcode, modes}
  end

  def step(program) do
    {opcode, modes} = parse_operation(program.state[program.pointer])
    input = program.input

    case opcode do
      99 ->
        {:halt, program}

      3 when input == [] ->
        {:block, program}

      _ ->
        params =
          1..get_arity(opcode)
          |> Enum.map(fn x -> Map.get(program.state, program.pointer + x) end)
          |> Enum.zip(modes)

        args = [program | params]
        {:ok, apply(@opcodes[opcode], args)}
    end
  end

  defp run_impl({:halt, program}), do: program
  defp run_impl({:ok, program}), do: run_impl(step(program))

  defp run_impl({:block, _}),
    do: raise(ArgumentError, "Program blocked; call run_blocking to handle")

  def run(program), do: run_impl({:ok, program})

  defp run_blocking_impl({:ok, program}), do: run_blocking_impl(step(program))
  defp run_blocking_impl(halt_or_block_result), do: halt_or_block_result
  def run_blocking(program), do: run_blocking_impl({:ok, program})

  def hack(program, entry_point, code) do
    converted = code |> Enum.with_index(entry_point) |> Map.new(fn {v, k} -> {k, v} end)
    %{program | state: Map.merge(program.state, converted)}
  end

  def new(code, input \\ nil) do
    %Program{
      input: List.wrap(input),
      state: code |> Enum.with_index() |> Map.new(fn {v, k} -> {k, v} end)
    }
  end

  def stringify_instruction(state, index, relative_pointer \\ 0, evaluate \\ false) do
    {opcode, modes} =
      try do
        parse_operation(state[index])
      rescue
        FunctionClauseError -> {state[index], nil}
      end

    if modes != nil do
      params =
        case opcode do
          99 ->
            []

          _ ->
            1..get_arity(opcode)
            |> Enum.map(fn x -> state[index + x] end)
            |> Enum.zip(modes)
        end

      opcode_string =
        case opcode do
          1 -> "ADDI"
          2 -> "MULI"
          3 -> "SAVE"
          4 -> "OUTP"
          5 -> "TJMP"
          6 -> "FJMP"
          7 -> "CLTI"
          8 -> "CEQI"
          9 -> "AJRP"
          99 -> "HALT"
        end

      params_string =
        params
        |> Enum.with_index()
        |> Enum.map(fn {{param, mode}, i} ->
          case evaluate and i < get_arity(opcode) - 1 do
            true ->
              case mode do
                0 -> to_string(state[param])
                1 -> to_string(param)
                2 -> to_string(state[relative_pointer])
              end

            false ->
              case mode do
                0 -> "[#{param}]"
                1 -> to_string(param)
                2 -> "[RP " <> if(param > 0, do: "+", else: "-") <> " #{abs(param)}]"
              end
          end
        end)
        |> Enum.map(fn x -> String.pad_leading(x, 10) end)
        |> Enum.join("\t")
        |> String.trim_trailing()

      opcode_string <> "\t" <> params_string
    else
      "DATA" <> "\t" <> String.pad_leading(to_string(opcode), 10)
    end
  end

  defp decompile(state, index, buffer) when index >= map_size(state),
    do: buffer |> Enum.reverse() |> Enum.join("\n")

  defp decompile(state, index, buffer) do
    index_string =
      index
      |> to_string
      |> String.pad_leading(4, "0")

    instruction = stringify_instruction(state, index)
    line = index_string <> "\t" <> instruction
    buffer = [line | buffer]

    opcode = rem(state[index], 100)

    index =
      if opcode in ([99] ++ Enum.to_list(1..9)),
        do: index + 1 + get_arity(opcode),
        else: index + 1

    decompile(state, index, buffer)
  end

  def decompile(program) do
    decompile(program.state, 0, [])
  end

  def compile(code) do
    code
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split("\t")
      # drop index
      |> Enum.drop(1)
    end)
    |> Enum.flat_map(fn
      ["DATA", x] ->
        [x |> String.trim() |> Integer.parse() |> elem(0)]

      [instruction | args] ->
        opcode =
          case instruction do
            "ADDI" -> 1
            "MULI" -> 2
            "SAVE" -> 3
            "OUTP" -> 4
            "TJMP" -> 5
            "FJMP" -> 6
            "CLTI" -> 7
            "CEQI" -> 8
            "AJRP" -> 9
            "HALT" -> 99
          end

        modes =
          args
          |> Enum.map(&String.trim/1)
          |> Enum.map(fn arg ->
            case Integer.parse(arg) do
              {_, ""} -> 1
              :error -> if String.contains?(arg, "RP"), do: 2, else: 0
            end
          end)
          |> Enum.reverse()
          |> Integer.undigits()

        opcode = modes * 100 + opcode

        args =
          args
          |> Enum.map(&String.trim/1)
          |> Enum.map(fn arg ->
            case Integer.parse(arg) do
              {x, ""} ->
                x

              :error ->
                if String.contains?(arg, "RP") do
                  arg |> String.replace(~r/[\[\]RP +]/, "") |> Integer.parse() |> elem(0)
                else
                  arg |> String.replace(~r/[\[\]]/, "") |> Integer.parse() |> elem(0)
                end
            end
          end)

        List.flatten([opcode, args])
    end)
  end

  defp inspect({status, program}, count, history) do
    prompt = "\nWhat would you like to do? 'h' for help\n"

    help = """
    (h)elp: Display this text
    (n)ext: Evaluate the next instruction
    (b)ack: Rewind history back one step
    (c)ontinue: Continue evaluating the program until the program halts
    (p)rint: Prints the current instruction
    (i)nspect: Inspect what is stored at an index (expects one argument: the index)
    (r)ecent: Lists the recent events (expects one argument: the number of recent events; default: 10)
    (s)tats: Displays current status (current pointer, relative pointer, how many instructions have been executed)
    (t)able: Displays current program code state as a table
    (e)nter: Enter input
    (o)utput: Displays program output
    (q)uit: Quits the inspector and returns the current program
    """

    status_printer = fn count, pointer, relative ->
      """
      Instructions executed: #{count}
      Pointer: #{pointer}
      Relative pointer: #{relative}
      """
      |> IO.puts()
    end

    state_printer = fn state, index ->
      (["\t"] ++
         (0..9
          |> Enum.to_list()
          |> Enum.map(fn x -> x |> to_string |> String.pad_leading(7) end)
          |> Enum.intersperse("\t")))
      |> IO.puts()

      state
      |> Enum.map(fn {i, v} -> {div(i, 10) * 10, rem(i, 10), v} end)
      |> Enum.sort()
      |> Enum.group_by(fn {y, _x, _v} -> y end, fn {_y, x, v} -> {x, v} end)
      |> Enum.sort()
      |> Enum.map(fn {y, list} ->
        [String.pad_leading(to_string(y), 4, "0"), "\t"] ++
          (list
           |> Enum.sort()
           |> Enum.map(fn {x, v} ->
             if y + x == index do
               # note that the rest of the row will probably be screwed up because the reset character, but oh well!
               # red + bright + reset + 7 = 5 + 4 + 4 + 7 = 20
               String.pad_leading(
                 IO.ANSI.red() <> IO.ANSI.bright() <> to_string(v) <> IO.ANSI.reset(),
                 20
               )
             else
               v = String.pad_leading(to_string(v), 7)
               unless byte_size(v) > 7, do: v, else: String.slice(v, 0, 4) <> "..."
             end
           end)
           |> Enum.intersperse("\t"))
      end)
      |> Enum.join("\n")
      |> IO.puts()
    end

    input = IO.gets(prompt)
    command = input |> String.at(0) |> String.downcase()
    args = input |> String.split() |> Enum.drop(1)

    case command do
      "h" ->
        IO.puts(help)
        inspect({status, program}, count, history)

      "q" ->
        IO.puts("Okay! Thanks for inspecting!")
        program

      "n" ->
        {new_status, new_program} = step(program)

        new_count =
          cond do
            new_status == :ok -> count + 1
            new_status == :halt and status != :halt -> count + 1
            new_status != :ok and status == :ok -> count + 1
            true -> count
          end

        if count == new_count do
          inspect({status, program}, count, history)
        else
          inspect({new_status, new_program}, new_count, [{status, program} | history])
        end

      "b" ->
        {previous, history} = List.pop_at(history, 0, {status, program})
        inspect(previous, max(0, count - 1), history)

      "c" ->
        result =
          Stream.unfold({{status, program}, count}, fn
            {{:halt, program}, count} -> {{:halt, program, count}, nil}
            {{:block, program}, count} -> {{:block, program, count}, nil}
            {{:ok, program}, count} -> {{:ok, program}, {step(program), count + 1}}
            nil -> nil
          end)

        reversed = Enum.reverse(result)
        [{new_status, new_program, new_count} | new_history] = reversed
        inspect({new_status, new_program}, new_count, new_history ++ history)

      "s" ->
        status_printer.(count, program.pointer, program.relative_pointer)
        inspect({status, program}, count, history)

      "t" ->
        state_printer.(program.state, program.pointer)
        inspect({status, program}, count, history)

      "i" ->
        {index, _} = args |> Enum.at(0, "-1") |> Integer.parse()
        value = Map.get(program.state, index)

        if value == nil,
          do:
            IO.warn(
              "No value present at index #{index} (defaults to -1 if index argument could not be parsed).",
              []
            ),
          else: IO.puts("The value present at index #{index} is #{value}.")

        inspect({status, program}, count, history)

      "p" ->
        IO.puts(
          stringify_instruction(program.state, program.pointer, program.relative_pointer, true)
        )

        inspect({status, program}, count, history)

      "e" ->
        input = Enum.at(args, 0)

        if input == nil do
          IO.puts("Entering input requires 1 arg")
          inspect({status, program}, count, history)
        else
          {input, _} = Integer.parse(input)
          program = %{program | input: [input | program.input]}
          inspect({status, program}, count, history)
        end

      "o" ->
        IO.inspect(program.output)
        inspect({status, program}, count, history)

      "r" ->
        {recent, _} = args |> Enum.at(0, "10") |> Integer.parse()

        history
        |> Enum.slice(0, recent)
        |> Enum.reverse()
        |> Enum.map(fn {_, program} ->
          stringify_instruction(program.state, program.pointer, program.relative_pointer, true)
        end)
        |> Enum.join("\n")
        |> IO.puts()

        inspect({status, program}, count, history)

      _ ->
        IO.puts("Sorry, I didn't quite understand that. Please try using 'h' for help.")
        inspect({status, program}, count, history)
    end
  end

  def inspect(program) do
    inspect({:ok, program}, 0, [])
  end
end
