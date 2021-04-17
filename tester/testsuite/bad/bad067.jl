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
