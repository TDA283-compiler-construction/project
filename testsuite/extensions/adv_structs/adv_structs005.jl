enum Color {
  RED,
  GREEN,
  BLUE
};

typedef struct Palette_t{
  Color color;
} * Palette;

int main(){
  Color color = Color.RED;
  if(color == Color.RED){
    printString("red");
  } else{
    printString("not red");
  }
  Palette p = new Palette_t;
  p->color = Color.GREEN;
  if(p->color == Color.GREEN){
    printString("green");
  } else{
    printString("not green");
  }
  return 0;
}
