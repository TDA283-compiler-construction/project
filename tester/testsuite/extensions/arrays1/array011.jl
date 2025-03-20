int main() {
    for(int x : f(5)) {
        printInt(x);
    }
    return 0;
}

int[] f(int n) {
    printString("f");
    return new int[n];
}
