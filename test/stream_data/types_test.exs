defmodule StreamData.TypesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias StreamData.Types
  alias StreamDataTest.AllTypes

  # test that all types specified in lib/elixir/pages/Typespecs.md can be generated
  test "any" do
    data = generate_data(:basic_any)

    check all term <- data, max_runs: 25 do
      assert is_term(term)
    end
  end

  test "none" do
    assert_raise(ArgumentError, fn ->
      generate_data(:basic_none)
    end)
  end

  test "atom" do
    data = generate_data(:basic_atom)

    check all x <- data, do: assert(is_atom(x))
  end

  test "map" do
    data = generate_data(:basic_map)

    check all x <- data, max_runs: 25 do
      assert is_map(x)
    end
  end

  test "pid"
  test "port"

  test "references" do
    data = generate_data(:basic_reference)

    check all x <- data, do: assert(is_reference(x))
  end

  test "struct"

  test "tuple" do
    data = generate_data(:basic_tuple)

    check all x <- data, max_runs: 25 do
      assert is_tuple(x)
    end
  end

  # Numbers
  test "float" do
    data = generate_data(:basic_float)

    check all x <- data do
      assert is_float(x)
    end
  end

  test "integer" do
    data = generate_data(:basic_integer)

    check all x <- data, do: assert(is_integer(x))
  end

  test "neg_integer" do
    data = generate_data(:basic_neg_integer)

    check all x <- data do
      assert is_integer(x)
      assert x < 0
    end
  end

  test "non_neg_integer" do
    data = generate_data(:basic_non_neg_integer)

    check all x <- data do
      assert is_integer(x)
      assert x >= 0
    end
  end

  test "pos_integer" do
    data = generate_data(:basic_pos_integer)

    check all x <- data do
      assert is_integer(x)
      assert x > 0
    end
  end

  # Lists
  describe "lists" do
    test "basic lists" do
      data = generate_data(:basic_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert Enum.all?(list, fn x -> is_integer(x) end)
      end
    end

    test "nested lists" do
      data = generate_data(:nested_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)

        assert Enum.all?(list, fn x ->
                 is_list(x) and Enum.all?(x, &is_integer(&1))
               end)
      end
    end
  end

  describe "nonempty_list" do
    test "basic nonempty list" do
      data = generate_data(:basic_nonempty_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert length(list) > 0
        assert Enum.all?(list, fn x -> is_integer(x) end)
      end
    end

    test "nested nonempty list" do
      data = generate_data(:nested_nonempty_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert length(list) > 0

        assert Enum.all?(list, fn x ->
                 is_list(x) and Enum.all?(x, &is_integer(&1))
               end)
      end
    end
  end

  test "maybe_improper_list" do
    data = generate_data(:basic_maybe_improper_list_type)

    check all list <- data do
      each_improper_list(list, &assert(is_integer(&1)), &assert(is_atom(&1) or is_integer(&1)))
    end
  end

  test "nonempty_improper_list" do
    data = generate_data(:basic_nonempty_improper_list_type)

    check all list <- data do
      assert list != []
      each_improper_list(list, &assert(is_integer(&1)), &assert(is_atom(&1)))
    end
  end

  test "nonempty_maybe_improper_list" do
    data = generate_data(:basic_nonempty_maybe_improper_list_type)

    check all list <- data do
      assert list != []
      each_improper_list(list, &assert(is_integer(&1)), &assert(is_atom(&1) or is_integer(&1)))
    end
  end

  # Literals
  describe "literals" do
    test "atom" do
      data = generate_data(:literal_atom)

      check all x <- data do
        assert x == :atom
      end
    end

    test "special atom" do
      data = generate_data(:literal_special_atom)

      check all x <- data do
        assert x == false
      end
    end

    test "integer" do
      data = generate_data(:literal_integer)

      check all x <- data do
        assert x == 1
      end
    end

    test "range" do
      data = generate_data(:literal_integers)

      check all x <- data do
        assert is_integer(x)
        assert x in 0..10
      end
    end

    test "bitstrings" do
      data = generate_data(:literal_empty_bitstring)

      check all x <- data do
        assert x == ""
      end
    end

    test "bitstrings with size 0" do
      data = generate_data(:literal_size_0)

      check all x <- data do
        assert "" == x
      end
    end

    test "bitstrings with unit 1" do
      data = generate_data(:literal_unit_1)

      check all x <- data do
        assert x == ""
      end
    end

    test "bitstrings with size 1 and unit 8" do
      data = generate_data(:literal_size_1_unit_8)

      check all x <- data do
        assert <<_::1*8>> = x
      end
    end

    test "functions"

    test "list type" do
      data = generate_data(:literal_list_type)

      check all x <- data do
        assert is_list(x)
        assert Enum.all?(x, &is_integer(&1))
      end
    end

    test "empty list" do
      data = generate_data(:literal_empty_list)

      check all x <- data do
        assert x == []
      end
    end

    test "nonempty list" do
      data = generate_data(:literal_list_nonempty)

      check all x <- data, max_runs: 25 do
        assert is_list(x)
        assert x != []
      end
    end

    test "nonempty list with type" do
      data = generate_data(:literal_nonempty_list_type)

      check all x <- data, max_runs: 25 do
        assert is_list(x)
        assert x != []
        assert Enum.all?(x, &is_atom(&1))
      end
    end

    test "keyword list fixed key" do
      data = generate_data(:literal_keyword_list_fixed_key)

      check all x <- data do
        for {:key, int} <- x, do: assert(is_integer(int))
        assert is_list(x)
      end
    end

    test "keyword list fixed key variant 2" do
      data = generate_data(:literal_keyword_list_fixed_key2)

      check all x <- data do
        assert is_list(x)
        for {:key, int} <- x, do: assert(is_integer(int))
      end
    end

    test "keyword list with type as a key" do
      data = generate_data(:literal_keyword_list_type_key)

      check all x <- data do
        assert is_list(x)
        for {bin, int} <- x, do: assert(is_integer(int) and is_binary(bin))
      end
    end

    test "empty map" do
      data = generate_data(:literal_empty_map)

      check all x <- data do
        assert x == %{}
      end
    end

    test "map with fixed key" do
      data = generate_data(:literal_map_with_key)

      check all x <- data, max_runs: 25 do
        %{key: int} = x
        assert is_map(x)
        assert is_integer(int)
      end
    end

    test "map with optional key" do
      data = generate_data(:literal_map_with_optional_key)

      check all x <- data, max_runs: 25 do
        assert is_map(x)

        assert Map.keys(x) |> Enum.all?(fn k -> is_bitstring(k) end)
        assert Map.values(x) |> Enum.all?(fn v -> is_integer(v) end)
      end
    end

    test "map with required keys" do
      data = generate_data(:literal_map_with_required_key)

      check all x <- data, max_runs: 25 do
        assert is_map(x)
        assert x != %{}

        assert Map.keys(x) |> Enum.all?(fn k -> is_bitstring(k) end)
        assert Map.values(x) |> Enum.all?(fn v -> is_integer(v) end)
      end
    end

    test "map with required and optional key" do
      data = generate_data(:literal_map_with_required_and_optional_key)

      check all x <- data, max_runs: 25 do
        assert is_map(x)

        %{key: int} = x
        map = Map.delete(x, :key)
        assert is_integer(int)

        assert Map.keys(map) |> Enum.all?(fn k -> is_bitstring(k) end)
        assert Map.values(map) |> Enum.all?(fn v -> is_integer(v) end)
      end
    end

    test "struct with all fields any type" do
      data = generate_data(:literal_struct_all_fields_any_type)

      check all x <- data, max_runs: 25 do
        assert %StreamDataTest.AllTypes.SomeStruct{key: value} = x
        assert is_term(value)
      end
    end

    test "struct with all fields key type" do
      data = generate_data(:literal_struct_all_fields_key_type)

      check all x <- data, max_runs: 25 do
        assert %StreamDataTest.AllTypes.SomeStruct{key: value} = x
        assert is_integer(value)
      end
    end

    test "empty tuple" do
      data = generate_data(:literal_empty_tuple)

      check all x <- data, do: assert(x == {})
    end

    test "2 element tuple with fixed and random type" do
      data = generate_data(:literal_2_element_tuple)

      check all {1, x} <- data, do: assert(is_atom(x))
    end
  end

  describe "builtin types" do
    test "term" do
      data = generate_data(:builtin_term)

      check all term <- data, max_runs: 25 do
        is_term(term)
      end
    end

    test "arity" do
      data = generate_data(:builtin_arity)

      check all x <- data do
        assert is_integer(x)
        assert x in 0..255
      end
    end

    test "as_boolean"

    test "binary" do
      data = generate_data(:builtin_binary)

      check all x <- data, do: assert(is_binary(x))
    end

    test "bitstring" do
      data = generate_data(:builtin_bitstring)

      check all x <- data, do: assert(is_bitstring(x))
    end

    test "boolean" do
      data = generate_data(:builtin_boolean)

      check all x <- data, do: assert(is_boolean(x))
    end

    test "byte" do
      data = generate_data(:builtin_byte)

      check all x <- data do
        assert is_integer(x)
        assert x in 0..255
      end
    end

    test "char" do
      data = generate_data(:builtin_char)

      check all x <- data do
        assert is_integer(x)
        assert x in 0..0x10FFFF
      end
    end

    test "charlist" do
      data = generate_data(:builtin_charlist)

      check all x <- data do
        assert is_list(x)

        assert Enum.all?(x, &(&1 in 0..0x10FFFF))
      end
    end

    test "nonempty charlist" do
      data = generate_data(:builtin_nonempty_charlist)

      check all x <- data do
        assert is_list(x)
        assert x != []

        assert Enum.all?(x, &(&1 in 0..0x10FFFF))
      end
    end

    test "fun"
    test "function"

    test "identifier" # Depends on ports/pids/reference

    test "iolist" do
      data = generate_data(:builtin_iolist)

      check all x <- data do
        assert is_iolist(x)
      end
    end

    test "iodata" do
      data = generate_data(:builtin_iodata)

      check all x <- data do
        assert is_binary(x) or is_iolist(x)
      end
    end

    test "keyword" do
      data = generate_data(:builtin_keyword)

      check all x <- data, max_runs: 25 do
        assert is_list(x)
        Enum.each(x, fn {k, v} ->
          assert is_atom(k)
          assert is_term(v)
        end)
      end
    end

    #TODO:parameterized types - there is not cool support for list and map
    test "parameterized keyword" do
      data = generate_data(:builtin_keyword_value_type)

      check all x <- data, max_runs: 25 do
        assert is_list(x)
        Enum.each(x, fn {k, v} ->
          assert is_atom(k)
          assert is_integer(v)
        end)
      end
    end

    test "list" do
      data = generate_data(:builtin_list)

      check all x <- data, max_runs: 25 do
        assert is_list(x)
      end
    end

    test "nonempty_list" do
      data = generate_data(:builtin_nonempty_list)

      check all x <- data, max_runs: 25 do
        assert is_list(x)
        assert x != []
      end
    end

    test "maybe_improper_list" do
      data = generate_data(:builtin_maybe_improper_list)

      check all list <- data, max_runs: 25 do
        each_improper_list(list, &assert(is_term(&1)), &assert(is_term(&1)))
      end
    end

    test "nonempty_maybe_improper_list" do
      data = generate_data(:builtin_nonempty_maybe_improper_list)

      check all list <- data, max_runs: 25 do
        assert list != []
        each_improper_list(list, &assert(is_term(&1)), &assert(is_term(&1)))
      end
    end

    test "mfa" do
      data = generate_data(:builtin_mfa)

      check all {module, function, arity} <- data, max_runs: 25 do
        assert is_atom(module)
        assert is_atom(function)
        assert is_integer(arity)
        assert arity in 0..255
      end
    end

    test "module" do
      data = generate_data(:builtin_module)

      check all x <- data, do: assert is_atom(x)
    end

    test "no_return" do
      assert_raise(ArgumentError, fn ->
        generate_data(:builtin_no_return)
      end)
    end

    test "node" do
      data = generate_data(:builtin_node)

      check all x <- data, do: assert is_atom(x)
    end

    test "number" do
      data = generate_data(:builtin_number)

      check all x <- data, do: assert is_number(x)
    end

    test "struct"

    test "timeout" do
      data = generate_data(:builtin_timeout)

      check all x <- data do
        assert x == :infinity or is_integer(x)
      end
    end
  end

  # TODO: Delete if whole file is moved to stream_data.ex
  defp each_improper_list([], _head_fun, _tail_fun) do
    :ok
  end

  defp each_improper_list([elem], _head_fun, tail_fun) do
    tail_fun.(elem)
  end

  defp each_improper_list([head | tail], head_fun, tail_fun) do
    head_fun.(head)

    if is_list(tail) do
      each_improper_list(tail, head_fun, tail_fun)
    else
      tail_fun.(tail)
    end
  end

  defp generate_data(name) do
    Types.generate(AllTypes, name)
  end

  defp is_term(t) do
    # Will something ever be false here?
    is_boolean(t) or is_integer(t) or is_float(t) or is_binary(t) or is_atom(t) or is_reference(t) or
      is_list(t) or is_map(t) or is_tuple(t)
  end

  defp is_iolist([]), do: true
  defp is_iolist(x) when is_binary(x), do: true
  defp is_iolist([x|xs]) when x in 0..255, do: is_iolist(xs)
  defp is_iolist([x|xs]) when is_binary(x), do: is_iolist(xs)
  defp is_iolist([x|xs]) do
    case is_iolist(x) do
      true -> is_iolist(xs)
      _ -> false
    end
  end
  defp is_iolist(_), do: false
end
