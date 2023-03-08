int main() {
  int x = 5;
  int timesX(int n) {
    if (n <= 0) {
      return 0;
    } else {
      return x + timesX(n - 1);
    }
  }
  printInt(timesX(6));
  printInt(timesX(100));
  return 0;
}
