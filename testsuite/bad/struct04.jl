


typedef struct Bad *Dab;

struct Bad {
  Dab d;
}

int main() {
  Dab a = new Bad;
  Dab b = a->d;
  b->y = new Bad;
  return 0;
}
