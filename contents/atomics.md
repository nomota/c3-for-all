# Atomics

### What is atomic and how to use?

In C3 programming language, "atomic" refers to operations that are guaranteed to be performed as a single, indivisible unit. When multiple threads access the same data, an atomic operation ensures that no other thread can see the data in a partially modified state.

C3 handles atomicity primarily through built-in types and atomic intrinsics, following a model very similar to C11 atomics but with cleaner syntax.

1. What is "Atomic"?

In concurrent programming, a standard operation like x += 1 actually consists of three steps:
* Read the value of x.
* Add 1 to that value.
* Write the result back to x.

If two threads do this at the same time, they might both read "5" and both write "6," causing one increment to be lost. An atomic operation forces these three steps to happen as one, preventing this "race condition."

2. Using Atomics in C3

In C3 standard library, there are three set's of atomic operations, (1) simple ones, (2) typed ones, and (3) compile time ones.

Simple atomic operations are defined in `std::core::mem` as follows.

```c3
// defined in std::core::mem; // you don't need to import

enum AtomicOrdering : int 
{
    NOT_ATOMIC, // Not atomic
    UNORDERED,  // No lock
    RELAXED, // Consistent ordering
    ACQUIRE, // Barrier locking load/store
    RELEASE, // Barrier releasing load/store
    ACQUIRE_RELEASE, // Barrier fence to load/store
    SEQ_CONSISTENT, // Acquire semantics, ordered with other seq_consistent
}

old_val = @atomic_load(#x, AtomicOrdering $ordering = SEQ_CONSISTENT, $volatile = false);
void @atomic_store(#x, value, AtomicOrdering $ordering = SEQ_CONSISTENT, $volatile = false);
old_val = mem::compare_exchange(ptr, compare, value, AtomicOrdering $success = SEQ_CONSISTENT, AtomicOrdering $failure = SEQ_CONSISTENT, bool $volatile = true, bool $weak = false, usz $alignment = 0);
```

Typed atomic oprration set is defined in `std::atomic::types{Type}`.

```c3
import std::atomic::types;

struct Atomic
{
    Type data;
}

Atomic{Type} atm;

Type val = atm.load(AtomicOrdering ordering = SEQ_CONSISTENT);
void atm.store(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.add(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.sub(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.mul(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.div(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.max(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.min(Type value, AtomicOrdering ordering = SEQ_CONSISTENT);
Type old = atm.or(Type value, AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) != FLOAT);
Type old = atm.xor(Type value, AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) != FLOAT);
Type old = atm.and(Type value, AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) != FLOAT);
Type old = atm.shr(Type amount, AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) != FLOAT);
Type old = atm.shl(Type amount, AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) != FLOAT);
Type old = atm.set(AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) == BOOL);
Type old = atm.clear(AtomicOrdering ordering = SEQ_CONSISTENT) @if(types::flat_kind(Type) == BOOL);

ordering = NOT_ATOMIC | UNORDERED | RRELAXED | AQUIRE | RELEASE | ACQUIRE_RELEASE |  SEQ_CONSISTENT
```

Third set is defined in `std::atomic` module. Note that these all has $-variable, which is compile time variable. So followings are applied only in compile time.

```c3
import std::atomic;

bool b = atomic::is_native_atomic_type($Type);
old = atomic::fetch_add(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
old = atomic::fetch_sub(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
old = atomic::fetch_mul(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT);
old = atomic::fetch_div(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT);
old = atomic::fetch_or(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
old = atomic::fetch_xor(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
old = atomic::fetch_and(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
old = atomic::fetch_shift_right(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT);
old = atomic::fetch_shift_left(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT);
old = atomic::flag_set(ptr, AtomicOrdering $ordering = SEQ_CONSISTENT);
old = atomic::flag_clear(ptr, AtomicOrdering $ordering = SEQ_CONSISTENT);
old = atomic::fetch_max(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
old = atomic::fetch_min(ptr, y, AtomicOrdering $ordering = SEQ_CONSISTENT, bool $volatile = false, usz $alignment = 0);
```

Another important concept related to atomics is `fence()` that acts like a guard.

```c3
import std::thread;

void thread::fence(AtomicOrdering $ordering);
```

```c3
import std::atomic::types;

// Define an atomic 32-bit integer
Atomic{int} counter;
counter.data = 0;

// Define an atomic pointer
Atomic{void*} shared_ptr;
shared_ptr.data = null;
```

Atomic Operations: C3 provides a set of standard functions to interact with these variables safely.

3. Ordering

C3 atomics allow you to specify Atomic Order, which tells the CPU and compiler how strictly to synchronize atomic operations across threads. If you don't specify one, it usually defaults to SEQ_CONSISTENT (the safest but slowest).

