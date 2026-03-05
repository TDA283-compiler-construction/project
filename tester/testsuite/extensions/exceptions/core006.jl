int main() {
    try {
        printString("body");
    } finally {
        printString("clean up");
    }
    return 0;
}
