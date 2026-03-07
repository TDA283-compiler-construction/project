int main() {
  int x = 4;
  fn<int(int)> dbl = \int(int x) -> x + x;
  printInt(dbl(x));
  return 0;
}
