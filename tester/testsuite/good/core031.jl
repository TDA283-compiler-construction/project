int main() {
  many_params(1,2,3,4,
              100.0,100.0,100.0,100.0,
              5,6,7,8,
              9,10,11,12,
              13,14,15,16);
  return 0;
}

void many_params(int x1, int x2, int x3, int x4,
                double d1, double d2, double d3, double d4,
                int y1, int y2, int y3, int y4,
                int z1, int z2, int z3, int z4,
                int q1, int q2, int q3, int q4) {
  printInt(x1);
  printInt(y1);
  printInt(z1);
  printInt(q1);
  printDouble(d1);
  if (x1 != 2) {
    many_params(q4,x1,x2,x3,
                d4/2.0,d1*2.0,d2+1.0,d3-0.0,
                x4,y1,y2,y3,
                y4,z1,z2,z3,
                z4,q1,q2,q3);
  }
}
