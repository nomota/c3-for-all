import std::io;
import std::sort;

fn int cmp(int a, int b) {
  return a-b;
}

fn void main() {
  int[] a = { 8, 3, 2, 9, 4, 6 };
  usz i = sort::binarysearch(a, 5, &cmp);
  io::printfn("%d", i);
}
