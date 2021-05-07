using GPUCompiler
using LLVM, LLVM.Interop

struct WASMCompilerParams <: AbstractCompilerParams end

function wasmfunction(f::Core.Function, tt::Type=Tuple{})
  source = FunctionSpec(f, tt, false)
  target = WASMCompilerTarget()
  params = WASMCompilerParams()
  job = CompilerJob(target, source, params)
  GPUCompiler.cached_compilation(wasmfunction_cache, job,
                                 wasmfunction_compile,
                                 wasmfunction_link)
end

const wasmfunction_cache = Dict{UInt,Any}()

# actual compilation
function wasmfunction_compile(@nospecialize(job::CompilerJob))

  # compile to WASM
  method_instance, world = GPUCompiler.emit_julia(job)
  ir, kernel = GPUCompiler.emit_llvm(job, method_instance, world; libraries=false)
  print(ir)
  code = GPUCompiler.emit_asm(job, ir, kernel; format=LLVM.API.LLVMObjectFile, validate=true)
  return collect(codeunits(code))
end
wasmfunction_link(@nospecialize(job::CompilerJob), exe) = exe