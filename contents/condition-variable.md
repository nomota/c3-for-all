# Condition variable

In C3, a ConditionVariable is a synchronization primitive used to block a thread until a particular condition is met. It is almost always used in conjunction with a Mutex to protect shared data.

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

* Note: all  `void?` can be ignored if not `@maydiscard` annotated.

1. Method Overview

* `init() / destroy()`: Handles the lifecycle of the condition variable.
* `wait(Mutex* mutex)`: This is the core function. It atomicaly releases the mutex and puts the thread to sleep. When the thread is woken up (via signal), it automatically re-acquires the mutex before returning.
* `signal()`: Wakes up at least one thread currently waiting on the condition variable.
* `broadcast()`: Wakes up all threads currently waiting.
* `wait_timeout() / wait_until()`: Prevents indefinite blocking by providing a time limit.

See also [Threads](threads.md)

2. Typical Workflow

The interaction between the Mutex and the Condition Variable follows a specific sequence to ensure no data races occur:

* Thread A locks the Mutex.
* Thread A checks a condition (e.g., `is_queue_empty`). If true, it calls `wait()`.
* Thread B locks the Mutex, updates the data (e.g., `push_to_queue`), and calls `signal()`.
* Thread A wakes up, re-locks the Mutex, and continues execution.

3. Practical Example: Producer-Consumer

Here is a standard example where a "Worker" thread waits for a "Main" thread to provide data.

```c3
import std::io;
import std::thread;

struct TaskData {
    Mutex mutex;
    ConditionVariable cond;
    bool is_ready;
    int payload;
}

fn int worker_func(void* arg) // ThreadFn
{
    TaskData* data = (TaskData*) arg;
    // 1. Lock the mutex to check the shared state
    data.mutex.lock();
    defer data.mutex.unlock();
    
    // 2. Always use a 'while' loop to protect against "spurious wakeups"
    while (!data.is_ready) {
        io::printn("Worker: Data not ready, going to sleep...");
        // This releases the mutex and sleeps. 
        // Upon waking, it re-acquires the mutex.
        data.cond.wait(&data.mutex);
    }
    
    // 3. Access the protected data safely
    io::printfn("Worker: Data received! Value: %d", data.payload);
}

fn void main() 
{
    TaskData data;
    data.mutex.init();
    data.cond.init()!!;
    data.is_ready = false;

    // Spawn the worker thread
    Thread t; t.create(&worker_func, &data);

    // Simulate some work...
    thread::sleep_ms(1000);
    
    // 4. Update the shared state and notify the worker
    data.mutex.lock();
    data.payload = 100;
    data.is_ready = true;
    io::printn("Main: Data is ready, signaling worker.");
    data.cond.signal(); 
    data.mutex.unlock();

    t.join();
    
    data.cond.destroy();
    data.mutex.destroy();
}
```

Key Rules to Remember

* The "Lost Wakeup" Problem: Never call `signal()` or `broadcast()` unless you have updated the state that the waiter is checking. If you signal before the waiter has actually started waiting, the signal is "lost."
* Spurious Wakeups: A thread might wake up even if no signal was sent (due to OS implementation details). This is why you must check your condition in a while loop:

```c3
// Correct
while (!condition) { cond.wait(&mutex); }

// Dangerous
if (!condition) { cond.wait(&mutex); }
```

### Thread safe queue 

Implementing a thread-safe Queue is the perfect way to see `ConditionVariable` in action. In this pattern, we use the condition variable to handle two specific states:

* Preventing Overflows: The producer waits if the queue is full.
* Preventing Underflows: The consumer waits if the queue is empty.

#### Thread-Safe Queue Implementation

This example demonstrates a fixed-size buffer where multiple threads can safely push and pop integers.

```c3
import std::io;
import std::thread;

const usz QUEUE_SIZE = 5;

struct SafeQueue {
    Mutex mutex;
    ConditionVariable not_full;  // Signaled when a slot becomes available
    ConditionVariable not_empty; // Signaled when data is added
    int[QUEUE_SIZE] buffer;
    uint count;
    uint head;
    uint tail;
}

fn void SafeQueue.init(&self) 
{
    self.mutex.init();
    self.not_full.init();
    self.not_empty.init();
    self.count = 0;
    self.head = 0;
    self.tail = 0;
    return;
}

fn void SafeQueue.push(&self, int value) 
{
    self.mutex.lock();
    defer self.mutex.unlock();
    
    // Wait while the buffer is full
    while (self.count >= QUEUE_SIZE) {
        self.not_full.wait(&self.mutex);
    }
    
    self.buffer[self.tail] = value;
    self.tail = (self.tail + 1) % QUEUE_SIZE;
    self.count++;
    
    // Notify consumers that data is available
    self.not_empty.signal();
}

fn int SafeQueue.pop(&self) 
{
    self.mutex.lock();
    defer self.mutex.u lock();
    
    // Wait while the buffer is empty
    while (self.count == 0) {
        self.not_empty.wait(&self.mutex);
    }
    
    int value = self.buffer[self.head];
    self.head = (self.head + 1) % QUEUE_SIZE;
    self.count--;
    
    // Notify producers that there is space available
    self.not_full.signal();

    return value;
}
```

#### How the Synchronization Works

In the diagram above, you can see the cycle of "waiting" and "signaling":

* The Mutex acts as a gatekeeper, ensuring only one thread modifies the `count, head, or tail` at a time.
* `not_empty.wait()`: If a consumer arrives and the queue is empty, it goes to sleep. It "gives up" its turn at the gate (the Mutex) so a producer can enter.
* `not_empty.signal()`: When a producer adds an item, it rings the "not empty" bell. This wakes up one sleeping consumer.
* `not_full.signal()`: Similarly, when a consumer removes an item, it rings the "not full" bell to let producers know there is room for more data.

#### Why use two Condition Variables?

Using two (`not_full and not_empty`) is more efficient than using one. If you used only one, `signal()` might wake up a producer when you actually needed to wake up a consumer, leading to unnecessary CPU cycles. By using two, you ensure you are waking up exactly the type of thread that can make progress.


Back to [Condition Variable](0.table-of-contents.md)

