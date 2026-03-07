int main() {
  int x = 1;
  fn<int(int)> addXZ() {
    int z = 3;
    return \int(int y) -> y + x + z;
  }
  printInt(addXZ()(2));
  return 0;
}
