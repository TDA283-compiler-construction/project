int main() {
    // bool operations with doubles
    double y = readDouble();
    printDouble(1.01325e5);
    printDouble(y);
    if (1.01325e5 == y && 1.01325e5 <= y && 1.01325e5 >= y) {
         printInt(1);
    }

    if (0.01325e5 > y && y < 0.01325e5 && y != 0.01325e5) {
    }
    else{
         printInt(2);
    }
    return 0;

}
