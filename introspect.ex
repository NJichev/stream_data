introspect = fn module ->
  with {^module, beam, _file} <- :code.get_object_code(module),
       x <- :beam_lib.chunks(beam, [:abstract_code]), do: IO.inspect(x)
end

introspect.(Simple)
introspect.(:m)
IO.puts("=========")
IO.inspect(Kernel.Typespec.beam_types(Simple))
IO.puts("=========")
IO.inspect(Kernel.Typespec.beam_types(:m))
