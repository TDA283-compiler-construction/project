int main() {
    int[][] xss = new int[f()][g()];

    for(int xs : xss[f()])
        printString("loop");

    return 0;
}

int f() {
    printString("f");
    return 5;
}

int g() {
    printString("g");
    return 3;
}
