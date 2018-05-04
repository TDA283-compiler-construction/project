int main() {
  boolean[] bools = new boolean[10];
  double[] doubles = new double[10];
  int j=0;
  double x = 0.0;
  while (j<bools.length) {
    doubles[j] = x*2.5;
    bools[j] = doubles[j] > 15.0;
    j++;
    x = x + 1.0;
  }

  j = 0;
  for(boolean b : bools) {
    if(b) {
      printString("yes");
    } else {
      printDouble(doubles[j]);
    }
    j++;
  }
  return 0;
}
