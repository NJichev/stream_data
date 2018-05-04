defmodule StreamData.TypesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias StreamData.Types
  alias StreamDataTest.AllTypes

  describe "it covers basic types" do
    test "integer" do
      data = Types.generate(AllTypes, :int)

      check all x <- data, do: assert is_integer(x)
    end

    test "neg_integer" do
      data = Types.generate(AllTypes, :neg_int)

      check all x <- data do
        assert is_integer(x)
        assert x < 0
      end
    end

    test "pos_integer" do
      data = Types.generate(AllTypes, :pos_int)

      check all x <- data do
        assert is_integer(x)
        assert x > 0
      end
    end

    test "non_neg_integer" do
      data = Types.generate(AllTypes, :non_neg_int)

      check all x <- data do
        assert is_integer(x)
        assert x >= 0
      end
    end

    test "float" do
      data = Types.generate(AllTypes, :floats)

      check all x <- data do
        assert is_float(x)
      end
    end

    test "references" do
      data = Types.generate(AllTypes, :refs)

      check all x <- data, do: assert is_reference(x)
    end

    test "atom" do
      data = Types.generate(AllTypes, :atoms)

      check all x <- data, do: assert is_atom(x)
    end

    test "bottom" do
      data = Types.generate(AllTypes, :bottom)

      check all x <- data, do
      end
    end

    test "any" do
      data = Types.generate(AllTypes, :any_type)

      check all term <- data, max_runs: 25 do
        assert is_boolean(term) or is_integer(term) or is_float(term) or is_binary(term) or
                is_atom(term) or is_reference(term) or is_list(term) or is_map(term) or
                is_tuple(term)
    end

    test "nonempty_improper_list" do
      data = Types.generate(AllTypes, :l)

      check all x <- data do
        IO.inspect(x)
      end
    end
  end
end
