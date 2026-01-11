import std::io;
import std::collections::list;

fn bool filter(int* d)
{
  if (*d % 2 == 0) return true;
  return false;
}

fn void main() {
  List{int} l;
  l.push(2);
  l.push(3);
  l.push(5);
  usz n = l.retain_if(&filter);
  io::printf("%d: %s", n, l);
}
