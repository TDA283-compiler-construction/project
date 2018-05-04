int main() {

  double[] vector = new double[4];
  double[][] matrix = new double[3][4];

  int i=0;
  while (i<matrix.length) {
    int j=0;
    while (j<matrix[0].length) {
       matrix[i][j] = 5.0;
       j++;
    }
    i++;
  }

  i=0;
  while (i<vector.length-1) {
     vector[i] = 3.0;
     i++;
  }

  matrix[0] = vector; 

  int j = 0;
  while (j<vector.length) {
    matrix[1][j] = vector[j]+1.0;
    j++;
  }
  
  for (double[] x : matrix)
    for (double y : x)
      printDouble(y);

  return 0 ;
}
