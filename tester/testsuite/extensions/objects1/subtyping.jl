class Animal { double weight; }

class Dog extends Animal { boolean good; }
class Cat extends Animal { int age; }

class Node {
  Animal elem;
  Node next;

  void   setElem(Animal a) { elem = a; }
  void   setNext(Node n) { next = n; }
  Animal getElem() { return elem; }
  Node   getNext() { return next; }
}

class Stack {
  Node head;

  boolean isEmpty() { return head==(Node)null; }

  void push(Animal a) {
    Node newHead = new Node;
    newHead.setElem(a);
    newHead.setNext(head);
    head = newHead;
  }

  void pop() { head = head.getNext(); }
  Animal top() { return head.getElem(); }
}

void pushBigger(Stack s, Animal x, Animal y) {
  if (x.weight > y.weight) {
    s.push(x);
  } else {
    s.push(y);
  }
}


int main() {
  Stack s = new Stack;

  Dog d1 = new Dog;
  d1.weight = 10.0;

  Cat c1 = new Cat;
  c1.weight = 5.0;

  pushBigger(s, d1, c1);

  Dog d2 = new Dog;
  d2.weight = 8.0;

  s.push(d2);

  while (!s.isEmpty()) {
    Animal a = s.top();
    printDouble(a.weight);
    s.pop();
  }
  return 0;
}