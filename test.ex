defmodule Simple do
  @type foo :: integer()
  @type bar :: atom()
  @typep baz :: integer()

  @type hard :: foo() | bar()
end
