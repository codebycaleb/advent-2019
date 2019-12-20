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

  def run(program) do
    {opcode, modes} = parse_operation(program.state[program.pointer])

    case opcode do
      99 ->
        program

      _ ->
        params =
          1..get_arity(opcode)
          |> Enum.map(fn x -> Map.get(program.state, program.pointer + x) end)
          |> Enum.zip(modes)

        args = [program | params]
        run(apply(@opcodes[opcode], args))
    end
  end

  def run_blocking(program) do
    {opcode, modes} = parse_operation(program.state[program.pointer])
    # used in guard below
    input = program.input

    case opcode do
      99 ->
        {:ok, program}

      3 when input == [] ->
        {:halt, program}

      _ ->
        params =
          1..get_arity(opcode)
          |> Enum.map(fn x -> Map.get(program.state, program.pointer + x) end)
          |> Enum.zip(modes)

        args = [program | params]
        run_blocking(apply(@opcodes[opcode], args))
    end
  end

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

  defp decompile(state, index, buffer) when index >= map_size(state),
    do: buffer |> Enum.reverse() |> Enum.join("\n")

  defp decompile(state, index, buffer) do
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
        |> Enum.map(fn {param, mode} ->
          case mode do
            0 -> "[#{param}]"
            1 -> param
            2 -> if param > 0, do: "[RP + #{param}]", else: "[RP - #{abs(param)}]"
          end
        end)
        |> Enum.map(fn x -> x |> to_string |> String.pad_leading(10) end)
        |> Enum.join("\t")

      index_string =
        index
        |> to_string
        |> String.pad_leading(4, "0")

      buffer = [
        String.trim(Enum.join([index_string, opcode_string, params_string], "\t")) | buffer
      ]

      decompile(state, index + 1 + length(params), buffer)
    else
      index_string = String.pad_leading(to_string(index), 4, "0")
      opcode_string = String.pad_leading(to_string(opcode), 10)

      decompile(state, index + 1, [
        Enum.join([index_string, "DATA", opcode_string], "\t") | buffer
      ])
    end
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
end
