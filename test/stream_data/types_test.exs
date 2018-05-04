defmodule StreamData.TypesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias StreamData.Types
  alias StreamDataTest.AllTypes

  # test that all types specified in lib/elixir/pages/Typespecs.md can be generated
  test "any" do
    data = Types.generate(AllTypes, :basic_any)

    check all term <- data, max_runs: 25 do
      assert is_boolean(term) or is_integer(term) or is_float(term) or is_binary(term) or
              is_atom(term) or is_reference(term) or is_list(term) or is_map(term) or
              is_tuple(term)
    end
  end

  test "none" do
    assert_raise(ArgumentError, fn ->
      Types.generate(AllTypes, :basic_none)
    end)
  end

  test "atom" do
    data = Types.generate(AllTypes, :basic_atom)

    check all x <- data, do: assert is_atom(x)
  end

  test "map"
  test "pid"
  test "port"

  test "references" do
    data = Types.generate(AllTypes, :basic_reference)

    check all x <- data, do: assert is_reference(x)
  end

  test "struct"
  test "tuple"

  # Numbers
  test "float" do
    data = Types.generate(AllTypes, :basic_float)

    check all x <- data do
      assert is_float(x)
    end
  end

  test "integer" do
    data = Types.generate(AllTypes, :basic_integer)

    check all x <- data, do: assert is_integer(x)
  end

  test "neg_integer" do
    data = Types.generate(AllTypes, :basic_neg_integer)

    check all x <- data do
      assert is_integer(x)
      assert x < 0
    end
  end

  test "non_neg_integer" do
    data = Types.generate(AllTypes, :basic_non_neg_integer)

    check all x <- data do
      assert is_integer(x)
      assert x >= 0
    end
  end

  test "pos_integer" do
    data = Types.generate(AllTypes, :basic_pos_integer)

    check all x <- data do
      assert is_integer(x)
      assert x > 0
    end
  end

  # Lists
  describe "lists" do
    test "basic lists" do
      data = Types.generate(AllTypes, :basic_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert length(list) >= 0
        assert Enum.all?(list, fn x -> is_integer(x) end)
      end
    end

    test "nested lists" do
      data = Types.generate(AllTypes, :nested_list_type)

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
      data = Types.generate(AllTypes, :basic_nonempty_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert length(list) > 0
        assert Enum.all?(list, fn x -> is_integer(x) end)
      end
    end

    test "nested nonempty list" do
      data = Types.generate(AllTypes, :nested_nonempty_list_type)

      check all list <- data, max_runs: 25 do
        assert is_list(list)
        assert length(list) > 0
        assert Enum.all?(list, fn x ->
          is_list(x) and Enum.all?(x, &is_integer(&1))
        end)
      end
    end
  end
end
