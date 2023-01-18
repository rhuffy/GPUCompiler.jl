using GPUCompiler
using LLVM, LLVM.Interop

struct WASMCompilerParams <: AbstractCompilerParams end
const WASMCompilerJob = CompilerJob{WASMCompilerTarget,WASMCompilerParams}

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
function wasmfunction_compile(@nospecialize(job::WASMCompilerJob))
  # compile to WASM
  mi, mi_meta = GPUCompiler.emit_julia(job)
  ir, ir_meta = GPUCompiler.emit_llvm(job, mi; libraries=true, ctx=JuliaContext())
  asm, asm_meta = GPUCompiler.emit_asm(job, ir; format=LLVM.API.LLVMObjectFile, validate=false)
  return collect(codeunits(asm))
end
wasmfunction_link(@nospecialize(job::WASMCompilerJob), exe) = exe

module WASMRuntime
  import ..GPUCompiler
  GPUCompiler.reset_runtime()
  @generated function js_error(arg)
    quote
      ccall("extern js_error", llvmcall, Nothing, ($arg,), arg)
    end
  end

  function report_exception(ex)
    js_error(reinterpret(Core.LLVMPtr{UInt8, 0}, ex))
    return
  end

  function signal_exception()
    return
  end
end

GPUCompiler.runtime_module(::WASMCompilerJob) = WASMRuntime