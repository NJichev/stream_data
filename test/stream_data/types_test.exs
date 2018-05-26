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

  test "atom" do
    data = generate_data(:basic_atom)

    check all x <- data, do: assert(is_atom(x))
  end

  test "parameterized remote types" do
    data = generate_data(:remote_keyword_t1)

    check all x <- data do
      assert is_list(x)
      Enum.each(x, fn {a, i} ->
        assert is_atom(a)
        assert is_integer(i)
      end)
    end
  end

  describe "union" do
    test "basic union" do
      generate_data(:union_atom_or_integer)
      data = generate_data(:union_atom_or_integer)

      check all x <- data do
        assert is_integer(x) or is_atom(x)
      end
    end

    test "union any" do
      data = generate_data(:union_any)

      check all x <- data, max_runs: 25 do
        assert is_term(x)
      end
    end
  end

  describe "recursive types" do
    test "list" do
      data = generate_data(:recursive_list)

      check all x <- data, max_runs: 25 do
        assert is_union_list(x)
      end
    end
  end

  describe "mutually recursive types" do
    test "tree" do
      data = generate_data(:forest)
      data = generate_data(:tree)
    end
  end

  defp each_improper_list([], _head_fun, _tail_fun), do: :ok

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

  defp generate_data(name, args \\ []) do
    generate(AllTypes, name, args)
  end

  defp generate(module, name, args \\ []) do
    Types.generate(module, name, args)
  end

  defp is_term(t) do
    is_boolean(t) or is_integer(t) or is_float(t) or is_binary(t) or is_atom(t) or is_reference(t) or
      is_list(t) or is_map(t) or is_tuple(t)
  end

  defp is_union_list(nil), do: true
  defp is_union_list({t, list}) do
    is_integer(t) and is_union_list(list)
  end
  defp is_union_list(_), do: false

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
