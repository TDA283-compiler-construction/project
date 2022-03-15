
int main(){
    printInt(foo(12) + foo(34));
    return 0;
}

int foo(int x) {
    printInt(x);
    return x;
}