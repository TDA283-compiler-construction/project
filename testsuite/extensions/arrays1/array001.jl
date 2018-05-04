int main() {

  int[] a = new int[10];
  int j=0;
  while (j<a.length) {
     a[j] = j;
     j++;
  }

  for (int x : a) 
     printInt(x);

  int x = 45;
  printInt(x);
  return 0;
}