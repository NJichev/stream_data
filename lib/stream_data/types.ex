defmodule StreamData.Types do
  import StreamData

  @doc """
  """
  def generate(module, name, args \\ [])

  def generate(module, name, args) when is_atom(module) and is_atom(name) and is_list(args) do
    type = for x = {^name, _type} <- beam_types(module), do: x

    # pick correct type, when multiple
    # Validate outer is list/map/tuple when having args
    # Convert args
    # put args in type tuple
    case type do
      [] ->
        msg = """
        Module #{inspect(module)} does not define a type called #{name}.
        """

        raise ArgumentError, msg

      types when is_list(types) ->
        pick_type(types, args)
        |> do_generate(args)
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
        Could not find .beam file for Module #{inspect(module)}.
        Are you sure you have passed in the correct module name?
        """

        raise ArgumentError, msg
    end
  end

  defp pick_type(types, args) do
    len = length(args)
    res = for {_name, t} = type <- types, vars(t) == len, do: type

    case res do
      [t] ->
        t

      _ ->
        raise ArgumentError, "Not enough arguments passed"
    end
  end

  defp vars({:var, _, _}), do: 1

  defp vars({:type, _, _, types}) do
    vars(types)
  end

  defp vars(types) when is_list(types) do
    types
    |> Enum.map(&vars(&1))
    |> Enum.sum()
  end

  defp vars(_), do: 0

  # TODO: Handle unions/recursives here
  defp do_generate({name, type}, args) when is_atom(name) do
    put_args(type, args)
    |> IO.inspect()
    |> generate_stream()
  end

  defp put_args({:type, line, name, args_with_var}, args) do
    {res, []} = replace_var(args_with_var, args)
    {:type, line, name, res}
  end

  defp put_args(type, _args), do: type

  # There has to be a better way.
  def replace_var([{:type, line, name, types} | tail], args) do
    {x, rest_args} = replace_var(types, args)
    {result, rest_args} = replace_var(tail, rest_args)
    {[{:type, line, name, x} | result], rest_args}
  end

  def replace_var([{:var, _, _} | tail1], [type | tail2]) do
    {result, r} = replace_var(tail1, tail2)
    {[type | result], r}
  end

  def replace_var([t | tail], args) do
    {res, r} = replace_var(tail, args)
    {[t | res], r}
  end

  def replace_var(l, a), do: {l, a}

  defp generate_stream({:type, _, :integer, _}) do
    integer()
  end

  defp generate_stream({:type, _, :atom, _}) do
    atom(:alphanumeric)
  end

  defp generate_stream({:type, _, :neg_integer, _}) do
    negative_integer()
  end

  defp generate_stream({:type, _, :pos_integer, _}) do
    positive_integer()
  end

  defp generate_stream({:type, _, :non_neg_integer, _}) do
    non_negative_integer()
  end

  defp generate_stream({:type, _, :float, _}) do
    float()
  end

  defp generate_stream({:type, _, :reference, _}) do
    reference()
  end

  defp generate_stream({:type, _, type, _}) when type in [:any, :term] do
    term()
  end

  defp generate_stream({:type, _, bottom, _}) when bottom in [:none, :no_return] do
    msg = """
    Cannot generate types of type bottom.
    """

    raise ArgumentError, msg
  end

  defp generate_stream({:type, _, :list, []}) do
    term()
    |> list_of()
  end

  defp generate_stream({:type, _, :list, [type]}) do
    generate_stream(type)
    |> list_of()
  end

  defp generate_stream({:type, _, :nonempty_list, [type]}) do
    generate_stream(type)
    |> list_of()
    |> nonempty()
  end

  defp generate_stream({:type, _, :maybe_improper_list, []}) do
    maybe_improper_list_of(
      term(),
      term()
    )
  end

  defp generate_stream({:type, _, :maybe_improper_list, [type1, type2]}) do
    maybe_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
  end

  defp generate_stream({:type, _, :nonempty_improper_list, [type1, type2]}) do
    nonempty_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
  end

  defp generate_stream({:type, _, :nonempty_maybe_improper_list, []}) do
    maybe_improper_list_of(
      term(),
      term()
    )
    |> nonempty()
  end

  defp generate_stream({:type, _, :nonempty_maybe_improper_list, [type1, type2]}) do
    maybe_improper_list_of(
      generate_stream(type1),
      generate_stream(type2)
    )
    |> nonempty()
  end

  # Literals
  defp generate_stream({type, _, literal}) when type in [:atom, :integer] do
    constant(literal)
  end

  defp generate_stream({:type, _, :range, [{:integer, _, lower}, {:integer, _, upper}]}) do
    integer(lower..upper)
  end

  defp generate_stream({:type, _, :binary, [{:integer, _, size}, {:integer, _, unit}]}) do
    # Not sure this is right
    bitstring(length: size * unit)
  end

  defp generate_stream({:type, _, :bitstring, []}) do
    bitstring()
  end

  defp generate_stream({:type, _, nil, []}), do: constant([])

  defp generate_stream({:type, _, :nonempty_list, []}) do
    term()
    |> list_of()
    |> nonempty()
  end

  defp generate_stream({:type, _, :tuple, :any}) do
    term()
    |> list_of()
    |> map(&List.to_tuple/1)
  end

  defp generate_stream({:type, _, :tuple, types}) do
    types
    |> Enum.map(&generate_stream/1)
    |> List.to_tuple()
    |> tuple()
  end

  defp generate_stream({:type, _, :binary, []}) do
    binary()
  end

  defp generate_stream({:type, _, :map, :any}) do
    map_of(term(), term())
  end

  defp generate_stream({:type, _, :map, []}) do
    constant(%{})
  end

  defp generate_stream({:type, _, :map, field_types}) do
    field_types
    |> Enum.map(&generate_map_field/1)
    |> Enum.reduce(fn x, acc ->
      bind(acc, fn map1 ->
        bind(x, fn map2 ->
          Map.merge(map2, map1)
          |> constant()
        end)
      end)
    end)
  end

  # Built-in types
  defp generate_stream({:type, _, :arity, []}) do
    integer(0..255)
  end

  defp generate_stream({:type, _, :boolean, []}) do
    boolean()
  end

  defp generate_stream({:type, _, :byte, []}) do
    byte()
  end

  defp generate_stream({:type, _, :char, []}) do
    char()
  end

  # Note: This is the type we call charlist()
  defp generate_stream({:type, _, :string, []}) do
    char()
    |> list_of()
  end

  defp generate_stream({:type, _, :nonempty_string, []}) do
    char()
    |> list_of()
    |> nonempty()
  end

  defp generate_stream({:remote_type, _, [{:atom, _, module}, {:atom, _, type}, args]}) do
    generate(module, type, args)
  end

  defp generate_stream({:type, _, :iolist, []}) do
    iolist()
  end

  defp generate_stream({:type, _, :iodata, []}) do
    iodata()
  end

  defp generate_stream({:type, _, :mfa, []}) do
    module = atom(:alphanumeric)
    function = atom(:alphanumeric)
    arity = integer(0..255)

    bind(module, fn m ->
      bind(function, fn f ->
        bind(arity, fn a ->
          constant({m, f, a})
        end)
      end)
    end)
  end

  defp generate_stream({:type, _, x, []}) when x in [:module, :node] do
    atom(:alphanumeric)
  end

  defp generate_stream({:type, _, :number, []}) do
    one_of([
      integer(),
      float()
    ])
  end

  defp generate_stream({:type, _, :timeout, []}) do
    one_of([
      integer(),
      constant(:infinity)
    ])
  end

  # Unions
  defp generate_stream({:type, _, :union, types}) do
    types
    |> Enum.map(&generate_stream(&1))
    |> one_of
  end

  defp generate_stream(type), do: IO.inspect(type)

  # Generate map keys seperately
  defp generate_map_field({:type, _, :map_field_exact, [{_, _, key}, value]}) do
    value = generate_stream(value)

    fixed_map(%{key => value})
  end

  defp generate_map_field({:type, _, :map_field_exact, [key, value]}) do
    map_of(
      generate_stream(key),
      generate_stream(value)
    )
    |> filter(&(&1 != %{}))
  end

  defp generate_map_field({:type, _, :map_field_assoc, [key, value]}) do
    map_of(
      generate_stream(key),
      generate_stream(value)
    )
  end

  defp char() do
    integer(0..0x10FFFF)
  end
end
