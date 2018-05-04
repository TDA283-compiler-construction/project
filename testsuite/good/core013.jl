/* Test boolean operators. */

int main() {
  printString("&&");
  printBool(test(-1) && test(0));
  printBool(test(-2) && test(1));
  printBool(test(3) && test(-5));
  printBool(test(234234) && test(21321));
  printString("||");
  printBool(test(-1) || test(0));
  printBool(test(-2) || test(1));
  printBool(test(3) || test(-5));
  printBool(test(234234) || test(21321));
  printString("!");
  printBool(true);
  printBool(false);
  return 0 ;

}

void printBool(boolean b) {
  if (!b) {
    printString("false");
  } else {
    printString("true");
 }
 return;
}

boolean test(int i) {
  printInt(i);
  return i > 0;
}