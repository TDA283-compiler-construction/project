// Our struct to use in the array
typedef struct Foo_t{
  int bar;
} * Foo;

int main(){
  // Init struct array
  Foo[] foos = new Foo[10];

  // Init all values (default value is null)
  int i = 0;
  while(i < foos.length){
    foos[i] = new Foo_t;
    foos[i]->bar = i;
    i++;
  }

  // Print all values
  printInt(foos.length);
  for(Foo foo : foos){
     printInt(foo->bar);
  }
  return 0;
}
