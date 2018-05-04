defmodule StreamDataTest.AllTypes do
  @types [
    int: :integer,
    neg_int: :neg_integer,
    pos_int: :pos_integer,
    non_neg_int: :non_neg_integer,
    floats: :float,
    refs: :reference,
    atoms: :atom,
    structs: :struct, #TODO
    m: :map, #TODO
    t: :tuple, #TODO
    bottom: :none,
    any_type: :any,
  ]

  @list_types [
    lists: {:list, :term},
    nonempty_lists: {:nonempty_list, :term}
  ]

  for {name, type} <- @types, do: @type unquote(name)() :: unquote(type)()

  @type l :: nonempty_improper_list(integer(), atom())
end