* RELAXED: No synchronization, just ensures the operation itself is atomic.
* ACQUIRE/RELEASE: Ensures that memory writes in one thread are visible to another thread that "acquires" the same variable.
* SEQ_CONSISTENT: The strictest; all threads see all atomic operations in the same order.

4. Example Code

Here is a simple example of a thread-safe counter in C3:
```c3
import std::io;
import std::atomic::types;

Atomic{int} g_counter;

fn void increment_task() {
    for (int i = 0; i < 1000; i++) {
        // Atomically add 1 to the global counter
        g_counter.add(1); // atomic
    }
}

fn void main() {
    g_counter.data = 0;
    
    // Imagine starting multiple threads here...
    increment_task();
    
    int final_val = g_counter.load(); // atomic
    io::printfn("Final count: %d", final_val);
}
```

#### When to use Atomics?

* Use Atomics for simple flags, counters, or building "lock-free" data structures. They are faster than Mutexes because they don't put the thread to "sleep."
* Use Mutexes (Locks) for complex logic involving multiple variables or large blocks of code, as atomics can only protect a single variable at a time.

#### Lock-Free Stack using these atomic operations in C3?

Implementing a Lock-Free Stack (often called a Treiber Stack) is a classic way to see the power of the atomic `mem::compare_exchange()` operation.
In a lock-free stack, we don't use a Mutex to lock the whole structure. Instead, we use a loop to "try" to update the head of the stack. If another thread beats us to it, we simply try again.

##### How it Works: The CAS Logic

The "magic" happens with atomic `mem::compare_exchange()`. This operation checks: "Is the current head still what I thought it was a millisecond ago? If yes, swap it with my new node. If no, someone else changed it, so fail and let me try again."

Implementation in C3

```c3
import std::io;

struct Node {
    int value;
    Node* next;
}

struct AtomicStack {
    Node* head;
}

// Push a value onto the stack
fn void push(AtomicStack* stack, int val) {
    Node* new_node = mem::alloc(Node);
    new_node.value = val;

    while (true) {
        // 1. Get the current head
        Node* old_head = @atomic_load(stack.head); // atomic load
        
        // 2. Point our new node to the current head
        new_node.next = old_head;

        // 3. Try to swap the head. 
        // If stack.head is still old_head, set stack.head to new_node.
        if (mem::compare_exchange(&stack.head, &old_head, new_node)) {
            break; // Success!
        }
        // If it failed, 
        // we loop back to try again.
    }
}

// Pop a value from the stack
fn bool pop(AtomicStack* stack, int* out_val) {
    while (true) {
        Node* old_head = @atomic_load(stack.head); // atomic
        if (old_head == null) return false; // Stack is empty

        Node* next_node = old_head.next;

        // Try to move the head to the next node
        if (mem::compare_exchange(&stack.1 head, &old_head, next_node)) {
            *out_val = old_head.value;
            // In a real app, you'd handle memory reclamation (like an RCU or hazard pointers)
            free(old_head); 
            return true;
        }
    }
}
```

##### Key Takeaways for C3 Atomics

* Pointers can be Atomic: Notice that `Node*` head is treated as atomic.
* The While Loop: Lock-free programming almost always involves a while(true) or do-while loop because you have to account for the possibility of "contention" (multiple threads hitting the same variable).

### Fence

In concurrent programming, an atomic fence (also known as a memory barrier) is a synchronization primitive that does not involve a specific variable. Instead, it enforces an ordering constraint on the memory operations performed by the CPU and the compiler.

While atomic variables (like `atomic.add()`) protect a specific piece of data, a fence protects the "visibility" of all memory operations around it.

1. Why use a Fence?

Normally, CPUs and compilers reorder instructions to make code run faster. For example:

```c3
// The CPU might see these as independent and flip their order!
ready = true;
data = 42; 
```

If another thread sees `ready = true;` before the data is actually written, you get a bug. A fence acts as a line in the sand that instructions cannot cross.

2. Common Types of Fences

C3 typically exposes fences via a `thread::fence(ordering)`. The behavior depends on the memory ordering used:

* ACQUIRE: Ensures no subsequent reads/writes move above the fence.
* RELEASE: Ensures no previous reads/writes move below the fence.
* SEQ_CONSISTENT: The strongest barrier; prevents reordering in both directions.

3. How to use it in C3

Fences are often used to implement "Message Passing" between threads without making every single variable atomic. This is more efficient because only the fence carries the performance penalty.

Example: The Producer-Consumer Pattern

