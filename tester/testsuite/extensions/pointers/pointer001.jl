struct A {
    int x;
};

typedef struct A* A;

int main() {
    a()->x++;
    a()->x--;

    return 0;
}

A a() {
    printString("A");
    return new A;
}
