int main() {
  int x = 1;
  fn(double) -> int addX(fn(double) -> int f) {
    return \(double y) -> int: f(y) + x;
  }
  printInt(addX(\(int y) -> int: y + 3)(2.0));
  return 0;
}
