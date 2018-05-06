defmodule StreamDataTest.AllTypes do
  defmodule SomeStruct do
    defstruct [:key]
  end

  @type basic_any() :: any()
  @type basic_none() :: none()
  @type basic_atom() :: atom()
  @type basic_map() :: map()
  @type basic_pid() :: pid()
  @type basic_port() :: port()
  @type basic_reference() :: reference()
  @type basic_struct() :: struct()
  @type basic_tuple() :: tuple()

  # Numbers
  @type basic_float() :: float()
  @type basic_integer() :: integer()
  @type basic_neg_integer() :: neg_integer()
  @type basic_non_neg_integer() :: non_neg_integer()
  @type basic_pos_integer() :: pos_integer()

  # Lists
  @type basic_list_type() :: list(integer())
  @type basic_nonempty_list_type() :: nonempty_list(integer())
  @type basic_maybe_improper_list_type() :: maybe_improper_list(integer(), atom())
  @type basic_nonempty_improper_list_type() :: nonempty_improper_list(integer(), atom())
  @type basic_nonempty_maybe_improper_list_type() ::
            nonempty_maybe_improper_list(integer(), atom())


  ## Nested Lists
  @type nested_list_type :: list(list(integer()))
  @type nested_nonempty_list_type :: nonempty_list(list(integer()))

  ## Literals
  @type literal_atom() :: :atom
  @type literal_special_atom() :: false
  @type literal_integer() :: 1
  @type literal_integers() :: 1..10
  @type literal_empty_bitstring() :: <<>>
  @type literal_size_0() :: <<_::0>>
  @type literal_unit_1() :: <<_::_*1>>
  @type literal_size_1_unit_8() :: <<_::1, _::_*8>>
  @type literal_function_arity_any() :: (... -> integer())
  @type literal_function_arity_0() :: (() -> integer())
  @type literal_function_arity_2() :: (integer(), atom() -> integer())
  @type literal_list_type() :: [integer()]
  @type literal_empty_list() :: []
  @type literal_list_nonempty() :: [...]
  @type literal_nonempty_list_type() :: [atom(), ...]
  @type literal_keyword_list_fixed_key() :: [key: integer()]
  @type literal_keyword_list_fixed_key2() :: [{:key, integer()}]
  @type literal_keyword_list_type_key() :: [{binary(), integer()}]
  @type literal_empty_map() :: %{}
  @type literal_map_with_key() :: %{:key => integer()}
  @type literal_map_with_required_key() :: %{required(bitstring()) => integer()}
  @type literal_map_with_optional_key() :: %{optional(bitstring()) => integer()}
  @type literal_map_with_required_and_optional_key() :: %{:key => integer(), optional(bitstring()) => integer()}
  @type literal_struct_all_fields_any_type() :: %SomeStruct{}
  @type literal_struct_all_fields_key_type() :: %SomeStruct{key: integer()}
  @type literal_empty_tuple() :: {}
  @type literal_2_element_tuple() :: {1, atom()}

  ## Built-in types
  @type builtin_term() :: term()
  @type builtin_arity() :: arity()
  @type builtin_as_boolean() :: as_boolean(:t)
  @type builtin_binary() :: binary()
  @type builtin_bitstring() :: bitstring()
  @type builtin_boolean() :: boolean()
  @type builtin_byte() :: byte()
  @type builtin_char() :: char()
  @type builtin_charlist() :: charlist()
  @type builtin_nonempty_charlist() :: nonempty_charlist()
  @type builtin_fun() :: fun()
  @type builtin_function() :: function()
  @type builtin_identifier() :: identifier()
  @type builtin_iodata() :: iodata()
  @type builtin_iolist() :: iolist()
  @type builtin_keyword() :: keyword()
  @type builtin_keyword_value_type() :: keyword(:t)
  @type builtin_list() :: list()
  @type builtin_nonempty_list() :: nonempty_list()
  @type builtin_maybe_improper_list() :: maybe_improper_list()
  @type builtin_nonempty_maybe_improper_list() :: nonempty_maybe_improper_list()
  @type builtin_mfa() :: mfa()
  @type builtin_module() :: module()
  @type builtin_no_return() :: no_return()
  @type builtin_node() :: node()
  @type builtin_number() :: number()
  @type builtin_struct() :: struct()
  @type builtin_timeout() :: timeout()

  ## Remote types
  @type remote_enum_t0() :: Enum.t()
  @type remote_keyword_t1() :: Keyword.t(integer())
end
