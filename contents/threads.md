
# Threads

C3 threads are OS's native threads. Followings are thread related concepts.

* Thread: threads run concurrently in a process
* Mutex: used to prevent simultaneous access by two or more threads
* Atomic: sharing interger like variables among multiple threads, safely without mutex
* Condition Variable: block a thread until certain condition is met
* Channels: message queue to communicate among threads
* Thread local: local variables visible only within a thread
* ThreadPool: managing a pool of reusable threads, to eliminate the thread create/destroy overhead
* Once: to guaratee a function is called just once among multiple threads 

### Thread

A thread is an isolated flow within a process, there may be multiple threads concurrently running in a process. Threads all share the memory space of the process.

```c3
import std::thread;

alias ThreadFn = fn int (void*);

Thread thr;

void? thr.create(ThreadFn thread_fn, void* arg);
int? thr.join() @maydiscard;
void? thr.detach() @maydiscard;
```

Following functions are available in a thread.

```c3
import std::thread;

import std::time;
typedef Duration = long; // in std::time
typedef NanoDuration = long; // in std::time

void thread::yield();
Thread this_thread = thread::current();
void thread::exit(int result);
void? thread::sleep_ms(ulong milliseconds);
void? thread::sleep(Duration d) @maydiscard;
void? thread::sleep_ns(NanoDuration ns) @maydiscard;
```
### Mutex

Followings are basic mutex functions.

```c3
import std::thread;

Mutex mutex;

void? mutex.init();
bool b = mutex.is_initialized();
void? mutex.lock() @maydiscard;
void? mutex.unlock() @maydiscard;
void? mutex.destroy() @maydiscard;
```

Unlike a standard `.lock()` function, which pauses the entire thread and waits until the lock becomes available, `.try_lock()` returns immediately, telling you whether it succeeded or failed, in non-blocking way.

```c3
bool b = mutex.try_lock();
```

A Recursive Mutex allows the same thread to acquire the same lock multiple times without causing a deadlock.

In a standard mutex, if a thread tries to lock a resource it already holds, it will "deadlock" (wait forever for itself to release the lock). A recursive mutex solves this by keeping track of the "ownership count."

```c3
import std::thread;

RecursiveMutex r_mutex;

void? r_mutex.init() @maydiscard;
// other methods are same as mutex
```

Unlike a standard mutex, which will make a thread wait indefinitely (block) until the lock becomes available, a timed mutex allows a thread to try to acquire the lock for a specific duration. If the lock isn't granted within that timeframe, `.lock()` returns false.

```c3
import std::thread;

TimedMutex t_mutex;

void? t_mutex.init();
void? t_mutex.lock_timeout(ulong ms);
// all other methods are same as mutex 
```

TimedRecursive mutex is both timed and recursive.

```c3
import std::thread;

TimedRecursiveMutex tr_mutex;

void? tr_mutex.init() @maydiscard;
```

A typical use of a mutex is a little verbose, std library provides a very simple macro scope for brevity.

```c3
import std::thread;

Mutex mx;
if (catch err = mx.init()) {
  // error handling
}

if (mx.lock()) {
    defer mx.unlock();
    
    // process shared memory here
}

// macro signiture 
macro void Mutex.@in_lock(&mutex; @body);

Mutex mx;
mx.init()!!;

mx.@in_lock(;) { // semicolon needed
    // process shared memory here
};
// semicolon needed
```

### Atomic

Atomic is a fast memory sharing way, because it's supported by 1 cycle CPU instruction and it does not involve system call like mutex.

Atomic is only applied to bool, integers and pointers.

In C3 standard library, there are three set's of atomic operations, (1) simple ones, (2) typed ones, and (3) compile time ones.

For more information, see also [Atomics](atomics.md)

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
old_val = mem::compare_exchange(ptr, old_val, new_value, AtomicOrdering $success = SEQ_CONSISTENT, AtomicOrdering $failure = SEQ_CONSISTENT, bool $volatile = true, bool $weak = false, usz $alignment = 0);
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

For more information, see also [Atomics](atomics.md)

### Condition Variable

In C3, a ConditionVariable is a synchronization primitive used to block a thread until a particular condition is met. It is almost always used in conjunction with a Mutex to protect shared data.

See also [Condition Variable](condition-variable.md)

```c3
import std::thread;

ConditionVariable cond;

void? cond.init();
void? cond.destroy() @maydiscard;
void? cond.signal() @maydiscard;
void? cond.broadcast() @maydiscard;
void? cond.wait(Mutex* mutex) @maydiscard;
void? cond.wait_timeout(Mutex* mutex, #ms_or_duration);
void? cond.wait_until(Mutex* mutex, Time time);
```

* `init() / destroy()`: Handles the lifecycle of the condition variable.
* `wait(Mutex* mutex)`: This is the core function. It atomicaly releases the mutex and puts the thread to sleep. When the thread is woken up (via signal), it automatically re-acquires the mutex before returning.
* `signal()`: Wakes up at least one thread currently waiting on the condition variable.
* `broadcast()`: Wakes up all threads currently waiting.
* `wait_timeout() / wait_until()`: Prevents indefinite blocking by providing a time limit.

See also [Condition Variable](condition-variable.md)

### Channels

In the C3 programming language, channels follow the "message passing" philosophy: instead of sharing memory and using locks (which can lead to race conditions), you move data through a pipe from one thread to another.

The `std::thread::channel` module provides two distinct types of channels: Buffered and Unbuffered.

