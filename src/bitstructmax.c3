import std::io;

bitstruct BitS : int {
  int a:0..3;
}

fn void main() {
  BitS x;
  int y;
  io::printfn("%d", $typeof(x.a).max); // 2147483647
  io::printfn("%d", $typeof(y).max); // 2147483647
  x.a = 5; // Ok
  x.a = 100; // Compile Error
}
