int main() {

  int[][][] a3 = new int[3][4][5];

  a3[2] = a3[1];

  int p=0;
  int i=0;
  while (i<a3.length) {
    int j=0;
    while (j<a3[0].length) {
      int k=0;
      while (k<a3[0][0].length) {
        a3[i][j][k] = p;
        p++;
        k++;
      }
      j++;
    }
    i++;
  }

  for (int[][] x : a3)
    for (int[] y : x)
      for (int t : y)
        printInt(t);

  return 0 ;
}
