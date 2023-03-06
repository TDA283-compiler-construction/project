
typedef struct Big *big;

struct Big {
  int x01;
  int x02;
  int x03;
  int x04;
  int x05;
  int x06;
  int x07;
  int x08;
  int x09;
  int x10;
};

int main() {
  big b01 = new Big;
  big b02 = new Big;

  b01->x01 = 1;
  b01->x02 = 2;
  b01->x03 = 3;
  b01->x04 = 4;
  b01->x05 = 5;
  b01->x06 = 6;
  b01->x07 = 7;
  b01->x08 = 8;
  b01->x09 = 9;
  b01->x10 = 10;

  b02->x01 = 11;
  b02->x02 = 12;
  b02->x03 = 13;
  b02->x04 = 14;
  b02->x05 = 15;
  b02->x06 = 16;
  b02->x07 = 17;
  b02->x08 = 18;
  b02->x09 = 19;
  b02->x10 = 20;

  printInt(b01->x01);
  printInt(b01->x02);
  printInt(b01->x03);
  printInt(b01->x04);
  printInt(b01->x05);
  printInt(b01->x06);
  printInt(b01->x07);
  printInt(b01->x08);
  printInt(b01->x09);
  printInt(b01->x10);

  printInt(b02->x01);
  printInt(b02->x02);
  printInt(b02->x03);
  printInt(b02->x04);
  printInt(b02->x05);
  printInt(b02->x06);
  printInt(b02->x07);
  printInt(b02->x08);
  printInt(b02->x09);
  printInt(b02->x10);

  return 0;
}
