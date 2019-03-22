/* Test boolean operators */

int main () {
  int x = 4;
  if (3 <= x && 4 != 2 && true) {
    printBool(true);
  } else {
    printString("apa");
  }

  printBool(true == true || dontCallMe(1));
  printBool(4.0 < -50.0 && dontCallMe(2));

  printBool(4 == x && true == !false && true);

  printBool(implies(false,false));
  printBool(implies(false,true));
  printBool(implies(true,false));
  printBool(implies(true,true));
  return 0 ;

}

boolean dontCallMe(int x) {
  printInt(x);
  return true;
}

void printBool(boolean b) {
  if (b) {
    printString("true");
  } else {
    printString("false");
 }
 return;
}

boolean implies(boolean x, boolean y) {
  return !x || x == y;
}
