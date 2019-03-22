/* parity of positive integers by recursion */

int main () {
  printInt(ev(17)) ;
  return 0 ;
}

int ev (int y) {
  if (y > 0)
    return ev (y-2) ;
  else
    if (y < 0)
      return 0 ;
    else
      return 1 ;
}