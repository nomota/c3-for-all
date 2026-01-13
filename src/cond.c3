import std::io;
import std::thread;

struct TaskData {
    Mutex mutex;
    ConditionVariable cond;
    bool is_ready;
    int payload;
}

fn int worker_func(void* vdata) {
    TaskData* data = vdata;
    // 1. Lock the mutex to check the shared state
    data.mutex.lock()!!;
    defer data.mutex.unlock()!!;
    
    // 2. Always use a 'while' loop to protect against "spurious wakeups"
    while (!data.is_ready) {
        io::printn("Worker: Data not ready, going to sleep...");
        // This releases the mutex and sleeps. 
        // Upon waking, it re-acquires the mutex.
        data.cond.wait(&data.mutex)!!;
    }
    
    // 3. Access the protected data safely
    io::printfn("Worker: Data received! Value: %d", data.payload);
    return 0;
}

fn void main() {
    TaskData data;
    data.mutex.init()!!;
    data.cond.init()!!;
    data.is_ready = false;

    // Spawn the worker thread
    Thread t;
    t.create(&worker_func, &data)!!;

    // Simulate some work...
    thread::sleep_ms(1000);
    
    // 4. Update the shared state and notify the worker
    data.mutex.lock()!!;
    data.payload = 100;
    data.is_ready = true;
    io::printn("Main: Data is ready, signaling worker.");
    data.cond.signal()!!;
    data.mutex.unlock()!!;

    t.join()!!;
    
    data.cond.destroy()!!;
    data.mutex.destroy()!!;
}
