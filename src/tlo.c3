import std::io;
import std::thread;

tlocal int a = 3;
int b = 3;

fn int run(void* arg) {
  a++;
  b++;
  return 0;
}

fn void main() {
  Thread t1; t1.create(&run, null)!!;  
  Thread t2; t2.create(&run, null)!!;  

  t1.join()!!;
  t2.join()!!;
  io::printfn("%d,%d", a, b);
}