```c3
import std::thread;

int shared_data = 0;
bool ready = false;

fn void producer() {
    shared_data = 100; // 1. Write non-atomic data
    
    // 2. Use a Release fence: Everything above this MUST be 
    // finished before anything below it starts.
    thread::fence(RELEASE);
    
    @atomic_store(&ready, true); // 3. Signal the other thread
}

fn void consumer() {
    // 1. Wait for signal
    while (! @atomic_load(&ready)) { /* spin */ }
    
    // 2. Use an Acquire fence: Everything below this MUST 
    // stay below it (don't read data too early).
    thread::fence(ACQUIRE);
    
    // 3. Now we are GUARANTEED that shared_data is 100
    int result = shared_data;
    io::printfn("Data: %d", result);
}
```

4. Fence vs. Atomic Variable

* Atomic Variable: Direct protection for one piece of data. Use this for counters or simple state flags.
* Fence: Bulk synchronization. Use this when you have a large amount of regular (non-atomic) data that needs to be "shipped" to another thread safely.
Summary of Rules
* Release your data in the producer thread.
* Acquire the data in the consumer thread.
* The combination of a Release Fence and an Acquire Fence creates a "Happens-Before" relationship between the two threads.

#### High performance RingBuffer

Building a Ring Buffer (or Circular Queue) is a perfect use case for fences because it allows you to move large chunks of data between threads while only synchronizing at the very last moment.

In this pattern, we use Relaxed atomic operations for the head and tail indices to avoid unnecessary overhead, then use Fences to ensure the actual data in the buffer is fully "published" before the other thread reads it.

High-Performance Ring Buffer in C3

```c3
import std::thread;

const BUFFER_SIZE = 1024;

struct RingBuffer {
    int[BUFFER_SIZE] data;
    uint head; // Producer index
    uint tail; // Consumer index
}

// PRODUCER: Adds data to the buffer
fn bool try_push(RingBuffer* rb, int value) {
    uint h = @atomic_load(&rb.head, RELAXED);
    uint t = @atomic_load(&rb.tail, RELAXED);

    // Check if full
    if ((h + 1) % BUFFER_SIZE == t) return false;

    rb.data[h] = value; // Write data (non-atomic)

    // RELEASE FENCE: Ensures 'data[h] = value' is visible 
    // to other threads BEFORE we update the head.
    thread::fence(RELEASE);

    @atomic_store(&rb.head, (h + 1) % BUFFER_SIZE, RELAXED);
    return true;
}

// CONSUMER: Takes data from the buffer
fn bool try_pop(RingBuffer* rb, int* out_val) {
    uint t = @atomic_load(&rb.tail, RELAXED);
    uint h = @atomic_load(&rb.head, RELAXED);

    // Check if empty
    if (h == t) return false;

    // ACQUIRE FENCE: Ensures we don't read 'data[t]' 
    // until we have confirmed the head has moved.
    thread::fence(ACQUIRE);

    *out_val = rb.data[t]; // Read data (non-atomic)

    @atomic_store(&rb.tail, (t + 1) % BUFFER_SIZE, RELAXED);
    return true;
}
```

Why use `thread::fence()` here instead of SEQ_CONSISTENT?

If we didn't use fences, we would have to make every single atomic operation SEQ_CONSISTENT. On many CPU architectures (like ARM), SEQ_CONSISTENT is significantly more expensive because it forces a full pipeline flush.

By using RELAXED atomics + Fences, we get:

* Speed: The CPU can reorder the index math freely.
* Safety: The RELEASE fence acts as a "gate," ensuring the data is sitting in memory ready to be read.
* Efficiency: The ACQUIRE fence ensures the consumer doesn't "speculate" and read stale data from its own cache.

Summary Checklist for Atomics in C3

* Simple Counters: Use `atomic::fetch_add()` with default ordering.
* Flags/Booleans: Use `@atomic_store()` / `@atomic_load()``.
* Complex Data (Stacks/Queues): Use `mem::compare_exchange()`.
* Bulk Data Transfer: Use RELAXED atomics + `thread::fence()`.

##### ABA problem

In concurrent programming, the ABA Problem is a subtle bug that occurs when a memory location is read twice, has the same value both times, but "something happened" in between that makes the second read misleading.

This is especially dangerous in C3 (or any systems language) when managing memory in lock-free structures like the Stack we built earlier.

1. What is the ABA Problem?

Imagine this sequence in a Lock-Free Stack:

* Thread 1 reads the head of the stack (Address A).
* Thread 1 gets interrupted.
* Thread 2 pops A, pops B, and then pushes A back onto the stack.
* Thread 1 wakes up and performs a Compare-and-Swap (CAS) on A.
* The Bug: The CAS succeeds because the head is still A, but the internal state (the next pointer of A) might now be totally different or invalid!

2. The Solution: Tagged Pointers

The most common way to fix this in C3 is to use a Tagged Pointer (also called a Versioned Pointer). Instead of just storing the pointer, we store a Counter alongside it. Every time the pointer is modified, we increment the counter.

Even if the address becomes A again, the counter will be different (e.g., A at version 1 vs. A at version 3), causing the CAS to fail safely.

3. Implementing Tagged Pointers in C3

Because C3 allows for manual memory layout, we can create a struct that fits into a 128-bit atomic (on supported 64-bit CPUs).


```C3

