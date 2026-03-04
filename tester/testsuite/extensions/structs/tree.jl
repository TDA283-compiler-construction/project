struct Tree {
  Tree left;
  int val;
  Tree right;
}

struct IntSet {
  Tree elems;
}

void insert (int x, IntSet s) {
  s.elems = insertTree(x,s.elems);
}

boolean isElem(int x, IntSet s) {
  return isElemTree (x,s.elems);
}

Tree insertTree(int x,Tree t) {
  if (t==(Tree)null) {
    Tree n1 = new Tree;
    n1.left = (Tree)null;
    n1.val = x;
    n1.right = (Tree)null;
    return n1;
  }
  else if (x < t.val) 
    t.left = insertTree(x,t.left);
  else if (x > t.val)
    t.right = insertTree(x,t.right);
  return t;
}

boolean isElemTree(int x,Tree t) {
  if (t==(Tree)null)
    return false;
  else if (x==t.val) 
    return true;
  else if (x < t.val)
    return isElemTree (x, t.left);
  else
    return isElemTree(x, t.right);
}

void printElem(int n, IntSet s) {
  if (isElem(n,s))
     printString("Elem!");
  else
     printString("Not elem!");
  return;
}

int main () {
  IntSet s = new IntSet;
  s.elems = (Tree)null;

  int x = 3;
  int i = 0;
  while (i<100) {
    x = (x * 37) % 100;
    i++;
    insert(x, s);
  }
  printElem(23,s);
  printElem(24,s);
  printElem(25,s);
  return 0;
}
