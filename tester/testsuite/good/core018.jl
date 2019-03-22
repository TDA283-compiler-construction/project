/* test input */

int main() {
  int x = readInt();
  double y = readDouble();

  printInt(x-5);
  
  if (y > 42.0 || y < 43.0) 
    printString("yay!");
  else
    printString("nay!");
  return 0 ;

}