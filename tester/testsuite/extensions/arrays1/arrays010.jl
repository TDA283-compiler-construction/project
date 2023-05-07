int[] foo() {
  printString("new array");
  return new int[5];
}

int bar() {
  printString("new index");
  return 0;
}

int main() {
  foo()[bar()]++;
  return 0;
}
