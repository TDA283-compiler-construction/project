class A {
    int x;

    void set(int a) {
        x=a;
    }

    int get() {
        return x;
    }
}

A init(int x) {
    A a = new A;
    a.set(x);
    return a;
}

int main() {
    A[] as = new A[5];

    int i = 0;
    while(i < as.length) {
        as[i] = init(i);
        i++;
    }

    for(A a : as) {
        printInt(a.get());
    }

    return 0;
}
