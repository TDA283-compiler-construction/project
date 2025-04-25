typedef struct Node *list;

struct Node {
  int elem;
  list next;
};

int head (list xs) {
  return xs -> elem;
}

list cons (int x, list xs) {
  list n;
  n = new Node;
  n->elem = x;
  n->next = xs;
  return n;
}

list fromTo (int m, int n) {
  if (m>n)
    return (list)null;
  else 
    return cons (m, fromTo(m+1,n));
}

int foldLeft(int mempty, fn(int, int) -> int f, list xs) {
  int go(int acc, list xs) {
    if (xs == (list)null) {
      return acc;
    } else {
      return go(f(acc, xs->elem), xs->next);
    }
  }
  return go(mempty, xs);
}

int main() {
  list xs = fromTo(1,6);

  fn(list) -> int prod = \(list xs) -> int: foldLeft(1, \(int x, int y) -> int: x * y, xs);

  int v = prod(xs);
  printInt(v);

  return 0;
}
