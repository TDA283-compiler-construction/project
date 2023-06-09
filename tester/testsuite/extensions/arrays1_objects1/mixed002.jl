class A {
    int[] xs;

    void set(int[] as) {
        xs = as;
    }

    int[] get() {
        return xs;
    }

    int getIndex(int n) {
        return xs[n];
    }

}

A init(int n) {
    A a = new A;

    int[] xs = new int[n];
    int i = 0;
    while(i < xs.length) {
        xs[i] = i;
        i++;
    }

    a.set(xs);

    return a;
}

int main() {

    A a = init(4);

    for(int x : a.get())
        printInt(x);

    int i = 0;
    while(i < a.get().length) {
        printInt(a.getIndex(i));
        i++;
    }

    return 0;
}
