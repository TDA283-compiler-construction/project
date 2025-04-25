void foo() {
    throw new Exception;
}

int main() {
    try {
        foo();
    } catch (Exception e) {
        printString("Caught!");
        return 0;
    }
    printString("Missed!");
    return 1;
}
