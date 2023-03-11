int[] map(int[] xs, fn(int) -> int f) {
  int[] ys = new int[xs.length];
  int j = 0;
  while (j < xs.length) {
    ys[j] = f(xs[j]);
    j++;
  }
  return ys;
}

void printArray(int[] xs) {
  for (int x : xs) {
    printInt(x);
  }
}

int main() {
  int[] xs = new int[5];
  int j = 0;
  while (j < xs.length) {
    xs[j] = j + 1;
    j++;
  }

  int[] ys = map(xs, \(int x) -> int: x * 2);
  printArray(xs);
  printArray(ys);

  return 0;
}
