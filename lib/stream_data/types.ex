defmodule StreamData.Types do
  def generate(module, name) when is_atom(module) and is_atom(name) do
    #TODO: Handle missing type
    #TODO: Handle same name, different args
    [{^name, type}|_] = for x = {^name, _type} <- beam_types(module), do: x

    IO.inspect(type)
    generate_stream(type)
  end

  #TODO: Use Code.Typespec when merged in elixir
  defp beam_types(module) do
    #TODO: Warn missing .beam file/not compiled
    with {^module, beam, _file} <- :code.get_object_code(module),
         {:ok, {^module, [abstract_code: {:raw_abstract_v1, abstract_code}]}} <-
           :beam_lib.chunks(beam, [:abstract_code]) do
      for {:attribute, _line, :type, {name, type, _other}} <- abstract_code, do: {name, type}
    end
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
  defp generate_stream({:type, _, :list, [type]}) do
    generate_stream(type)
    |> StreamData.list_of()
  end
  defp generate_stream({:type, _, :nonempty_list, [type]}) do
    generate_stream(type)
    |> StreamData.list_of()
    |> StreamData.nonempty()
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
  defp generate_stream({:type, _, :nonempty_maybe_improper_list, [type1, type2]}) do
    StreamData.maybe_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
    |> StreamData.nonempty
  end
  # Literals
  defp generate_stream({type, _, literal}) when type in [:atom, :integer] do
    StreamData.constant(literal)
  end
  defp generate_stream({:type, _, :range, [{:integer, _, lower}, {:integer, _, upper}]}) do
    StreamData.integer(lower..upper)
  end
  defp generate_stream({:type, _, :binary, [{:integer, _, size}, {:integer, _, unit}]}) do
    #Not sure this is right
    StreamData.bitstring(length: size * unit)
  end
  defp generate_stream({:type, _, :bitstring, []}) do
    StreamData.bitstring
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
    |> List.to_tuple
    |> StreamData.tuple
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
          |> StreamData.constant
        end)
      end)
    end)
  end

  defp generate_stream(type), do: IO.inspect(type)

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
