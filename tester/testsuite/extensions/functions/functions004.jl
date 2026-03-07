int main() {
  int x = 1;
  fn<int(int)> addX(fn<int(int)> f) {
    return \int(int y) -> f(y) + x;
  }
  printInt(addX(\int(int y) -> y + 3)(2));
  return 0;
}
