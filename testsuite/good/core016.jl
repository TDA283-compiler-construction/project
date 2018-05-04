/* parity of positive integers by loop */

int main () {
  int y = 17;
  while (y > 0)
    y = y - 2;
  if (y < 0) {
    printInt(0);
    return 0 ;
    }
  else {
    printInt(1);
    return 0 ;
    }
}
