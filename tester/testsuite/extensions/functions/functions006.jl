int apply(fn<int(int)> f, int x) {
  return f(x);
}

fn<int(int)> compose(fn<int(int)> f, fn<int(int)> g) {
  return \int(int x) -> f(g(x));
}

int main() {
  fn<int(int)> inc = \int(int x) -> x + 1;
  fn<int(int)> times2 = \int(int x) -> x * 2;

  printInt(apply(compose(inc, times2), 3));
  printInt(apply(compose(times2, inc), 3));

  return 0;
}
