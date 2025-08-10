let wasmMod, wasmInst, memU8;

async function load() {
  if (wasmInst) return;
  const res = await fetch(new URL('./x448_wasm_bg.wasm', import.meta.url));
  const buf = await res.arrayBuffer();
  const mod = await WebAssembly.compile(buf);
  const inst = await WebAssembly.instantiate(mod, {});
  wasmMod = mod;
  wasmInst = inst;
  memU8 = new Uint8Array(wasmInst.exports.memory.buffer);
}

export async function x448_init() {
  await load();
}

export function x448_public_from_private(priv /* Uint8Array len 56 */) {
  if (!wasmInst) throw new Error('wasm not loaded');
  const malloc = (n) => {
    // simple bump allocator on stack pointer
    const spGet = wasmInst.exports.emscripten_stack_get_current;
    const spSet = wasmInst.exports._emscripten_stack_restore;
    const base = spGet();
    const ptr = base - n;
    spSet(ptr);
    return ptr;
  };

  const outPtr = malloc(56);
  const inPtr  = malloc(56);
  memU8.set(priv, inPtr);
  wasmInst.exports._x448_public_from_private(outPtr, inPtr);
  const out = memU8.slice(outPtr, outPtr + 56);
  return out;
}

export function x448_shared(priv /* 56 */, peerPub /* 56 */) {
  if (!wasmInst) throw new Error('wasm not loaded');
  const malloc = (n) => {
    const spGet = wasmInst.exports.emscripten_stack_get_current;
    const spSet = wasmInst.exports._emscripten_stack_restore;
    const base = spGet();
    const ptr = base - n;
    spSet(ptr);
    return ptr;
  };

  const outPtr = malloc(56);
  const aPtr   = malloc(56);
  const bPtr   = malloc(56);
  memU8.set(priv, aPtr);
  memU8.set(peerPub, bPtr);
  const rc = wasmInst.exports._x448_shared(outPtr, aPtr, bPtr);
  const out = memU8.slice(outPtr, outPtr + 56);
  if (rc !== 1) throw new Error('x448_shared failed');
  return out;
}
EOF
