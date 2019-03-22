typedef struct Node *list;

struct Node {
  int elem;
  list next;
};


int main() {
  printInt(length(fromTo(1,50)));
  printInt(length2(fromTo(1,100)));
  return 0;
}

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

int length (list xs) {
  if (xs==(list)null)
    return 0;
  else
    return 1 + length (xs->next);
}

list fromTo (int m, int n) {
  if (m>n)
    return (list)null;
  else 
    return cons (m,fromTo (m+1,n));
}

int length2 (list xs) {
  int res = 0;
  while (xs != (list)null) {
    res++;
    xs = xs->next;
  }
  return res;
}