// A tagged pointer combines the node address with a generation counter
struct TaggedPointer {
    Node* ptr;
    uint tag;
}

struct AtomicStack {
    // Note: This requires the CPU to support 128-bit atomics (CMPXCHG16B)
    TaggedPointer head;
}

fn void push(AtomicStack* stack, int val) {
    Node* new_node = mem::alloc(Node);
    new_node.value = val;

    while (true) {
        TaggedPointer old_head = (TaggedPointer)@atomic_load(&(uint128)stack.head);
        new_node.next = old_head.ptr;

        TaggedPointer new_head;
        new_head.ptr = new_node;
        new_head.tag = old_head.tag + 1; // Increment the version

        // This CAS will now fail if another thread changed the stack,
        // even if the head pointer address is the same as before.
        if (mem::compare_exchange(&(uint128)stack.head, &(uint128)old_head, (uint128)new_head)) {
            break;
        }
    }
}
```

4. Atomic Structs in C3

You might wonder: How can C3 handle a whole struct atomically?

* Alignment: C3 ensures that atomic types are properly aligned in memory. For a TaggedPointer (two 64-bit values), the struct must be 16-byte aligned.
* Hardware Support: If the CPU supports it, the compiler uses a "double-wide" CAS instruction.
* Lock-based Fallback: If the hardware doesn't support an atomic operation for a specific struct size, the C3 runtime may use an internal spinlock (though this is platform-dependent).

Summary Checklist

* Is your data small (1-8 bytes)? Use standard atomic types.
* Is it a pointer in a stack/queue? Use a Tagged Pointer to avoid ABA.
* Is it a large struct? Use a Mutex instead of atomic, as double-wide atomics are complex and less portable.

#### Atomic boolean

Using Atomic Booleans for thread cancellation is one of the most common and practical uses of atomics. It’s the standard way to tell a background thread, "Stop what you're doing and shut down safely."

In C3, you use a "Stop Flag" pattern. This is much better than "killing" a thread (which can leave files open or memory leaked) because it allows the thread to clean up after itself.

1. The "Stop Flag" Pattern

A non-atomic boolean is unsafe here because the compiler might optimize the code by caching the value in a CPU register, meaning the thread would never see the "True" value sent by the main thread. An Atomic Boolean ensures the thread always checks the actual memory.

```c3
import std::io;
import std::thread;

// The global stop flag
bool should_stop = false;

fn int background_worker(void* arg) {
    io::printfn("Worker: Starting work...");

    while (!@atomic_load(&should_stop)) {
        // Perform a small chunk of work
        io::printfn("Worker: Processing data...");
        thread::sleep_ms(500); 
    }

    io::printfn("Worker: Shutting down cleanly.");
}

fn void main() {
    // Start the worker thread
    Thread thr; 
    thr.create(&background_worker, null);

    // Let it run for 2 seconds
    thread::sleep_ms(2000);

    io::printfn("Main: Requesting stop...");
    
    // Set the flag to true
    @atomic_store(&should_stop, true);

    // Wait for the thread to finish
    thr.join();
    io::printfn("Main: Worker has stopped.");
}
```

2. Why not just use a Mutex?

You could use a Mutex to protect a boolean, but it is overkill:

* Performance: A Mutex requires a system call to the OS kernel if there is contention. An atomic load is just a single CPU instruction (usually MOV on x86).
* Simplicity: You don't have to worry about locking and unlocking; you just read the value.

3. Advanced: The "Atomic Pause"

Sometimes you don't want to stop the thread, just pause it. You can combine an atomic variable with a "Futex" (Fast Userspace Mutex) or a condition variable, but for simple logic, an Atomic State machine works great:

```c3
import std::thread;

enum WorkerState : int {
    RUNNING,
    PAUSED,
    STOPPED
}

WorkerState current_state = RUNNING;

fn void worker_loop() {
    while (true) {
        WorkerState s = @atomic_load(&current_state);
        
        if (s == STOPPED) break;
        if (s == PAUSED) {
            thread::sleep_ms(100);
            continue;
        }

        // Do work...
    }
}
```

Summary of C3 Atomic Strengths

* Type Safety: The compiler prevents you from accidentally using non-atomic functions on atomic types.
* Readability: No messy macros like in C; atomic is part of the standard library.
* Control: You have full access to memory ordering (RELAXED, ACQUIRE/RELEASE, SEQ_CONSISTENT) when you need to squeeze out every drop of performance.


Back to [Table of Contents](0.table-of-contents.md)

