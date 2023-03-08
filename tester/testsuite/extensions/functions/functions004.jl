int main() {
  int x = 1;
  fn(int) -> int addX(fn(int) -> int f) {
    return \(int y) -> int: f(y) + x;
  }
  printInt(addX(\(int y) -> int: y + 3)(2));
  return 0;
}
