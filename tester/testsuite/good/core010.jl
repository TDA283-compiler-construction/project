// count function parameters as initialized

int main() {
  printInt(fac(5));
  return 0 ;
}

int fac (int a) {
  int r;
  int n;
  r = 1;
  n = a;
  while (n > 0)
  {
    r = r * n;
    n = n - 1;
  }
  return r;
}
