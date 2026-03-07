int main() {
  int x = 1;
  fn<int(int)> addX() {
    return \int(int y) -> y + x;
  }
  printInt(addX()(2));
  return 0;
}
