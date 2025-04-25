struct List {
  int elem;
  List next;
}

int main() {
  printInt(length(fromTo(1,50)));
  printInt(length2(fromTo(1,100)));
  return 0;
}

int head (List xs) {
  return xs.elem;
}
 
List cons(int x, List xs) {
  List n;
  n = new List;
  n.elem = x;
  n.next = xs;
  return n;
}

int length(List xs) {
  if (xs==(List)null)
    return 0;
  else
    return 1 + length(xs.next);
}

List fromTo(int m, int n) {
  if (m>n)
    return (List)null;
  else 
    return cons (m,fromTo (m+1,n));
}

int length2(List xs) {
  int res = 0;
  while (xs != (List)null) {
    res++;
    xs = xs.next;
  }
  return res;
}
