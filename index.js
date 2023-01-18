function ijl_apply_generic(...args){
  console.log("call ijl_apply_generic", ...args)
}
function ijl_invoke(...args){
  console.log("call ijl_invoke", ...args)
}
function js_error(...args){
  console.log("call js_error", ...args)
}
function ijl_get_binding_or_error(...args) {
  console.log("call ijl_get_binding_or_error", ...args)
}
function jl_f_tuple(...args) {
  console.log("call jl_f_tuple", ...args)
}
function memset(...args) {
  console.log("call memset", ...args)
}
function gpu_malloc(...args){
  console.log("call gpu_malloc", ...args)
}
function gpu_report_oom(...args){
  console.log("call gpu_report_oom", ...args)
}

const importObject = { 
  env: {
    __linear_memory: new WebAssembly.Memory({initial: 10, maximum: 100}),
    __stack_pointer: new WebAssembly.Global({ value: "i32", mutable: true }, 0),
    __indirect_function_table: new WebAssembly.Table({ initial: 10000000, element: "anyfunc" }),
    js_print: console.log,
    ijl_apply_generic: ijl_apply_generic,
    ijl_get_binding_or_error: ijl_get_binding_or_error,
    ijl_invoke: ijl_invoke,
    jl_f_tuple: jl_f_tuple,
    js_error: js_error,
    memset: memset,
    gpu_malloc: gpu_malloc,
    gpu_report_oom: gpu_report_oom
  }
};

WebAssembly.instantiateStreaming(fetch("output.wasm"), importObject).then(
  (obj) => {
    console.log(obj)
    res = obj.instance.exports.julia_foo(BigInt(2), BigInt(3))
    console.log(res)
  }
);
