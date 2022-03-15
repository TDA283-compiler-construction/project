
int main(){
    printInt(bar(foo(1), foo(2), foo(3)));
    return 0;
}

int foo(int x) {
    printInt(x);
    return x;
}

int bar(int x, int y, int z) {
    return x + y + z;
}