defmodule StreamData.TypeGenerators do
  def generate(module, name) when is_atom(name) do
    [type|_] = for x = {^name, type} <- beam_types(module), do: x

    generate_stream(type)
  end

  defp beam_types(module) do
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
end
