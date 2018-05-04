class Point2 {
  int x;
  int y;

  void move (int dx, int dy) {
     x = x + dx;
     y = y + dy;
  }

  int getX () { return x; }

  int getY () { return y; }
}

class Point3 extends Point2 {
  int z;

  void moveZ (int dz) {
    z = z + dz;
  }

  int getZ () { return z; }

}

class Point4 extends Point3 {
  int w;

  void moveW (int dw) {
    w = w + dw;
  }

  int getW () { return w; }

}



int main () {
  Point2 p = new Point3;

  Point3 q = new Point3;

  Point4 r = new Point4;

  q.move(2,4);
  q.moveZ(7);
  p = q;

  p.move(3,5);
 
  r.move(1,3);
  r.moveZ(6);
  r.moveW(2);

  printInt(p.getX());  
  printInt(p.getY());  
  printInt(q.getZ());  
  printInt(r.getW());
  return 0;

}