class ExceptionEx extends Exception {
    int value;

    int getValue() { return value; }
    void setValue(int value) { self.value = value; }
}

void foo() {
    try {
        throw new Exception;
    } catch (ExceptionEx e) {
        printInt(e.getValue());
    } finally {
        printString("clean up");
    }
}

int main() {
    try {
        foo();
    } catch (Exception e) {
        printString("catch");
    }
    return 0;
}
