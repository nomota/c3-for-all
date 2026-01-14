import std::io;
import std::thread::pool;
import std::thread;

fn int my_task(void* data) {
    usz val = (usz)data;
    if (val == 7) thread::sleep_ms(3000);
    io::printfn("Processing task: %d", val);
    return 0;
}

fn void main() {
    // 1. Declare and Initialize
    const int N = 10;
    ThreadPool{N} pool; 
    if (catch err = pool.init()) {
        io::printn("Failed to init pool");
        return;
    }

    // 2. Push tasks
    for (usz i = 0; i < N; i++) {
        pool.push(&my_task, (void*)i)!!;
    }

    // 3. Wait and Cleanup
    // pool.join();
    pool.destroy()!!;
}

