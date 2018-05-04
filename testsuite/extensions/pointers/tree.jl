struct Node {
  tree left;
  int val;
  tree right;
};

typedef struct Node *tree;

struct Header {
  tree elems;
};

typedef struct Header *intset;

void insert (int x, intset s) {
  s->elems = insertTree(x,s->elems);
  return;
}

boolean isElem(int x, intset s) {
  return isElemTree (x,s->elems);
}

tree insertTree(int x,tree t) {
  if (t==(tree)null) {
    tree n1;
    n1 = new Node;
    n1->left = (tree)null;
    n1->val = x;
    n1->right = (tree)null;
    return n1;
  }   
  else if (x < t->val) 
          t->left = insertTree (x,t->left);
  else if (x > t->val)
          t->right = insertTree (x,t->right);
  return t;
}

boolean isElemTree(int x,tree t) {
  if (t==(tree)null)
    return false;
  else if (x==t->val) 
    return true;
  else if (x < t->val)
    return isElemTree (x, t->left);
  else
    return isElemTree(x, t->right);
}

void printElem(int n, intset s) {
  if (isElem(n,s))
     printString("Elem!");
  else
     printString("Not elem!");
  return;
}

int main () {
  intset s;
  s = new Header;
  s->elems = (tree)null;

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
    

    