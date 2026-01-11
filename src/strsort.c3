import std::io;
import std::collections::list;
import libc;
import std::sort;

fn int cmp(String a, String b) {
  return libc::strncmp((char*)a, (char*)b, a.len);
}

fn void main() {
  List{String} l;
  l.push("abc");
  l.push("xyz");
  l.push("def");
  sort::quicksort(&l, &cmp);
  io::printn(l);
}
