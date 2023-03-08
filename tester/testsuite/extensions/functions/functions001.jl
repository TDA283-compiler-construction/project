int main() {
  int x = 1;
  int addX(int y) {
    return x + y;
  }
  printInt(addX(2));
  return 0;
}
