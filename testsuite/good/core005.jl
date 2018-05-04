/* usage of variable initialized in both branches. */

int main () {
  int x;
  int y = 56;
  if (y + 45 <= 2) {
    x = 1;
  } else {
    x = 2;
  }
  printInt(x);
  return 0 ;

}