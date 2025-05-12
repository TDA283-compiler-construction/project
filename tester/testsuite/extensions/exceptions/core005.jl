class ExceptionEx extends Exception {
    int value;

    int getValue() { return value; }
    void setValue(int value) { self.value = value; }
}

int main() {
    try {
        ExceptionEx e = new ExceptionEx;
        e.setValue(10);
        throw e;
    } catch (ExceptionEx e) {
        printInt(e.getValue());
    } finally {
        printString("clean up");
    }
    return 0;
}
