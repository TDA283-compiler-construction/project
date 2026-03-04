void foo() {
    throw new Exception;
}

int main() {
    foo();
    printString("This should not have happened!");
    return 1;
}
