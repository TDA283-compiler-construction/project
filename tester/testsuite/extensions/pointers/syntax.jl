typedef struct A* A;

struct A {
    int a;
    A b;
};

int main () {
    printInt((new A)->a);
    (new A)->b = new A;
    return 0;
}
