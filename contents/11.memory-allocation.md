# Memmory Allocation

There are mutiple memory allocators available in C3.

* Default allocator
* Temp allocator
* Tracking allocator
* Arena allocator
* BackedArena allocator
* DynamicArena allocator
* OnStack allocator
* SimpleHeap allocator

All allocators conform `interface Allocator` reuiement and they are interchangeable.

Two allocators are defined as `@builtin` so as to be used easily.

* `mem`: default allocator
* `tmem`: temp allocator

Note: Standard library in `std::core` are imported implicitly. Memory allocators are defined in standard library `std::core::mem::allocator`, and you don't have to import in your code.

## Default allocator

By default, allocator is mapped to `libc`'s memory allocation and these macros are available, just like in C.

* `void* malloc(usz size)`
* `void* calloc(usz size)` // fills zero
* `void* realloc(void* ptr, usz new_size)`
* `void free(void* ptr)`

To achieve better type safety, a new set of allocations are also available.

* `Type* p = mem::alloc(Type)`
* `Type* p = mem::new(Type, {initial value})`
* `Type[] p = mem::alloc_array(Type, usz number)`
* `Type[] p = mem::new_array(Type, usz number)` // zero-filled
* `Type* p = mem::@clone(Type value)`

