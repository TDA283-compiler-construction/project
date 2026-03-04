int main() {
    try {
        throw new Exception;
    } catch (Exception e) {
        printString("Caught!");
        return 0;
    }
    printString("Missed!");
    return 1;
}
