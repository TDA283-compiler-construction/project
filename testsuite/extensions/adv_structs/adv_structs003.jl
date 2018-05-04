enum Color {
  RED,
  GREEN,
  BLUE
};

int main(){
  Color color = Color.RED;
  if(color == Color.RED){
    printString("red");
  } else{
    printString("not red");
  }
  return 0;
}