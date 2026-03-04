struct A {
    int x;
}

int main() {
    (a().x)++;
    (a().x)--;
    return 0;
}

A a() {
    printString("A");
    return new A;
}
