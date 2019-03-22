
struct Bad {
  int x;
};

int main() {
  Bad b = new Bad;
  b->x = true;
  return 0;
}

