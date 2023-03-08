int main() {
  int x = 1;
  fn(int) -> boolean addX() {
    return \(int y) -> boolean: y + x;
  }
  printInt(addX()(2));
  return 0;
}
