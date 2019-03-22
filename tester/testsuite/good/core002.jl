/* void expression as statement */

int main() {
  foo();
  return 0 ;

}

void foo() {
   printString("foo");
   return;
}
