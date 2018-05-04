defmodule StreamData.TypesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias StreamData.Types
  alias StreamDataTest.AllTypes

  # test that all types specified in lib/elixir/pages/Typespecs.md can be generated
  test "any" do
    data = generate_data(:basic_any)

    check all term <- data, max_runs: 25 do
      assert is_boolean(term) or is_integer(term) or is_float(term) or is_binary(term) or
              is_atom(term) or is_reference(term) or is_list(term) or is_map(term) or
              is_tuple(term)
    end
  end

  test "none" do
    assert_raise(ArgumentError, fn ->
      generate_data(:basic_none)
    end)
  end

  test "atom" do
    data = generate_data(:basic_atom)

    check all x <- data, do: assert is_atom(x)
  end

  test "map"
  test "pid"
  test "port"

  test "references" do
    data = generate_data(:basic_reference)

    check all x <- data, do: assert is_reference(x)
  end

  test "struct"
  test "tuple"

  # Numbers
  test "float" do
    data = generate_data(:basic_float)

    check all x <- data do
      assert is_float(x)
    end
  end

  test "integer" do
    data = generate_data(:basic_integer)

    check all x <- data, do: assert is_integer(x)
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
        assert length(list) >= 0
        assert Enum.all?(list, fn x -> is_integer(x) end)
      end
    end

    test "nested lists" do
      data = generate_data(:nested_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert length(list) >= 0
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
        assert x >= 1
        assert x <= 10
      end
    end
  end

  #TODO: Delete if merge types file and test file to stream_data.ex
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
end
