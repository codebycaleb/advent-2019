defmodule Program do
  defstruct [:input, state: %{}, pointer: 0, relative_pointer: 0, output: []]

  def evaluate_param(program, {param, mode}) do
    case mode do
      0 -> program.state[param]
      1 -> param
      2 -> program.state[program.relative_pointer + param]
    end
  end

  def evaluate_index(program, {param, mode}) do
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
            evaluate_index(program, c),
            evaluate_param(program, a) + evaluate_param(program, b)
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
            evaluate_index(program, c),
            evaluate_param(program, a) * evaluate_param(program, b)
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
            evaluate_index(program, a),
            program.input
          ),
        pointer: program.pointer + 2
    }
  end

  def write(program, a) do
    %{
      program
      | output: [evaluate_param(program, a) | program.output],
        pointer: program.pointer + 2
    }
  end

  def jump_true(program, a, b) do
    case evaluate_param(program, a) do
      0 -> %{program | pointer: program.pointer + 3}
      _ -> %{program | pointer: evaluate_param(program, b)}
    end
  end

  def jump_false(program, a, b) do
    case evaluate_param(program, a) do
      0 -> %{program | pointer: evaluate_param(program, b)}
      _ -> %{program | pointer: program.pointer + 3}
    end
  end

  def less_than(program, a, b, c) do
    case evaluate_param(program, a) < evaluate_param(program, b) do
      true ->
        %{
          program
          | state: Map.put(program.state, evaluate_index(program, c), 1),
            pointer: program.pointer + 4
        }

      false ->
        %{
          program
          | state: Map.put(program.state, evaluate_index(program, c), 0),
            pointer: program.pointer + 4
        }
    end
  end

  def equals(program, a, b, c) do
    case evaluate_param(program, a) == evaluate_param(program, b) do
      true ->
        %{
          program
          | state: Map.put(program.state, evaluate_index(program, c), 1),
            pointer: program.pointer + 4
        }

      false ->
        %{
          program
          | state: Map.put(program.state, evaluate_index(program, c), 0),
            pointer: program.pointer + 4
        }
    end
  end

  def adjust_relative_pointer(program, a) do
    %{
      program
      | relative_pointer: program.relative_pointer + evaluate_param(program, a),
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

  def evaluate(program) do
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
        evaluate(apply(@opcodes[opcode], args))
    end
  end

  def new(code, input \\ nil) do
    %Program{
      input: input,
      state: code |> Enum.with_index() |> Map.new(fn {v, k} -> {k, v} end)
    }
  end
end
