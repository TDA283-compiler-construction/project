int main() {

  int x = 1;

  int one() {
    return 1;
  }

  int fib(int n) {
    printInt(x);
    if (n <= 1) {
      return n;
    } else {
      return fib(n-1) + fib(n-2);
    }
  }

  printInt(fib(3));

  return 0;
}