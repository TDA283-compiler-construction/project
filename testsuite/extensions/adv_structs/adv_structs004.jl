enum Square{
  NONE,  // Default value
  KING,
  QUEEN,
  ROOK,
  KNIGHT,
  BISHOP,
  PAWN
};

Square[] initRow(){
  Square[] row = new Square[8];
  row[0] = Square.ROOK;
  row[7] = Square.ROOK;
  row[1] = Square.BISHOP;
  row[6] = Square.BISHOP;
  row[2] = Square.KNIGHT;
  row[5] = Square.KNIGHT;
  row[3] = Square.KING;
  row[4] = Square.QUEEN;
  return row;
}

Square[][] createBoard(){
  Square[][] board = new Square[8][8];
  board[0] = initRow();
  board[7] = initRow();
  return board;
}

int main(){
  Square[][] board = createBoard();
  if(board[0][4] == Square.QUEEN){
    printString("Queen is in correct pos");
  } else{
    printString("The queen is gone :(");
  }
  return 0;
}