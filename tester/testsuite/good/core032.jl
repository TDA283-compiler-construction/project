int foo(int n) {
  if (n < 100) {
    n = foo(foo(n + 11));
  }
  return n;
}

int main() {
  printInt(foo(1));
  return 0;
}
