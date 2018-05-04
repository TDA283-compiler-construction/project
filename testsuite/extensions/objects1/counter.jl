int main () {
  Counter c;
  c = new Counter;
  c.incr();
  c.incr();
  c.incr();
  int x = c.value();
  printInt(x);
  return 0;
}

class Counter {
  int val;

  void incr () {val++; return;}

  int value () {return val;}

}
