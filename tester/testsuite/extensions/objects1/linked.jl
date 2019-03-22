class Node {
  int elem;
  Node next;

  void setElem(int c) { elem = c; }

  void setNext(Node n) { next = n; }

  int getElem() { return elem; }

  Node getNext() { return next; }
}

class Stack {
  Node head;

  void push(int c) {
    Node newHead = new Node;
    newHead.setElem(c);
    newHead.setNext(head);
    head = newHead;
  }

  boolean isEmpty() {
    return head==(Node)null;
  }

  int top() {
    return head.getElem();
  }

  void pop() {
    head = head.getNext();
  }
}

int main() {
   Stack s = new Stack;
   int i= 0;
   while (i<10) {
     s.push(i);
     i++;
   }
     
   while (!s.isEmpty()) {
     printInt(s.top());
     s.pop();
   }
   return 0;
}
