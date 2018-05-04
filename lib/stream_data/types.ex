defmodule StreamData.Types do
  def generate(module, name) when is_atom(name) do
    #TODO: Handle missing type
    #TODO: Handle same name, different args
    [type|_] = for x = {^name, _type} <- beam_types(module), do: x

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

  defp generate_stream({name, {:type, _, :integer, _}}) when is_atom(name) do
    StreamData.integer()
  end
  defp generate_stream({name, {:type, _, :atom, _}}) when is_atom(name) do
    StreamData.atom(:alphanumeric)
  end
  defp generate_stream({name, {:type, _, :neg_integer, _}}) when is_atom(name) do
    StreamData.negative_integer()
  end
  defp generate_stream({name, {:type, _, :pos_integer, _}}) when is_atom(name) do
    StreamData.positive_integer()
  end
  defp generate_stream({name, {:type, _, :non_neg_integer, _}}) when is_atom(name) do
    StreamData.non_negative_integer()
  end
  defp generate_stream({name, {:type, _, :float, _}}) when is_atom(name) do
    StreamData.float()
  end
  defp generate_stream({name, {:type, _, :reference, _}}) when is_atom(name) do
    StreamData.reference()
  end
  defp generate_stream({name, {:type, _, type, _}}) when is_atom(name) and type in [:any, :term] do
    StreamData.term()
  end
  defp generate_stream({name, {:type, _, bottom, _}}) when is_atom(name) and bottom in [:none, :no_return] do
    msg = """
    Can't generate the bottom type.
    """
    raise ArgumentError, msg
  end
  defp generate_stream({name, {:type, _, :list, [type]}}) when is_atom(name) do
    generate_stream({:anonymous, type})
    |> StreamData.list_of()
  end
  defp generate_stream({name, {:type, _, :nonempty_list, [type]}}) when is_atom(name) do
    generate_stream({:anonymous, type})
    |> StreamData.list_of()
    |> StreamData.nonempty()
  end
  defp generate_stream({name, {:type, _, :maybe_improper_list, [type1, type2]}}) when is_atom(name) do
    StreamData.maybe_improper_list_of(
      generate_stream({:anonymous, type1}),
      generate_stream({:anonymous, type2})
    )
  end
  defp generate_stream({name, {:type, _, :nonempty_improper_list, [type1, type2]}}) when is_atom(name) do
    StreamData.nonempty_improper_list_of(
      generate_stream({:anonymous, type1}),
      generate_stream({:anonymous, type2})
    )
  end
  defp generate_stream({name, {:type, _, :nonempty_maybe_improper_list, [type1, type2]}}) when is_atom(name) do
    StreamData.maybe_improper_list_of(
      generate_stream({:anonymous, type1}),
      generate_stream({:anonymous, type2})
    )
    |> StreamData.nonempty
  end
  # Literals
  defp generate_stream({name, {type, _, literal}}) when is_atom(name) and type in [:atom, :integer] do
    StreamData.constant(literal)
  end


  defp generate_stream(type), do: IO.inspect(type)
end
