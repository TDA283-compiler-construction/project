int main() {

  int[] a = new int[10];
  int[] b = new int[10];

  int j=0;
  while (j<a.length) {
     a[j] = 5 * j;
     j++;
  }

  b = a;
  b[0] = 500;

  for (int x : a)
     printInt(x);

  return 0;
}
