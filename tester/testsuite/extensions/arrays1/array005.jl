int foo(int x) {
  return x + x;
}

int main () {
  // The grammar should accept any expression to the left of the
  // dot, and any expression inside [ ].
  printInt(new int[foo(7)].length);
  return 0;
}
