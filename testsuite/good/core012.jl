/* Test arithmetic and comparisons. */

int main() {
    int x = 56;
    int y = -23;
    printInt(x+y);
    printInt(x-y);
    printInt(x*y);
    printInt(45/2);
    printInt(78%3);
    double z = -9.3;
    double w = 5.1;
    printBool(z+w > z-w);
    printBool(z/w <= z*w);
    return 0 ;
}

void printBool(boolean b) {
  if (b) {
    printString("true");
    return;
  } else {
    printString("false");
    return;
 }
}