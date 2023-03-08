int foldLeft(int mempty, fn(int, int) -> int f, int[] xs) {
  int go(int acc, int[] arr, int i) {
    if (i >= arr.length) {
      return acc;
    } else {
      return go(f(acc, arr[i]), arr, i+1);
    }
  }
  return go(mempty, xs, 0);
}

int main() {
  int[] xs = new int[6];
  int j = 0;
  while (j < xs.length) {
    xs[j] = j + 1;
    j++;
  }

  fn(int[]) -> int prod = \(int[] xs) -> int: foldLeft(1, \(int x, int y) -> int: x * y, xs);

  int v = prod(xs);
  printInt(v);

  return 0;
}
