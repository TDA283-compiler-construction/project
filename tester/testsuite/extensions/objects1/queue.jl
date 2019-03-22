class Node {
  int elem;
  Node next;

  void setElem (int e)  { elem = e; }
  void setNext (Node n) { next = n; }

  int  getElem () { return elem; }
  Node getNext () { return next; }

}

class IntQueue {
  Node front;
  Node rear;

  boolean isEmpty () { return front == (Node)null; }

  void insert (int x) {
    Node last = new Node;
    last.setElem(x);
    if (self.isEmpty())
      front = last;
    else 
      rear.setNext(last);
    rear = last;
  }

  int first () { return front.getElem(); }

  void rmFirst () {
    front = front.getNext();
  }

  int size () {
      Node n = front;
      int res = 0;
      while (n != (Node)null) {
        n = n.getNext();
        res++;
      }
     return res;
  }
}

int f (int x) {
  return x*x + 3;
}

int main () {
  IntQueue q = new IntQueue;
  q.insert(f(3));
  q.insert(5);
  q.insert(7);
  printInt(q.first());
  q.rmFirst();
  printInt(q.size());
  return 0;
}

     