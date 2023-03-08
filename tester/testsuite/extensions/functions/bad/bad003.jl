int main() {
  int x = 1;
  fn(int) -> int addX(fn(int) -> int f) {
    return \(int y) -> int: f(y) + x;
  }
  printInt(addX(\(double y) -> double: y + 3.0)(2));
  return 0;
}
