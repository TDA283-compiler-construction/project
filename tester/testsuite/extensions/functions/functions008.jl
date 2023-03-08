data List {
  Nil();
  Cons(int, List);
}

List map(fn(int) -> int f, List list) {
  case (list) {
    Nil(): return new Nil();
    Cons(head, tail): {
      return new Cons(f(head), map(f, tail));
    }
  }
}

int main() {

  List gen(int n) {
    if (n == 0) {
      return new Nil();
    } else {
      return new Cons(n, gen(n - 1));
    }
  }

  void printList(List list) {
    case (list) {
      Cons(head, tail): {
        printInt(head);
        printList(tail);
      }
    }
    return;
  }

  List l = gen(5);

  List mapped = map(\(int x) -> int: x * 2, l);

  printList(mapped);

  return 0;
}