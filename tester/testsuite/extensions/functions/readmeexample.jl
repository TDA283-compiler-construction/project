int apply(fn(int) -> int f, int x) {
  return f(x);
}

fn(int) -> int compose(fn(int) -> int f, fn(int) -> int g) {
  return \(int x) -> int: f(g(x));
}

int main() {
  int inc(int x) {
    return x + 1;
  }
  fn(int) -> int times2 = \(int x) -> int: x * 2;

  printInt(apply(compose(inc, times2), 3));
  printInt(apply(compose(times2, inc), 3));

  return 0;
}
