import std::io;
import std::collections;
fn void main() {
  List{int} l;
  int[3] a;
  l.init_wrapping_array(mem, &a);
  io::printn(l);
  // l.push(3); // Out of boundary error

  ElasticArray{int, 3} ea;
  List{int} l2;
  // l2.init_wrapping_array(tmem, &ea); // compile error
}