```c3
import std::thread::channel;

Allocator allocx;
BufferedChannel{Type} b_chan;

void? b_chan.init(allocx, usz size = 1);
void? b_chan.destroy() @maydiscard;
void? b_chan.push(Type val);
Type? b_chan.pop();
void? b_chan.close() @maydiscard;

UnbufferedChannel{Type} ub_chan;

void? ub_chan.init(allocx);
void? ub_chan.destroy() @maydiscard;
void? ub_chan.push(Type val);
Type? ub_chan.pop();
void? ub_chan.close() @maydiscard;
```

##### Buffered Channels (BufferedChannel)

* A buffered channel has a fixed-capacity internal queue (a "mailbox").
* Non-Blocking (mostly): The sender (`push()`) can continue working as long as there is space in the buffer.
* Decoupling: It allows the producing thread to get ahead of the consuming thread without waiting for an immediate "handshake."
* Behavior: If the buffer is full, `push()` will block until a slot becomes available. If the buffer is empty, `pop()` will block until a message is sent.

##### Unbuffered Channels (UnbufferedChannel)

* An unbuffered channel has no internal storage capacity.
* Synchronous Handshake: A `push()` operation will block until another thread calls `pop()` at the same time, and vice versa.
* Guaranteed Delivery: When a push completes, you are 100% certain the receiver has actually received the data.
* Behavior: It acts as a synchronization point, ensuring both threads are at the same stage of execution during the transfer.

### Thread local

A variable can be visible only within a thread, and it is declared as `tlocal`.

```c3
import std::io;
import std::thread;

tlocal int a = 3; // thread local
int b = 3; // global

fn int run(void* arg) // ThreadFn
{
    a++;
    b++;
    return 0;
}

fn void main() 
{
    Thread t1; t1.create(&run, null);  
    Thread t2; t2.create(&run, null);  

    t1.join();
    t2.join();

    io::printfn("%d,%d", a, b); // prints 3,5
}
```

### Thread pool

The C3 programming language provides a built-in thread pool implementation in its standard library (std::thread::pool). This is a powerful tool for managing concurrency without the overhead of manually creating and destroying threads for every task.

```c3
import std::thread::pool;

alias ThreadFn = fn int (void*);

const int NUM = 10;
ThreadPool{NUM} pool;

void? pool.init();
void? pool.push(ThreadFn func, void* arg) @maydiscard;
void? pool.join() @maydiscard;
void? pool.destroy() @maydiscard;
```

1. Initialization

± `ThreadPool{NUM} pool;` This declares a thread pool. In C3, the size (number of worker threads) is often defined at compile-time or initialization.

* `pool.init()`: This allocates the necessary synchronization primitives and starts the worker threads. It returns a `void? (Optional), meaning you should handle potential errors (e.g., if the OS fails to spawn threads).

2. Task Submission

* `void? pool.push(ThreadFn func, void* arg)`: This is how you give the pool work to do.
* ThreadFn: This is a function pointer with a signature like `fn int (void*)`.
* arg: A pointer to any data the function needs.
* @maydiscard: This attribute tells the compiler it's okay if you don't check the return value, though checking for a full queue is usually good practice.

3. Synchronization and Cleanup

* `pool.join()`: This blocks the calling thread (usually the main thread) until all currently queued tasks are completed. Use this when you need to ensure work is done before moving to the next stage of your program.
* `pool.destroy()`: This shuts down the worker threads and frees the memory associated with the pool.

Practical Example

```c3
import std::io;
import std::thread::pool;
import std::thread;

fn int my_task(void* data) {
    usz val = (usz)data;
    if (val == 3) thread::sleep_ms(3000);
    io::printfn("Processing task: %d", val);
    return 0;
}

fn void main() {
    // 1. Declare and Initialize
    ThreadPool{4} pool; 
    if (catch err = pool.init()) {
        io::printn("Failed to init pool");
        return;
    }

    // 2. Push tasks
    for (usz i = 0; i < 10; i++) {
        pool.push(&my_task, (void*)i)!!;
    }

    // 3. Wait and Cleanup
    pool.join();
    pool.destroy();
}
```

Key Considerations

* Memory Safety: Since you are passing `void*` arguments, ensure that the memory pointed to by arg remains valid until the task is executed.
* Error Handling: Always use `if (catch ...)` syntax with `pool.init()` to prevent crashes on systems with restricted threading.


### Once

In the context of concurrent programming, the once pattern is a synchronization primitive used to ensure that a specific piece of code (like initialization) is executed exactly once, even if multiple threads attempt to call it simultaneously.

```c3
import std::thread;

alias OnceFn = fn void();
OnceFlag once;

void once.call(OnceFn func);;
```

* `OnceFlag`: This is a state variable (usually a struct) that keeps track of whether the function has been executed. It starts in an "uninitialized" state.
* `once.call(OnceFn func)`: This method takes a function pointer (OnceFn).
  * If it's the first time any thread calls this, the function is executed.
  * If other threads call it while the function is running, they will block (wait) until the first thread finishes.
  * If a thread calls it after the function has finished, it returns immediately without executing the function again.

Common Use Cases

* Lazy Initialization: Setting up a heavy resource (like a database connection or a configuration file) only when it's first needed.
* Global State Setup: Initializing global variables in a way that is thread-safe without needing a manual mutex lock every time the variable is accessed.
* Plugin Loading: Ensuring a shared library is registered only once in a multi-threaded environment.

Why not just use a bool?

* Using a simple boolean (e.g., `if (!initialized) { init(); }`) is dangerous in multi-threaded programs. Two threads could check the boolean at the same time, see that it is false, and both run the initialization code, leading to "race conditions" or memory leaks.
* `OnceFlag` handles the internal locking and memory barriers required to make this check atomic and safe.

Back to [Table of Contents](0.table-of-contents.md)

