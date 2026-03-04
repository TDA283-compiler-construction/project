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
    return cons (m,fromTo (m+1,n));
}

list map(list xs, fn(int) -> int f) {
  if (xs == (list)null) {
    return (list)null;
  } else {
    return cons(f(xs->elem), map(xs->next, f));
  }
}

void printList(list xs) {
  while (xs != (list)null) {
    printInt(xs->elem);
    xs = xs->next;
  }
}

int main() {
  list xs = fromTo(1,5);
  list ys = map(xs, \(int x) -> int: x * 2);
  printList(xs);
  printList(ys);

  return 0;
}
