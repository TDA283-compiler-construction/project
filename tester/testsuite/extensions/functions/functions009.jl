int main() {
  int x = 4;
  fn(int) -> int dbl = \(int x) -> int: x + x;
  printInt(dbl(x));
  return 0;
}
