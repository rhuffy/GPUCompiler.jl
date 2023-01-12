# implementation of the GPUCompiler interfaces for generating WASM code

## target

export WASMCompilerTarget

Base.@kwdef struct WASMCompilerTarget <: AbstractCompilerTarget
end

llvm_triple(::WASMCompilerTarget) = "wasm32-unknown-unknown"

function llvm_machine(target::WASMCompilerTarget)
  triple = llvm_triple(target)

  t = Target(triple=triple)

  cpu = ""
  feat = ""
  tm = TargetMachine(t, triple, cpu, feat)
  asm_verbosity!(tm, true)

  return tm
end

function process_entry!(job::CompilerJob{WASMCompilerTarget}, mod::LLVM.Module, entry::LLVM.Function)
  push!(function_attributes(entry), StringAttribute("wasm-export-name", String(chop(LLVM.name(entry), tail=4)), ctx=context(mod)))
  invoke(process_entry!, Tuple{CompilerJob, LLVM.Module, LLVM.Function}, job, mod, entry)
end

## job

runtime_slug(job::CompilerJob{WASMCompilerTarget}) = "wasm"
