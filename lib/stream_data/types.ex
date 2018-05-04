defmodule StreamData.Types do
  def generate(module, name) when is_atom(name) do
    [type|_] = for x = {^name, _type} <- beam_types(module), do: x

    generate_stream(type)
  end

  defp beam_types(module) do
    #TODO: Warn missing .beam file
    with {^module, beam, _file} <- :code.get_object_code(module),
         {:ok, {^module, [abstract_code: {:raw_abstract_v1, abstract_code}]}} <-
           :beam_lib.chunks(beam, [:abstract_code]) do
      for {:attribute, _line, :type, {name, type, _other}} <- abstract_code, do: {name, type}
    end
  end
Types
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
  defp generate_stream(type), do: IO.inspect(type)
end
