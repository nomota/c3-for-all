# c3-for-all

# C3 Programming Language

C3 is an evolution of C and a minimalist systems programming language.

### Ergonomics and Safety

- Optionals to safely and quickly handle errors and null values.
- Defer to clean up resources.
- Slices and foreach for safe iteration.
- Contracts in comments to add constraints to your code.
- Automatically free memory after use in @pool() context.

### Performance by Default

- Write SIMD vectors to program the hardware directly.
- Access to different memory allocators to fine-tune performance.
- Zero-overhead errors.
- Fast compilation times.
- Industrial-strength optimizations backed by LLVM.
- Easy-to-use inline assembly.

### Batteries-Included Standard Library

- Dynamic containers and strings.
- Cross-platform abstractions for ease of use.
- Access to the native platform when you need it.

### Leverage Existing C or C++ Libraries

- Full C ABI compatibility.
- C3 can link C code; C can link C3 code.

### Simple Modules

- Modules namespace code.
- Modules make encapsulation simple with explicit control.
- Interfaces define shared behavior to write robust libraries.
- Generic modules make extending code easier.
- Simple struct composition and reuse with struct subtyping.

### Macros Without a PhD

- Macros can be similar to normal functions.
- Or write code that understands the types in your code.

---

**Next:** Design Goals & Background
