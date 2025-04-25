class SubException extends Exception {
}

int main() {
    try {
        throw new Exception;
    } catch (SubException e) {
        printString("Caught SubException!");
    } catch (Exception e) {
        printString("Caught Exception!");
    }

    try {
        throw new SubException;
    } catch (Exception e) {
        printString("Caught!");
        return 0;
    }
    printString("Missed!");
    return 1;
}
