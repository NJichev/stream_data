-module(m).          % module attribute
-export_type([foo/0, hard/0]).

-type foo() :: integer().
-type bar() :: integer().
-type baz() :: integer().
-type hard() :: foo() | bar().
