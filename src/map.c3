import std::io;
import std::collections;

fn void main() {
  HashMap{int,int} m;
  m[4] = 2;
  m[5]= 7;
  io::printn(m);
  foreach(i, v: m.value_iter()) {
    io::printfn("%d %d", i, v);
  }
  foreach(i, k: m.key_iter()) {
    io::printfn("%d %d", i, k);
  }
  foreach(i, e: m.iter()) {
    io::printfn("%d %d:%d", i, e.key, e.value);
  }
  foreach(i, &e: m.iter()) {
    e.key = 6; e.value = 10;
  }
  io::printn(m);
}
