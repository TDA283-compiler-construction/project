// Testing the return checker

int f () {
   if (true)
     return 0;
   else
     {}
}

int g () {
  if (false) 
      {}
  else
      return 0;
}

void p () {}
  
int main() {
  p();
  return 0;
}

// bad067.jl

    /* Test increment/decrements for doubles. Only int allowed */
    int main () {
      double x = 1.0 ;
      x++;  // Only for variables of type int
      x--;  // Only for variables of type int
      return 0;
    }

