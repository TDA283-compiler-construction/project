int main() {
  many_params(1,2,3,4,
              100.0,100.0,100.0,100.0,
              200.0,200.0,200.0,200.0,
              300.0,300.0,300.0,300.0,
              400.0,400.0,400.0,400.0,
              5,6,7,8,
              9,10,11,12,
              13,14,15);
  return 0;
}

void many_params(int x1, int x2, int x3, int x4,
                double d01, double d02, double d03, double d04,
                double d11, double d12, double d13, double d14,
                double d21, double d22, double d23, double d24,
                double d31, double d32, double d33, double d34,
                int y1, int y2, int y3, int y4,
                int z1, int z2, int z3, int z4,
                int q1, int q2, int q3) {
  printInt(x1);
  printInt(y1);
  printInt(z1);
  printInt(q1);
  printDouble(d01);
  printDouble(d11);
  printDouble(d21);
  printDouble(d31);
  if (x1 != 2) {
    many_params(q3,x1,x2,x3,
                d04/2.0,d01*2.0,d02+1.0,d03-0.0,
                d14/2.0,d11*2.0,d12+1.0,d13-0.0,
                d24/2.0,d21*2.0,d22+1.0,d23-0.0,
                d34/2.0,d31*2.0,d32+1.0,d33-0.0,
                x4,y1,y2,y3,
                y4,z1,z2,z3,
                z4,q1,q2);
  }
}
