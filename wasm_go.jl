include("wasm_runner.jl")

function square(x)
  x*x
end

open("output.wasm", "w") do io
  write(io, wasmfunction(square, Tuple{Int}))
end