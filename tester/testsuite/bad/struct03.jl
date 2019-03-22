
struct Bad {
  int x;
}


int main() {
  Bad b = new Bad;
  b->y = 3;
  return 0;
}
