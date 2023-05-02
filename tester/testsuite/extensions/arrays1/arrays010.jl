int[] foo() {
  printString("new array");
  return new int[5];
}

int main() {
  foo()[0]++;
  return 0;
}
