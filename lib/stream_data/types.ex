defmodule StreamData.Types do
  def generate(module, name) when is_atom(module) and is_atom(name) do
    type = for x = {^name, _type} <- beam_types(module), do: x

    case type do
      [t] ->
        IO.inspect(t)
        do_generate(t)

      _ ->
        msg = """
        Module #{inspect(module)} does not define a type called #{name}.
        """

        raise ArgumentError, msg
    end
  end

  # TODO: Use Code.Typespec when merged in elixir
  defp beam_types(module) do
    with {^module, beam, _file} <- :code.get_object_code(module),
         {:ok, {^module, [abstract_code: {:raw_abstract_v1, abstract_code}]}} <-
           :beam_lib.chunks(beam, [:abstract_code]) do
      for {:attribute, _line, :type, {name, type, _other}} <- abstract_code, do: {name, type}
    else
      _ ->
        msg = """
        Could not find .beam file for Module #{module}.
        Are you sure you have passed in the correct module name?
        """

        raise ArgumentError, msg
    end
  end

  # TODO: Handle unions/recursives here
  defp do_generate({name, type}) when is_atom(name) do
    generate_stream(type)
  end

  defp generate_stream({:type, _, :integer, _}) do
    StreamData.integer()
  end

  defp generate_stream({:type, _, :atom, _}) do
    StreamData.atom(:alphanumeric)
  end

  defp generate_stream({:type, _, :neg_integer, _}) do
    StreamData.negative_integer()
  end

  defp generate_stream({:type, _, :pos_integer, _}) do
    StreamData.positive_integer()
  end

  defp generate_stream({:type, _, :non_neg_integer, _}) do
    StreamData.non_negative_integer()
  end

  defp generate_stream({:type, _, :float, _}) do
    StreamData.float()
  end

  defp generate_stream({:type, _, :reference, _}) do
    StreamData.reference()
  end

  defp generate_stream({:type, _, type, _}) when type in [:any, :term] do
    StreamData.term()
  end

  defp generate_stream({:type, _, bottom, _}) when bottom in [:none, :no_return] do
    msg = """
    Can't generate the bottom type.
    """

    raise ArgumentError, msg
  end

  defp generate_stream({:type, _, :list, []}) do
    StreamData.term()
    |> StreamData.list_of()
  end

  defp generate_stream({:type, _, :list, [type]}) do
    generate_stream(type)
    |> StreamData.list_of()
  end

  defp generate_stream({:type, _, :nonempty_list, [type]}) do
    generate_stream(type)
    |> StreamData.list_of()
    |> StreamData.nonempty()
  end

  defp generate_stream({:type, _, :maybe_improper_list, []}) do
    StreamData.maybe_improper_list_of(
      StreamData.term(),
      StreamData.term()
    )
  end

  defp generate_stream({:type, _, :maybe_improper_list, [type1, type2]}) do
    StreamData.maybe_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
  end

  defp generate_stream({:type, _, :nonempty_improper_list, [type1, type2]}) do
    StreamData.nonempty_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
  end

  defp generate_stream({:type, _, :nonempty_maybe_improper_list, []}) do
    StreamData.maybe_improper_list_of(
      StreamData.term(),
      StreamData.term()
    )
    |> StreamData.nonempty()
  end

  defp generate_stream({:type, _, :nonempty_maybe_improper_list, [type1, type2]}) do
    StreamData.maybe_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
    |> StreamData.nonempty()
  end

  # Literals
  defp generate_stream({type, _, literal}) when type in [:atom, :integer] do
    StreamData.constant(literal)
  end

  defp generate_stream({:type, _, :range, [{:integer, _, lower}, {:integer, _, upper}]}) do
    StreamData.integer(lower..upper)
  end

  defp generate_stream({:type, _, :binary, [{:integer, _, size}, {:integer, _, unit}]}) do
    # Not sure this is right
    StreamData.bitstring(length: size * unit)
  end

  defp generate_stream({:type, _, :bitstring, []}) do
    StreamData.bitstring()
  end

  defp generate_stream({:type, _, nil, []}), do: StreamData.constant([])

  defp generate_stream({:type, _, :nonempty_list, []}) do
    StreamData.term()
    |> StreamData.list_of()
    |> StreamData.nonempty()
  end

  defp generate_stream({:type, _, :tuple, :any}) do
    StreamData.term()
    |> StreamData.list_of()
    |> StreamData.map(&List.to_tuple/1)
  end

  defp generate_stream({:type, _, :tuple, types}) do
    types
    |> Enum.map(&generate_stream/1)
    |> List.to_tuple()
    |> StreamData.tuple()
  end

  defp generate_stream({:type, _, :binary, []}) do
    StreamData.binary()
  end

  defp generate_stream({:type, _, :map, :any}) do
    StreamData.map_of(StreamData.term(), StreamData.term())
  end

  defp generate_stream({:type, _, :map, []}) do
    StreamData.constant(%{})
  end

  defp generate_stream({:type, _, :map, field_types}) do
    field_types
    |> Enum.map(&generate_map_field/1)
    |> Enum.reduce(fn x, acc ->
      StreamData.bind(acc, fn map1 ->
        StreamData.bind(x, fn map2 ->
          Map.merge(map2, map1)
          |> StreamData.constant()
        end)
      end)
    end)
  end

  # Built-in types
  defp generate_stream({:type, _, :arity, []}) do
    StreamData.integer(0..255)
  end

  defp generate_stream({:type, _, :boolean, []}) do
    StreamData.boolean()
  end

  defp generate_stream({:type, _, :byte, []}) do
    StreamData.byte()
  end

  defp generate_stream({:type, _, :char, []}) do
    StreamData.char()
  end

  # Note: This is the type we call charlist()
  defp generate_stream({:type, _, :string, []}) do
    StreamData.char()
    |> StreamData.list_of()
  end

  defp generate_stream({:type, _, :nonempty_string, []}) do
    StreamData.char()
    |> StreamData.list_of()
    |> StreamData.nonempty()
  end

  # TODO: Take args
  defp generate_stream({:remote_type, _, [{:atom, _, module}, {:atom, _, type}, []]}) do
    generate(module, type)
  end

  defp generate_stream({:type, _, :iolist, []}) do
    StreamData.iolist()
  end

  defp generate_stream({:type, _, :iodata, []}) do
    StreamData.iodata()
  end

  defp generate_stream({:type, _, :mfa, []}) do
    module = StreamData.atom(:alphanumeric)
    function = StreamData.atom(:alphanumeric)
    arity = StreamData.integer(0..255)

    StreamData.bind(module, fn m ->
      StreamData.bind(function, fn f ->
        StreamData.bind(arity, fn a ->
          StreamData.constant({m, f, a})
        end)
      end)
    end)
  end

  defp generate_stream({:type, _, x, []}) when x in [:module, :node] do
    StreamData.atom(:alphanumeric)
  end

  defp generate_stream({:type, _, :number, []}) do
    StreamData.one_of([
      StreamData.integer(),
      StreamData.float()
    ])
  end

  defp generate_stream({:type, _, :timeout, []}) do
    StreamData.one_of([
      StreamData.integer(),
      StreamData.constant(:infinity)
    ])
  end

  defp generate_stream(type), do: IO.inspect(type)

  # Generate map keys seperately
  defp generate_map_field({:type, _, :map_field_exact, [{_, _, key}, value]}) do
    value = generate_stream(value)

    StreamData.fixed_map(%{key => value})
  end

  defp generate_map_field({:type, _, :map_field_exact, [key, value]}) do
    StreamData.map_of(
      generate_stream(key),
      generate_stream(value)
    )
    |> StreamData.filter(&(&1 != %{}))
  end

  defp generate_map_field({:type, _, :map_field_assoc, [key, value]}) do
    StreamData.map_of(
      generate_stream(key),
      generate_stream(value)
    )
  end
end
