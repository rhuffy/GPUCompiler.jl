include("wasm_runner.jl")

import JSON

@generated function js_print(arg)
  quote
    ccall("extern js_print", llvmcall, Nothing, ($arg,), arg)
  end
end

# struct FooStruct
#   value::Float32
# end

# function square(x)
#   x^2
# end

# function foo(x)
#   return JSON.json(FooStruct(x, x))
# end

function foo(a)
  A = [a]
  return A[1]
end

open("output.wasm", "w") do io
  # write(io, wasmfunction(square, Tuple{Int}))
  write(io, wasmfunction(foo, Tuple{Int}))
end