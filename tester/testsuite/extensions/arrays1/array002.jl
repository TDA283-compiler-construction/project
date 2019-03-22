int [] doubleArray (int [] a){
  int [] res = new int [a . length];
  int i = 0 ;
  for (int n : a){
    res [i] = 2 * n ;
    i ++ ;
  }
  return res ;
}

void shiftLeft (int [] a){
  int x = a [0];
  int i = 0 ;
  while (i < a.length - 1){
    a [i] = a [i + 1];
    i ++ ;
  }
  a[a.length - 1]= x ;
  return;
 }

int scalProd(int[] a, int[] b) {
  int res = 0;
  int i = 0;
  while (i < a.length) {
    res = res + a[i] * b[i];
    i++;
  }
  return res;
}

int main () {
  int [] a = new int [5];
  int i = 0 ;
  while (i < a.length){
    a [i]= i ;
    i ++ ;
    }
  shiftLeft (a);
  int [] b = doubleArray (a);
  for (int x : a)printInt (x);
  for (int x : b)printInt (x);
  printInt(scalProd(a,b));
  return 0 ;
}
 