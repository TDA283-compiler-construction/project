
struct Bad {
  int x;
};

typedef struct Bad *Bad;

int main() {
  Bad b = new Bad;
  b->x = true;
  return 0;
}
