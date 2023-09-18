class A {

}

class B extends A {

}

void foo(B b) {
    return;
}

int main() {
    A a = new A;
    foo(a);
    return 1;
}
